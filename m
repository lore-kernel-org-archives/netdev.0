From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6 07/21] bnad: do vlan cleanup
Date: Fri, 15 Jul 2011 23:33:25 +0200
Message-ID: <1310765619-27827-8-git-send-email-jpirko@redhat.com>
References: <1310765619-27827-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, shemminger@linux-foundation.org,
	eric.dumazet@gmail.com, greearb@candelatech.com, mirqus@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55549 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752605Ab1GOVeA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Jul 2011 17:34:00 -0400
In-Reply-To: <1310765619-27827-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- unify vlan and nonvlan rx path
- kill bnad->vlan_grp and bnad_vlan_rx_register

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/bna/bnad.c |   55 ++++++++++++++---------------------------------
 drivers/net/bna/bnad.h |    3 +-
 2 files changed, 19 insertions(+), 39 deletions(-)

diff --git a/drivers/net/bna/bnad.c b/drivers/net/bna/bnad.c
index fa997bf..c89c9b2 100644
--- a/drivers/net/bna/bnad.c
+++ b/drivers/net/bna/bnad.c
@@ -15,6 +15,7 @@
  * All rights reserved
  * www.brocade.com
  */
+#include <linux/bitops.h>
 #include <linux/netdevice.h>
 #include <linux/skbuff.h>
 #include <linux/etherdevice.h>
@@ -24,6 +25,7 @@
 #include <linux/if_ether.h>
 #include <linux/ip.h>
 #include <linux/prefetch.h>
+#include <linux/if_vlan.h>
 
 #include "bnad.h"
 #include "bna.h"
@@ -514,24 +516,16 @@ bnad_poll_cq(struct bnad *bnad, struct bna_ccb *ccb, int budget)
 		rcb->rxq->rx_bytes += skb->len;
 		skb->protocol = eth_type_trans(skb, bnad->netdev);
 
-		if (bnad->vlan_grp && (flags & BNA_CQ_EF_VLAN)) {
-			struct bnad_rx_ctrl *rx_ctrl =
-				(struct bnad_rx_ctrl *)ccb->ctrl;
-			if (skb->ip_summed == CHECKSUM_UNNECESSARY)
-				vlan_gro_receive(&rx_ctrl->napi, bnad->vlan_grp,
-						ntohs(cmpl->vlan_tag), skb);
-			else
-				vlan_hwaccel_receive_skb(skb,
-							 bnad->vlan_grp,
-							 ntohs(cmpl->vlan_tag));
-
-		} else { /* Not VLAN tagged/stripped */
-			struct bnad_rx_ctrl *rx_ctrl =
-				(struct bnad_rx_ctrl *)ccb->ctrl;
-			if (skb->ip_summed == CHECKSUM_UNNECESSARY)
-				napi_gro_receive(&rx_ctrl->napi, skb);
-			else
-				netif_receive_skb(skb);
+		if (flags & BNA_CQ_EF_VLAN)
+			__vlan_hwaccel_put_tag(skb, ntohs(cmpl->vlan_tag));
+
+		if (skb->ip_summed == CHECKSUM_UNNECESSARY) {
+			struct bnad_rx_ctrl *rx_ctrl;
+
+			rx_ctrl = (struct bnad_rx_ctrl *) ccb->ctrl;
+			napi_gro_receive(&rx_ctrl->napi, skb);
+		} else {
+			netif_receive_skb(skb);
 		}
 
 next:
@@ -1981,19 +1975,14 @@ bnad_enable_default_bcast(struct bnad *bnad)
 static void
 bnad_restore_vlans(struct bnad *bnad, u32 rx_id)
 {
-	u16 vlan_id;
+	u16 vid;
 	unsigned long flags;
 
-	if (!bnad->vlan_grp)
-		return;
-
 	BUG_ON(!(VLAN_N_VID == (BFI_MAX_VLAN + 1)));
 
-	for (vlan_id = 0; vlan_id < VLAN_N_VID; vlan_id++) {
-		if (!vlan_group_get_device(bnad->vlan_grp, vlan_id))
-			continue;
+	for_each_set_bit(vid, bnad->active_vlans, VLAN_N_VID) {
 		spin_lock_irqsave(&bnad->bna_lock, flags);
-		bna_rx_vlan_add(bnad->rx_info[rx_id].rx, vlan_id);
+		bna_rx_vlan_add(bnad->rx_info[rx_id].rx, vid);
 		spin_unlock_irqrestore(&bnad->bna_lock, flags);
 	}
 }
@@ -2796,17 +2785,6 @@ bnad_change_mtu(struct net_device *netdev, int new_mtu)
 }
 
 static void
-bnad_vlan_rx_register(struct net_device *netdev,
-				  struct vlan_group *vlan_grp)
-{
-	struct bnad *bnad = netdev_priv(netdev);
-
-	mutex_lock(&bnad->conf_mutex);
-	bnad->vlan_grp = vlan_grp;
-	mutex_unlock(&bnad->conf_mutex);
-}
-
-static void
 bnad_vlan_rx_add_vid(struct net_device *netdev,
 				 unsigned short vid)
 {
@@ -2820,6 +2798,7 @@ bnad_vlan_rx_add_vid(struct net_device *netdev,
 
 	spin_lock_irqsave(&bnad->bna_lock, flags);
 	bna_rx_vlan_add(bnad->rx_info[0].rx, vid);
+	set_bit(vid, bnad->active_vlans);
 	spin_unlock_irqrestore(&bnad->bna_lock, flags);
 
 	mutex_unlock(&bnad->conf_mutex);
@@ -2838,6 +2817,7 @@ bnad_vlan_rx_kill_vid(struct net_device *netdev,
 	mutex_lock(&bnad->conf_mutex);
 
 	spin_lock_irqsave(&bnad->bna_lock, flags);
+	clear_bit(vid, bnad->active_vlans);
 	bna_rx_vlan_del(bnad->rx_info[0].rx, vid);
 	spin_unlock_irqrestore(&bnad->bna_lock, flags);
 
@@ -2887,7 +2867,6 @@ static const struct net_device_ops bnad_netdev_ops = {
 	.ndo_validate_addr      = eth_validate_addr,
 	.ndo_set_mac_address    = bnad_set_mac_address,
 	.ndo_change_mtu		= bnad_change_mtu,
-	.ndo_vlan_rx_register   = bnad_vlan_rx_register,
 	.ndo_vlan_rx_add_vid    = bnad_vlan_rx_add_vid,
 	.ndo_vlan_rx_kill_vid   = bnad_vlan_rx_kill_vid,
 #ifdef CONFIG_NET_POLL_CONTROLLER
diff --git a/drivers/net/bna/bnad.h b/drivers/net/bna/bnad.h
index ccdabad..7aa550b 100644
--- a/drivers/net/bna/bnad.h
+++ b/drivers/net/bna/bnad.h
@@ -24,6 +24,7 @@
 #include <linux/etherdevice.h>
 #include <linux/mutex.h>
 #include <linux/firmware.h>
+#include <linux/if_vlan.h>
 
 /* Fix for IA64 */
 #include <asm/checksum.h>
@@ -216,7 +217,7 @@ struct bnad {
 	struct bnad_tx_info tx_info[BNAD_MAX_TXS];
 	struct bnad_rx_info rx_info[BNAD_MAX_RXS];
 
-	struct vlan_group	*vlan_grp;
+	unsigned long active_vlans[BITS_TO_LONGS(VLAN_N_VID)];
 	/*
 	 * These q numbers are global only because
 	 * they are used to calculate MSIx vectors.
-- 
1.7.6

