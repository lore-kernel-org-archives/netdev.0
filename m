From: Iyappan Subramanian <isubramanian-qTEPVZfXA3Y@public.gmane.org>
Subject: [PATCH v5 02/11] drivers: net: xgene: Fix module unload crash - hw resource cleanup
Date: Thu,  7 Jul 2016 16:02:50 -0700
Message-ID: <1467932579-14320-3-git-send-email-isubramanian@apm.com>
References: <1467932579-14320-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, patches-qTEPVZfXA3Y@public.gmane.org,
	matthias.bgg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, andrew-g2DYL2Zd6BY@public.gmane.org, linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org,
	Iyappan Subramanian <isubramanian-qTEPVZfXA3Y@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1467932579-14320-1-git-send-email-isubramanian-qTEPVZfXA3Y@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

When the driver is configured as kernel module and when it gets
unloaded and reloaded, kernel crash was observed.  This patch
address the hardware resource cleanups by doing the following,

- Added mac_ops->clear() to do prefetch buffer clean up
- Fixed delete freepool buffers logic
- Reordered mac_enable and mac_disable
- Added Tx completion ring free
- Moved down delete_desc_rings after ring cleanup

Signed-off-by: Iyappan Subramanian <isubramanian-qTEPVZfXA3Y@public.gmane.org>
Tested-by: Fushen Chen <fchen-qTEPVZfXA3Y@public.gmane.org>
Tested-by: Toan Le <toanle-qTEPVZfXA3Y@public.gmane.org>
Tested-by: Matthias Brugger <mbrugger-IBi9RG/b67k@public.gmane.org>
---
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.c    | 41 ++++++++++++++++++
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.h    |  2 +
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c  | 39 +++++++----------
 drivers/net/ethernet/apm/xgene/xgene_enet_main.h  |  2 +
 drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c | 52 +++++++++++++++++++++--
 drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c | 42 +++++++++++++++++-
 6 files changed, 149 insertions(+), 29 deletions(-)

diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
index 725109b..009fb8e 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
@@ -697,8 +697,48 @@ static int xgene_enet_reset(struct xgene_enet_pdata *pdata)
 	return 0;
 }
 
+static void xgene_enet_clear(struct xgene_enet_pdata *pdata,
+			     struct xgene_enet_desc_ring *ring)
+{
+	u32 addr, val, data;
+
+	val = xgene_enet_ring_bufnum(ring->id);
+
+	if (xgene_enet_is_bufpool(ring->id)) {
+		addr = ENET_CFGSSQMIFPRESET_ADDR;
+		data = BIT(val - 0x20);
+	} else {
+		addr = ENET_CFGSSQMIWQRESET_ADDR;
+		data = BIT(val);
+	}
+
+	xgene_enet_wr_ring_if(pdata, addr, data);
+}
+
 static void xgene_gport_shutdown(struct xgene_enet_pdata *pdata)
 {
+	struct xgene_enet_desc_ring *ring;
+	u32 pb, val;
+	int i;
+
+	pb = 0;
+	for (i = 0; i < pdata->rxq_cnt; i++) {
+		ring = pdata->rx_ring[i]->buf_pool;
+
+		val = xgene_enet_ring_bufnum(ring->id);
+		pb |= BIT(val - 0x20);
+	}
+	xgene_enet_wr_ring_if(pdata, ENET_CFGSSQMIFPRESET_ADDR, pb);
+
+	pb = 0;
+	for (i = 0; i < pdata->txq_cnt; i++) {
+		ring = pdata->tx_ring[i];
+
+		val = xgene_enet_ring_bufnum(ring->id);
+		pb |= BIT(val);
+	}
+	xgene_enet_wr_ring_if(pdata, ENET_CFGSSQMIWQRESET_ADDR, pb);
+
 	if (!IS_ERR(pdata->clk))
 		clk_disable_unprepare(pdata->clk);
 }
@@ -901,6 +941,7 @@ const struct xgene_mac_ops xgene_gmac_ops = {
 
 const struct xgene_port_ops xgene_gport_ops = {
 	.reset = xgene_enet_reset,
+	.clear = xgene_enet_clear,
 	.cle_bypass = xgene_enet_cle_bypass,
 	.shutdown = xgene_gport_shutdown,
 };
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.h b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.h
index e840f96..eec55c1 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.h
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.h
@@ -167,6 +167,8 @@ enum xgene_enet_rm {
 #define TX_DV_GATE_EN0			BIT(2)
 #define RX_DV_GATE_EN0			BIT(1)
 #define RESUME_RX0			BIT(0)
+#define ENET_CFGSSQMIFPRESET_ADDR		0x14
+#define ENET_CFGSSQMIWQRESET_ADDR		0x1c
 #define ENET_CFGSSQMIWQASSOC_ADDR		0xe0
 #define ENET_CFGSSQMIFPQASSOC_ADDR		0xdc
 #define ENET_CFGSSQMIQMLITEFPQASSOC_ADDR	0xf0
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
index 8da3860..f79950a 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
@@ -102,25 +102,13 @@ static u8 xgene_enet_hdr_len(const void *data)
 
 static void xgene_enet_delete_bufpool(struct xgene_enet_desc_ring *buf_pool)
 {
-	struct xgene_enet_pdata *pdata = netdev_priv(buf_pool->ndev);
-	struct xgene_enet_raw_desc16 *raw_desc;
-	u32 slots = buf_pool->slots - 1;
-	u32 tail = buf_pool->tail;
-	u32 userinfo;
-	int i, len;
-
-	len = pdata->ring_ops->len(buf_pool);
-	for (i = 0; i < len; i++) {
-		tail = (tail - 1) & slots;
-		raw_desc = &buf_pool->raw_desc16[tail];
+	int i;
 
-		/* Hardware stores descriptor in little endian format */
-		userinfo = GET_VAL(USERINFO, le64_to_cpu(raw_desc->m0));
-		dev_kfree_skb_any(buf_pool->rx_skb[userinfo]);
+	/* Free up the buffers held by hardware */
+	for (i = 0; i < buf_pool->slots; i++) {
+		if (buf_pool->rx_skb[i])
+			dev_kfree_skb_any(buf_pool->rx_skb[i]);
 	}
-
-	pdata->ring_ops->wr_cmd(buf_pool, -len);
-	buf_pool->tail = tail;
 }
 
 static irqreturn_t xgene_enet_rx_irq(const int irq, void *data)
@@ -481,6 +469,7 @@ static int xgene_enet_rx_frame(struct xgene_enet_desc_ring *rx_ring,
 			 XGENE_ENET_MAX_MTU, DMA_FROM_DEVICE);
 	skb_index = GET_VAL(USERINFO, le64_to_cpu(raw_desc->m0));
 	skb = buf_pool->rx_skb[skb_index];
+	buf_pool->rx_skb[skb_index] = NULL;
 
 	/* checking for error */
 	status = (GET_VAL(ELERR, le64_to_cpu(raw_desc->m0)) << LERR_LEN) ||
@@ -720,9 +709,6 @@ static int xgene_enet_open(struct net_device *ndev)
 	if (ret)
 		return ret;
 
-	mac_ops->tx_enable(pdata);
-	mac_ops->rx_enable(pdata);
-
 	xgene_enet_napi_enable(pdata);
 	ret = xgene_enet_register_irq(ndev);
 	if (ret)
@@ -735,6 +721,8 @@ static int xgene_enet_open(struct net_device *ndev)
 		netif_carrier_off(ndev);
 	}
 
+	mac_ops->tx_enable(pdata);
+	mac_ops->rx_enable(pdata);
 	netif_start_queue(ndev);
 
 	return ret;
@@ -747,15 +735,14 @@ static int xgene_enet_close(struct net_device *ndev)
 	int i;
 
 	netif_stop_queue(ndev);
+	mac_ops->tx_disable(pdata);
+	mac_ops->rx_disable(pdata);
 
 	if (pdata->phy_mode == PHY_INTERFACE_MODE_RGMII)
 		phy_stop(pdata->phy_dev);
 	else
 		cancel_delayed_work_sync(&pdata->link_work);
 
-	mac_ops->tx_disable(pdata);
-	mac_ops->rx_disable(pdata);
-
 	xgene_enet_free_irq(ndev);
 	xgene_enet_napi_disable(pdata);
 	for (i = 0; i < pdata->rxq_cnt; i++)
@@ -785,6 +772,9 @@ static void xgene_enet_delete_desc_rings(struct xgene_enet_pdata *pdata)
 		ring = pdata->tx_ring[i];
 		if (ring) {
 			xgene_enet_delete_ring(ring);
+			pdata->port_ops->clear(pdata, ring);
+			if (pdata->cq_cnt)
+				xgene_enet_delete_ring(ring->cp_ring);
 			pdata->tx_ring[i] = NULL;
 		}
 	}
@@ -795,6 +785,7 @@ static void xgene_enet_delete_desc_rings(struct xgene_enet_pdata *pdata)
 			buf_pool = ring->buf_pool;
 			xgene_enet_delete_bufpool(buf_pool);
 			xgene_enet_delete_ring(buf_pool);
+			pdata->port_ops->clear(pdata, buf_pool);
 			xgene_enet_delete_ring(ring);
 			pdata->rx_ring[i] = NULL;
 		}
@@ -1682,8 +1673,8 @@ static int xgene_enet_remove(struct platform_device *pdev)
 	if (pdata->phy_mode == PHY_INTERFACE_MODE_RGMII)
 		xgene_enet_mdio_remove(pdata);
 	unregister_netdev(ndev);
-	xgene_enet_delete_desc_rings(pdata);
 	pdata->port_ops->shutdown(pdata);
+	xgene_enet_delete_desc_rings(pdata);
 	free_netdev(ndev);
 
 	return 0;
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.h b/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
index aed9f43..681a473 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
@@ -148,6 +148,8 @@ struct xgene_mac_ops {
 
 struct xgene_port_ops {
 	int (*reset)(struct xgene_enet_pdata *pdata);
+	void (*clear)(struct xgene_enet_pdata *pdata,
+		      struct xgene_enet_desc_ring *ring);
 	void (*cle_bypass)(struct xgene_enet_pdata *pdata,
 			   u32 dst_ring_num, u16 bufpool_id);
 	void (*shutdown)(struct xgene_enet_pdata *pdata);
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c b/drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c
index 01447ef..cf09e12 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_sgmac.c
@@ -137,9 +137,17 @@ static u32 xgene_enet_rd_mac(struct xgene_enet_pdata *p, u32 rd_addr)
 static int xgene_enet_ecc_init(struct xgene_enet_pdata *p)
 {
 	struct net_device *ndev = p->ndev;
-	u32 data;
+	u32 data, shutdown;
 	int i = 0;
 
+	shutdown = xgene_enet_rd_diag_csr(p, ENET_CFG_MEM_RAM_SHUTDOWN_ADDR);
+	data = xgene_enet_rd_diag_csr(p, ENET_BLOCK_MEM_RDY_ADDR);
+
+	if (!shutdown && data == ~0U) {
+		netdev_dbg(ndev, "+ ecc_init done, skipping\n");
+		return 0;
+	}
+
 	xgene_enet_wr_diag_csr(p, ENET_CFG_MEM_RAM_SHUTDOWN_ADDR, 0);
 	do {
 		usleep_range(100, 110);
@@ -462,10 +470,47 @@ static void xgene_enet_cle_bypass(struct xgene_enet_pdata *p,
 	xgene_enet_wr_csr(p, cle_bypass_reg1 + offset, data);
 }
 
+static void xgene_enet_clear(struct xgene_enet_pdata *pdata,
+			     struct xgene_enet_desc_ring *ring)
+{
+	u32 addr, val, data;
+
+	val = xgene_enet_ring_bufnum(ring->id);
+
+	if (xgene_enet_is_bufpool(ring->id)) {
+		addr = ENET_CFGSSQMIFPRESET_ADDR;
+		data = BIT(val - 0x20);
+	} else {
+		addr = ENET_CFGSSQMIWQRESET_ADDR;
+		data = BIT(val);
+	}
+
+	xgene_enet_wr_ring_if(pdata, addr, data);
+}
+
 static void xgene_enet_shutdown(struct xgene_enet_pdata *p)
 {
-	if (!IS_ERR(p->clk))
-		clk_disable_unprepare(p->clk);
+	struct xgene_enet_desc_ring *ring;
+	u32 pb, val;
+	int i;
+
+	pb = 0;
+	for (i = 0; i < p->rxq_cnt; i++) {
+		ring = p->rx_ring[i]->buf_pool;
+
+		val = xgene_enet_ring_bufnum(ring->id);
+		pb |= BIT(val - 0x20);
+	}
+	xgene_enet_wr_ring_if(p, ENET_CFGSSQMIFPRESET_ADDR, pb);
+
+	pb = 0;
+	for (i = 0; i < p->txq_cnt; i++) {
+		ring = p->tx_ring[i];
+
+		val = xgene_enet_ring_bufnum(ring->id);
+		pb |= BIT(val);
+	}
+	xgene_enet_wr_ring_if(p, ENET_CFGSSQMIWQRESET_ADDR, pb);
 }
 
 static void xgene_enet_link_state(struct work_struct *work)
@@ -513,6 +558,7 @@ const struct xgene_mac_ops xgene_sgmac_ops = {
 
 const struct xgene_port_ops xgene_sgport_ops = {
 	.reset		= xgene_enet_reset,
+	.clear		= xgene_enet_clear,
 	.cle_bypass	= xgene_enet_cle_bypass,
 	.shutdown	= xgene_enet_shutdown
 };
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c b/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c
index ba030dc..d0b4419 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_xgmac.c
@@ -292,8 +292,45 @@ static void xgene_enet_xgcle_bypass(struct xgene_enet_pdata *pdata,
 
 static void xgene_enet_shutdown(struct xgene_enet_pdata *pdata)
 {
-	if (!IS_ERR(pdata->clk))
-		clk_disable_unprepare(pdata->clk);
+	struct xgene_enet_desc_ring *ring;
+	u32 pb, val;
+	int i;
+
+	pb = 0;
+	for (i = 0; i < pdata->rxq_cnt; i++) {
+		ring = pdata->rx_ring[i]->buf_pool;
+
+		val = xgene_enet_ring_bufnum(ring->id);
+		pb |= BIT(val - 0x20);
+	}
+	xgene_enet_wr_ring_if(pdata, ENET_CFGSSQMIFPRESET_ADDR, pb);
+
+	pb = 0;
+	for (i = 0; i < pdata->txq_cnt; i++) {
+		ring = pdata->tx_ring[i];
+
+		val = xgene_enet_ring_bufnum(ring->id);
+		pb |= BIT(val);
+	}
+	xgene_enet_wr_ring_if(pdata, ENET_CFGSSQMIWQRESET_ADDR, pb);
+}
+
+static void xgene_enet_clear(struct xgene_enet_pdata *pdata,
+			     struct xgene_enet_desc_ring *ring)
+{
+	u32 addr, val, data;
+
+	val = xgene_enet_ring_bufnum(ring->id);
+
+	if (xgene_enet_is_bufpool(ring->id)) {
+		addr = ENET_CFGSSQMIFPRESET_ADDR;
+		data = BIT(val - 0x20);
+	} else {
+		addr = ENET_CFGSSQMIWQRESET_ADDR;
+		data = BIT(val);
+	}
+
+	xgene_enet_wr_ring_if(pdata, addr, data);
 }
 
 static void xgene_enet_link_state(struct work_struct *work)
@@ -340,6 +377,7 @@ const struct xgene_mac_ops xgene_xgmac_ops = {
 
 const struct xgene_port_ops xgene_xgport_ops = {
 	.reset = xgene_enet_reset,
+	.clear = xgene_enet_clear,
 	.cle_bypass = xgene_enet_xgcle_bypass,
 	.shutdown = xgene_enet_shutdown,
 };
-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
