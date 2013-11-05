From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 2/3] netfilter: ip6_tables: use reasm skb for matching
Date: Tue,  5 Nov 2013 12:02:12 +0100
Message-ID: <1383649333-6321-3-git-send-email-jiri@resnulli.us>
References: <1383649333-6321-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, pablo@netfilter.org,
	netfilter-devel@vger.kernel.org, yoshfuji@linux-ipv6.org,
	kadlec@blackhole.kfki.hu, kaber@trash.net, mleitner@redhat.com,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, wensong@linux-vs.org,
	horms@verge.net.au, ja@ssi.bg, edumazet@google.com,
	pshelar@nicira.com, jasowang@redhat.com,
	alexander.h.duyck@intel.com, coreteam@netfilter.org, fw@strlen.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f169.google.com ([209.85.215.169]:60355 "EHLO
	mail-ea0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753548Ab3KELCW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Nov 2013 06:02:22 -0500
Received: by mail-ea0-f169.google.com with SMTP id k11so4094992eaj.14
        for <netdev@vger.kernel.org>; Tue, 05 Nov 2013 03:02:21 -0800 (PST)
In-Reply-To: <1383649333-6321-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
 net/ipv6/netfilter/ip6_tables.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index 710238f..ec9cb1a 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -328,6 +328,10 @@ ip6t_do_table(struct sk_buff *skb,
 	const struct xt_table_info *private;
 	struct xt_action_param acpar;
 	unsigned int addend;
+	struct sk_buff *reasm = skb_nfct_reasm(skb);
+
+	if (!reasm)
+		reasm = skb;
 
 	/* Initialization */
 	indev = in ? in->name : nulldevname;
@@ -368,7 +372,7 @@ ip6t_do_table(struct sk_buff *skb,
 
 		IP_NF_ASSERT(e);
 		acpar.thoff = 0;
-		if (!ip6_packet_match(skb, indev, outdev, &e->ipv6,
+		if (!ip6_packet_match(reasm, indev, outdev, &e->ipv6,
 		    &acpar.thoff, &acpar.fragoff, &acpar.hotdrop)) {
  no_match:
 			e = ip6t_next_entry(e);
@@ -378,7 +382,7 @@ ip6t_do_table(struct sk_buff *skb,
 		xt_ematch_foreach(ematch, e) {
 			acpar.match     = ematch->u.kernel.match;
 			acpar.matchinfo = ematch->data;
-			if (!acpar.match->match(skb, &acpar))
+			if (!acpar.match->match(reasm, &acpar))
 				goto no_match;
 		}
 
-- 
1.8.3.1
