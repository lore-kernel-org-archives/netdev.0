From: Petko Manolov <petkan@nucleusys.com>
Subject: [PATCH 1/3] drivers: net: usb: pegasus: remove skb pool
Date: Fri, 26 Apr 2013 09:57:07 +0300 (EEST)
Message-ID: <alpine.DEB.2.02.1304260934030.3746@fry.nucleusys.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Petko Manolov <petkan@nucleusys.com>

The socket buffer pool for the receive path is now gone.  It's existence 
didn't make much difference (performance-wise) and the code is better off 
without the spinlocks protecting it.

Signed-off-by: Petko Manolov <petkan@nucleusys.com>
---
 pegasus.c |   73 +++++++--------------------------------------------
 pegasus.h |    3 ---
 2 files changed, 9 insertions(+), 67 deletions(-)

diff --git a/pegasus.c b/pegasus.c
index a0b5807..9e5e11f 100644
--- a/pegasus.c
+++ b/pegasus.c
@@ -577,51 +577,6 @@ static int enable_net_traffic(struct net_device *dev, struct usb_device *usb)
 	return ret;
 }
 
-static void fill_skb_pool(pegasus_t *pegasus)
-{
-	int i;
-
-	for (i = 0; i < RX_SKBS; i++) {
-		if (pegasus->rx_pool[i])
-			continue;
-		pegasus->rx_pool[i] = dev_alloc_skb(PEGASUS_MTU + 2);
-		/*
-		 ** we give up if the allocation fail. the tasklet will be
-		 ** rescheduled again anyway...
-		 */
-		if (pegasus->rx_pool[i] == NULL)
-			return;
-		skb_reserve(pegasus->rx_pool[i], 2);
-	}
-}
-
-static void free_skb_pool(pegasus_t *pegasus)
-{
-	int i;
-
-	for (i = 0; i < RX_SKBS; i++) {
-		if (pegasus->rx_pool[i]) {
-			dev_kfree_skb(pegasus->rx_pool[i]);
-			pegasus->rx_pool[i] = NULL;
-		}
-	}
-}
-
-static inline struct sk_buff *pull_skb(pegasus_t * pegasus)
-{
-	int i;
-	struct sk_buff *skb;
-
-	for (i = 0; i < RX_SKBS; i++) {
-		if (likely(pegasus->rx_pool[i] != NULL)) {
-			skb = pegasus->rx_pool[i];
-			pegasus->rx_pool[i] = NULL;
-			return skb;
-		}
-	}
-	return NULL;
-}
-
 static void read_bulk_callback(struct urb *urb)
 {
 	pegasus_t *pegasus = urb->context;
@@ -706,9 +661,8 @@ static void read_bulk_callback(struct urb *urb)
 	if (pegasus->flags & PEGASUS_UNPLUG)
 		return;
 
-	spin_lock(&pegasus->rx_pool_lock);
-	pegasus->rx_skb = pull_skb(pegasus);
-	spin_unlock(&pegasus->rx_pool_lock);
+	pegasus->rx_skb = __netdev_alloc_skb_ip_align(pegasus->net, PEGASUS_MTU,
+						      GFP_ATOMIC);
 
 	if (pegasus->rx_skb == NULL)
 		goto tl_sched;
@@ -736,24 +690,23 @@ tl_sched:
 static void rx_fixup(unsigned long data)
 {
 	pegasus_t *pegasus;
-	unsigned long flags;
 	int status;
 
 	pegasus = (pegasus_t *) data;
 	if (pegasus->flags & PEGASUS_UNPLUG)
 		return;
 
-	spin_lock_irqsave(&pegasus->rx_pool_lock, flags);
-	fill_skb_pool(pegasus);
 	if (pegasus->flags & PEGASUS_RX_URB_FAIL)
 		if (pegasus->rx_skb)
 			goto try_again;
 	if (pegasus->rx_skb == NULL)
-		pegasus->rx_skb = pull_skb(pegasus);
+		pegasus->rx_skb = __netdev_alloc_skb_ip_align(pegasus->net,
+							      PEGASUS_MTU,
+							      GFP_ATOMIC);
 	if (pegasus->rx_skb == NULL) {
 		netif_warn(pegasus, rx_err, pegasus->net, "low on memory\n");
 		tasklet_schedule(&pegasus->rx_tl);
-		goto done;
+		return;
 	}
 	usb_fill_bulk_urb(pegasus->rx_urb, pegasus->usb,
 			  usb_rcvbulkpipe(pegasus->usb, 1),
@@ -769,8 +722,6 @@ try_again:
 	} else {
 		pegasus->flags &= ~PEGASUS_RX_URB_FAIL;
 	}
-done:
-	spin_unlock_irqrestore(&pegasus->rx_pool_lock, flags);
 }
 
 static void write_bulk_callback(struct urb *urb)
@@ -1009,10 +960,9 @@ static int pegasus_open(struct net_device *net)
 	int res;
 
 	if (pegasus->rx_skb == NULL)
-		pegasus->rx_skb = pull_skb(pegasus);
-	/*
-	 ** Note: no point to free the pool.  it is empty :-)
-	 */
+		pegasus->rx_skb = __netdev_alloc_skb_ip_align(pegasus->net,
+							      PEGASUS_MTU,
+							      GFP_KERNEL);
 	if (!pegasus->rx_skb)
 		return -ENOMEM;
 
@@ -1046,7 +996,6 @@ static int pegasus_open(struct net_device *net)
 		res = -EIO;
 		usb_kill_urb(pegasus->rx_urb);
 		usb_kill_urb(pegasus->intr_urb);
-		free_skb_pool(pegasus);
 		goto exit;
 	}
 	set_carrier(net);
@@ -1359,7 +1308,6 @@ static int pegasus_probe(struct usb_interface *intf,
 	pegasus->mii.mdio_write = mdio_write;
 	pegasus->mii.phy_id_mask = 0x1f;
 	pegasus->mii.reg_num_mask = 0x1f;
-	spin_lock_init(&pegasus->rx_pool_lock);
 	pegasus->msg_enable = netif_msg_init(msg_level, NETIF_MSG_DRV
 				| NETIF_MSG_PROBE | NETIF_MSG_LINK);
 
@@ -1371,7 +1319,6 @@ static int pegasus_probe(struct usb_interface *intf,
 		goto out2;
 	}
 	set_ethernet_addr(pegasus);
-	fill_skb_pool(pegasus);
 	if (pegasus->features & PEGASUS_II) {
 		dev_info(&intf->dev, "setup Pegasus II specific registers\n");
 		setup_pegasus_II(pegasus);
@@ -1399,7 +1346,6 @@ static int pegasus_probe(struct usb_interface *intf,
 
 out3:
 	usb_set_intfdata(intf, NULL);
-	free_skb_pool(pegasus);
 out2:
 	free_all_urbs(pegasus);
 out1:
@@ -1424,7 +1370,6 @@ static void pegasus_disconnect(struct usb_interface *intf)
 	unregister_netdev(pegasus->net);
 	unlink_all_urbs(pegasus);
 	free_all_urbs(pegasus);
-	free_skb_pool(pegasus);
 	if (pegasus->rx_skb != NULL) {
 		dev_kfree_skb(pegasus->rx_skb);
 		pegasus->rx_skb = NULL;
diff --git a/pegasus.h b/pegasus.h
index 65b78b3..00d44e3 100644
--- a/pegasus.h
+++ b/pegasus.h
@@ -13,7 +13,6 @@
 #define	HAS_HOME_PNA		0x40000000
 
 #define	PEGASUS_MTU		1536
-#define	RX_SKBS			4
 
 #define	EPROM_WRITE		0x01
 #define	EPROM_READ		0x02
@@ -97,11 +96,9 @@ typedef struct pegasus {
 	struct tasklet_struct	rx_tl;
 	struct delayed_work	carrier_check;
 	struct urb		*ctrl_urb, *rx_urb, *tx_urb, *intr_urb;
-	struct sk_buff		*rx_pool[RX_SKBS];
 	struct sk_buff		*rx_skb;
 	struct usb_ctrlrequest	dr;
 	wait_queue_head_t	ctrl_wait;
-	spinlock_t		rx_pool_lock;
 	int			chip;
 	unsigned char		intr_buff[8];
 	__u8			tx_buff[PEGASUS_MTU];
