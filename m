From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH 25/44] [IPV6] MIP6: Add inbound interface of home address option.
Date: Thu, 24 Aug 2006 00:02:26 +0900
Message-ID: <11563453661764-git-send-email-yoshfuji@linux-ipv6.org>
References: <11563453651167-git-send-email-yoshfuji@linux-ipv6.org> <11563453651533-git-send-email-yoshfuji@linux-ipv6.org> <11563453653169-git-send-email-yoshfuji@linux-ipv6.org> <1156345365325-git-send-email-yoshfuji@linux-ipv6.org> <11563453653851-git-send-email-yoshfuji@linux-ipv6.org> <11563453653575-git-send-email-yoshfuji@linux-ipv6.org> <1156345365651-git-send-email-yoshfuji@linux-ipv6.org> <1156345365264-git-send-email-yoshfuji@linux-ipv6.org> <1156345365312-git-send-email-yoshfuji@linux-ipv6.org> <11563453652646-git-send-email-yoshfuji@linux-ipv6.org> <1156345365315-git-send-email-yoshfuji@linux-ipv6.org> <11563453651452-git-send-email-yoshfuji@linux-ipv6.org> <1156345366288-git-send-email-yoshfuji@linux-ipv6.org> <1156345366857-git-send-email-yoshfuji@linux-ipv6.org> <11563453663761-git-send-email-yoshfuji@linux-ipv6.org> <11563453662321-git-send-email-yoshfuji@linux-ipv6.org>
  <11563453661892-git-send-email-yoshfuji@linux-ipv6.org> <11563453661207-git-send-email-yoshfuji@linux-ipv6.org> <11563453663743-git-send-email-yoshfuji@linux-ipv6.org> <1156345366676-git-send-email-yoshfuji@linux-ipv6.org> <11563453662840-git-send-email-yoshfuji@linux-ipv6.org> <11563453662913-git-send-email-yoshfuji@linux-ipv6.org> <11563453663400-git-send-email-yoshfuji@linux-ipv6.org> <1156345366549-git-send-email-yoshfuji@linux-ipv6.org> <11563453662956-git-send-email-yoshfuji@linux-ipv6.org>
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org,
	Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pc9.nezu.wide.ad.jp ([203.178.142.216]:5001 "EHLO
	jupiter.linux-ipv6.org") by vger.kernel.org with ESMTP
	id S964935AbWHWPCv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 11:02:51 -0400
To: davem@davemloft.net
In-Reply-To: <11563453662956-git-send-email-yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Masahide NAKAMURA <nakam@linux-ipv6.org>

Add inbound function of home address option by registering it to TLV table for
destination options header.
Based on MIPL2 kernel patch.

This patch was also written by: Ville Nuorvala <vnuorval@tcs.hut.fi>

Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 include/linux/ipv6.h |    3 ++
 net/ipv6/exthdrs.c   |   84 +++++++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 86 insertions(+), 1 deletions(-)

diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index c1601ef..4613a38 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -226,6 +226,9 @@ struct inet6_skb_parm {
 	__u16			dst0;
 	__u16			srcrt;
 	__u16			dst1;
+#ifdef CONFIG_IPV6_MIP6
+	__u16			dsthao;
+#endif
 	__u16			lastopt;
 	__u32			nhoff;
 	__u16			flags;
diff --git a/net/ipv6/exthdrs.c b/net/ipv6/exthdrs.c
index fc972c1..077f626 100644
--- a/net/ipv6/exthdrs.c
+++ b/net/ipv6/exthdrs.c
@@ -196,8 +196,80 @@ bad:
   Destination options header.
  *****************************/
 
+#ifdef CONFIG_IPV6_MIP6
+static int ipv6_dest_hao(struct sk_buff **skbp, int optoff)
+{
+	struct sk_buff *skb = *skbp;
+	struct ipv6_destopt_hao *hao;
+	struct inet6_skb_parm *opt = IP6CB(skb);
+	struct ipv6hdr *ipv6h = (struct ipv6hdr *)skb->nh.raw;
+	struct in6_addr tmp_addr;
+	int ret;
+
+	if (opt->dsthao) {
+		LIMIT_NETDEBUG(KERN_DEBUG "hao duplicated\n");
+		goto discard;
+	}
+	opt->dsthao = opt->dst1;
+	opt->dst1 = 0;
+
+	hao = (struct ipv6_destopt_hao *)(skb->nh.raw + optoff);
+
+	if (hao->length != 16) {
+		LIMIT_NETDEBUG(
+			KERN_DEBUG "hao invalid option length = %d\n", hao->length);
+		goto discard;
+	}
+
+	if (!(ipv6_addr_type(&hao->addr) & IPV6_ADDR_UNICAST)) {
+		LIMIT_NETDEBUG(
+			KERN_DEBUG "hao is not an unicast addr: " NIP6_FMT "\n", NIP6(hao->addr));
+		goto discard;
+	}
+
+	ret = xfrm6_input_addr(skb, (xfrm_address_t *)&ipv6h->daddr,
+			       (xfrm_address_t *)&hao->addr, IPPROTO_DSTOPTS);
+	if (unlikely(ret < 0))
+		goto discard;
+
+	if (skb_cloned(skb)) {
+		struct sk_buff *skb2 = skb_copy(skb, GFP_ATOMIC);
+		if (skb2 == NULL)
+			goto discard;
+
+		kfree_skb(skb);
+
+		/* update all variable using below by copied skbuff */
+		*skbp = skb = skb2;
+		hao = (struct ipv6_destopt_hao *)(skb2->nh.raw + optoff);
+		ipv6h = (struct ipv6hdr *)skb2->nh.raw;
+	}
+
+	if (skb->ip_summed == CHECKSUM_COMPLETE)
+		skb->ip_summed = CHECKSUM_NONE;
+
+	ipv6_addr_copy(&tmp_addr, &ipv6h->saddr);
+	ipv6_addr_copy(&ipv6h->saddr, &hao->addr);
+	ipv6_addr_copy(&hao->addr, &tmp_addr);
+
+	if (skb->tstamp.off_sec == 0)
+		__net_timestamp(skb);
+
+	return 1;
+
+ discard:
+	kfree_skb(skb);
+	return 0;
+}
+#endif
+
 static struct tlvtype_proc tlvprocdestopt_lst[] = {
-	/* No destination options are defined now */
+#ifdef CONFIG_IPV6_MIP6
+	{
+		.type	= IPV6_TLV_HAO,
+		.func	= ipv6_dest_hao,
+	},
+#endif
 	{-1,			NULL}
 };
 
@@ -205,6 +277,9 @@ static int ipv6_destopt_rcv(struct sk_bu
 {
 	struct sk_buff *skb = *skbp;
 	struct inet6_skb_parm *opt = IP6CB(skb);
+#ifdef CONFIG_IPV6_MIP6
+	__u16 dstbuf;
+#endif
 
 	if (!pskb_may_pull(skb, (skb->h.raw-skb->data)+8) ||
 	    !pskb_may_pull(skb, (skb->h.raw-skb->data)+((skb->h.raw[1]+1)<<3))) {
@@ -215,11 +290,18 @@ static int ipv6_destopt_rcv(struct sk_bu
 
 	opt->lastopt = skb->h.raw - skb->nh.raw;
 	opt->dst1 = skb->h.raw - skb->nh.raw;
+#ifdef CONFIG_IPV6_MIP6
+	dstbuf = opt->dst1;
+#endif
 
 	if (ip6_parse_tlv(tlvprocdestopt_lst, skbp)) {
 		skb = *skbp;
 		skb->h.raw += ((skb->h.raw[1]+1)<<3);
+#ifdef CONFIG_IPV6_MIP6
+		opt->nhoff = dstbuf;
+#else
 		opt->nhoff = opt->dst1;
+#endif
 		return 1;
 	}
 
-- 
1.4.0

