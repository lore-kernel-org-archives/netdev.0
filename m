From: Brad House <brad@mcve.com>
Subject: r8169 -- bad patch
Date: Tue, 25 Nov 2003 19:55:04 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FC3F9E8.7040403@mcve.com>
References: <20031122183001.GA16993@gtf.org> <20031124000939.A456@electric-eye.fr.zoreil.com> <20031126004550.A25408@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Jeff Garzik <jgarzik@pobox.com>, brad_mssw@gentoo.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20031126004550.A25408@electric-eye.fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

it appears as though the
r8169-start-xmit-fixes.patch
is the culprit for the system lockups ...
After reverting that patch, it went back to vanilla behavior.

-Brad

Francois Romieu wrote:
> More Brad/Realtek's merging. Bugs are mine, of course.
> 
> Applies on top of:
> 2.6.0-test10 + 2.6.0-test9-bk25-netdrvr-exp1 + r8169-mac-phy-version
> 
> Brad, if you haven't found time to identify where the problem happens,
> could you wait 24h before patching anything ? There may be something on the
> radar.
> 
> Thanks.
> 
> --
> Ueimor
> 
> 
> ------------------------------------------------------------------------
> 
> 
> Merge of changes done by Realtek to rtl8169_init_one():
> - phy capability settings allows lower or equal capability as suggested
>   in Realtek's changes;
> - I/O voodoo;
> - no need to s/mdio_write/RTL8169_WRITE_GMII_REG/;
> - s/rtl8169_hw_PHY_config/rtl8169_hw_phy_config/;
> - rtl8169_hw_phy_config(): ad-hoc struct "phy_magic" to limit duplication
>   of code (yep, the u16 -> int conversions should work as expected);
> - variable renames and whitepace changes ignored.
> 
> 
>  drivers/net/r8169.c |  115 ++++++++++++++++++++++++++++++++++++++++++++++++----
>  1 files changed, 107 insertions(+), 8 deletions(-)
> 
> diff -puN drivers/net/r8169.c~r8169-init_one drivers/net/r8169.c
> --- linux-2.6.0-test10/drivers/net/r8169.c~r8169-init_one	2003-11-24 22:55:05.000000000 +0100
> +++ linux-2.6.0-test10-romieu/drivers/net/r8169.c	2003-11-26 00:15:59.000000000 +0100
> @@ -336,6 +336,11 @@ static const u16 rtl8169_intr_mask =
>  static const unsigned int rtl8169_rx_config =
>      (RX_FIFO_THRESH << RxCfgFIFOShift) | (RX_DMA_BURST << RxCfgDMAShift);
>  
> +#define PHY_Cap_10_Half_Or_Less PHY_Cap_10_Half
> +#define PHY_Cap_10_Full_Or_Less PHY_Cap_10_Full | PHY_Cap_10_Half_Or_Less
> +#define PHY_Cap_100_Half_Or_Less PHY_Cap_100_Half | PHY_Cap_10_Full_Or_Less
> +#define PHY_Cap_100_Full_Or_Less PHY_Cap_100_Full | PHY_Cap_100_Half_Or_Less
> +
>  void
>  mdio_write(void *ioaddr, int RegAddr, int value)
>  {
> @@ -373,6 +378,17 @@ mdio_read(void *ioaddr, int RegAddr)
>  	return value;
>  }
>  
> +static void rtl8169_write_gmii_reg_bit(void *ioaddr, int reg, int bitnum,
> +				       int bitval)
> +{
> +	int val;
> +
> +	val = mdio_read(ioaddr, reg);
> +	val = (bitval == 1) ?
> +		val | (bitval << bitnum) :  val & ~(0x0001 << bitnum);
> +	mdio_write(ioaddr, reg, val & 0xffff); 
> +}
> +
>  static void rtl8169_get_mac_version(struct rtl8169_private *tp, void *ioaddr)
>  {
>  	const struct {
> @@ -456,6 +472,74 @@ static void rtl8169_print_phy_version(st
>  	dprintk("phy_version == Unknown\n");
>  }
>  
> +static void rtl8169_hw_phy_config(struct net_device *dev)
> +{
> +	struct rtl8169_private *tp = dev->priv;
> +	void *ioaddr = tp->mmio_addr;
> +	struct {
> +		u16 regs[5]; /* Beware of bit-sign propagation */
> +	} phy_magic[5] = { {
> +		{ 0x0000,	//w 4 15 12 0
> +		  0x00a1,	//w 3 15 0 00a1
> +		  0x0008,	//w 2 15 0 0008
> +		  0x1020,	//w 1 15 0 1020
> +		  0x1000 } },{	//w 0 15 0 1000
> +		{ 0x7000,	//w 4 15 12 7
> +		  0xff41,	//w 3 15 0 ff41
> +		  0xde60,	//w 2 15 0 de60
> +		  0x0140,	//w 1 15 0 0140
> +		  0x0077 } },{	//w 0 15 0 0077
> +		{ 0xa000,	//w 4 15 12 a
> +		  0xdf01,	//w 3 15 0 df01
> +		  0xdf20,	//w 2 15 0 df20
> +		  0xff95,	//w 1 15 0 ff95
> +		  0xfa00 } },{	//w 0 15 0 fa00
> +		{ 0xb000,	//w 4 15 12 b
> +		  0xff41,	//w 3 15 0 ff41
> +		  0xde20,	//w 2 15 0 de20
> +		  0x0140,	//w 1 15 0 0140
> +		  0x00bb } },{	//w 0 15 0 00bb
> +		{ 0xf000,	//w 4 15 12 f
> +		  0xdf01,	//w 3 15 0 df01
> +		  0xdf20,	//w 2 15 0 df20
> +		  0xff95,	//w 1 15 0 ff95
> +		  0xbf00 }	//w 0 15 0 bf00
> +		}
> +	}, *p = phy_magic;
> +	int i;
> +
> +	rtl8169_print_mac_version(tp);
> +	rtl8169_print_phy_version(tp);
> +
> +	if (tp->mac_version <= RTL_GIGA_MAC_VER_B)
> +		return;
> +	if (tp->phy_version >= RTL_GIGA_PHY_VER_F) 
> +		return;
> +
> +	dprintk("MAC version != 0 && PHY version == 0 or 1\n");
> +	dprintk("Do final_reg2.cfg\n");
> +
> +	/* Shazam ! */
> +
> +	// phy config for RTL8169s mac_version C chip
> +	mdio_write(ioaddr, 31, 0x0001);			//w 31 2 0 1
> +	mdio_write(ioaddr, 21, 0x1000);			//w 21 15 0 1000
> +	mdio_write(ioaddr, 24, 0x65c7);			//w 24 15 0 65c7
> +	rtl8169_write_gmii_reg_bit(ioaddr, 4, 11, 0);	//w 4 11 11 0
> +
> +	for (i = ARRAY_SIZE(phy_magic); i > 0; i++, p++) {
> +		int val, pos = 4;
> +
> +		val = (mdio_read(ioaddr, pos) & 0x0fff) | (p->regs[0] & 0xffff);
> +		mdio_write(ioaddr, pos, val);
> +		while (--pos >= 0)
> +			mdio_write(ioaddr, pos, p->regs[4 - pos] & 0xffff);
> +		rtl8169_write_gmii_reg_bit(ioaddr, 4, 11, 1); //w 4 11 11 1
> +		rtl8169_write_gmii_reg_bit(ioaddr, 4, 11, 0); //w 4 11 11 0
> +	}
> +	mdio_write(ioaddr, 31, 0x0000); //w 31 2 0 0
> +}
> +
>  static int __devinit
>  rtl8169_init_board(struct pci_dev *pdev, struct net_device **dev_out,
>  		   void **ioaddr_out)
> @@ -642,6 +726,23 @@ rtl8169_init_one(struct pci_dev *pdev, c
>  	       dev->dev_addr[2], dev->dev_addr[3],
>  	       dev->dev_addr[4], dev->dev_addr[5], dev->irq);
>  
> +	rtl8169_hw_phy_config(dev);
> +
> +	dprintk("Set MAC Reg C+CR Offset 0x82h = 0x01h\n");
> +	RTL_W8(0x82, 0x01);
> +
> +	if (tp->mac_version < RTL_GIGA_MAC_VER_E) {
> +		dprintk("Set PCI Latency=0x40\n");
> +		pci_write_config_byte(pdev, PCI_LATENCY_TIMER, 0x40);
> +	}
> +
> +	if (tp->mac_version == RTL_GIGA_MAC_VER_D) {
> +		dprintk("Set MAC Reg C+CR Offset 0x82h = 0x01h\n");
> +		RTL_W8(0x82, 0x01);
> +		dprintk("Set PHY Reg 0x0bh = 0x00h\n");
> +		mdio_write(ioaddr, 0x0b, 0x0000); //w 0x0b 15 0 0
> +	}
> +
>  	// if TBI is not endbled
>  	if (!(RTL_R8(PHYstatus) & TBI_Enable)) {
>  		int val = mdio_read(ioaddr, PHY_AUTO_NEGO_REG);
> @@ -654,23 +755,23 @@ rtl8169_init_one(struct pci_dev *pdev, c
>  			Cap10_100 = 0, Cap1000 = 0;
>  			switch (option) {
>  			case _10_Half:
> -				Cap10_100 = PHY_Cap_10_Half;
> +				Cap10_100 = PHY_Cap_10_Half_Or_Less;
>  				Cap1000 = PHY_Cap_Null;
>  				break;
>  			case _10_Full:
> -				Cap10_100 = PHY_Cap_10_Full;
> +				Cap10_100 = PHY_Cap_10_Full_Or_Less;
>  				Cap1000 = PHY_Cap_Null;
>  				break;
>  			case _100_Half:
> -				Cap10_100 = PHY_Cap_100_Half;
> +				Cap10_100 = PHY_Cap_100_Half_Or_Less;
>  				Cap1000 = PHY_Cap_Null;
>  				break;
>  			case _100_Full:
> -				Cap10_100 = PHY_Cap_100_Full;
> +				Cap10_100 = PHY_Cap_100_Full_Or_Less;
>  				Cap1000 = PHY_Cap_Null;
>  				break;
>  			case _1000_Full:
> -				Cap10_100 = PHY_Cap_Null;
> +				Cap10_100 = PHY_Cap_100_Full_Or_Less;
>  				Cap1000 = PHY_Cap_1000_Full;
>  				break;
>  			default:
> @@ -684,9 +785,7 @@ rtl8169_init_one(struct pci_dev *pdev, c
>  
>  			// enable 10/100 Full/Half Mode, leave PHY_AUTO_NEGO_REG bit4:0 unchanged
>  			mdio_write(ioaddr, PHY_AUTO_NEGO_REG,
> -				   PHY_Cap_10_Half | PHY_Cap_10_Full |
> -				   PHY_Cap_100_Half | PHY_Cap_100_Full | (val &
> -									  0x1F));
> +				   PHY_Cap_100_Full_Or_Less | (val & 0x1f));
>  
>  			// enable 1000 Full Mode
>  			mdio_write(ioaddr, PHY_1000_CTRL_REG,
> 
> _
