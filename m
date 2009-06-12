From: Patrick McHardy <kaber@trash.net>
Subject: net: fix network drivers ndo_start_xmit() return values (part 3)
Date: Fri, 12 Jun 2009 16:08:02 +0200
Message-ID: <4A326142.8030905@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020206070100020502010700"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	linux-wireless@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Zhu Yi <yi.zhu@intel.com>, mcgrof@gmail.com,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:45818 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764032AbZFLOID (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Jun 2009 10:08:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------020206070100020502010700
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit


--------------020206070100020502010700
Content-Type: text/x-patch;
 name="03.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="03.diff"

commit 1fd73a30c86a658fdc61710b187fda8d6b914ced
Author: Patrick McHardy <kaber@trash.net>
Date:   Fri Jun 12 16:02:08 2009 +0200

    net: fix network drivers ndo_start_xmit() return values (part 3)
    
    Fix up wireless drivers that return an errno value to qdisc_restart(), causing
    qdisc_restart() to print a warning an requeue/retransmit the skb.
    
    - airo: transmission not implemented for chip, intention is to free and abort
    - ipw2200: transmission not implemented for promiscous mode, intention is to
               drop
    - prism54: intention is to drop
    - wl3501_cs: intention appears to be to drop
    - zd1201: error counter indicates intention is to drop
    
    All drivers compile tested.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/drivers/net/wireless/airo.c b/drivers/net/wireless/airo.c
index 9eabf4d..dfb30b9 100644
--- a/drivers/net/wireless/airo.c
+++ b/drivers/net/wireless/airo.c
@@ -2193,7 +2193,8 @@ static int airo_start_xmit11(struct sk_buff *skb, struct net_device *dev) {
 	if (test_bit(FLAG_MPI, &priv->flags)) {
 		/* Not implemented yet for MPI350 */
 		netif_stop_queue(dev);
-		return -ENETDOWN;
+		dev_kfree_skb_any(skb);
+		return NETDEV_TX_OK;
 	}
 
 	if ( skb == NULL ) {
diff --git a/drivers/net/wireless/ipw2x00/ipw2200.c b/drivers/net/wireless/ipw2x00/ipw2200.c
index c3b3dfe..44c29b3 100644
--- a/drivers/net/wireless/ipw2x00/ipw2200.c
+++ b/drivers/net/wireless/ipw2x00/ipw2200.c
@@ -11524,7 +11524,8 @@ static int ipw_prom_stop(struct net_device *dev)
 static int ipw_prom_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	IPW_DEBUG_INFO("prom dev->xmit\n");
-	return -EOPNOTSUPP;
+	dev_kfree_skb(skb);
+	return NETDEV_TX_OK;
 }
 
 static const struct net_device_ops ipw_prom_netdev_ops = {
diff --git a/drivers/net/wireless/prism54/islpci_eth.c b/drivers/net/wireless/prism54/islpci_eth.c
index ef3ef45..8f62109 100644
--- a/drivers/net/wireless/prism54/islpci_eth.c
+++ b/drivers/net/wireless/prism54/islpci_eth.c
@@ -87,7 +87,6 @@ islpci_eth_transmit(struct sk_buff *skb, struct net_device *ndev)
 	unsigned long flags;
 	unsigned char wds_mac[6];
 	u32 curr_frag;
-	int err = 0;
 
 #if VERBOSE > SHOW_ERROR_MESSAGES
 	DEBUG(SHOW_FUNCTION_CALLS, "islpci_eth_transmit \n");
@@ -107,8 +106,6 @@ islpci_eth_transmit(struct sk_buff *skb, struct net_device *ndev)
 		isl38xx_w32_flush(priv->device_base, ISL38XX_DEV_INT_UPDATE,
 				  ISL38XX_DEV_INT_REG);
 		udelay(ISL38XX_WRITEIO_DELAY);
-
-		err = -EBUSY;
 		goto drop_free;
 	}
 	/* Check alignment and WDS frame formatting. The start of the packet should
@@ -152,7 +149,6 @@ islpci_eth_transmit(struct sk_buff *skb, struct net_device *ndev)
 			if (unlikely(newskb == NULL)) {
 				printk(KERN_ERR "%s: Cannot allocate skb\n",
 				       ndev->name);
-				err = -ENOMEM;
 				goto drop_free;
 			}
 			newskb_offset = (4 - (long) newskb->data) & 0x03;
@@ -197,8 +193,6 @@ islpci_eth_transmit(struct sk_buff *skb, struct net_device *ndev)
 	if (unlikely(pci_map_address == 0)) {
 		printk(KERN_WARNING "%s: cannot map buffer to PCI\n",
 		       ndev->name);
-
-		err = -EIO;
 		goto drop_free;
 	}
 	/* Place the fragment in the control block structure. */
@@ -246,7 +240,7 @@ islpci_eth_transmit(struct sk_buff *skb, struct net_device *ndev)
 	ndev->stats.tx_dropped++;
 	spin_unlock_irqrestore(&priv->slock, flags);
 	dev_kfree_skb(skb);
-	return err;
+	return NETDEV_TX_OK;
 }
 
 static inline int
diff --git a/drivers/net/wireless/wl3501_cs.c b/drivers/net/wireless/wl3501_cs.c
index 1f64d60..e3e96bb 100644
--- a/drivers/net/wireless/wl3501_cs.c
+++ b/drivers/net/wireless/wl3501_cs.c
@@ -1348,6 +1348,7 @@ static int wl3501_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (rc) {
 		++dev->stats.tx_dropped;
 		netif_stop_queue(dev);
+		rc = NETDEV_TX_OK;
 	} else {
 		++dev->stats.tx_packets;
 		dev->stats.tx_bytes += skb->len;
diff --git a/drivers/net/wireless/zd1201.c b/drivers/net/wireless/zd1201.c
index 5fabd9c..4430b8d 100644
--- a/drivers/net/wireless/zd1201.c
+++ b/drivers/net/wireless/zd1201.c
@@ -819,11 +819,11 @@ static int zd1201_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (err) {
 		dev->stats.tx_errors++;
 		netif_start_queue(dev);
-		return err;
+	} else {
+		dev->stats.tx_packets++;
+		dev->stats.tx_bytes += skb->len;
+		dev->trans_start = jiffies;
 	}
-	dev->stats.tx_packets++;
-	dev->stats.tx_bytes += skb->len;
-	dev->trans_start = jiffies;
 	kfree_skb(skb);
 
 	return 0;

--------------020206070100020502010700--
