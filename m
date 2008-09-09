From: Jesse Barnes <jbarnes@virtuousgeek.org>
Subject: Re: [PATCH 3/3] sky2: use pci_read_vpd to read info during boot
Date: Mon, 8 Sep 2008 21:36:40 -0700
Message-ID: <200809082136.40341.jbarnes@virtuousgeek.org>
References: <20080827204626.4b65862f@extreme> <20080903160017.299831b0@extreme> <48BF8FE9.6060309@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-pci@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <48BF8FE9.6060309@garzik.org>
Content-Disposition: inline
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday, September 04, 2008 12:36 am Jeff Garzik wrote:
> Stephen Hemminger wrote:
> > Change sky2 driver (in netdev next tree) to use vpd access routines.
> >
> > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> >
> > Note: other usage of vpd internal access routines will go away in later
> > patches.
> >
> > ---
> > Patch against netdev-2.6#upstream-next assumes the previous PCI API
> > change.
> >
> > --- a/drivers/net/sky2.c	2008-09-03 11:35:47.000000000 -0700
> > +++ b/drivers/net/sky2.c	2008-09-03 11:44:06.000000000 -0700
> > @@ -4199,10 +4199,9 @@ static int __devinit pci_wake_enabled(st
> >
> >  static void __devinit sky2_vpd_info(struct sky2_hw *hw)
> >  {
> > -	int cap = pci_find_capability(hw->pdev, PCI_CAP_ID_VPD);
> > -	const u8 *p;
> > -	u8 *vpd_buf = NULL;
> > -	u16 len;
> > +	loff_t offs;
> > +	u8 len;
> > +	u8 tag[3];
> >  	static struct vpd_tag {
> >  		char tag[2];
> >  		char *label;
> > @@ -4211,47 +4210,48 @@ static void __devinit sky2_vpd_info(stru
> >  		{ "EC", "Engineering Level" },
> >  		{ "MN", "Manufacturer" },
> >  	};
> > +	char str[128];
> >
> > -	if (!cap)
> > -		goto out;
> > -
> > -	vpd_buf = kmalloc(VPD_SIZE, GFP_KERNEL);
> > -	if (!vpd_buf)
> > -		goto out;
> > +	if (pci_read_vpd(hw->pdev, 0, sizeof(tag), tag) < 0)
> > +		return;
> > +	if (tag[0] != VPD_MAGIC)
> > +		return;
> > +	len = tag[1];
> > +	if (len == 0 || len > sizeof(str))
> > +		return;
> >
> > -	if (sky2_vpd_read(hw, cap, vpd_buf, 0, VPD_SIZE))
> > -		goto out;
> > +	offs = 3;
> > +	if (pci_read_vpd(hw->pdev, offs, len, str) < 0)
> > +		return;
> >
> > -	if (vpd_buf[0] != VPD_MAGIC)
> > -		goto out;
> > -	len = vpd_buf[1];
> > -	if (len == 0 || len > VPD_SIZE - 4)
> > -		goto out;
> > -	p = vpd_buf + 3;
> > -	dev_info(&hw->pdev->dev, "%.*s\n", len, p);
> > -	p += len;
> > +	dev_info(&hw->pdev->dev, "%.*s\n", len, str);
> >
> > -	while (p < vpd_buf + VPD_SIZE - 4) {
> > +	for(;;) {
> >  		int i;
> >
> > -		if (!memcmp("RW", p, 2))	/* end marker */
> > +		offs += len;
> > +		if (pci_read_vpd(hw->pdev, offs, sizeof(tag), tag) < 0)
> >  			break;
> >
> > -		len = p[2];
> > -		if (len > (p - vpd_buf) - 4)
> > +		if (!memcmp("RW", tag, 2))	/* end marker */
> > +			break;
> > +
> > +		offs += sizeof(tag);
> > +		len = tag[2];
> > +		if (len > sizeof(str))
> >  			break;
> >
> >  		for (i = 0; i < ARRAY_SIZE(vpd_tags); i++) {
> > -			if (!memcmp(vpd_tags[i].tag, p, 2)) {
> > +			if (!memcmp(vpd_tags[i].tag, tag, 2)) {
> > +				if (pci_read_vpd(hw->pdev, offs, len, str) < 0)
> > +					return;
> > +
> >  				printk(KERN_DEBUG " %s: %.*s\n",
> > -				       vpd_tags[i].label, len, p + 3);
> > +				       vpd_tags[i].label, len, str);
> >  				break;
> >  			}
> >  		}
> > -		p += len + 3;
> >  	}
> > -out:
> > -	kfree(vpd_buf);
> >  }
>
> Acked-by: me
>
> I presume this will go via PCI tree?

The sky2 bits too?  Sure, that's fine with me.  I'll stuff it into my 
linux-next tree tomorrow after a quick look.

Thanks,
Jesse
