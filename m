From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6 16/21] s2io: do vlan cleanup
Date: Fri, 15 Jul 2011 23:33:34 +0200
Message-ID: <1310765619-27827-17-git-send-email-jpirko@redhat.com>
References: <1310765619-27827-1-git-send-email-jpirko@redhat.com>
Cc: davem@davemloft.net, shemminger@linux-foundation.org,
	eric.dumazet@gmail.com, greearb@candelatech.com, mirqus@gmail.com,
	jdmason@kudzu.us
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45245 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753328Ab1GOVeS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Jul 2011 17:34:18 -0400
In-Reply-To: <1310765619-27827-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- unify vlan and nonvlan rx path
- kill sp->vlgrp and s2io_vlan_rx_register and s2io_vlan_rx_kill_vid
(which does nothing and is never called :))

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/s2io.c |   70 ++++-----------------------------------------------
 drivers/net/s2io.h |    1 -
 2 files changed, 6 insertions(+), 65 deletions(-)

diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index 043850b..277d48b 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -356,56 +356,6 @@ static void do_s2io_copy_mac_addr(struct s2io_nic *sp, int offset, u64 mac_addr)
 	sp->def_mac_addr[offset].mac_addr[0] = (u8) (mac_addr >> 40);
 }
 
-/* Add the vlan */
-static void s2io_vlan_rx_register(struct net_device *dev,
-				  struct vlan_group *grp)
-{
-	int i;
-	struct s2io_nic *nic = netdev_priv(dev);
-	unsigned long flags[MAX_TX_FIFOS];
-	struct config_param *config = &nic->config;
-	struct mac_info *mac_control = &nic->mac_control;
-
-	for (i = 0; i < config->tx_fifo_num; i++) {
-		struct fifo_info *fifo = &mac_control->fifos[i];
-
-		spin_lock_irqsave(&fifo->tx_lock, flags[i]);
-	}
-
-	nic->vlgrp = grp;
-
-	for (i = config->tx_fifo_num - 1; i >= 0; i--) {
-		struct fifo_info *fifo = &mac_control->fifos[i];
-
-		spin_unlock_irqrestore(&fifo->tx_lock, flags[i]);
-	}
-}
-
-/* Unregister the vlan */
-static void s2io_vlan_rx_kill_vid(struct net_device *dev, unsigned short vid)
-{
-	int i;
-	struct s2io_nic *nic = netdev_priv(dev);
-	unsigned long flags[MAX_TX_FIFOS];
-	struct config_param *config = &nic->config;
-	struct mac_info *mac_control = &nic->mac_control;
-
-	for (i = 0; i < config->tx_fifo_num; i++) {
-		struct fifo_info *fifo = &mac_control->fifos[i];
-
-		spin_lock_irqsave(&fifo->tx_lock, flags[i]);
-	}
-
-	if (nic->vlgrp)
-		vlan_group_set_device(nic->vlgrp, vid, NULL);
-
-	for (i = config->tx_fifo_num - 1; i >= 0; i--) {
-		struct fifo_info *fifo = &mac_control->fifos[i];
-
-		spin_unlock_irqrestore(&fifo->tx_lock, flags[i]);
-	}
-}
-
 /*
  * Constants to be programmed into the Xena's registers, to configure
  * the XAUI.
@@ -7737,8 +7687,6 @@ static const struct net_device_ops s2io_netdev_ops = {
 	.ndo_set_mac_address    = s2io_set_mac_addr,
 	.ndo_change_mtu	   	= s2io_change_mtu,
 	.ndo_set_features	= s2io_set_features,
-	.ndo_vlan_rx_register   = s2io_vlan_rx_register,
-	.ndo_vlan_rx_kill_vid   = s2io_vlan_rx_kill_vid,
 	.ndo_tx_timeout	   	= s2io_tx_watchdog,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller    = s2io_netpoll,
@@ -8617,18 +8565,12 @@ static void queue_rx_frame(struct sk_buff *skb, u16 vlan_tag)
 	struct s2io_nic *sp = netdev_priv(dev);
 
 	skb->protocol = eth_type_trans(skb, dev);
-	if (sp->vlgrp && vlan_tag && (sp->vlan_strip_flag)) {
-		/* Queueing the vlan frame to the upper layer */
-		if (sp->config.napi)
-			vlan_hwaccel_receive_skb(skb, sp->vlgrp, vlan_tag);
-		else
-			vlan_hwaccel_rx(skb, sp->vlgrp, vlan_tag);
-	} else {
-		if (sp->config.napi)
-			netif_receive_skb(skb);
-		else
-			netif_rx(skb);
-	}
+	if (vlan_tag && sp->vlan_strip_flag)
+		__vlan_hwaccel_put_tag(skb, vlan_tag);
+	if (sp->config.napi)
+		netif_receive_skb(skb);
+	else
+		netif_rx(skb);
 }
 
 static void lro_append_pkt(struct s2io_nic *sp, struct lro *lro,
diff --git a/drivers/net/s2io.h b/drivers/net/s2io.h
index 800b3a4..ae3c8e7 100644
--- a/drivers/net/s2io.h
+++ b/drivers/net/s2io.h
@@ -939,7 +939,6 @@ struct s2io_nic {
 
 	int task_flag;
 	unsigned long long start_time;
-	struct vlan_group *vlgrp;
 	int vlan_strip_flag;
 #define MSIX_FLG                0xA5
 	int num_entries;
-- 
1.7.6

