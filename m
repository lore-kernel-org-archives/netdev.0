From: Shannon Nelson <shannon.nelson@intel.com>
Subject: [PATCH 2/3] ixgbe: add additional parameter options
Date: Thu, 10 Jan 2013 18:02:36 -0800
Message-ID: <20130111020234.15463.3763.stgit@starfish.jf.intel.com>
References: <20130111020046.15463.72333.stgit@starfish.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, dwmw2@infradead.org,
	jeffrey.t.kirsher@intel.com, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130111020046.15463.72333.stgit@starfish.jf.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With the new userland ASCII parameter file available, add a few
new parameters for finer control of some driver activity.

dca=off	Disable DCA (Direct Cache Access) activity

FdirPballoc=N
	Flow Director packet buffer allocation control
	1 = 8k hash filters or 2k perfect filters
	2 = 16k hash filters or 4k perfect filters
	3 = 32k hash filters or 8k perfect filters

AtrSampleRate=N
	Set the Software ATR Tx packet sample rate to every Nth packet,
	from 0 (disabled) to 255.

Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Cc: David Woodhouse <dwmw2@infradead.org>
---

 drivers/net/ethernet/intel/ixgbe/ixgbe.h      |    4 ++
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   63 +++++++++++++++++++++++++
 2 files changed, 66 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index 8e78676..adfcd58 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -111,6 +111,10 @@
 #define IXGBE_TX_FLAGS_VLAN_PRIO_SHIFT  29
 #define IXGBE_TX_FLAGS_VLAN_SHIFT	16
 
+#define IXGBE_MAX_ATR_SAMPLE_RATE	255
+#define IXGBE_MIN_ATR_SAMPLE_RATE	1
+#define IXGBE_ATR_SAMPLE_RATE_OFF	0
+
 #define IXGBE_MAX_VF_MC_ENTRIES         30
 #define IXGBE_MAX_VF_FUNCTIONS          64
 #define IXGBE_MAX_VFTA_ENTRIES          128
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 1670fc7..9a94ca2 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -164,6 +164,11 @@ enum {
 #ifdef CONFIG_PCI_IOV
 	Opt_max_vfs,
 #endif
+#ifdef CONFIG_IXGBE_DCA
+	Opt_no_dca,
+#endif
+	Opt_FdirPballoc,
+	Opt_AtrSampleRate,
 };
 
 static const match_table_t tokens = {
@@ -172,6 +177,11 @@ static const match_table_t tokens = {
 #ifdef CONFIG_PCI_IOV
 	{ Opt_max_vfs, "max_vfs=%u" },
 #endif
+#ifdef CONFIG_IXGBE_DCA
+	{ Opt_no_dca, "nodca" },
+#endif
+	{ Opt_FdirPballoc, "FdirPballoc=%u" },
+	{ Opt_AtrSampleRate, "AtrSampleRate=%u" },
 
 	/* terminator token */
 	{ 0, NULL },
@@ -181,6 +191,9 @@ MODULE_INFO(fw_option, "allow_unsupported_sfp : Allow unsupported and untested S
 MODULE_INFO(fw_option,
 	    "max_vfs=N : Maximum number of virtual functions per physical function (default=0) - 0 <= N < "
 	    xstr(IXGBE_MAX_VF_FUNCTIONS));
+MODULE_INFO(fw_option, "nodca : Disable Direct Cache Access");
+MODULE_INFO(fw_option, "FdirPballoc=N : Flow Director packet buffer allocation level - 1, 2, or 3");
+MODULE_INFO(fw_option, "AtrSampleRate=N : Software ATR Tx packet sample rate, 0-255");
 
 /**
  * ixgbe_parse_option_line - find ixgbe options
@@ -195,7 +208,7 @@ static void ixgbe_parse_option_line(struct ixgbe_adapter *adapter,
 	char *p;
 	char *next_option = config_line;
 	substring_t args[MAX_OPT_ARGS];
-	int value;
+	int value, x;
 
 	if (!config_line)
 		return;
@@ -239,6 +252,54 @@ static void ixgbe_parse_option_line(struct ixgbe_adapter *adapter,
 			break;
 
 #endif
+#ifdef CONFIG_IXGBE_DCA
+		case Opt_no_dca:
+			adapter->flags &= ~(IXGBE_FLAG_DCA_CAPABLE |
+					    IXGBE_FLAG_DCA_ENABLED);
+			break;
+
+#endif
+		case Opt_FdirPballoc:
+			if (match_int(args, &value))
+				goto parse_error;
+
+			x = adapter->fdir_pballoc;
+			if (adapter->hw.mac.type == ixgbe_mac_82598EB
+			    || value == IXGBE_FDIR_PBALLOC_NONE) {
+				adapter->fdir_pballoc = IXGBE_FDIR_PBALLOC_NONE;
+				x = 0;
+			} else if (value == IXGBE_FDIR_PBALLOC_256K) {
+				adapter->fdir_pballoc = IXGBE_FDIR_PBALLOC_256K;
+				x = 256;
+			} else if (value == IXGBE_FDIR_PBALLOC_128K) {
+				adapter->fdir_pballoc = IXGBE_FDIR_PBALLOC_128K;
+				x = 128;
+			} else if (value == IXGBE_FDIR_PBALLOC_64K) {
+				adapter->fdir_pballoc = IXGBE_FDIR_PBALLOC_64K;
+				x = 64;
+			} else {
+				e_dev_err("Bad FdirPballoc value %d\n", value);
+			}
+
+			e_dev_err(
+				"Flow Director will be allocated %dKB of packet buffer\n",
+				x);
+			break;
+
+		case Opt_AtrSampleRate:
+			if (match_int(args, &value))
+				goto parse_error;
+
+			if (adapter->hw.mac.type == ixgbe_mac_82598EB
+			    || value == IXGBE_ATR_SAMPLE_RATE_OFF)
+				adapter->atr_sample_rate = value;
+			else if (value >= IXGBE_MIN_ATR_SAMPLE_RATE
+				   && value <= IXGBE_MAX_ATR_SAMPLE_RATE)
+				adapter->atr_sample_rate = value;
+			else
+				e_dev_err("Bad AtrSampleRate %d\n", value);
+			break;
+
 		default:
 			goto parse_error;
 			break;
