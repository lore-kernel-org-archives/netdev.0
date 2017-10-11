From: Daniel Drake <drake@endlessm.com>
Subject: [PATCH] r8169: only enable PCI wakeups when WOL is active
Date: Wed, 11 Oct 2017 12:56:52 +0800
Message-ID: <20171011045652.6301-1-drake@endlessm.com>
Cc: netdev@vger.kernel.org, romieu@fr.zoreil.com, linux@enlessm.com
To: nic_swsd@realtek.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:43861 "EHLO
        mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750729AbdJKE5N (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 00:57:13 -0400
Received: by mail-pf0-f179.google.com with SMTP id a8so80405pfc.0
        for <netdev@vger.kernel.org>; Tue, 10 Oct 2017 21:57:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rtl_init_one() currently enables PCI wakeups if the ethernet device
is found to be WOL-capable. There is no need to do this when
rtl8169_set_wol() will correctly enable or disable the same wakeup flag
when WOL is activated/deactivated.

This works around an ACPI DSDT bug which prevents the Acer laptop models
Aspire ES1-533, Aspire ES1-732, PackardBell ENTE69AP and Gateway NE533
from entering S3 suspend - even when no ethernet cable is connected.

On these platforms, the DSDT says that GPE08 is a wakeup source for
ethernet, but this GPE fires as soon as the system goes into suspend,
waking the system up immediately. Having the wakeup normally disabled
avoids this issue in the default case.

With this change, WOL will continue to be unusable on these platforms
(it will instantly wake up if WOL is later enabled by the user) but we
do not expect this to be a commonly used feature on these consumer
laptops. We have separately determined that WOL works fine without any
ACPI GPEs enabled during sleep, so a DSDT fix or override would be
possible to make WOL work.

Signed-off-by: Daniel Drake <drake@endlessm.com>
---
 drivers/net/ethernet/realtek/r8169.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index e03fcf914690..a3c949ea7d1a 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -8491,8 +8491,6 @@ static int rtl_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		rtl8168_driver_start(tp);
 	}
 
-	device_set_wakeup_enable(&pdev->dev, tp->features & RTL_FEATURE_WOL);
-
 	if (pci_dev_run_wake(pdev))
 		pm_runtime_put_noidle(&pdev->dev);
 
-- 
2.11.0
