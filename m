From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCHv2 net-next-2.6 2/2] qlcnic: Take FW dump via ethtool
Date: Tue, 10 May 2011 19:40:26 +0100
Message-ID: <1305052826.2859.53.camel@bwh-desktop>
References: <1304989352-24810-1-git-send-email-anirban.chakraborty@qlogic.com>
	 <1304989352-24810-4-git-send-email-anirban.chakraborty@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:29156 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750811Ab1EJSk3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2011 14:40:29 -0400
In-Reply-To: <1304989352-24810-4-git-send-email-anirban.chakraborty@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-05-09 at 18:02 -0700, Anirban Chakraborty wrote:
> Driver checks if the previous dump has been cleared before taking the dump.
> It doesn't take the dump if it is not cleared.
> 
> Signed-off-by: Anirban Chakraborty <anirban.chakraborty@qlogic.com>
> ---
>  drivers/net/qlcnic/qlcnic_ethtool.c |   60 +++++++++++++++++++++++++++++++++++
>  1 files changed, 60 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/qlcnic/qlcnic_ethtool.c b/drivers/net/qlcnic/qlcnic_ethtool.c
> index c541461..1237449 100644
> --- a/drivers/net/qlcnic/qlcnic_ethtool.c
> +++ b/drivers/net/qlcnic/qlcnic_ethtool.c
> @@ -965,6 +965,64 @@ static void qlcnic_set_msglevel(struct net_device *netdev, u32 msglvl)
>  	adapter->msg_enable = msglvl;
>  }
>  
> +static int
> +qlcnic_get_dump(struct net_device *netdev, struct ethtool_dump *dump,
> +		void *buffer)
> +{
> +	int i, copy_sz;
> +	u32 *hdr_ptr, *data;
> +	struct qlcnic_adapter *adapter = netdev_priv(netdev);
> +	struct qlcnic_fw_dump *fw_dump = &adapter->ahw->fw_dump;
> +
> +	if (dump->type == ETHTOOL_DUMP_FLAG) {
> +		dump->len = fw_dump->tmpl_hdr->size + fw_dump->size;
> +		dump->flag = fw_dump->tmpl_hdr->drv_cap_mask;
> +		return 0;
> +	}
> +	if (!fw_dump->clr) {
> +		netdev_info(netdev, "Dump not available\n");
> +		return -EINVAL;
> +	}
> +	copy_sz = fw_dump->tmpl_hdr->size;
> +	/* Copy template header first */
> +	hdr_ptr = (u32 *) fw_dump->tmpl_hdr;
> +	data = (u32 *) buffer;
> +	for (i = 0; i < copy_sz/sizeof(u32); i++)
> +		*data++ = cpu_to_le32(*hdr_ptr++);
> +	/* Copy captured dump data */
> +	memcpy(buffer + copy_sz, fw_dump->data, fw_dump->size);
> +	dump->len = copy_sz + fw_dump->size;
> +	dump->flag = fw_dump->tmpl_hdr->drv_cap_mask;
> +	/* free dump area once the whoel dump data has been captured */
> +	vfree(fw_dump->data);
> +	fw_dump->size = 0;
> +	fw_dump->data = NULL;
> +	fw_dump->clr = 0;

This doesn't seem to be serialised with the code that captures firmware
dumps.  They need to use the same lock!

> +	return 0;
> +}
> +
> +static int
> +qlcnic_set_dump(struct net_device *netdev, struct ethtool_dump *val)
> +{
> +	struct qlcnic_adapter *adapter = netdev_priv(netdev);
> +	struct qlcnic_fw_dump *fw_dump = &adapter->ahw->fw_dump;
> +	if (val->flag == QLCNIC_FORCE_FW_DUMP_KEY) {
> +		netdev_info(netdev, "Forcing a FW dump\n");
> +		qlcnic_dev_request_reset(adapter);
> +	} else {
> +		if (val->flag > QLCNIC_DUMP_MASK_MAX ||
> +			val->flag < QLCNIC_DUMP_MASK_MIN) {
> +				netdev_info(netdev,
> +				"Invalid dump level: 0x%x\n", val->flag);
> +				return -EINVAL;
> +		}
> +		fw_dump->tmpl_hdr->drv_cap_mask = val->flag & 0xff;
> +		netdev_info(netdev, "Driver mask changed to: 0x%x\n",
> +			fw_dump->tmpl_hdr->drv_cap_mask);

If the flags change, doesn't this invalidate any dump that has been
collected by the driver but not saved?

Also, same locking problem here.

Ben.

> +	}
> +	return 0;
> +}
> +
>  const struct ethtool_ops qlcnic_ethtool_ops = {
>  	.get_settings = qlcnic_get_settings,
>  	.set_settings = qlcnic_set_settings,
> @@ -991,4 +1049,6 @@ const struct ethtool_ops qlcnic_ethtool_ops = {
>  	.set_phys_id = qlcnic_set_led,
>  	.set_msglevel = qlcnic_set_msglevel,
>  	.get_msglevel = qlcnic_get_msglevel,
> +	.get_dump = qlcnic_get_dump,
> +	.set_dump = qlcnic_set_dump,
>  };

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

