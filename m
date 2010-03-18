From: "yucheng.wang" <yucheng.wang@windriver.com>
Subject: Help: the 82577 network driver can't work
Date: Thu, 18 Mar 2010 13:40:25 +0800
Message-ID: <4BA1BCC9.1080401@windriver.com>
Reply-To: yucheng.wang@windriver.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Bruce.Ashfield@windriver.com, Shuo.Kang@windriver.com,
	Bo.Liu@windriver.com, rongkai.zhan@windriver.com,
	Yang.Shi@windriver.com, Shuo.Liu@windriver.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:49198 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752387Ab0CRFk3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Mar 2010 01:40:29 -0400
Received: from ALA-MAIL03.corp.ad.wrs.com (ala-mail03 [147.11.57.144])
	by mail.windriver.com (8.14.3/8.14.3) with ESMTP id o2I5eSHo005197
	for <netdev@vger.kernel.org>; Wed, 17 Mar 2010 22:40:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

I need some help for intel 82577 network card driver, named
CONFIG_E1000E in the kernel config.

In the kernel 2.6.31 and 2.6.32, the patch works well, but in the kernel 
2.6.33 and 2.6.34-rc1 the dmesg shows some problem below,and the network 
card can't work.
**********************************************************************
e1000e: Intel(R) PRO/1000 Network Driver - 1.0.2-k2
e1000e: Copyright (c) 1999 - 2009 Intel Corporation.
e1000e 0000:00:19.0: PCI INT A -> GSI 20 (level, low) -> IRQ 20
0000:00:19.0: 0000:00:19.0: Write-protect NVM Disabled
0000:00:19.0: 0000:00:19.0: Failed to initialize MSI interrupts. Falling
back to legacy interrupts.
ata4: SATA link down (SStatus 0 SControl 300)
ata3: SATA link down (SStatus 0 SControl 300)
ata2.00: SATA link down (SStatus 0 SControl 300)
ata2.01: SATA link down (SStatus 0 SControl 300)
ata1.00: SATA link down (SStatus 0 SControl 0)
ata1.01: SATA link down (SStatus 0 SControl 300)
e1000e 0000:00:19.0: PCI INT A disabled
e1000e: probe of 0000:00:19.0 failed with error -3
********************************************************************
I read the source code using 2.6.34-rc-1 kernel.
When calling e1000e_git_phy_id(), the function returns a wrong value 
"-3". The kernel 2.6.31 and 2.6.32 ignores this error, and the kernel 
run well. The function e1000_acquire_swflag_ich8lan( ), called by 
e1000e_get_phy_id(), return "-3".
  ************************** The code *********************************
       extcnf_ctrl |= E1000_EXTCNF_CTRL_SWFLAG;
       ew32(EXTCNF_CTRL, extcnf_ctrl);

       while (timeout) {
           extcnf_ctrl = er32(EXTCNF_CTRL);
           if (extcnf_ctrl&  E1000_EXTCNF_CTRL_SWFLAG)
               break;

           mdelay(1);
           timeout--;
       }

       if (!timeout) {
           e_dbg("Failed to acquire the semaphore.\n");
           extcnf_ctrl&= ~E1000_EXTCNF_CTRL_SWFLAG;
           ew32(EXTCNF_CTRL, extcnf_ctrl);
           ret_val = -E1000_ERR_CONFIG;
           goto out;
       }
  ************************** The code *********************************
The kernel can't set the bit E1000_EXTCNF_CTRL_SWFLAG of the register 
EXTCNF_CTRL.

We found the information in the 82577 user manual:
In the Extended Configuration Control Register.
  Software Semaphore FLAG (SWFLAG). This bit is set by the device driver 
to gain access permission to shared CSR registers with the firmware and 
hardware. The bit is initialized on power up PCI reset and software 
reset. and the default value when Reset is "0b".

I don't know why the bit E1000_EXTCNF_CTRL_SWFLAG is not right, and not 
find any information about writing the bit. Due to the bit returns 0 
when reset the controller, we wrote the patch below.
*****************************The patch**********************************
diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index 8b6ecd1..b3e20f4 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -224,6 +224,7 @@ static void 
e1000_power_down_phy_copper_ich8lan(struct e1000_hw *hw);
  static void e1000_lan_init_done_ich8lan(struct e1000_hw *hw);
  static s32  e1000_k1_gig_workaround_hv(struct e1000_hw *hw, bool link);
  static s32 e1000_set_mdio_slow_mode_hv(struct e1000_hw *hw);
+static s32 e1000_reset_hw_ich8lan(struct e1000_hw *hw);

  static inline u16 __er16flash(struct e1000_hw *hw, unsigned long reg)
  {
@@ -276,8 +277,12 @@ static s32 e1000_init_phy_params_pchlan(struct 
e1000_hw *hw)

      phy->id = e1000_phy_unknown;
      ret_val = e1000e_get_phy_id(hw);
-    if (ret_val)
-        goto out;
+    if (ret_val) {
+        e1000_reset_hw_ich8lan(hw);
+        ret_val = e1000e_get_phy_id(hw);
+        if (ret_val)
+            goto out;
+    }
      if ((phy->id == 0) || (phy->id == PHY_REVISION_MASK)) {
          /*
           * In case the PHY needs to be in mdio slow mode (eg. 82577),
****************************************************************************
I'm not sure it's right, but using the patch, 82577 network can work 
well.I need more eyes about this, how can I make the patch better?
Any suggestion would be helped me make the patch better.

By the way, we find 3 patches make it not well.

 From 0be8401051c716be4533272e983b7eed3d83946d Mon Sep 17 00:00:00 2001
From: Bruce Allan <bruce.w.allan@intel.com>
Date: Wed, 2 Dec 2009 17:03:18 +0000
Subject:  e1000e: correct ICH/PCH PHY operations function pointers

 From fddaa1aff881c98f524221236af98ce70dcd04cf Mon Sep 17 00:00:00 2001

From: Bruce Allan <bruce.w.allan@intel.com>
Date: Wed, 13 Jan 2010 01:52:49 +0000
Subject: e1000e: MDIO slow mode should always be done for 82577

 From baf86c9d36826fab0160251bbc87dfab3af48a21 Mon Sep 17 00:00:00 2001

From: Bruce Allan <bruce.w.allan@intel.com>
Date: Wed, 13 Jan 2010 01:53:08 +0000
Subject: e1000e: workaround link issues on busy hub in half duplex on
82577/82578

thanks,
Yucheng.Wang
