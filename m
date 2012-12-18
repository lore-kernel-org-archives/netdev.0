From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [GIT PULL net-next 12/17] ndisc: Make ndisc_fill_xxx_option() for
 sk_buff.
Date: Tue, 18 Dec 2012 19:55:56 +0900
Message-ID: <50D04BBC.1070407@linux-ipv6.org>
References: <50CF84A5.7030706@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:56632 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754695Ab2LRKz5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Dec 2012 05:55:57 -0500
In-Reply-To: <50CF84A5.7030706@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/ndisc.c |   32 ++++++++++++++------------------
 1 file changed, 14 insertions(+), 18 deletions(-)

diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 1100559..5458aed 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -148,11 +148,12 @@ static inline int ndisc_opt_addr_space(struct net_device *dev)
 	return NDISC_OPT_SPACE(dev->addr_len + ndisc_addr_option_pad(dev->type));
 }
 
-static u8 *ndisc_fill_addr_option(u8 *opt, int type, void *data, int data_len,
-				  unsigned short addr_type)
+static void ndisc_fill_addr_option(struct sk_buff *skb, int type, void *data)
 {
-	int pad   = ndisc_addr_option_pad(addr_type);
+	int data_len = skb->dev->addr_len;
+	int pad   = ndisc_addr_option_pad(skb->dev->type);
 	int space = NDISC_OPT_SPACE(data_len + pad);
+	u8 *opt = __skb_put(skb, space);
 
 	opt[0] = type;
 	opt[1] = space>>3;
@@ -166,7 +167,6 @@ static u8 *ndisc_fill_addr_option(u8 *opt, int type, void *data, int data_len,
 	opt += data_len;
 	if ((space -= data_len) > 0)
 		memset(opt, 0, space);
-	return opt + space;
 }
 
 static struct nd_opt_hdr *ndisc_next_option(struct nd_opt_hdr *cur,
@@ -436,7 +436,7 @@ static struct sk_buff *ndisc_build_skb(struct net_device *dev,
 	if (!skb)
 		return NULL;
 
-	skb_put(skb, len + optlen);
+	skb_put(skb, len);
 
 	hdr = (struct icmp6hdr *)skb_transport_header(skb);
 	memcpy(hdr, icmp6h, sizeof(*hdr));
@@ -448,8 +448,7 @@ static struct sk_buff *ndisc_build_skb(struct net_device *dev,
 	}
 
 	if (llinfo)
-		ndisc_fill_addr_option(opt, llinfo, dev->dev_addr,
-				       dev->addr_len, dev->type);
+		ndisc_fill_addr_option(skb, llinfo, dev->dev_addr);
 
 	hdr->icmp6_cksum = csum_ipv6_magic(saddr, daddr, skb->len,
 					   IPPROTO_ICMPV6,
@@ -1360,17 +1359,18 @@ static void ndisc_redirect_rcv(struct sk_buff *skb)
 	icmpv6_notify(skb, NDISC_REDIRECT, 0, 0);
 }
 
-static u8 *ndisc_fill_redirect_hdr_option(u8 *opt, struct sk_buff *orig_skb,
-					  int rd_len)
+static void ndisc_fill_redirect_hdr_option(struct sk_buff *skb,
+					   struct sk_buff *orig_skb,
+					   int rd_len)
 {
+	u8 *opt = __skb_put(skb, rd_len);
+
 	memset(opt, 0, 8);
 	*(opt++) = ND_OPT_REDIRECT_HDR;
 	*(opt++) = (rd_len >> 3);
 	opt += 6;
 
 	memcpy(opt, ipv6_hdr(orig_skb), rd_len - 8);
-
-	return opt;
 }
 
 void ndisc_send_redirect(struct sk_buff *skb, const struct in6_addr *target)
@@ -1386,7 +1386,6 @@ void ndisc_send_redirect(struct sk_buff *skb, const struct in6_addr *target)
 	struct rt6_info *rt;
 	struct dst_entry *dst;
 	struct flowi6 fl6;
-	u8 *opt;
 	int rd_len;
 	u8 ha_buf[MAX_ADDR_LEN], *ha = NULL;
 	bool ret;
@@ -1460,7 +1459,7 @@ void ndisc_send_redirect(struct sk_buff *skb, const struct in6_addr *target)
 	if (!buff)
 		goto release;
 
-	skb_put(buff, sizeof(struct red_msg) + optlen);
+	skb_put(buff, sizeof(struct red_msg));
 	msg = (struct red_msg *)icmp6_hdr(buff);
 
 	memset(&msg->icmph, 0, sizeof(struct icmp6hdr));
@@ -1473,22 +1472,19 @@ void ndisc_send_redirect(struct sk_buff *skb, const struct in6_addr *target)
 	msg->target = *target;
 	msg->dest = ipv6_hdr(skb)->daddr;
 
-	opt = msg->opt;
-
 	/*
 	 *	include target_address option
 	 */
 
 	if (ha)
-		opt = ndisc_fill_addr_option(opt, ND_OPT_TARGET_LL_ADDR, ha,
-					     dev->addr_len, dev->type);
+		ndisc_fill_addr_option(skb, ND_OPT_TARGET_LL_ADDR, ha);
 
 	/*
 	 *	build redirect option and copy skb over to the new packet.
 	 */
 
 	if (rd_len)
-		opt = ndisc_fill_redirect_hdr_option(opt, skb, rd_len);
+		ndisc_fill_redirect_hdr_option(buff, skb, rd_len);
 
 	msg->icmph.icmp6_cksum = csum_ipv6_magic(&saddr_buf, &ipv6_hdr(skb)->saddr,
 						 buff->len, IPPROTO_ICMPV6,
-- 
1.7.9.5
