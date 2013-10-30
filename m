From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next RFC] netfilter: ip6_tables: use reasm skb for matching
Date: Wed, 30 Oct 2013 11:50:01 +0100
Message-ID: <1383130201-6198-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, pablo@netfilter.org,
	netfilter-devel@vger.kernel.org, yoshfuji@linux-ipv6.org,
	kadlec@blackhole.kfki.hu, kaber@trash.net, mleitner@redhat.com
To: netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Currently, when ipv6 fragment goes through the netfilter, match
functions are called on them directly. This might cause match function
to fail. So benefit from the fact that nf_defrag_ipv6 constructs
reassembled skb for us and use this reassembled skb for matching.

This patch fixes for example following situation:
On HOSTA do:
ip6tables -I INPUT -p icmpv6 -j DROP
ip6tables -I INPUT -p icmpv6 -m icmp6 --icmpv6-type 128 -j ACCEPT

and on HOSTB you do:
ping6 HOSTA -s2000    (MTU is 1500)

Incoming echo requests will be filtered out on HOSTA. This issue does
not occur with smaller packets than MTU (where fragmentation does not happen).

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 net/ipv6/netfilter/ip6_tables.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index 44400c2..5421beb0 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -328,6 +328,7 @@ ip6t_do_table(struct sk_buff *skb,
 	const struct xt_table_info *private;
 	struct xt_action_param acpar;
 	unsigned int addend;
+	struct sk_buff *reasm = skb->nfct_reasm ? skb->nfct_reasm : skb;
 
 	/* Initialization */
 	indev = in ? in->name : nulldevname;
@@ -363,7 +364,7 @@ ip6t_do_table(struct sk_buff *skb,
 
 		IP_NF_ASSERT(e);
 		acpar.thoff = 0;
-		if (!ip6_packet_match(skb, indev, outdev, &e->ipv6,
+		if (!ip6_packet_match(reasm, indev, outdev, &e->ipv6,
 		    &acpar.thoff, &acpar.fragoff, &acpar.hotdrop)) {
  no_match:
 			e = ip6t_next_entry(e);
@@ -373,7 +374,7 @@ ip6t_do_table(struct sk_buff *skb,
 		xt_ematch_foreach(ematch, e) {
 			acpar.match     = ematch->u.kernel.match;
 			acpar.matchinfo = ematch->data;
-			if (!acpar.match->match(skb, &acpar))
+			if (!acpar.match->match(reasm, &acpar))
 				goto no_match;
 		}
 
-- 
1.8.3.1

