From: Robert Dolca <robert.dolca@intel.com>
Subject: [PATCH v4 10/10] nfc: Add Intel Fields Peak NFC solution driver
Date: Thu, 22 Oct 2015 12:11:42 +0300
Message-ID: <1445505102-16639-11-git-send-email-robert.dolca@intel.com>
References: <1445505102-16639-1-git-send-email-robert.dolca@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org,
	Christophe Ricard <christophe.ricard@gmail.com>,
	Robert Dolca <robert.dolca@intel.com>
To: linux-nfc@lists.01.org,
	Lauro Ramos Venancio <lauro.venancio@openbossa.org>,
	Aloisio Almeida Jr <aloisio.almeida@openbossa.org>,
	Samuel Ortiz <sameo@linux.intel.com>,
	Robert Dolca <robert.dolca@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:8976 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964911AbbJVJMj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Oct 2015 05:12:39 -0400
In-Reply-To: <1445505102-16639-1-git-send-email-robert.dolca@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46ields Peak complies with the ISO/IEC 14443A/B, 15693, 18092,
and JIS X 6319-4. It is an NCI based controller.

RF Protocols supported:
 - NFC Forum Type 1 Tags (Jewel, Topaz)
 - NFC Forum Type 2 Tags (Mifare UL)
 - NFC Forum Type 3 Tags (FeliCa)
 - NFC Forum Type 4A (ISO/IEC 14443 A-4 106kbps to 848kbps)
 - NFC Forum Type 4B (ISO/IEC 14443 B-4 106kbps to 848kbps)
 - NFCIP in passive and active modes (ISO/IEC 18092 106kbps to 424kbps)
 - B=E2=80=99 (based on ISO/IEC 14443 B-2)
 - iCLASS (based on ISO/IEC 15693-2)
 - Vicinity cards (ISO/IEC 15693-3)
 - Kovio tags (NFC Forum Type 2)

The device can be enumerated using ACPI using the id INT339A.
The 1st GPIO is the IRQ and the 2nd is the RESET pin.

Signed-off-by: Robert Dolca <robert.dolca@intel.com>
---
 drivers/nfc/Kconfig      |   1 +
 drivers/nfc/Makefile     |   1 +
 drivers/nfc/fdp/Kconfig  |  23 ++
 drivers/nfc/fdp/Makefile |   9 +
 drivers/nfc/fdp/fdp.c    | 817 +++++++++++++++++++++++++++++++++++++++=
++++++++
 drivers/nfc/fdp/fdp.h    |  38 +++
 drivers/nfc/fdp/i2c.c    | 388 ++++++++++++++++++++++
 7 files changed, 1277 insertions(+)
 create mode 100644 drivers/nfc/fdp/Kconfig
 create mode 100644 drivers/nfc/fdp/Makefile
 create mode 100644 drivers/nfc/fdp/fdp.c
 create mode 100644 drivers/nfc/fdp/fdp.h
 create mode 100644 drivers/nfc/fdp/i2c.c

diff --git a/drivers/nfc/Kconfig b/drivers/nfc/Kconfig
index 6639cd1..0d6003d 100644
--- a/drivers/nfc/Kconfig
+++ b/drivers/nfc/Kconfig
@@ -68,6 +68,7 @@ config NFC_PORT100
=20
 	  If unsure, say N.
=20
+source "drivers/nfc/fdp/Kconfig"
 source "drivers/nfc/pn544/Kconfig"
 source "drivers/nfc/microread/Kconfig"
 source "drivers/nfc/nfcmrvl/Kconfig"
diff --git a/drivers/nfc/Makefile b/drivers/nfc/Makefile
index 2757fe1..e362141 100644
--- a/drivers/nfc/Makefile
+++ b/drivers/nfc/Makefile
@@ -2,6 +2,7 @@
 # Makefile for nfc devices
 #
=20
+obj-$(CONFIG_NFC_FDP)		+=3D fdp/
 obj-$(CONFIG_NFC_PN544)		+=3D pn544/
 obj-$(CONFIG_NFC_MICROREAD)	+=3D microread/
 obj-$(CONFIG_NFC_PN533)		+=3D pn533.o
diff --git a/drivers/nfc/fdp/Kconfig b/drivers/nfc/fdp/Kconfig
new file mode 100644
index 0000000..fbccd9d
--- /dev/null
+++ b/drivers/nfc/fdp/Kconfig
@@ -0,0 +1,23 @@
+config NFC_FDP
+	tristate "Intel FDP NFC driver"
+	depends on NFC_NCI
+	select CRC_CCITT
+	default n
+	---help---
+	  Intel Fields Peak NFC controller core driver.
+	  This is a driver based on the NCI NFC kernel layers.
+
+	  To compile this driver as a module, choose m here. The module will
+	  be called fdp.
+	  Say N if unsure.
+
+config NFC_FDP_I2C
+	tristate "NFC FDP i2c support"
+	depends on NFC_FDP && I2C
+	---help---
+	  This module adds support for the Intel Fields Peak NFC controller
+	  i2c interface.
+	  Select this if your platform is using the i2c bus.
+
+	  If you choose to build a module, it'll be called fdp_i2c.
+	  Say N if unsure.
diff --git a/drivers/nfc/fdp/Makefile b/drivers/nfc/fdp/Makefile
new file mode 100644
index 0000000..e79d51b
--- /dev/null
+++ b/drivers/nfc/fdp/Makefile
@@ -0,0 +1,9 @@
+#
+# Makefile for FDP NCI based NFC driver
+#
+
+obj-$(CONFIG_NFC_FDP)     +=3D fdp.o
+obj-$(CONFIG_NFC_FDP_I2C) +=3D fdp_i2c.o
+
+fdp_i2c-objs  =3D i2c.o
+
diff --git a/drivers/nfc/fdp/fdp.c b/drivers/nfc/fdp/fdp.c
new file mode 100644
index 0000000..ccb07a1
--- /dev/null
+++ b/drivers/nfc/fdp/fdp.c
@@ -0,0 +1,817 @@
+/* -------------------------------------------------------------------=
------
+ * Copyright (C) 2014-2016, Intel Corporation
+ *
+ *  This program is free software; you can redistribute it and/or modi=
fy
+ *  it under the terms of the GNU General Public License as published =
by
+ *  the Free Software Foundation; either version 2 of the License, or
+ *  (at your option) any later version.
+ *
+ *  This program is distributed in the hope that it will be useful,
+ *  but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ *  GNU General Public License for more details.
+ * -------------------------------------------------------------------=
------
+ */
+
+#include <linux/module.h>
+#include <linux/nfc.h>
+#include <linux/i2c.h>
+#include <linux/delay.h>
+#include <linux/firmware.h>
+#include <net/nfc/nci_core.h>
+
+#include "fdp.h"
+
+#define FDP_OTP_PATCH_NAME			"otp.bin"
+#define FDP_RAM_PATCH_NAME			"ram.bin"
+#define FDP_FW_HEADER_SIZE			576
+#define FDP_FW_UPDATE_SLEEP			1000
+
+#define NCI_GET_VERSION_TIMEOUT			8000
+#define NCI_PATCH_REQUEST_TIMEOUT		8000
+#define FDP_PATCH_CONN_DEST			0xC2
+#define FDP_PATCH_CONN_PARAM_TYPE		0xA0
+
+#define NCI_PATCH_TYPE_RAM			0x00
+#define NCI_PATCH_TYPE_OTP			0x01
+#define NCI_PATCH_TYPE_EOT			0xFF
+
+#define NCI_PARAM_ID_FW_RAM_VERSION		0xA0
+#define NCI_PARAM_ID_FW_OTP_VERSION		0xA1
+#define NCI_PARAM_ID_OTP_LIMITED_VERSION	0xC5
+#define NCI_PARAM_ID_KEY_INDEX_ID		0xC6
+
+#define NCI_GID_PROP				0x0F
+#define NCI_OP_PROP_PATCH_OID			0x08
+#define NCI_OP_PROP_SET_PDATA_OID		0x23
+
+struct fdp_nci_info {
+	struct nfc_phy_ops *phy_ops;
+	struct fdp_i2c_phy *phy;
+	struct nci_dev *ndev;
+
+	const struct firmware *otp_patch;
+	const struct firmware *ram_patch;
+	u32 otp_patch_version;
+	u32 ram_patch_version;
+
+	u32 otp_version;
+	u32 ram_version;
+	u32 limited_otp_version;
+	u8 key_index;
+
+	u8 *fw_vsc_cfg;
+	u8 clock_type;
+	u32 clock_freq;
+
+	atomic_t data_pkt_counter;
+	void (*data_pkt_counter_cb)(struct nci_dev *ndev);
+	u8 setup_patch_sent;
+	u8 setup_patch_ntf;
+	u8 setup_patch_status;
+	u8 setup_reset_ntf;
+	wait_queue_head_t setup_wq;
+};
+
+static u8 nci_core_get_config_otp_ram_version[5] =3D {
+	0x04,
+	NCI_PARAM_ID_FW_RAM_VERSION,
+	NCI_PARAM_ID_FW_OTP_VERSION,
+	NCI_PARAM_ID_OTP_LIMITED_VERSION,
+	NCI_PARAM_ID_KEY_INDEX_ID
+};
+
+struct nci_core_get_config_rsp {
+	u8 status;
+	u8 count;
+	u8 data[0];
+};
+
+static int fdp_nci_create_conn(struct nci_dev *ndev)
+{
+	struct fdp_nci_info *info =3D nci_get_drvdata(ndev);
+	struct core_conn_create_dest_spec_params param;
+	int r;
+
+	/* proprietary destination specific paramerer without value */
+	param.type =3D FDP_PATCH_CONN_PARAM_TYPE;
+	param.length =3D 0x00;
+
+	r =3D nci_core_conn_create(info->ndev, FDP_PATCH_CONN_DEST, 1,
+				 sizeof(param), &param);
+	if (r)
+		return r;
+
+	return nci_get_conn_info_by_id(ndev, 0);
+}
+
+static inline int fdp_nci_get_versions(struct nci_dev *ndev)
+{
+	return nci_core_cmd(ndev, NCI_OP_CORE_GET_CONFIG_CMD,
+			    sizeof(nci_core_get_config_otp_ram_version),
+			    (__u8 *) &nci_core_get_config_otp_ram_version);
+}
+
+static inline int fdp_nci_patch_cmd(struct nci_dev *ndev, u8 type)
+{
+	return nci_prop_cmd(ndev, NCI_OP_PROP_PATCH_OID, sizeof(type), &type)=
;
+}
+
+static inline int fdp_nci_set_production_data(struct nci_dev *ndev, u8=
 len,
+					      char *data)
+{
+	return nci_prop_cmd(ndev, NCI_OP_PROP_SET_PDATA_OID, len, data);
+}
+
+static int fdp_nci_set_clock(struct nci_dev *ndev, u8 clock_type,
+			     u32 clock_freq)
+{
+	u32 fc =3D 13560;
+	u32 nd, num, delta;
+	char data[9];
+
+	nd =3D (24 * fc) / clock_freq;
+	delta =3D 24 * fc - nd * clock_freq;
+	num =3D (32768 * delta) / clock_freq;
+
+	data[0] =3D 0x00;
+	data[1] =3D 0x00;
+	data[2] =3D 0x00;
+
+	data[3] =3D 0x10;
+	data[4] =3D 0x04;
+	data[5] =3D num & 0xFF;
+	data[6] =3D (num >> 8) & 0xff;
+	data[7] =3D nd;
+	data[8] =3D clock_type;
+
+	return fdp_nci_set_production_data(ndev, 9, data);
+}
+
+static void fdp_nci_send_patch_cb(struct nci_dev *ndev)
+{
+	struct fdp_nci_info *info =3D nci_get_drvdata(ndev);
+
+	info->setup_patch_sent =3D 1;
+	wake_up(&info->setup_wq);
+}
+
+/**
+ * Register a packet sent counter and a callback
+ *
+ * We have no other way of knowing when all firmware packets were sent=
 out
+ * on the i2c bus. We need to know that in order to close the connecti=
on and
+ * send the patch end message.
+ */
+static void fdp_nci_set_data_pkt_counter(struct nci_dev *ndev,
+				  void (*cb)(struct nci_dev *ndev), int count)
+{
+	struct fdp_nci_info *info =3D nci_get_drvdata(ndev);
+	struct device *dev =3D &info->phy->i2c_dev->dev;
+
+	dev_dbg(dev, "NCI data pkt counter %d\n", count);
+	atomic_set(&info->data_pkt_counter, count);
+	info->data_pkt_counter_cb =3D cb;
+}
+
+/**
+ * The device is expecting a stream of packets. All packets need to
+ * have the PBF flag set to 0x0 (last packet) even if the firmware
+ * file is segmented and there are multiple packets. If we give the
+ * whole firmware to nci_send_data it will segment it and it will set
+ * the PBF flag to 0x01 so we need to do the segmentation here.
+ *
+ * The firmware will be analyzed and applied when we send NCI_OP_PROP_=
PATCH_CMD
+ * command with NCI_PATCH_TYPE_EOT parameter. The device will send a
+ * NFCC_PATCH_NTF packaet and a NCI_OP_CORE_RESET_NTF packet.
+ */
+static int fdp_nci_send_patch(struct nci_dev *ndev, u8 conn_id, u8 typ=
e)
+{
+	struct fdp_nci_info *info =3D nci_get_drvdata(ndev);
+	const struct firmware *fw;
+	struct sk_buff *skb;
+	unsigned long len;
+	u8 max_size, payload_size;
+	int rc =3D 0;
+
+	if ((type =3D=3D NCI_PATCH_TYPE_OTP && !info->otp_patch) ||
+	    (type =3D=3D NCI_PATCH_TYPE_RAM && !info->ram_patch))
+		return -EINVAL;
+
+	if (type =3D=3D NCI_PATCH_TYPE_OTP)
+		fw =3D info->otp_patch;
+	else
+		fw =3D info->ram_patch;
+
+	max_size =3D nci_conn_max_data_pkt_payload_size(ndev, conn_id);
+	if (max_size <=3D 0)
+		return -EINVAL;
+
+	len =3D fw->size;
+
+	fdp_nci_set_data_pkt_counter(ndev, fdp_nci_send_patch_cb,
+				     DIV_ROUND_UP(fw->size, max_size));
+
+	while (len) {
+
+		payload_size =3D min_t(unsigned long, (unsigned long) max_size,
+				     len);
+
+		skb =3D nci_skb_alloc(ndev, (NCI_CTRL_HDR_SIZE + payload_size),
+				    GFP_KERNEL);
+		if (!skb) {
+			fdp_nci_set_data_pkt_counter(ndev, NULL, 0);
+			return -ENOMEM;
+		}
+
+
+		skb_reserve(skb, NCI_CTRL_HDR_SIZE);
+
+		memcpy(skb_put(skb, payload_size), fw->data + (fw->size - len),
+		       payload_size);
+
+		rc =3D nci_send_data(ndev, conn_id, skb);
+
+		if (rc) {
+			fdp_nci_set_data_pkt_counter(ndev, NULL, 0);
+			return rc;
+		}
+
+		len -=3D payload_size;
+	}
+
+	return rc;
+}
+
+static int fdp_nci_open(struct nci_dev *ndev)
+{
+	int r;
+	struct fdp_nci_info *info =3D nci_get_drvdata(ndev);
+	struct device *dev =3D &info->phy->i2c_dev->dev;
+
+	dev_dbg(dev, "%s\n", __func__);
+
+	r =3D info->phy_ops->enable(info->phy);
+
+	return r;
+}
+
+static int fdp_nci_close(struct nci_dev *ndev)
+{
+	struct fdp_nci_info *info =3D nci_get_drvdata(ndev);
+	struct device *dev =3D &info->phy->i2c_dev->dev;
+
+	dev_dbg(dev, "%s\n", __func__);
+	return 0;
+}
+
+static int fdp_nci_send(struct nci_dev *ndev, struct sk_buff *skb)
+{
+	struct fdp_nci_info *info =3D nci_get_drvdata(ndev);
+	struct device *dev =3D &info->phy->i2c_dev->dev;
+
+	dev_dbg(dev, "%s\n", __func__);
+
+	if (atomic_dec_and_test(&info->data_pkt_counter))
+		info->data_pkt_counter_cb(ndev);
+
+	return info->phy_ops->write(info->phy, skb);
+}
+
+int fdp_nci_recv_frame(struct nci_dev *ndev, struct sk_buff *skb)
+{
+	struct fdp_nci_info *info =3D nci_get_drvdata(ndev);
+	struct device *dev =3D &info->phy->i2c_dev->dev;
+
+	dev_dbg(dev, "%s\n", __func__);
+	return nci_recv_frame(ndev, skb);
+}
+EXPORT_SYMBOL(fdp_nci_recv_frame);
+
+static int fdp_nci_request_firmware(struct nci_dev *ndev)
+{
+	struct fdp_nci_info *info =3D nci_get_drvdata(ndev);
+	struct device *dev =3D &info->phy->i2c_dev->dev;
+	u8 *data;
+	int r;
+
+	r =3D request_firmware(&info->ram_patch, FDP_RAM_PATCH_NAME, dev);
+	if (r < 0) {
+		nfc_err(dev, "RAM patch request error\n");
+		goto error;
+	}
+
+	data =3D (u8 *) info->ram_patch->data;
+	info->ram_patch_version =3D
+		data[FDP_FW_HEADER_SIZE] |
+		(data[FDP_FW_HEADER_SIZE + 1] << 8) |
+		(data[FDP_FW_HEADER_SIZE + 2] << 16) |
+		(data[FDP_FW_HEADER_SIZE + 3] << 24);
+
+	dev_dbg(dev, "RAM patch version: %d, size: %d\n",
+		  info->ram_patch_version, (int) info->ram_patch->size);
+
+
+	r =3D request_firmware(&info->otp_patch, FDP_OTP_PATCH_NAME, dev);
+	if (r < 0) {
+		nfc_err(dev, "OTP patch request error\n");
+		goto out;
+	}
+
+	data =3D (u8 *) info->otp_patch->data;
+	info->otp_patch_version =3D
+		data[FDP_FW_HEADER_SIZE] |
+		(data[FDP_FW_HEADER_SIZE + 1] << 8) |
+		(data[FDP_FW_HEADER_SIZE+2] << 16) |
+		(data[FDP_FW_HEADER_SIZE+3] << 24);
+
+	dev_dbg(dev, "OTP patch version: %d, size: %d\n",
+		 info->otp_patch_version, (int) info->otp_patch->size);
+out:
+	return 0;
+error:
+	return r;
+}
+
+static void fdp_nci_release_firmware(struct nci_dev *ndev)
+{
+	struct fdp_nci_info *info =3D nci_get_drvdata(ndev);
+
+	if (info->otp_patch) {
+		release_firmware(info->otp_patch);
+		info->otp_patch =3D NULL;
+	}
+
+	if (info->ram_patch) {
+		release_firmware(info->ram_patch);
+		info->otp_patch =3D NULL;
+	}
+}
+
+static int fdp_nci_patch_otp(struct nci_dev *ndev)
+{
+	struct fdp_nci_info *info =3D nci_get_drvdata(ndev);
+	struct device *dev =3D &info->phy->i2c_dev->dev;
+	u8 conn_id;
+	int r =3D 0;
+
+	if (info->otp_version >=3D info->otp_patch_version)
+		goto out;
+
+	info->setup_patch_sent =3D 0;
+	info->setup_reset_ntf =3D 0;
+	info->setup_patch_ntf =3D 0;
+
+	/* Patch init request */
+	r =3D fdp_nci_patch_cmd(ndev, NCI_PATCH_TYPE_OTP);
+	if (r)
+		goto out;
+
+	/* Patch data connection creation */
+	conn_id =3D fdp_nci_create_conn(ndev);
+	if (conn_id < 0) {
+		r =3D conn_id;
+		goto out;
+	}
+
+	/* Send the patch over the data connection */
+	r =3D fdp_nci_send_patch(ndev, conn_id, NCI_PATCH_TYPE_OTP);
+	if (r)
+		goto out;
+
+	/* Wait for all the packets to be send over i2c */
+	wait_event_interruptible(info->setup_wq,
+				 info->setup_patch_sent =3D=3D 1);
+
+	/* make sure that the NFCC processed the last data packet */
+	msleep(FDP_FW_UPDATE_SLEEP);
+
+	/* Close the data connection */
+	r =3D nci_core_conn_close(info->ndev, conn_id);
+	if (r)
+		goto out;
+
+	/* Patch finish message */
+	if (fdp_nci_patch_cmd(ndev, NCI_PATCH_TYPE_EOT)) {
+		nfc_err(dev, "OTP patch error 0x%x\n", r);
+		r =3D -EINVAL;
+		goto out;
+	}
+
+	/* If the patch notification didn't arrive yet, wait for it */
+	wait_event_interruptible(info->setup_wq, info->setup_patch_ntf);
+
+	/* Check if the patching was successful */
+	r =3D info->setup_patch_status;
+	if (r) {
+		nfc_err(dev, "OTP patch error 0x%x\n", r);
+		r =3D -EINVAL;
+		goto out;
+	}
+
+	/*
+	 * We need to wait for the reset notification before we
+	 * can continue
+	 */
+	wait_event_interruptible(info->setup_wq, info->setup_reset_ntf);
+
+out:
+	return r;
+}
+
+static int fdp_nci_patch_ram(struct nci_dev *ndev)
+{
+	struct fdp_nci_info *info =3D nci_get_drvdata(ndev);
+	struct device *dev =3D &info->phy->i2c_dev->dev;
+	u8 conn_id;
+	int r =3D 0;
+
+	if (info->ram_version >=3D info->ram_patch_version)
+		goto out;
+
+	info->setup_patch_sent =3D 0;
+	info->setup_reset_ntf =3D 0;
+	info->setup_patch_ntf =3D 0;
+
+	/* Patch init request */
+	r =3D fdp_nci_patch_cmd(ndev, NCI_PATCH_TYPE_RAM);
+	if (r)
+		goto out;
+
+	/* Patch data connection creation */
+	conn_id =3D fdp_nci_create_conn(ndev);
+	if (conn_id < 0) {
+		r =3D conn_id;
+		goto out;
+	}
+
+	/* Send the patch over the data connection */
+	r =3D fdp_nci_send_patch(ndev, conn_id, NCI_PATCH_TYPE_RAM);
+	if (r)
+		goto out;
+
+	/* Wait for all the packets to be send over i2c */
+	wait_event_interruptible(info->setup_wq,
+				 info->setup_patch_sent =3D=3D 1);
+
+	/* make sure that the NFCC processed the last data packet */
+	msleep(FDP_FW_UPDATE_SLEEP);
+
+	/* Close the data connection */
+	r =3D nci_core_conn_close(info->ndev, conn_id);
+	if (r)
+		goto out;
+
+	/* Patch finish message */
+	if (fdp_nci_patch_cmd(ndev, NCI_PATCH_TYPE_EOT)) {
+		nfc_err(dev, "RAM patch error 0x%x\n", r);
+		r =3D -EINVAL;
+		goto out;
+	}
+
+	/* If the patch notification didn't arrive yet, wait for it */
+	wait_event_interruptible(info->setup_wq, info->setup_patch_ntf);
+
+	/* Check if the patching was successful */
+	r =3D info->setup_patch_status;
+	if (r) {
+		nfc_err(dev, "RAM patch error 0x%x\n", r);
+		r =3D -EINVAL;
+		goto out;
+	}
+
+	/*
+	 * We need to wait for the reset notification before we
+	 * can continue
+	 */
+	wait_event_interruptible(info->setup_wq, info->setup_reset_ntf);
+
+out:
+	return r;
+}
+
+static int fdp_nci_setup(struct nci_dev *ndev)
+{
+	/* Format: total length followed by an NCI packet */
+	struct fdp_nci_info *info =3D nci_get_drvdata(ndev);
+	struct device *dev =3D &info->phy->i2c_dev->dev;
+	int r;
+	u8 patched =3D 0;
+
+	dev_dbg(dev, "%s\n", __func__);
+
+	r =3D nci_core_init(ndev);
+	if (r)
+		goto error;
+
+	/* Get RAM and OTP version */
+	r =3D fdp_nci_get_versions(ndev);
+	if (r)
+		goto error;
+
+	/* Load firmware from disk */
+	r =3D fdp_nci_request_firmware(ndev);
+	if (r)
+		goto error;
+
+	/* Update OTP */
+	if (info->otp_version < info->otp_patch_version) {
+		r =3D fdp_nci_patch_otp(ndev);
+		if (r)
+			goto error;
+		patched =3D 1;
+	}
+
+	/* Update RAM */
+	if (info->ram_version < info->ram_patch_version) {
+		r =3D fdp_nci_patch_ram(ndev);
+		if (r)
+			goto error;
+		patched =3D 1;
+	}
+
+	/* Release the firmware buffers */
+	fdp_nci_release_firmware(ndev);
+
+	/* If a patch was applied the new version is checked */
+	if (patched) {
+		r =3D nci_core_init(ndev);
+		if (r)
+			goto error;
+
+		r =3D fdp_nci_get_versions(ndev);
+		if (r)
+			goto error;
+
+		if (info->otp_version !=3D info->otp_patch_version ||
+		    info->ram_version !=3D info->ram_patch_version) {
+			nfc_err(dev, "Firmware update failed");
+			r =3D -EINVAL;
+			goto error;
+		}
+	}
+
+	/*
+	 * We initialized the devices but the NFC subsystem expects
+	 * it to not be initialized.
+	 */
+	return nci_core_reset(ndev);
+
+error:
+	fdp_nci_release_firmware(ndev);
+	nfc_err(dev, "Setup error %d\n", r);
+	return r;
+}
+
+static int fdp_nci_post_setup(struct nci_dev *ndev)
+{
+	struct fdp_nci_info *info =3D nci_get_drvdata(ndev);
+	struct device *dev =3D &info->phy->i2c_dev->dev;
+	int r;
+
+	/* Check if the device has VSC */
+	if (info->fw_vsc_cfg && info->fw_vsc_cfg[0]) {
+
+		/* Set the vendor specific configuration */
+		r =3D fdp_nci_set_production_data(ndev, info->fw_vsc_cfg[3],
+						&info->fw_vsc_cfg[4]);
+		if (r) {
+			nfc_err(dev, "Vendor specific config set error %d\n",
+				r);
+			return r;
+		}
+	}
+
+	/* Set clock type and frequency */
+	r =3D fdp_nci_set_clock(ndev, info->clock_type, info->clock_freq);
+	if (r) {
+		nfc_err(dev, "Clock set error %d\n", r);
+		return r;
+	}
+
+	/*
+	 * In order to apply the VSC FDP needs a reset
+	 */
+	r =3D nci_core_reset(ndev);
+	if (r)
+		return r;
+
+	/**
+	 * The nci core was initialized when post setup was called
+	 * so we leave it like that
+	 */
+	return nci_core_init(ndev);
+}
+
+static int fdp_nci_core_reset_ntf_packet(struct nci_dev *ndev,
+					  struct sk_buff *skb)
+{
+	struct fdp_nci_info *info =3D nci_get_drvdata(ndev);
+	struct device *dev =3D &info->phy->i2c_dev->dev;
+
+	dev_dbg(dev, "%s\n", __func__);
+	info->setup_reset_ntf =3D 1;
+	wake_up(&info->setup_wq);
+
+	return 0;
+}
+
+static int fdp_nci_prop_patch_ntf_packet(struct nci_dev *ndev,
+					  struct sk_buff *skb)
+{
+	struct fdp_nci_info *info =3D nci_get_drvdata(ndev);
+	struct device *dev =3D &info->phy->i2c_dev->dev;
+
+	dev_dbg(dev, "%s\n", __func__);
+	info->setup_patch_ntf =3D 1;
+	info->setup_patch_status =3D skb->data[0];
+	wake_up(&info->setup_wq);
+
+	return 0;
+}
+
+static int fdp_nci_prop_patch_rsp_packet(struct nci_dev *ndev,
+					  struct sk_buff *skb)
+{
+	struct fdp_nci_info *info =3D nci_get_drvdata(ndev);
+	struct device *dev =3D &info->phy->i2c_dev->dev;
+	u8 status =3D skb->data[0];
+
+	dev_dbg(dev, "%s: status 0x%x\n", __func__, status);
+	nci_req_complete(ndev, status);
+
+	return 0;
+}
+
+static int fdp_nci_prop_set_production_data_rsp_packet(struct nci_dev =
*ndev,
+							struct sk_buff *skb)
+{
+	struct fdp_nci_info *info =3D nci_get_drvdata(ndev);
+	struct device *dev =3D &info->phy->i2c_dev->dev;
+	u8 status =3D skb->data[0];
+
+	dev_dbg(dev, "%s: status 0x%x\n", __func__, status);
+	nci_req_complete(ndev, status);
+
+	return 0;
+}
+
+static int fdp_nci_core_get_config_rsp_packet(struct nci_dev *ndev,
+						struct sk_buff *skb)
+{
+	struct fdp_nci_info *info =3D nci_get_drvdata(ndev);
+	struct device *dev =3D &info->phy->i2c_dev->dev;
+	struct nci_core_get_config_rsp *rsp =3D (void *) skb->data;
+	u8 i, *p;
+
+	if (rsp->status =3D=3D NCI_STATUS_OK) {
+
+		p =3D rsp->data;
+		for (i =3D 0; i < 4; i++) {
+
+			switch (*p++) {
+			case NCI_PARAM_ID_FW_RAM_VERSION:
+				p++;
+				info->ram_version =3D le32_to_cpup((__le32 *) p);
+				p +=3D 4;
+				break;
+			case NCI_PARAM_ID_FW_OTP_VERSION:
+				p++;
+				info->otp_version =3D le32_to_cpup((__le32 *) p);
+				p +=3D 4;
+				break;
+			case NCI_PARAM_ID_OTP_LIMITED_VERSION:
+				p++;
+				info->otp_version =3D le32_to_cpup((__le32 *) p);
+				p +=3D 4;
+				break;
+			case NCI_PARAM_ID_KEY_INDEX_ID:
+				p++;
+				info->key_index =3D *p++;
+			}
+		}
+	}
+
+	dev_dbg(dev, "OTP version %d\n", info->otp_version);
+	dev_dbg(dev, "RAM version %d\n", info->ram_version);
+	dev_dbg(dev, "key index %d\n", info->key_index);
+	dev_dbg(dev, "%s: status 0x%x\n", __func__, rsp->status);
+
+	nci_req_complete(ndev, rsp->status);
+
+	return 0;
+}
+
+static struct nci_driver_ops fdp_core_ops[] =3D {
+	{
+		.opcode =3D NCI_OP_CORE_GET_CONFIG_RSP,
+		.rsp =3D fdp_nci_core_get_config_rsp_packet,
+	},
+	{
+		.opcode =3D NCI_OP_CORE_RESET_NTF,
+		.ntf =3D fdp_nci_core_reset_ntf_packet,
+	},
+};
+
+static struct nci_driver_ops fdp_prop_ops[] =3D {
+	{
+		.opcode =3D nci_opcode_pack(NCI_GID_PROP, NCI_OP_PROP_PATCH_OID),
+		.rsp =3D fdp_nci_prop_patch_rsp_packet,
+		.ntf =3D fdp_nci_prop_patch_ntf_packet,
+	},
+	{
+		.opcode =3D nci_opcode_pack(NCI_GID_PROP,
+					  NCI_OP_PROP_SET_PDATA_OID),
+		.rsp =3D fdp_nci_prop_set_production_data_rsp_packet,
+	},
+};
+
+struct nci_ops nci_ops =3D {
+	.open =3D fdp_nci_open,
+	.close =3D fdp_nci_close,
+	.send =3D fdp_nci_send,
+	.setup =3D fdp_nci_setup,
+	.post_setup =3D fdp_nci_post_setup,
+	.prop_ops =3D fdp_prop_ops,
+	.n_prop_ops =3D ARRAY_SIZE(fdp_prop_ops),
+	.core_ops =3D fdp_core_ops,
+	.n_core_ops =3D ARRAY_SIZE(fdp_core_ops),
+};
+
+int fdp_nci_probe(struct fdp_i2c_phy *phy, struct nfc_phy_ops *phy_ops=
,
+			struct nci_dev **ndevp, int tx_headroom,
+			int tx_tailroom, u8 clock_type, u32 clock_freq,
+			u8 *fw_vsc_cfg)
+{
+	struct device *dev =3D &phy->i2c_dev->dev;
+	struct fdp_nci_info *info;
+	struct nci_dev *ndev;
+	u32 protocols;
+	int r;
+
+	info =3D kzalloc(sizeof(struct fdp_nci_info), GFP_KERNEL);
+	if (!info) {
+		r =3D -ENOMEM;
+		goto err_info_alloc;
+	}
+
+	info->phy =3D phy;
+	info->phy_ops =3D phy_ops;
+	info->clock_type =3D clock_type;
+	info->clock_freq =3D clock_freq;
+	info->fw_vsc_cfg =3D fw_vsc_cfg;
+
+	init_waitqueue_head(&info->setup_wq);
+
+	protocols =3D NFC_PROTO_JEWEL_MASK |
+		    NFC_PROTO_MIFARE_MASK |
+		    NFC_PROTO_FELICA_MASK |
+		    NFC_PROTO_ISO14443_MASK |
+		    NFC_PROTO_ISO14443_B_MASK |
+		    NFC_PROTO_NFC_DEP_MASK |
+		    NFC_PROTO_ISO15693_MASK;
+
+	ndev =3D nci_allocate_device(&nci_ops, protocols, tx_headroom,
+				   tx_tailroom);
+	if (!ndev) {
+		nfc_err(dev, "Cannot allocate nfc ndev\n");
+		r =3D -ENOMEM;
+		goto err_alloc_ndev;
+	}
+
+	r =3D nci_register_device(ndev);
+	if (r)
+		goto err_regdev;
+
+	*ndevp =3D ndev;
+	info->ndev =3D ndev;
+
+	nci_set_drvdata(ndev, info);
+
+	return 0;
+
+err_regdev:
+	nci_free_device(ndev);
+err_alloc_ndev:
+	kfree(info);
+err_info_alloc:
+	return r;
+}
+EXPORT_SYMBOL(fdp_nci_probe);
+
+void fdp_nci_remove(struct nci_dev *ndev)
+{
+	struct fdp_nci_info *info =3D nci_get_drvdata(ndev);
+	struct device *dev =3D &info->phy->i2c_dev->dev;
+
+	dev_dbg(dev, "%s\n", __func__);
+
+	nci_unregister_device(ndev);
+	nci_free_device(ndev);
+	kfree(info);
+}
+EXPORT_SYMBOL(fdp_nci_remove);
+
+MODULE_LICENSE("GPL");
+MODULE_DESCRIPTION("NFC NCI driver for Intel Fields Peak NFC controlle=
r");
+MODULE_AUTHOR("Robert Dolca <robert.dolca@intel.com>");
diff --git a/drivers/nfc/fdp/fdp.h b/drivers/nfc/fdp/fdp.h
new file mode 100644
index 0000000..0bd36c0
--- /dev/null
+++ b/drivers/nfc/fdp/fdp.h
@@ -0,0 +1,38 @@
+/* -------------------------------------------------------------------=
------
+ * Copyright (C) 2014-2016, Intel Corporation
+ *
+ *  This program is free software; you can redistribute it and/or modi=
fy
+ *  it under the terms of the GNU General Public License as published =
by
+ *  the Free Software Foundation; either version 2 of the License, or
+ *  (at your option) any later version.
+ *
+ *  This program is distributed in the hope that it will be useful,
+ *  but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ *  GNU General Public License for more details.
+ * -------------------------------------------------------------------=
------
+ */
+
+#ifndef __LOCAL_FDP_H_
+#define __LOCAL_FDP_H_
+
+#include <net/nfc/nci_core.h>
+#include <linux/gpio/consumer.h>
+
+struct fdp_i2c_phy {
+	struct i2c_client *i2c_dev;
+	struct gpio_desc *power_gpio;
+	struct nci_dev *ndev;
+
+	/* < 0 if i2c error occurred */
+	int hard_fault;
+	uint16_t next_read_size;
+};
+
+int fdp_nci_probe(struct fdp_i2c_phy *phy, struct nfc_phy_ops *phy_ops=
,
+		  struct nci_dev **ndev, int tx_headroom, int tx_tailroom,
+		  u8 clock_type, u32 clock_freq, u8 *fw_vsc_cfg);
+void fdp_nci_remove(struct nci_dev *ndev);
+int fdp_nci_recv_frame(struct nci_dev *ndev, struct sk_buff *skb);
+
+#endif /* __LOCAL_FDP_H_ */
diff --git a/drivers/nfc/fdp/i2c.c b/drivers/nfc/fdp/i2c.c
new file mode 100644
index 0000000..532db28
--- /dev/null
+++ b/drivers/nfc/fdp/i2c.c
@@ -0,0 +1,388 @@
+/* -------------------------------------------------------------------=
------
+ * Copyright (C) 2014-2016, Intel Corporation
+ *
+ *  This program is free software; you can redistribute it and/or modi=
fy
+ *  it under the terms of the GNU General Public License as published =
by
+ *  the Free Software Foundation; either version 2 of the License, or
+ *  (at your option) any later version.
+ *
+ *  This program is distributed in the hope that it will be useful,
+ *  but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ *  GNU General Public License for more details.
+ * -------------------------------------------------------------------=
------
+ */
+
+#include <linux/module.h>
+#include <linux/acpi.h>
+#include <linux/i2c.h>
+#include <linux/interrupt.h>
+#include <linux/nfc.h>
+#include <linux/delay.h>
+#include <linux/gpio/consumer.h>
+#include <net/nfc/nfc.h>
+#include <net/nfc/nci_core.h>
+
+#include "fdp.h"
+
+#define FDP_I2C_DRIVER_NAME	"fdp_nci_i2c"
+
+#define FDP_DP_POWER_GPIO_NAME	"power"
+#define FDP_DP_CLOCK_TYPE_NAME	"clock-type"
+#define FDP_DP_CLOCK_FREQ_NAME	"clock-freq"
+#define FDP_DP_FW_VSC_CFG_NAME	"fw-vsc-cfg"
+
+#define FDP_FRAME_HEADROOM	2
+#define FDP_FRAME_TAILROOM	1
+
+#define FDP_NCI_I2C_MIN_PAYLOAD	5
+#define FDP_NCI_I2C_MAX_PAYLOAD	261
+
+#define FDP_POWER_OFF		0
+#define FDP_POWER_ON		1
+
+#define fdp_nci_i2c_dump_skb(dev, prefix, skb)				\
+	print_hex_dump(KERN_DEBUG, prefix": ", DUMP_PREFIX_OFFSET,	\
+		       16, 1, (skb)->data, (skb)->len, 0)
+
+static void fdp_nci_i2c_reset(struct fdp_i2c_phy *phy)
+{
+	/* Reset RST/WakeUP for at least 100 micro-second */
+	gpiod_set_value_cansleep(phy->power_gpio, FDP_POWER_OFF);
+	usleep_range(1000, 4000);
+	gpiod_set_value_cansleep(phy->power_gpio, FDP_POWER_ON);
+	usleep_range(10000, 14000);
+}
+
+static int fdp_nci_i2c_enable(void *phy_id)
+{
+	struct fdp_i2c_phy *phy =3D phy_id;
+
+	dev_dbg(&phy->i2c_dev->dev, "%s\n", __func__);
+	fdp_nci_i2c_reset(phy);
+
+	return 0;
+}
+
+static void fdp_nci_i2c_disable(void *phy_id)
+{
+	struct fdp_i2c_phy *phy =3D phy_id;
+
+	dev_dbg(&phy->i2c_dev->dev, "%s\n", __func__);
+	fdp_nci_i2c_reset(phy);
+}
+
+static void fdp_nci_i2c_add_len_lrc(struct sk_buff *skb)
+{
+	u8 lrc =3D 0;
+	u16 len, i;
+
+	/* Add length header */
+	len =3D skb->len;
+	*skb_push(skb, 1) =3D len & 0xff;
+	*skb_push(skb, 1) =3D len >> 8;
+
+	/* Compute and add lrc */
+	for (i =3D 0; i < len + 2; i++)
+		lrc ^=3D skb->data[i];
+
+	*skb_put(skb, 1) =3D lrc;
+}
+
+static void fdp_nci_i2c_remove_len_lrc(struct sk_buff *skb)
+{
+	skb_pull(skb, FDP_FRAME_HEADROOM);
+	skb_trim(skb, skb->len - FDP_FRAME_TAILROOM);
+}
+
+static int fdp_nci_i2c_write(void *phy_id, struct sk_buff *skb)
+{
+	struct fdp_i2c_phy *phy =3D phy_id;
+	struct i2c_client *client =3D phy->i2c_dev;
+	int r;
+
+	if (phy->hard_fault !=3D 0)
+		return phy->hard_fault;
+
+	fdp_nci_i2c_add_len_lrc(skb);
+	fdp_nci_i2c_dump_skb(&client->dev, "fdp_wr", skb);
+
+	r =3D i2c_master_send(client, skb->data, skb->len);
+	if (r =3D=3D -EREMOTEIO) {  /* Retry, chip was in standby */
+		usleep_range(1000, 4000);
+		r =3D i2c_master_send(client, skb->data, skb->len);
+	}
+
+	if (r < 0 || r !=3D skb->len)
+		dev_dbg(&client->dev, "%s: error err=3D%d len=3D%d\n",
+			__func__, r, skb->len);
+
+	if (r >=3D 0) {
+		if (r !=3D skb->len) {
+			phy->hard_fault =3D r;
+			r =3D -EREMOTEIO;
+		} else {
+			r =3D 0;
+		}
+	}
+
+	fdp_nci_i2c_remove_len_lrc(skb);
+
+	return r;
+}
+
+static struct nfc_phy_ops i2c_phy_ops =3D {
+	.write =3D fdp_nci_i2c_write,
+	.enable =3D fdp_nci_i2c_enable,
+	.disable =3D fdp_nci_i2c_disable,
+};
+
+static int fdp_nci_i2c_read(struct fdp_i2c_phy *phy, struct sk_buff **=
skb)
+{
+	int r, len;
+	u8 tmp[FDP_NCI_I2C_MAX_PAYLOAD], lrc, k;
+	u16 i;
+	struct i2c_client *client =3D phy->i2c_dev;
+
+	*skb =3D NULL;
+
+	/* Read the length packet and the data packet */
+	for (k =3D 0; k < 2; k++) {
+
+		len =3D phy->next_read_size;
+
+		r =3D i2c_master_recv(client, tmp, len);
+		if (r !=3D len) {
+			dev_dbg(&client->dev, "%s: i2c recv err: %d\n",
+				__func__, r);
+			goto flush;
+		}
+
+		/* Check packet integruty */
+		for (lrc =3D i =3D 0; i < r; i++)
+			lrc ^=3D tmp[i];
+
+		/*
+		 * LRC check failed. This may due to transmission error or
+		 * desynchronization between driver and FDP. Drop the paquet
+		 * and force resynchronization
+		 */
+		if (lrc) {
+			dev_dbg(&client->dev, "%s: corrupted packet\n",
+				__func__);
+			phy->next_read_size =3D 5;
+			goto flush;
+		}
+
+		/* Packet that contains a length */
+		if (tmp[0] =3D=3D 0 && tmp[1] =3D=3D 0) {
+			phy->next_read_size =3D (tmp[2] << 8) + tmp[3] + 3;
+		} else {
+			phy->next_read_size =3D FDP_NCI_I2C_MIN_PAYLOAD;
+
+			*skb =3D alloc_skb(len, GFP_KERNEL);
+			if (*skb =3D=3D NULL) {
+				r =3D -ENOMEM;
+				goto flush;
+			}
+
+			memcpy(skb_put(*skb, len), tmp, len);
+			fdp_nci_i2c_dump_skb(&client->dev, "fdp_rd", *skb);
+
+			fdp_nci_i2c_remove_len_lrc(*skb);
+		}
+	}
+
+	return 0;
+
+flush:
+	/* Flush the remaining data */
+	if (i2c_master_recv(client, tmp, sizeof(tmp)) < 0)
+		r =3D -EREMOTEIO;
+
+	return r;
+}
+
+static irqreturn_t fdp_nci_i2c_irq_thread_fn(int irq, void *phy_id)
+{
+	struct fdp_i2c_phy *phy =3D phy_id;
+	struct i2c_client *client;
+	struct sk_buff *skb;
+	int r;
+
+	client =3D phy->i2c_dev;
+	dev_dbg(&client->dev, "%s\n", __func__);
+
+	if (!phy || irq !=3D phy->i2c_dev->irq) {
+		WARN_ON_ONCE(1);
+		return IRQ_NONE;
+	}
+
+	r =3D fdp_nci_i2c_read(phy, &skb);
+
+	if (r =3D=3D -EREMOTEIO)
+		return IRQ_HANDLED;
+	else if (r =3D=3D -ENOMEM || r =3D=3D -EBADMSG)
+		return IRQ_HANDLED;
+
+	if (skb !=3D NULL)
+		fdp_nci_recv_frame(phy->ndev, skb);
+
+	return IRQ_HANDLED;
+}
+
+static void fdp_nci_i2c_read_device_properties(struct device *dev,
+					       u8 *clock_type, u32 *clock_freq,
+					       u8 **fw_vsc_cfg)
+{
+	int r;
+	u8 len;
+
+	r =3D device_property_read_u8(dev, FDP_DP_CLOCK_TYPE_NAME, clock_type=
);
+	if (r) {
+		dev_dbg(dev, "Using default clock type");
+		*clock_type =3D 0;
+	}
+
+	r =3D device_property_read_u32(dev, FDP_DP_CLOCK_FREQ_NAME, clock_fre=
q);
+	if (r) {
+		dev_dbg(dev, "Using default clock frequency\n");
+		*clock_freq =3D 26000;
+	}
+
+	if (device_property_present(dev, FDP_DP_FW_VSC_CFG_NAME)) {
+		r =3D device_property_read_u8(dev, FDP_DP_FW_VSC_CFG_NAME,
+					    &len);
+
+		if (r || len <=3D 0)
+			goto vsc_read_err;
+
+		/* Add 1 to the length to inclue the length byte itself */
+		len++;
+
+		*fw_vsc_cfg =3D devm_kmalloc(dev,
+					   len * sizeof(**fw_vsc_cfg),
+					   GFP_KERNEL);
+
+		r =3D device_property_read_u8_array(dev, FDP_DP_FW_VSC_CFG_NAME,
+						  *fw_vsc_cfg, len);
+
+		if (r) {
+			devm_kfree(dev, fw_vsc_cfg);
+			goto vsc_read_err;
+		}
+	} else {
+vsc_read_err:
+		dev_dbg(dev, "FW vendor specific commands not present\n");
+		*fw_vsc_cfg =3D NULL;
+	}
+
+	dev_dbg(dev, "Clock type: %d, clock frequency: %d, VSC: %s",
+		*clock_type, *clock_freq, *fw_vsc_cfg !=3D NULL ? "yes" : "no");
+}
+
+static int fdp_nci_i2c_probe(struct i2c_client *client,
+			     const struct i2c_device_id *id)
+{
+	struct fdp_i2c_phy *phy;
+	struct device *dev =3D &client->dev;
+	u8 *fw_vsc_cfg;
+	u8 clock_type;
+	u32 clock_freq;
+	int r =3D 0;
+
+	dev_dbg(dev, "%s\n", __func__);
+
+	if (!i2c_check_functionality(client->adapter, I2C_FUNC_I2C)) {
+		nfc_err(dev, "No I2C_FUNC_I2C support\n");
+		return -ENODEV;
+	}
+
+	phy =3D devm_kzalloc(dev, sizeof(struct fdp_i2c_phy),
+			   GFP_KERNEL);
+	if (!phy)
+		return -ENOMEM;
+
+	phy->i2c_dev =3D client;
+	phy->next_read_size =3D FDP_NCI_I2C_MIN_PAYLOAD;
+	i2c_set_clientdata(client, phy);
+
+	/* Checking if we have an irq */
+	if (client->irq <=3D 0) {
+		dev_err(dev, "IRQ not present\n");
+		return -ENODEV;
+	}
+
+	r =3D request_threaded_irq(client->irq, NULL, fdp_nci_i2c_irq_thread_=
fn,
+				 IRQF_TRIGGER_RISING | IRQF_ONESHOT,
+				 FDP_I2C_DRIVER_NAME, phy);
+
+	if (r < 0) {
+		nfc_err(&client->dev, "Unable to register IRQ handler\n");
+		return r;
+	}
+
+	/* Requesting the power gpio */
+	phy->power_gpio =3D devm_gpiod_get(dev, FDP_DP_POWER_GPIO_NAME,
+					 GPIOD_OUT_LOW);
+
+	if (IS_ERR(phy->power_gpio)) {
+		nfc_err(dev, "Power GPIO request failed\n");
+		return PTR_ERR(phy->power_gpio);
+	}
+
+	/* read device properties to get the clock and production settings */
+	fdp_nci_i2c_read_device_properties(dev, &clock_type, &clock_freq,
+					   &fw_vsc_cfg);
+
+	/* Call the NFC specific probe function */
+	r =3D fdp_nci_probe(phy, &i2c_phy_ops, &phy->ndev,
+			  FDP_FRAME_HEADROOM, FDP_FRAME_TAILROOM,
+			  clock_type, clock_freq, fw_vsc_cfg);
+	if (r < 0) {
+		nfc_err(dev, "NCI probing error\n");
+		return r;
+	}
+
+	dev_dbg(dev, "I2C driver loaded\n");
+	return 0;
+}
+
+static int fdp_nci_i2c_remove(struct i2c_client *client)
+{
+	struct fdp_i2c_phy *phy =3D i2c_get_clientdata(client);
+
+	dev_dbg(&client->dev, "%s\n", __func__);
+
+	fdp_nci_remove(phy->ndev);
+	fdp_nci_i2c_disable(phy);
+
+	return 0;
+}
+
+static struct i2c_device_id fdp_nci_i2c_id_table[] =3D {
+	{"int339a", 0},
+	{}
+};
+MODULE_DEVICE_TABLE(i2c, fdp_nci_i2c_id_table);
+
+static const struct acpi_device_id fdp_nci_i2c_acpi_match[] =3D {
+	{"INT339A", 0},
+	{}
+};
+MODULE_DEVICE_TABLE(acpi, fdp_nci_i2c_acpi_match);
+
+static struct i2c_driver fdp_nci_i2c_driver =3D {
+	.driver =3D {
+		   .name =3D FDP_I2C_DRIVER_NAME,
+		   .acpi_match_table =3D ACPI_PTR(fdp_nci_i2c_acpi_match),
+		  },
+	.id_table =3D fdp_nci_i2c_id_table,
+	.probe =3D fdp_nci_i2c_probe,
+	.remove =3D fdp_nci_i2c_remove,
+};
+module_i2c_driver(fdp_nci_i2c_driver);
+
+MODULE_LICENSE("GPL");
+MODULE_DESCRIPTION("I2C driver for Intel Fields Peak NFC controller");
+MODULE_AUTHOR("Robert Dolca <robert.dolca@intel.com>");
--=20
1.9.1
