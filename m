From: ohashi-h@mb.dnes.nec.co.jp
Subject: e1000: LED indicates trouble, and [PATCH] enable/disable of force-link-up
Date: Wed, 3 Dec 2008 16:36:36 +0900
Message-ID: <20081203163636ohashi-h@mail.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, peter.p.waskiewicz.jr@intel.com,
	john.ronciak@intel.com, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from TYO202.gate.nec.co.jp ([202.32.8.206]:39216 "EHLO
	tyo202.gate.nec.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753410AbYLCHgs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2008 02:36:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hiroki Ohashi  <ohashi-h@mb.dnes.nec.co.jp>

Hi all,

I faced the following situations.
The LED of NIC was indicated, even when the system was not linked
the network (auto-negotiation failed or link partner cannot 
auto-negotiate). 
LED should be indicate only when the network was linked.
And so, it is a problem that LED indicates.

I think the indicating the LED is a problem for maintenance.
I cannot know the condition of the link, because I confirm 
to link up by LED's indication.

We are using 82571EB ethernet controler and serdes interface.

I think this problem is caused by the e1000 device driver
setting LU and SLU bits in the interface and forcing the link
to go up.
I deleted this logic. (the following modification.) 
Then, LED was turned off.

================================
--- e1000_hw.c.org
+++ e1000_hw.c
@@ -3069,6 +3069,7 @@I
             hw->autoneg_failed = 1;
             return 0;
         }
+#if 0
         DEBUGOUT("NOT RXing /C/, disable AutoNeg and force link.\n");
 
         /* Disable auto-negotiation in the TXCW register */
@@ -3078,6 +3079,7 @@
         ctrl = E1000_READ_REG(hw, CTRL);
         ctrl |= (E1000_CTRL_SLU | E1000_CTRL_FD);
         E1000_WRITE_REG(hw, CTRL, ctrl);
+#endif
 
         /* Configure Flow Control after forcing link up. */
         ret_val = e1000_config_fc_after_link_up(hw);
================================


I think the e1000 driver should enable/disable force-link-up
depending on the condition of the link.
But I don't know a good way to do this.
If you have any good ideas, please let me know.

As a temporary idea, I thought of a way of adding a module parameter
to control enable/disable force-link-up.
The patch is as follows.

This patch adds "disable_force_link_up_when_autoneg_failed"
as module parameter. When this is 0, force-link-up is disable.

From: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
Signed-off-by: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>

================================
--- drivers/net/e1000/e1000_hw.h.org
+++ drivers/net/e1000/e1000_hw.h
@@ -1469,6 +1469,7 @@ struct e1000_hw {
 	bool			has_manc2h;
 	bool			rx_needs_kicking;
 	bool			has_smbus;
+	bool			disable_force_link_up_when_autoneg_failed;
 };
--- drivers/net/e1000/e1000_param.c.org
+++ drivers/net/e1000/e1000_param.c
@@ -196,6 +196,13 @@ E1000_PARAM(SmartPowerDownEnable, "Enabl
  */
 E1000_PARAM(KumeranLockLoss, "Enable Kumeran lock loss workaround");
 
+/* Enable Force Link Up When AutoNeg Failed
+ *
+ * Valid Range: 0, 1
+ *
+ * Default Value: 1 (force link up enabled)  */
+E1000_PARAM(EnableForceLinkOnSERDES, "Enable force link up when AutoNeg failed");
+
 struct e1000_option {
 	enum { enable_option, range_option, list_option } type;
 	const char *name;
@@ -534,6 +541,23 @@ void __devinit e1000_check_options(struc
 			adapter->hw.kmrn_lock_loss_workaround_disabled = !opt.def;
 		}
 	}
+	{ /* Enable Force Link Up When AutoNeg Failed */
+		struct e1000_option opt = {
+			.type = enable_option,
+			.name = "Enable Force Link Up When AutoNeg Failed",
+			.err  = "defaulting to Enabled",
+			.def  = OPTION_ENABLED
+		};
+
+		if (num_EnableForceLinkOnSERDES > bd) {
+			unsigned int force_link_up = EnableForceLinkOnSERDES [bd];
+			e1000_validate_option(&force_link_up, &opt, adapter);
+			adapter->hw.disable_force_link_up_when_autoneg_failed = !force_link_up;
+
+		} else {
+			adapter->hw.disable_force_link_up_when_autoneg_failed = !opt.def;
+		}
+	}
 
 	switch (adapter->hw.media_type) {
 	case e1000_media_type_fiber:
--- drivers/net/e1000/e1000_hw.c.org
+++ drivers/net/e1000/e1000_hw.c
@@ -3062,6 +3062,12 @@ s32 e1000_check_for_link(struct e1000_hw
             hw->autoneg_failed = 1;
             return 0;
         }
+
+        if (hw->disable_force_link_up_when_autoneg_failed) {
+            DEBUGOUT("Force Link Up Disabled\n");
+            return -E1000_ERR_PHY;
+        }
+
         DEBUGOUT("NOT RXing /C/, disable AutoNeg and force link.\n");
 
         /* Disable auto-negotiation in the TXCW register */
================================
