From: Madalin Bucur <madalin.bucur@nxp.com>
Subject: [PATCH net-next v7 03/10] dpaa_eth: add option to use one buffer pool set
Date: Fri, 11 Nov 2016 10:20:00 +0200
Message-ID: <1478852407-27420-4-git-send-email-madalin.bucur@nxp.com>
References: <1478852407-27420-1-git-send-email-madalin.bucur@nxp.com>
Reply-To: <madalin.bucur@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linuxppc-dev@lists.ozlabs.org>, <linux-kernel@vger.kernel.org>,
        <davem@davemloft.net>, <oss@buserror.net>, <ppc@mindchasers.com>,
        <joe@perches.com>, <pebolle@tiscali.nl>,
        <joakim.tjernlund@infinera.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1478852407-27420-1-git-send-email-madalin.bucur@nxp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Madalin Bucur <madalin.bucur@nxp.com>
---
 drivers/net/ethernet/freescale/dpaa/Kconfig    |  9 +++++++++
 drivers/net/ethernet/freescale/dpaa/dpaa_eth.c | 23 +++++++++++++++++++++++
 2 files changed, 32 insertions(+)

diff --git a/drivers/net/ethernet/freescale/dpaa/Kconfig b/drivers/net/ethernet/freescale/dpaa/Kconfig
index f3a3454..c0ebc92 100644
--- a/drivers/net/ethernet/freescale/dpaa/Kconfig
+++ b/drivers/net/ethernet/freescale/dpaa/Kconfig
@@ -8,3 +8,12 @@ menuconfig FSL_DPAA_ETH
 	  supporting the Freescale QorIQ chips.
 	  Depends on Freescale Buffer Manager and Queue Manager
 	  driver and Frame Manager Driver.
+
+if FSL_DPAA_ETH
+config FSL_DPAA_ETH_COMMON_BPOOL
+	bool "Use a common buffer pool set for all the interfaces"
+	---help---
+	  The DPAA Ethernet netdevices require buffer pools for storing the buffers
+	  used by the FMan hardware for reception. One can use a single buffer pool
+	  set for all interfaces or a dedicated buffer pool set for each interface.
+endif # FSL_DPAA_ETH
diff --git a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
index 8b9b0720f..aa3a155 100644
--- a/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
+++ b/drivers/net/ethernet/freescale/dpaa/dpaa_eth.c
@@ -158,6 +158,11 @@ struct fm_port_fqs {
 	struct dpaa_fq *rx_errq;
 };
 
+#ifdef CONFIG_FSL_DPAA_ETH_COMMON_BPOOL
+/* These bpools are shared by all the dpaa interfaces */
+static u8 dpaa_common_bpids[DPAA_BPS_NUM];
+#endif
+
 /* All the dpa bps in use at any moment */
 static struct dpaa_bp *dpaa_bp_array[BM_MAX_NUM_OF_POOLS];
 
@@ -2470,6 +2475,12 @@ static int dpaa_eth_probe(struct platform_device *pdev)
 	for (i = 0; i < DPAA_BPS_NUM; i++) {
 		int err;
 
+#ifdef CONFIG_FSL_DPAA_ETH_COMMON_BPOOL
+		/* if another interface probed the bps reuse those */
+		dpaa_bps[i] = (dpaa_common_bpids[i] != FSL_DPAA_BPID_INV) ?
+				dpaa_bpid2pool(dpaa_common_bpids[i]) : NULL;
+		if (!dpaa_bps[i]) {
+#endif
 		dpaa_bps[i] = dpaa_bp_alloc(dev);
 		if (IS_ERR(dpaa_bps[i]))
 			return PTR_ERR(dpaa_bps[i]);
@@ -2485,6 +2496,11 @@ static int dpaa_eth_probe(struct platform_device *pdev)
 			priv->dpaa_bps[i] = NULL;
 			goto bp_create_failed;
 		}
+#ifdef CONFIG_FSL_DPAA_ETH_COMMON_BPOOL
+		}
+		dpaa_common_bpids[i] = dpaa_bps[i]->bpid;
+		dpaa_bps[i] = (dpaa_bpid2pool(dpaa_common_bpids[i]));
+#endif
 		priv->dpaa_bps[i] = dpaa_bps[i];
 	}
 
@@ -2659,6 +2675,13 @@ static int __init dpaa_load(void)
 	dpaa_rx_extra_headroom = fman_get_rx_extra_headroom();
 	dpaa_max_frm = fman_get_max_frm();
 
+#ifdef CONFIG_FSL_DPAA_ETH_COMMON_BPOOL
+	/* set initial invalid values, first interface probe will set correct
+	 * values that will be shared by the other interfaces
+	 */
+	memset(dpaa_common_bpids, FSL_DPAA_BPID_INV, sizeof(dpaa_common_bpids));
+#endif
+
 	err = platform_driver_register(&dpaa_driver);
 	if (err < 0)
 		pr_err("Error, platform_driver_register() = %d\n", err);
-- 
2.1.0
