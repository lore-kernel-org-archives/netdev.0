From: Robert Dolca <robert.dolca-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 2/2] nfc: NXP PN544 ACPI support
Date: Fri,  9 Jan 2015 14:02:17 +0200
Message-ID: <1420804937-10787-2-git-send-email-robert.dolca@intel.com>
References: <1420804937-10787-1-git-send-email-robert.dolca@intel.com>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Lauro Ramos Venancio <lauro.venancio-430g2QfJUUCGglJvpFV4uA@public.gmane.org>,
	Aloisio Almeida Jr <aloisio.almeida-430g2QfJUUCGglJvpFV4uA@public.gmane.org>,
	Samuel Ortiz <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Clement Perrochaud <clement.perrochaud-3arQi8VN3Tc@public.gmane.org>,
	Robert Dolca <robert.dolca-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: linux-nfc-hn68Rpc1hR1g9hUCZPvPmw@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1420804937-10787-1-git-send-email-robert.dolca-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Device id: NXP5440
Pin mapping:
 - 0 IRQ pin
 - 1 enable pin
 - 2 firmware pin

Signed-off-by: Robert Dolca <robert.dolca-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
---
 drivers/nfc/Kconfig     |   1 +
 drivers/nfc/pn544/i2c.c | 115 ++++++++++++++++++++++++++++++++++++++++++++++--
 net/nfc/core.c          |   1 +
 3 files changed, 114 insertions(+), 3 deletions(-)

diff --git a/drivers/nfc/Kconfig b/drivers/nfc/Kconfig
index 7929fac..a25e712 100644
--- a/drivers/nfc/Kconfig
+++ b/drivers/nfc/Kconfig
@@ -68,6 +68,7 @@ config NFC_PORT100
 
 	  If unsure, say N.
 
+source "drivers/nfc/pn547/Kconfig"
 source "drivers/nfc/pn544/Kconfig"
 source "drivers/nfc/microread/Kconfig"
 source "drivers/nfc/nfcmrvl/Kconfig"
diff --git a/drivers/nfc/pn544/i2c.c b/drivers/nfc/pn544/i2c.c
index 5f4b9c1..58b9029 100644
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
@@ -859,6 +872,90 @@ exit_state_wait_secure_write_answer:
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
@@ -884,7 +981,7 @@ static int pn544_hci_i2c_of_request_resources(struct i2c_client *client)
 	phy->gpio_en = ret;
 
 	/* Configuration of EN GPIO */
-	ret = gpio_request(phy->gpio_en, "pn544_en");
+	ret = gpio_request(phy->gpio_en, PN544_GPIO_NAME_EN);
 	if (ret) {
 		nfc_err(&client->dev, "Fail EN pin\n");
 		goto err_dt;
@@ -906,7 +1003,7 @@ static int pn544_hci_i2c_of_request_resources(struct i2c_client *client)
 	phy->gpio_fw = ret;
 
 	/* Configuration of FW GPIO */
-	ret = gpio_request(phy->gpio_fw, "pn544_fw");
+	ret = gpio_request(phy->gpio_fw, PN544_GPIO_NAME_FW);
 	if (ret) {
 		nfc_err(&client->dev, "Fail FW pin\n");
 		goto err_gpio_en;
@@ -1001,6 +1098,14 @@ static int pn544_hci_i2c_probe(struct i2c_client *client,
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
@@ -1020,9 +1125,12 @@ static int pn544_hci_i2c_probe(struct i2c_client *client,
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
@@ -1080,6 +1188,7 @@ static struct i2c_driver pn544_hci_i2c_driver = {
 		   .name = PN544_HCI_I2C_DRIVER_NAME,
 		   .owner  = THIS_MODULE,
 		   .of_match_table = of_match_ptr(of_pn544_i2c_match),
+		   .acpi_match_table = ACPI_PTR(pn544_hci_i2c_acpi_match),
 		  },
 	.probe = pn544_hci_i2c_probe,
 	.id_table = pn544_hci_i2c_id_table,
diff --git a/net/nfc/core.c b/net/nfc/core.c
index 819b877..a53c2cc 100644
--- a/net/nfc/core.c
+++ b/net/nfc/core.c
@@ -32,6 +32,7 @@
 
 #include "nfc.h"
 
+#define DEBUG
 #define VERSION "0.1"
 
 #define NFC_CHECK_PRES_FREQ_MS	2000
-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
