From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 07/11] ixgb: Fixed flow control parameters
Date: Fri, 21 Apr 2006 18:00:46 -0700
Message-ID: <20060422010045.24255.14686.stgit@jk-desktop.jf.intel.com>
References: <20060422010016.24255.50772.stgit@jk-desktop.jf.intel.com>
Cc: John Rociak <john.ronciak@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmr19.intel.com ([134.134.136.18]:34989 "EHLO
	orsfmr004.jf.intel.com") by vger.kernel.org with ESMTP
	id S1750817AbWDVA5j (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Apr 2006 20:57:39 -0400
To: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
In-Reply-To: <20060422010016.24255.50772.stgit@jk-desktop.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


- make default flow control only have *sending* of flow control packets enabled
- fix to disable / enable flow control correctly

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: John Ronciak <john.ronciak@intel.com>
---

 drivers/net/ixgb/ixgb_param.c |   22 ++++++++++------------
 1 files changed, 10 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ixgb/ixgb_param.c b/drivers/net/ixgb/ixgb_param.c
index 8a83dfd..39e0a47 100644
--- a/drivers/net/ixgb/ixgb_param.c
+++ b/drivers/net/ixgb/ixgb_param.c
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
+		if( !(adapter->hw.fc.type & ixgb_fc_tx_pause) )
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
+		if( !(adapter->hw.fc.type & ixgb_fc_tx_pause) )
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
+		if( !(adapter->hw.fc.type & ixgb_fc_tx_pause) )
+			printk (KERN_INFO
 				"Ignoring FCReqTimeout when no RxFC\n");
 	}
 	/* high low and spacing check for rx flow control thresholds */
-	if (adapter->hw.fc.type & ixgb_fc_rx_pause) {
+	if (adapter->hw.fc.type & ixgb_fc_tx_pause) {
 		/* high must be greater than low */
 		if (adapter->hw.fc.high_water < (adapter->hw.fc.low_water + 8)) {
 			/* set defaults */

