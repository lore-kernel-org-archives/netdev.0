From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next] net, cls: allow for deleting all filters for given parent
Date: Sat,  4 Jun 2016 18:24:23 +0200
Message-ID: <cd8455dfef0cccec5ef0a1ca2d1f678e9397d66e.1465056745.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, john.fastabend@gmail.com,
	jhs@mojatatu.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:50238 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750996AbcFDQYh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Jun 2016 12:24:37 -0400
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

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 net/sched/cls_api.c | 24 ++++++++++++++++++++----
 1 file changed, 20 insertions(+), 4 deletions(-)

diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index a75864d..caa1dd4 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -156,11 +156,22 @@ replay:
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
+		default:
 			return -ENOENT;
-		prio = TC_H_MAKE(0x80000000U, 0U);
+		}
 	}
 
 	/* Find head of filter chain. */
@@ -200,6 +211,11 @@ replay:
 	err = -EINVAL;
 	if (chain == NULL)
 		goto errout;
+	if (n->nlmsg_type == RTM_DELTFILTER && prio == 0) {
+		tcf_destroy_chain(chain);
+		err = 0;
+		goto errout;
+	}
 
 	/* Check the chain for existence of proto-tcf with this priority */
 	for (back = chain;
-- 
1.9.3
