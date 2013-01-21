From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH net-next 05/19] ndisc: Introduce ndisc_alloc_skb() helper.
Date: Tue, 22 Jan 2013 01:48:14 +0900
Message-ID: <50FD714E.8080107@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:50343 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752233Ab3AUQsP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 11:48:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/ndisc.c |   52 +++++++++++++++++++++++++++-------------------------
 1 file changed, 27 insertions(+), 25 deletions(-)

diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 53a545f..1776a0d 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -366,6 +366,29 @@ static void pndisc_destructor(struct pneigh_entry *n)
 	ipv6_dev_mc_dec(dev, &maddr);
 }
 
+static struct sk_buff *ndisc_alloc_skb(struct net_device *dev,
+				       int len)
+{
+	int hlen = LL_RESERVED_SPACE(dev);
+	int tlen = dev->needed_tailroom;
+	struct sock *sk = dev_net(dev)->ipv6.ndisc_sk;
+	struct sk_buff *skb;
+	int err;
+
+	skb = sock_alloc_send_skb(sk,
+				  hlen + sizeof(struct ipv6hdr) + len + tlen,
+				  1, &err);
+	if (!skb) {
+		ND_PRINTK(0, err, "ndisc: %s failed to allocate an skb, err=%d\n",
+			  __func__, err);
+		return NULL;
+	}
+
+	skb_reserve(skb, hlen);
+
+	return skb;
+}
+
 static struct sk_buff *ndisc_build_skb(struct net_device *dev,
 				       const struct in6_addr *daddr,
 				       const struct in6_addr *saddr,
@@ -377,10 +400,7 @@ static struct sk_buff *ndisc_build_skb(struct net_device *dev,
 	struct sock *sk = net->ipv6.ndisc_sk;
 	struct sk_buff *skb;
 	struct icmp6hdr *hdr;
-	int hlen = LL_RESERVED_SPACE(dev);
-	int tlen = dev->needed_tailroom;
 	int len;
-	int err;
 	u8 *opt;
 
 	if (!dev->addr_len)
@@ -390,17 +410,10 @@ static struct sk_buff *ndisc_build_skb(struct net_device *dev,
 	if (llinfo)
 		len += ndisc_opt_addr_space(dev);
 
-	skb = sock_alloc_send_skb(sk,
-				  (sizeof(struct ipv6hdr) +
-				   len + hlen + tlen),
-				  1, &err);
-	if (!skb) {
-		ND_PRINTK(0, err, "ND: %s failed to allocate an skb, err=%d\n",
-			  __func__, err);
+	skb = ndisc_alloc_skb(dev, len);
+	if (!skb)
 		return NULL;
-	}
 
-	skb_reserve(skb, hlen);
 	ip6_nd_hdr(sk, skb, dev, saddr, daddr, IPPROTO_ICMPV6, len);
 
 	skb->transport_header = skb->tail;
@@ -1369,7 +1382,6 @@ void ndisc_send_redirect(struct sk_buff *skb, const struct in6_addr *target)
 	struct inet6_dev *idev;
 	struct flowi6 fl6;
 	u8 *opt;
-	int hlen, tlen;
 	int rd_len;
 	int err;
 	u8 ha_buf[MAX_ADDR_LEN], *ha = NULL;
@@ -1439,20 +1451,10 @@ void ndisc_send_redirect(struct sk_buff *skb, const struct in6_addr *target)
 	rd_len &= ~0x7;
 	len += rd_len;
 
-	hlen = LL_RESERVED_SPACE(dev);
-	tlen = dev->needed_tailroom;
-	buff = sock_alloc_send_skb(sk,
-				   (sizeof(struct ipv6hdr) +
-				    len + hlen + tlen),
-				   1, &err);
-	if (buff == NULL) {
-		ND_PRINTK(0, err,
-			  "Redirect: %s failed to allocate an skb, err=%d\n",
-			  __func__, err);
+	buff = ndisc_alloc_skb(dev, len);
+	if (!buff)
 		goto release;
-	}
 
-	skb_reserve(buff, hlen);
 	ip6_nd_hdr(sk, buff, dev, &saddr_buf, &ipv6_hdr(skb)->saddr,
 		   IPPROTO_ICMPV6, len);
 
-- 
1.7.9.5
