From: Robert Dolca <robert.dolca@intel.com>
Subject: [PATCH v2 2/2] NFC: Add ACPI support for NXP PN544
Date: Mon, 26 Jan 2015 13:13:37 +0200
Message-ID: <1422270817-10950-3-git-send-email-robert.dolca@intel.com>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1422270817-10950-1-git-send-email-robert.dolca@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Currently there is no support for ACPI.
This patch uses the following configuration:
	- Device id: NXP5440
	- Pin mapping:
		- 0 IRQ pin
		- 1 enable pin
		- 2 firmware pin

Signed-off-by: Robert Dolca <robert.dolca@intel.com>
---
 drivers/nfc/pn544/i2c.c | 115 ++++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 112 insertions(+), 3 deletions(-)

diff --git a/drivers/nfc/pn544/i2c.c b/drivers/nfc/pn544/i2c.c
index d9018cd..ae817b0 100644
--- a/drivers/nfc/pn544/i2c.c
+++ b/drivers/nfc/pn544/i2c.c
@@ -24,6 +24,7 @@
 #include <linux/gpio.h>
 #include <linux/of_gpio.h>
 #include <linux/of_irq.h>
+#include <linux/acpi.h>
 #include <linux/miscdevice.h>
 #include <linux/interrupt.h>
 #include <linux/delay.h>
@@ -41,6 +42,11 @@
 #define PN544_I2C_FRAME_HEADROOM 1
 #define PN544_I2C_FRAME_TAILROOM 2
 
+/* GPIO names */
+#define PN544_GPIO_NAME_IRQ "pn544_irq"
+#define PN544_GPIO_NAME_FW  "pn544_fw"
+#define PN544_GPIO_NAME_EN  "pn544_en"
+
 /* framing in HCI mode */
 #define PN544_HCI_I2C_LLC_LEN		1
 #define PN544_HCI_I2C_LLC_CRC		2
@@ -58,6 +64,13 @@ static struct i2c_device_id pn544_hci_i2c_id_table[] = {
 
 MODULE_DEVICE_TABLE(i2c, pn544_hci_i2c_id_table);
 
+static const struct acpi_device_id pn544_hci_i2c_acpi_match[] = {
+	{"NXP5440", 0},
+	{}
+};
+
+MODULE_DEVICE_TABLE(acpi, pn544_hci_i2c_acpi_match);
+
 #define PN544_HCI_I2C_DRIVER_NAME "pn544_hci_i2c"
 
 /*
@@ -861,6 +874,90 @@ exit_state_wait_secure_write_answer:
 	}
 }
 
+static int pn544_hci_i2c_acpi_request_resources(struct i2c_client *client)
+{
+	struct pn544_i2c_phy *phy = i2c_get_clientdata(client);
+	const struct acpi_device_id *id;
+	struct gpio_desc *gpiod_en, *gpiod_irq, *gpiod_fw;
+	struct device *dev;
+	int ret;
+
+	if (!client)
+		return -EINVAL;
+
+	dev = &client->dev;
+
+	/* Match the struct device against a given list of ACPI IDs */
+	id = acpi_match_device(dev->driver->acpi_match_table, dev);
+
+	if (!id)
+		return -ENODEV;
+
+	/* Get EN GPIO from ACPI */
+	gpiod_en = devm_gpiod_get_index(dev, PN544_GPIO_NAME_EN, 1);
+	if (IS_ERR(gpiod_en)) {
+		nfc_err(dev,
+			"Unable to get EN GPIO\n");
+		return -ENODEV;
+	}
+
+	phy->gpio_en  = desc_to_gpio(gpiod_en);
+
+	/* Configuration EN GPIO */
+	ret = gpiod_direction_output(gpiod_en, 0);
+	if (ret) {
+		nfc_err(dev, "Fail EN pin direction\n");
+		return ret;
+	}
+
+	/* Get FW GPIO from ACPI */
+	gpiod_fw = devm_gpiod_get_index(dev, PN544_GPIO_NAME_FW, 2);
+	if (IS_ERR(gpiod_fw)) {
+		nfc_err(dev,
+			"Unable to get FW GPIO\n");
+		return -ENODEV;
+	}
+
+	phy->gpio_fw  = desc_to_gpio(gpiod_fw);
+
+	/* Configuration FW GPIO */
+	ret = gpiod_direction_output(gpiod_fw, 0);
+	if (ret) {
+		nfc_err(dev, "Fail FW pin direction\n");
+		return ret;
+	}
+
+	/* Get IRQ GPIO */
+	gpiod_irq = devm_gpiod_get_index(dev, PN544_GPIO_NAME_IRQ, 0);
+	if (IS_ERR(gpiod_irq)) {
+		nfc_err(dev,
+			"Unable to get IRQ GPIO\n");
+		return -ENODEV;
+	}
+
+	phy->gpio_irq = desc_to_gpio(gpiod_irq);
+
+	/* Configure IRQ GPIO */
+	ret = gpiod_direction_input(gpiod_irq);
+	if (ret) {
+		nfc_err(dev, "Fail IRQ pin direction\n");
+		return ret;
+	}
+
+	/* Map the pin to an IRQ */
+	ret = gpiod_to_irq(gpiod_irq);
+	if (ret < 0) {
+		nfc_err(dev, "Fail pin IRQ mapping\n");
+		return ret;
+	}
+
+	nfc_info(dev, "GPIO resource, no:%d irq:%d\n",
+			desc_to_gpio(gpiod_irq), ret);
+	client->irq = ret;
+
+	return 0;
+}
+
 #ifdef CONFIG_OF
 
 static int pn544_hci_i2c_of_request_resources(struct i2c_client *client)
@@ -886,7 +983,7 @@ static int pn544_hci_i2c_of_request_resources(struct i2c_client *client)
 	phy->gpio_en = ret;
 
 	/* Configuration of EN GPIO */
-	ret = gpio_request(phy->gpio_en, "pn544_en");
+	ret = gpio_request(phy->gpio_en, PN544_GPIO_NAME_EN);
 	if (ret) {
 		nfc_err(&client->dev, "Fail EN pin\n");
 		goto err_dt;
@@ -908,7 +1005,7 @@ static int pn544_hci_i2c_of_request_resources(struct i2c_client *client)
 	phy->gpio_fw = ret;
 
 	/* Configuration of FW GPIO */
-	ret = gpio_request(phy->gpio_fw, "pn544_fw");
+	ret = gpio_request(phy->gpio_fw, PN544_GPIO_NAME_FW);
 	if (ret) {
 		nfc_err(&client->dev, "Fail FW pin\n");
 		goto err_gpio_en;
@@ -1003,6 +1100,14 @@ static int pn544_hci_i2c_probe(struct i2c_client *client,
 		phy->gpio_en = pdata->get_gpio(NFC_GPIO_ENABLE);
 		phy->gpio_fw = pdata->get_gpio(NFC_GPIO_FW_RESET);
 		phy->gpio_irq = pdata->get_gpio(NFC_GPIO_IRQ);
+	/* Using ACPI */
+	} else if (ACPI_HANDLE(&client->dev)) {
+		r = pn544_hci_i2c_acpi_request_resources(client);
+		if (r) {
+			nfc_err(&client->dev,
+				"Cannot get ACPI data\n");
+			return r;
+		}
 	} else {
 		nfc_err(&client->dev, "No platform data\n");
 		return -EINVAL;
@@ -1022,9 +1127,12 @@ static int pn544_hci_i2c_probe(struct i2c_client *client,
 			    PN544_I2C_FRAME_HEADROOM, PN544_I2C_FRAME_TAILROOM,
 			    PN544_HCI_I2C_LLC_MAX_PAYLOAD,
 			    pn544_hci_i2c_fw_download, &phy->hdev);
-	if (r < 0)
+	if (r < 0) {
+		nfc_err(&client->dev, "HCI Probing error\n");
 		goto err_hci;
+	}
 
+	nfc_info(&client->dev, "NFC I2C driver loaded\n");
 	return 0;
 
 err_hci:
@@ -1082,6 +1190,7 @@ static struct i2c_driver pn544_hci_i2c_driver = {
 		   .name = PN544_HCI_I2C_DRIVER_NAME,
 		   .owner  = THIS_MODULE,
 		   .of_match_table = of_match_ptr(of_pn544_i2c_match),
+		   .acpi_match_table = ACPI_PTR(pn544_hci_i2c_acpi_match),
 		  },
 	.probe = pn544_hci_i2c_probe,
 	.id_table = pn544_hci_i2c_id_table,
-- 
1.9.1
