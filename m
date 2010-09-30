From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH] net: code cleanups
Date: Thu, 30 Sep 2010 10:24:57 +0800
Message-ID: <1285813497-7384-1-git-send-email-xiaosuo@gmail.com>
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:52312 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751770Ab0I3CZj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Sep 2010 22:25:39 -0400
Received: by gxk9 with SMTP id 9so471042gxk.19
        for <netdev@vger.kernel.org>; Wed, 29 Sep 2010 19:25:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Compare operations are more readable, and compilers generate the same code
for the both.

Use the macros fl4_* to shrink the length of the lines.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
 net/ipv4/af_inet.c |    7 +++----
 net/ipv4/route.c   |   27 ++++++++++++---------------
 2 files changed, 15 insertions(+), 19 deletions(-)
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index f581f77..ef26640 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1338,10 +1338,9 @@ static struct sk_buff **inet_gro_receive(struct sk_buff **head,
 
 		iph2 = ip_hdr(p);
 
-		if ((iph->protocol ^ iph2->protocol) |
-		    (iph->tos ^ iph2->tos) |
-		    ((__force u32)iph->saddr ^ (__force u32)iph2->saddr) |
-		    ((__force u32)iph->daddr ^ (__force u32)iph2->daddr)) {
+		if (iph->protocol != iph2->protocol || iph->tos != iph2->tos ||
+		    (__force u32)iph->saddr != (__force u32)iph2->saddr ||
+		    (__force u32)iph->daddr != (__force u32)iph2->daddr) {
 			NAPI_GRO_CB(p)->same_flow = 0;
 			continue;
 		}
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 98beda4..6b00fde 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -683,19 +683,18 @@ static inline bool rt_caching(const struct net *net)
 static inline bool compare_hash_inputs(const struct flowi *fl1,
 					const struct flowi *fl2)
 {
-	return ((((__force u32)fl1->nl_u.ip4_u.daddr ^ (__force u32)fl2->nl_u.ip4_u.daddr) |
-		((__force u32)fl1->nl_u.ip4_u.saddr ^ (__force u32)fl2->nl_u.ip4_u.saddr) |
-		(fl1->iif ^ fl2->iif)) == 0);
+	return (__force u32)fl1->fl4_dst == (__force u32)fl2->fl4_dst &&
+	       (__force u32)fl1->fl4_src == (__force u32)fl2->fl4_src &&
+	       fl1->iif == fl2->iif;
 }
 
 static inline int compare_keys(struct flowi *fl1, struct flowi *fl2)
 {
-	return (((__force u32)fl1->nl_u.ip4_u.daddr ^ (__force u32)fl2->nl_u.ip4_u.daddr) |
-		((__force u32)fl1->nl_u.ip4_u.saddr ^ (__force u32)fl2->nl_u.ip4_u.saddr) |
-		(fl1->mark ^ fl2->mark) |
-		(*(u16 *)&fl1->nl_u.ip4_u.tos ^ *(u16 *)&fl2->nl_u.ip4_u.tos) |
-		(fl1->oif ^ fl2->oif) |
-		(fl1->iif ^ fl2->iif)) == 0;
+	return (__force u32)fl1->fl4_dst == (__force u32)fl2->fl4_dst &&
+	       (__force u32)fl1->fl4_src == (__force u32)fl2->fl4_src &&
+	       fl1->mark == fl2->mark &&
+	       *(u16 *)&fl1->fl4_tos == *(u16 *)&fl2->fl4_tos &&
+	       fl1->oif == fl2->oif && fl1->iif == fl2->iif;
 }
 
 static inline int compare_netns(struct rtable *rt1, struct rtable *rt2)
@@ -2286,12 +2285,10 @@ int ip_route_input_common(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 
 	for (rth = rcu_dereference(rt_hash_table[hash].chain); rth;
 	     rth = rcu_dereference(rth->dst.rt_next)) {
-		if ((((__force u32)rth->fl.fl4_dst ^ (__force u32)daddr) |
-		     ((__force u32)rth->fl.fl4_src ^ (__force u32)saddr) |
-		     (rth->fl.iif ^ iif) |
-		     rth->fl.oif |
-		     (rth->fl.fl4_tos ^ tos)) == 0 &&
-		    rth->fl.mark == skb->mark &&
+		if ((__force u32)rth->fl.fl4_dst == (__force u32)daddr &&
+		    (__force u32)rth->fl.fl4_src == (__force u32)saddr &&
+		    rth->fl.iif == iif && rth->fl.oif == 0 &&
+		    rth->fl.fl4_tos == tos && rth->fl.mark == skb->mark &&
 		    net_eq(dev_net(rth->dst.dev), net) &&
 		    !rt_is_expired(rth)) {
 			if (noref) {
