From: "Michael Chan" <mchan@broadcom.com>
Subject: [TG3]: Workaround MSI bug on 5714/5780.
Date: Wed, 05 Sep 2007 13:07:08 -0700
Message-ID: <1189022828.4960.2.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4814 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755359AbXIETJ7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Sep 2007 15:09:59 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[TG3]: Workaround MSI bug on 5714/5780.

A hardware bug was revealed after a recent PCI MSI patch was made to
always disable legacy INTX when enabling MSI.  The 5714/5780 chips
will not generate MSI when INTX is disabled, causing MSI failure
messages to be reported, and another patch was made to workaround the
problem by disabling MSI on ServerWorks HT1000 bridge chips commonly
found with the 5714.

We workaround this chip bug by enabling INTX after we enable MSI and
after we resume from suspend.

Update version to 3.81.

This problem was discovered by David Miller.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 5874042..9034a05 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -64,8 +64,8 @@
 
 #define DRV_MODULE_NAME		"tg3"
 #define PFX DRV_MODULE_NAME	": "
-#define DRV_MODULE_VERSION	"3.80"
-#define DRV_MODULE_RELDATE	"August 2, 2007"
+#define DRV_MODULE_VERSION	"3.81"
+#define DRV_MODULE_RELDATE	"September 5, 2007"
 
 #define TG3_DEF_MAC_MODE	0
 #define TG3_DEF_RX_MODE		0
@@ -7127,6 +7127,10 @@ static int tg3_open(struct net_device *dev)
 		} else if (pci_enable_msi(tp->pdev) == 0) {
 			u32 msi_mode;
 
+			/* Hardware bug - MSI won't work if INTX disabled. */
+			if (tp->tg3_flags2 & TG3_FLG2_5780_CLASS)
+				pci_intx(tp->pdev, 1);
+
 			msi_mode = tr32(MSGINT_MODE);
 			tw32(MSGINT_MODE, msi_mode | MSGINT_MODE_ENABLE);
 			tp->tg3_flags2 |= TG3_FLG2_USING_MSI;
@@ -12172,6 +12176,11 @@ static int tg3_resume(struct pci_dev *pdev)
 	if (err)
 		return err;
 
+	/* Hardware bug - MSI won't work if INTX disabled. */
+	if ((tp->tg3_flags2 & TG3_FLG2_5780_CLASS) &&
+	    (tp->tg3_flags2 & TG3_FLG2_USING_MSI))
+		pci_intx(tp->pdev, 1);
+
 	netif_device_attach(dev);
 
 	tg3_full_lock(tp, 0);


