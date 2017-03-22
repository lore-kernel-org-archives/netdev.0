From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH v2 net-next 3/4] drivers: net: xgene-v2: Fix port reset
Date: Tue, 21 Mar 2017 18:18:04 -0700
Message-ID: <1490145485-32661-4-git-send-email-isubramanian@apm.com>
References: <1490145485-32661-1-git-send-email-isubramanian@apm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kchudgar@apm.com, patches@apm.com, linux-arm-kernel@lists.infradead.org,
 Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org, andrew@lunn.ch,
 f.fainelli@gmail.com, David.Laight@aculab.com
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1490145485-32661-1-git-send-email-isubramanian@apm.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Fixed port reset sequence by adding ECC init.

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
---
 drivers/net/ethernet/apm/xgene-v2/enet.c | 24 ++++++++++++++++++------
 drivers/net/ethernet/apm/xgene-v2/enet.h |  2 ++
 drivers/net/ethernet/apm/xgene-v2/mac.h  |  1 -
 3 files changed, 20 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/apm/xgene-v2/enet.c b/drivers/net/ethernet/apm/xgene-v2/enet.c
index b49edee..5998da0 100644
--- a/drivers/net/ethernet/apm/xgene-v2/enet.c
+++ b/drivers/net/ethernet/apm/xgene-v2/enet.c
@@ -38,10 +38,24 @@ u32 xge_rd_csr(struct xge_pdata *pdata, u32 offset)
 int xge_port_reset(struct net_device *ndev)
 {
 	struct xge_pdata *pdata = netdev_priv(ndev);
+	struct device *dev = &pdata->pdev->dev;
+	u32 data, wait = 10;
 
-	xge_wr_csr(pdata, ENET_SRST, 0x3);
-	xge_wr_csr(pdata, ENET_SRST, 0x2);
-	xge_wr_csr(pdata, ENET_SRST, 0x0);
+	xge_wr_csr(pdata, ENET_CLKEN, 0x3);
+	xge_wr_csr(pdata, ENET_SRST, 0xf);
+	xge_wr_csr(pdata, ENET_SRST, 0);
+	xge_wr_csr(pdata, CFG_MEM_RAM_SHUTDOWN, 1);
+	xge_wr_csr(pdata, CFG_MEM_RAM_SHUTDOWN, 0);
+
+	do {
+		usleep_range(100, 110);
+		data = xge_rd_csr(pdata, BLOCK_MEM_RDY);
+	} while (data != MEM_RDY && wait--);
+
+	if (data != MEM_RDY) {
+		dev_err(dev, "ECC init failed: %x\n", data);
+		return -ETIMEDOUT;
+	}
 
 	xge_wr_csr(pdata, ENET_SHIM, DEVM_ARAUX_COH | DEVM_AWAUX_COH);
 
@@ -59,13 +73,11 @@ static void xge_traffic_resume(struct net_device *ndev)
 	xge_wr_csr(pdata, RX_DV_GATE_REG, 1);
 }
 
-int xge_port_init(struct net_device *ndev)
+void xge_port_init(struct net_device *ndev)
 {
 	struct xge_pdata *pdata = netdev_priv(ndev);
 
 	pdata->phy_speed = SPEED_1000;
 	xge_mac_init(pdata);
 	xge_traffic_resume(ndev);
-
-	return 0;
 }
diff --git a/drivers/net/ethernet/apm/xgene-v2/enet.h b/drivers/net/ethernet/apm/xgene-v2/enet.h
index 40371cf..3fd36dc6 100644
--- a/drivers/net/ethernet/apm/xgene-v2/enet.h
+++ b/drivers/net/ethernet/apm/xgene-v2/enet.h
@@ -28,6 +28,7 @@
 #define CFG_MEM_RAM_SHUTDOWN	0xd070
 #define BLOCK_MEM_RDY		0xd074
 
+#define MEM_RDY			0xffffffff
 #define DEVM_ARAUX_COH		BIT(19)
 #define DEVM_AWAUX_COH		BIT(3)
 
@@ -39,5 +40,6 @@
 void xge_wr_csr(struct xge_pdata *pdata, u32 offset, u32 val);
 u32 xge_rd_csr(struct xge_pdata *pdata, u32 offset);
 int xge_port_reset(struct net_device *ndev);
+void xge_port_init(struct net_device *ndev);
 
 #endif  /* __XGENE_ENET_V2_ENET__H__ */
diff --git a/drivers/net/ethernet/apm/xgene-v2/mac.h b/drivers/net/ethernet/apm/xgene-v2/mac.h
index 74397c9..18a9c9d 100644
--- a/drivers/net/ethernet/apm/xgene-v2/mac.h
+++ b/drivers/net/ethernet/apm/xgene-v2/mac.h
@@ -105,7 +105,6 @@ static inline u32 xgene_get_reg_bits(u32 var, int pos, int len)
 void xge_mac_enable(struct xge_pdata *pdata);
 void xge_mac_disable(struct xge_pdata *pdata);
 void xge_mac_init(struct xge_pdata *pdata);
-int xge_port_init(struct net_device *ndev);
 void xge_mac_set_station_addr(struct xge_pdata *pdata);
 
 #endif /* __XGENE_ENET_V2_MAC_H__ */
-- 
1.9.1
