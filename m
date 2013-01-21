From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH net-next 13/19] ndisc: Make ndisc_fill_xxx_option() for sk_buff.
Date: Tue, 22 Jan 2013 01:48:53 +0900
Message-ID: <50FD7175.9050704@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:50367 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753079Ab3AUQsy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 11:48:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/ndisc.c |   33 +++++++++++++++------------------
 1 file changed, 15 insertions(+), 18 deletions(-)

diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index c2b16ff..ed78644 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -143,12 +143,12 @@ struct neigh_table nd_tbl = {
 	.gc_thresh3 =	1024,
 };
 
-static u8 *ndisc_fill_addr_option(u8 *opt, int type, void *data,
-				  struct net_device *dev)
+static void ndisc_fill_addr_option(struct sk_buff *skb, int type, void *data)
 {
-	int pad   = ndisc_addr_option_pad(dev->type);
-	int data_len = dev->addr_len;
-	int space = ndisc_opt_addr_space(dev);
+	int pad   = ndisc_addr_option_pad(skb->dev->type);
+	int data_len = skb->dev->addr_len;
+	int space = ndisc_opt_addr_space(skb->dev);
+	u8 *opt = skb_put(skb, space);
 
 	opt[0] = type;
 	opt[1] = space>>3;
@@ -162,7 +162,6 @@ static u8 *ndisc_fill_addr_option(u8 *opt, int type, void *data,
 	opt += data_len;
 	if ((space -= data_len) > 0)
 		memset(opt, 0, space);
-	return opt + space;
 }
 
 static struct nd_opt_hdr *ndisc_next_option(struct nd_opt_hdr *cur,
@@ -440,7 +439,7 @@ static struct sk_buff *ndisc_build_skb(struct net_device *dev,
 	if (!skb)
 		return NULL;
 
-	skb_put(skb, len + optlen);
+	skb_put(skb, len);
 
 	hdr = (struct icmp6hdr *)skb_transport_header(skb);
 	memcpy(hdr, icmp6h, sizeof(*hdr));
@@ -452,7 +451,7 @@ static struct sk_buff *ndisc_build_skb(struct net_device *dev,
 	}
 
 	if (llinfo)
-		ndisc_fill_addr_option(opt, llinfo, dev->dev_addr, dev);
+		ndisc_fill_addr_option(skb, llinfo, dev->dev_addr);
 
 	hdr->icmp6_cksum = csum_ipv6_magic(saddr, daddr, skb->len,
 					   IPPROTO_ICMPV6,
@@ -1379,17 +1378,18 @@ static void ndisc_redirect_rcv(struct sk_buff *skb)
 	icmpv6_notify(skb, NDISC_REDIRECT, 0, 0);
 }
 
-static u8 *ndisc_fill_redirect_hdr_option(u8 *opt, struct sk_buff *orig_skb,
-					  int rd_len)
+static void ndisc_fill_redirect_hdr_option(struct sk_buff *skb,
+					   struct sk_buff *orig_skb,
+					   int rd_len)
 {
+	u8 *opt = skb_put(skb, rd_len);
+
 	memset(opt, 0, 8);
 	*(opt++) = ND_OPT_REDIRECT_HDR;
 	*(opt++) = (rd_len >> 3);
 	opt += 6;
 
 	memcpy(opt, ipv6_hdr(orig_skb), rd_len - 8);
-
-	return opt + rd_len - 8;
 }
 
 void ndisc_send_redirect(struct sk_buff *skb, const struct in6_addr *target)
@@ -1406,7 +1406,6 @@ void ndisc_send_redirect(struct sk_buff *skb, const struct in6_addr *target)
 	struct dst_entry *dst;
 	struct inet6_dev *idev;
 	struct flowi6 fl6;
-	u8 *opt;
 	int rd_len;
 	int err;
 	u8 ha_buf[MAX_ADDR_LEN], *ha = NULL;
@@ -1481,7 +1480,7 @@ void ndisc_send_redirect(struct sk_buff *skb, const struct in6_addr *target)
 	if (!buff)
 		goto release;
 
-	skb_put(buff, sizeof(*msg) + optlen);
+	skb_put(buff, sizeof(*msg));
 	msg = (struct rd_msg *)icmp6_hdr(buff);
 
 	memset(&msg->icmph, 0, sizeof(struct icmp6hdr));
@@ -1494,21 +1493,19 @@ void ndisc_send_redirect(struct sk_buff *skb, const struct in6_addr *target)
 	msg->target = *target;
 	msg->dest = ipv6_hdr(skb)->daddr;
 
-	opt = msg->opt;
-
 	/*
 	 *	include target_address option
 	 */
 
 	if (ha)
-		opt = ndisc_fill_addr_option(opt, ND_OPT_TARGET_LL_ADDR, ha, dev);
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
