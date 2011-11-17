From: David Decotigny <david.decotigny@google.com>
Subject: [PATCH FIX net v1] net-e1000e: Fix default interrupt throttle rate not set in NIC HW
Date: Wed, 16 Nov 2011 17:18:57 -0800
Message-ID: <7182ad277085740c360a17865326058779b101de.1321492611.git.david.decotigny__34087.1552857154$1321492807$gmane$org@google.com>
References: <cover.1321492611.git.david.decotigny@google.com>
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>,
	David Decotigny <david.decotigny@google.com>,
	Ying Cai <ycai@google.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Ski
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f74.google.com ([74.125.82.74]:57496 "EHLO
	mail-ww0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754734Ab1KQBTt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2011 20:19:49 -0500
Received: by wwe5 with SMTP id 5so27225wwe.1
        for <netdev@vger.kernel.org>; Wed, 16 Nov 2011 17:19:47 -0800 (PST)
In-Reply-To: <cover.1321492611.git.david.decotigny@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ying Cai <ycai@google.com>

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



Signed-off-by: David Decotigny <david.decotigny@google.com>
---
 drivers/net/ethernet/intel/e1000e/param.c |   98 +++++++++++++++-------------
 1 files changed, 52 insertions(+), 46 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/param.c b/drivers/net/ethernet/intel/e1000e/param.c
index 20e93b0..41937e5 100644
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
@@ -335,53 +335,59 @@ void __devinit e1000e_check_options(struct e1000_adapter *adapter)
 
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
+			/* Make sure a message is printed for
+			 * non-special values. And in case of an
+			 * invalid option, display warning, use
+			 * default and go through itr/itr_setting
+			 * adjustment logic below */
+			if ((adapter->itr < 0 || adapter->itr > 4)
+			    && e1000_validate_option(&adapter->itr, &opt,
+						     adapter))
+				adapter->itr = opt.def;
 		} else {
-			adapter->itr_setting = opt.def;
+			/* if no option specified, use default value
+			   and go through the logic below to adjust
+			   itr/itr_setting */
+			adapter->itr = opt.def;
+
+			/* Make sure a message is printed for
+			 * non-special default values */
+			if (adapter->itr < 0 || adapter->itr > 4)
+				e_info("%s set to default %d\n",
+				       opt.name, adapter->itr);
+		}
+
+
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
+			e_info("%s set to simplified (2000-8000 ints) "
+			       "mode\n", opt.name);
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
1.7.3.1
