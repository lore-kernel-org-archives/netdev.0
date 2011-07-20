From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6 28/47] via-velocity: do vlan cleanup
Date: Wed, 20 Jul 2011 16:54:30 +0200
Message-ID: <1311173689-17419-29-git-send-email-jpirko@redhat.com>
References: <1311173689-17419-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, shemminger@linux-foundation.org,
	eric.dumazet@gmail.com, greearb@candelatech.com, mirqus@gmail.com,
	romieu@fr.zoreil.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50632 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751418Ab1GTOzu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jul 2011 10:55:50 -0400
In-Reply-To: <1311173689-17419-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- unify vlan and nonvlan rx path
- kill vptr->vlgrp and velocity_vlan_rx_register

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/via-velocity.c |   49 ++++++++++++++++++--------------------------
 drivers/net/via-velocity.h |    2 +-
 2 files changed, 21 insertions(+), 30 deletions(-)

diff --git a/drivers/net/via-velocity.c b/drivers/net/via-velocity.c
index f929242..a9aa4a3 100644
--- a/drivers/net/via-velocity.c
+++ b/drivers/net/via-velocity.c
@@ -45,6 +45,7 @@
 
 #include <linux/module.h>
 #include <linux/types.h>
+#include <linux/bitops.h>
 #include <linux/init.h>
 #include <linux/mm.h>
 #include <linux/errno.h>
@@ -76,6 +77,7 @@
 #include <linux/udp.h>
 #include <linux/crc-ccitt.h>
 #include <linux/crc32.h>
+#include <linux/if_vlan.h>
 
 #include "via-velocity.h"
 
@@ -501,6 +503,7 @@ static void __devinit velocity_get_options(struct velocity_opt *opts, int index,
 static void velocity_init_cam_filter(struct velocity_info *vptr)
 {
 	struct mac_regs __iomem *regs = vptr->mac_regs;
+	unsigned int vid, i = 0;
 
 	/* Turn on MCFG_PQEN, turn off MCFG_RTGOPT */
 	WORD_REG_BITS_SET(MCFG_PQEN, MCFG_RTGOPT, &regs->MCFG);
@@ -513,30 +516,17 @@ static void velocity_init_cam_filter(struct velocity_info *vptr)
 	mac_set_cam_mask(regs, vptr->mCAMmask);
 
 	/* Enable VCAMs */
-	if (vptr->vlgrp) {
-		unsigned int vid, i = 0;
-
-		if (!vlan_group_get_device(vptr->vlgrp, 0))
-			WORD_REG_BITS_ON(MCFG_RTGOPT, &regs->MCFG);
-
-		for (vid = 1; (vid < VLAN_VID_MASK); vid++) {
-			if (vlan_group_get_device(vptr->vlgrp, vid)) {
-				mac_set_vlan_cam(regs, i, (u8 *) &vid);
-				vptr->vCAMmask[i / 8] |= 0x1 << (i % 8);
-				if (++i >= VCAM_SIZE)
-					break;
-			}
-		}
-		mac_set_vlan_cam_mask(regs, vptr->vCAMmask);
-	}
-}
 
-static void velocity_vlan_rx_register(struct net_device *dev,
-				      struct vlan_group *grp)
-{
-	struct velocity_info *vptr = netdev_priv(dev);
+	if (test_bit(0, vptr->active_vlans))
+		WORD_REG_BITS_ON(MCFG_RTGOPT, &regs->MCFG);
 
-	vptr->vlgrp = grp;
+	for_each_set_bit(vid, vptr->active_vlans, VLAN_N_VID) {
+		mac_set_vlan_cam(regs, i, (u8 *) &vid);
+		vptr->vCAMmask[i / 8] |= 0x1 << (i % 8);
+		if (++i >= VCAM_SIZE)
+			break;
+	}
+	mac_set_vlan_cam_mask(regs, vptr->vCAMmask);
 }
 
 static void velocity_vlan_rx_add_vid(struct net_device *dev, unsigned short vid)
@@ -544,6 +534,7 @@ static void velocity_vlan_rx_add_vid(struct net_device *dev, unsigned short vid)
 	struct velocity_info *vptr = netdev_priv(dev);
 
 	spin_lock_irq(&vptr->lock);
+	set_bit(vid, vptr->active_vlans);
 	velocity_init_cam_filter(vptr);
 	spin_unlock_irq(&vptr->lock);
 }
@@ -553,7 +544,7 @@ static void velocity_vlan_rx_kill_vid(struct net_device *dev, unsigned short vid
 	struct velocity_info *vptr = netdev_priv(dev);
 
 	spin_lock_irq(&vptr->lock);
-	vlan_group_set_device(vptr->vlgrp, vid, NULL);
+	clear_bit(vid, vptr->active_vlans);
 	velocity_init_cam_filter(vptr);
 	spin_unlock_irq(&vptr->lock);
 }
@@ -2094,11 +2085,12 @@ static int velocity_receive_frame(struct velocity_info *vptr, int idx)
 	skb_put(skb, pkt_len - 4);
 	skb->protocol = eth_type_trans(skb, vptr->dev);
 
-	if (vptr->vlgrp && (rd->rdesc0.RSR & RSR_DETAG)) {
-		vlan_hwaccel_rx(skb, vptr->vlgrp,
-				swab16(le16_to_cpu(rd->rdesc1.PQTAG)));
-	} else
-		netif_rx(skb);
+	if (rd->rdesc0.RSR & RSR_DETAG) {
+		u16 vid = swab16(le16_to_cpu(rd->rdesc1.PQTAG));
+
+		__vlan_hwaccel_put_tag(skb, vid);
+	}
+	netif_rx(skb);
 
 	stats->rx_bytes += pkt_len;
 
@@ -2641,7 +2633,6 @@ static const struct net_device_ops velocity_netdev_ops = {
 	.ndo_do_ioctl		= velocity_ioctl,
 	.ndo_vlan_rx_add_vid	= velocity_vlan_rx_add_vid,
 	.ndo_vlan_rx_kill_vid	= velocity_vlan_rx_kill_vid,
-	.ndo_vlan_rx_register	= velocity_vlan_rx_register,
 };
 
 /**
diff --git a/drivers/net/via-velocity.h b/drivers/net/via-velocity.h
index 0f1f05f..4cb9f13 100644
--- a/drivers/net/via-velocity.h
+++ b/drivers/net/via-velocity.h
@@ -1437,7 +1437,7 @@ struct velocity_info {
 	struct pci_dev *pdev;
 	struct net_device *dev;
 
-	struct vlan_group    *vlgrp;
+	unsigned long active_vlans[BITS_TO_LONGS(VLAN_N_VID)];
 	u8 ip_addr[4];
 	enum chip_type chip_id;
 
-- 
1.7.6

