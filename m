From: Brad House <brad@mcve.com>
Subject: Re: [PATCH] 2.6.0-test9-bk27-netdrvr-exp1 - r8169 update
Date: Sun, 23 Nov 2003 18:18:48 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FC14058.4010600@mcve.com>
References: <20031122183001.GA16993@gtf.org> <20031124000939.A456@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Jeff Garzik <jgarzik@pobox.com>, brad_mssw@gentoo.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20031124000939.A456@electric-eye.fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

cool. Did those previous patches you posted get merged into the
current netdrvr-exp1, or do those need to be applied as well ?

I'm going to see if I can test this out tonight...

-Brad

Francois Romieu wrote:
> Jeff Garzik <jgarzik@pobox.com> :
> [...]
> 
>>* r8169 stuff from Francois
> 
> 
> First round of merge of Brad/Realtek's stuff.
> 
> Applies on top of bk27 + bk25-netdrvr-exp1.
> 
> --
> Ueimor
> 
> 
> ------------------------------------------------------------------------
> 
> 
> Add {mac/phy}_version.
> - change of identification logic in rtl8169_init_board();
> - {chip/rtl_chip}_info are merged in rtl_chip_info;
> - misc style nits (lazy braces, SHOUTING MACROS from realtek converted to
>   functions).
> 
> 
>  drivers/net/r8169.c |  177 +++++++++++++++++++++++++++++++++++++++++-----------
>  1 files changed, 140 insertions(+), 37 deletions(-)
> 
> diff -puN drivers/net/r8169.c~r8169-mac-phy-version drivers/net/r8169.c
> --- linux-2.6.0-test9-bk27-netdrvr-exp1/drivers/net/r8169.c~r8169-mac-phy-version	2003-11-24 00:07:21.000000000 +0100
> +++ linux-2.6.0-test9-bk27-netdrvr-exp1-fr/drivers/net/r8169.c	2003-11-24 00:07:21.000000000 +0100
> @@ -56,9 +56,11 @@ VERSION 1.2	<2002/11/30>
>  	        printk( "Assertion failed! %s,%s,%s,line=%d\n",	\
>          	#expr,__FILE__,__FUNCTION__,__LINE__);		\
>          }
> +#define dprintk(fmt, args...)	do { printk(PFX fmt, ## args) } while (0)
>  #else
>  #define assert(expr) do {} while (0)
> -#endif
> +#define dprintk(fmt, args...)	do {} while (0)
> +#endif /* RTL8169_DEBUG */
>  
>  /* media options */
>  #define MAX_UNITS 8
> @@ -103,11 +105,35 @@ static int multicast_filter_limit = 32;
>  #define RTL_R16(reg)		readw (ioaddr + (reg))
>  #define RTL_R32(reg)		((unsigned long) readl (ioaddr + (reg)))
>  
> -static struct {
> +enum mac_version {
> +	RTL_GIGA_MAC_VER_B = 0x00,
> +	/* RTL_GIGA_MAC_VER_C = 0x03, */
> +	RTL_GIGA_MAC_VER_D = 0x01,
> +	RTL_GIGA_MAC_VER_E = 0x02
> +};
> +
> +enum phy_version {
> +	RTL_GIGA_PHY_VER_C = 0x03, /* PHY Reg 0x03 bit0-3 == 0x0000 */
> +	RTL_GIGA_PHY_VER_D = 0x04, /* PHY Reg 0x03 bit0-3 == 0x0000 */
> +	RTL_GIGA_PHY_VER_E = 0x05, /* PHY Reg 0x03 bit0-3 == 0x0000 */
> +	RTL_GIGA_PHY_VER_F = 0x06, /* PHY Reg 0x03 bit0-3 == 0x0001 */
> +	RTL_GIGA_PHY_VER_G = 0x07, /* PHY Reg 0x03 bit0-3 == 0x0002 */
> +};
> +
> +
> +#define _R(NAME,MAC,MASK) \
> +	{ .name = NAME, .mac_version = MAC, .RxConfigMask = MASK }
> +
> +const static struct {
>  	const char *name;
> -} board_info[] __devinitdata = {
> -	{
> -"RealTek RTL8169 Gigabit Ethernet"},};
> +	u8 mac_version;
> +	u32 RxConfigMask;	/* Clears the bits supported by this chip */
> +} rtl_chip_info[] __devinitdata = {
> +	_R("RTL8169",		RTL_GIGA_MAC_VER_B, 0xff7e1880),
> +	_R("RTL8169s/8110s",	RTL_GIGA_MAC_VER_D, 0xff7e1880),
> +	_R("RTL8169s/8110s",	RTL_GIGA_MAC_VER_E, 0xff7e1880)
> +};
> +#undef _R
>  
>  static struct pci_device_id rtl8169_pci_tbl[] = {
>  	{0x10ec, 0x8169, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
> @@ -246,14 +272,6 @@ enum RTL8169_register_content {
>  	TBILinkOK = 0x02000000,
>  };
>  
> -const static struct {
> -	const char *name;
> -	u8 version;		/* depend on RTL8169 docs */
> -	u32 RxConfigMask;	/* should clear the bits supported by this chip */
> -} rtl_chip_info[] = {
> -	{
> -"RTL-8169", 0x00, 0xff7e1880,},};
> -
>  enum _DescStatusBit {
>  	OWNbit = 0x80000000,
>  	EORbit = 0x40000000,
> @@ -281,6 +299,8 @@ struct rtl8169_private {
>  	struct net_device_stats stats;	/* statistics of net device */
>  	spinlock_t lock;	/* spin lock flag */
>  	int chipset;
> +	int mac_version;
> +	int phy_version;
>  	u32 cur_rx; /* Index into the Rx descriptor buffer of next Rx pkt. */
>  	u32 cur_tx; /* Index into the Tx descriptor buffer of next Rx pkt. */
>  	u32 dirty_rx;
> @@ -347,13 +367,95 @@ mdio_read(void *ioaddr, int RegAddr)
>  		if (RTL_R32(PHYAR) & 0x80000000) {
>  			value = (int) (RTL_R32(PHYAR) & 0xFFFF);
>  			break;
> -		} else {
> -			udelay(100);
>  		}
> +		udelay(100);
>  	}
>  	return value;
>  }
>  
> +static void rtl8169_get_mac_version(struct rtl8169_private *tp, void *ioaddr)
> +{
> +	const struct {
> +		u32 mask;
> +		int mac_version;
> +	} mac_info[] = {
> +		{ 0x1 << 26,	RTL_GIGA_MAC_VER_E },
> +		{ 0x1 << 23,	RTL_GIGA_MAC_VER_D }, 
> +		{ 0x00000000,	RTL_GIGA_MAC_VER_B } /* Catch-all */
> +	}, *p = mac_info;
> +	u32 reg;
> +
> +	reg = RTL_R32(TxConfig) & 0x7c800000;
> +	while ((reg & p->mask) != p->mask)
> +		p++;
> +	tp->mac_version = p->mac_version;
> +}
> +
> +static void rtl8169_print_mac_version(struct rtl8169_private *tp)
> +{
> +	struct {
> +		int version;
> +		char *msg;
> +	} mac_print[] = {
> +		{ RTL_GIGA_MAC_VER_E, "RTL_GIGA_MAC_VER_E" },
> +		{ RTL_GIGA_MAC_VER_D, "RTL_GIGA_MAC_VER_D" },
> +		{ RTL_GIGA_MAC_VER_B, "RTL_GIGA_MAC_VER_B" },
> +		{ 0, NULL }
> +	}, *p;
> +
> +	for (p = mac_print; p->msg; p++) {
> +		if (tp->mac_version == p->version) {
> +			dprintk("mac_version == %s (%04d)\n", p->msg,
> +				  p->version);
> +			return;
> +		}
> +	}
> +	dprintk("mac_version == Unknown\n");
> +}
> +
> +static void rtl8169_get_phy_version(struct rtl8169_private *tp, void *ioaddr)
> +{
> +	const struct {
> +		u16 mask;
> +		u16 set;
> +		int phy_version;
> +	} phy_info[] = {
> +		{ 0x000f, 0x0002, RTL_GIGA_PHY_VER_G },
> +		{ 0x000f, 0x0001, RTL_GIGA_PHY_VER_F },
> +		{ 0x000f, 0x0000, RTL_GIGA_PHY_VER_E },
> +		{ 0x0000, 0x0000, RTL_GIGA_PHY_VER_D } /* Catch-all */
> +	}, *p = phy_info;
> +	u16 reg;
> +
> +	reg = mdio_read(ioaddr, 3) & 0xffff;
> +	while ((reg & p->mask) != p->set)
> +		p++;
> +	tp->phy_version = p->phy_version;
> +}
> +
> +static void rtl8169_print_phy_version(struct rtl8169_private *tp)
> +{
> +	struct {
> +		int version;
> +		char *msg;
> +		u32 reg;
> +	} phy_print[] = {
> +		{ RTL_GIGA_PHY_VER_G, "RTL_GIGA_PHY_VER_G", 0x0002 },
> +		{ RTL_GIGA_PHY_VER_F, "RTL_GIGA_PHY_VER_F", 0x0001 },
> +		{ RTL_GIGA_PHY_VER_E, "RTL_GIGA_PHY_VER_E", 0x0000 },
> +		{ RTL_GIGA_PHY_VER_D, "RTL_GIGA_PHY_VER_D", 0x0000 },
> +		{ 0, NULL, 0x0000 }
> +	}, *p;
> +
> +	for (p = phy_print; p->msg; p++) {
> +		if (tp->phy_version == p->version) {
> +			dprintk("phy_version == %s (%04x)\n", p->msg, p->reg);
> +			return;
> +		}
> +	}
> +	dprintk("phy_version == Unknown\n");
> +}
> +
>  static int __devinit
>  rtl8169_init_board(struct pci_dev *pdev, struct net_device **dev_out,
>  		   void **ioaddr_out)
> @@ -363,7 +465,6 @@ rtl8169_init_board(struct pci_dev *pdev,
>  	struct rtl8169_private *tp;
>  	int rc, i;
>  	unsigned long mmio_start, mmio_end, mmio_flags, mmio_len;
> -	u32 tmp;
>  
>  	assert(pdev != NULL);
>  	assert(ioaddr_out != NULL);
> @@ -425,30 +526,32 @@ rtl8169_init_board(struct pci_dev *pdev,
>  	RTL_W8(ChipCmd, CmdReset);
>  
>  	// Check that the chip has finished the reset.
> -	for (i = 1000; i > 0; i--)
> +	for (i = 1000; i > 0; i--) {
>  		if ((RTL_R8(ChipCmd) & CmdReset) == 0)
>  			break;
> -		else
> -			udelay(10);
> +		udelay(10);
> +	}
>  
> -	// identify chip attached to board
> -	tmp = RTL_R32(TxConfig);
> -	tmp = ((tmp & 0x7c000000) + ((tmp & 0x00800000) << 2)) >> 24;
> -
> -	for (i = ARRAY_SIZE(rtl_chip_info) - 1; i >= 0; i--)
> -		if (tmp == rtl_chip_info[i].version) {
> -			tp->chipset = i;
> -			goto match;
> -		}
> -	//if unknown chip, assume array element #0, original RTL-8169 in this case
> -	printk(KERN_DEBUG PFX
> -	       "PCI device %s: unknown chip version, assuming RTL-8169\n",
> -	       pci_name(pdev));
> -	printk(KERN_DEBUG PFX "PCI device %s: TxConfig = 0x%lx\n",
> -	       pci_name(pdev), (unsigned long) RTL_R32(TxConfig));
> -	tp->chipset = 0;
> +	// Identify chip attached to board
> +	rtl8169_get_mac_version(tp, ioaddr);
> +	rtl8169_get_phy_version(tp, ioaddr);
> +
> +	rtl8169_print_mac_version(tp);
> +	rtl8169_print_phy_version(tp);
> +
> +	for (i = ARRAY_SIZE(rtl_chip_info) - 1; i >= 0; i--) {
> +		if (tp->mac_version == rtl_chip_info[i].mac_version)
> +			break;
> +	}
> +	if (i < 0) {
> +		/* Unknown chip: assume array element #0, original RTL-8169 */
> +		printk(KERN_DEBUG PFX
> +		       "PCI device %s: unknown chip version, assuming %s\n",
> +		       pci_name(pdev), rtl_chip_info[0].name);
> +		i++;
> +	}
> +	tp->chipset = i;
>  
> -match:
>  	*ioaddr_out = ioaddr;
>  	*dev_out = dev;
>  	return 0;
> @@ -533,7 +636,7 @@ rtl8169_init_one(struct pci_dev *pdev, c
>  	       "%2.2x:%2.2x:%2.2x:%2.2x:%2.2x:%2.2x, "
>  	       "IRQ %d\n",
>  	       dev->name,
> -	       board_info[ent->driver_data].name,
> +	       rtl_chip_info[ent->driver_data].name,
>  	       dev->base_addr,
>  	       dev->dev_addr[0], dev->dev_addr[1],
>  	       dev->dev_addr[2], dev->dev_addr[3],
> 
> _
