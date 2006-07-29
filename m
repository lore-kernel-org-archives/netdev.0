From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: [PATCH 7/20] [PATCH] [IPV6]: Allow to replace skbuff by TLV parser.
Date: Sat, 29 Jul 2006 18:38:31 +0900
Message-ID: <11541659113013-git-send-email-nakam@linux-ipv6.org>
Reply-To: Masahide NAKAMURA <nakam@linux-ipv6.org>
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org,
	Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pc9.nezu.wide.ad.jp ([203.178.142.216]:41603 "EHLO jupiter")
	by vger.kernel.org with ESMTP id S1422715AbWG2Jic (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Jul 2006 05:38:32 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In receiving Mobile IPv6 home address option which is a TLV carried
by destination options header, kernel will try to mangle source adderss
of packet. Think of cloned skbuff it is required to replace it by
the parser just like routing header case.
This is a framework to achieve that to allow TLV parser to replace
inbound skbuff pointer.
---
 include/net/ipv6.h   |    2 +-
 net/ipv6/exthdrs.c   |   29 +++++++++++++++++++----------
 net/ipv6/ip6_input.c |    2 +-
 3 files changed, 21 insertions(+), 12 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 2e78433..cbe72ea 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -230,7 +230,7 @@ extern int 			ip6_ra_control(struct sock
 					       void (*destructor)(struct sock *));
 
 
-extern int			ipv6_parse_hopopts(struct sk_buff *skb);
+extern int			ipv6_parse_hopopts(struct sk_buff **skbp);
 
 extern struct ipv6_txoptions *  ipv6_dup_options(struct sock *sk, struct ipv6_txoptions *opt);
 extern struct ipv6_txoptions *	ipv6_renew_options(struct sock *sk, struct ipv6_txoptions *opt,
diff --git a/net/ipv6/exthdrs.c b/net/ipv6/exthdrs.c
index fbedad9..336992a 100644
--- a/net/ipv6/exthdrs.c
+++ b/net/ipv6/exthdrs.c
@@ -102,7 +102,7 @@ int ipv6_find_tlv(struct sk_buff *skb, i
 
 struct tlvtype_proc {
 	int	type;
-	int	(*func)(struct sk_buff *skb, int offset);
+	int	(*func)(struct sk_buff **skbp, int offset);
 };
 
 /*********************
@@ -111,8 +111,10 @@ struct tlvtype_proc {
 
 /* An unknown option is detected, decide what to do */
 
-static int ip6_tlvopt_unknown(struct sk_buff *skb, int optoff)
+static int ip6_tlvopt_unknown(struct sk_buff **skbp, int optoff)
 {
+	struct sk_buff *skb = *skbp;
+
 	switch ((skb->nh.raw[optoff] & 0xC0) >> 6) {
 	case 0: /* ignore */
 		return 1;
@@ -137,8 +139,9 @@ static int ip6_tlvopt_unknown(struct sk_
 
 /* Parse tlv encoded option header (hop-by-hop or destination) */
 
-static int ip6_parse_tlv(struct tlvtype_proc *procs, struct sk_buff *skb)
+static int ip6_parse_tlv(struct tlvtype_proc *procs, struct sk_buff **skbp)
 {
+	struct sk_buff *skb = *skbp;
 	struct tlvtype_proc *curr;
 	int off = skb->h.raw - skb->nh.raw;
 	int len = ((skb->h.raw[1]+1)<<3);
@@ -168,13 +171,13 @@ static int ip6_parse_tlv(struct tlvtype_
 					/* type specific length/alignment 
 					   checks will be performed in the 
 					   func(). */
-					if (curr->func(skb, off) == 0)
+					if (curr->func(skbp, off) == 0)
 						return 0;
 					break;
 				}
 			}
 			if (curr->type < 0) {
-				if (ip6_tlvopt_unknown(skb, off) == 0)
+				if (ip6_tlvopt_unknown(skbp, off) == 0)
 					return 0;
 			}
 			break;
@@ -213,7 +216,8 @@ static int ipv6_destopt_rcv(struct sk_bu
 	opt->lastopt = skb->h.raw - skb->nh.raw;
 	opt->dst1 = skb->h.raw - skb->nh.raw;
 
-	if (ip6_parse_tlv(tlvprocdestopt_lst, skb)) {
+	if (ip6_parse_tlv(tlvprocdestopt_lst, skbp)) {
+		skb = *skbp;
 		skb->h.raw += ((skb->h.raw[1]+1)<<3);
 		opt->nhoff = opt->dst1;
 		return 1;
@@ -519,8 +523,10 @@ EXPORT_SYMBOL_GPL(ipv6_invert_rthdr);
 
 /* Router Alert as of RFC 2711 */
 
-static int ipv6_hop_ra(struct sk_buff *skb, int optoff)
+static int ipv6_hop_ra(struct sk_buff **skbp, int optoff)
 {
+	struct sk_buff *skb = *skbp;
+
 	if (skb->nh.raw[optoff+1] == 2) {
 		IP6CB(skb)->ra = optoff;
 		return 1;
@@ -533,8 +539,9 @@ static int ipv6_hop_ra(struct sk_buff *s
 
 /* Jumbo payload */
 
-static int ipv6_hop_jumbo(struct sk_buff *skb, int optoff)
+static int ipv6_hop_jumbo(struct sk_buff **skbp, int optoff)
 {
+	struct sk_buff *skb = *skbp;
 	u32 pkt_len;
 
 	if (skb->nh.raw[optoff+1] != 4 || (optoff&3) != 2) {
@@ -583,8 +590,9 @@ static struct tlvtype_proc tlvprochopopt
 	{ -1, }
 };
 
-int ipv6_parse_hopopts(struct sk_buff *skb)
+int ipv6_parse_hopopts(struct sk_buff **skbp)
 {
+	struct sk_buff *skb = *skbp;
 	struct inet6_skb_parm *opt = IP6CB(skb);
 
 	/*
@@ -600,7 +608,8 @@ int ipv6_parse_hopopts(struct sk_buff *s
 	}
 
 	opt->hop = sizeof(struct ipv6hdr);
-	if (ip6_parse_tlv(tlvprochopopt_lst, skb)) {
+	if (ip6_parse_tlv(tlvprochopopt_lst, skbp)) {
+		skb = *skbp;
 		skb->h.raw += (skb->h.raw[1]+1)<<3;
 		opt->nhoff = sizeof(struct ipv6hdr);
 		return 1;
diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
index aceee25..94cbdca 100644
--- a/net/ipv6/ip6_input.c
+++ b/net/ipv6/ip6_input.c
@@ -114,7 +114,7 @@ int ipv6_rcv(struct sk_buff *skb, struct
 	}
 
 	if (hdr->nexthdr == NEXTHDR_HOP) {
-		if (ipv6_parse_hopopts(skb) < 0) {
+		if (ipv6_parse_hopopts(&skb) < 0) {
 			IP6_INC_STATS_BH(IPSTATS_MIB_INHDRERRORS);
 			return 0;
 		}
-- 
1.4.1

