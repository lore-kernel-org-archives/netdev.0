From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH V3 net-next 07/28] ixp4xx_eth: Support the
	get_ts_info ethtool method.
Date: Tue,  3 Apr 2012 19:47:31 +0200
Message-ID: <2a9fdd3a9166a603922f3a5b082e7bb0610fcb44.1333474523.git.richardcochran@gmail.com>
References: <cover.1333474520.git.richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, Martin Porter <mporter@solarflare.com>,
	John Ronciak <john.ronciak@intel.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>, Jacob Keller <jacob.e.keller@intel.com>
To: <netdev@vger.kernel.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <cover.1333474520.git.richardcochran@gmail.com>
In-Reply-To: <cover.1333474520.git.richardcochran@gmail.com>
References: <cover.1333474520.git.richardcochran@gmail.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 arch/arm/mach-ixp4xx/include/mach/ixp46x_ts.h |    3 ++
 drivers/net/ethernet/xscale/ixp4xx_eth.c      |   29 +++++++++++++++++++++++++
 drivers/ptp/ptp_ixp46x.c                      |    3 ++
 3 files changed, 35 insertions(+), 0 deletions(-)

diff --git a/arch/arm/mach-ixp4xx/include/mach/ixp46x_ts.h b/arch/arm/mach-ixp4xx/include/mach/ixp46x_ts.h
index 292d55e..cf03614 100644
--- a/arch/arm/mach-ixp4xx/include/mach/ixp46x_ts.h
+++ b/arch/arm/mach-ixp4xx/include/mach/ixp46x_ts.h
@@ -75,4 +75,7 @@ struct ixp46x_ts_regs {
 #define TX_SNAPSHOT_LOCKED (1<<0)
 #define RX_SNAPSHOT_LOCKED (1<<1)
 
+/* The ptp_ixp46x module will set this variable */
+extern int ixp46x_phc_index;
+
 #endif
diff --git a/drivers/net/ethernet/xscale/ixp4xx_eth.c b/drivers/net/ethernet/xscale/ixp4xx_eth.c
index 41a8b5a..482648f 100644
--- a/drivers/net/ethernet/xscale/ixp4xx_eth.c
+++ b/drivers/net/ethernet/xscale/ixp4xx_eth.c
@@ -1002,12 +1002,41 @@ static int ixp4xx_nway_reset(struct net_device *dev)
 	return phy_start_aneg(port->phydev);
 }
 
+int ixp46x_phc_index = -1;
+
+static int ixp4xx_get_ts_info(struct net_device *dev,
+			      struct ethtool_ts_info *info)
+{
+	if (!cpu_is_ixp46x()) {
+		info->so_timestamping =
+			SOF_TIMESTAMPING_TX_SOFTWARE |
+			SOF_TIMESTAMPING_RX_SOFTWARE |
+			SOF_TIMESTAMPING_SOFTWARE;
+		info->phc_index = -1;
+		return 0;
+	}
+	info->so_timestamping =
+		SOF_TIMESTAMPING_TX_HARDWARE |
+		SOF_TIMESTAMPING_RX_HARDWARE |
+		SOF_TIMESTAMPING_RAW_HARDWARE;
+	info->phc_index = ixp46x_phc_index;
+	info->tx_types =
+		(1 << HWTSTAMP_TX_OFF) |
+		(1 << HWTSTAMP_TX_ON);
+	info->rx_filters =
+		(1 << HWTSTAMP_FILTER_NONE) |
+		(1 << HWTSTAMP_FILTER_PTP_V1_L4_SYNC) |
+		(1 << HWTSTAMP_FILTER_PTP_V1_L4_DELAY_REQ);
+	return 0;
+}
+
 static const struct ethtool_ops ixp4xx_ethtool_ops = {
 	.get_drvinfo = ixp4xx_get_drvinfo,
 	.get_settings = ixp4xx_get_settings,
 	.set_settings = ixp4xx_set_settings,
 	.nway_reset = ixp4xx_nway_reset,
 	.get_link = ethtool_op_get_link,
+	.get_ts_info = ixp4xx_get_ts_info,
 };
 
 
diff --git a/drivers/ptp/ptp_ixp46x.c b/drivers/ptp/ptp_ixp46x.c
index 6f2782b..9d13a71 100644
--- a/drivers/ptp/ptp_ixp46x.c
+++ b/drivers/ptp/ptp_ixp46x.c
@@ -284,6 +284,7 @@ static void __exit ptp_ixp_exit(void)
 {
 	free_irq(MASTER_IRQ, &ixp_clock);
 	free_irq(SLAVE_IRQ, &ixp_clock);
+	ixp46x_phc_clock = -1;
 	ptp_clock_unregister(ixp_clock.ptp_clock);
 }
 
@@ -302,6 +303,8 @@ static int __init ptp_ixp_init(void)
 	if (IS_ERR(ixp_clock.ptp_clock))
 		return PTR_ERR(ixp_clock.ptp_clock);
 
+	ixp46x_phc_clock = ptp_clock_index(ixp_clock.ptp_clock);
+
 	__raw_writel(DEFAULT_ADDEND, &ixp_clock.regs->addend);
 	__raw_writel(1, &ixp_clock.regs->trgt_lo);
 	__raw_writel(0, &ixp_clock.regs->trgt_hi);
-- 
1.7.2.5


------------------------------------------------------------------------------
Better than sec? Nothing is better than sec when it comes to
monitoring Big Data applications. Try Boundary one-second 
resolution app monitoring today. Free.
http://p.sf.net/sfu/Boundary-dev2dev
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
