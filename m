From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [GIT PULL net-next 06/17] ndisc: Introduce ndisc_send_skb_alloc()
 for sk_buff allocation.
Date: Tue, 18 Dec 2012 19:54:18 +0900
Message-ID: <50D04B5A.70207@linux-ipv6.org>
References: <50CF84A5.7030706@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:56613 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754349Ab2LRKyT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Dec 2012 05:54:19 -0500
In-Reply-To: <50CF84A5.7030706@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/ndisc.c |   50 ++++++++++++++++++++++++++------------------------
 1 file changed, 26 insertions(+), 24 deletions(-)

diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index a293676..45ce72c 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -370,6 +370,28 @@ static void pndisc_destructor(struct pneigh_entry *n)
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
+	return skb;
+}
+
 static struct sk_buff *ndisc_build_skb(struct net_device *dev,
 				       const struct in6_addr *daddr,
 				       const struct in6_addr *saddr,
@@ -381,10 +403,7 @@ static struct sk_buff *ndisc_build_skb(struct net_device *dev,
 	struct sock *sk = net->ipv6.ndisc_sk;
 	struct sk_buff *skb;
 	struct icmp6hdr *hdr;
-	int hlen = LL_RESERVED_SPACE(dev);
-	int tlen = dev->needed_tailroom;
 	int len;
-	int err;
 	u8 *opt;
 
 	if (!dev->addr_len)
@@ -394,16 +413,10 @@ static struct sk_buff *ndisc_build_skb(struct net_device *dev,
 	if (llinfo)
 		len += ndisc_opt_addr_space(dev);
 
-	skb = sock_alloc_send_skb(sk,
-				  hlen + sizeof(struct ipv6hdr) + len + tlen,
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
@@ -1356,9 +1369,7 @@ void ndisc_send_redirect(struct sk_buff *skb, const struct in6_addr *target)
 	struct dst_entry *dst;
 	struct flowi6 fl6;
 	u8 *opt;
-	int hlen, tlen;
 	int rd_len;
-	int err;
 	u8 ha_buf[MAX_ADDR_LEN], *ha = NULL;
 	bool ret;
 
@@ -1426,19 +1437,10 @@ void ndisc_send_redirect(struct sk_buff *skb, const struct in6_addr *target)
 	rd_len &= ~0x7;
 	len += rd_len;
 
-	hlen = LL_RESERVED_SPACE(dev);
-	tlen = dev->needed_tailroom;
-	buff = sock_alloc_send_skb(sk,
-				   hlen + sizeof(struct ipv6hdr) + len + tlen,
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
