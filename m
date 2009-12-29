From: Grant Grundler <grundler@parisc-linux.org>
Subject: Re: [PATCH] dmfe/tulip: Let dmfe handle DM910x except for SPARC
	on-board chips
Date: Tue, 29 Dec 2009 11:41:52 -0700
Message-ID: <20091229184151.GA20122@lackof.org>
References: <da824cf30911300914p2d08b87cr4625e9bc30ec7e5b@mail.gmail.com> <20091130.122642.113956563.davem@davemloft.net> <20091130222219.GA8073@jenkins.domain_not_set.invalid> <20091130.142925.23220838.davem@davemloft.net> <20091229182228.GE20379@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, brandon@ifup.org,
	grundler@google.com, tobias@ringis.se, kyle@mcmartin.ca,
	netdev@vger.kernel.org, grundler@parisc-linux.org
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from complete.lackof.org ([198.49.126.79]:34310 "EHLO
	complete.lackof.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752069AbZL2Slx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Dec 2009 13:41:53 -0500
Content-Disposition: inline
In-Reply-To: <20091229182228.GE20379@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 29, 2009 at 06:22:28PM +0000, Ben Hutchings wrote:
> The Davicom DM9100 and DM9102 chips are used on the motherboards of
> some SPARC systems (supported by the tulip driver) and also in PCI
> expansion cards (supported by the dmfe driver).  There is no
> difference in the PCI device ids for the two different configurations,
> so these drivers both claim the device ids.  However, it is possible
> to distinguish the two configurations by the presence of Open Firmware
> properties for them, so we do that.
> 
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>

Acked-by: Grant Grundler <grundler@parisc-linux.org>

I've reviewed the code and it looks fine to me.

Only thing I'm not sure about is if "KERN_ERR" is
the right priority for what are essentially warning
messages. Not harmful. But could be annoying to some
Sparc users who get this on every boot when both modules
are present and loaded in the "wrong" order.

thanks!
grant

> ---
> On Mon, 2009-11-30 at 14:29 -0800, David Miller wrote:
> > From: Brandon Philips <brandon@ifup.org>
> > Date: Mon, 30 Nov 2009 14:22:20 -0800
> > 
> > > On 12:26 Mon 30 Nov 2009, David Miller wrote:
> > >> From: Grant Grundler <grundler@google.com>
> > >> Date: Mon, 30 Nov 2009 09:14:01 -0800
> > >> > Has anyone posted "lspci -v" output for the "Netra X1 and Sunfire
> > >> > V100" motherboards?
> > >> > 
> > >> > I'm asking because I'm hoping it's possible to disambiguate the add-on
> > >> > cards from
> > >> > LAN-on-Motherboard cases by looking at subsystem vendor and device IDs as well.
> > >> 
> > >>             subsystem-id:  0000434e
> > >>             subsystem-vendor-id:  00004554
> > >>
> > >> Hmmm, what vendor is '0x4554'? :-)
> > > 
> > > Whoever it is it is the same as the expansion card on non-sparc
> > > boards: SubVendor: pci 0x4554 [1]
> > > 
> > > Hrm, dead end I guess.
> > 
> > We still have the OF properties.  So we can simply look for
> > merely the existence of a 'compatible' OF property on the
> > device and from that we'll know that it's a Sparc onboard
> > instance of this thing.
> 
> Here's my attempt at solving this.  It is untested since I do not have
> any DM910x hardware.  It will need to be tested on SPARC for both
> configurations (on-board vs expansion card).
> 
> The DM9100 revision check in tulip is probably redundant, but I have
> left it in place.

I think it's fine.

> 
> Dave, does the OF property check look reasonable?  I have never dealt
> with OF before.
> 
> Ben.
> 
>  drivers/net/tulip/Kconfig      |    4 ++++
>  drivers/net/tulip/dmfe.c       |   18 ++++++++++++++++++
>  drivers/net/tulip/tulip_core.c |   30 ++++++++++++++++++++++++------
>  3 files changed, 46 insertions(+), 6 deletions(-)
> 
> diff --git a/drivers/net/tulip/Kconfig b/drivers/net/tulip/Kconfig
> index 1cc8cf4..516713f 100644
> --- a/drivers/net/tulip/Kconfig
> +++ b/drivers/net/tulip/Kconfig
> @@ -101,6 +101,10 @@ config TULIP_NAPI_HW_MITIGATION
>  
>  	  If in doubt, say Y.
>  
> +config TULIP_DM910X
> +	def_bool y
> +	depends on TULIP && SPARC
> +
>  config DE4X5
>  	tristate "Generic DECchip & DIGITAL EtherWORKS PCI/EISA"
>  	depends on PCI || EISA
> diff --git a/drivers/net/tulip/dmfe.c b/drivers/net/tulip/dmfe.c
> index ad63621..004d285 100644
> --- a/drivers/net/tulip/dmfe.c
> +++ b/drivers/net/tulip/dmfe.c
> @@ -377,6 +377,24 @@ static int __devinit dmfe_init_one (struct pci_dev *pdev,
>  	if (!printed_version++)
>  		printk(version);
>  
> +	/*
> +	 *	SPARC on-board DM910x chips should be handled by the main
> +	 *	tulip driver, except for early DM9100s.
> +	 */
> +#ifdef CONFIG_TULIP_DM910X
> +	if (ent->driver_data == PCI_DM9100_ID && pdev->revision >= 0x30 ||
> +	    ent->driver_data == PCI_DM9102_ID) {
> +		struct device_node *dp = pci_device_to_OF_node(pdev);
> +		int len;
> +
> +		if (dp && of_get_property(dp, "local-mac-address", &len)) {
> +			printk(KERN_ERR DRV_NAME
> +			       ": skipping on-board DM910x (use tulip)\n");
> +			return -ENODEV;
> +		}
> +	}
> +#endif
> +
>  	/* Init network device */
>  	dev = alloc_etherdev(sizeof(*db));
>  	if (dev == NULL)
> diff --git a/drivers/net/tulip/tulip_core.c b/drivers/net/tulip/tulip_core.c
> index 0fa3140..e9d1cf0 100644
> --- a/drivers/net/tulip/tulip_core.c
> +++ b/drivers/net/tulip/tulip_core.c
> @@ -196,9 +196,13 @@ struct tulip_chip_table tulip_tbl[] = {
>  	| HAS_NWAY | HAS_PCI_MWI, tulip_timer, tulip_media_task },
>  
>    /* DM910X */
> +#ifdef CONFIG_TULIP_DM910X
>    { "Davicom DM9102/DM9102A", 128, 0x0001ebef,
>  	HAS_MII | HAS_MEDIA_TABLE | CSR12_IN_SROM | HAS_ACPI,
>  	tulip_timer, tulip_media_task },
> +#else
> +  { NULL },
> +#endif
>  
>    /* RS7112 */
>    { "Conexant LANfinity", 256, 0x0001ebef,
> @@ -228,8 +232,10 @@ static struct pci_device_id tulip_pci_tbl[] = {
>  	{ 0x1259, 0xa120, PCI_ANY_ID, PCI_ANY_ID, 0, 0, COMET },
>  	{ 0x11F6, 0x9881, PCI_ANY_ID, PCI_ANY_ID, 0, 0, COMPEX9881 },
>  	{ 0x8086, 0x0039, PCI_ANY_ID, PCI_ANY_ID, 0, 0, I21145 },
> +#ifdef CONFIG_TULIP_DM910X
>  	{ 0x1282, 0x9100, PCI_ANY_ID, PCI_ANY_ID, 0, 0, DM910X },
>  	{ 0x1282, 0x9102, PCI_ANY_ID, PCI_ANY_ID, 0, 0, DM910X },
> +#endif
>  	{ 0x1113, 0x1216, PCI_ANY_ID, PCI_ANY_ID, 0, 0, COMET },
>  	{ 0x1113, 0x1217, PCI_ANY_ID, PCI_ANY_ID, 0, 0, MX98715 },
>  	{ 0x1113, 0x9511, PCI_ANY_ID, PCI_ANY_ID, 0, 0, COMET },
> @@ -1299,18 +1305,30 @@ static int __devinit tulip_init_one (struct pci_dev *pdev,
>  	}
>  
>  	/*
> -	 *	Early DM9100's need software CRC and the DMFE driver
> +	 *	DM910x chips should be handled by the dmfe driver, except
> +	 *	on-board chips on SPARC systems.  Also, early DM9100s need
> +	 *	software CRC which only the dmfe driver supports.
>  	 */
>  
> -	if (pdev->vendor == 0x1282 && pdev->device == 0x9100)
> -	{
> -		/* Read Chip revision */
> -		if (pdev->revision < 0x30)
> -		{
> +#ifdef CONFIG_TULIP_DM910X
> +	if (chip_idx == DM910X) {
> +		struct device_node *dp;
> +		int len;
> +
> +		if (pdev->vendor == 0x1282 && pdev->device == 0x9100 &&
> +		    pdev->revision < 0x30) {
>  			printk(KERN_ERR PFX "skipping early DM9100 with Crc bug (use dmfe)\n");
>  			return -ENODEV;
>  		}
> +
> +		dp = pci_device_to_OF_node(pdev);
> +		if (!(dp && of_get_property(dp, "local-mac-address", &len))) {
> +			printk(KERN_ERR PFX
> +			       "skipping DM910x expansion card (use dmfe)\n");
> +			return -ENODEV;
> +		}
>  	}
> +#endif
>  
>  	/*
>  	 *	Looks for early PCI chipsets where people report hangs
> -- 
> 1.6.5.7
> 
