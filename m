From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [patch net-next v4 4/4] igb/igbvf: implement ndo_get_phys_port_id
Date: Thu, 25 Jul 2013 09:17:35 -0700
Message-ID: <51F14F9F.1010703@intel.com>
References: <1374757385-10875-1-git-send-email-jiri@resnulli.us> <1374757385-10875-5-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	stephen@networkplumber.org, Narendra_K@Dell.com,
	bhutchings@solarflare.com, john.r.fastabend@intel.com,
	or.gerlitz@gmail.com, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@intel.com, bruce.w.allan@intel.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	gregory.v.rose@intel.com, peter.p.waskiewicz.jr@intel.com,
	john.ronciak@intel.com, tushar.n.dave@intel.com,
	matthew.vick@intel.com, mitch.a.williams@intel.com,
	vyasevic@redhat.com, amwang@redhat.com, johannes@sipsolutions.net
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:41678 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753924Ab3GYQRg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Jul 2013 12:17:36 -0400
In-Reply-To: <1374757385-10875-5-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/25/2013 06:03 AM, Jiri Pirko wrote:
> @@ -1982,6 +2001,21 @@ static s32 igb_init_i2c(struct igb_adapter *adapter)
>  	return status;
>  }
>  
> +static void igb_compute_phys_port_id(struct igb_adapter *adapter)
> +{
> +	adapter->phys_port_id = *((u32 *) adapter->netdev->dev_addr);
> +	adapter->phys_port_id ^= *((u32 *) adapter->netdev->dev_addr + 4);
> +	adapter->phys_port_id ^= (long) adapter;
> +	adapter->phys_port_id ^= (long) adapter->hw.hw_addr;
> +	adapter->phys_port_id ^= (long) adapter->hw.flash_address;
> +	adapter->phys_port_id ^= (u32) adapter->hw.io_base;
> +	adapter->phys_port_id ^= adapter->hw.device_id;
> +	adapter->phys_port_id ^= adapter->hw.subsystem_vendor_id;
> +	adapter->phys_port_id ^= adapter->hw.subsystem_device_id;
> +	adapter->phys_port_id ^= adapter->hw.vendor_id;
> +	adapter->phys_port_id ^= adapter->hw.revision_id;
> +}
> +
>  /**
>   *  igb_probe - Device Initialization Routine
>   *  @pdev: PCI device information struct

I really think this bit here should be standardized and made available
to all drivers.  If nothing else maybe you should define a function that
takes in the netdev and the pci_dev and computes the hash based on those
values.  Otherwise you are going to end up with each driver doing its'
own version of this function and that will make things rather messy.

Also the port_id has a high likelihood of most fields canceling each
other out.  For example, I'm not sure if you really want to try and find
the offset of the hw_addr within the adapter structure but that is
likely what you are getting by casting the adapter pointer and he
hw_addr arrary as longs and XORing them together.  From what I can tell
the only fields that are providing any real value in distinguishing
between ports on a 4 port adapter would be the dev_addr, flash_address,
and io_base.

Thanks,

Alex
