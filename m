From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: [PATCH] tg3: Fix failure to enable WoL by default when possible
Date: Thu, 28 Apr 2011 23:02:15 +0200
Message-ID: <201104282302.15502.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	Matt Carlson <mcarlson@broadcom.com>,
	Michael Chan <mchan@broadcom.com>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rafael J. Wysocki <rjw@sisk.pl>

tg3 is supposed to enable WoL by default on adapters which support
that, but it fails to do so unless the adapter's
/sys/devices/.../power/wakeup file contains 'enabled' during the
initialization of the adapter.  Fix that by making tg3 use
device_set_wakeup_enable() to enable wakeup automatically whenever
WoL should be enabled by default.

Signed-off-by: Rafael J. Wysocki <rjw@sisk.pl>
---
 drivers/net/tg3.c |    8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

Index: linux-2.6/drivers/net/tg3.c
===================================================================
--- linux-2.6.orig/drivers/net/tg3.c
+++ linux-2.6/drivers/net/tg3.c
@@ -12327,8 +12327,10 @@ static void __devinit tg3_get_eeprom_hw_
 		if (val & VCPU_CFGSHDW_ASPM_DBNC)
 			tp->tg3_flags |= TG3_FLAG_ASPM_WORKAROUND;
 		if ((val & VCPU_CFGSHDW_WOL_ENABLE) &&
-		    (val & VCPU_CFGSHDW_WOL_MAGPKT))
+		    (val & VCPU_CFGSHDW_WOL_MAGPKT)) {
 			tp->tg3_flags |= TG3_FLAG_WOL_ENABLE;
+			device_set_wakeup_enable(&tp->pdev->dev, true);
+		}
 		goto done;
 	}
 
@@ -12461,8 +12463,10 @@ static void __devinit tg3_get_eeprom_hw_
 			tp->tg3_flags &= ~TG3_FLAG_WOL_CAP;
 
 		if ((tp->tg3_flags & TG3_FLAG_WOL_CAP) &&
-		    (nic_cfg & NIC_SRAM_DATA_CFG_WOL_ENABLE))
+		    (nic_cfg & NIC_SRAM_DATA_CFG_WOL_ENABLE)) {
 			tp->tg3_flags |= TG3_FLAG_WOL_ENABLE;
+			device_set_wakeup_enable(&tp->pdev->dev, true);
+		}
 
 		if (cfg2 & (1 << 17))
 			tp->phy_flags |= TG3_PHYFLG_CAPACITIVE_COUPLING;
