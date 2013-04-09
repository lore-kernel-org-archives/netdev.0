From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: [RFC/RFT PATCH 2/2] rtk_btusb: A new driver for the Bluetooth portion of the Realtek RTL8723AE chip
Date: Mon,  8 Apr 2013 19:57:48 -0500
Message-ID: <1365469068-4548-3-git-send-email-Larry.Finger@lwfinger.net>
References: <1365469068-4548-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org, gustavo-THi1TnShQwVAfugRpC6u6w@public.gmane.org,
	johan.hedberg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	champion_chen-kXabqFNEczNtrwSWzY7KCg@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1365469068-4548-1-git-send-email-Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This driver is similar to btusb, and uses as much of that code as possible.
Those parts that are unique are provided here.

Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
---
 drivers/bluetooth/Kconfig     |  10 +
 drivers/bluetooth/Makefile    |   1 +
 drivers/bluetooth/rtk_btusb.c | 974 ++++++++++++++++++++++++++++++++++++++++++
 drivers/bluetooth/rtk_btusb.h | 102 +++++
 4 files changed, 1087 insertions(+)
 create mode 100644 drivers/bluetooth/rtk_btusb.c
 create mode 100644 drivers/bluetooth/rtk_btusb.h

diff --git a/drivers/bluetooth/Kconfig b/drivers/bluetooth/Kconfig
index fdfd61a..11a9e80 100644
--- a/drivers/bluetooth/Kconfig
+++ b/drivers/bluetooth/Kconfig
@@ -242,4 +242,14 @@ config BT_WILINK
 
 	  Say Y here to compile support for Texas Instrument's WiLink7 driver
 	  into the kernel or say M to compile it as module.
+
+config BT_RTKUSB
+	tristate "Realtek BT driver for RTL8723AE"
+	select FW_LOADER
+	help
+	  This enables the Bluetooth driver for the Realtek RTL8723AE Wifi/BT
+	  combo device.
+
+	  Say Y here to compile support for these devices into the kernel
+	  or say M to build it as a module.
 endmenu
diff --git a/drivers/bluetooth/Makefile b/drivers/bluetooth/Makefile
index 4afae20..167ccc0 100644
--- a/drivers/bluetooth/Makefile
+++ b/drivers/bluetooth/Makefile
@@ -19,6 +19,7 @@ obj-$(CONFIG_BT_ATH3K)		+= ath3k.o
 obj-$(CONFIG_BT_MRVL)		+= btmrvl.o
 obj-$(CONFIG_BT_MRVL_SDIO)	+= btmrvl_sdio.o
 obj-$(CONFIG_BT_WILINK)		+= btwilink.o
+obj-$(CONFIG_BT_RTKUSB)		+= rtk_btusb.o
 
 btmrvl-y			:= btmrvl_main.o
 btmrvl-$(CONFIG_DEBUG_FS)	+= btmrvl_debugfs.o
diff --git a/drivers/bluetooth/rtk_btusb.c b/drivers/bluetooth/rtk_btusb.c
new file mode 100644
index 0000000..9a12855
--- /dev/null
+++ b/drivers/bluetooth/rtk_btusb.c
@@ -0,0 +1,974 @@
+/*
+ *
+ *  Realtek Bluetooth USB driver
+ *
+ *  Copyright (C) 2012-2013  Edward Bian <edward_bian-kXabqFNEczNtrwSWzY7KCg@public.gmane.org>
+ *
+ *  Parts of this routine are copied and modified from btusb, the
+ *  Generic Bluetooth USB driver. In addition, several of the routines
+ *  in btusb are used directly. The btusb code is
+ *  Copyright (C) 2005-2008  Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
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
+ *
+ *  You should have received a copy of the GNU General Public License
+ *  along with this program; if not, write to the Free Software
+ *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ *
+ */
+
+#include <linux/module.h>
+#include <linux/usb.h>
+#include <linux/firmware.h>
+#include <linux/suspend.h>
+#include <net/bluetooth/bluetooth.h>
+#include <net/bluetooth/hci_core.h>
+#include <linux/completion.h>
+#include <linux/version.h>
+#include <linux/pm_runtime.h>
+
+#include "btusb.h"
+#include "rtk_btusb.h"
+
+#define VERSION "0.8"
+
+static struct usb_driver btusb_driver;
+
+static struct patch_info patch_table[] = {
+	{0, 0x1200, "rtl_bt/rtl8723a.bin", "rtk8723_bt_config", NULL, 0}
+};
+
+static LIST_HEAD(dev_data_list);
+
+/*******************************/
+
+static struct usb_device_id btusb_table[] = {
+	{USB_DEVICE(0x0bda, 0x8723)},
+	{ }
+};
+
+/*******************************/
+
+MODULE_DEVICE_TABLE(usb, btusb_table);
+
+static int send_hci_cmd(struct xchange_data *xdata)
+{
+	int ret_val;
+
+	ret_val = usb_control_msg(
+		xdata->dev_entry->udev, xdata->pipe_out,
+		0, USB_TYPE_CLASS, 0, 0,
+		(void *)(xdata->send_pkt),
+		xdata->pkt_len, MSG_TO);
+
+	return ret_val;
+}
+
+static int rcv_hci_evt(struct xchange_data *xdata)
+{
+	int ret_len, ret_val;
+	int i;
+
+	while (1) {
+		for (i = 0; i < 5; i++) {
+			/*  Try to send USB interrupt message 5 times. */
+			ret_val = usb_interrupt_msg(
+				xdata->dev_entry->udev, xdata->pipe_in,
+				(void *)(xdata->rcv_pkt), PKT_LEN,
+				&ret_len, MSG_TO);
+			if (ret_val >= 0)
+				break;
+		}
+		if (ret_val < 0)
+			return ret_val;
+
+		if (CMD_CMP_EVT == xdata->evt_hdr->evt) {
+			if (xdata->cmd_hdr->opcode == xdata->cmd_cmp->opcode)
+				return ret_len;
+		}
+	}
+}
+
+static int download_data(struct xchange_data *xdata)
+{
+	struct download_cp *cmd_para;
+	struct download_rp *evt_para;
+	uint8_t *pcur;
+	int pkt_len, frag_num, frag_len;
+	int i, ret_val;
+
+	cmd_para = (struct download_cp *)xdata->req_para;
+	evt_para = (struct download_rp *)xdata->rsp_para;
+	pcur = xdata->fw_data;
+	pkt_len = CMD_HDR_LEN + sizeof(struct download_cp);
+	frag_num = xdata->fw_len / PATCH_SEG_MAX + 1;
+	frag_len = PATCH_SEG_MAX;
+
+	for (i = 0; i < frag_num; i++) {
+		cmd_para->index = i;
+		if (i == (frag_num - 1)) {
+			cmd_para->index |= DATA_END;
+			frag_len = xdata->fw_len % PATCH_SEG_MAX;
+			pkt_len -= (PATCH_SEG_MAX - frag_len);
+		}
+		xdata->cmd_hdr->opcode = cpu_to_le16(DOWNLOAD_OPCODE);
+		xdata->cmd_hdr->plen = sizeof(uint8_t) + frag_len;
+		xdata->pkt_len = pkt_len;
+		memcpy(cmd_para->data, pcur, frag_len);
+
+		ret_val = send_hci_cmd(xdata);
+		if (ret_val < 0)
+			return ret_val;
+
+		ret_val = rcv_hci_evt(xdata);
+		if (ret_val < 0)
+			return ret_val;
+		if (0 != evt_para->status)
+			return -1;
+
+		pcur += PATCH_SEG_MAX;
+	}
+
+	return xdata->fw_len;
+}
+
+static struct dev_data *dev_data_find(struct usb_interface *intf)
+{
+	struct dev_data *dev_entry;
+
+	list_for_each_entry(dev_entry, &dev_data_list, list_node) {
+		if (dev_entry->intf == intf)
+			return dev_entry;
+	}
+
+	return NULL;
+}
+
+static void init_xdata(struct xchange_data *xdata, struct dev_data *dev_entry)
+{
+	memset(xdata, 0, sizeof(struct xchange_data));
+	xdata->dev_entry = dev_entry;
+	xdata->pipe_in = usb_rcvintpipe(dev_entry->udev, INTR_EP);
+	xdata->pipe_out = usb_sndctrlpipe(dev_entry->udev, CTRL_EP);
+	xdata->cmd_hdr = (struct hci_command_hdr *)(xdata->send_pkt);
+	xdata->evt_hdr = (struct hci_event_hdr *)(xdata->rcv_pkt);
+	xdata->cmd_cmp = (struct hci_ev_cmd_complete *)(xdata->rcv_pkt +
+							EVT_HDR_LEN);
+	xdata->req_para = xdata->send_pkt + CMD_HDR_LEN;
+	xdata->rsp_para = xdata->rcv_pkt + EVT_HDR_LEN + CMD_CMP_LEN;
+}
+
+static int check_fw_version(struct xchange_data *xdata)
+{
+	struct hci_rp_read_local_version *read_ver_rsp;
+	struct patch_info *patch_entry;
+	int ret_val;
+
+	xdata->cmd_hdr->opcode = cpu_to_le16(HCI_OP_READ_LOCAL_VERSION);
+	xdata->cmd_hdr->plen = 0;
+	xdata->pkt_len = CMD_HDR_LEN;
+
+	ret_val = send_hci_cmd(xdata);
+	if (ret_val < 0)
+		goto version_end;
+
+	ret_val = rcv_hci_evt(xdata);
+	if (ret_val < 0)
+		goto version_end;
+
+	patch_entry = xdata->dev_entry->patch_entry;
+	read_ver_rsp = (struct hci_rp_read_local_version *)(xdata->rsp_para);
+	BT_DBG("check_fw_version : read_ver_rsp->lmp_subver = 0x%x",
+	       le16_to_cpu(read_ver_rsp->lmp_subver));
+	if (patch_entry->lmp_sub != le16_to_cpu(read_ver_rsp->lmp_subver))
+		return 1;
+
+	ret_val = 0;
+version_end:
+	return ret_val;
+}
+
+static void bt_fw_cb(const struct firmware *firmware, void *context)
+{
+	struct dev_data *dev_entry = context;
+
+	dev_entry->fw = firmware;
+	if (!firmware)
+		pr_err("In callback routine, firmware file not available\n");
+	complete(&dev_entry->firmware_loading_complete);
+}
+
+static int load_firmware(struct dev_data *dev_entry, uint8_t **buff)
+{
+#if LOAD_CONFIG
+	const struct firmware *fw;
+#endif
+	struct usb_device *udev;
+	struct patch_info *patch_entry;
+	char *fw_name;
+	int fw_len = 0, ret_val;
+
+	udev = dev_entry->udev;
+	init_completion(&dev_entry->firmware_loading_complete);
+	patch_entry = dev_entry->patch_entry;
+	fw_name = patch_entry->patch_name;
+	BT_DBG("Reading firmware file %s", fw_name);
+	ret_val = request_firmware_nowait(THIS_MODULE, 1, fw_name, &udev->dev,
+					  GFP_KERNEL, dev_entry, bt_fw_cb);
+	if (ret_val < 0)
+		goto fw_fail;
+
+	wait_for_completion(&dev_entry->firmware_loading_complete);
+	if (!dev_entry->fw)
+		goto fw_fail;
+	*buff = kzalloc(dev_entry->fw->size, GFP_KERNEL);
+	if (NULL == *buff)
+		goto alloc_fail;
+	memcpy(*buff, dev_entry->fw->data, dev_entry->fw->size);
+	fw_len = dev_entry->fw->size;
+
+#if LOAD_CONFIG
+	release_firmware(dev_entry->fw);
+	fw_name = patch_entry->config_name;
+	ret_val = request_firmware(&fw, fw_name, &udev->dev);
+	if (ret_val < 0) {
+		fw_len = 0;
+		kfree(*buff);
+		*buff = NULL;
+		goto fw_fail;
+	}
+
+	*buff = krealloc(*buff, fw_len + fw->size, GFP_KERNEL);
+	if (NULL == *buff) {
+		fw_len = 0;
+		release_firmware(fw);
+		goto fw_fail;
+	}
+	memcpy(*buff + fw_len, fw->data, fw->size);
+	fw_len += fw->size;
+#endif
+
+alloc_fail:
+	release_firmware(dev_entry->fw);
+fw_fail:
+	return fw_len;
+}
+
+static int get_firmware(struct xchange_data *xdata)
+{
+	struct dev_data	*dev_entry;
+	struct patch_info *patch_entry;
+
+	dev_entry = xdata->dev_entry;
+	patch_entry = dev_entry->patch_entry;
+	if (patch_entry->fw_len > 0) {
+		xdata->fw_data = kzalloc(patch_entry->fw_len, GFP_KERNEL);
+		if (NULL == xdata->fw_data)
+			return -ENOMEM;
+		memcpy(xdata->fw_data, patch_entry->fw_cache,
+		       patch_entry->fw_len);
+		xdata->fw_len = patch_entry->fw_len;
+	} else {
+		xdata->fw_len = load_firmware(dev_entry, &xdata->fw_data);
+		if (xdata->fw_len <= 0)
+			return -1;
+	}
+
+	return 0;
+}
+
+static int download_patch(struct usb_interface *intf)
+{
+	struct dev_data		*dev_entry;
+	uint8_t			*fw_buf;
+	int			ret_val;
+
+	BT_DBG("download_patch start");
+	dev_entry = dev_data_find(intf);
+	if (NULL == dev_entry) {
+		ret_val = -1;
+		BT_DBG("NULL == dev_entry");
+		goto patch_end;
+	}
+
+	init_xdata(&dev_entry->xdata, dev_entry);
+	ret_val = check_fw_version(&dev_entry->xdata);
+	if (ret_val != 0)
+		goto patch_end;
+
+	ret_val = get_firmware(&dev_entry->xdata);
+	if (ret_val < 0) {
+		BT_DBG("get_firmware failed!");
+		goto patch_end;
+	}
+	fw_buf = dev_entry->xdata.fw_data;
+
+	ret_val = download_data(&dev_entry->xdata);
+	if (ret_val < 0) {
+		BT_DBG("download_data failed!");
+		goto patch_fail;
+	}
+
+	ret_val = check_fw_version(&dev_entry->xdata);
+	if (ret_val <= 0) {
+		ret_val = -1;
+		goto patch_fail;
+	}
+
+	ret_val = 0;
+patch_fail:
+	kfree(fw_buf);
+patch_end:
+	BT_DBG("Rtk patch end %d", ret_val);
+	return ret_val;
+}
+
+static int btusb_open(struct hci_dev *hdev)
+{
+	struct btusb_data *data = hci_get_drvdata(hdev);
+	int err;
+
+	BT_DBG("%s", hdev->name);
+
+	err = usb_autopm_get_interface(data->intf);
+	if (err < 0)
+		return err;
+
+	data->intf->needs_remote_wakeup = 1;
+	BT_DBG("%s start pm_usage_cnt(0x%x)", __func__,
+		 atomic_read(&(data->intf->pm_usage_cnt)));
+
+	/*******************************/
+	if (0 == atomic_read(&hdev->promisc)) {
+		BT_DBG("btusb_open hdev->promisc == 0");
+		err = -1;
+	}
+	err = download_patch(data->intf);
+	if (err < 0)
+		goto failed;
+	/*******************************/
+
+	if (test_and_set_bit(HCI_RUNNING, &hdev->flags))
+		goto done;
+
+	if (test_and_set_bit(BTUSB_INTR_RUNNING, &data->flags))
+		goto done;
+
+	err = btusb_submit_intr_urb(hdev, GFP_KERNEL);
+	if (err < 0)
+		goto failed;
+
+	err = btusb_submit_bulk_urb(hdev, GFP_KERNEL);
+	if (err < 0) {
+		mdelay(URB_CANCELING_DELAY_MS);      /*  Added by Realtek */
+		usb_kill_anchored_urbs(&data->intr_anchor);
+		goto failed;
+	}
+
+	set_bit(BTUSB_BULK_RUNNING, &data->flags);
+	btusb_submit_bulk_urb(hdev, GFP_KERNEL);
+
+done:
+	usb_autopm_put_interface(data->intf);
+	BT_DBG("%s end  pm_usage_cnt(0x%x)", __func__,
+		  atomic_read(&(data->intf->pm_usage_cnt)));
+
+	return 0;
+
+failed:
+	clear_bit(BTUSB_INTR_RUNNING, &data->flags);
+	clear_bit(HCI_RUNNING, &hdev->flags);
+	usb_autopm_put_interface(data->intf);
+	BT_DBG("%s failed  pm_usage_cnt(0x%x)", __func__,
+		  atomic_read(&(data->intf->pm_usage_cnt)));
+	return err;
+}
+
+static int btusb_close(struct hci_dev *hdev)
+{
+	struct btusb_data *data = hci_get_drvdata(hdev);
+	int i, err;
+
+	if (!test_and_clear_bit(HCI_RUNNING, &hdev->flags))
+		return 0;
+
+	BT_DBG("btusb_close");
+	/*******************************/
+	for (i = 0; i < NUM_REASSEMBLY; i++) {
+		if (hdev->reassembly[i])	{
+			kfree_skb(hdev->reassembly[i]);
+			hdev->reassembly[i] = NULL;
+			BT_DBG("%s free ressembly i =%d", __func__, i);
+		}
+	}
+	/*******************************/
+	cancel_work_sync(&data->work);
+	cancel_work_sync(&data->waker);
+
+	clear_bit(BTUSB_ISOC_RUNNING, &data->flags);
+	clear_bit(BTUSB_BULK_RUNNING, &data->flags);
+	clear_bit(BTUSB_INTR_RUNNING, &data->flags);
+
+	btusb_stop_traffic(data);
+	err = usb_autopm_get_interface(data->intf);
+	if (err < 0)
+		goto failed;
+
+	data->intf->needs_remote_wakeup = 0;
+	usb_autopm_put_interface(data->intf);
+
+failed:
+	mdelay(URB_CANCELING_DELAY_MS);     /*  Added by Realtek */
+	usb_scuttle_anchored_urbs(&data->deferred);
+	return 0;
+}
+
+static inline int __set_isoc_interface(struct hci_dev *hdev, int altsetting)
+{
+	struct btusb_data *data = hci_get_drvdata(hdev);
+	struct usb_interface *intf = data->isoc;
+	struct usb_endpoint_descriptor *ep_desc;
+	int i, err;
+
+	if (!data->isoc)
+		return -ENODEV;
+
+	err = usb_set_interface(data->udev, 1, altsetting);
+	if (err < 0) {
+		BT_ERR("%s setting interface failed (%d)", hdev->name, -err);
+		return err;
+	}
+
+	data->isoc_altsetting = altsetting;
+
+	data->isoc_tx_ep = NULL;
+	data->isoc_rx_ep = NULL;
+
+	for (i = 0; i < intf->cur_altsetting->desc.bNumEndpoints; i++) {
+		ep_desc = &intf->cur_altsetting->endpoint[i].desc;
+
+		if (!data->isoc_tx_ep && usb_endpoint_is_isoc_out(ep_desc)) {
+			data->isoc_tx_ep = ep_desc;
+			continue;
+		}
+
+		if (!data->isoc_rx_ep && usb_endpoint_is_isoc_in(ep_desc)) {
+			data->isoc_rx_ep = ep_desc;
+			continue;
+		}
+	}
+
+	if (!data->isoc_tx_ep || !data->isoc_rx_ep) {
+		BT_ERR("%s invalid SCO descriptors", hdev->name);
+		return -ENODEV;
+	}
+
+	return 0;
+}
+
+static void btusb_work(struct work_struct *work)
+{
+	struct btusb_data *data = container_of(work, struct btusb_data, work);
+	struct hci_dev *hdev = data->hdev;
+	int err;
+
+	if (hdev->conn_hash.sco_num > 0) {
+		if (!test_bit(BTUSB_DID_ISO_RESUME, &data->flags)) {
+			err = usb_autopm_get_interface(data->isoc ? data->isoc :
+						       data->intf);
+			if (err < 0) {
+				clear_bit(BTUSB_ISOC_RUNNING, &data->flags);
+				/*  Delay added by Realtek */
+				mdelay(URB_CANCELING_DELAY_MS);
+				usb_kill_anchored_urbs(&data->isoc_anchor);
+				return;
+			}
+
+			set_bit(BTUSB_DID_ISO_RESUME, &data->flags);
+		}
+		if (data->isoc_altsetting != 2) {
+			clear_bit(BTUSB_ISOC_RUNNING, &data->flags);
+			mdelay(URB_CANCELING_DELAY_MS);  /*  Added by Realtek */
+			usb_kill_anchored_urbs(&data->isoc_anchor);
+
+			if (__set_isoc_interface(hdev, 2) < 0)
+				return;
+		}
+
+		if (!test_and_set_bit(BTUSB_ISOC_RUNNING, &data->flags)) {
+			if (btusb_submit_isoc_urb(hdev, GFP_KERNEL) < 0)
+				clear_bit(BTUSB_ISOC_RUNNING, &data->flags);
+			else
+				btusb_submit_isoc_urb(hdev, GFP_KERNEL);
+		}
+	} else {
+		clear_bit(BTUSB_ISOC_RUNNING, &data->flags);
+		mdelay(URB_CANCELING_DELAY_MS);      /*  Added by Realtek */
+		usb_kill_anchored_urbs(&data->isoc_anchor);
+
+		__set_isoc_interface(hdev, 0);
+		if (test_and_clear_bit(BTUSB_DID_ISO_RESUME, &data->flags))
+			usb_autopm_put_interface(data->isoc ? data->isoc :
+						 data->intf);
+	}
+}
+
+static struct patch_info *get_patch_entry(struct usb_device *udev)
+{
+	struct patch_info	*patch_entry;
+	uint16_t	pid;
+
+	patch_entry = patch_table;
+	pid = le16_to_cpu(udev->descriptor.idProduct);
+	while (pid != patch_entry->prod_id) {
+		if (0 == patch_entry->prod_id)
+			break;
+		patch_entry++;
+	}
+
+	return patch_entry;
+}
+
+static int rtkbt_pm_notify(struct notifier_block *notifier, ulong pm_event,
+		    void *unused)
+{
+	struct dev_data	*dev_entry;
+	struct patch_info	*patch_entry;
+	struct usb_device *udev;
+
+	dev_entry = container_of(notifier, struct dev_data, pm_notifier);
+	patch_entry = dev_entry->patch_entry;
+	udev = dev_entry->udev;
+	BT_DBG("rtkbt_pm_notify pm_event =%ld", pm_event);
+	switch (pm_event) {
+	case PM_SUSPEND_PREPARE:
+	case PM_HIBERNATION_PREPARE:
+		patch_entry->fw_len = load_firmware(dev_entry,
+						    &patch_entry->fw_cache);
+		if (patch_entry->fw_len <= 0) {
+			BT_DBG("rtkbt_pm_notify return NOTIFY_BAD");
+			return NOTIFY_BAD;
+		}
+
+		if (!device_may_wakeup(&udev->dev)) {
+			dev_entry->intf->needs_binding = 1;
+			BT_DBG("remote wakeup not support, set intf->needs_binding = 1");
+		}
+		break;
+	case PM_POST_SUSPEND:
+	case PM_POST_HIBERNATION:
+	case PM_POST_RESTORE:
+		if (patch_entry->fw_len > 0) {
+			kfree(patch_entry->fw_cache);
+			patch_entry->fw_cache = NULL;
+			patch_entry->fw_len = 0;
+		}
+#if BTUSB_RPM
+		usb_disable_autosuspend(udev);
+		usb_enable_autosuspend(udev);
+		pm_runtime_set_autosuspend_delay(&(udev->dev), 2000);
+#endif
+		break;
+
+	default:
+		break;
+	}
+
+	return NOTIFY_DONE;
+}
+
+static int patch_add(struct usb_interface *intf)
+{
+	struct dev_data	*dev_entry;
+	struct usb_device *udev;
+
+	BT_DBG("patch_add");
+	dev_entry = dev_data_find(intf);
+	if (NULL != dev_entry)
+		return -1;
+
+	udev = interface_to_usbdev(intf);
+#if BTUSB_RPM
+	BT_DBG("auto suspend is enabled");
+	usb_enable_autosuspend(udev);
+	pm_runtime_set_autosuspend_delay(&(udev->dev), 2000);
+#endif
+
+	dev_entry = kzalloc(sizeof(struct dev_data), GFP_KERNEL);
+	dev_entry->intf = intf;
+	dev_entry->udev = udev;
+	dev_entry->pm_notifier.notifier_call = rtkbt_pm_notify;
+	dev_entry->patch_entry = get_patch_entry(udev);
+	list_add(&dev_entry->list_node, &dev_data_list);
+	register_pm_notifier(&dev_entry->pm_notifier);
+
+	return 0;
+}
+
+static int btusb_probe(struct usb_interface *intf,
+				const struct usb_device_id *id)
+{
+	struct usb_endpoint_descriptor *ep_desc;
+	struct btusb_data *data;
+	struct hci_dev *hdev;
+	int i, err, flag1, flag2;
+	struct usb_device *udev;
+	udev = interface_to_usbdev(intf);
+
+	BT_DBG("Realtek Bluetooth USB driver ver %s", VERSION);
+
+	/* interface numbers are hardcoded in the spec */
+	if (intf->cur_altsetting->desc.bInterfaceNumber != 0)
+		return -ENODEV;
+
+	/*******************************/
+	flag1 = device_can_wakeup(&udev->dev);
+	flag2 = device_may_wakeup(&udev->dev);
+	BT_DBG("btusb_probe 1 ========== can_wakeup =%x	 flag2 =%x",
+	       flag1, flag2);
+	device_wakeup_disable(&udev->dev);
+	flag1 = device_can_wakeup(&udev->dev);
+	flag2 = device_may_wakeup(&udev->dev);
+	BT_DBG("wakeup_disable ========== can_wakeup =%x	 flag2 =%x",
+	       flag1, flag2);
+	err = patch_add(intf);
+	if (err < 0)
+		return -1;
+	/*******************************/
+
+	data = kzalloc(sizeof(*data), GFP_KERNEL);
+	if (!data)
+		return -ENOMEM;
+
+
+	for (i = 0; i < intf->cur_altsetting->desc.bNumEndpoints; i++) {
+		ep_desc = &intf->cur_altsetting->endpoint[i].desc;
+
+		if (!data->intr_ep && usb_endpoint_is_int_in(ep_desc)) {
+			data->intr_ep = ep_desc;
+			continue;
+		}
+
+		if (!data->bulk_tx_ep && usb_endpoint_is_bulk_out(ep_desc)) {
+			data->bulk_tx_ep = ep_desc;
+			continue;
+		}
+
+		if (!data->bulk_rx_ep && usb_endpoint_is_bulk_in(ep_desc)) {
+			data->bulk_rx_ep = ep_desc;
+			continue;
+		}
+	}
+
+	if (!data->intr_ep || !data->bulk_tx_ep || !data->bulk_rx_ep) {
+		kfree(data);
+		return -ENODEV;
+	}
+
+	data->cmdreq_type = USB_TYPE_CLASS;
+
+	data->udev = interface_to_usbdev(intf);
+	data->intf = intf;
+
+	spin_lock_init(&data->lock);
+
+	INIT_WORK(&data->work, btusb_work);
+	INIT_WORK(&data->waker, btusb_waker);
+	spin_lock_init(&data->txlock);
+
+	init_usb_anchor(&data->tx_anchor);
+	init_usb_anchor(&data->intr_anchor);
+	init_usb_anchor(&data->bulk_anchor);
+	init_usb_anchor(&data->isoc_anchor);
+	init_usb_anchor(&data->deferred);
+
+	hdev = hci_alloc_dev();
+	if (!hdev) {
+		kfree(data);
+		return -ENOMEM;
+	}
+
+	HDEV_BUS = HCI_USB;
+
+	data->hdev = hdev;
+
+	SET_HCIDEV_DEV(hdev, &intf->dev);
+
+	hdev->open     = btusb_open;
+	hdev->close    = btusb_close;
+	hdev->flush    = btusb_flush;
+	hdev->send     = btusb_send_frame;
+	hdev->notify   = btusb_notify;
+
+
+	hci_set_drvdata(hdev, data);
+
+	/* Interface numbers are hardcoded in the specification */
+	data->isoc = usb_ifnum_to_if(data->udev, 1);
+
+	if (data->isoc) {
+		err = usb_driver_claim_interface(&btusb_driver,
+						 data->isoc, data);
+		if (err < 0) {
+			hci_free_dev(hdev);
+			kfree(data);
+			return err;
+		}
+	}
+
+	err = hci_register_dev(hdev);
+	if (err < 0) {
+		hci_free_dev(hdev);
+		kfree(data);
+		return err;
+	}
+
+	usb_set_intfdata(intf, data);
+
+	return 0;
+}
+
+static void patch_remove(struct usb_interface *intf)
+{
+	struct dev_data *dev_entry;
+	struct usb_device *udev;
+
+	udev = interface_to_usbdev(intf);
+#if BTUSB_RPM
+	usb_disable_autosuspend(udev);
+#endif
+
+	dev_entry = dev_data_find(intf);
+	if (NULL == dev_entry)
+		return;
+
+	BT_DBG("patch_remove");
+	list_del(&dev_entry->list_node);
+	unregister_pm_notifier(&dev_entry->pm_notifier);
+	kfree(dev_entry);
+}
+
+static void btusb_disconnect(struct usb_interface *intf)
+{
+	struct btusb_data *data = usb_get_intfdata(intf);
+	struct hci_dev *hdev;
+	struct usb_device *udev;
+	udev = interface_to_usbdev(intf);
+
+	if (intf->cur_altsetting->desc.bInterfaceNumber != 0)
+		return;
+
+	if (!data)
+		return;
+
+	BT_DBG("btusb_disconnect");
+	/*******************************/
+	patch_remove(intf);
+	/*******************************/
+
+	hdev = data->hdev;
+
+	usb_set_intfdata(data->intf, NULL);
+
+	if (data->isoc)
+		usb_set_intfdata(data->isoc, NULL);
+
+	hci_unregister_dev(hdev);
+
+	if (intf == data->isoc)
+		usb_driver_release_interface(&btusb_driver, data->intf);
+	else if (data->isoc)
+		usb_driver_release_interface(&btusb_driver, data->isoc);
+
+	hci_free_dev(hdev);
+	kfree(data);
+}
+
+#ifdef CONFIG_PM
+static int set_btoff(struct usb_interface *intf)
+{
+	struct dev_data *dev_entry;
+	int ret_val;
+
+	BT_DBG("set_btoff");
+	dev_entry = dev_data_find(intf);
+	if (NULL == dev_entry)
+		return -1;
+
+	init_xdata(&dev_entry->xdata, dev_entry);
+	dev_entry->xdata.cmd_hdr->opcode = cpu_to_le16(BTOFF_OPCODE);
+	dev_entry->xdata.cmd_hdr->plen = 1;
+	dev_entry->xdata.pkt_len = CMD_HDR_LEN + 1;
+	dev_entry->xdata.send_pkt[CMD_HDR_LEN] = 1;
+
+	ret_val = send_hci_cmd(&dev_entry->xdata);
+	if (ret_val < 0)
+		return ret_val;
+
+	ret_val = rcv_hci_evt(&dev_entry->xdata);
+	if (ret_val < 0)
+		return ret_val;
+
+	BT_DBG("set_btoff done");
+	return 0;
+}
+
+static int btusb_suspend(struct usb_interface *intf, pm_message_t message)
+{
+	struct btusb_data *data = usb_get_intfdata(intf);
+
+	if (intf->cur_altsetting->desc.bInterfaceNumber != 0)
+		return 0;
+
+	/*******************************/
+	BT_DBG("btusb_suspend message.event = 0x%x, data->suspend_count =%d",
+	       message.event, data->suspend_count);
+	if (!test_bit(HCI_RUNNING, &data->hdev->flags)) {
+		BT_DBG("btusb_suspend-----bt is off");
+		set_btoff(data->intf);
+	}
+	/*******************************/
+
+	if (data->suspend_count++)
+		return 0;
+
+	spin_lock_irq(&data->txlock);
+	if (!((message.event & PM_EVENT_AUTO) && data->tx_in_flight)) {
+		set_bit(BTUSB_SUSPENDING, &data->flags);
+		spin_unlock_irq(&data->txlock);
+	} else {
+		spin_unlock_irq(&data->txlock);
+		data->suspend_count--;
+		return -EBUSY;
+	}
+
+	cancel_work_sync(&data->work);
+
+	btusb_stop_traffic(data);
+	mdelay(URB_CANCELING_DELAY_MS);      /*  Added by Realtek */
+	usb_kill_anchored_urbs(&data->tx_anchor);
+
+	return 0;
+}
+
+static void play_deferred(struct btusb_data *data)
+{
+	struct urb *urb;
+	int err;
+
+	while ((urb = usb_get_from_anchor(&data->deferred))) {
+
+		/************************************/
+		usb_anchor_urb(urb, &data->tx_anchor);
+		err = usb_submit_urb(urb, GFP_ATOMIC);
+		if (err < 0) {
+			BT_ERR("play_deferred urb %p submission failed",  urb);
+			kfree(urb->setup_packet);
+			usb_unanchor_urb(urb);
+		} else {
+			usb_mark_last_busy(data->udev);
+		}
+		usb_free_urb(urb);
+		/************************************/
+		data->tx_in_flight++;
+	}
+	mdelay(URB_CANCELING_DELAY_MS);     /*  Added by Realtek */
+	usb_scuttle_anchored_urbs(&data->deferred);
+}
+
+static int btusb_resume(struct usb_interface *intf)
+{
+	struct btusb_data *data = usb_get_intfdata(intf);
+	struct hci_dev *hdev = data->hdev;
+	int err = 0;
+
+	if (intf->cur_altsetting->desc.bInterfaceNumber != 0)
+		return 0;
+
+
+	/*******************************/
+	BT_DBG("btusb_resume data->suspend_count =%d", data->suspend_count);
+
+	if (!test_bit(HCI_RUNNING, &hdev->flags)) {
+		BT_DBG("btusb_resume-----bt is off, download patch");
+		download_patch(intf);
+	} else {
+		BT_DBG("btusb_resume,----bt is on");
+	}
+	/*******************************/
+	if (--data->suspend_count)
+		return 0;
+
+	if (test_bit(BTUSB_INTR_RUNNING, &data->flags)) {
+		err = btusb_submit_intr_urb(hdev, GFP_NOIO);
+		if (err < 0) {
+			clear_bit(BTUSB_INTR_RUNNING, &data->flags);
+			goto failed;
+		}
+	}
+
+	if (test_bit(BTUSB_BULK_RUNNING, &data->flags)) {
+		err = btusb_submit_bulk_urb(hdev, GFP_NOIO);
+		if (err < 0) {
+			clear_bit(BTUSB_BULK_RUNNING, &data->flags);
+			goto failed;
+		}
+
+		btusb_submit_bulk_urb(hdev, GFP_NOIO);
+	}
+
+	if (test_bit(BTUSB_ISOC_RUNNING, &data->flags)) {
+		if (btusb_submit_isoc_urb(hdev, GFP_NOIO) < 0)
+			clear_bit(BTUSB_ISOC_RUNNING, &data->flags);
+		else
+			btusb_submit_isoc_urb(hdev, GFP_NOIO);
+	}
+
+	spin_lock_irq(&data->txlock);
+	play_deferred(data);
+	clear_bit(BTUSB_SUSPENDING, &data->flags);
+	spin_unlock_irq(&data->txlock);
+	schedule_work(&data->work);
+
+	return 0;
+
+failed:
+	mdelay(URB_CANCELING_DELAY_MS);      /*  Added by Realtek */
+	usb_scuttle_anchored_urbs(&data->deferred);
+/* done: */
+	spin_lock_irq(&data->txlock);
+	clear_bit(BTUSB_SUSPENDING, &data->flags);
+	spin_unlock_irq(&data->txlock);
+
+	return err;
+}
+#endif
+
+static struct usb_driver btusb_driver = {
+	.name		= "rtk_btusb",
+	.probe		= btusb_probe,
+	.disconnect	= btusb_disconnect,
+#ifdef CONFIG_PM
+	.suspend	= btusb_suspend,
+	.resume		= btusb_resume,
+#endif
+	.id_table	= btusb_table,
+	.supports_autosuspend = 1,
+};
+
+
+module_usb_driver(btusb_driver);
+
+MODULE_AUTHOR("Edward Bian <edward_bian-kXabqFNEczNtrwSWzY7KCg@public.gmane.org>");
+MODULE_DESCRIPTION("Realtek Bluetooth USB driver ver " VERSION);
+MODULE_VERSION(VERSION);
+MODULE_LICENSE("GPL");
+MODULE_FIRMWARE("rtl_bt/rtl8723a.bin");
diff --git a/drivers/bluetooth/rtk_btusb.h b/drivers/bluetooth/rtk_btusb.h
new file mode 100644
index 0000000..0c55dd6
--- /dev/null
+++ b/drivers/bluetooth/rtk_btusb.h
@@ -0,0 +1,102 @@
+/*
+ *
+ *  Realtek Bluetooth USB driver
+ *
+ *  Copyright (C) 2012-2013  Edward Bian <edward_bian-kXabqFNEczNtrwSWzY7KCg@public.gmane.org>
+ *
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
+ *
+ *  You should have received a copy of the GNU General Public License
+ *  along with this program; if not, write to the Free Software
+ *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ *
+ */
+
+#ifndef RTK_BTUSB_H
+#define RTK_BTUSB_H
+
+#define HDEV_BUS			(hdev->bus)
+#define USB_RPM				1
+
+#define BTUSB_RPM			0	/*1 SS enable; 0 SS disable */
+#define LOAD_CONFIG			0
+#define URB_CANCELING_DELAY_MS		10   /*  Added by Realtek */
+
+#define BTUSB_MAX_ISOC_FRAMES		10
+#define BTUSB_INTR_RUNNING		0
+#define BTUSB_BULK_RUNNING		1
+#define BTUSB_ISOC_RUNNING		2
+#define BTUSB_SUSPENDING		3
+#define BTUSB_DID_ISO_RESUME		4
+
+#define CMD_CMP_EVT			0x0e
+#define PKT_LEN				300
+#define MSG_TO				1000
+#define PATCH_SEG_MAX			252
+#define DATA_END			0x80
+#define DOWNLOAD_OPCODE			0xfc20
+#define BTOFF_OPCODE			0xfc28
+#define CMD_HDR_LEN			sizeof(struct hci_command_hdr)
+#define EVT_HDR_LEN			sizeof(struct hci_event_hdr)
+#define CMD_CMP_LEN			sizeof(struct hci_ev_cmd_complete)
+
+enum rtk_endpoit {
+	CTRL_EP = 0,
+	INTR_EP = 1,
+	BULK_EP = 2,
+	ISOC_EP = 3
+};
+
+struct patch_info {
+	uint16_t	prod_id;
+	uint16_t	lmp_sub;
+	char		*patch_name;
+	char		*config_name;
+	uint8_t		*fw_cache;
+	int		fw_len;
+};
+
+struct xchange_data {
+	struct dev_data	*dev_entry;
+	int pipe_in, pipe_out;
+	uint8_t send_pkt[PKT_LEN];
+	uint8_t rcv_pkt[PKT_LEN];
+	struct hci_command_hdr *cmd_hdr;
+	struct hci_event_hdr *evt_hdr;
+	struct hci_ev_cmd_complete *cmd_cmp;
+	uint8_t *req_para, *rsp_para;
+	uint8_t *fw_data;
+	int pkt_len, fw_len;
+};
+
+struct dev_data {
+	struct list_head	list_node;
+	struct usb_interface	*intf;
+	struct usb_device	*udev;
+	struct notifier_block	pm_notifier;
+	struct patch_info	*patch_entry;
+	struct xchange_data	xdata;
+	struct completion firmware_loading_complete;
+	const struct firmware *fw;
+};
+
+struct download_cp {
+	uint8_t index;
+	uint8_t data[PATCH_SEG_MAX];
+} __packed;
+
+struct download_rp {
+	uint8_t status;
+	uint8_t index;
+} __packed;
+
+#endif
-- 
1.8.1.4
