From: Rasesh Mody <rmody@brocade.com>
Subject: [net-next 07/13] bna: Fix Stale MTU used to Configure Multi-buffer RX
Date: Wed, 20 Nov 2013 21:54:11 -0800
Message-ID: <1385013257-32745-8-git-send-email-rmody@brocade.com>
References: <1385013257-32745-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	<adapter_linux_open_src_team@Brocade.COM>,
	Rasesh Mody <rmody@Brocade.COM>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:23167 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750856Ab3KUGOr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Nov 2013 01:14:47 -0500
In-Reply-To: <1385013257-32745-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change Details:
 - Rx initialization uses MTU. ENET MTU set should be called before setting up
   Rx. Added checks to make sure that reinit is called only when required.

Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/ethernet/brocade/bna/bnad.c | 32 +++++++++++++++++++++++++-------
 drivers/net/ethernet/brocade/bna/bnad.h |  6 +-----
 2 files changed, 26 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/brocade/bna/bnad.c b/drivers/net/ethernet/brocade/bna/bnad.c
index e8c1900..6ae1d9a 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.c
+++ b/drivers/net/ethernet/brocade/bna/bnad.c
@@ -2013,6 +2013,7 @@ err_return:
 static void
 bnad_init_rx_config(struct bnad *bnad, struct bna_rx_config *rx_config)
 {
+	memset(rx_config, 0, sizeof(*rx_config));
 	rx_config->rx_type = BNA_RX_T_REGULAR;
 	rx_config->num_paths = bnad->num_rxp_per_rx;
 	rx_config->coalescing_timeo = bnad->rx_coalescing_timeo;
@@ -2035,6 +2036,7 @@ bnad_init_rx_config(struct bnad *bnad, struct bna_rx_config *rx_config)
 	}
 
 	rx_config->frame_size = BNAD_FRAME_SIZE(bnad->netdev->mtu);
+	rx_config->q0_multi_buf = BNA_STATUS_T_DISABLED;
 
 	/* BNA_RXP_SINGLE - one data-buffer queue
 	 * BNA_RXP_SLR - one small-buffer and one large-buffer queues
@@ -2044,7 +2046,8 @@ bnad_init_rx_config(struct bnad *bnad, struct bna_rx_config *rx_config)
 	rx_config->rxp_type = BNA_RXP_SLR;
 
 	if (BNAD_PCI_DEV_IS_CAT2(bnad) &&
-			bnad_enable_multi_buffer(rx_config->frame_size)) {
+			bnad_enable_multi_buffer &&
+			rx_config->frame_size > 4096) {
 		/* though size_routing_enable is set in SLR,
 		 * small packets may get routed to same rxq.
 		 * set buf_size to 2048 instead of PAGE_SIZE.
@@ -2092,8 +2095,16 @@ bnad_reinit_rx(struct bnad *bnad)
 	for (rx_id = 0; rx_id < bnad->num_rx; rx_id++) {
 		if (!bnad->rx_info[rx_id].rx)
 			continue;
-		count++;
 		bnad_destroy_rx(bnad, rx_id);
+	}
+
+	spin_lock_irqsave(&bnad->bna_lock, flags);
+	bna_enet_mtu_set(&bnad->bna.enet,
+			BNAD_FRAME_SIZE(bnad->netdev->mtu), NULL);
+	spin_unlock_irqrestore(&bnad->bna_lock, flags);
+
+	for (rx_id = 0; rx_id < bnad->num_rx; rx_id++) {
+		count++;
 		current_err = bnad_setup_rx(bnad, rx_id);
 		if (current_err && !err) {
 			err = current_err;
@@ -3262,7 +3273,7 @@ bnad_change_mtu(struct net_device *netdev, int new_mtu)
 {
 	int err, mtu;
 	struct bnad *bnad = netdev_priv(netdev);
-	u32 rx_count = 0;
+	u32 rx_count = 0, frame, new_frame;
 
 	if (new_mtu + ETH_HLEN < ETH_ZLEN || new_mtu > BNAD_JUMBO_MTU)
 		return -EINVAL;
@@ -3272,15 +3283,22 @@ bnad_change_mtu(struct net_device *netdev, int new_mtu)
 	mtu = netdev->mtu;
 	netdev->mtu = new_mtu;
 
+	frame = BNAD_FRAME_SIZE(mtu);
+	new_frame = BNAD_FRAME_SIZE(new_mtu);
+
 	/* check if multi-buffer needs to be enabled */
-	if (BNAD_PCI_DEV_IS_CAT2(bnad) &&
-			bnad_reinit_rx_needed(BNAD_FRAME_SIZE(new_mtu)))
-		rx_count = bnad_reinit_rx(bnad);
+	if (BNAD_PCI_DEV_IS_CAT2(bnad) && bnad_enable_multi_buffer &&
+						netif_running(bnad->netdev)) {
+		/* only when transition is over 4K */
+		if ((frame <= 4096 && new_frame > 4096) ||
+				(frame > 4096 && new_frame <= 4096))
+			rx_count = bnad_reinit_rx(bnad);
+	}
 
 	/* rx_count > 0 - new rx created
 	 *	- Linux set err = 0 and return
 	 */
-	err = bnad_mtu_set(bnad, new_mtu);
+	err = bnad_mtu_set(bnad, new_frame);
 	if (err)
 		err = -EBUSY;
 
diff --git a/drivers/net/ethernet/brocade/bna/bnad.h b/drivers/net/ethernet/brocade/bna/bnad.h
index d1dc930..f2b50d9 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.h
+++ b/drivers/net/ethernet/brocade/bna/bnad.h
@@ -263,11 +263,7 @@ struct bnad_rx_unmap_q {
 #define BNAD_PCI_DEV_IS_CAT2(_bnad) \
 	((_bnad)->pcidev->device == BFA_PCI_DEVICE_ID_CT2)
 
-#define bnad_enable_multi_buffer(_mtu) \
-		bnad_reinit_rx_needed((_mtu))
-
-#define bnad_reinit_rx_needed(_frame) \
-	(bnad_multi_buffer_rx && (_frame) > 4096)
+#define bnad_enable_multi_buffer bnad_multi_buffer_rx
 
 /* Bit mask values for bnad->cfg_flags */
 #define	BNAD_CF_DIM_ENABLED		0x01	/* DIM */
-- 
1.8.2.3
