From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH net-next 4/8] drivers: net: xgene: Add change_mtu function
Date: Thu,  1 Dec 2016 16:41:40 -0800
Message-ID: <1480639304-18757-5-git-send-email-isubramanian@apm.com>
References: <1480639304-18757-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, patches@apm.com,
        Iyappan Subramanian <isubramanian@apm.com>,
        Quan Nguyen <qnguyen@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f41.google.com ([74.125.83.41]:34532 "EHLO
        mail-pg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755569AbcLBAkn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 19:40:43 -0500
Received: by mail-pg0-f41.google.com with SMTP id x23so100733211pgx.1
        for <netdev@vger.kernel.org>; Thu, 01 Dec 2016 16:40:43 -0800 (PST)
In-Reply-To: <1480639304-18757-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch implements ndo_change_mtu() callback function that
enables mtu change.

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
Signed-off-by: Quan Nguyen <qnguyen@apm.com>
---
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.c    |  6 ++++++
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c  | 20 ++++++++++++++++++++
 drivers/net/ethernet/apm/xgene/xgene_enet_main.h  |  1 +
 drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c |  6 ++++++
 drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c |  7 +++++++
 5 files changed, 40 insertions(+)

diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
index fc9010f..92cc7e5 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
@@ -504,6 +504,11 @@ static void xgene_gmac_set_speed(struct xgene_enet_pdata *pdata)
 	xgene_enet_wr_mcx_csr(pdata, ICM_CONFIG2_REG_0_ADDR, icm2);
 }
 
+static void xgene_enet_set_frame_size(struct xgene_enet_pdata *pdata, int size)
+{
+	xgene_enet_wr_mcx_mac(pdata, MAX_FRAME_LEN_ADDR, size);
+}
+
 static void xgene_gmac_init(struct xgene_enet_pdata *pdata)
 {
 	u32 value;
@@ -903,6 +908,7 @@ void xgene_enet_mdio_remove(struct xgene_enet_pdata *pdata)
 	.tx_disable = xgene_gmac_tx_disable,
 	.set_speed = xgene_gmac_set_speed,
 	.set_mac_addr = xgene_gmac_set_mac_addr,
+	.set_framesize = xgene_enet_set_frame_size,
 };
 
 const struct xgene_port_ops xgene_gport_ops = {
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
index 698df27..6c7eea8 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
@@ -1500,12 +1500,31 @@ static int xgene_enet_set_mac_address(struct net_device *ndev, void *addr)
 	return ret;
 }
 
+static int xgene_change_mtu(struct net_device *ndev, int new_mtu)
+{
+	struct xgene_enet_pdata *pdata = netdev_priv(ndev);
+	int frame_size;
+
+	if (!netif_running(ndev))
+		return 0;
+
+	frame_size = (new_mtu > ETH_DATA_LEN) ? (new_mtu + 18) : 0x600;
+
+	xgene_enet_close(ndev);
+	ndev->mtu = new_mtu;
+	pdata->mac_ops->set_framesize(pdata, frame_size);
+	xgene_enet_open(ndev);
+
+	return 0;
+}
+
 static const struct net_device_ops xgene_ndev_ops = {
 	.ndo_open = xgene_enet_open,
 	.ndo_stop = xgene_enet_close,
 	.ndo_start_xmit = xgene_enet_start_xmit,
 	.ndo_tx_timeout = xgene_enet_timeout,
 	.ndo_get_stats64 = xgene_enet_get_stats64,
+	.ndo_change_mtu = xgene_change_mtu,
 	.ndo_set_mac_address = xgene_enet_set_mac_address,
 };
 
@@ -1832,6 +1851,7 @@ static int xgene_enet_init_hw(struct xgene_enet_pdata *pdata)
 					    buf_pool->id, ring_id);
 	}
 
+	ndev->max_mtu = XGENE_ENET_MAX_MTU;
 	pdata->phy_speed = SPEED_UNKNOWN;
 	pdata->mac_ops->init(pdata);
 
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.h b/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
index 023ed76..61aa987 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
@@ -156,6 +156,7 @@ struct xgene_mac_ops {
 	void (*rx_disable)(struct xgene_enet_pdata *pdata);
 	void (*set_speed)(struct xgene_enet_pdata *pdata);
 	void (*set_mac_addr)(struct xgene_enet_pdata *pdata);
+	void (*set_framesize)(struct xgene_enet_pdata *pdata, int framesize);
 	void (*set_mss)(struct xgene_enet_pdata *pdata, u16 mss, u8 index);
 	void (*link_state)(struct work_struct *work);
 };
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c b/drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c
index a10ab64..6283f2b 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c
@@ -343,6 +343,11 @@ static void xgene_sgmac_set_speed(struct xgene_enet_pdata *p)
 	xgene_enet_wr_mcx_csr(p, icm2_addr, icm2);
 }
 
+static void xgene_sgmac_set_frame_size(struct xgene_enet_pdata *pdata, int size)
+{
+	xgene_enet_wr_mac(pdata, MAX_FRAME_LEN_ADDR, size);
+}
+
 static void xgene_sgmii_enable_autoneg(struct xgene_enet_pdata *p)
 {
 	u32 data, loop = 10;
@@ -595,6 +600,7 @@ static void xgene_enet_link_state(struct work_struct *work)
 	.tx_disable	= xgene_sgmac_tx_disable,
 	.set_speed	= xgene_sgmac_set_speed,
 	.set_mac_addr	= xgene_sgmac_set_mac_addr,
+	.set_framesize  = xgene_sgmac_set_frame_size,
 	.link_state	= xgene_enet_link_state
 };
 
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c b/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c
index 4109776..2a9761b 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c
@@ -250,6 +250,12 @@ static void xgene_xgmac_set_mss(struct xgene_enet_pdata *pdata,
 	xgene_enet_wr_csr(pdata, XG_TSIF_MSS_REG0_ADDR + offset, data);
 }
 
+static void xgene_xgmac_set_frame_size(struct xgene_enet_pdata *pdata, int size)
+{
+	xgene_enet_wr_mac(pdata, HSTMAXFRAME_LENGTH_ADDR,
+			  ((((size + 2) >> 2) << 16) | size));
+}
+
 static u32 xgene_enet_link_status(struct xgene_enet_pdata *pdata)
 {
 	u32 data;
@@ -474,6 +480,7 @@ static void xgene_enet_link_state(struct work_struct *work)
 	.rx_disable = xgene_xgmac_rx_disable,
 	.tx_disable = xgene_xgmac_tx_disable,
 	.set_mac_addr = xgene_xgmac_set_mac_addr,
+	.set_framesize = xgene_xgmac_set_frame_size,
 	.set_mss = xgene_xgmac_set_mss,
 	.link_state = xgene_enet_link_state
 };
-- 
1.9.1
