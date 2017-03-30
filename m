From: Johan Hovold <johan@kernel.org>
Subject: [PATCH v2 8/8] NFC: nfcmrvl: allow gpio 0 for reset signalling
Date: Thu, 30 Mar 2017 12:15:42 +0200
Message-ID: <20170330101542.15384-9-johan@kernel.org>
References: <20170330101542.15384-1-johan@kernel.org>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Johan Hovold <johan@kernel.org>
To: Lauro Ramos Venancio <lauro.venancio@openbossa.org>,
        Aloisio Almeida Jr <aloisio.almeida@openbossa.org>,
        Samuel Ortiz <sameo@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170330101542.15384-1-johan@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Allow gpio 0 to be used for reset signalling, and instead use negative
errnos to disable the reset functionality.

Signed-off-by: Johan Hovold <johan@kernel.org>
---
 drivers/nfc/nfcmrvl/main.c            | 9 ++++-----
 include/linux/platform_data/nfcmrvl.h | 2 +-
 2 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/drivers/nfc/nfcmrvl/main.c b/drivers/nfc/nfcmrvl/main.c
index a446590a71ca..838627fa82ee 100644
--- a/drivers/nfc/nfcmrvl/main.c
+++ b/drivers/nfc/nfcmrvl/main.c
@@ -123,12 +123,12 @@ struct nfcmrvl_private *nfcmrvl_nci_register_dev(enum nfcmrvl_phy phy,
 
 	memcpy(&priv->config, pdata, sizeof(*pdata));
 
-	if (priv->config.reset_n_io) {
+	if (gpio_is_valid(priv->config.reset_n_io)) {
 		rc = gpio_request_one(priv->config.reset_n_io,
 				      GPIOF_OUT_INIT_LOW,
 				      "nfcmrvl_reset_n");
 		if (rc < 0) {
-			priv->config.reset_n_io = 0;
+			priv->config.reset_n_io = -EINVAL;
 			nfc_err(dev, "failed to request reset_n io\n");
 		}
 	}
@@ -183,7 +183,7 @@ struct nfcmrvl_private *nfcmrvl_nci_register_dev(enum nfcmrvl_phy phy,
 error_free_dev:
 	nci_free_device(priv->ndev);
 error_free_gpio:
-	if (priv->config.reset_n_io)
+	if (gpio_is_valid(priv->config.reset_n_io))
 		gpio_free(priv->config.reset_n_io);
 	kfree(priv);
 	return ERR_PTR(rc);
@@ -199,7 +199,7 @@ void nfcmrvl_nci_unregister_dev(struct nfcmrvl_private *priv)
 
 	nfcmrvl_fw_dnld_deinit(priv);
 
-	if (priv->config.reset_n_io)
+	if (gpio_is_valid(priv->config.reset_n_io))
 		gpio_free(priv->config.reset_n_io);
 
 	nci_unregister_device(ndev);
@@ -267,7 +267,6 @@ int nfcmrvl_parse_dt(struct device_node *node,
 	reset_n_io = of_get_named_gpio(node, "reset-n-io", 0);
 	if (reset_n_io < 0) {
 		pr_info("no reset-n-io config\n");
-		reset_n_io = 0;
 	} else if (!gpio_is_valid(reset_n_io)) {
 		pr_err("invalid reset-n-io GPIO\n");
 		return reset_n_io;
diff --git a/include/linux/platform_data/nfcmrvl.h b/include/linux/platform_data/nfcmrvl.h
index a6f9d633f5be..9e75ac8d19be 100644
--- a/include/linux/platform_data/nfcmrvl.h
+++ b/include/linux/platform_data/nfcmrvl.h
@@ -23,7 +23,7 @@ struct nfcmrvl_platform_data {
 	 */
 
 	/* GPIO that is wired to RESET_N signal */
-	unsigned int reset_n_io;
+	int reset_n_io;
 	/* Tell if transport is muxed in HCI one */
 	unsigned int hci_muxed;
 
-- 
2.12.2
