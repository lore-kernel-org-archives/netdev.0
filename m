From: Johan Hovold <johan@kernel.org>
Subject: [PATCH 5/7] NFC: nfcmrvl: fix firmware-management initialisation
Date: Wed, 29 Mar 2017 18:21:10 +0200
Message-ID: <20170329162112.18121-6-johan@kernel.org>
References: <20170329162112.18121-1-johan@kernel.org>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Johan Hovold <johan@kernel.org>,
        stable <stable@vger.kernel.org>,
        Vincent Cuissard <cuissard@marvell.com>
To: Lauro Ramos Venancio <lauro.venancio@openbossa.org>,
        Aloisio Almeida Jr <aloisio.almeida@openbossa.org>,
        Samuel Ortiz <sameo@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170329162112.18121-1-johan@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The nci-device was never deregistered in the event that
fw-initialisation failed.

Fix this by moving the firmware initialisation before device
registration since the firmware work queue should be available before
registering.

Note that this depends on a recent fix that moved device-name
initialisation back to to nci_allocate_device() as the
firmware-workqueue name is now derived from the nfc-device name.

Fixes: 3194c6870158 ("NFC: nfcmrvl: add firmware download support")
Cc: stable <stable@vger.kernel.org>     # 4.4
Cc: Vincent Cuissard <cuissard@marvell.com>
Signed-off-by: Johan Hovold <johan@kernel.org>
---
 drivers/nfc/nfcmrvl/main.c | 16 +++++++++-------
 1 file changed, 9 insertions(+), 7 deletions(-)

diff --git a/drivers/nfc/nfcmrvl/main.c b/drivers/nfc/nfcmrvl/main.c
index 8d4294fc3005..f20220bab6b6 100644
--- a/drivers/nfc/nfcmrvl/main.c
+++ b/drivers/nfc/nfcmrvl/main.c
@@ -156,26 +156,28 @@ struct nfcmrvl_private *nfcmrvl_nci_register_dev(enum nfcmrvl_phy phy,
 		goto error;
 	}
 
+	rc = nfcmrvl_fw_dnld_init(priv);
+	if (rc) {
+		nfc_err(dev, "failed to initialize FW download %d\n", rc);
+		goto error_free_dev;
+	}
+
 	nci_set_drvdata(priv->ndev, priv);
 
 	rc = nci_register_device(priv->ndev);
 	if (rc) {
 		nfc_err(dev, "nci_register_device failed %d\n", rc);
-		goto error_free_dev;
+		goto error_fw_dnld_deinit;
 	}
 
 	/* Ensure that controller is powered off */
 	nfcmrvl_chip_halt(priv);
 
-	rc = nfcmrvl_fw_dnld_init(priv);
-	if (rc) {
-		nfc_err(dev, "failed to initialize FW download %d\n", rc);
-		goto error_free_dev;
-	}
-
 	nfc_info(dev, "registered with nci successfully\n");
 	return priv;
 
+error_fw_dnld_deinit:
+	nfcmrvl_fw_dnld_deinit(priv);
 error_free_dev:
 	nci_free_device(priv->ndev);
 error:
-- 
2.12.2
