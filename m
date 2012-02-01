From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] bna: Implement ethtool flash_device entry point.
Date: Wed, 1 Feb 2012 19:14:47 +0000
Message-ID: <1328123687.2541.10.camel@bwh-desktop>
References: <1328054801-11322-1-git-send-email-kgudipat@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<adapter_linux_open_src_team@brocade.com>
To: <kgudipat@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:17958 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754243Ab2BATOu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2012 14:14:50 -0500
In-Reply-To: <1328054801-11322-1-git-send-email-kgudipat@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-01-31 at 16:06 -0800, kgudipat@brocade.com wrote:
> From: Krishna Gudipati <kgudipat@brocade.com>
> 
> Change details:
> 	- Implement ethtool flash_device() entry point to write the
> 	  firmware image to the flash firmware partition.
> 
> Signed-off-by: Krishna Gudipati <kgudipat@brocade.com>
> ---
>  drivers/net/ethernet/brocade/bna/bfa_defs.h     |    1 +
>  drivers/net/ethernet/brocade/bna/bnad_ethtool.c |   36 +++++++++++++++++++++++
>  2 files changed, 37 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/ethernet/brocade/bna/bfa_defs.h b/drivers/net/ethernet/brocade/bna/bfa_defs.h
> index 871c630..48f8773 100644
> --- a/drivers/net/ethernet/brocade/bna/bfa_defs.h
> +++ b/drivers/net/ethernet/brocade/bna/bfa_defs.h
> @@ -297,6 +297,7 @@ enum bfa_mode {
>  #define BFA_FLASH_PART_ENTRY_SIZE	32	/* partition entry size */
>  #define BFA_FLASH_PART_MAX		32	/* maximal # of partitions */
>  #define BFA_TOTAL_FLASH_SIZE		0x400000
> +#define BFA_FLASH_PART_FWIMG		2
>  #define BFA_FLASH_PART_MFG		7
>  
>  /*
> diff --git a/drivers/net/ethernet/brocade/bna/bnad_ethtool.c b/drivers/net/ethernet/brocade/bna/bnad_ethtool.c
> index 9b44ec8..3e18ee7 100644
> --- a/drivers/net/ethernet/brocade/bna/bnad_ethtool.c
> +++ b/drivers/net/ethernet/brocade/bna/bnad_ethtool.c
> @@ -1072,6 +1072,41 @@ done:
>  	return ret;
>  }
>  
> +static int
> +bnad_flash_device(struct net_device *netdev, struct ethtool_flash *eflash)
> +{
> +	struct bnad *bnad = netdev_priv(netdev);
> +	struct bnad_iocmd_comp fcomp;
> +	const struct firmware *fw;
> +	unsigned long flags = 0;
> +	int ret = 0;
> +
> +	if (request_firmware(&fw, eflash->data, &bnad->pcidev->dev)) {
> +		pr_err("Can't locate firmware %s\n", eflash->data);
> +		goto out;

This results in returning 0.

> +	}
> +
> +	fcomp.bnad = bnad;
> +	fcomp.comp_status = 0;
> +
> +	init_completion(&fcomp.comp);
> +	spin_lock_irqsave(&bnad->bna_lock, flags);

No need to save flags, this is not called in IRQ context!

> +	ret = bfa_nw_flash_update_part(&bnad->bna.flash, BFA_FLASH_PART_FWIMG,
> +				bnad->id, (u8 *)fw->data, fw->size, 0,
> +				bnad_cb_completion, &fcomp);
> +	if (ret != BFA_STATUS_OK) {
> +		spin_unlock_irqrestore(&bnad->bna_lock, flags);
> +		goto out;
> +	}
> +
> +	spin_unlock_irqrestore(&bnad->bna_lock, flags);
> +	wait_for_completion(&fcomp.comp);
> +	ret = fcomp.comp_status;
> +out:
> +	release_firmware(fw);
> +	return ret;

It looks like the value of ret will be an enumerator from enum
bfa_status and not a Linux error code.  In that case you need to convert
it before returning.

Ben.

> +}
> +
>  static const struct ethtool_ops bnad_ethtool_ops = {
>  	.get_settings = bnad_get_settings,
>  	.set_settings = bnad_set_settings,
> @@ -1090,6 +1125,7 @@ static const struct ethtool_ops bnad_ethtool_ops = {
>  	.get_eeprom_len = bnad_get_eeprom_len,
>  	.get_eeprom = bnad_get_eeprom,
>  	.set_eeprom = bnad_set_eeprom,
> +	.flash_device = bnad_flash_device,
>  };
>  
>  void

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
