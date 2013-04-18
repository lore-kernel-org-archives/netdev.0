From: Gustavo Padovan <gustavo@padovan.org>
Subject: Re: [RFC/RFT PATCH 2/2] rtk_btusb: A new driver for the Bluetooth
 portion of the Realtek RTL8723AE chip
Date: Thu, 18 Apr 2013 19:22:21 -0300
Message-ID: <20130418222221.GA15279@joana>
References: <1365469068-4548-1-git-send-email-Larry.Finger@lwfinger.net>
 <1365469068-4548-3-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linville@tuxdriver.com, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, marcel@holtmann.org,
	johan.hedberg@gmail.com, linux-bluetooth@vger.kernel.org,
	champion_chen@realsil.com.cn
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f172.google.com ([209.85.216.172]:48307 "EHLO
	mail-qc0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936456Ab3DRWWa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Apr 2013 18:22:30 -0400
Content-Disposition: inline
In-Reply-To: <1365469068-4548-3-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Larry,

* Larry Finger <Larry.Finger@lwfinger.net> [2013-04-08 19:57:48 -0500]:

> This driver is similar to btusb, and uses as much of that code as possible.
> Those parts that are unique are provided here.
> 
> Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
> ---
>  drivers/bluetooth/Kconfig     |  10 +
>  drivers/bluetooth/Makefile    |   1 +
>  drivers/bluetooth/rtk_btusb.c | 974 ++++++++++++++++++++++++++++++++++++++++++
>  drivers/bluetooth/rtk_btusb.h | 102 +++++
>  4 files changed, 1087 insertions(+)
>  create mode 100644 drivers/bluetooth/rtk_btusb.c
>  create mode 100644 drivers/bluetooth/rtk_btusb.h
> 
> diff --git a/drivers/bluetooth/Kconfig b/drivers/bluetooth/Kconfig
> index fdfd61a..11a9e80 100644
> --- a/drivers/bluetooth/Kconfig
> +++ b/drivers/bluetooth/Kconfig
> @@ -242,4 +242,14 @@ config BT_WILINK
>  
>  	  Say Y here to compile support for Texas Instrument's WiLink7 driver
>  	  into the kernel or say M to compile it as module.
> +
> +config BT_RTKUSB
> +	tristate "Realtek BT driver for RTL8723AE"
> +	select FW_LOADER
> +	help
> +	  This enables the Bluetooth driver for the Realtek RTL8723AE Wifi/BT
> +	  combo device.
> +
> +	  Say Y here to compile support for these devices into the kernel
> +	  or say M to build it as a module.
>  endmenu
> diff --git a/drivers/bluetooth/Makefile b/drivers/bluetooth/Makefile
> index 4afae20..167ccc0 100644
> --- a/drivers/bluetooth/Makefile
> +++ b/drivers/bluetooth/Makefile
> @@ -19,6 +19,7 @@ obj-$(CONFIG_BT_ATH3K)		+= ath3k.o
>  obj-$(CONFIG_BT_MRVL)		+= btmrvl.o
>  obj-$(CONFIG_BT_MRVL_SDIO)	+= btmrvl_sdio.o
>  obj-$(CONFIG_BT_WILINK)		+= btwilink.o
> +obj-$(CONFIG_BT_RTKUSB)		+= rtk_btusb.o
>  
>  btmrvl-y			:= btmrvl_main.o
>  btmrvl-$(CONFIG_DEBUG_FS)	+= btmrvl_debugfs.o
> diff --git a/drivers/bluetooth/rtk_btusb.c b/drivers/bluetooth/rtk_btusb.c
> new file mode 100644
> index 0000000..9a12855
> --- /dev/null
> +++ b/drivers/bluetooth/rtk_btusb.c
> @@ -0,0 +1,974 @@
> +/*
> + *
> + *  Realtek Bluetooth USB driver
> + *
> + *  Copyright (C) 2012-2013  Edward Bian <edward_bian@realsil.com.cn>
> + *
> + *  Parts of this routine are copied and modified from btusb, the
> + *  Generic Bluetooth USB driver. In addition, several of the routines
> + *  in btusb are used directly. The btusb code is
> + *  Copyright (C) 2005-2008  Marcel Holtmann <marcel@holtmann.org>
> + *
> + *  This program is free software; you can redistribute it and/or modify
> + *  it under the terms of the GNU General Public License as published by
> + *  the Free Software Foundation; either version 2 of the License, or
> + *  (at your option) any later version.
> + *
> + *  This program is distributed in the hope that it will be useful,
> + *  but WITHOUT ANY WARRANTY; without even the implied warranty of
> + *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + *  GNU General Public License for more details.
> + *
> + *  You should have received a copy of the GNU General Public License
> + *  along with this program; if not, write to the Free Software
> + *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
> + *
> + */
> +
> +#include <linux/module.h>
> +#include <linux/usb.h>
> +#include <linux/firmware.h>
> +#include <linux/suspend.h>
> +#include <net/bluetooth/bluetooth.h>
> +#include <net/bluetooth/hci_core.h>
> +#include <linux/completion.h>
> +#include <linux/version.h>
> +#include <linux/pm_runtime.h>
> +
> +#include "btusb.h"
> +#include "rtk_btusb.h"
> +
> +#define VERSION "0.8"
> +
> +static struct usb_driver btusb_driver;
> +
> +static struct patch_info patch_table[] = {
> +	{0, 0x1200, "rtl_bt/rtl8723a.bin", "rtk8723_bt_config", NULL, 0}
> +};
> +
> +static LIST_HEAD(dev_data_list);
> +
> +/*******************************/
> +
> +static struct usb_device_id btusb_table[] = {
> +	{USB_DEVICE(0x0bda, 0x8723)},
> +	{ }
> +};
> +
> +/*******************************/
> +
> +MODULE_DEVICE_TABLE(usb, btusb_table);
> +
> +static int send_hci_cmd(struct xchange_data *xdata)
> +{
> +	int ret_val;
> +
> +	ret_val = usb_control_msg(
> +		xdata->dev_entry->udev, xdata->pipe_out,
> +		0, USB_TYPE_CLASS, 0, 0,
> +		(void *)(xdata->send_pkt),
> +		xdata->pkt_len, MSG_TO);
> +
> +	return ret_val;
> +}
> +
> +static int rcv_hci_evt(struct xchange_data *xdata)
> +{
> +	int ret_len, ret_val;
> +	int i;
> +
> +	while (1) {
> +		for (i = 0; i < 5; i++) {
> +			/*  Try to send USB interrupt message 5 times. */
> +			ret_val = usb_interrupt_msg(
> +				xdata->dev_entry->udev, xdata->pipe_in,
> +				(void *)(xdata->rcv_pkt), PKT_LEN,
> +				&ret_len, MSG_TO);
> +			if (ret_val >= 0)
> +				break;
> +		}
> +		if (ret_val < 0)
> +			return ret_val;
> +
> +		if (CMD_CMP_EVT == xdata->evt_hdr->evt) {
> +			if (xdata->cmd_hdr->opcode == xdata->cmd_cmp->opcode)
> +				return ret_len;
> +		}
> +	}
> +}
> +
> +static int download_data(struct xchange_data *xdata)
> +{
> +	struct download_cp *cmd_para;
> +	struct download_rp *evt_para;
> +	uint8_t *pcur;
> +	int pkt_len, frag_num, frag_len;
> +	int i, ret_val;
> +
> +	cmd_para = (struct download_cp *)xdata->req_para;
> +	evt_para = (struct download_rp *)xdata->rsp_para;
> +	pcur = xdata->fw_data;
> +	pkt_len = CMD_HDR_LEN + sizeof(struct download_cp);
> +	frag_num = xdata->fw_len / PATCH_SEG_MAX + 1;
> +	frag_len = PATCH_SEG_MAX;
> +
> +	for (i = 0; i < frag_num; i++) {
> +		cmd_para->index = i;
> +		if (i == (frag_num - 1)) {
> +			cmd_para->index |= DATA_END;
> +			frag_len = xdata->fw_len % PATCH_SEG_MAX;
> +			pkt_len -= (PATCH_SEG_MAX - frag_len);
> +		}
> +		xdata->cmd_hdr->opcode = cpu_to_le16(DOWNLOAD_OPCODE);
> +		xdata->cmd_hdr->plen = sizeof(uint8_t) + frag_len;
> +		xdata->pkt_len = pkt_len;
> +		memcpy(cmd_para->data, pcur, frag_len);
> +
> +		ret_val = send_hci_cmd(xdata);
> +		if (ret_val < 0)
> +			return ret_val;
> +
> +		ret_val = rcv_hci_evt(xdata);
> +		if (ret_val < 0)
> +			return ret_val;
> +		if (0 != evt_para->status)
> +			return -1;
> +
> +		pcur += PATCH_SEG_MAX;
> +	}
> +
> +	return xdata->fw_len;
> +}
> +
> +static struct dev_data *dev_data_find(struct usb_interface *intf)
> +{
> +	struct dev_data *dev_entry;
> +
> +	list_for_each_entry(dev_entry, &dev_data_list, list_node) {
> +		if (dev_entry->intf == intf)
> +			return dev_entry;
> +	}
> +
> +	return NULL;
> +}
> +
> +static void init_xdata(struct xchange_data *xdata, struct dev_data *dev_entry)
> +{
> +	memset(xdata, 0, sizeof(struct xchange_data));
> +	xdata->dev_entry = dev_entry;
> +	xdata->pipe_in = usb_rcvintpipe(dev_entry->udev, INTR_EP);
> +	xdata->pipe_out = usb_sndctrlpipe(dev_entry->udev, CTRL_EP);
> +	xdata->cmd_hdr = (struct hci_command_hdr *)(xdata->send_pkt);
> +	xdata->evt_hdr = (struct hci_event_hdr *)(xdata->rcv_pkt);
> +	xdata->cmd_cmp = (struct hci_ev_cmd_complete *)(xdata->rcv_pkt +
> +							EVT_HDR_LEN);
> +	xdata->req_para = xdata->send_pkt + CMD_HDR_LEN;
> +	xdata->rsp_para = xdata->rcv_pkt + EVT_HDR_LEN + CMD_CMP_LEN;
> +}
> +
> +static int check_fw_version(struct xchange_data *xdata)
> +{
> +	struct hci_rp_read_local_version *read_ver_rsp;
> +	struct patch_info *patch_entry;
> +	int ret_val;
> +
> +	xdata->cmd_hdr->opcode = cpu_to_le16(HCI_OP_READ_LOCAL_VERSION);
> +	xdata->cmd_hdr->plen = 0;
> +	xdata->pkt_len = CMD_HDR_LEN;
> +
> +	ret_val = send_hci_cmd(xdata);
> +	if (ret_val < 0)
> +		goto version_end;
> +
> +	ret_val = rcv_hci_evt(xdata);
> +	if (ret_val < 0)
> +		goto version_end;
> +
> +	patch_entry = xdata->dev_entry->patch_entry;
> +	read_ver_rsp = (struct hci_rp_read_local_version *)(xdata->rsp_para);
> +	BT_DBG("check_fw_version : read_ver_rsp->lmp_subver = 0x%x",
> +	       le16_to_cpu(read_ver_rsp->lmp_subver));
> +	if (patch_entry->lmp_sub != le16_to_cpu(read_ver_rsp->lmp_subver))
> +		return 1;
> +
> +	ret_val = 0;
> +version_end:
> +	return ret_val;
> +}
> +
> +static void bt_fw_cb(const struct firmware *firmware, void *context)
> +{
> +	struct dev_data *dev_entry = context;
> +
> +	dev_entry->fw = firmware;
> +	if (!firmware)
> +		pr_err("In callback routine, firmware file not available\n");
> +	complete(&dev_entry->firmware_loading_complete);
> +}
> +
> +static int load_firmware(struct dev_data *dev_entry, uint8_t **buff)
> +{
> +#if LOAD_CONFIG
> +	const struct firmware *fw;
> +#endif
> +	struct usb_device *udev;
> +	struct patch_info *patch_entry;
> +	char *fw_name;
> +	int fw_len = 0, ret_val;
> +
> +	udev = dev_entry->udev;
> +	init_completion(&dev_entry->firmware_loading_complete);
> +	patch_entry = dev_entry->patch_entry;
> +	fw_name = patch_entry->patch_name;
> +	BT_DBG("Reading firmware file %s", fw_name);
> +	ret_val = request_firmware_nowait(THIS_MODULE, 1, fw_name, &udev->dev,
> +					  GFP_KERNEL, dev_entry, bt_fw_cb);
> +	if (ret_val < 0)
> +		goto fw_fail;
> +
> +	wait_for_completion(&dev_entry->firmware_loading_complete);
> +	if (!dev_entry->fw)
> +		goto fw_fail;
> +	*buff = kzalloc(dev_entry->fw->size, GFP_KERNEL);
> +	if (NULL == *buff)
> +		goto alloc_fail;
> +	memcpy(*buff, dev_entry->fw->data, dev_entry->fw->size);
> +	fw_len = dev_entry->fw->size;
> +
> +#if LOAD_CONFIG
> +	release_firmware(dev_entry->fw);
> +	fw_name = patch_entry->config_name;
> +	ret_val = request_firmware(&fw, fw_name, &udev->dev);
> +	if (ret_val < 0) {
> +		fw_len = 0;
> +		kfree(*buff);
> +		*buff = NULL;
> +		goto fw_fail;
> +	}
> +
> +	*buff = krealloc(*buff, fw_len + fw->size, GFP_KERNEL);
> +	if (NULL == *buff) {
> +		fw_len = 0;
> +		release_firmware(fw);
> +		goto fw_fail;
> +	}
> +	memcpy(*buff + fw_len, fw->data, fw->size);
> +	fw_len += fw->size;
> +#endif
> +
> +alloc_fail:
> +	release_firmware(dev_entry->fw);
> +fw_fail:
> +	return fw_len;
> +}
> +
> +static int get_firmware(struct xchange_data *xdata)
> +{
> +	struct dev_data	*dev_entry;
> +	struct patch_info *patch_entry;
> +
> +	dev_entry = xdata->dev_entry;
> +	patch_entry = dev_entry->patch_entry;
> +	if (patch_entry->fw_len > 0) {
> +		xdata->fw_data = kzalloc(patch_entry->fw_len, GFP_KERNEL);
> +		if (NULL == xdata->fw_data)
> +			return -ENOMEM;
> +		memcpy(xdata->fw_data, patch_entry->fw_cache,
> +		       patch_entry->fw_len);
> +		xdata->fw_len = patch_entry->fw_len;
> +	} else {
> +		xdata->fw_len = load_firmware(dev_entry, &xdata->fw_data);
> +		if (xdata->fw_len <= 0)
> +			return -1;
> +	}
> +
> +	return 0;
> +}
> +
> +static int download_patch(struct usb_interface *intf)
> +{
> +	struct dev_data		*dev_entry;
> +	uint8_t			*fw_buf;
> +	int			ret_val;
> +
> +	BT_DBG("download_patch start");
> +	dev_entry = dev_data_find(intf);
> +	if (NULL == dev_entry) {
> +		ret_val = -1;
> +		BT_DBG("NULL == dev_entry");
> +		goto patch_end;
> +	}
> +
> +	init_xdata(&dev_entry->xdata, dev_entry);
> +	ret_val = check_fw_version(&dev_entry->xdata);
> +	if (ret_val != 0)
> +		goto patch_end;
> +
> +	ret_val = get_firmware(&dev_entry->xdata);
> +	if (ret_val < 0) {
> +		BT_DBG("get_firmware failed!");
> +		goto patch_end;
> +	}
> +	fw_buf = dev_entry->xdata.fw_data;
> +
> +	ret_val = download_data(&dev_entry->xdata);
> +	if (ret_val < 0) {
> +		BT_DBG("download_data failed!");
> +		goto patch_fail;
> +	}
> +
> +	ret_val = check_fw_version(&dev_entry->xdata);
> +	if (ret_val <= 0) {
> +		ret_val = -1;
> +		goto patch_fail;
> +	}
> +
> +	ret_val = 0;
> +patch_fail:
> +	kfree(fw_buf);
> +patch_end:
> +	BT_DBG("Rtk patch end %d", ret_val);
> +	return ret_val;
> +}
> +
> +static int btusb_open(struct hci_dev *hdev)
> +{
> +	struct btusb_data *data = hci_get_drvdata(hdev);
> +	int err;
> +
> +	BT_DBG("%s", hdev->name);
> +
> +	err = usb_autopm_get_interface(data->intf);
> +	if (err < 0)
> +		return err;
> +
> +	data->intf->needs_remote_wakeup = 1;
> +	BT_DBG("%s start pm_usage_cnt(0x%x)", __func__,
> +		 atomic_read(&(data->intf->pm_usage_cnt)));
> +
> +	/*******************************/
> +	if (0 == atomic_read(&hdev->promisc)) {
> +		BT_DBG("btusb_open hdev->promisc == 0");
> +		err = -1;
> +	}
> +	err = download_patch(data->intf);
> +	if (err < 0)
> +		goto failed;
> +	/*******************************/

We recently added a setup callback to btusb to run device specific
initialization, take a look in bluetooth-next to check how that can help you
avoid duplicate a lot of code.

	Gustavo
