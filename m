From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 3/3] sky2: use pci_read_vpd to read info during boot
Date: Thu, 04 Sep 2008 03:36:09 -0400
Message-ID: <48BF8FE9.6060309@garzik.org>
References: <20080827204626.4b65862f@extreme>	<20080828111323.GI7908@solarflare.com>	<20080903155316.1a0a5698@extreme>	<20080903155700.7517d8d9@extreme> <20080903160017.299831b0@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Jesse Barnes <jbarnes@virtuousgeek.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-pci@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20080903160017.299831b0@extreme>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> Change sky2 driver (in netdev next tree) to use vpd access routines.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> Note: other usage of vpd internal access routines will go away in later patches.
> 
> ---
> Patch against netdev-2.6#upstream-next assumes the previous PCI API change.
> 
> --- a/drivers/net/sky2.c	2008-09-03 11:35:47.000000000 -0700
> +++ b/drivers/net/sky2.c	2008-09-03 11:44:06.000000000 -0700
> @@ -4199,10 +4199,9 @@ static int __devinit pci_wake_enabled(st
>  
>  static void __devinit sky2_vpd_info(struct sky2_hw *hw)
>  {
> -	int cap = pci_find_capability(hw->pdev, PCI_CAP_ID_VPD);
> -	const u8 *p;
> -	u8 *vpd_buf = NULL;
> -	u16 len;
> +	loff_t offs;
> +	u8 len;
> +	u8 tag[3];
>  	static struct vpd_tag {
>  		char tag[2];
>  		char *label;
> @@ -4211,47 +4210,48 @@ static void __devinit sky2_vpd_info(stru
>  		{ "EC", "Engineering Level" },
>  		{ "MN", "Manufacturer" },
>  	};
> +	char str[128];
>  
> -	if (!cap)
> -		goto out;
> -
> -	vpd_buf = kmalloc(VPD_SIZE, GFP_KERNEL);
> -	if (!vpd_buf)
> -		goto out;
> +	if (pci_read_vpd(hw->pdev, 0, sizeof(tag), tag) < 0)
> +		return;
> +	if (tag[0] != VPD_MAGIC)
> +		return;
> +	len = tag[1];
> +	if (len == 0 || len > sizeof(str))
> +		return;
>  
> -	if (sky2_vpd_read(hw, cap, vpd_buf, 0, VPD_SIZE))
> -		goto out;
> +	offs = 3;
> +	if (pci_read_vpd(hw->pdev, offs, len, str) < 0)
> +		return;
>  
> -	if (vpd_buf[0] != VPD_MAGIC)
> -		goto out;
> -	len = vpd_buf[1];
> -	if (len == 0 || len > VPD_SIZE - 4)
> -		goto out;
> -	p = vpd_buf + 3;
> -	dev_info(&hw->pdev->dev, "%.*s\n", len, p);
> -	p += len;
> +	dev_info(&hw->pdev->dev, "%.*s\n", len, str);
>  
> -	while (p < vpd_buf + VPD_SIZE - 4) {
> +	for(;;) {
>  		int i;
>  
> -		if (!memcmp("RW", p, 2))	/* end marker */
> +		offs += len;
> +		if (pci_read_vpd(hw->pdev, offs, sizeof(tag), tag) < 0)
>  			break;
>  
> -		len = p[2];
> -		if (len > (p - vpd_buf) - 4)
> +		if (!memcmp("RW", tag, 2))	/* end marker */
> +			break;
> +
> +		offs += sizeof(tag);
> +		len = tag[2];
> +		if (len > sizeof(str))
>  			break;
>  
>  		for (i = 0; i < ARRAY_SIZE(vpd_tags); i++) {
> -			if (!memcmp(vpd_tags[i].tag, p, 2)) {
> +			if (!memcmp(vpd_tags[i].tag, tag, 2)) {
> +				if (pci_read_vpd(hw->pdev, offs, len, str) < 0)
> +					return;
> +
>  				printk(KERN_DEBUG " %s: %.*s\n",
> -				       vpd_tags[i].label, len, p + 3);
> +				       vpd_tags[i].label, len, str);
>  				break;
>  			}
>  		}
> -		p += len + 3;
>  	}
> -out:
> -	kfree(vpd_buf);
>  }

Acked-by: me

I presume this will go via PCI tree?
