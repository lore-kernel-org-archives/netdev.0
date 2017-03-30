From: Johan Hovold <johan@kernel.org>
Subject: [PATCH v2 4/8] NFC: nfcmrvl: use nfc-device for firmware download
Date: Thu, 30 Mar 2017 12:15:38 +0200
Message-ID: <20170330101542.15384-5-johan@kernel.org>
References: <20170330101542.15384-1-johan@kernel.org>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Johan Hovold <johan@kernel.org>,
        stable <stable@vger.kernel.org>,
        Vincent Cuissard <cuissard@marvell.com>
To: Lauro Ramos Venancio <lauro.venancio@openbossa.org>,
        Aloisio Almeida Jr <aloisio.almeida@openbossa.org>,
        Samuel Ortiz <sameo@linux.intel.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20170330101542.15384-1-johan@kernel.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the nfc- rather than phy-device in firmware-management code that
needs a valid struct device.

This specifically fixes a NULL-pointer dereference in
nfcmrvl_fw_dnld_init() during registration when the underlying tty is
one end of a Unix98 pty.

Note that the driver still uses the phy device for any debugging, which
is fine for now.

Fixes: 3194c6870158 ("NFC: nfcmrvl: add firmware download support")
Cc: stable <stable@vger.kernel.org>     # 4.4
Cc: Vincent Cuissard <cuissard@marvell.com>
Signed-off-by: Johan Hovold <johan@kernel.org>
---
 drivers/nfc/nfcmrvl/fw_dnld.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/nfc/nfcmrvl/fw_dnld.c b/drivers/nfc/nfcmrvl/fw_dnld.c
index f8dcdf4b24f6..af62c4c854f3 100644
--- a/drivers/nfc/nfcmrvl/fw_dnld.c
+++ b/drivers/nfc/nfcmrvl/fw_dnld.c
@@ -459,7 +459,7 @@ int	nfcmrvl_fw_dnld_init(struct nfcmrvl_private *priv)
 
 	INIT_WORK(&priv->fw_dnld.rx_work, fw_dnld_rx_work);
 	snprintf(name, sizeof(name), "%s_nfcmrvl_fw_dnld_rx_wq",
-		 dev_name(priv->dev));
+		 dev_name(&priv->ndev->nfc_dev->dev));
 	priv->fw_dnld.rx_wq = create_singlethread_workqueue(name);
 	if (!priv->fw_dnld.rx_wq)
 		return -ENOMEM;
@@ -496,6 +496,7 @@ int nfcmrvl_fw_dnld_start(struct nci_dev *ndev, const char *firmware_name)
 {
 	struct nfcmrvl_private *priv = nci_get_drvdata(ndev);
 	struct nfcmrvl_fw_dnld *fw_dnld = &priv->fw_dnld;
+	int res;
 
 	if (!priv->support_fw_dnld)
 		return -ENOTSUPP;
@@ -511,7 +512,9 @@ int nfcmrvl_fw_dnld_start(struct nci_dev *ndev, const char *firmware_name)
 	 */
 
 	/* Retrieve FW binary */
-	if (request_firmware(&fw_dnld->fw, firmware_name, priv->dev) < 0) {
+	res = request_firmware(&fw_dnld->fw, firmware_name,
+			       &ndev->nfc_dev->dev);
+	if (res < 0) {
 		nfc_err(priv->dev, "failed to retrieve FW %s", firmware_name);
 		return -ENOENT;
 	}
-- 
2.12.2
