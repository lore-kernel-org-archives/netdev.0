From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH 23/44] [IPV6]: Allow to replace skbuff by TLV parser.
Date: Thu, 24 Aug 2006 00:02:24 +0900
Message-ID: <1156345366549-git-send-email-yoshfuji@linux-ipv6.org>
References: <11563453651167-git-send-email-yoshfuji@linux-ipv6.org> <11563453651533-git-send-email-yoshfuji@linux-ipv6.org> <11563453653169-git-send-email-yoshfuji@linux-ipv6.org> <1156345365325-git-send-email-yoshfuji@linux-ipv6.org> <11563453653851-git-send-email-yoshfuji@linux-ipv6.org> <11563453653575-git-send-email-yoshfuji@linux-ipv6.org> <1156345365651-git-send-email-yoshfuji@linux-ipv6.org> <1156345365264-git-send-email-yoshfuji@linux-ipv6.org> <1156345365312-git-send-email-yoshfuji@linux-ipv6.org> <11563453652646-git-send-email-yoshfuji@linux-ipv6.org> <1156345365315-git-send-email-yoshfuji@linux-ipv6.org> <11563453651452-git-send-email-yoshfuji@linux-ipv6.org> <1156345366288-git-send-email-yoshfuji@linux-ipv6.org> <1156345366857-git-send-email-yoshfuji@linux-ipv6.org> <11563453663761-git-send-email-yoshfuji@linux-ipv6.org> <11563453662321-git-send-email-yoshfuji@linux-ipv6.org>
  <11563453661892-git-send-email-yoshfuji@linux-ipv6.org> <11563453661207-git-send-email-yoshfuji@linux-ipv6.org> <11563453663743-git-send-email-yoshfuji@linux-ipv6.org> <1156345366676-git-send-email-yoshfuji@linux-ipv6.org> <11563453662840-git-send-email-yoshfuji@linux-ipv6.org> <11563453662913-git-send-email-yoshfuji@linux-ipv6.org> <11563453663400-git-send-email-yoshfuji@linux-ipv6.org>
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org,
	Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pc9.nezu.wide.ad.jp ([203.178.142.216]:4489 "EHLO
	jupiter.linux-ipv6.org") by vger.kernel.org with ESMTP
	id S964934AbWHWPCv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 11:02:51 -0400
To: davem@davemloft.net
In-Reply-To: <11563453663400-git-send-email-yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Masahide NAKAMURA <nakam@linux-ipv6.org>

In receiving Mobile IPv6 home address option which is a TLV carried
by destination options header, kernel will try to mangle source adderss
of packet. Think of cloned skbuff it is required to replace it by
the parser just like routing header case.
This is a framework to achieve that to allow TLV parser to replace
inbound skbuff pointer.

Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 include/net/ipv6.h   |    2 +-
 net/ipv6/exthdrs.c   |   29 +++++++++++++++++++----------
 net/ipv6/ip6_input.c |    2 +-
 3 files changed, 21 insertions(+), 12 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index c4ea127..8e6ec60 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -229,7 +229,7 @@ extern int 			ip6_ra_control(struct sock
 					       void (*destructor)(struct sock *));
 
 
-extern int			ipv6_parse_hopopts(struct sk_buff *skb);
+extern int			ipv6_parse_hopopts(struct sk_buff **skbp);
 
 extern struct ipv6_txoptions *  ipv6_dup_options(struct sock *sk, struct ipv6_txoptions *opt);
 extern struct ipv6_txoptions *	ipv6_renew_options(struct sock *sk, struct ipv6_txoptions *opt,
diff --git a/net/ipv6/exthdrs.c b/net/ipv6/exthdrs.c
index 72e8175..fc972c1 100644
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
@@ -517,8 +521,10 @@ EXPORT_SYMBOL_GPL(ipv6_invert_rthdr);
 
 /* Router Alert as of RFC 2711 */
 
-static int ipv6_hop_ra(struct sk_buff *skb, int optoff)
+static int ipv6_hop_ra(struct sk_buff **skbp, int optoff)
 {
+	struct sk_buff *skb = *skbp;
+
 	if (skb->nh.raw[optoff+1] == 2) {
 		IP6CB(skb)->ra = optoff;
 		return 1;
@@ -531,8 +537,9 @@ static int ipv6_hop_ra(struct sk_buff *s
 
 /* Jumbo payload */
 
-static int ipv6_hop_jumbo(struct sk_buff *skb, int optoff)
+static int ipv6_hop_jumbo(struct sk_buff **skbp, int optoff)
 {
+	struct sk_buff *skb = *skbp;
 	u32 pkt_len;
 
 	if (skb->nh.raw[optoff+1] != 4 || (optoff&3) != 2) {
@@ -581,8 +588,9 @@ static struct tlvtype_proc tlvprochopopt
 	{ -1, }
 };
 
-int ipv6_parse_hopopts(struct sk_buff *skb)
+int ipv6_parse_hopopts(struct sk_buff **skbp)
 {
+	struct sk_buff *skb = *skbp;
 	struct inet6_skb_parm *opt = IP6CB(skb);
 
 	/*
@@ -598,7 +606,8 @@ int ipv6_parse_hopopts(struct sk_buff *s
 	}
 
 	opt->hop = sizeof(struct ipv6hdr);
-	if (ip6_parse_tlv(tlvprochopopt_lst, skb)) {
+	if (ip6_parse_tlv(tlvprochopopt_lst, skbp)) {
+		skb = *skbp;
 		skb->h.raw += (skb->h.raw[1]+1)<<3;
 		opt->nhoff = sizeof(struct ipv6hdr);
 		return 1;
diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
index 25c2a9e..6b8e6d7 100644
--- a/net/ipv6/ip6_input.c
+++ b/net/ipv6/ip6_input.c
@@ -111,7 +111,7 @@ int ipv6_rcv(struct sk_buff *skb, struct
 	}
 
 	if (hdr->nexthdr == NEXTHDR_HOP) {
-		if (ipv6_parse_hopopts(skb) < 0) {
+		if (ipv6_parse_hopopts(&skb) < 0) {
 			IP6_INC_STATS_BH(IPSTATS_MIB_INHDRERRORS);
 			return 0;
 		}
-- 
1.4.0

