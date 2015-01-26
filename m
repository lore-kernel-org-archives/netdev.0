From: Robert Dolca <robert.dolca@intel.com>
Subject: [PATCH v2 1/2] NFC: PN544: GPIO access that may sleep
Date: Mon, 26 Jan 2015 13:13:36 +0200
Message-ID: <1422270817-10950-2-git-send-email-robert.dolca@intel.com>
References: <1422270817-10950-1-git-send-email-robert.dolca@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Berg Johannes <johannes.berg@intel.com>,
	Clement Perrochaud <clement.perrochaud@nxp.com>,
	Robert Dolca <robert.dolca@intel.com>
To: linux-nfc@lists.01.org,
	Lauro Ramos Venancio <lauro.venancio@openbossa.org>,
	Aloisio Almeida Jr <aloisio.almeida@openbossa.org>,
	Samuel Ortiz <sameo@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:64239 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751221AbbAZLOG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Jan 2015 06:14:06 -0500
In-Reply-To: <1422270817-10950-1-git-send-email-robert.dolca@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

gpio_set_value was replaced with gpio_set_value_cansleep in order
to allow GPIO access that may sleep. This is particularelly useful
when GPIO is accessed using busses like I2C, SPI, USB

Signed-off-by: Robert Dolca <robert.dolca@intel.com>
---
 drivers/nfc/pn544/i2c.c | 22 ++++++++++++----------
 1 file changed, 12 insertions(+), 10 deletions(-)

diff --git a/drivers/nfc/pn544/i2c.c b/drivers/nfc/pn544/i2c.c
index fc02e8d..d9018cd 100644
--- a/drivers/nfc/pn544/i2c.c
+++ b/drivers/nfc/pn544/i2c.c
@@ -195,18 +195,19 @@ static void pn544_hci_i2c_platform_init(struct pn544_i2c_phy *phy)
 	nfc_info(&phy->i2c_dev->dev, "Detecting nfc_en polarity\n");
 
 	/* Disable fw download */
-	gpio_set_value(phy->gpio_fw, 0);
+	gpio_set_value_cansleep(phy->gpio_fw, 0);
 
 	for (polarity = 0; polarity < 2; polarity++) {
 		phy->en_polarity = polarity;
 		retry = 3;
 		while (retry--) {
 			/* power off */
-			gpio_set_value(phy->gpio_en, !phy->en_polarity);
+			gpio_set_value_cansleep(phy->gpio_en,
+						!phy->en_polarity);
 			usleep_range(10000, 15000);
 
 			/* power on */
-			gpio_set_value(phy->gpio_en, phy->en_polarity);
+			gpio_set_value_cansleep(phy->gpio_en, phy->en_polarity);
 			usleep_range(10000, 15000);
 
 			/* send reset */
@@ -225,13 +226,14 @@ static void pn544_hci_i2c_platform_init(struct pn544_i2c_phy *phy)
 		"Could not detect nfc_en polarity, fallback to active high\n");
 
 out:
-	gpio_set_value(phy->gpio_en, !phy->en_polarity);
+	gpio_set_value_cansleep(phy->gpio_en, !phy->en_polarity);
 }
 
 static void pn544_hci_i2c_enable_mode(struct pn544_i2c_phy *phy, int run_mode)
 {
-	gpio_set_value(phy->gpio_fw, run_mode == PN544_FW_MODE ? 1 : 0);
-	gpio_set_value(phy->gpio_en, phy->en_polarity);
+	gpio_set_value_cansleep(phy->gpio_fw,
+				run_mode == PN544_FW_MODE ? 1 : 0);
+	gpio_set_value_cansleep(phy->gpio_en, phy->en_polarity);
 	usleep_range(10000, 15000);
 
 	phy->run_mode = run_mode;
@@ -254,14 +256,14 @@ static void pn544_hci_i2c_disable(void *phy_id)
 {
 	struct pn544_i2c_phy *phy = phy_id;
 
-	gpio_set_value(phy->gpio_fw, 0);
-	gpio_set_value(phy->gpio_en, !phy->en_polarity);
+	gpio_set_value_cansleep(phy->gpio_fw, 0);
+	gpio_set_value_cansleep(phy->gpio_en, !phy->en_polarity);
 	usleep_range(10000, 15000);
 
-	gpio_set_value(phy->gpio_en, phy->en_polarity);
+	gpio_set_value_cansleep(phy->gpio_en, phy->en_polarity);
 	usleep_range(10000, 15000);
 
-	gpio_set_value(phy->gpio_en, !phy->en_polarity);
+	gpio_set_value_cansleep(phy->gpio_en, !phy->en_polarity);
 	usleep_range(10000, 15000);
 
 	phy->powered = 0;
-- 
1.9.1
