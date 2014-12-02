From: David L Stevens <david.stevens@oracle.com>
Subject: [PATCH net-next 3/6] sunvnet: add scatter/gather support
Date: Tue, 02 Dec 2014 15:31:13 -0500
Message-ID: <547E2191.2090909@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Sowmini Varadhan <sowmini.varadhan@oracle.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:31027 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933360AbaLBUbS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2014 15:31:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds scatter/gather support to the sunvnet driver.

Signed-off-by: David L Stevens <david.stevens@oracle.com>
---
 drivers/net/ethernet/sun/sunvnet.c |   97 ++++++++++++++++++++++++++++--------
 1 files changed, 76 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/sun/sunvnet.c b/drivers/net/ethernet/sun/sunvnet.c
index 7a8da56..b6a5336 100644
--- a/drivers/net/ethernet/sun/sunvnet.c
+++ b/drivers/net/ethernet/sun/sunvnet.c
@@ -15,6 +15,7 @@
 #include <linux/ethtool.h>
 #include <linux/etherdevice.h>
 #include <linux/mutex.h>
+#include <linux/highmem.h>
 #include <linux/if_vlan.h>
 
 #if IS_ENABLED(CONFIG_IPV6)
@@ -978,11 +979,54 @@ static void vnet_clean_timer_expire(unsigned long port0)
 		del_timer(&port->clean_timer);
 }
 
-static inline struct sk_buff *vnet_skb_shape(struct sk_buff *skb, void **pstart,
-					     int *plen)
+static inline int vnet_skb_map(struct ldc_channel *lp, struct sk_buff *skb,
+			       struct ldc_trans_cookie *cookies, int ncookies,
+			       unsigned int map_perm)
+{
+	int i, nc, err, blen;
+
+	/* header */
+	blen = skb_headlen(skb);
+	if (blen < ETH_ZLEN)
+		blen = ETH_ZLEN;
+	blen += VNET_PACKET_SKIP;
+	blen += 8 - (blen & 7);
+
+	err = ldc_map_single(lp, skb->data-VNET_PACKET_SKIP, blen, cookies,
+			     ncookies, map_perm);
+	if (err < 0)
+		return err;
+	nc = err;
+
+	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
+		skb_frag_t *f = &skb_shinfo(skb)->frags[i];
+		u8 *vaddr;
+
+		if (nc < ncookies) {
+			vaddr = kmap_atomic(skb_frag_page(f));
+			blen = skb_frag_size(f);
+			blen += 8 - (blen & 7);
+			err = ldc_map_single(lp, vaddr + f->page_offset,
+					     blen, cookies + nc, ncookies - nc,
+					     map_perm);
+			kunmap_atomic(vaddr);
+		} else {
+			err = -EMSGSIZE;
+		}
+
+		if (err < 0) {
+			ldc_unmap(lp, cookies, nc);
+			return err;
+		}
+		nc += err;
+	}
+	return nc;
+}
+
+static inline struct sk_buff *vnet_skb_shape(struct sk_buff *skb, int ncookies)
 {
 	struct sk_buff *nskb;
-	int len, pad;
+	int i, len, pad, docopy;
 
 	len = skb->len;
 	pad = 0;
@@ -992,14 +1036,25 @@ static inline struct sk_buff *vnet_skb_shape(struct sk_buff *skb, void **pstart,
 	}
 	len += VNET_PACKET_SKIP;
 	pad += 8 - (len & 7);
-	len += 8 - (len & 7);
 
+	/* make sure we have enough cookies and alignment in every frag */
+	docopy = skb_shinfo(skb)->nr_frags >= ncookies;
+	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
+		skb_frag_t *f = &skb_shinfo(skb)->frags[i];
+
+		docopy |= f->page_offset & 7;
+	}
 	if (((unsigned long)skb->data & 7) != VNET_PACKET_SKIP ||
 	    skb_tailroom(skb) < pad ||
-	    skb_headroom(skb) < VNET_PACKET_SKIP) {
+	    skb_headroom(skb) < VNET_PACKET_SKIP || docopy) {
 		int offset;
 
-		nskb = alloc_and_align_skb(skb->dev, skb->len);
+		len = skb->len > ETH_ZLEN ? skb->len : ETH_ZLEN;
+		nskb = alloc_and_align_skb(skb->dev, len);
+		if (nskb == NULL) {
+			dev_kfree_skb(skb);
+			return NULL;
+		}
 		skb_reserve(nskb, VNET_PACKET_SKIP);
 
 		nskb->protocol = skb->protocol;
@@ -1022,9 +1077,6 @@ static inline struct sk_buff *vnet_skb_shape(struct sk_buff *skb, void **pstart,
 		dev_kfree_skb(skb);
 		skb = nskb;
 	}
-
-	*pstart = skb->data - VNET_PACKET_SKIP;
-	*plen = len;
 	return skb;
 }
 
@@ -1049,15 +1101,9 @@ static int vnet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	unsigned int len;
 	struct sk_buff *freeskbs = NULL;
 	int i, err, txi;
-	void *start = NULL;
-	int nlen = 0;
 	unsigned pending = 0;
 	struct netdev_queue *txq;
 
-	skb = vnet_skb_shape(skb, &start, &nlen);
-	if (unlikely(!skb))
-		goto out_dropped;
-
 	rcu_read_lock();
 	port = __tx_port_find(vp, skb);
 	if (unlikely(!port)) {
@@ -1097,6 +1143,13 @@ static int vnet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		goto out_dropped;
 	}
 
+	skb = vnet_skb_shape(skb, 2);
+
+	if (unlikely(!skb)) {
+		rcu_read_unlock();
+		goto out_dropped;
+	}
+
 	dr = &port->vio.drings[VIO_DRIVER_TX_RING];
 	i = skb_get_queue_mapping(skb);
 	txq = netdev_get_tx_queue(dev, i);
@@ -1124,16 +1177,15 @@ static int vnet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (len < ETH_ZLEN)
 		len = ETH_ZLEN;
 
-	port->tx_bufs[txi].skb = skb;
-	skb = NULL;
-
-	err = ldc_map_single(port->vio.lp, start, nlen,
-			     port->tx_bufs[txi].cookies, VNET_MAXCOOKIES,
-			     (LDC_MAP_SHADOW | LDC_MAP_DIRECT | LDC_MAP_RW));
+	err = vnet_skb_map(port->vio.lp, skb, port->tx_bufs[txi].cookies, 2,
+			   (LDC_MAP_SHADOW | LDC_MAP_DIRECT | LDC_MAP_RW));
 	if (err < 0) {
 		netdev_info(dev, "tx buffer map error %d\n", err);
 		goto out_dropped;
 	}
+
+	port->tx_bufs[txi].skb = skb;
+	skb = NULL;
 	port->tx_bufs[txi].ncookies = err;
 
 	/* We don't rely on the ACKs to free the skb in vnet_start_xmit(),
@@ -1559,6 +1611,9 @@ static struct vnet *vnet_new(const u64 *local_mac)
 	dev->ethtool_ops = &vnet_ethtool_ops;
 	dev->watchdog_timeo = VNET_TX_TIMEOUT;
 
+	dev->hw_features = NETIF_F_SG;
+	dev->features = dev->hw_features;
+
 	err = register_netdev(dev);
 	if (err) {
 		pr_err("Cannot register net device, aborting\n");
-- 
1.7.1
