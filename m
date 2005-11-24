From: Eugene Surovegin <ebs@ebshome.net>
Subject: [PATCH] ibm_emac: fix graceful stop timeout handling
Date: Thu, 24 Nov 2005 14:48:40 -0800
Message-ID: <20051124224840.GB21929@gate.ebshome.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linuxppc-embedded@ozlabs.org
Return-path: <linuxppc-embedded-bounces@ozlabs.org>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-embedded>,
	<mailto:linuxppc-embedded-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-embedded>
List-Post: <mailto:linuxppc-embedded@ozlabs.org>
List-Help: <mailto:linuxppc-embedded-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-embedded>,
	<mailto:linuxppc-embedded-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-embedded-bounces@ozlabs.org
Errors-To: linuxppc-embedded-bounces@ozlabs.org
List-Id: netdev.vger.kernel.org

This patch fixes graceful stop timeout handling in PPC4xx EMAC driver.

Currently, when we stop TX/RX channels we just do some number of loops 
without relying on actual spent time. This has finally bitten me on 
one of our systems (heavy network traffic during start up, RX channel 
is stopped several times to configure multicast list). 

Graceful channel stop can take up to 1 frame time, so I've added 
device specific timeout counter which depends on current link speed 
and calls to udelay() to really wait required amount of time before 
giving up.

Signed-off-by: Eugene Surovegin <ebs@ebshome.net>
---

 drivers/net/ibm_emac/ibm_emac_core.c |   38 ++++++++++++++++++++++++++--------
 drivers/net/ibm_emac/ibm_emac_core.h |    2 ++
 2 files changed, 31 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ibm_emac/ibm_emac_core.c b/drivers/net/ibm_emac/ibm_emac_core.c
index eb7d694..1da8a66 100644
--- a/drivers/net/ibm_emac/ibm_emac_core.c
+++ b/drivers/net/ibm_emac/ibm_emac_core.c
@@ -65,7 +65,7 @@
  */
 
 #define DRV_NAME        "emac"
-#define DRV_VERSION     "3.53"
+#define DRV_VERSION     "3.54"
 #define DRV_DESC        "PPC 4xx OCP EMAC driver"
 
 MODULE_DESCRIPTION(DRV_DESC);
@@ -158,6 +158,14 @@ static inline void emac_report_timeout_e
 #define PHY_POLL_LINK_ON	HZ
 #define PHY_POLL_LINK_OFF	(HZ / 5)
 
+/* Graceful stop timeouts in us. 
+ * We should allow up to 1 frame time (full-duplex, ignoring collisions) 
+ */
+#define STOP_TIMEOUT_10		1230	
+#define STOP_TIMEOUT_100	124
+#define STOP_TIMEOUT_1000	13
+#define STOP_TIMEOUT_1000_JUMBO	73
+
 /* Please, keep in sync with struct ibm_emac_stats/ibm_emac_error_stats */
 static const char emac_stats_keys[EMAC_ETHTOOL_STATS_COUNT][ETH_GSTRING_LEN] = {
 	"rx_packets", "rx_bytes", "tx_packets", "tx_bytes", "rx_packets_csum",
@@ -222,10 +230,12 @@ static void emac_tx_disable(struct ocp_e
 
 	r = in_be32(&p->mr0);
 	if (r & EMAC_MR0_TXE) {
-		int n = 300;
+		int n = dev->stop_timeout;
 		out_be32(&p->mr0, r & ~EMAC_MR0_TXE);
-		while (!(in_be32(&p->mr0) & EMAC_MR0_TXI) && n)
+		while (!(in_be32(&p->mr0) & EMAC_MR0_TXI) && n) {
+			udelay(1);
 			--n;
+		}	
 		if (unlikely(!n))
 			emac_report_timeout_error(dev, "TX disable timeout");
 	}
@@ -248,9 +258,11 @@ static void emac_rx_enable(struct ocp_en
 	if (!(r & EMAC_MR0_RXE)) {
 		if (unlikely(!(r & EMAC_MR0_RXI))) {
 			/* Wait if previous async disable is still in progress */
-			int n = 100;
-			while (!(r = in_be32(&p->mr0) & EMAC_MR0_RXI) && n)
+			int n = dev->stop_timeout;
+			while (!(r = in_be32(&p->mr0) & EMAC_MR0_RXI) && n) {
+				udelay(1);
 				--n;
+			}	
 			if (unlikely(!n))
 				emac_report_timeout_error(dev,
 							  "RX disable timeout");
@@ -273,10 +285,12 @@ static void emac_rx_disable(struct ocp_e
 
 	r = in_be32(&p->mr0);
 	if (r & EMAC_MR0_RXE) {
-		int n = 300;
+		int n = dev->stop_timeout;
 		out_be32(&p->mr0, r & ~EMAC_MR0_RXE);
-		while (!(in_be32(&p->mr0) & EMAC_MR0_RXI) && n)
+		while (!(in_be32(&p->mr0) & EMAC_MR0_RXI) && n) {
+			udelay(1);
 			--n;
+		}	
 		if (unlikely(!n))
 			emac_report_timeout_error(dev, "RX disable timeout");
 	}
@@ -395,6 +409,7 @@ static int emac_configure(struct ocp_ene
 	r = EMAC_MR1_BASE(emac_opb_mhz()) | EMAC_MR1_VLE | EMAC_MR1_IST;
 	if (dev->phy.duplex == DUPLEX_FULL)
 		r |= EMAC_MR1_FDE;
+	dev->stop_timeout = STOP_TIMEOUT_10;
 	switch (dev->phy.speed) {
 	case SPEED_1000:
 		if (emac_phy_gpcs(dev->phy.mode)) {
@@ -409,12 +424,16 @@ static int emac_configure(struct ocp_ene
 			r |= EMAC_MR1_MF_1000;
 		r |= EMAC_MR1_RFS_16K;
 		gige = 1;
-		
-		if (dev->ndev->mtu > ETH_DATA_LEN)
+
+		if (dev->ndev->mtu > ETH_DATA_LEN) {
 			r |= EMAC_MR1_JPSM;
+			dev->stop_timeout = STOP_TIMEOUT_1000_JUMBO;
+		} else
+			dev->stop_timeout = STOP_TIMEOUT_1000;
 		break;
 	case SPEED_100:
 		r |= EMAC_MR1_MF_100;
+		dev->stop_timeout = STOP_TIMEOUT_100;
 		/* Fall through */
 	default:
 		r |= EMAC_MR1_RFS_4K;
@@ -2048,6 +2067,7 @@ static int __init emac_probe(struct ocp_
 	dev->phy.duplex = DUPLEX_FULL;
 	dev->phy.autoneg = AUTONEG_DISABLE;
 	dev->phy.pause = dev->phy.asym_pause = 0;
+	dev->stop_timeout = STOP_TIMEOUT_100;
 	init_timer(&dev->link_timer);
 	dev->link_timer.function = emac_link_timer;
 	dev->link_timer.data = (unsigned long)dev;
diff --git a/drivers/net/ibm_emac/ibm_emac_core.h b/drivers/net/ibm_emac/ibm_emac_core.h
index e9b44d0..911abba 100644
--- a/drivers/net/ibm_emac/ibm_emac_core.h
+++ b/drivers/net/ibm_emac/ibm_emac_core.h
@@ -189,6 +189,8 @@ struct ocp_enet_private {
 	struct timer_list		link_timer;
 	int				reset_failed;
 
+	int				stop_timeout;	/* in us */
+
 	struct ibm_emac_error_stats	estats;
 	struct net_device_stats		nstats;
