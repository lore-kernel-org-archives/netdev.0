From: Martin Capitanio <c4p7n@capitanio.org>
Subject: Re: [PATCH 2/2] r8169: checks against wrong mac addresse init
Date: Fri, 17 Oct 2008 19:47:51 +0200
Message-ID: <1224265672.17605.27.camel@marvin>
References: <20081016214555.GA27208@electric-eye.fr.zoreil.com>
	 <20081016214808.GC27208@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	jeff@garzik.org, Edward Hsu <edward_hsu@realtek.com.tw>,
	Ivan Vecera <ivecera@redhat.com>,
	Petr Vandrovec <petr@vandrovec.name>,
	Plamen Petrov <pvp-lsts@fs.ru.acad.bg>,
	"J.A." =?ISO-8859-1?Q?Magall=F3n?= <jamagallon@ono.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.161]:22788 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756361AbYJQRtL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Oct 2008 13:49:11 -0400
In-Reply-To: <20081016214808.GC27208@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-10-16 at 23:48 +0200, Francois Romieu wrote:
> Checking the signature of the eeprom and the validity of the
> MAC address should be enough to filter out the bad addresses
> observed so far.
> 
> Contributed by Ivan Vecera and Martin Capitanio.

-Tested on 8102el, 8168b and 8169 for a start.
+Tested on 8102e, 8168b and 8169 for a start.
XID 34a00000

Please take a look at the realtek r8101_n aka RealTek RTL8101E,
RTL8102E(L) code. Only CFG_METHOD_1, CFG_METHOD_2
and #(ioaddr, 0x00) == 0x8128 are here allowed to EEPROM access.

Thanks,
Martin


static void 
rtl8101_get_mac_version(struct rtl8101_private *tp, 
			void __iomem *ioaddr)
{
	u32 reg,val32;
	u32 ICVerID;
		
	val32 = RTL_R32(TxConfig);	
	reg = val32 & 0x7c800000;
	ICVerID = val32 & 0x00700000;

	switch (reg) {
		case 0x34000000:
			if (ICVerID == 0x00000000)
				tp->mcfg = CFG_METHOD_1;
			else if (ICVerID == 0x00200000)
				tp->mcfg = CFG_METHOD_2;
			else if (ICVerID == 0x00300000)
				tp->mcfg = CFG_METHOD_6;
			else
				tp->mcfg = CFG_METHOD_6;
			break;
		case 0x34800000: //RTL8102E
		case 0x24800000: //RTL8102EL
			if (ICVerID == 0x00000000)
				tp->mcfg = CFG_METHOD_3;
			else if (ICVerID == 0x00100000)
				tp->mcfg = CFG_METHOD_4;
			else if (ICVerID == 0x00200000)
				tp->mcfg = CFG_METHOD_5;
			else
				tp->mcfg = CFG_METHOD_5;
			break;
		default:
			tp->mcfg = 0;
			printk("unknown chip version (%x)\n",reg);
			break;
	}

}

static void
rtl8101_check_eeprom(struct rtl8101_private *tp)
{
	void __iomem *ioaddr = tp->mmio_addr;
	u32 mac_addr_1 = 0;
	u32 mac_addr_2 = 0;

	if ((tp->mcfg != CFG_METHOD_1) && (tp->mcfg != CFG_METHOD_2))
		return;

	if (rtl_eeprom_read_sc(ioaddr, 0x00) != 0x8128)
		return;

	RTL_W8(Cfg9346, Cfg9346_Unlock);
	RTL_W8(Config5, RTL_R8(Config5) & ~UWF);
	RTL_W8(Cfg9346, Cfg9346_Lock);

	rtl_eeprom_write_sc(ioaddr, 0x00, 0x8129);

	RTL_W8(Cfg9346, Cfg9346_EEM0);
	mdelay(15);
	rtl_eeprom_write_sc(ioaddr, 0x00, 0x8128);

	mac_addr_1 = rtl_eeprom_read_sc(ioaddr, 0x08);
	mac_addr_1 = mac_addr_1 << 16;

	mac_addr_2 = rtl_eeprom_read_sc(ioaddr, 0x07);
	mac_addr_1 |= mac_addr_2;

	RTL_W8(Cfg9346, Cfg9346_Unlock);
	RTL_W32(MAC0, mac_addr_1);
	RTL_W8(Cfg9346, Cfg9346_Lock);

	mac_addr_1 = 0;
	mac_addr_1 = rtl_eeprom_read_sc(ioaddr, 0x09);

	RTL_W8(Cfg9346, Cfg9346_Unlock);
	RTL_W32(MAC4, mac_addr_1);
	RTL_W8(Cfg9346, Cfg9346_Lock);
}



> 
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> Cc: Edward Hsu <edward_hsu@realtek.com.tw>
> ---
>  drivers/net/r8169.c |   22 ++++++++++++++++++----
>  1 files changed, 18 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
> index cd9a215..2b4e975 100644
> --- a/drivers/net/r8169.c
> +++ b/drivers/net/r8169.c
> @@ -81,6 +81,10 @@ static const int multicast_filter_limit = 32;
>  #define RTL8169_TX_TIMEOUT	(6*HZ)
>  #define RTL8169_PHY_TIMEOUT	(10*HZ)
>  
> +#define RTL_EEPROM_SIG		cpu_to_le32(0x8129)
> +#define RTL_EEPROM_SIG_MASK	cpu_to_le32(0xffff)
> +#define RTL_EEPROM_SIG_ADDR	0x0000
> +
>  /* write/read MMIO register */
>  #define RTL_W8(reg, val8)	writeb ((val8), ioaddr + (reg))
>  #define RTL_W16(reg, val16)	writew ((val16), ioaddr + (reg))
> @@ -1944,9 +1948,10 @@ static void rtl_init_mac_address(struct rtl8169_private *tp,
>  				 void __iomem *ioaddr)
>  {
>  	struct pci_dev *pdev = tp->pci_dev;
> -	u8 cfg1;
>  	int vpd_cap;
> +	__le32 sig;
>  	u8 mac[8];
> +	u8 cfg1;
>  
>  	cfg1 = RTL_R8(Config1);
>  	if (!(cfg1  & VPD)) {
> @@ -1961,7 +1966,16 @@ static void rtl_init_mac_address(struct rtl8169_private *tp,
>  	if (!vpd_cap)
>  		return;
>  
> -	/* MAC address is stored in EEPROM at offset 0x0e
> +	if (rtl_eeprom_read(pdev, vpd_cap, RTL_EEPROM_SIG_ADDR, &sig) < 0)
> +		return;
> +
> +	if ((sig & RTL_EEPROM_SIG_MASK) != RTL_EEPROM_SIG) {
> +		dev_info(&pdev->dev, "Missing EEPROM signature: %08x\n", sig);
> +		return;
> +	}
> +
> +	/*
> +	 * MAC address is stored in EEPROM at offset 0x0e
>  	 * Realtek says: "The VPD address does not have to be a DWORD-aligned
>  	 * address as defined in the PCI 2.2 Specifications, but the VPD data
>  	 * is always consecutive 4-byte data starting from the VPD address
> @@ -1983,8 +1997,8 @@ static void rtl_init_mac_address(struct rtl8169_private *tp,
>  			 print_mac(buf, mac));
>  	}
>  
> -	/* Write MAC address */
> -	rtl_rar_set(tp, mac);
> +	if (is_valid_ether_addr(mac))
> +		rtl_rar_set(tp, mac);
>  }
>  
>  static int __devinit

