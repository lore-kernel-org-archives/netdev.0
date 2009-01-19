From: ohashi-h@mb.dnes.nec.co.jp
Subject: [PATCH] e1000e: introduce new parameter to disable force-link-up on serdes
Date: Mon, 19 Jan 2009 19:42:10 +0900
Message-ID: <20090119194210ohashi-h@mail.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: jesse.brandeburg@intel.com, bruce.w.allan@intel.com,
	peter.p.waskiewicz.jr@intel.com, john.ronciak@intel.com,
	jgarzik@pobox.com, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net, h-shimamoto@ct.jp.nec.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from TYO201.gate.nec.co.jp ([202.32.8.193]:37448 "EHLO
	tyo201.gate.nec.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757563AbZASKok (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2009 05:44:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hiroki Ohashi  <ohashi-h@mb.dnes.nec.co.jp>

Hi,

ohashi-h@mb.dnes.nec.co.jp wrote (2008/12/12 16:41:55 +0900 )：
>
>ohashi-h@mb.dnes.nec.co.jp wrote (2008/12/04 18:24:21 +0900 )：
>>
>>Jeff Kirsher wrote (2008/12/03 17:12:00 +0900 )：
>>
>>>On Tue, Dec 2, 2008 at 11:36 PM,  <ohashi-h@mb.dnes.nec.co.jp> wrote:
>>>> From: Hiroki Ohashi  <ohashi-h@mb.dnes.nec.co.jp>
>>>>
>>>> Hi all,
>>>>
>>>> I faced the following situations.
>>>> The LED of NIC was indicated, even when the system was not linked
>>>> the network (auto-negotiation failed or link partner cannot
>>>> auto-negotiate).
>>>> LED should be indicate only when the network was linked.
>>>> And so, it is a problem that LED indicates.
>>>>
>>>> I think the indicating the LED is a problem for maintenance.
>>>> I cannot know the condition of the link, because I confirm
>>>> to link up by LED's indication.
>>>>
>>>> We are using 82571EB ethernet controler and serdes interface.
>>>>
>...
>
>>>
>>>I am a little confused.  You state you are using an NIC (82571EB)
>>>which is currently not supported by e1000, but is supported in the
>>>e1000e driver.  Then you suggest a change to the e1000 driver to
>>>resolve an issue you see with your 82571EB NIC.
>>>
>>>So I would suggest you use the e1000e driver first.
>>
>>Thank you, I will try again using e1000e driver.
>>
>>>Also the Link LED is supposed to indicated that there is a "physical"
>>>link, in which case you can have a physical connection and still fail
>>>auto-neg.  So I do not necessarily agree with your interpretation of
>>>what a link LED is supposed to indicate.
>>
>>My explanation was insufficiently.
>>My system was NOT connected LAN cable to NIC, but the Link LED
>>was indicated.
>>So the problem is the LED is indicated without connecting the cable.
>>
>
>I tried again using kernel 2.6.27.8 (e1000e driver).
>The LED of NIC was indicated, even when the system was not 
>connected LAN cable.
>When I deleted logic of force-link-up (the following modification.),
>the LED was turned off.
>
>I think it is a problem that LED indicates.
>If you have any good way to modify, please let me know.
>(Patches are considering.)

I send the patch to modify.

-------------------------
From: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
Subject: [PATCH] e1000e: introduce new parameter to disable force-link-up on serdes

Introduce new parameter EnableForceLinkOnSERDES to disable force-link-up
on SERDES fablic.
The problem that LED indicates in the following cases is avoided. 
  - LAN cable was not connected.
  - AutoNeg failed (LAN cable is connected).
  - Link partner could not auto-neg (LAN cable is connected).

Signed-off-by: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
Signed-off-by: Hiroki Ohashi <ohashi-h@mb.dnes.nec.co.jp>
Tested-by: Hiroki Ohashi <ohashi-h@mb.dnes.nec.co.jp>

---
 drivers/net/e1000e/hw.h    |    1 +
 drivers/net/e1000e/lib.c   |    4 ++++
 drivers/net/e1000e/param.c |   24 ++++++++++++++++++++++++
 3 files changed, 29 insertions(+), 0 deletions(-)

diff --git a/drivers/net/e1000e/hw.h b/drivers/net/e1000e/hw.h
index f25e961..c051223 100644
--- a/drivers/net/e1000e/hw.h
+++ b/drivers/net/e1000e/hw.h
@@ -857,6 +857,7 @@ struct e1000_fc_info {
 struct e1000_dev_spec_82571 {
 	bool laa_is_present;
 	bool alt_mac_addr_is_present;
+	bool enable_force_link_up;
 };
 
 struct e1000_shadow_ram {
diff --git a/drivers/net/e1000e/lib.c b/drivers/net/e1000e/lib.c
index 6674110..6bdac30 100644
--- a/drivers/net/e1000e/lib.c
+++ b/drivers/net/e1000e/lib.c
@@ -539,6 +539,10 @@ s32 e1000e_check_for_serdes_link(struct e1000_hw *hw)
 			mac->autoneg_failed = 1;
 			return 0;
 		}
+		if (!hw->dev_spec.e82571.enable_force_link_up) {
+			hw_dbg(hw, "Force link up disabled.\n");
+			return -E1000_ERR_PHY;
+		}
 		hw_dbg(hw, "NOT RXing /C/, disable AutoNeg and force link.\n");
 
 		/* Disable auto-negotiation in the TXCW register */
diff --git a/drivers/net/e1000e/param.c b/drivers/net/e1000e/param.c
index e909f96..225f006 100644
--- a/drivers/net/e1000e/param.c
+++ b/drivers/net/e1000e/param.c
@@ -161,6 +161,15 @@ E1000_PARAM(WriteProtectNVM, "Write-protect NVM [WARNING: disabling this can lea
 E1000_PARAM(CrcStripping, "Enable CRC Stripping, disable if your BMC needs " \
                           "the CRC");
 
+/*
+ * Enable Force Link Up on SERDES
+ *
+ * Valid Range: 0, 1
+ *
+ * Default Value: 1 (enabled)
+ */
+E1000_PARAM(EnableForceLinkUpOnSERDES, "Enable force link up SERDES");
+
 struct e1000_option {
 	enum { enable_option, range_option, list_option } type;
 	const char *name;
@@ -470,4 +479,19 @@ void __devinit e1000e_check_options(struct e1000_adapter *adapter)
 			}
 		}
 	}
+	{ /* Enable Force Link Up on SERDES */
+		const struct e1000_option opt = {
+			.type = enable_option,
+			.name = "Enable Force Link Up on SERDES",
+			.err  = "defaulting to Enabled",
+			.def  = OPTION_ENABLED
+		};
+
+		if (num_EnableForceLinkUpOnSERDES > bd) {
+			unsigned int force_link_up = EnableForceLinkUpOnSERDES[bd];
+			e1000_validate_option(&force_link_up, &opt, adapter);
+			hw->dev_spec.e82571.enable_force_link_up = force_link_up;
+		} else
+			hw->dev_spec.e82571.enable_force_link_up = opt.def;
+	}
 }
-- 


>================================================
>--- drivers/net/e1000e/lib.c.org
>+++ drivers/net/e1000e/lib.c
>@@ -539,8 +539,6 @@ s32 e1000e_check_for_serdes_link(struct 
>                        mac->autoneg_failed = 1;
>                        return 0;
>                }
>+#if 0
>                hw_dbg(hw, "NOT RXing /C/, disable AutoNeg and force link.\n");
> 
>                /* Disable auto-negotiation in the TXCW register */
>@@ -550,7 +548,7 @@ s32 e1000e_check_for_serdes_link(struct 
>                ctrl = er32(CTRL);
>                ctrl |= (E1000_CTRL_SLU | E1000_CTRL_FD);
>                ew32(CTRL, ctrl);
>+#endif
>-
>                /* Configure Flow Control after forcing link up. */
>                ret_val = e1000e_config_fc_after_link_up(hw);
>                if (ret_val) {
>================================================
>

Hiroki Ohashi
