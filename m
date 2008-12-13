From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH] ipmr: merge common code
Date: Sat, 13 Dec 2008 21:59:34 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0812132151320.4160@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-1530841098-1229198374=:4160"
Cc: Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:37391 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751521AbYLMT7g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Dec 2008 14:59:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-1530841098-1229198374=:4160
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

Also removes redundant skb->len < x check which can't
be true once pskb_may_pull(skb, x) succeeded.

$ diff-funcs pim_rcv ipmr.c ipmr.c pim_rcv_v1
  --- ipmr.c:pim_rcv()
  +++ ipmr.c:pim_rcv_v1()
@@ -1,22 +1,27 @@
-static int pim_rcv(struct sk_buff * skb)
+int pim_rcv_v1(struct sk_buff * skb)
 {
-	struct pimreghdr *pim;
+	struct igmphdr *pim;
 	struct iphdr   *encap;
 	struct net_device  *reg_dev = NULL;

 	if (!pskb_may_pull(skb, sizeof(*pim) + sizeof(*encap)))
 		goto drop;

-	pim = (struct pimreghdr *)skb_transport_header(skb);
-	if (pim->type != ((PIM_VERSION<<4)|(PIM_REGISTER)) ||
-	    (pim->flags&PIM_NULL_REGISTER) ||
-	    (ip_compute_csum((void *)pim, sizeof(*pim)) != 0 &&
-	     csum_fold(skb_checksum(skb, 0, skb->len, 0))))
+	pim = igmp_hdr(skb);
+
+	if (!mroute_do_pim ||
+	    skb->len < sizeof(*pim) + sizeof(*encap) ||
+	    pim->group != PIM_V1_VERSION || pim->code != PIM_V1_REGISTER)
 		goto drop;

-	/* check if the inner packet is destined to mcast group */
 	encap = (struct iphdr *)(skb_transport_header(skb) +
-				 sizeof(struct pimreghdr));
+				 sizeof(struct igmphdr));
+	/*
+	   Check that:
+	   a. packet is really destinted to a multicast group
+	   b. packet is not a NULL-REGISTER
+	   c. packet is not truncated
+	 */
 	if (!ipv4_is_multicast(encap->daddr) ||
 	    encap->tot_len == 0 ||
 	    ntohs(encap->tot_len) + sizeof(*pim) > skb->len)
@@ -40,9 +45,9 @@
 	skb->ip_summed = 0;
 	skb->pkt_type = PACKET_HOST;
 	dst_release(skb->dst);
+	skb->dst = NULL;
 	reg_dev->stats.rx_bytes += skb->len;
 	reg_dev->stats.rx_packets++;
-	skb->dst = NULL;
 	nf_reset(skb);
 	netif_rx(skb);
 	dev_put(reg_dev);

$ codiff net/ipv4/ipmr.o.old net/ipv4/ipmr.o.new

net/ipv4/ipmr.c:
  pim_rcv_v1 | -283
  pim_rcv    | -284
 2 functions changed, 567 bytes removed

net/ipv4/ipmr.c:
  __pim_rcv | +307
 1 function changed, 307 bytes added

net/ipv4/ipmr.o.new:
 3 functions changed, 307 bytes added, 567 bytes removed, diff: -260

(Tested on x86_64).

It seems that pimlen arg could be left out as well and
eq-sizedness of structs trapped with BUILD_BUG_ON but
I don't think that's more than a cosmetic flaw since there
aren't that many args anyway.

Compile tested.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/ipmr.c |  103 +++++++++++++++++++++----------------------------------
 1 files changed, 39 insertions(+), 64 deletions(-)

diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 244a624..1466644 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -1482,29 +1482,13 @@ dont_forward:
 	return 0;
 }
 
-#ifdef CONFIG_IP_PIMSM_V1
-/*
- * Handle IGMP messages of PIMv1
- */
-
-int pim_rcv_v1(struct sk_buff * skb)
+#ifdef CONFIG_IP_PIMSM
+static int __pim_rcv(struct sk_buff *skb, unsigned int pimlen)
 {
-	struct igmphdr *pim;
-	struct iphdr   *encap;
-	struct net_device  *reg_dev = NULL;
-
-	if (!pskb_may_pull(skb, sizeof(*pim) + sizeof(*encap)))
-		goto drop;
+	struct net_device *reg_dev = NULL;
+	struct iphdr *encap;
 
-	pim = igmp_hdr(skb);
-
-	if (!mroute_do_pim ||
-	    skb->len < sizeof(*pim) + sizeof(*encap) ||
-	    pim->group != PIM_V1_VERSION || pim->code != PIM_V1_REGISTER)
-		goto drop;
-
-	encap = (struct iphdr *)(skb_transport_header(skb) +
-				 sizeof(struct igmphdr));
+	encap = (struct iphdr *)(skb_transport_header(skb) + pimlen);
 	/*
 	   Check that:
 	   a. packet is really destinted to a multicast group
@@ -1513,8 +1497,8 @@ int pim_rcv_v1(struct sk_buff * skb)
 	 */
 	if (!ipv4_is_multicast(encap->daddr) ||
 	    encap->tot_len == 0 ||
-	    ntohs(encap->tot_len) + sizeof(*pim) > skb->len)
-		goto drop;
+	    ntohs(encap->tot_len) + pimlen > skb->len)
+		return 1;
 
 	read_lock(&mrt_lock);
 	if (reg_vif_num >= 0)
@@ -1524,7 +1508,7 @@ int pim_rcv_v1(struct sk_buff * skb)
 	read_unlock(&mrt_lock);
 
 	if (reg_dev == NULL)
-		goto drop;
+		return 1;
 
 	skb->mac_header = skb->network_header;
 	skb_pull(skb, (u8*)encap - skb->data);
@@ -1540,9 +1524,33 @@ int pim_rcv_v1(struct sk_buff * skb)
 	nf_reset(skb);
 	netif_rx(skb);
 	dev_put(reg_dev);
+
 	return 0;
- drop:
-	kfree_skb(skb);
+}
+#endif
+
+#ifdef CONFIG_IP_PIMSM_V1
+/*
+ * Handle IGMP messages of PIMv1
+ */
+
+int pim_rcv_v1(struct sk_buff * skb)
+{
+	struct igmphdr *pim;
+
+	if (!pskb_may_pull(skb, sizeof(*pim) + sizeof(struct iphdr)))
+		goto drop;
+
+	pim = igmp_hdr(skb);
+
+	if (!mroute_do_pim ||
+	    pim->group != PIM_V1_VERSION || pim->code != PIM_V1_REGISTER)
+		goto drop;
+
+	if (__pim_rcv(skb, sizeof(*pim))) {
+drop:
+		kfree_skb(skb);
+	}
 	return 0;
 }
 #endif
@@ -1551,10 +1559,8 @@ int pim_rcv_v1(struct sk_buff * skb)
 static int pim_rcv(struct sk_buff * skb)
 {
 	struct pimreghdr *pim;
-	struct iphdr   *encap;
-	struct net_device  *reg_dev = NULL;
 
-	if (!pskb_may_pull(skb, sizeof(*pim) + sizeof(*encap)))
+	if (!pskb_may_pull(skb, sizeof(*pim) + sizeof(struct iphdr)))
 		goto drop;
 
 	pim = (struct pimreghdr *)skb_transport_header(skb);
@@ -1564,41 +1570,10 @@ static int pim_rcv(struct sk_buff * skb)
 	     csum_fold(skb_checksum(skb, 0, skb->len, 0))))
 		goto drop;
 
-	/* check if the inner packet is destined to mcast group */
-	encap = (struct iphdr *)(skb_transport_header(skb) +
-				 sizeof(struct pimreghdr));
-	if (!ipv4_is_multicast(encap->daddr) ||
-	    encap->tot_len == 0 ||
-	    ntohs(encap->tot_len) + sizeof(*pim) > skb->len)
-		goto drop;
-
-	read_lock(&mrt_lock);
-	if (reg_vif_num >= 0)
-		reg_dev = vif_table[reg_vif_num].dev;
-	if (reg_dev)
-		dev_hold(reg_dev);
-	read_unlock(&mrt_lock);
-
-	if (reg_dev == NULL)
-		goto drop;
-
-	skb->mac_header = skb->network_header;
-	skb_pull(skb, (u8*)encap - skb->data);
-	skb_reset_network_header(skb);
-	skb->dev = reg_dev;
-	skb->protocol = htons(ETH_P_IP);
-	skb->ip_summed = 0;
-	skb->pkt_type = PACKET_HOST;
-	dst_release(skb->dst);
-	reg_dev->stats.rx_bytes += skb->len;
-	reg_dev->stats.rx_packets++;
-	skb->dst = NULL;
-	nf_reset(skb);
-	netif_rx(skb);
-	dev_put(reg_dev);
-	return 0;
- drop:
-	kfree_skb(skb);
+	if (__pim_rcv(skb, sizeof(*pim))) {
+drop:
+		kfree_skb(skb);
+	}
 	return 0;
 }
 #endif
-- 
1.5.2.2

---696208474-1530841098-1229198374=:4160--
