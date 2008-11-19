From: ohashi-h@mb.dnes.nec.co.jp
Subject: e1000 driver: LED indicates trouble
Date: Wed, 19 Nov 2008 10:45:50 +0900
Message-ID: <20081119104550ohashi-h@mail.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from TYO201.gate.nec.co.jp ([202.32.8.193]:37143 "EHLO
	tyo201.gate.nec.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751035AbYKSBpz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Nov 2008 20:45:55 -0500
Received: from mailgate4.nec.co.jp ([10.7.69.184])
	by tyo201.gate.nec.co.jp (8.13.8/8.13.4) with ESMTP id mAJ1jrKv019366
	for <netdev@vger.kernel.org>; Wed, 19 Nov 2008 10:45:53 +0900 (JST)
Received: (from root@localhost) by mailgate4.nec.co.jp (8.11.7/3.7W-MAILGATE-NEC)
	id mAJ1jrb01223 for netdev@vger.kernel.org; Wed, 19 Nov 2008 10:45:53 +0900 (JST)
Received: from kaishu.jp.nec.com (kaishu.jp.nec.com [10.26.220.5])
	by mailsv4.nec.co.jp (8.13.8/8.13.4) with ESMTP id mAJ1jrrA028729
	for <netdev@vger.kernel.org>; Wed, 19 Nov 2008 10:45:53 +0900 (JST)
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

We are using 82571EB ethernet controler and serdes interface.

I think this problem is caused by the e1000 device driver
setting LU and SLU bits in the interface and forcing the link
to go up.
I deleted this logic. (the following modification.) 
Then, LED was turned off.

================================
--- e1000_hw.c.org
+++ e1000_hw.c
@@ -3069,6 +3069,7 @@
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


================================
--- drivers/net/e1000/e1000_hw.h.org
+++ drivers/net/e1000/e1000_hw.h
@@ -1459,6 +1459,7 @@ struct e1000_hw {
        boolean_t leave_av_bit_off;
        boolean_t kmrn_lock_loss_workaround_disabled;
        boolean_t rx_needs_kicking;
+       boolean_t disable_force_link_up_when_autoneg_failed;
 };

--- drivers/net/e1000/e1000_param.c.org
+++ drivers/net/e1000/e1000_param.c
@@ -218,6 +218,13 @@ E1000_PARAM(SmartPowerDownEnable, "Enabl
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
 	char *name;
@@ -596,6 +603,28 @@ e1000_check_options(struct e1000_adapter
 		}
 #endif
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
+			adapter- >hw.disable_force_link_up_when_autoneg_failed = !force_link_up;
+
+		} else {
+			adapter->hw.disable_force_link_up_when_autoneg_failed = !opt.def;
+		}
+	
+	}
 
 	switch (adapter->hw.media_type) {
 	case e1000_media_type_fiber:
--- drivers/net/e1000/e1000_hw.c.org
+++ drivers/net/e1000/e1000_hw.c
@@ -3057,7 +3057,16 @@ e1000_check_for_link(struct e1000_hw *hw
 			hw->autoneg_failed = 1;
 			return 0;
 		}
+
+		if (hw->disable_force_link_up_when_autoneg_failed) {
+        		DEBUGOUT("Force Link Up Disabled\n");
+               return -E1000_ERR_PHY;
+		}
+else {
 		DEBUGOUT("NOT RXing /C/, disable AutoNeg and force link.\n");
 
 		/* Disable auto-negotiation in the TXCW register */
 		E1000_WRITE_REG(hw, TXCW, (hw->txcw & ~E1000_TXCW_ANE));
@@ -3066,7 +3075,7 @@ e1000_check_for_link(struct e1000_hw *hw
 		ctrl = E1000_READ_REG(hw, CTRL);
 		ctrl |= (E1000_CTRL_SLU | E1000_CTRL_FD);
 		E1000_WRITE_REG(hw, CTRL, ctrl);
-
+}
 		/* Configure Flow Control after forcing link up. */
 		ret_val = e1000_config_fc_after_link_up(hw);
 		if (ret_val) {
================================



