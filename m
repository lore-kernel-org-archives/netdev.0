From: Amerigo Wang <amwang@redhat.com>
Subject: [v2 Patch 1/2] s2io: add dynamic LRO disable support
Date: Wed, 9 Jun 2010 06:05:24 -0400
Message-ID: <20100609100928.6573.14199.sendpatchset@localhost.localdomain>
Cc: nhorman@redhat.com, sgruszka@redhat.com, herbert.xu@redhat.com,
	Amerigo Wang <amwang@redhat.com>, bhutchings@solarflare.com,
	Ramkrishna.Vepa@exar.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1026 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751677Ab0FIKFb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Jun 2010 06:05:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This patch adds dynamic LRO diable support for s2io net driver.

I don't have s2io card, so only did compiling test. Anyone who wants
to test this is more than welcome.

This is based on Neil's initial work.

Signed-off-by: WANG Cong <amwang@redhat.com>
Signed-off-by: Neil Horman <nhorman@redhat.com>
Acked-by: Neil Horman <nhorman@redhat.com>
Reviewed-by: Stanislaw Gruszka <sgruszka@redhat.com>
Cc: Ramkrishna Vepa <Ramkrishna.Vepa@exar.com>

---

diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index 668327c..e558aa7 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -795,7 +795,6 @@ static int init_shared_mem(struct s2io_nic *nic)
 		ring->rx_curr_put_info.ring_len = rx_cfg->num_rxd - 1;
 		ring->nic = nic;
 		ring->ring_no = i;
-		ring->lro = lro_enable;
 
 		blk_cnt = rx_cfg->num_rxd / (rxd_count[nic->rxd_mode] + 1);
 		/*  Allocating all the Rx blocks */
@@ -6684,6 +6683,35 @@ static int s2io_ethtool_op_set_tso(struct net_device *dev, u32 data)
 
 	return 0;
 }
+static int s2io_ethtool_set_flags(struct net_device *dev, u32 data)
+{
+	struct s2io_nic *sp = netdev_priv(dev);
+	int rc = 0;
+	int changed = 0;
+
+	if (data & ETH_FLAG_LRO) {
+		if (lro_enable) {
+			if (!(dev->features & NETIF_F_LRO)) {
+				dev->features |= NETIF_F_LRO;
+				changed = 1;
+			}
+		} else
+			rc = -EINVAL;
+	} else if (dev->features & NETIF_F_LRO) {
+		dev->features &= ~NETIF_F_LRO;
+		changed = 1;
+	}
+
+	if (changed && netif_running(dev)) {
+		s2io_stop_all_tx_queue(sp);
+		s2io_card_down(sp);
+		sp->lro = dev->features & NETIF_F_LRO;
+		rc = s2io_card_up(sp);
+		s2io_start_all_tx_queue(sp);
+	}
+
+	return rc;
+}
 
 static const struct ethtool_ops netdev_ethtool_ops = {
 	.get_settings = s2io_ethtool_gset,
@@ -6701,6 +6729,8 @@ static const struct ethtool_ops netdev_ethtool_ops = {
 	.get_rx_csum = s2io_ethtool_get_rx_csum,
 	.set_rx_csum = s2io_ethtool_set_rx_csum,
 	.set_tx_csum = s2io_ethtool_op_set_tx_csum,
+	.set_flags = s2io_ethtool_set_flags,
+	.get_flags = ethtool_op_get_flags,
 	.set_sg = ethtool_op_set_sg,
 	.get_tso = s2io_ethtool_op_get_tso,
 	.set_tso = s2io_ethtool_op_set_tso,
@@ -7229,6 +7259,7 @@ static int s2io_card_up(struct s2io_nic *sp)
 		struct ring_info *ring = &mac_control->rings[i];
 
 		ring->mtu = dev->mtu;
+		ring->lro = sp->lro;
 		ret = fill_rx_buffers(sp, ring, 1);
 		if (ret) {
 			DBG_PRINT(ERR_DBG, "%s: Out of memory in Open\n",
