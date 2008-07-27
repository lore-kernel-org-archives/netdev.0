From: c4p7n1@capitanio.org
Subject: Re: [patch inside] kernel crash, RTL8101E [10ec:8136]
Date: Sun, 27 Jul 2008 21:04:16 +0200 (MEST)
Message-ID: <200807271904.m6RJ4G2Y013513@post.webmailer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Mario Limonciello" <Mario_Limonciello@Dell.com>,
	"Edward Hsu" <edward_hsu@realtek.com.tw>,
	"Linus Torvalds" <torvalds@linux-foundation.org>,
	"Martin Capitanio" <c4p7n1@capitanio.org>, netdev@vger.kernel.org
To: "Francois Romieu" <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from em-p00-ob.rzone.de ([81.169.146.224]:54181 "EHLO
	em-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751006AbYG0TEY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Jul 2008 15:04:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Francois Romieu<romieu@fr.zoreil.com> :
> Martin Capitanio <c4p7n1@capitanio.org> :
> [...]
> > It's a foreign language and my outside view may be completely wrong,
> 
> The communication with Realtek has not halted in 2007.
I guess Realtek doesn't have enough resources and that's why taking
the easier approach...

----

Boiling hot Sunday. So I decided to spend some time for digging to this issue.
I see some parts that may not behave as intended. Could someone take a care?  

Fist I thought that the pci system and the subsystem disagrees about the
chip-set:

02:00.0 Ethernet controller [0200]: Realtek Semiconductor Co., Ltd. RTL8101E PCI
Express Fast Ethernet controller [10ec:8136] (rev 02)
Subsystem: Toshiba America Info Systems Unknown device [1179:ff64]
means Realtek RTL8102E Family PCI-E Fast Ethernet NIC (NDIS 6.0)
[Toshiba America Information Systems] 1179:ff64 rev 02

But this system id catches a lot of different chipsets:
listing. driveragent. com/pci/10ec/8136?q=10ec%3A8136

The pci entry just confuse people, the correct message were something like
Realtek Semiconductor Co., Ltd. RTL81xxx Ethernet controller

Everything depending on this information may break, right?
drivers/net/r8169.c:166:{ PCI_DEVICE(PCI_VENDOR_ID_REALTEK,0x8136),0,0,RTL_CFG_2 },

Checking the web for the differences btw RTL8102E and RTL8101E:
the RTL8102E claims to support receive-side scaling, is this implemented
somewhere in linux (aka NAPI?)? Can miss-detecting have a bad side-effects?

RTL8102E offers an option for non-EEPROM (=OTP) design. Can the driver break the
hardware?

----

The Realtek driver walks for this device:

#define RTL8101_VERSION "1.007.00" NAPI_SUFFIX
#define MODULENAME "r8101"
printk(KERN_INFO "%s Fast Ethernet driver %s loaded\n",
		       MODULENAME, RTL8101_VERSION);

/* write/read MMIO register */
#define RTL_R32(reg)		((unsigned long) readl (ioaddr + (reg)))

rtl8101_get_mac_version
val32 = RTL_R32(TxConfig)     -> 0x37a00600	
reg = val32 & 0x7c800000;     -> 0x34800000
ICVerID = val32 & 0x00700000; -> 0x00200000
	switch (reg) {
		case 0x34800000: //RTL8102E
		case 0x24800000: //RTL8102EL
			else if (ICVerID == 0x00200000)
				tp->mcfg = CFG_METHOD_5;

_R("RTL8102E", CFG_METHOD_5, 0xff7e1880),

rtl8101_hw_phy_config
	} else if (tp->mcfg == CFG_METHOD_5) {
		mdio_write(ioaddr, 0x1f, 0x0000);
		mdio_write(ioaddr, 0x11, 0x15C0);
		mdio_write(ioaddr, 0x19, 0x2080);
		mdio_write(ioaddr, 0x1f, 0x0000);
	}

Not the same I posted, something is wrong.

+static void rtl8101_hw_phy_config(void __iomem *ioaddr)
+{
+       struct phy_reg phy_reg_init[] = {
+               { 0x1f, 0x0000 },
+               { 0x11, mdio_read(ioaddr,0x11) | 0x1000 },
+               { 0x19, mdio_read(ioaddr,0x19) | 0x2000 },
+               { 0x1f, 0x0003 },
+               { 0x08, 0x441D },
+               { 0x01, 0xc066 },
+               { 0x1f, 0x0000 }
+       };
+
+       rtl_phy_write(ioaddr, phy_reg_init, ARRAY_SIZE(phy_reg_init));
+}
+

Double check.
The driver website got updated in the meantime, walking again:

+#define RTL8101_VERSION "1.009.00" NAPI_SUFFIX
+printk(KERN_INFO "%s: This product is covered by one or more of the
	following patents: US5,307,459, US5,434,872, US5,732,094, US6,570,884,
	US6,115,776, and US6,327,625.\n", MODULENAME);
me: [0-9]Com and this ill patent system sucks.

Lot of changes, just closing my eyes and scrolling down.

 	} else if (tp->mcfg == CFG_METHOD_5) {
 		mdio_write(ioaddr, 0x1f, 0x0000);
+		mdio_write(ioaddr, 0x11, mdio_read(ioaddr, 0x11) | 0x1000);
+		mdio_write(ioaddr, 0x19, mdio_read(ioaddr, 0x19) | 0x2000);
+
+		mdio_write(ioaddr, 0x1f, 0x0003);
+		mdio_write(ioaddr, 0x08, 0x441D);
+		mdio_write(ioaddr, 0x01, 0x9100); <-
 		mdio_write(ioaddr, 0x1f, 0x0000);
 	}

True. The device doesn't need the second pill, Mario forgot that break and
there is a minor change for the drive magic.


> marc.info/?l=linux-netdev&m=121699353804102
> Can you give the completely untested patch below a try (say, against
> 2.6.26 or more) ?
This works.

----

 r8169 Gigabit Ethernet driver 2.2LK-NAPI loaded
[  892.510803] PCI: 0000:02:00.0 has unsupported PM cap regs version (7)
??
[  892.510803] ACPI: PCI Interrupt 0000:02:00.0[A] -> GSI 16 (level, low) -> IRQ 16
[  892.510803] PCI: Setting latency timer of device 0000:02:00.0 to 64
[  892.510803] **** MAC: (37a00600)
[  892.510803] r8169: mac_version = 0x11
[  892.511499] eth0: RTL8101e at 0xf895a000, , XID 34a00000 IRQ 220
[  892.511506] r8169: mac_version = 0x11
[  892.511511] **** RTL_GIGA_MAC_VER_16
[  892.534089] r8169: eth0: link down
[  892.534089] r8169: eth0: link down
??
[  894.026724] r8169: eth0: link up

----

Uncle, may I have my notebook back?
.Yes, just let me reboot ...
I like those two penguins.

.kernel: rtl8187: 8187B chip detected. Support is EXPERIMENTAL, and could damage
.        your hardware, use at your own risk
What's that??
.Don't fear, that's wireless.
.Here, plug this network cable.

