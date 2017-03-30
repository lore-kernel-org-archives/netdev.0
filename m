From: Johan Hovold <johan-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH v2 5/8] NFC: nfcmrvl: fix firmware-management initialisation
Date: Thu, 30 Mar 2017 12:15:39 +0200
Message-ID: <20170330101542.15384-6-johan@kernel.org>
References: <20170330101542.15384-1-johan@kernel.org>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Johan Hovold <johan-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        stable <stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Vincent Cuissard <cuissard-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>
To: Lauro Ramos Venancio <lauro.venancio-430g2QfJUUCGglJvpFV4uA@public.gmane.org>,
        Aloisio Almeida Jr <aloisio.almeida-430g2QfJUUCGglJvpFV4uA@public.gmane.org>,
        Samuel Ortiz <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170330101542.15384-1-johan-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
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
Cc: stable <stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>     # 4.4
Cc: Vincent Cuissard <cuissard-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>
Signed-off-by: Johan Hovold <johan-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 drivers/nfc/nfcmrvl/main.c | 16 +++++++++-------
 1 file changed, 9 insertions(+), 7 deletions(-)

diff --git a/drivers/nfc/nfcmrvl/main.c b/drivers/nfc/nfcmrvl/main.c
index 3e3fc9588f10..a446590a71ca 100644
--- a/drivers/nfc/nfcmrvl/main.c
+++ b/drivers/nfc/nfcmrvl/main.c
@@ -158,26 +158,28 @@ struct nfcmrvl_private *nfcmrvl_nci_register_dev(enum nfcmrvl_phy phy,
 		goto error_free_gpio;
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
