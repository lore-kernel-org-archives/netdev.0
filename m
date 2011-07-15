From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6 14/21] mlx4: do vlan cleanup
Date: Fri, 15 Jul 2011 23:33:32 +0200
Message-ID: <1310765619-27827-15-git-send-email-jpirko@redhat.com>
References: <1310765619-27827-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, shemminger@linux-foundation.org,
	eric.dumazet@gmail.com, greearb@candelatech.com, mirqus@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2998 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753793Ab1GOVen (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Jul 2011 17:34:43 -0400
In-Reply-To: <1310765619-27827-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- unify vlan and nonvlan path
- kill priv->vlgrp and mlx4_en_vlan_rx_register

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/mlx4/en_netdev.c |   49 +++++++++--------------------------------
 drivers/net/mlx4/en_port.c   |   23 +++++++------------
 drivers/net/mlx4/en_rx.c     |   24 +++++++++++---------
 drivers/net/mlx4/mlx4_en.h   |    6 +++-
 4 files changed, 37 insertions(+), 65 deletions(-)

diff --git a/drivers/net/mlx4/en_netdev.c b/drivers/net/mlx4/en_netdev.c
index 61850ad..9d3f57e 100644
--- a/drivers/net/mlx4/en_netdev.c
+++ b/drivers/net/mlx4/en_netdev.c
@@ -45,25 +45,6 @@
 #include "mlx4_en.h"
 #include "en_port.h"
 
-
-static void mlx4_en_vlan_rx_register(struct net_device *dev, struct vlan_group *grp)
-{
-	struct mlx4_en_priv *priv = netdev_priv(dev);
-	struct mlx4_en_dev *mdev = priv->mdev;
-	int err;
-
-	en_dbg(HW, priv, "Registering VLAN group:%p\n", grp);
-	priv->vlgrp = grp;
-
-	mutex_lock(&mdev->state_lock);
-	if (mdev->device_up && priv->port_up) {
-		err = mlx4_SET_VLAN_FLTR(mdev->dev, priv->port, grp);
-		if (err)
-			en_err(priv, "Failed configuring VLAN filter\n");
-	}
-	mutex_unlock(&mdev->state_lock);
-}
-
 static void mlx4_en_vlan_rx_add_vid(struct net_device *dev, unsigned short vid)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
@@ -71,16 +52,14 @@ static void mlx4_en_vlan_rx_add_vid(struct net_device *dev, unsigned short vid)
 	int err;
 	int idx;
 
-	if (!priv->vlgrp)
-		return;
+	en_dbg(HW, priv, "adding VLAN:%d\n", vid);
 
-	en_dbg(HW, priv, "adding VLAN:%d (vlgrp entry:%p)\n",
-	       vid, vlan_group_get_device(priv->vlgrp, vid));
+	set_bit(vid, priv->active_vlans);
 
 	/* Add VID to port VLAN filter */
 	mutex_lock(&mdev->state_lock);
 	if (mdev->device_up && priv->port_up) {
-		err = mlx4_SET_VLAN_FLTR(mdev->dev, priv->port, priv->vlgrp);
+		err = mlx4_SET_VLAN_FLTR(mdev->dev, priv);
 		if (err)
 			en_err(priv, "Failed configuring VLAN filter\n");
 	}
@@ -97,12 +76,9 @@ static void mlx4_en_vlan_rx_kill_vid(struct net_device *dev, unsigned short vid)
 	int err;
 	int idx;
 
-	if (!priv->vlgrp)
-		return;
+	en_dbg(HW, priv, "Killing VID:%d\n", vid);
 
-	en_dbg(HW, priv, "Killing VID:%d (vlgrp:%p vlgrp entry:%p)\n",
-	       vid, priv->vlgrp, vlan_group_get_device(priv->vlgrp, vid));
-	vlan_group_set_device(priv->vlgrp, vid, NULL);
+	clear_bit(vid, priv->active_vlans);
 
 	/* Remove VID from port VLAN filter */
 	mutex_lock(&mdev->state_lock);
@@ -112,7 +88,7 @@ static void mlx4_en_vlan_rx_kill_vid(struct net_device *dev, unsigned short vid)
 		en_err(priv, "could not find vid %d in cache\n", vid);
 
 	if (mdev->device_up && priv->port_up) {
-		err = mlx4_SET_VLAN_FLTR(mdev->dev, priv->port, priv->vlgrp);
+		err = mlx4_SET_VLAN_FLTR(mdev->dev, priv);
 		if (err)
 			en_err(priv, "Failed configuring VLAN filter\n");
 	}
@@ -265,12 +241,10 @@ static void mlx4_en_do_set_multicast(struct work_struct *work)
 				priv->flags |= MLX4_EN_FLAG_MC_PROMISC;
 			}
 
-			if (priv->vlgrp) {
-				/* Disable port VLAN filter */
-				err = mlx4_SET_VLAN_FLTR(mdev->dev, priv->port, NULL);
-				if (err)
-					en_err(priv, "Failed disabling VLAN filter\n");
-			}
+			/* Disable port VLAN filter */
+			err = mlx4_SET_VLAN_FLTR(mdev->dev, priv);
+			if (err)
+				en_err(priv, "Failed disabling VLAN filter\n");
 		}
 		goto out;
 	}
@@ -304,7 +278,7 @@ static void mlx4_en_do_set_multicast(struct work_struct *work)
 		}
 
 		/* Enable port VLAN filter */
-		err = mlx4_SET_VLAN_FLTR(mdev->dev, priv->port, priv->vlgrp);
+		err = mlx4_SET_VLAN_FLTR(mdev->dev, priv);
 		if (err)
 			en_err(priv, "Failed enabling VLAN filter\n");
 	}
@@ -1046,7 +1020,6 @@ static const struct net_device_ops mlx4_netdev_ops = {
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_change_mtu		= mlx4_en_change_mtu,
 	.ndo_tx_timeout		= mlx4_en_tx_timeout,
-	.ndo_vlan_rx_register	= mlx4_en_vlan_rx_register,
 	.ndo_vlan_rx_add_vid	= mlx4_en_vlan_rx_add_vid,
 	.ndo_vlan_rx_kill_vid	= mlx4_en_vlan_rx_kill_vid,
 #ifdef CONFIG_NET_POLL_CONTROLLER
diff --git a/drivers/net/mlx4/en_port.c b/drivers/net/mlx4/en_port.c
index f2a4f5d..2a74bc8 100644
--- a/drivers/net/mlx4/en_port.c
+++ b/drivers/net/mlx4/en_port.c
@@ -48,7 +48,7 @@ int mlx4_SET_MCAST_FLTR(struct mlx4_dev *dev, u8 port,
 			MLX4_CMD_SET_MCAST_FLTR, MLX4_CMD_TIME_CLASS_B);
 }
 
-int mlx4_SET_VLAN_FLTR(struct mlx4_dev *dev, u8 port, struct vlan_group *grp)
+int mlx4_SET_VLAN_FLTR(struct mlx4_dev *dev, struct mlx4_en_priv *priv)
 {
 	struct mlx4_cmd_mailbox *mailbox;
 	struct mlx4_set_vlan_fltr_mbox *filter;
@@ -63,20 +63,15 @@ int mlx4_SET_VLAN_FLTR(struct mlx4_dev *dev, u8 port, struct vlan_group *grp)
 		return PTR_ERR(mailbox);
 
 	filter = mailbox->buf;
-	if (grp) {
-		memset(filter, 0, sizeof *filter);
-		for (i = VLAN_FLTR_SIZE - 1; i >= 0; i--) {
-			entry = 0;
-			for (j = 0; j < 32; j++)
-				if (vlan_group_get_device(grp, index++))
-					entry |= 1 << j;
-			filter->entry[i] = cpu_to_be32(entry);
-		}
-	} else {
-		/* When no vlans are configured we block all vlans */
-		memset(filter, 0, sizeof(*filter));
+	memset(filter, 0, sizeof(*filter));
+	for (i = VLAN_FLTR_SIZE - 1; i >= 0; i--) {
+		entry = 0;
+		for (j = 0; j < 32; j++)
+			if (test_bit(index++, priv->active_vlans))
+				entry |= 1 << j;
+		filter->entry[i] = cpu_to_be32(entry);
 	}
-	err = mlx4_cmd(dev, mailbox->dma, port, 0, MLX4_CMD_SET_VLAN_FLTR,
+	err = mlx4_cmd(dev, mailbox->dma, priv->port, 0, MLX4_CMD_SET_VLAN_FLTR,
 		       MLX4_CMD_TIME_CLASS_B);
 	mlx4_free_cmd_mailbox(dev, mailbox);
 	return err;
diff --git a/drivers/net/mlx4/en_rx.c b/drivers/net/mlx4/en_rx.c
index 5197b50..37cc9e5 100644
--- a/drivers/net/mlx4/en_rx.c
+++ b/drivers/net/mlx4/en_rx.c
@@ -611,11 +611,14 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 					gro_skb->truesize += length;
 					gro_skb->ip_summed = CHECKSUM_UNNECESSARY;
 
-					if (priv->vlgrp && (cqe->vlan_my_qpn &
-							    cpu_to_be32(MLX4_CQE_VLAN_PRESENT_MASK)))
-						vlan_gro_frags(&cq->napi, priv->vlgrp, be16_to_cpu(cqe->sl_vid));
-					else
-						napi_gro_frags(&cq->napi);
+					if (cqe->vlan_my_qpn &
+					    cpu_to_be32(MLX4_CQE_VLAN_PRESENT_MASK)) {
+						u16 vid = be16_to_cpu(cqe->sl_vid);
+
+						__vlan_hwaccel_put_tag(gro_skb, vid);
+					}
+
+					napi_gro_frags(&cq->napi);
 
 					goto next;
 				}
@@ -647,13 +650,12 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 		skb->protocol = eth_type_trans(skb, dev);
 		skb_record_rx_queue(skb, cq->ring);
 
+		if (be32_to_cpu(cqe->vlan_my_qpn) &
+		    MLX4_CQE_VLAN_PRESENT_MASK)
+			__vlan_hwaccel_put_tag(skb, be16_to_cpu(cqe->sl_vid));
+
 		/* Push it up the stack */
-		if (priv->vlgrp && (be32_to_cpu(cqe->vlan_my_qpn) &
-				    MLX4_CQE_VLAN_PRESENT_MASK)) {
-			vlan_hwaccel_receive_skb(skb, priv->vlgrp,
-						be16_to_cpu(cqe->sl_vid));
-		} else
-			netif_receive_skb(skb);
+		netif_receive_skb(skb);
 
 next:
 		++cq->mcq.cons_index;
diff --git a/drivers/net/mlx4/mlx4_en.h b/drivers/net/mlx4/mlx4_en.h
index 0b5150d..ed84811 100644
--- a/drivers/net/mlx4/mlx4_en.h
+++ b/drivers/net/mlx4/mlx4_en.h
@@ -34,10 +34,12 @@
 #ifndef _MLX4_EN_H_
 #define _MLX4_EN_H_
 
+#include <linux/bitops.h>
 #include <linux/compiler.h>
 #include <linux/list.h>
 #include <linux/mutex.h>
 #include <linux/netdevice.h>
+#include <linux/if_vlan.h>
 
 #include <linux/mlx4/device.h>
 #include <linux/mlx4/qp.h>
@@ -418,7 +420,7 @@ struct mlx4_en_priv {
 	struct mlx4_en_dev *mdev;
 	struct mlx4_en_port_profile *prof;
 	struct net_device *dev;
-	struct vlan_group *vlgrp;
+	unsigned long active_vlans[BITS_TO_LONGS(VLAN_N_VID)];
 	struct net_device_stats stats;
 	struct net_device_stats ret_stats;
 	struct mlx4_en_port_state port_state;
@@ -553,7 +555,7 @@ int mlx4_en_free_tx_buf(struct net_device *dev, struct mlx4_en_tx_ring *ring);
 void mlx4_en_rx_irq(struct mlx4_cq *mcq);
 
 int mlx4_SET_MCAST_FLTR(struct mlx4_dev *dev, u8 port, u64 mac, u64 clear, u8 mode);
-int mlx4_SET_VLAN_FLTR(struct mlx4_dev *dev, u8 port, struct vlan_group *grp);
+int mlx4_SET_VLAN_FLTR(struct mlx4_dev *dev, struct mlx4_en_priv *priv);
 int mlx4_SET_PORT_general(struct mlx4_dev *dev, u8 port, int mtu,
 			  u8 pptx, u8 pfctx, u8 pprx, u8 pfcrx);
 int mlx4_SET_PORT_qpn_calc(struct mlx4_dev *dev, u8 port, u32 base_qpn,
-- 
1.7.6

