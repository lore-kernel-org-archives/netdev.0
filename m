From: Robert Dolca <robert.dolca@intel.com>
Subject: [PATCH 8/8] NFC: Add Intel FieldsPeak NFC solution driver
Date: Tue, 24 Feb 2015 12:01:52 +0200
Message-ID: <1424772112-27399-9-git-send-email-robert.dolca@intel.com>
References: <1424772112-27399-1-git-send-email-robert.dolca@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Robert Dolca <robert.dolca@intel.com>
To: linux-nfc@lists.01.org,
	Lauro Ramos Venancio <lauro.venancio@openbossa.org>,
	Aloisio Almeida Jr <aloisio.almeida@openbossa.org>,
	Samuel Ortiz <sameo@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1424772112-27399-1-git-send-email-robert.dolca@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The device can be enumerated using ACPI using the id INT339A.
The 1st GPIO is the IRQ and the 2nd is the RESET pin.
I can be also enumerated using platform init.

Signed-off-by: Robert Dolca <robert.dolca@intel.com>
---
 drivers/nfc/Kconfig               |   1 +
 drivers/nfc/fdp/Kconfig           |  22 ++
 drivers/nfc/fdp/Makefile          |  10 +
 drivers/nfc/fdp/cmd.c             | 196 +++++++++++++++
 drivers/nfc/fdp/core.c            | 503 ++++++++++++++++++++++++++++++++++++++
 drivers/nfc/fdp/fdp.h             | 115 +++++++++
 drivers/nfc/fdp/i2c.c             | 454 ++++++++++++++++++++++++++++++++++
 drivers/nfc/fdp/ntf.c             |  68 ++++++
 drivers/nfc/fdp/rsp.c             | 117 +++++++++
 include/linux/platform_data/fdp.h |  33 +++
 10 files changed, 1519 insertions(+)
 create mode 100644 drivers/nfc/fdp/Kconfig
 create mode 100644 drivers/nfc/fdp/Makefile
 create mode 100644 drivers/nfc/fdp/cmd.c
 create mode 100644 drivers/nfc/fdp/core.c
 create mode 100644 drivers/nfc/fdp/fdp.h
 create mode 100644 drivers/nfc/fdp/i2c.c
 create mode 100644 drivers/nfc/fdp/ntf.c
 create mode 100644 drivers/nfc/fdp/rsp.c
 create mode 100644 include/linux/platform_data/fdp.h

diff --git a/drivers/nfc/Kconfig b/drivers/nfc/Kconfig
index 6ee2e8d..302fe59 100644
--- a/drivers/nfc/Kconfig
+++ b/drivers/nfc/Kconfig
@@ -68,6 +68,7 @@ config NFC_PORT100
 
 	  If unsure, say N.
 
+source "drivers/nfc/fdp/Kconfig"
 source "drivers/nfc/pn544/Kconfig"
 source "drivers/nfc/microread/Kconfig"
 source "drivers/nfc/nfcmrvl/Kconfig"
diff --git a/drivers/nfc/fdp/Kconfig b/drivers/nfc/fdp/Kconfig
new file mode 100644
index 0000000..130a235
--- /dev/null
+++ b/drivers/nfc/fdp/Kconfig
@@ -0,0 +1,22 @@
+config NFC_FDP
+	tristate "Intel FDP NFC driver"
+	depends on NFC_NCI
+	select CRC_CCITT
+	default n
+	---help---
+	  Intel FDP core driver.
+	  This is a driver based on the NCI NFC kernel layers.
+
+	  To compile this driver as a module, choose m here. The module will
+	  be called pn547.
+	  Say N if unsure.
+
+config NFC_FDP_I2C
+	tristate "NFC FDP i2c support"
+	depends on NFC_FDP && I2C
+	---help---
+	  This module adds support for the Intel FDP i2c interface.
+	  Select this if your platform is using the i2c bus.
+
+	  If you choose to build a module, it'll be called fdp_i2c.
+	  Say N if unsure.
diff --git a/drivers/nfc/fdp/Makefile b/drivers/nfc/fdp/Makefile
new file mode 100644
index 0000000..caad636
--- /dev/null
+++ b/drivers/nfc/fdp/Makefile
@@ -0,0 +1,10 @@
+#
+# Makefile for FDP NCI based NFC driver
+#
+
+obj-$(CONFIG_NFC_FDP)     += fdp.o
+obj-$(CONFIG_NFC_FDP_I2C) += fdp_i2c.o
+
+fdp-objs = core.o cmd.o ntf.o rsp.o
+fdp_i2c-objs  = i2c.o
+
diff --git a/drivers/nfc/fdp/cmd.c b/drivers/nfc/fdp/cmd.c
new file mode 100644
index 0000000..1b78602
--- /dev/null
+++ b/drivers/nfc/fdp/cmd.c
@@ -0,0 +1,196 @@
+/* -------------------------------------------------------------------------
+ * Copyright (C) 2014-2016, Intel Corporation
+ *
+ *  This program is free software; you can redistribute it and/or modify
+ *  it under the terms of the GNU General Public License as published by
+ *  the Free Software Foundation; either version 2 of the License, or
+ *  (at your option) any later version.
+ *
+ *  This program is distributed in the hope that it will be useful,
+ *  but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ *  GNU General Public License for more details.
+ * ------------------------------------------------------------------------- */
+
+#include <linux/module.h>
+#include <linux/nfc.h>
+#include <linux/i2c.h>
+#include <linux/firmware.h>
+#include <net/nfc/nci_core.h>
+
+#include "fdp.h"
+
+#define NCI_OP_PROP_PATCH_CMD		     nci_opcode_pack(NCI_GID_PROP, 0x08)
+#define NCI_OP_PROP_SET_PRODUCTION_DATA_CMD  nci_opcode_pack(NCI_GID_PROP, 0x23)
+#define NCI_OP_CORE_GET_CONFIG_CMD           nci_opcode_pack(NCI_GID_CORE, 0x03)
+static u8 nci_core_get_config_otp_ram_version[5] = {
+	0x04,
+	NCI_PARAM_ID_FW_RAM_VERSION,
+	NCI_PARAM_ID_FW_OTP_VERSION,
+	NCI_PARAM_ID_OTP_LIMITED_VERSION,
+	NCI_PARAM_ID_KEY_INDEX_ID
+};
+
+#define NCI_GET_VERSION_TIMEOUT		8000
+#define NCI_PATCH_REQUEST_TIMEOUT	8000
+
+struct production_data {
+	u8 len;
+	char *data;
+};
+
+static void fdp_nci_get_version_req(struct nci_dev *ndev, unsigned long opt)
+{
+	fdp_nci_send_cmd(ndev, NCI_OP_CORE_GET_CONFIG_CMD,
+			 sizeof(nci_core_get_config_otp_ram_version),
+			 &nci_core_get_config_otp_ram_version);
+}
+
+static void fdp_nci_set_production_data_req(struct nci_dev *ndev,
+					    unsigned long opt)
+{
+	struct production_data *pd = (struct production_data *)opt;
+
+	fdp_nci_send_cmd(ndev, NCI_OP_PROP_SET_PRODUCTION_DATA_CMD,
+			 pd->len, pd->data);
+}
+
+static void fdp_nci_patch_req(struct nci_dev *ndev, unsigned long opt)
+{
+	u8 type = (u8) opt;
+
+	fdp_nci_send_cmd(ndev, NCI_OP_PROP_PATCH_CMD, sizeof(type), &type);
+}
+
+int fdp_nci_create_conn(struct nci_dev *ndev)
+{
+	struct fdp_nci_info *info = nci_get_drvdata(ndev);
+	struct core_conn_create_dest_spec_params param;
+
+	param.type = 0xA0;
+	param.length = 0x00;
+
+	return nci_core_conn_create(info->ndev, 0xC2, 1, sizeof(param), &param,
+				    &info->conn_id);
+}
+
+int fdp_nci_close_conn(struct nci_dev *ndev)
+{
+	struct fdp_nci_info *info = nci_get_drvdata(ndev);
+
+	return nci_core_conn_close(info->ndev, info->conn_id);
+}
+
+int fdp_nci_get_versions(struct nci_dev *ndev)
+{
+	return nci_request_driver(ndev, fdp_nci_get_version_req, 0,
+				  msecs_to_jiffies(NCI_GET_VERSION_TIMEOUT));
+}
+
+int fdp_nci_patch_start(struct nci_dev *ndev, u8 type)
+{
+	return nci_request_driver(ndev, fdp_nci_patch_req, (unsigned long) type,
+				  msecs_to_jiffies(NCI_PATCH_REQUEST_TIMEOUT));
+}
+
+int fdp_nci_patch_end(struct nci_dev *ndev)
+{
+	return nci_request_driver(ndev, fdp_nci_patch_req, NCI_PATCH_TYPE_EOT,
+				  msecs_to_jiffies(NCI_PATCH_REQUEST_TIMEOUT));
+}
+
+int fdp_nci_set_production_data(struct nci_dev *ndev, u8 len, char *data)
+{
+	struct production_data pd;
+
+	pd.len = len;
+	pd.data = data;
+
+	return nci_request_driver(ndev, fdp_nci_set_production_data_req,
+				  (unsigned long) &pd,
+				  msecs_to_jiffies(NCI_PATCH_REQUEST_TIMEOUT));
+}
+
+int fdp_nci_set_clock(struct nci_dev *ndev, u8 clock_type, u32 clock_freq)
+{
+	u32 fc = 13560;
+	u32 nd, num, delta;
+	char data[9];
+
+	nd = (24 * fc) / clock_freq;
+	delta = 24 * fc - nd * clock_freq;
+	num = (32768 * delta) / clock_freq;
+
+	data[0] = 0x00;
+	data[1] = 0x00;
+	data[2] = 0x00;
+
+	data[3] = 0x10;
+	data[4] = 0x04;
+	data[5] = num & 0xFF;
+	data[6] = (num >> 8) & 0xff;
+	data[7] = nd;
+	data[8] = clock_type;
+
+	return fdp_nci_set_production_data(ndev, 9, data);
+}
+
+static void fdp_nci_send_patch_cb(struct nci_dev *ndev)
+{
+	struct fdp_nci_info *info = nci_get_drvdata(ndev);
+
+	info->setup_patch_sent = 1;
+	wake_up(&info->setup_wq);
+}
+
+int fdp_nci_send_patch(struct nci_dev *ndev, u8 type)
+{
+	struct fdp_nci_info *info = nci_get_drvdata(ndev);
+	const struct firmware *fw;
+	struct sk_buff *skb;
+	unsigned long len;
+	u8 max_size, payload_size;
+	int rc = 0;
+
+	if ((type == NCI_PATCH_TYPE_OTP && !info->otp_patch) ||
+	    (type == NCI_PATCH_TYPE_RAM && !info->ram_patch))
+		return -EINVAL;
+
+	if (type == NCI_PATCH_TYPE_OTP)
+		fw = info->otp_patch;
+	else
+		fw = info->ram_patch;
+
+	max_size = nci_conn_max_data_pkt_payload_size(ndev, info->conn_id);
+	if (!max_size)
+		return -EINVAL;
+
+	len = fw->size;
+
+	fdp_nci_set_data_pkt_counter(ndev, fdp_nci_send_patch_cb,
+				     DIV_ROUND_UP(fw->size, max_size));
+
+	while (len) {
+
+		payload_size = min_t(unsigned long, (unsigned long) max_size,
+				     len);
+
+		skb = nci_skb_alloc(ndev, (NCI_CTRL_HDR_SIZE + payload_size),
+				    GFP_KERNEL);
+		skb_reserve(skb, NCI_CTRL_HDR_SIZE);
+
+		memcpy(skb_put(skb, payload_size), fw->data + (fw->size - len),
+		       payload_size);
+
+		rc = nci_send_data(ndev, info->conn_id, skb);
+
+		if (rc) {
+			fdp_nci_set_data_pkt_counter(ndev, NULL, 0);
+			return rc;
+		}
+
+		len -= payload_size;
+	}
+
+	return rc;
+}
diff --git a/drivers/nfc/fdp/core.c b/drivers/nfc/fdp/core.c
new file mode 100644
index 0000000..ca0a7cb
--- /dev/null
+++ b/drivers/nfc/fdp/core.c
@@ -0,0 +1,503 @@
+/* -------------------------------------------------------------------------
+ * Copyright (C) 2014-2016, Intel Corporation
+ *
+ *  This program is free software; you can redistribute it and/or modify
+ *  it under the terms of the GNU General Public License as published by
+ *  the Free Software Foundation; either version 2 of the License, or
+ *  (at your option) any later version.
+ *
+ *  This program is distributed in the hope that it will be useful,
+ *  but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ *  GNU General Public License for more details.
+ * ------------------------------------------------------------------------- */
+
+#include <linux/module.h>
+#include <linux/nfc.h>
+#include <linux/i2c.h>
+#include <linux/delay.h>
+#include <net/nfc/nci_core.h>
+
+#include "fdp.h"
+
+#define FDP_OTP_PATCH_NAME "otp.bin"
+#define FDP_RAM_PATCH_NAME "ram.bin"
+#define FDP_FW_HEADER_SIZE 576
+
+int fdp_nci_open(struct nci_dev *ndev)
+{
+	int r;
+	struct fdp_nci_info *info;
+
+	info = nci_get_drvdata(ndev);
+	pr_debug("%s\n", __func__);
+
+	mutex_lock(&info->lock);
+
+	skb_queue_purge(&info->rx_q);
+	r = info->phy_ops->enable(info->phy);
+	if (r == 0)
+		info->state = FDP_ST_RESET;
+
+	mutex_unlock(&info->lock);
+	return r;
+}
+
+int fdp_nci_close(struct nci_dev *ndev)
+{
+	struct fdp_nci_info *info = nci_get_drvdata(ndev);
+
+	pr_debug("%s\n", __func__);
+	skb_queue_purge(&info->rx_q);
+
+	return 0;
+}
+
+int fdp_nci_send(struct nci_dev *ndev, struct sk_buff *skb)
+{
+	struct fdp_nci_info *info = nci_get_drvdata(ndev);
+
+	pr_debug("%s\n", __func__);
+
+	if (atomic_dec_and_test(&info->data_pkt_counter))
+		info->data_pkt_counter_cb(ndev);
+
+	return info->phy_ops->write(info->phy, skb);
+}
+
+void fdp_nci_intercept_inc(struct nci_dev *ndev)
+{
+	struct fdp_nci_info *info = nci_get_drvdata(ndev);
+
+	pr_info("FDP NCI intercept INC\n");
+	atomic_inc(&info->intercept);
+}
+
+void fdp_nci_intercept_dec(struct nci_dev *ndev)
+{
+	struct fdp_nci_info *info = nci_get_drvdata(ndev);
+
+	pr_info("FDP NCI intercept DEC\n");
+	atomic_dec(&info->intercept);
+}
+
+void fdp_nci_intercept_add(struct nci_dev *ndev, int count)
+{
+	struct fdp_nci_info *info = nci_get_drvdata(ndev);
+
+	pr_info("FDP NCI intercept ADD %d\n", count);
+	atomic_add(count, &info->intercept);
+}
+
+void fdp_nci_intercept_disable(struct nci_dev *ndev)
+{
+	struct fdp_nci_info *info = nci_get_drvdata(ndev);
+
+	pr_info("FDP NCI intercept disabled\n");
+	atomic_set(&info->intercept, 0);
+}
+
+void fdp_nci_set_data_pkt_counter(struct nci_dev *ndev,
+				  void (*cb)(struct nci_dev *ndev), int count)
+{
+	struct fdp_nci_info *info = nci_get_drvdata(ndev);
+
+	pr_info("FDP NCI data pkt counter %d\n", count);
+	atomic_set(&info->data_pkt_counter, count);
+	info->data_pkt_counter_cb = cb;
+}
+
+int fdp_nci_recv_frame(struct nci_dev *ndev, struct sk_buff *skb)
+{
+	struct fdp_nci_info *info = nci_get_drvdata(ndev);
+
+	pr_debug("%s\n", __func__);
+
+	if (atomic_read(&info->intercept)) {
+		skb_queue_tail(&info->rx_q, skb);
+		schedule_work(&info->rx_work);
+		return 0;
+	}
+
+	return nci_recv_frame(ndev, skb);
+}
+EXPORT_SYMBOL(fdp_nci_recv_frame);
+
+void fdp_nci_rx_work(struct work_struct *work)
+{
+	struct sk_buff *skb;
+	struct fdp_nci_info *info = container_of(work, struct fdp_nci_info,
+						 rx_work);
+	struct nci_dev *ndev = info->ndev;
+	int r;
+
+	while ((skb = skb_dequeue(&info->rx_q))) {
+
+		switch (nci_mt(skb->data)) {
+		case NCI_MT_RSP_PKT:
+			r = fdp_nci_rsp_packet(ndev, skb);
+			break;
+		case NCI_MT_NTF_PKT:
+			r = fdp_nci_ntf_packet(ndev, skb);
+			break;
+		default:
+			r = -EINVAL;
+		}
+
+		/*
+		 * Packet received. Disabling intercept
+		 * It should be reenabled if still needed
+		 */
+		if (!r)
+			fdp_nci_intercept_dec(ndev);
+
+		kfree_skb(skb);
+	}
+}
+
+int fdp_nci_send_cmd(struct nci_dev *ndev, u16 opcode, u8 plen,
+		     void *payload)
+{
+	fdp_nci_intercept_inc(ndev);
+	return nci_send_cmd(ndev, opcode, plen, payload);
+}
+
+int fdp_nci_request_firmware(struct nci_dev *ndev)
+{
+	struct fdp_nci_info *info = nci_get_drvdata(ndev);
+	struct device *dev = &info->phy->i2c_dev->dev;
+	u8 *data;
+	int r;
+
+	r = request_firmware(&info->otp_patch, FDP_OTP_PATCH_NAME, dev);
+	if (r < 0) {
+		pr_info("FDP OTP patch request error\n");
+		goto error;
+	}
+
+	r = request_firmware(&info->ram_patch, FDP_RAM_PATCH_NAME, dev);
+	if (r < 0) {
+		pr_info("FDP RAM patch request error\n");
+		goto release_otp_patch;
+	}
+
+	data = (u8 *) info->otp_patch->data;
+	info->otp_patch_version =
+		data[FDP_FW_HEADER_SIZE] |
+		(data[FDP_FW_HEADER_SIZE + 1] << 8) |
+		(data[FDP_FW_HEADER_SIZE+2] << 16) |
+		(data[FDP_FW_HEADER_SIZE+3] << 24);
+
+	data = (u8 *) info->ram_patch->data;
+	info->ram_patch_version =
+		data[FDP_FW_HEADER_SIZE] |
+		(data[FDP_FW_HEADER_SIZE + 1] << 8) |
+		(data[FDP_FW_HEADER_SIZE + 2] << 16) |
+		(data[FDP_FW_HEADER_SIZE + 3] << 24);
+
+	pr_info("FDP OTP patch version: %d, size: %d\n",
+		 info->otp_patch_version, (int) info->otp_patch->size);
+	pr_info("FDP RAM patch version: %d, size: %d\n",
+		 info->ram_patch_version, (int) info->ram_patch->size);
+
+	return 0;
+
+release_otp_patch:
+	release_firmware(info->otp_patch);
+error:
+	return r;
+}
+
+int fdp_nci_setup(struct nci_dev *ndev)
+{
+	/* Format: total length followed by an NCI packet */
+	struct fdp_nci_info *info = nci_get_drvdata(ndev);
+	char fdp_post_fw_vsc_cfg[] = {  0x1A, 0x2F, 0x23, 0x17,
+					0x00, 0x00, 0x00,
+					0x00, 0x04, 0x04, 0x2B, 0x20, 0xFF,
+					0x09, 0x07, 0xFF, 0xFF, 0xFF, 0xFF,
+					0x02, 0xFF, 0xFF,
+					0x08, 0x03, 0x00, 0xFF, 0xFF };
+	int r;
+	u8 patched = 0;
+
+	pr_debug("%s\n", __func__);
+
+	r = nci_init(ndev);
+	if (r)
+		goto error;
+
+	/* Get RAM and OTP version */
+	r = fdp_nci_get_versions(ndev);
+	if (r)
+		goto error;
+
+	/* Load firmware from disk */
+	r = fdp_nci_request_firmware(ndev);
+	if (r)
+		goto error;
+
+	/* Update OTP */
+	if (info->otp_version < info->otp_patch_version) {
+
+		info->setup_patch_sent = 0;
+		info->setup_reset_ntf = 0;
+		info->setup_patch_ntf = 0;
+
+		/* Patch init request */
+		r = fdp_nci_patch_start(ndev, NCI_PATCH_TYPE_OTP);
+		if (r)
+			goto error;
+
+		/* Patch data connection creation */
+		r = fdp_nci_create_conn(ndev);
+		if (r)
+			goto error;
+
+		/* Send the patch over the data connection */
+		r = fdp_nci_send_patch(ndev, NCI_PATCH_TYPE_OTP);
+		if (r)
+			goto error;
+
+		/* Wait for all the packets to be send over i2c */
+		wait_event_interruptible(info->setup_wq,
+					 info->setup_patch_sent == 1);
+
+		/* Close the data connection */
+		r = fdp_nci_close_conn(ndev);
+		if (r)
+			goto error;
+
+		/*
+		 * After we send the patch finish message we expect two
+		 * notifications: NCI_OP_PROP_PATCH_NTF,
+		 * NCI_OP_CORE_RESET_NTF
+		 */
+		fdp_nci_intercept_add(ndev, 2);
+
+		/* Patch finish message */
+		r = fdp_nci_patch_end(ndev);
+		if (r) {
+			pr_err("FDP OTP patch error %d\n", r);
+			r = -EINVAL;
+			goto error;
+		}
+
+		/* If the patch notification didn't arrive yet, wait for it */
+		wait_event_interruptible(info->setup_wq, info->setup_patch_ntf);
+
+		/* Check if the patching was successful */
+		r = info->setup_patch_status;
+		if (r) {
+			pr_err("FDP OTP patch error %d\n", r);
+			r = -EINVAL;
+			goto error;
+		}
+
+		/*
+		 * We need to wait for the reset notification before we
+		 * can continue
+		 */
+		wait_event_interruptible(info->setup_wq, info->setup_reset_ntf);
+
+		patched = 1;
+	}
+
+	/* Update RAM */
+	if (info->ram_version < info->ram_patch_version) {
+
+		info->setup_patch_sent = 0;
+		info->setup_reset_ntf = 0;
+		info->setup_patch_ntf = 0;
+
+		/* Patch init request */
+		r = fdp_nci_patch_start(ndev, NCI_PATCH_TYPE_RAM);
+		if (r)
+			goto error;
+
+		/* Patch data connection creation */
+		r = fdp_nci_create_conn(ndev);
+		if (r)
+			goto error;
+
+		/* Send the patch over the data connection */
+		r = fdp_nci_send_patch(ndev, NCI_PATCH_TYPE_RAM);
+		if (r)
+			goto error;
+
+		/* Wait for all the packets to be send over i2c */
+		wait_event_interruptible(info->setup_wq,
+					 info->setup_patch_sent == 1);
+
+		/* Close the data connection */
+		r = fdp_nci_close_conn(ndev);
+		if (r)
+			goto error;
+
+		/*
+		 * After we send the patch finish message we expect two
+		 * notifications: NCI_OP_PROP_PATCH_NTF,
+		 * NCI_OP_CORE_RESET_NTF
+		 */
+		fdp_nci_intercept_add(ndev, 2);
+
+		/* Patch finish message */
+		if (fdp_nci_patch_end(ndev)) {
+			r = -EINVAL;
+			goto error;
+		}
+
+		/* If the patch notification didn't arrive yet, wait for it*/
+		wait_event_interruptible(info->setup_wq, info->setup_patch_ntf);
+
+		/* Check if the patching was successful */
+		r = info->setup_patch_status;
+		if (r) {
+			pr_err("FDP RAM patch error %d\n", r);
+			r = -EINVAL;
+			goto error;
+		}
+
+		/*
+		 * We need to wait for the reset notification before we
+		 * can continue
+		 */
+		wait_event_interruptible(info->setup_wq, info->setup_reset_ntf);
+
+		patched = 1;
+	}
+
+	/* If a patch was applied the new version is checked */
+	if (patched) {
+		r = nci_init(ndev);
+		if (r)
+			goto error;
+
+		r = fdp_nci_get_versions(ndev);
+		if (r)
+			goto error;
+
+		if (info->otp_version != info->otp_patch_version ||
+		    info->ram_version != info->ram_patch_version) {
+			pr_err("FRP firmware update failed");
+			r = -EINVAL;
+		}
+	}
+
+	/* Check if the device has VSC */
+	if (fdp_post_fw_vsc_cfg[0]) {
+		/* Set the vendor specific configuration */
+		r = fdp_nci_set_production_data(ndev, fdp_post_fw_vsc_cfg[3],
+						&fdp_post_fw_vsc_cfg[4]);
+		if (r)
+			goto error;
+	}
+
+	/* Set clock type and frequency */
+	r = fdp_nci_set_clock(ndev, 0, 26000);
+	if (r)
+		goto error;
+
+	/*
+	 * We initialized the devices but thA NFC subsystem
+	 * expects it to not be initialized. Also in order to
+	 * apply the VSC FDP needs a reset
+	 */
+	r = nci_reset(ndev);
+	if (r)
+		goto error;
+
+	pr_info("FDP Setup done\n");
+
+	return 0;
+
+error:
+	fdp_nci_intercept_disable(ndev);
+	pr_info("FDP Setup error %d\n", r);
+	return r;
+}
+
+struct nci_ops nci_ops = {
+	.open = fdp_nci_open,
+	.close = fdp_nci_close,
+	.send = fdp_nci_send,
+	.setup = fdp_nci_setup,
+};
+
+int fdp_nci_probe(struct fdp_i2c_phy *phy, struct nfc_phy_ops *phy_ops,
+			struct nci_dev **ndevp, int tx_headroom,
+			int tx_tailroom)
+{
+	struct fdp_nci_info *info;
+	struct nci_dev *ndev;
+	u32 protocols;
+	int r;
+
+	nfc_info(&phy->i2c_dev->dev, "%s\n", __func__);
+
+	info = kzalloc(sizeof(struct fdp_nci_info), GFP_KERNEL);
+	if (!info) {
+		r = -ENOMEM;
+		goto err_info_alloc;
+	}
+
+	info->phy = phy;
+	info->phy_ops = phy_ops;
+	info->state = FDP_ST_COLD;
+	mutex_init(&info->lock);
+
+	skb_queue_head_init(&info->rx_q);
+	INIT_WORK(&info->rx_work, fdp_nci_rx_work);
+
+	init_waitqueue_head(&info->setup_wq);
+
+	protocols = NFC_PROTO_JEWEL_MASK |
+		    NFC_PROTO_MIFARE_MASK |
+		    NFC_PROTO_FELICA_MASK |
+		    NFC_PROTO_ISO14443_MASK |
+		    NFC_PROTO_ISO14443_B_MASK |
+		    NFC_PROTO_NFC_DEP_MASK |
+		    NFC_PROTO_ISO15693_MASK;
+
+	ndev = nci_allocate_device(&nci_ops, protocols, tx_headroom,
+				   tx_tailroom);
+	if (!ndev) {
+		pr_err("Cannot allocate nfc ndev\n");
+		r = -ENOMEM;
+		goto err_alloc_ndev;
+	}
+
+	r = nci_register_device(ndev);
+	if (r)
+		goto err_regdev;
+
+	*ndevp = ndev;
+	info->ndev = ndev;
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
+	struct fdp_nci_info *info = nci_get_drvdata(ndev);
+
+	pr_info("%s\n", __func__);
+
+	nci_unregister_device(ndev);
+	nci_free_device(ndev);
+	kfree(info);
+}
+EXPORT_SYMBOL(fdp_nci_remove);
+
+MODULE_LICENSE("GPL");
+MODULE_DESCRIPTION(DRIVER_DESC);
diff --git a/drivers/nfc/fdp/fdp.h b/drivers/nfc/fdp/fdp.h
new file mode 100644
index 0000000..5c05a2c
--- /dev/null
+++ b/drivers/nfc/fdp/fdp.h
@@ -0,0 +1,115 @@
+/* -------------------------------------------------------------------------
+ * Copyright (C) 2014-2016, Intel Corporation
+ *
+ *  This program is free software; you can redistribute it and/or modify
+ *  it under the terms of the GNU General Public License as published by
+ *  the Free Software Foundation; either version 2 of the License, or
+ *  (at your option) any later version.
+ *
+ *  This program is distributed in the hope that it will be useful,
+ *  but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ *  GNU General Public License for more details.
+ * ------------------------------------------------------------------------- */
+
+#ifndef __LOCAL_FDP_H_
+#define __LOCAL_FDP_H_
+
+#include <net/nfc/nci_core.h>
+#include <linux/firmware.h>
+#include <linux/workqueue.h>
+
+#define DRIVER_DESC "NCI NFC driver for Intel FDP"
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
+
+struct fdp_i2c_phy {
+	struct i2c_client *i2c_dev;
+	struct nci_dev *ndev;
+
+	unsigned int gpio_en;
+	unsigned int gpio_irq;
+	unsigned int en_polarity;
+
+	int powered;
+
+	uint16_t next_read_size;
+
+	/*
+	 * < 0 if hardware error occurred (e.g. i2c err)
+	 * and prevents normal operation
+	 */
+	int hard_fault;
+};
+
+enum fdp_state {
+	FDP_ST_COLD,
+	FDP_ST_RESET,
+	FDP_ST_READY,
+	FDP_ST_ERROR,
+};
+
+struct fdp_nci_info {
+	struct nfc_phy_ops *phy_ops;
+	struct fdp_i2c_phy *phy;
+	struct nci_dev *ndev;
+
+	enum fdp_state state;
+	struct mutex lock;
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
+	u8 conn_id;
+	atomic_t intercept;
+	atomic_t data_pkt_counter;
+	void (*data_pkt_counter_cb)(struct nci_dev *ndev);
+	u8 setup_patch_sent;
+	u8 setup_patch_ntf;
+	u8 setup_patch_status;
+	u8 setup_reset_ntf;
+	wait_queue_head_t setup_wq;
+
+	struct sk_buff_head      rx_q;
+	struct work_struct	 rx_work;
+};
+
+int fdp_nci_probe(struct fdp_i2c_phy *phy, struct nfc_phy_ops *phy_ops,
+		struct nci_dev **ndev, int tx_headroom, int tx_tailroom);
+void fdp_nci_remove(struct nci_dev *ndev);
+
+int fdp_nci_recv_frame(struct nci_dev *ndev, struct sk_buff *skb);
+int fdp_nci_send_cmd(struct nci_dev *ndev, __u16 opcode, __u8 plen,
+		     void *payload);
+
+int fdp_nci_ntf_packet(struct nci_dev *ndev, struct sk_buff *skb);
+int fdp_nci_rsp_packet(struct nci_dev *ndev, struct sk_buff *skb);
+
+int fdp_nci_create_conn(struct nci_dev *ndev);
+int fdp_nci_close_conn(struct nci_dev *ndev);
+int fdp_nci_get_versions(struct nci_dev *ndev);
+int fdp_nci_patch_start(struct nci_dev *ndev, u8 type);
+int fdp_nci_patch_end(struct nci_dev *ndev);
+int fdp_nci_send_patch(struct nci_dev *ndev, u8 type);
+int fdp_nci_set_production_data(struct nci_dev *ndev, u8 len, char *data);
+int fdp_nci_set_clock(struct nci_dev *ndev, u8 clock_type, u32 clock_freq);
+void fdp_nci_set_data_pkt_counter(struct nci_dev *ndev,
+				  void (*cb)(struct nci_dev *ndev), int count);
+
+#endif /* __LOCAL_FDP_H_ */
diff --git a/drivers/nfc/fdp/i2c.c b/drivers/nfc/fdp/i2c.c
new file mode 100644
index 0000000..760f9e3
--- /dev/null
+++ b/drivers/nfc/fdp/i2c.c
@@ -0,0 +1,454 @@
+/* -------------------------------------------------------------------------
+ * Copyright (C) 2014-2016, Intel Corporation
+ *
+ *  This program is free software; you can redistribute it and/or modify
+ *  it under the terms of the GNU General Public License as published by
+ *  the Free Software Foundation; either version 2 of the License, or
+ *  (at your option) any later version.
+ *
+ *  This program is distributed in the hope that it will be useful,
+ *  but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ *  GNU General Public License for more details.
+ * ------------------------------------------------------------------------- */
+
+#include <linux/module.h>
+#include <linux/acpi.h>
+#include <linux/i2c.h>
+#include <linux/interrupt.h>
+#include <linux/nfc.h>
+#include <linux/gpio.h>
+#include <linux/platform_data/fdp.h>
+#include <linux/delay.h>
+#include <net/nfc/nfc.h>
+#include <net/nfc/nci_core.h>
+
+#include "fdp.h"
+
+#define FDP_GPIO_NAME_IRQ "fdp_irq"
+#define FDP_GPIO_NAME_EN  "fdp_en"
+
+#define FDP_FRAME_HEADROOM 2
+#define FDP_FRAME_TAILROOM 1
+
+#define FDP_NCI_I2C_MIN_PAYLOAD 5
+#define FDP_NCI_I2C_MAX_PAYLOAD 25
+
+#define RST_RESET 0
+#define RST_NO_RESET 1
+
+#define FDP_NCI_I2C_DRIVER_NAME "fdp_nci_i2c"
+
+#define I2C_DUMP_SKB(info, skb)					\
+do {								\
+	pr_debug("%s:\n", info);				\
+	print_hex_dump(KERN_DEBUG, "i2c: ", DUMP_PREFIX_OFFSET,	\
+		       16, 1, (skb)->data, (skb)->len, 0);	\
+} while (0)
+
+static void fdp_nci_i2c_reset(struct fdp_i2c_phy *phy)
+{
+	/* Reset RST/WakeUP for at least 2 micro-second */
+	gpio_set_value_cansleep(phy->gpio_en, RST_RESET);
+	usleep_range(1000, 4000);
+	gpio_set_value_cansleep(phy->gpio_en, RST_NO_RESET);
+	usleep_range(10000, 14000);
+}
+
+static int fdp_nci_i2c_enable(void *phy_id)
+{
+	struct fdp_i2c_phy *phy = phy_id;
+
+	dev_dbg(&phy->i2c_dev->dev, "%s\n", __func__);
+
+	fdp_nci_i2c_reset(phy);
+	phy->powered = 1;
+
+	return 0;
+}
+
+static void fdp_nci_i2c_disable(void *phy_id)
+{
+	struct fdp_i2c_phy *phy = phy_id;
+
+	dev_dbg(&phy->i2c_dev->dev, "%s\n", __func__);
+
+	fdp_nci_i2c_reset(phy);
+	phy->powered = 0;
+}
+
+static void fdp_nci_i2c_add_len_lrc(struct sk_buff *skb)
+{
+	u8 lrc = 0;
+	u16 len, i;
+
+	/* Add length header */
+	len = skb->len;
+	*skb_push(skb, 1) = len & 0xff;
+	*skb_push(skb, 1) = len >> 8;
+
+	/* Compute and add lrc */
+	for (i = 0; i < len + 2; i++)
+		lrc ^= skb->data[i];
+
+	*skb_put(skb, 1) = lrc;
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
+	struct fdp_i2c_phy *phy = phy_id;
+	struct i2c_client *client = phy->i2c_dev;
+	int r;
+
+	if (phy->hard_fault != 0)
+		return phy->hard_fault;
+
+	fdp_nci_i2c_add_len_lrc(skb);
+
+	I2C_DUMP_SKB("fdp_nci_i2c_write", skb);
+
+	r = i2c_master_send(client, skb->data, skb->len);
+	if (r == -EREMOTEIO) {  /* Retry, chip was in standby */
+		usleep_range(1000, 4000);
+		r = i2c_master_send(client, skb->data, skb->len);
+	}
+
+	if (r < 0 || r != skb->len)
+		dev_dbg(&client->dev, "%s: error err=%d len=%d\n",
+			__func__, r, skb->len);
+
+	if (r >= 0) {
+		if (r != skb->len) {
+			phy->hard_fault = r;
+			r = -EREMOTEIO;
+		} else {
+			r = 0;
+		}
+	}
+
+	fdp_nci_i2c_remove_len_lrc(skb);
+
+	return r;
+}
+
+static struct nfc_phy_ops i2c_phy_ops = {
+	.write = fdp_nci_i2c_write,
+	.enable = fdp_nci_i2c_enable,
+	.disable = fdp_nci_i2c_disable,
+};
+
+static int fdp_nci_i2c_acpi_request_resources(struct i2c_client *client)
+{
+	struct fdp_i2c_phy *phy = i2c_get_clientdata(client);
+	const struct acpi_device_id *id;
+	struct gpio_desc *gpiod_en, *gpiod_irq;
+	struct device *dev;
+	int ret;
+
+	dev_dbg(&client->dev, "%s\n", __func__);
+
+	if (!client)
+		return -EINVAL;
+
+	dev = &client->dev;
+
+	/* Match the struct device against a given list of ACPI IDs */
+	id = acpi_match_device(dev->driver->acpi_match_table, dev);
+	if (!id)
+		return -ENODEV;
+
+	/* Get EN GPIO from ACPI */
+	gpiod_en = devm_gpiod_get_index(dev, FDP_GPIO_NAME_EN, 1);
+	if (IS_ERR(gpiod_en)) {
+		nfc_err(dev, "Unable to get EN GPIO\n");
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
+	/* Get IRQ GPIO */
+	gpiod_irq = devm_gpiod_get_index(dev, FDP_GPIO_NAME_IRQ, 0);
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
+static int fdp_nci_i2c_read(struct fdp_i2c_phy *phy, struct sk_buff **skb)
+{
+	int r, len;
+	u8 tmp[FDP_NCI_I2C_MAX_PAYLOAD], lrc, k;
+	u16 i;
+	struct i2c_client *client = phy->i2c_dev;
+
+	*skb = NULL;
+
+	/* Read the length packet and the data packet */
+	for (k = 0; k < 2; k++) {
+
+		len = phy->next_read_size;
+
+		r = i2c_master_recv(client, tmp, len);
+		if (r != len) {
+			dev_dbg(&client->dev, "%s: i2c recv err: %d\n",
+				__func__, r);
+			goto flush;
+		}
+
+		/* Check packet integruty */
+		for (lrc = i = 0; i < r; i++)
+			lrc ^= tmp[i];
+
+		/*
+		 * LRC check failed. This may due to transmission error or
+		 * desynchronization between driver and FDP. Drop the paquet
+		 * and force resynchronization
+		 */
+		if (lrc) {
+			dev_dbg(&client->dev, "%s: corrupted packet\n",
+				__func__);
+			phy->next_read_size = 5;
+			goto flush;
+		}
+
+		/* Packet that contains a length */
+		if (tmp[0] == 0 && tmp[1] == 0) {
+
+			phy->next_read_size = (tmp[2] << 8) + tmp[3] + 3;
+
+		} else {
+
+			phy->next_read_size = FDP_NCI_I2C_MIN_PAYLOAD;
+
+			*skb = alloc_skb(len, GFP_KERNEL);
+			if (*skb == NULL) {
+				r = -ENOMEM;
+				goto flush;
+			}
+
+			memcpy(skb_put(*skb, len), tmp, len);
+			I2C_DUMP_SKB("fdp_nci_i2c_read", *skb);
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
+		r = -EREMOTEIO;
+
+	return r;
+}
+
+static irqreturn_t fdp_nci_i2c_irq_thread_fn(int irq, void *phy_id)
+{
+	struct fdp_i2c_phy *phy = phy_id;
+	struct i2c_client *client;
+	struct sk_buff *skb;
+	int r;
+
+	client = phy->i2c_dev;
+	dev_dbg(&client->dev, "%s\n", __func__);
+
+	if (!phy || irq != phy->i2c_dev->irq) {
+		WARN_ON_ONCE(1);
+		return IRQ_NONE;
+	}
+
+	r = fdp_nci_i2c_read(phy, &skb);
+
+	if (r == -EREMOTEIO)
+		return IRQ_HANDLED;
+	else if (r == -ENOMEM || r == -EBADMSG)
+		return IRQ_HANDLED;
+
+	if (skb != NULL)
+		fdp_nci_recv_frame(phy->ndev, skb);
+
+	return IRQ_HANDLED;
+}
+
+
+static int fdp_nci_i2c_probe(struct i2c_client *client,
+			       const struct i2c_device_id *id)
+{
+	struct fdp_i2c_phy *phy;
+	struct fdp_nfc_platform_data *pdata;
+	int r = 0;
+
+	dev_dbg(&client->dev, "%s\n", __func__);
+	dev_dbg(&client->dev, "IRQ: %d\n", client->irq);
+
+	if (!i2c_check_functionality(client->adapter, I2C_FUNC_I2C)) {
+		nfc_err(&client->dev, "No I2C_FUNC_I2C\n");
+		return -ENODEV;
+	}
+
+	phy = devm_kzalloc(&client->dev, sizeof(struct fdp_i2c_phy),
+			   GFP_KERNEL);
+	if (!phy)
+		return -ENOMEM;
+
+	phy->i2c_dev = client;
+	phy->next_read_size = FDP_NCI_I2C_MIN_PAYLOAD;
+	i2c_set_clientdata(client, phy);
+
+	pdata = client->dev.platform_data;
+
+	/* Using platform data. */
+	if (pdata) {
+
+		if (pdata->request_resources == NULL) {
+			nfc_err(&client->dev, "request_resources() missing\n");
+			return -EINVAL;
+		}
+
+		r = pdata->request_resources(client);
+		if (r) {
+			nfc_err(&client->dev,
+				"Cannot get platform resources\n");
+			return r;
+		}
+
+		phy->gpio_en = pdata->get_gpio(NFC_GPIO_ENABLE);
+		phy->gpio_irq = pdata->get_gpio(NFC_GPIO_IRQ);
+
+	/* Using ACPI */
+	} else if (ACPI_HANDLE(&client->dev)) {
+
+		r = fdp_nci_i2c_acpi_request_resources(client);
+		if (r) {
+			nfc_err(&client->dev,
+				"Cannot get ACPI data\n");
+			return r;
+		}
+
+	} else {
+		nfc_err(&client->dev, "No platform data\n");
+		return -EINVAL;
+	}
+
+	r = request_threaded_irq(client->irq, NULL, fdp_nci_i2c_irq_thread_fn,
+				 IRQF_TRIGGER_RISING | IRQF_ONESHOT,
+				 FDP_NCI_I2C_DRIVER_NAME, phy);
+
+	if (r < 0) {
+		nfc_err(&client->dev, "Unable to register IRQ handler\n");
+		goto err_rti;
+	}
+
+	r = fdp_nci_probe(phy, &i2c_phy_ops, &phy->ndev,
+				FDP_FRAME_HEADROOM, FDP_FRAME_TAILROOM);
+
+	if (r < 0) {
+		nfc_err(&client->dev, "NCI probing error\n");
+		goto err_nci;
+	}
+
+	nfc_info(&client->dev, "FDP I2C driver loaded\n");
+	return 0;
+
+err_nci:
+	free_irq(client->irq, phy);
+
+err_rti:
+	if (!pdata)
+		gpio_free(phy->gpio_en);
+	else if (pdata->free_resources)
+		pdata->free_resources();
+
+	return r;
+}
+
+static int fdp_nci_i2c_remove(struct i2c_client *client)
+{
+	struct fdp_i2c_phy *phy = i2c_get_clientdata(client);
+	struct fdp_nfc_platform_data *pdata = client->dev.platform_data;
+
+	dev_dbg(&client->dev, "%s\n", __func__);
+
+	fdp_nci_remove(phy->ndev);
+
+	if (phy->powered)
+		fdp_nci_i2c_disable(phy);
+
+	free_irq(client->irq, phy);
+
+	/* No platform data, GPIOs have been requested by this driver */
+	if (!pdata) {
+		gpio_free(phy->gpio_en);
+	/* Using platform data */
+	} else if (pdata->free_resources) {
+		pdata->free_resources();
+	}
+
+	return 0;
+}
+
+static struct i2c_device_id fdp_nci_i2c_id_table[] = {
+	{"INT339A", 0},
+	{}
+};
+
+MODULE_DEVICE_TABLE(i2c, fdp_nci_i2c_id_table);
+
+
+static const struct acpi_device_id fdp_nci_i2c_acpi_match[] = {
+	{"INT339A", 0},
+	{}
+};
+
+static struct i2c_driver fdp_nci_i2c_driver = {
+	.driver = {
+		   .name = FDP_NCI_I2C_DRIVER_NAME,
+		   .owner  = THIS_MODULE,
+		   .acpi_match_table = ACPI_PTR(fdp_nci_i2c_acpi_match),
+		  },
+	.id_table = fdp_nci_i2c_id_table,
+	.probe = fdp_nci_i2c_probe,
+	.remove = fdp_nci_i2c_remove,
+};
+
+module_i2c_driver(fdp_nci_i2c_driver);
+
+MODULE_LICENSE("GPL");
+MODULE_DESCRIPTION(DRIVER_DESC);
diff --git a/drivers/nfc/fdp/ntf.c b/drivers/nfc/fdp/ntf.c
new file mode 100644
index 0000000..5e4adb8
--- /dev/null
+++ b/drivers/nfc/fdp/ntf.c
@@ -0,0 +1,68 @@
+/* -------------------------------------------------------------------------
+ * Copyright (C) 2014-2016, Intel Corporation
+ *
+ *  This program is free software; you can redistribute it and/or modify
+ *  it under the terms of the GNU General Public License as published by
+ *  the Free Software Foundation; either version 2 of the License, or
+ *  (at your option) any later version.
+ *
+ *  This program is distributed in the hope that it will be useful,
+ *  but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ *  GNU General Public License for more details.
+ * ------------------------------------------------------------------------- */
+
+#include <linux/module.h>
+#include <linux/nfc.h>
+#include <linux/i2c.h>
+#include <linux/firmware.h>
+#include <net/nfc/nci_core.h>
+
+#include "fdp.h"
+
+#define NCI_OP_PROP_PATCH_NTF		nci_opcode_pack(NCI_GID_PROP, 0x08)
+#define NCI_OP_CORE_RESET_NTF		nci_opcode_pack(NCI_GID_CORE, 0x00)
+
+void fdp_nci_core_reset_ntf_packet(struct nci_dev *ndev, struct sk_buff *skb)
+{
+	struct fdp_nci_info *info = nci_get_drvdata(ndev);
+
+	info->setup_reset_ntf = 1;
+	wake_up(&info->setup_wq);
+}
+
+void fdp_nci_prop_patch_ntf_packet(struct nci_dev *ndev, struct sk_buff *skb)
+{
+	struct fdp_nci_info *info = nci_get_drvdata(ndev);
+
+	info->setup_patch_ntf = 1;
+	info->setup_patch_status = skb->data[0];
+	wake_up(&info->setup_wq);
+}
+
+int fdp_nci_ntf_packet(struct nci_dev *ndev, struct sk_buff *skb)
+{
+	u16 ntf_opcode;
+	int r = 0;
+
+	ntf_opcode = nci_opcode(skb->data);
+
+	/* strip the nci control header */
+	skb_pull(skb, NCI_CTRL_HDR_SIZE);
+
+	switch (ntf_opcode) {
+	case NCI_OP_CORE_RESET_NTF:
+		fdp_nci_core_reset_ntf_packet(ndev, skb);
+		break;
+	case NCI_OP_PROP_PATCH_NTF:
+		fdp_nci_prop_patch_ntf_packet(ndev, skb);
+		break;
+	default:
+		r = -EINVAL;
+	}
+
+	/* restore the nci control header */
+	skb_push(skb, NCI_CTRL_HDR_SIZE);
+
+	return r;
+}
diff --git a/drivers/nfc/fdp/rsp.c b/drivers/nfc/fdp/rsp.c
new file mode 100644
index 0000000..ce40e19
--- /dev/null
+++ b/drivers/nfc/fdp/rsp.c
@@ -0,0 +1,117 @@
+/* -------------------------------------------------------------------------
+ * Copyright (C) 2014-2016, Intel Corporation
+ *
+ *  This program is free software; you can redistribute it and/or modify
+ *  it under the terms of the GNU General Public License as published by
+ *  the Free Software Foundation; either version 2 of the License, or
+ *  (at your option) any later version.
+ *
+ *  This program is distributed in the hope that it will be useful,
+ *  but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ *  GNU General Public License for more details.
+ * ------------------------------------------------------------------------- */
+
+#include <linux/module.h>
+#include <linux/nfc.h>
+#include <linux/i2c.h>
+#include <linux/firmware.h>
+#include <net/nfc/nci_core.h>
+
+#include "fdp.h"
+
+#define NCI_OP_PROP_PATCH_RSP                nci_opcode_pack(NCI_GID_PROP, 0x08)
+#define NCI_OP_PROP_SET_PRODUCTION_DATA_RSP  nci_opcode_pack(NCI_GID_PROP, 0x23)
+#define NCI_OP_CORE_GET_CONFIG_RSP           nci_opcode_pack(NCI_GID_CORE, 0x03)
+
+struct nci_core_get_config_rsp {
+	u8 status;
+	u8 count;
+	u8 data[0];
+};
+
+void fdp_nci_prop_patch_rsp_packet(struct nci_dev *ndev, struct sk_buff *skb)
+{
+	u8 status = skb->data[0];
+
+	pr_debug("status 0x%x\n", status);
+	nci_req_complete_driver(ndev, status);
+}
+
+void fdp_nci_prop_set_production_data_rsp_packet(struct nci_dev *ndev,
+						 struct sk_buff *skb)
+{
+	u8 status = skb->data[0];
+
+	pr_debug("status 0x%x\n", status);
+	nci_req_complete_driver(ndev, status);
+}
+
+void fdp_nci_core_get_config_rsp_packet(struct nci_dev *ndev,
+					struct sk_buff *skb)
+{
+	struct fdp_nci_info *info = nci_get_drvdata(ndev);
+	struct nci_core_get_config_rsp *rsp = (void *) skb->data;
+	u8 i, *p;
+
+	if (rsp->status == NCI_STATUS_OK) {
+
+		p = rsp->data;
+		for (i = 0; i < 4; i++) {
+
+			switch (*p++) {
+			case NCI_PARAM_ID_FW_RAM_VERSION:
+				p++;
+				info->ram_version = le32_to_cpup((u32 *) p);
+				p += 4;
+				break;
+			case NCI_PARAM_ID_FW_OTP_VERSION:
+				p++;
+				info->otp_version = le32_to_cpup((u32 *) p);
+				p += 4;
+				break;
+			case NCI_PARAM_ID_OTP_LIMITED_VERSION:
+				p++;
+				info->otp_version = le32_to_cpup((u32 *) p);
+				p += 4;
+				break;
+			case NCI_PARAM_ID_KEY_INDEX_ID:
+				p++;
+				info->key_index = *p++;
+			}
+		}
+	}
+
+	pr_debug("FDP OTP version %d\n", info->otp_version);
+	pr_debug("FDP RAM version %d\n", info->ram_version);
+	pr_debug("FDP key index %d\n", info->key_index);
+
+	pr_debug("status 0x%x\n", rsp->status);
+	nci_req_complete_driver(ndev, rsp->status);
+}
+
+int fdp_nci_rsp_packet(struct nci_dev *ndev, struct sk_buff *skb)
+{
+	u16 ntf_opcode;
+	int r = 0;
+
+	ntf_opcode = nci_opcode(skb->data);
+	skb_pull(skb, NCI_CTRL_HDR_SIZE);
+
+	switch (ntf_opcode) {
+	case NCI_OP_CORE_GET_CONFIG_RSP:
+		fdp_nci_core_get_config_rsp_packet(ndev, skb);
+		break;
+	case NCI_OP_PROP_PATCH_RSP:
+		fdp_nci_prop_patch_rsp_packet(ndev, skb);
+		break;
+	case NCI_OP_PROP_SET_PRODUCTION_DATA_RSP:
+		fdp_nci_prop_set_production_data_rsp_packet(ndev, skb);
+		break;
+	default:
+		r = -EINVAL;
+	}
+
+	skb_push(skb, NCI_CTRL_HDR_SIZE);
+	return r;
+}
diff --git a/include/linux/platform_data/fdp.h b/include/linux/platform_data/fdp.h
new file mode 100644
index 0000000..5a77095
--- /dev/null
+++ b/include/linux/platform_data/fdp.h
@@ -0,0 +1,33 @@
+/* -------------------------------------------------------------------------
+ * Copyright (C) 2014-2016, Intel Corporation
+ *
+ *  This program is free software; you can redistribute it and/or modify
+ *  it under the terms of the GNU General Public License as published by
+ *  the Free Software Foundation; either version 2 of the License, or
+ *  (at your option) any later version.
+ *
+ *  This program is distributed in the hope that it will be useful,
+ *  but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ *  GNU General Public License for more details.
+ * ------------------------------------------------------------------------- */
+
+
+#ifndef _FDP_H_
+#define _FDP_H_
+
+#include <linux/i2c.h>
+
+enum {
+	NFC_GPIO_ENABLE,
+	NFC_GPIO_IRQ,
+};
+
+/* board config */
+struct fdp_nfc_platform_data {
+	int (*request_resources)(struct i2c_client *client);
+	void (*free_resources)(void);
+	int (*get_gpio)(int type);
+};
+
+#endif /* _FDP_H_ */
-- 
1.9.1
