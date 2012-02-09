From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 2/2] rename dev_hw_addr_random and remove redundant
 second
Date: Thu, 9 Feb 2012 20:11:30 +0000
Message-ID: <1328818290.2562.19.camel@bwh-desktop>
References: <1328816934-11508-1-git-send-email-danny.kukawka@bisect.de>
	 <1328816934-11508-3-git-send-email-danny.kukawka@bisect.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Danny Kukawka <dkukawka@suse.de>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Alex Duyck <alexander.h.duyck@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>,
	Jiri Pirko <jpirko@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	<e1000-devel@lists.sourceforge.net>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Danny Kukawka <danny.kukawka@bisect.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1328816934-11508-3-git-send-email-danny.kukawka@bisect.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2012-02-09 at 20:48 +0100, Danny Kukawka wrote:
> Renamed dev_hw_addr_random to eth_hw_addr_random() to reflect that
> this function only assign a random ethernet address (MAC). Removed
> the second parameter (u8 *hwaddr), it's redundant since the also
> given net_device already contains net_device->dev_addr.
> Set it directly.
> 
> Adapt igbvf and ixgbevf to the changed function.
[...]
> --- a/drivers/net/ethernet/intel/igbvf/netdev.c
> +++ b/drivers/net/ethernet/intel/igbvf/netdev.c
> @@ -2695,18 +2695,19 @@ static int __devinit igbvf_probe(struct pci_dev *pdev,
>  		dev_info(&pdev->dev,
>  			 "PF still in reset state, assigning new address."
>  			 " Is the PF interface up?\n");
> -		dev_hw_addr_random(adapter->netdev, hw->mac.addr);
> +		eth_hw_addr_random(netdev);
> +		memcpy(adapter->hw.mac.addr, netdev->dev_addr,
> +			netdev->addr_len);
>  	} else {
>  		err = hw->mac.ops.read_mac_addr(hw);
>  		if (err) {
>  			dev_err(&pdev->dev, "Error reading MAC address\n");
>  			goto err_hw_init;
>  		}
> +		memcpy(netdev->dev_addr, adapter->hw.mac.addr,
> +			netdev->addr_len);
>  	}
>  
> -	memcpy(netdev->dev_addr, adapter->hw.mac.addr, netdev->addr_len);
> -	memcpy(netdev->perm_addr, adapter->hw.mac.addr, netdev->addr_len);
> -
>  	if (!is_valid_ether_addr(netdev->perm_addr)) {
>  		dev_err(&pdev->dev, "Invalid MAC Address: %pM\n",
>  		        netdev->dev_addr);
> @@ -2714,6 +2715,8 @@ static int __devinit igbvf_probe(struct pci_dev *pdev,
>  		goto err_hw_init;
>  	}
>  
> +	memcpy(netdev->perm_addr, adapter->hw.mac.addr, netdev->addr_len);
[...]

I wonder whether VF drivers should claim to have a permanent address at
all, let alone setting the 'permanent' address to a randomly generated
address.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
