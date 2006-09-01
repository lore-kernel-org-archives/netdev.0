From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 1/5] skge: use netdev_alloc_skb
Date: Fri, 01 Sep 2006 15:53:47 -0700
Message-ID: <20060901225449.031404541@zqx3.pdx.osdl.net>
References: <20060901225346.750571061@zqx3.pdx.osdl.net>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:63630 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750967AbWIAW5d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2006 18:57:33 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline; filename=skge-netdev-alloc.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Change to use new netdev_alloc_skb interface for 2.6.18.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- skge-2.6.orig/drivers/net/skge.c
+++ skge-2.6/drivers/net/skge.c
@@ -818,8 +818,9 @@ static void skge_rx_clean(struct skge_po
 /* Allocate buffers for receive ring
  * For receive:  to_clean is next received frame.
  */
-static int skge_rx_fill(struct skge_port *skge)
+static int skge_rx_fill(struct net_device *dev)
 {
+	struct skge_port *skge = netdev_priv(dev);
 	struct skge_ring *ring = &skge->rx_ring;
 	struct skge_element *e;
 
@@ -827,8 +828,8 @@ static int skge_rx_fill(struct skge_port
 	do {
 		struct sk_buff *skb;
 
-		skb = __dev_alloc_skb(skge->rx_buf_size + NET_IP_ALIGN,
-				      GFP_KERNEL);
+		skb = __netdev_alloc_skb(dev, skge->rx_buf_size + NET_IP_ALIGN,
+					 GFP_KERNEL);
 		if (!skb)
 			return -ENOMEM;
 
@@ -2179,7 +2180,7 @@ static int skge_up(struct net_device *de
 	if (err)
 		goto free_pci_mem;
 
-	err = skge_rx_fill(skge);
+	err = skge_rx_fill(dev);
 	if (err)
 		goto free_rx_ring;
 
@@ -2585,16 +2586,17 @@ static inline int bad_phy_status(const s
 /* Get receive buffer from descriptor.
  * Handles copy of small buffers and reallocation failures
  */
-static inline struct sk_buff *skge_rx_get(struct skge_port *skge,
-					  struct skge_element *e,
-					  u32 control, u32 status, u16 csum)
+static struct sk_buff *skge_rx_get(struct net_device *dev,
+				   struct skge_element *e,
+				   u32 control, u32 status, u16 csum)
 {
+	struct skge_port *skge = netdev_priv(dev);
 	struct sk_buff *skb;
 	u16 len = control & BMU_BBC;
 
 	if (unlikely(netif_msg_rx_status(skge)))
 		printk(KERN_DEBUG PFX "%s: rx slot %td status 0x%x len %d\n",
-		       skge->netdev->name, e - skge->rx_ring.start,
+		       dev->name, e - skge->rx_ring.start,
 		       status, len);
 
 	if (len > skge->rx_buf_size)
@@ -2610,7 +2612,7 @@ static inline struct sk_buff *skge_rx_ge
 		goto error;
 
 	if (len < RX_COPY_THRESHOLD) {
-		skb = dev_alloc_skb(len + 2);
+		skb = netdev_alloc_skb(dev, len + 2);
 		if (!skb)
 			goto resubmit;
 
@@ -2625,7 +2627,7 @@ static inline struct sk_buff *skge_rx_ge
 		skge_rx_reuse(e, skge->rx_buf_size);
 	} else {
 		struct sk_buff *nskb;
-		nskb = dev_alloc_skb(skge->rx_buf_size + NET_IP_ALIGN);
+		nskb = netdev_alloc_skb(dev, skge->rx_buf_size + NET_IP_ALIGN);
 		if (!nskb)
 			goto resubmit;
 
@@ -2640,20 +2642,19 @@ static inline struct sk_buff *skge_rx_ge
 	}
 
 	skb_put(skb, len);
-	skb->dev = skge->netdev;
 	if (skge->rx_csum) {
 		skb->csum = csum;
 		skb->ip_summed = CHECKSUM_HW;
 	}
 
-	skb->protocol = eth_type_trans(skb, skge->netdev);
+	skb->protocol = eth_type_trans(skb, dev);
 
 	return skb;
 error:
 
 	if (netif_msg_rx_err(skge))
 		printk(KERN_DEBUG PFX "%s: rx err, slot %td control 0x%x status 0x%x\n",
-		       skge->netdev->name, e - skge->rx_ring.start,
+		       dev->name, e - skge->rx_ring.start,
 		       control, status);
 
 	if (skge->hw->chip_id == CHIP_ID_GENESIS) {
@@ -2723,7 +2724,7 @@ static int skge_poll(struct net_device *
 		if (control & BMU_OWN)
 			break;
 
-		skb = skge_rx_get(skge, e, control, rd->status, rd->csum2);
+		skb = skge_rx_get(dev, e, control, rd->status, rd->csum2);
 		if (likely(skb)) {
 			dev->last_rx = jiffies;
 			netif_receive_skb(skb);

--


-- 
VGER BF report: H 0.0016278
