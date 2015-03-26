From: Samuel Ortiz <sameo@linux.intel.com>
Subject: Re: [PATCH 8/8] NFC: Add Intel FieldsPeak NFC solution driver
Date: Thu, 26 Mar 2015 01:30:25 +0100
Message-ID: <20150326003025.GE10954@ribalta.home>
References: <1424772112-27399-1-git-send-email-robert.dolca@intel.com>
 <1424772112-27399-9-git-send-email-robert.dolca@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfc@lists.01.org,
	Lauro Ramos Venancio <lauro.venancio@openbossa.org>,
	Aloisio Almeida Jr <aloisio.almeida@openbossa.org>,
	linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Robert Dolca <robert.dolca@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:31710 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752258AbbCZAaa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Mar 2015 20:30:30 -0400
Content-Disposition: inline
In-Reply-To: <1424772112-27399-9-git-send-email-robert.dolca@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Robert,

On Tue, Feb 24, 2015 at 12:01:52PM +0200, Robert Dolca wrote:
> The device can be enumerated using ACPI using the id INT339A.
Please give us some more details about the device. NCI ? HCI ?
Features ? What does the initial patchset support ?

> +config NFC_FDP
> +	tristate "Intel FDP NFC driver"
> +	depends on NFC_NCI
> +	select CRC_CCITT
> +	default n
> +	---help---
> +	  Intel FDP core driver.
What's FDP ?


> +	  This is a driver based on the NCI NFC kernel layers.
What does it support ?

> +
> +	  To compile this driver as a module, choose m here. The module will
> +	  be called pn547.
pn547, that's a typo.

> +#define NCI_OP_PROP_PATCH_CMD		     nci_opcode_pack(NCI_GID_PROP, 0x08)
> +#define NCI_OP_PROP_SET_PRODUCTION_DATA_CMD  nci_opcode_pack(NCI_GID_PROP, 0x23)
> +#define NCI_OP_CORE_GET_CONFIG_CMD           nci_opcode_pack(NCI_GID_CORE, 0x03)
This is an NFC Forum spcified command, it should be defined in nci.h.

> +static void fdp_nci_get_version_req(struct nci_dev *ndev, unsigned long opt)
> +{
> +	fdp_nci_send_cmd(ndev, NCI_OP_CORE_GET_CONFIG_CMD,
> +			 sizeof(nci_core_get_config_otp_ram_version),
> +			 &nci_core_get_config_otp_ram_version);
I don't think you need the intercept logic, so this should be a
simple wrapper around nci_send_cmd().


> +int fdp_nci_create_conn(struct nci_dev *ndev)
> +{
> +	struct fdp_nci_info *info = nci_get_drvdata(ndev);
> +	struct core_conn_create_dest_spec_params param;
> +
> +	param.type = 0xA0;
> +	param.length = 0x00;
Would you please describe what those parameters are for ?


> +
> +	return nci_core_conn_create(info->ndev, 0xC2, 1, sizeof(param), &param,
Please define 0xC2, #define FDP_FW_UPDATE_DEST 0xC2


> +int fdp_nci_send_patch(struct nci_dev *ndev, u8 type)
> +{
> +	struct fdp_nci_info *info = nci_get_drvdata(ndev);
> +	const struct firmware *fw;
> +	struct sk_buff *skb;
> +	unsigned long len;
> +	u8 max_size, payload_size;
> +	int rc = 0;
> +
> +	if ((type == NCI_PATCH_TYPE_OTP && !info->otp_patch) ||
> +	    (type == NCI_PATCH_TYPE_RAM && !info->ram_patch))
> +		return -EINVAL;
> +
> +	if (type == NCI_PATCH_TYPE_OTP)
> +		fw = info->otp_patch;
> +	else
> +		fw = info->ram_patch;
> +
> +	max_size = nci_conn_max_data_pkt_payload_size(ndev, info->conn_id);
> +	if (!max_size)
> +		return -EINVAL;
> +
> +	len = fw->size;
> +
> +	fdp_nci_set_data_pkt_counter(ndev, fdp_nci_send_patch_cb,
> +				     DIV_ROUND_UP(fw->size, max_size));
> +
> +	while (len) {
> +
> +		payload_size = min_t(unsigned long, (unsigned long) max_size,
> +				     len);
> +
> +		skb = nci_skb_alloc(ndev, (NCI_CTRL_HDR_SIZE + payload_size),
> +				    GFP_KERNEL);
> +		skb_reserve(skb, NCI_CTRL_HDR_SIZE);
> +
> +		memcpy(skb_put(skb, payload_size), fw->data + (fw->size - len),
> +		       payload_size);
Where is your control header set ? How does your boot ROM know how much
bytes are expected ?

> +void fdp_nci_intercept_disable(struct nci_dev *ndev)
> +{
> +	struct fdp_nci_info *info = nci_get_drvdata(ndev);
> +
> +	pr_info("FDP NCI intercept disabled\n");
> +	atomic_set(&info->intercept, 0);
> +}
Please remove all the intercept stuff here, go through the NCI core and
have a prop_rx ops called.

> +int fdp_nci_recv_frame(struct nci_dev *ndev, struct sk_buff *skb)
> +{
> +	struct fdp_nci_info *info = nci_get_drvdata(ndev);
> +
> +	pr_debug("%s\n", __func__);
> +
> +	if (atomic_read(&info->intercept)) {
> +		skb_queue_tail(&info->rx_q, skb);
> +		schedule_work(&info->rx_work);
> +		return 0;
> +	}
> +
> +	return nci_recv_frame(ndev, skb);
> +}
> +EXPORT_SYMBOL(fdp_nci_recv_frame);
Without the intercept stuff, this should only be nci_recv_frame().

> +int fdp_nci_send_cmd(struct nci_dev *ndev, u16 opcode, u8 plen,
> +		     void *payload)
> +{
> +	fdp_nci_intercept_inc(ndev);
> +	return nci_send_cmd(ndev, opcode, plen, payload);
> +}
Ditto

> +int fdp_nci_setup(struct nci_dev *ndev)
> +{
> +	/* Format: total length followed by an NCI packet */
> +	struct fdp_nci_info *info = nci_get_drvdata(ndev);
> +	char fdp_post_fw_vsc_cfg[] = {  0x1A, 0x2F, 0x23, 0x17,
> +					0x00, 0x00, 0x00,
> +					0x00, 0x04, 0x04, 0x2B, 0x20, 0xFF,
> +					0x09, 0x07, 0xFF, 0xFF, 0xFF, 0xFF,
> +					0x02, 0xFF, 0xFF,
> +					0x08, 0x03, 0x00, 0xFF, 0xFF };
> +	int r;
> +	u8 patched = 0;
> +
> +	pr_debug("%s\n", __func__);
> +
> +	r = nci_init(ndev);
I won't comment further on the fact that I'd prefer to not export
nci_init().

> +	if (r)
> +		goto error;
> +
> +	/* Get RAM and OTP version */
> +	r = fdp_nci_get_versions(ndev);
> +	if (r)
> +		goto error;
> +
> +	/* Load firmware from disk */
> +	r = fdp_nci_request_firmware(ndev);
> +	if (r)
> +		goto error;
> +
> +	/* Update OTP */
> +	if (info->otp_version < info->otp_patch_version) {
> +
> +		info->setup_patch_sent = 0;
> +		info->setup_reset_ntf = 0;
> +		info->setup_patch_ntf = 0;
> +
> +		/* Patch init request */
> +		r = fdp_nci_patch_start(ndev, NCI_PATCH_TYPE_OTP);
> +		if (r)
> +			goto error;
> +
> +		/* Patch data connection creation */
> +		r = fdp_nci_create_conn(ndev);
> +		if (r)
> +			goto error;
> +
> +		/* Send the patch over the data connection */
> +		r = fdp_nci_send_patch(ndev, NCI_PATCH_TYPE_OTP);
> +		if (r)
> +			goto error;
> +
> +		/* Wait for all the packets to be send over i2c */
> +		wait_event_interruptible(info->setup_wq,
> +					 info->setup_patch_sent == 1);
> +
> +		/* Close the data connection */
> +		r = fdp_nci_close_conn(ndev);
> +		if (r)
> +			goto error;
> +
> +		/*
> +		 * After we send the patch finish message we expect two
> +		 * notifications: NCI_OP_PROP_PATCH_NTF,
> +		 * NCI_OP_CORE_RESET_NTF
> +		 */
> +		fdp_nci_intercept_add(ndev, 2);
> +
> +		/* Patch finish message */
> +		r = fdp_nci_patch_end(ndev);
> +		if (r) {
> +			pr_err("FDP OTP patch error %d\n", r);
> +			r = -EINVAL;
> +			goto error;
> +		}
> +
> +		/* If the patch notification didn't arrive yet, wait for it */
> +		wait_event_interruptible(info->setup_wq, info->setup_patch_ntf);
> +
> +		/* Check if the patching was successful */
> +		r = info->setup_patch_status;
> +		if (r) {
> +			pr_err("FDP OTP patch error %d\n", r);
> +			r = -EINVAL;
> +			goto error;
> +		}
> +
> +		/*
> +		 * We need to wait for the reset notification before we
> +		 * can continue
> +		 */
> +		wait_event_interruptible(info->setup_wq, info->setup_reset_ntf);
> +
> +		patched = 1;
> +	}
> +
> +	/* Update RAM */
> +	if (info->ram_version < info->ram_patch_version) {
> +
> +		info->setup_patch_sent = 0;
> +		info->setup_reset_ntf = 0;
> +		info->setup_patch_ntf = 0;
> +
> +		/* Patch init request */
> +		r = fdp_nci_patch_start(ndev, NCI_PATCH_TYPE_RAM);
> +		if (r)
> +			goto error;
> +
> +		/* Patch data connection creation */
> +		r = fdp_nci_create_conn(ndev);
> +		if (r)
> +			goto error;
> +
> +		/* Send the patch over the data connection */
> +		r = fdp_nci_send_patch(ndev, NCI_PATCH_TYPE_RAM);
> +		if (r)
> +			goto error;
> +
> +		/* Wait for all the packets to be send over i2c */
> +		wait_event_interruptible(info->setup_wq,
> +					 info->setup_patch_sent == 1);
> +
> +		/* Close the data connection */
> +		r = fdp_nci_close_conn(ndev);
> +		if (r)
> +			goto error;
> +
> +		/*
> +		 * After we send the patch finish message we expect two
> +		 * notifications: NCI_OP_PROP_PATCH_NTF,
> +		 * NCI_OP_CORE_RESET_NTF
> +		 */
> +		fdp_nci_intercept_add(ndev, 2);
> +
> +		/* Patch finish message */
> +		if (fdp_nci_patch_end(ndev)) {
> +			r = -EINVAL;
> +			goto error;
> +		}
> +
> +		/* If the patch notification didn't arrive yet, wait for it*/
> +		wait_event_interruptible(info->setup_wq, info->setup_patch_ntf);
> +
> +		/* Check if the patching was successful */
> +		r = info->setup_patch_status;
> +		if (r) {
> +			pr_err("FDP RAM patch error %d\n", r);
> +			r = -EINVAL;
> +			goto error;
> +		}
> +
> +		/*
> +		 * We need to wait for the reset notification before we
> +		 * can continue
> +		 */
> +		wait_event_interruptible(info->setup_wq, info->setup_reset_ntf);
> +
> +		patched = 1;
> +	}
You probably want to release your OTP and RAM buffers here.


> +	/* If a patch was applied the new version is checked */
> +	if (patched) {
> +		r = nci_init(ndev);
> +		if (r)
> +			goto error;
> +
> +		r = fdp_nci_get_versions(ndev);
> +		if (r)
> +			goto error;
> +
> +		if (info->otp_version != info->otp_patch_version ||
> +		    info->ram_version != info->ram_patch_version) {
> +			pr_err("FRP firmware update failed");
> +			r = -EINVAL;
> +		}
> +	}
> +
> +	/* Check if the device has VSC */
> +	if (fdp_post_fw_vsc_cfg[0]) {
> +		/* Set the vendor specific configuration */
> +		r = fdp_nci_set_production_data(ndev, fdp_post_fw_vsc_cfg[3],
> +						&fdp_post_fw_vsc_cfg[4]);
> +		if (r)
> +			goto error;
> +	}
> +
> +	/* Set clock type and frequency */
> +	r = fdp_nci_set_clock(ndev, 0, 26000);
> +	if (r)
> +		goto error;
The version checking, production data setting and clock setting should
be part of a post setup notification call. Please add an nci_dev
notify() ops that could get called on certain events, for example when
NCI is up. Bluetooth's HCI does something along those lines already.
>From this notification hook you could implement this post setup stage.

The idea is for your setup routine to only do firmware update and
nothing else. It will make it shorter, and thus easier to read as well.


> +struct fdp_nci_info {
> +	struct nfc_phy_ops *phy_ops;
> +	struct fdp_i2c_phy *phy;
> +	struct nci_dev *ndev;
> +
> +	enum fdp_state state;
> +	struct mutex lock;
> +
> +	const struct firmware *otp_patch;
> +	const struct firmware *ram_patch;
> +	u32 otp_patch_version;
> +	u32 ram_patch_version;
> +
> +	u32 otp_version;
> +	u32 ram_version;
> +	u32 limited_otp_version;
> +	u8 key_index;
> +
> +	u8 conn_id;
> +	atomic_t intercept;
> +	atomic_t data_pkt_counter;
> +	void (*data_pkt_counter_cb)(struct nci_dev *ndev);
> +	u8 setup_patch_sent;
> +	u8 setup_patch_ntf;
> +	u8 setup_patch_status;
> +	u8 setup_reset_ntf;
> +	wait_queue_head_t setup_wq;
> +
> +	struct sk_buff_head      rx_q;
> +	struct work_struct	 rx_work;
I expect those 2 ones to go away as well.


Cheers,
Samuel.
