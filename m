From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next  9/9] igb: Add ethtool support to configure number of
 channels
Date: Tue, 1 Oct 2013 16:59:08 +0100
Message-ID: <1380643148.1939.11.camel@bwh-desktop.uk.level5networks.com>
References: <1380627236-3190-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1380627236-3190-10-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>,
	Laura Mihaela Vasilescu <laura.vasilescu@rosedu.org>,
	<netdev@vger.kernel.org>, <gospo@redhat.com>, <sassmann@redhat.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:47600 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751095Ab3JAP7N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Oct 2013 11:59:13 -0400
In-Reply-To: <1380627236-3190-10-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-10-01 at 04:33 -0700, Jeff Kirsher wrote:
> From: Laura Mihaela Vasilescu <laura.vasilescu@rosedu.org>
> 
> This patch adds the ethtool callbacks necessary to configure the
> number of RSS queues.
> 
> The maximum number of queues is in accordance with the datasheets.
> 
> Signed-off-by: Laura Mihaela Vasilescu <laura.vasilescu@rosedu.org>
> Tested-by: Aaron Brown <aaron.f.brown@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
[...]
> --- a/drivers/net/ethernet/intel/igb/igb_ethtool.c
> +++ b/drivers/net/ethernet/intel/igb/igb_ethtool.c
[...]
> +static void igb_get_channels(struct net_device *netdev,
> +			     struct ethtool_channels *ch)
[...]
> +static int igb_set_channels(struct net_device *netdev,
> +			    struct ethtool_channels *ch)

These functions look fine to me.

[...]
> --- a/drivers/net/ethernet/intel/igb/igb_main.c
> +++ b/drivers/net/ethernet/intel/igb/igb_main.c
> @@ -7838,4 +7838,26 @@ s32 igb_write_i2c_byte(struct e1000_hw *hw, u8 byte_offset,
>  		return E1000_SUCCESS;
>  
>  }
> +
> +int igb_reinit_queues(struct igb_adapter *adapter)
> +{
> +	struct net_device *netdev = adapter->netdev;
> +	struct pci_dev *pdev = adapter->pdev;
> +	int err = 0;
> +
> +	if (netif_running(netdev))
> +		igb_close(netdev);
> +
> +	igb_clear_interrupt_scheme(adapter);
> +
> +	if (igb_init_interrupt_scheme(adapter, true)) {
> +		dev_err(&pdev->dev, "Unable to allocate memory for queues\n");
> +		return -ENOMEM;
> +	}
> +
> +	if (netif_running(netdev))
> +		err = igb_open(netdev);
> +
> +	return err;
> +}
>  /* igb_main.c */

In case this fails, is the interface in a consistent state where is it
safe to reconfigure the interface again or to unbind the driver?

If it fails, and the interface was up, shouldn't it call dev_close() so
that it's obviously down and the user can then try to bring it up again?

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
