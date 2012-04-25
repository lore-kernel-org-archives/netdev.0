From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 2/2] e1000e: Fix default interrupt throttle rate not set in NIC HW
Date: Tue, 24 Apr 2012 22:55:14 -0700
Message-ID: <1335333314-6814-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1335333314-6814-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com, Ying Cai <ycai@google.com>,
	David Decotigny <david.decotigny@google.com>,
	Jeff Kirsher <jeffrey.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:63052 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758909Ab2DYFzS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Apr 2012 01:55:18 -0400
In-Reply-To: <1335333314-6814-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Based on the original patch from  Ying Cai <ycai@google.com>
This change ensures that the itr/itr_setting adjustment logic is used,
even for the default/compiled-in value.

Context:
  When we changed the default InterruptThrottleRate value from default
  (3 = dynamic mode) to 8000 for example, only adapter->itr_setting
  (which controls interrupt coalescing mode) was set to 8000, but
  adapter->itr (which controls the value set in NIC register) was not
  updated accordingly. So from ethtool, it seemed the interrupt
  throttling is enabled at 8000 intr/s, but the NIC actually was
  running in dynamic mode which has lower CPU efficiency especially
  when throughput is not high.

CC: Ying Cai <ycai@google.com>
CC: David Decotigny <david.decotigny@google.com>
Signed-off-by: Jeff Kirsher <jeffrey.kirsher@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
---
 drivers/net/ethernet/intel/e1000e/param.c |   99 +++++++++++++++-------------
 1 files changed, 53 insertions(+), 46 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/param.c b/drivers/net/ethernet/intel/e1000e/param.c
index ff796e4..16adeb9 100644
--- a/drivers/net/ethernet/intel/e1000e/param.c
+++ b/drivers/net/ethernet/intel/e1000e/param.c
@@ -106,7 +106,7 @@ E1000_PARAM(RxAbsIntDelay, "Receive Absolute Interrupt Delay");
 /*
  * Interrupt Throttle Rate (interrupts/sec)
  *
- * Valid Range: 100-100000 (0=off, 1=dynamic, 3=dynamic conservative)
+ * Valid Range: 100-100000 or one of: 0=off, 1=dynamic, 3=dynamic conservative
  */
 E1000_PARAM(InterruptThrottleRate, "Interrupt Throttling Rate");
 #define DEFAULT_ITR 3
@@ -344,53 +344,60 @@ void __devinit e1000e_check_options(struct e1000_adapter *adapter)
 
 		if (num_InterruptThrottleRate > bd) {
 			adapter->itr = InterruptThrottleRate[bd];
-			switch (adapter->itr) {
-			case 0:
-				e_info("%s turned off\n", opt.name);
-				break;
-			case 1:
-				e_info("%s set to dynamic mode\n", opt.name);
-				adapter->itr_setting = adapter->itr;
-				adapter->itr = 20000;
-				break;
-			case 3:
-				e_info("%s set to dynamic conservative mode\n",
-					opt.name);
-				adapter->itr_setting = adapter->itr;
-				adapter->itr = 20000;
-				break;
-			case 4:
-				e_info("%s set to simplified (2000-8000 ints) "
-				       "mode\n", opt.name);
-				adapter->itr_setting = 4;
-				break;
-			default:
-				/*
-				 * Save the setting, because the dynamic bits
-				 * change itr.
-				 */
-				if (e1000_validate_option(&adapter->itr, &opt,
-							  adapter) &&
-				    (adapter->itr == 3)) {
-					/*
-					 * In case of invalid user value,
-					 * default to conservative mode.
-					 */
-					adapter->itr_setting = adapter->itr;
-					adapter->itr = 20000;
-				} else {
-					/*
-					 * Clear the lower two bits because
-					 * they are used as control.
-					 */
-					adapter->itr_setting =
-						adapter->itr & ~3;
-				}
-				break;
-			}
+
+			/*
+			 * Make sure a message is printed for non-special
+			 * values.  And in case of an invalid option, display
+			 * warning, use default and got through itr/itr_setting
+			 * adjustment logic below
+			 */
+			if ((adapter->itr > 4) &&
+			    e1000_validate_option(&adapter->itr, &opt, adapter))
+				adapter->itr = opt.def;
 		} else {
-			adapter->itr_setting = opt.def;
+			/*
+			 * If no option specified, use default value and go
+			 * through the logic below to adjust itr/itr_setting
+			 */
+			adapter->itr = opt.def;
+
+			/*
+			 * Make sure a message is printed for non-special
+			 * default values
+			 */
+			if (adapter->itr > 40)
+				e_info("%s set to default %d\n", opt.name,
+				       adapter->itr);
+		}
+
+		adapter->itr_setting = adapter->itr;
+		switch (adapter->itr) {
+		case 0:
+			e_info("%s turned off\n", opt.name);
+			break;
+		case 1:
+			e_info("%s set to dynamic mode\n", opt.name);
+			adapter->itr = 20000;
+			break;
+		case 3:
+			e_info("%s set to dynamic conservative mode\n",
+			       opt.name);
 			adapter->itr = 20000;
+			break;
+		case 4:
+			e_info("%s set to simplified (2000-8000 ints) mode\n",
+			       opt.name);
+			break;
+		default:
+			/*
+			 * Save the setting, because the dynamic bits
+			 * change itr.
+			 *
+			 * Clear the lower two bits because
+			 * they are used as control.
+			 */
+			adapter->itr_setting &= ~3;
+			break;
 		}
 	}
 	{ /* Interrupt Mode */
-- 
1.7.7.6
