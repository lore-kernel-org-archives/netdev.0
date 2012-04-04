From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH V4 net-next 06/26] ixp4xx_eth: Support the get_ts_info ethtool method.
Date: Wed,  4 Apr 2012 10:59:21 +0200
Message-ID: <c81fd9344333fd1f4f4332709f6334c33de9c325.1333529506.git.richardcochran@gmail.com>
References: <cover.1333529504.git.richardcochran@gmail.com>
Cc: David Miller <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Martin Porter <mporter@solarflare.com>,
	Jacob Keller <jacob.e.keller@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	e1000-devel@lists.sourceforge.net
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:46716 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932100Ab2DDJAX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Apr 2012 05:00:23 -0400
Received: by wejx9 with SMTP id x9so25092wej.19
        for <netdev@vger.kernel.org>; Wed, 04 Apr 2012 02:00:21 -0700 (PDT)
In-Reply-To: <cover.1333529504.git.richardcochran@gmail.com>
In-Reply-To: <cover.1333529504.git.richardcochran@gmail.com>
References: <cover.1333529504.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
