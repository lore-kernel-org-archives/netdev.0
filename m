From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 3/9] ixgb: fix flow control
Date: Tue, 23 May 2006 11:04:09 -0700
Message-ID: <20060523180409.17428.29892.stgit@gitlost.site>
References: <20060523180302.17428.89125.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke <auke-jan.h.kok"@intel.com,
	"Kok, Auke" <auke@foo-projects.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:41733 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S932128AbWEWR7L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 May 2006 13:59:11 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060523180302.17428.89125.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Make default flow control only have *sending* of flow control packets
enabled, and fix to disable / enable flow control correctly. Set flow
control defaults to disable receiving flow control from the link
partner, to fix the transmit fifo overlow errata

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
Signed-off-by: John Ronciak <john.ronciak@intel.com>
---

 drivers/net/ixgb/ixgb_param.c |   24 +++++++++++-------------
 1 files changed, 11 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ixgb/ixgb_param.c b/drivers/net/ixgb/ixgb_param.c
index 8a83dfd..388462c 100644
--- a/drivers/net/ixgb/ixgb_param.c
+++ b/drivers/net/ixgb/ixgb_param.c
@@ -76,7 +76,7 @@ IXGB_PARAM(RxDescriptors, "Number of rec
  *  - 2 - Tx only, generate PAUSE frames but ignore them on receive
  *  - 3 - Full Flow Control Support
  *
- * Default Value: Read flow control settings from the EEPROM
+ * Default Value: 2 - Tx only (silicon bug avoidance)
  */
 
 IXGB_PARAM(FlowControl, "Flow Control setting");
@@ -137,7 +137,7 @@ IXGB_PARAM(RxFCLowThresh, "Receive Flow 
  *
  * Valid Range: 1 - 65535 
  *
- * Default Value:  256 (0x100)
+ * Default Value:  65535 (0xffff) (we'll send an xon if we recover)
  */
 
 IXGB_PARAM(FCReqTimeout, "Flow Control Request Timeout");
@@ -165,8 +165,6 @@ IXGB_PARAM(IntDelayEnable, "Transmit Int
 
 #define XSUMRX_DEFAULT		 OPTION_ENABLED
 
-#define FLOW_CONTROL_FULL	   ixgb_fc_full
-#define FLOW_CONTROL_DEFAULT  FLOW_CONTROL_FULL
 #define DEFAULT_FCRTL	  		0x28000
 #define DEFAULT_FCRTH			0x30000
 #define MIN_FCRTL			      0
@@ -174,9 +172,9 @@ IXGB_PARAM(IntDelayEnable, "Transmit Int
 #define MIN_FCRTH			      8
 #define MAX_FCRTH			0x3FFF0
 
-#define DEFAULT_FCPAUSE		  	0x100	/* this may be too long */
 #define MIN_FCPAUSE			      1
 #define MAX_FCPAUSE			 0xffff
+#define DEFAULT_FCPAUSE		  	 0xFFFF /* this may be too long */
 
 struct ixgb_option {
 	enum { enable_option, range_option, list_option } type;
@@ -336,7 +334,7 @@ ixgb_check_options(struct ixgb_adapter *
 			.type = list_option,
 			.name = "Flow Control",
 			.err  = "reading default settings from EEPROM",
-			.def  = ixgb_fc_full,
+			.def  = ixgb_fc_tx_pause,
 			.arg  = { .l = { .nr = LIST_LEN(fc_list),
 					 .p = fc_list }}
 		};
@@ -365,8 +363,8 @@ ixgb_check_options(struct ixgb_adapter *
 		} else {
 			adapter->hw.fc.high_water = opt.def;
 		}
-		if(!(adapter->hw.fc.type & ixgb_fc_rx_pause) )
-			printk (KERN_INFO 
+		if (!(adapter->hw.fc.type & ixgb_fc_tx_pause) )
+			printk (KERN_INFO
 				"Ignoring RxFCHighThresh when no RxFC\n");
 	}
 	{ /* Receive Flow Control Low Threshold */
@@ -385,8 +383,8 @@ ixgb_check_options(struct ixgb_adapter *
 		} else {
 			adapter->hw.fc.low_water = opt.def;
 		}
-		if(!(adapter->hw.fc.type & ixgb_fc_rx_pause) )
-			printk (KERN_INFO 
+		if (!(adapter->hw.fc.type & ixgb_fc_tx_pause) )
+			printk (KERN_INFO
 				"Ignoring RxFCLowThresh when no RxFC\n");
 	}
 	{ /* Flow Control Pause Time Request*/
@@ -406,12 +404,12 @@ ixgb_check_options(struct ixgb_adapter *
 		} else {
 			adapter->hw.fc.pause_time = opt.def;
 		}
-		if(!(adapter->hw.fc.type & ixgb_fc_rx_pause) )
-			printk (KERN_INFO 
+		if (!(adapter->hw.fc.type & ixgb_fc_tx_pause) )
+			printk (KERN_INFO
 				"Ignoring FCReqTimeout when no RxFC\n");
 	}
 	/* high low and spacing check for rx flow control thresholds */
-	if (adapter->hw.fc.type & ixgb_fc_rx_pause) {
+	if (adapter->hw.fc.type & ixgb_fc_tx_pause) {
 		/* high must be greater than low */
 		if (adapter->hw.fc.high_water < (adapter->hw.fc.low_water + 8)) {
 			/* set defaults */



--
Auke Kok <auke-jan.h.kok@intel.com>
