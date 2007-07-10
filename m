From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [RFT] via-velocity: use standard VLAN infrastructure
Date: Tue, 10 Jul 2007 09:46:50 -0700
Message-ID: <20070710094650.67708934@freepuppy.rosehill.hemminger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:55919 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755018AbXGJQrD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2007 12:47:03 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The via-velocity is using a non-standard VLAN acceleration interface.
This patch converts it to use standard API. Compile tested only.

The module parameter method of VLAN configuration is removed, use
vconfig instead.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
 drivers/net/via-velocity.c |   68 +++++++++++++++++++++++++++------------------
 drivers/net/via-velocity.h |    3 +
 2 files changed, 44 insertions(+), 27 deletions(-)

--- a/drivers/net/via-velocity.c	2007-06-25 09:03:14.000000000 -0700
+++ b/drivers/net/via-velocity.c	2007-07-10 09:38:05.000000000 -0700
@@ -72,6 +72,7 @@
 #include <linux/mii.h>
 #include <linux/in.h>
 #include <linux/if_arp.h>
+#include <linux/if_vlan.h>
 #include <linux/ip.h>
 #include <linux/tcp.h>
 #include <linux/udp.h>
@@ -111,15 +112,6 @@ VELOCITY_PARAM(RxDescriptors, "Number of
 #define TX_DESC_DEF     64
 VELOCITY_PARAM(TxDescriptors, "Number of transmit descriptors");
 
-#define VLAN_ID_MIN     0
-#define VLAN_ID_MAX     4095
-#define VLAN_ID_DEF     0
-/* VID_setting[] is used for setting the VID of NIC.
-   0: default VID.
-   1-4094: other VIDs.
-*/
-VELOCITY_PARAM(VID_setting, "802.1Q VLAN ID");
-
 #define RX_THRESH_MIN   0
 #define RX_THRESH_MAX   3
 #define RX_THRESH_DEF   0
@@ -147,13 +139,6 @@ VELOCITY_PARAM(rx_thresh, "Receive fifo 
 */
 VELOCITY_PARAM(DMA_length, "DMA length");
 
-#define TAGGING_DEF     0
-/* enable_tagging[] is used for enabling 802.1Q VID tagging.
-   0: disable VID seeting(default).
-   1: enable VID setting.
-*/
-VELOCITY_PARAM(enable_tagging, "Enable 802.1Q tagging");
-
 #define IP_ALIG_DEF     0
 /* IP_byte_align[] is used for IP header DWORD byte aligned
    0: indicate the IP header won't be DWORD byte aligned.(Default) .
@@ -442,8 +427,7 @@ static void __devinit velocity_get_optio
 	velocity_set_int_opt(&opts->DMA_length, DMA_length[index], DMA_LENGTH_MIN, DMA_LENGTH_MAX, DMA_LENGTH_DEF, "DMA_length", devname);
 	velocity_set_int_opt(&opts->numrx, RxDescriptors[index], RX_DESC_MIN, RX_DESC_MAX, RX_DESC_DEF, "RxDescriptors", devname);
 	velocity_set_int_opt(&opts->numtx, TxDescriptors[index], TX_DESC_MIN, TX_DESC_MAX, TX_DESC_DEF, "TxDescriptors", devname);
-	velocity_set_int_opt(&opts->vid, VID_setting[index], VLAN_ID_MIN, VLAN_ID_MAX, VLAN_ID_DEF, "VID_setting", devname);
-	velocity_set_bool_opt(&opts->flags, enable_tagging[index], TAGGING_DEF, VELOCITY_FLAGS_TAGGING, "enable_tagging", devname);
+
 	velocity_set_bool_opt(&opts->flags, txcsum_offload[index], TX_CSUM_DEF, VELOCITY_FLAGS_TX_CSUM, "txcsum_offload", devname);
 	velocity_set_int_opt(&opts->flow_cntl, flow_control[index], FLOW_CNTL_MIN, FLOW_CNTL_MAX, FLOW_CNTL_DEF, "flow_control", devname);
 	velocity_set_bool_opt(&opts->flags, IP_byte_align[index], IP_ALIG_DEF, VELOCITY_FLAGS_IP_ALIGN, "IP_byte_align", devname);
@@ -465,6 +449,7 @@ static void __devinit velocity_get_optio
 static void velocity_init_cam_filter(struct velocity_info *vptr)
 {
 	struct mac_regs __iomem * regs = vptr->mac_regs;
+	unsigned short vid;
 
 	/* Turn on MCFG_PQEN, turn off MCFG_RTGOPT */
 	WORD_REG_BITS_SET(MCFG_PQEN, MCFG_RTGOPT, &regs->MCFG);
@@ -477,13 +462,19 @@ static void velocity_init_cam_filter(str
 	mac_set_cam_mask(regs, vptr->mCAMmask, VELOCITY_MULTICAST_CAM);
 
 	/* Enable first VCAM */
-	if (vptr->flags & VELOCITY_FLAGS_TAGGING) {
-		/* If Tagging option is enabled and VLAN ID is not zero, then
-		   turn on MCFG_RTGOPT also */
-		if (vptr->options.vid != 0)
-			WORD_REG_BITS_ON(MCFG_RTGOPT, &regs->MCFG);
+	if (vptr->vlgrp) {
+		for (vid = 0; vid < VLAN_VID_MASK; vid++) {
+			if (vlan_group_get_device(vptr->vlgrp, vid)) {
+				/* If Tagging option is enabled and
+				   VLAN ID is not zero, then
+				   turn on MCFG_RTGOPT also */
+				if (vid != 0)
+					WORD_REG_BITS_ON(MCFG_RTGOPT, &regs->MCFG);
 
-		mac_set_cam(regs, 0, (u8 *) & (vptr->options.vid), VELOCITY_VLAN_ID_CAM);
+				mac_set_cam(regs, 0, (u8 *) &vid,
+					    VELOCITY_VLAN_ID_CAM);
+			}
+		}
 		vptr->vCAMmask[0] |= 1;
 		mac_set_cam_mask(regs, vptr->vCAMmask, VELOCITY_VLAN_ID_CAM);
 	} else {
@@ -494,6 +485,26 @@ static void velocity_init_cam_filter(str
 	}
 }
 
+static void velocity_vlan_rx_add_vid(struct net_device *dev, unsigned short vid)
+{
+	struct velocity_info *vptr = netdev_priv(dev);
+
+	spin_lock_irq(&vptr->lock);
+	velocity_init_cam_filter(vptr);
+	spin_unlock_irq(&vptr->lock);
+}
+
+static void velocity_vlan_rx_kill_vid(struct net_device *dev, unsigned short vid)
+{
+	struct velocity_info *vptr = netdev_priv(dev);
+
+	spin_lock_irq(&vptr->lock);
+	vlan_group_set_device(vptr->vlgrp, vid, NULL);
+	velocity_init_cam_filter(vptr);
+	spin_unlock_irq(&vptr->lock);
+}
+
+
 /**
  *	velocity_rx_reset	-	handle a receive reset
  *	@vptr: velocity we are resetting
@@ -791,9 +802,14 @@ static int __devinit velocity_found1(str
 	dev->do_ioctl = velocity_ioctl;
 	dev->ethtool_ops = &velocity_ethtool_ops;
 	dev->change_mtu = velocity_change_mtu;
+
+	dev->vlan_rx_add_vid = velocity_vlan_rx_add_vid;
+	dev->vlan_rx_kill_vid = velocity_vlan_rx_kill_vid;
+
 #ifdef  VELOCITY_ZERO_COPY_SUPPORT
 	dev->features |= NETIF_F_SG;
 #endif
+	dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_FILTER;
 
 	if (vptr->flags & VELOCITY_FLAGS_TX_CSUM) {
 		dev->features |= NETIF_F_IP_CSUM;
@@ -1995,8 +2011,8 @@ static int velocity_xmit(struct sk_buff 
 		td_ptr->tdesc1.CMDZ = 2;
 	}
 
-	if (vptr->flags & VELOCITY_FLAGS_TAGGING) {
-		td_ptr->tdesc1.pqinf.VID = (vptr->options.vid & 0xfff);
+	if (vptr->vlgrp && vlan_tx_tag_present(skb)) {
+		td_ptr->tdesc1.pqinf.VID = vlan_tx_tag_get(skb);
 		td_ptr->tdesc1.pqinf.priority = 0;
 		td_ptr->tdesc1.pqinf.CFI = 0;
 		td_ptr->tdesc1.TCR |= TCR0_VETAG;
--- a/drivers/net/via-velocity.h	2007-06-25 09:03:14.000000000 -0700
+++ b/drivers/net/via-velocity.h	2007-07-10 09:34:46.000000000 -0700
@@ -1701,7 +1701,7 @@ struct velocity_opt {
 	int numrx;			/* Number of RX descriptors */
 	int numtx;			/* Number of TX descriptors */
 	enum speed_opt spd_dpx;		/* Media link mode */
-	int vid;			/* vlan id */
+
 	int DMA_length;			/* DMA length */
 	int rx_thresh;			/* RX_THRESH */
 	int flow_cntl;
@@ -1727,6 +1727,7 @@ struct velocity_info {
 	dma_addr_t tx_bufs_dma;
 	u8 *tx_bufs;
 
+	struct vlan_group    *vlgrp;
 	u8 ip_addr[4];
 	enum chip_type chip_id;
 
