From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 5/5] ixgbe: add ethtool counters for OS2BMC
Date: Sat,  7 May 2011 03:25:23 -0700
Message-ID: <1304763923-6839-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1304763923-6839-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:24860 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754594Ab1EGKZa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 7 May 2011 06:25:30 -0400
In-Reply-To: <1304763923-6839-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

OS2BMC registers are available for X540.
This patch adds ethtool counters based on those registers.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Evan Swanson <evan.swanson@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_ethtool.c |    4 ++++
 drivers/net/ixgbe/ixgbe_main.c    |    7 ++++++-
 drivers/net/ixgbe/ixgbe_type.h    |    8 ++++++++
 3 files changed, 18 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index 545b231..1fdd075 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -102,6 +102,10 @@ static struct ixgbe_stats ixgbe_gstrings_stats[] = {
 	{"alloc_rx_page_failed", IXGBE_STAT(alloc_rx_page_failed)},
 	{"alloc_rx_buff_failed", IXGBE_STAT(alloc_rx_buff_failed)},
 	{"rx_no_dma_resources", IXGBE_STAT(hw_rx_no_dma_resources)},
+	{"os2bmc_rx_by_bmc", IXGBE_STAT(stats.o2bgptc)},
+	{"os2bmc_tx_by_bmc", IXGBE_STAT(stats.b2ospc)},
+	{"os2bmc_tx_by_host", IXGBE_STAT(stats.o2bspc)},
+	{"os2bmc_rx_by_host", IXGBE_STAT(stats.b2ogprc)},
 #ifdef IXGBE_FCOE
 	{"fcoe_bad_fccrc", IXGBE_STAT(stats.fccrc)},
 	{"rx_fcoe_dropped", IXGBE_STAT(stats.fcoerpdc)},
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 56cc9a1..a3e384b 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -5912,8 +5912,13 @@ void ixgbe_update_stats(struct ixgbe_adapter *adapter)
 		hwstats->gotc += IXGBE_READ_REG(hw, IXGBE_GOTCH);
 		hwstats->tor += IXGBE_READ_REG(hw, IXGBE_TORH);
 		break;
-	case ixgbe_mac_82599EB:
 	case ixgbe_mac_X540:
+		/* OS2BMC stats are X540 only*/
+		hwstats->o2bgptc += IXGBE_READ_REG(hw, IXGBE_O2BGPTC);
+		hwstats->o2bspc += IXGBE_READ_REG(hw, IXGBE_O2BSPC);
+		hwstats->b2ospc += IXGBE_READ_REG(hw, IXGBE_B2OSPC);
+		hwstats->b2ogprc += IXGBE_READ_REG(hw, IXGBE_B2OGPRC);
+	case ixgbe_mac_82599EB:
 		hwstats->gorc += IXGBE_READ_REG(hw, IXGBE_GORCL);
 		IXGBE_READ_REG(hw, IXGBE_GORCH); /* to clear */
 		hwstats->gotc += IXGBE_READ_REG(hw, IXGBE_GOTCL);
diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index b1d523c..70e6870 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -672,6 +672,10 @@
 #define IXGBE_FCOEDWRC  0x0242C /* Number of FCoE DWords Received */
 #define IXGBE_FCOEPTC   0x08784 /* Number of FCoE Packets Transmitted */
 #define IXGBE_FCOEDWTC  0x08788 /* Number of FCoE DWords Transmitted */
+#define IXGBE_O2BGPTC   0x041C4
+#define IXGBE_O2BSPC    0x087B0
+#define IXGBE_B2OSPC    0x041C0
+#define IXGBE_B2OGPRC   0x02F90
 #define IXGBE_PCRC8ECL  0x0E810
 #define IXGBE_PCRC8ECH  0x0E811
 #define IXGBE_PCRC8ECH_MASK     0x1F
@@ -2554,6 +2558,10 @@ struct ixgbe_hw_stats {
 	u64 fcoeptc;
 	u64 fcoedwrc;
 	u64 fcoedwtc;
+	u64 b2ospc;
+	u64 b2ogprc;
+	u64 o2bgptc;
+	u64 o2bspc;
 };
 
 /* forward declaration */
-- 
1.7.4.4

