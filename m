From: Johan Hovold <johan@kernel.org>
Subject: [PATCH 3/7] NFC: nfcmrvl: do not use device-managed resources
Date: Wed, 29 Mar 2017 18:21:08 +0200
Message-ID: <20170329162112.18121-4-johan@kernel.org>
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

This specifically fixes a NULL-pointer dereference when using the n_nci
line discipline on one end of a Unix98 pty as well as resource leaks in
the registration error paths.

Device-managed resources is a bad fit for this driver as devices can be
registered from the n_nci line discipline. Firstly, a tty may not even
have a corresponding device (should it be part of a Unix98 pty)
something which would lead to a NULL-pointer dereference when
registering resources.

Secondly, if the tty has a class device, its lifetime exceeds that of
the line discipline, which means that resources would leak every time
the line discipline is closed (or if registration fails).

Currently, the devres interface was only being used to request a reset
gpio despite the fact that it was already explicitly freed in
nfcmrvl_nci_unregister_dev() (along with the private data), something
which also prevented the resource leak at close.

Fixes: b2fe288eac72 ("NFC: nfcmrvl: free reset gpio")
Fixes: 4a2b947f56b3 ("NFC: nfcmrvl: add chip reset management")
Cc: stable <stable@vger.kernel.org>     # 4.2: b2fe288eac72
Cc: Vincent Cuissard <cuissard@marvell.com>
Signed-off-by: Johan Hovold <johan@kernel.org>
---
 drivers/nfc/nfcmrvl/main.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/nfc/nfcmrvl/main.c b/drivers/nfc/nfcmrvl/main.c
index 51c8240a1672..8d4294fc3005 100644
--- a/drivers/nfc/nfcmrvl/main.c
+++ b/drivers/nfc/nfcmrvl/main.c
@@ -124,10 +124,9 @@ struct nfcmrvl_private *nfcmrvl_nci_register_dev(enum nfcmrvl_phy phy,
 	memcpy(&priv->config, pdata, sizeof(*pdata));
 
 	if (priv->config.reset_n_io) {
-		rc = devm_gpio_request_one(dev,
-					   priv->config.reset_n_io,
-					   GPIOF_OUT_INIT_LOW,
-					   "nfcmrvl_reset_n");
+		rc = gpio_request_one(priv->config.reset_n_io,
+				      GPIOF_OUT_INIT_LOW,
+				      "nfcmrvl_reset_n");
 		if (rc < 0)
 			nfc_err(dev, "failed to request reset_n io\n");
 	}
@@ -195,7 +194,7 @@ void nfcmrvl_nci_unregister_dev(struct nfcmrvl_private *priv)
 	nfcmrvl_fw_dnld_deinit(priv);
 
 	if (priv->config.reset_n_io)
-		devm_gpio_free(priv->dev, priv->config.reset_n_io);
+		gpio_free(priv->config.reset_n_io);
 
 	nci_unregister_device(ndev);
 	nci_free_device(ndev);
-- 
2.12.2
