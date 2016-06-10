From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next v2] net, cls: allow for deleting all filters for given parent
Date: Fri, 10 Jun 2016 23:10:22 +0200
Message-ID: <4f60a899712d32c9c635107b4278a1b62cd18f3e.1465591897.git.daniel@iogearbox.net>
Cc: xiyou.wangcong@gmail.com, jhs@mojatatu.com,
	alexei.starovoitov@gmail.com, john.fastabend@gmail.com,
	netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:35217 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751868AbcFJVK1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jun 2016 17:10:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a possibility where the user can just specify the parent and
all filters under that parent are then being purged. Currently,
for example for scripting, one needs to specify pref/prio to have
a well-defined number for 'tc filter del' command for addressing
the previously created instance or additionally filter handle in
case of priorities being the same. Improve usage by allowing the
option for tc to specify the parent and removing the whole chain
for that given parent.

Example usage after patch, no tc changes required:

  # tc qdisc replace dev foo clsact
  # tc filter add dev foo egress bpf da obj ./bpf.o
  # tc filter add dev foo egress bpf da obj ./bpf.o
  # tc filter show dev foo egress
  filter protocol all pref 49151 bpf
  filter protocol all pref 49151 bpf handle 0x1 bpf.o:[classifier] direct-action
  filter protocol all pref 49152 bpf
  filter protocol all pref 49152 bpf handle 0x1 bpf.o:[classifier] direct-action
  # tc filter del dev foo egress
  # tc filter show dev foo egress
  #

Previously, RTM_DELTFILTER requests with invalid prio of 0 were
rejected, so only netlink requests with RTM_NEWTFILTER and NLM_F_CREATE
flag were allowed where the kernel would auto-generate a pref/prio.
We can piggyback on that and use prio of 0 as a wildcard for
requests of RTM_DELTFILTER.

For notifying tc netlink monitoring users (e.g. libnl uses this
for caching), there are two options, that is, sending individual
tfilter_notify() notifications for each tcf_proto, or sending a
single one indicating wildcard removal. I tried both and there
are pros and cons for each, eventually I decided for sending
individual tfilter_notify(), so that user space can support this
seamlessly and there won't be a mess of changing each and every
application to make sure expectations from the kernel won't break
when they don't understand single notification. Since linear chains
don't really scale, I expect only a handful of classifiers to be
attached at max for a given parent anyway.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 v1 -> v2:
  - Added notification support, thanks Cong!
  - Kept Jamal's ack from previous RFC for v2.

 net/sched/cls_api.c | 37 +++++++++++++++++++++++++++++++++----
 1 file changed, 33 insertions(+), 4 deletions(-)

diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index aafa6bce..cca1ef5 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -103,6 +103,17 @@ static int tfilter_notify(struct net *net, struct sk_buff *oskb,
 			  struct nlmsghdr *n, struct tcf_proto *tp,
 			  unsigned long fh, int event);
 
+static void tfilter_notify_chain(struct net *net, struct sk_buff *oskb,
+				 struct nlmsghdr *n,
+				 struct tcf_proto __rcu **chain, int event)
+{
+	struct tcf_proto __rcu **it_chain;
+	struct tcf_proto *tp;
+
+	for (it_chain = chain; (tp = rtnl_dereference(*it_chain)) != NULL;
+	     it_chain = &tp->next)
+		tfilter_notify(net, oskb, n, tp, 0, event);
+}
 
 /* Select new prio value from the range, managed by kernel. */
 
@@ -156,11 +167,23 @@ replay:
 	cl = 0;
 
 	if (prio == 0) {
-		/* If no priority is given, user wants we allocated it. */
-		if (n->nlmsg_type != RTM_NEWTFILTER ||
-		    !(n->nlmsg_flags & NLM_F_CREATE))
+		switch (n->nlmsg_type) {
+		case RTM_DELTFILTER:
+			if (protocol || t->tcm_handle)
+				return -ENOENT;
+			break;
+		case RTM_NEWTFILTER:
+			/* If no priority is provided by the user,
+			 * we allocate one.
+			 */
+			if (n->nlmsg_flags & NLM_F_CREATE) {
+				prio = TC_H_MAKE(0x80000000U, 0U);
+				break;
+			}
+			/* fall-through */
+		default:
 			return -ENOENT;
-		prio = TC_H_MAKE(0x80000000U, 0U);
+		}
 	}
 
 	/* Find head of filter chain. */
@@ -200,6 +223,12 @@ replay:
 	err = -EINVAL;
 	if (chain == NULL)
 		goto errout;
+	if (n->nlmsg_type == RTM_DELTFILTER && prio == 0) {
+		tfilter_notify_chain(net, skb, n, chain, RTM_DELTFILTER);
+		tcf_destroy_chain(chain);
+		err = 0;
+		goto errout;
+	}
 
 	/* Check the chain for existence of proto-tcf with this priority */
 	for (back = chain;
-- 
1.9.3
