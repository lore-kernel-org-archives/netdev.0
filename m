From: Jeff Mahoney <jeffm@suse.com>
Subject: [PATCH] dl2k: Clean up rio_ioctl
Date: Wed, 25 Apr 2012 20:32:09 -0400
Message-ID: <4F989789.9040405@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Network Development <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charybdis-ext.suse.de ([195.135.221.2]:28702 "EHLO
	nat.nue.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932689Ab2DZAcZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Apr 2012 20:32:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The dl2k driver's rio_ioctl call has a few issues:
- No permissions checking
- Implements SIOCGMIIREG and SIOCGMIIREG using the SIOCDEVPRIVATE numbers
- Has a few ioctls that may have been used for debugging at one point
  but have no place in the kernel proper.

This patch removes all but the MII ioctls, renumbers them to use the
standard ones, and adds the proper permission check for SIOCSMIIREG.

We can also get rid of the dl2k-specific struct mii_data in favor of
the generic struct mii_ioctl_data.

Since we have the phyid on hand, we can add the SIOCGMIIPHY ioctl too.

Most of the MII code for the driver could probably be converted to use
the generic MII library but I don't have a device to test the results.

Reported-by: Stephan Mueller <stephan.mueller@atsec.com>
Signed-off-by: Jeff Mahoney <jeffm@suse.com>
---
 drivers/net/ethernet/dlink/dl2k.c |   52 ++++++--------------------------------
 drivers/net/ethernet/dlink/dl2k.h |    7 -----
 2 files changed, 9 insertions(+), 50 deletions(-)

--- a/drivers/net/ethernet/dlink/dl2k.c
+++ b/drivers/net/ethernet/dlink/dl2k.c
@@ -1259,55 +1259,21 @@ rio_ioctl (struct net_device *dev, struc
 {
 	int phy_addr;
 	struct netdev_private *np = netdev_priv(dev);
-	struct mii_data *miidata = (struct mii_data *) &rq->ifr_ifru;
-
-	struct netdev_desc *desc;
-	int i;
+	struct mii_ioctl_data *miidata = if_mii(rq);
 
 	phy_addr = np->phy_addr;
 	switch (cmd) {
-	case SIOCDEVPRIVATE:
-		break;
-
-	case SIOCDEVPRIVATE + 1:
-		miidata->out_value = mii_read (dev, phy_addr, miidata->reg_num);
-		break;
-	case SIOCDEVPRIVATE + 2:
-		mii_write (dev, phy_addr, miidata->reg_num, miidata->in_value);
-		break;
-	case SIOCDEVPRIVATE + 3:
+	case SIOCGMIIPHY:
+		miidata->phy_id = phy_addr;
 		break;
-	case SIOCDEVPRIVATE + 4:
+	case SIOCGMIIREG:
+		miidata->val_out = mii_read (dev, phy_addr, miidata->reg_num);
 		break;
-	case SIOCDEVPRIVATE + 5:
-		netif_stop_queue (dev);
+	case SIOCSMIIREG:
+		if (!capable(CAP_NET_ADMIN))
+			return -EPERM;
+		mii_write (dev, phy_addr, miidata->reg_num, miidata->val_in);
 		break;
-	case SIOCDEVPRIVATE + 6:
-		netif_wake_queue (dev);
-		break;
-	case SIOCDEVPRIVATE + 7:
-		printk
-		    ("tx_full=%x cur_tx=%lx old_tx=%lx cur_rx=%lx old_rx=%lx\n",
-		     netif_queue_stopped(dev), np->cur_tx, np->old_tx, np->cur_rx,
-		     np->old_rx);
-		break;
-	case SIOCDEVPRIVATE + 8:
-		printk("TX ring:\n");
-		for (i = 0; i < TX_RING_SIZE; i++) {
-			desc = &np->tx_ring[i];
-			printk
-			    ("%02x:cur:%08x next:%08x status:%08x frag1:%08x frag0:%08x",
-			     i,
-			     (u32) (np->tx_ring_dma + i * sizeof (*desc)),
-			     (u32)le64_to_cpu(desc->next_desc),
-			     (u32)le64_to_cpu(desc->status),
-			     (u32)(le64_to_cpu(desc->fraginfo) >> 32),
-			     (u32)le64_to_cpu(desc->fraginfo));
-			printk ("\n");
-		}
-		printk ("\n");
-		break;
-
 	default:
 		return -EOPNOTSUPP;
 	}
--- a/drivers/net/ethernet/dlink/dl2k.h
+++ b/drivers/net/ethernet/dlink/dl2k.h
@@ -365,13 +365,6 @@ struct ioctl_data {
 	char *data;
 };
 
-struct mii_data {
-	__u16 reserved;
-	__u16 reg_num;
-	__u16 in_value;
-	__u16 out_value;
-};
-
 /* The Rx and Tx buffer descriptors. */
 struct netdev_desc {
 	__le64 next_desc;
