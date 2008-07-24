From: c4p7n1@capitanio.org
Subject: [patch inside] kernel crash, RTL8101E [10ec:8136]
Date: Thu, 24 Jul 2008 17:54:36 +0200 (MEST)
Message-ID: <200807241554.m6OFsaL1005401@post.webmailer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: kernel@vger.kernel.org, netdev@vger.kernel.org,
	c4p7n1@capitanio.org
To: "Francois Romieu" <romieu@fr.zoreil.com>,
	"Mario Limonciello" <Mario_Limonciello@Dell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cg-p00-ob.rzone.de ([81.169.146.192]:20171 "EHLO
	cg-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751836AbYGXQBd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jul 2008 12:01:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

----- original message --------
http://marc.info/?l=linux-netdev&m=121274740606834&w=2

Subject: Re: [BUG or cosmic ray] WARNING: at net/sched/sch_generic.c:222 dev_watchdog+0xe8/0x100()
Sent: Sat, 14 Jun 2008
From: Francois Romieu<romieu@fr.zoreil.com>
> If lspci can not read the device registers correctly, chances are high
> that the device driver can not either.
> 
> If you can reproduce the "!!! Unknown header type 7f" error with lspci
> on 2.6.26-rc6 we have a problem which goes beyond the sole r8169 device
> driver. linux-kernel or linux-pci will probably be more helpful than
> netdev then.

Hi Francois and Mario,

(apologies if I missed something)
it comes out that by a "bad luck" the RTL8101E internally crashes and is no more
reachable on the pcie bus and/or freezes the the kernel immediately.

Marcus Sundberg found, I think, a first relevant bug
http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=77332894c21165404496c56763d7df6c15c4bb09
r8169: avoid thrashing PCI conf space above RTL_GIGA_MAC_VER_06

that helps, but not quite. Mario Limonciello <Mario_Limonciello@Dell.com>
extracted from the Realtek driver some start-up magic feed. It would be great
if someone RTL* savvy can double check.

I am personally wondering why the Realtek guys keep brainless pushing magic
numbers in their obviously Dead End gpl driver[s] (if any) and are not sending
patches helping at least with the magic here directly? Sure, it's better than
nothing. You know, it's easy to shorten an eeprom mtbf from years to weeks just
applying a wrong bias. Hint: _That can long-term burn a lot of Dells at al money._

However, I can't test this on the current linus' tree, the kernel is broken
itself, but I can confirm, applied to the vanilla v2.6.26, solves the problem and
makes my notebook more happy. (Fixing remaining rtl8187b, drm/x3100/intelfb/x11
issues seems to be on the go :-))

-----------------

OriginalAuthor: Mario Limonciello <Mario_Limonciello@Dell.com>
This fix was created based upon the differences in the startup procedures
of the Realtek r8101 driver and the upstream r8169 driver.

Properly merged with
http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=77332894c21165404496c56763d7df6c15c4bb09
solves the bug on the Toshiba L300 laptop reported here
http://marc.info/?l=linux-netdev&m=121274740606834&w=2

Signed-off-by: Martin Capitanio <c4p7n1@capitanio.org>
---

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 6572425..8e82546 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -1139,6 +1139,10 @@ static void rtl8169_get_mac_version(struct rtl8169_private *tp,
                { 0x7cf00000, 0x34000000,       RTL_GIGA_MAC_VER_13 },
                { 0x7cf00000, 0x34200000,       RTL_GIGA_MAC_VER_16 },
                { 0x7c800000, 0x34000000,       RTL_GIGA_MAC_VER_16 },
+               /* 8102EL */
+               { 0x7c800000, 0x24800000,       RTL_GIGA_MAC_VER_16 },
+               /* 8102E */
+               { 0x7c800000, 0x34800000,       RTL_GIGA_MAC_VER_16 },
                /* FIXME: where did these entries come from ? -- FR */
                { 0xfc800000, 0x38800000,       RTL_GIGA_MAC_VER_15 },
                { 0xfc800000, 0x30800000,       RTL_GIGA_MAC_VER_14 },
@@ -1299,6 +1303,21 @@ static void rtl8168cx_hw_phy_config(void __iomem *ioaddr)
        rtl_phy_write(ioaddr, phy_reg_init, ARRAY_SIZE(phy_reg_init));
 }
 
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
 static void rtl_hw_phy_config(struct net_device *dev)
 {
        struct rtl8169_private *tp = netdev_priv(dev);
@@ -1316,6 +1335,9 @@ static void rtl_hw_phy_config(struct net_device *dev)
        case RTL_GIGA_MAC_VER_04:
                rtl8169sb_hw_phy_config(ioaddr);
                break;
+       case RTL_GIGA_MAC_VER_13:
+       case RTL_GIGA_MAC_VER_16:
+               rtl8101_hw_phy_config(ioaddr);
        case RTL_GIGA_MAC_VER_18:
                rtl8168cp_hw_phy_config(ioaddr);
                break;
@@ -1438,8 +1460,10 @@ static void rtl8169_init_phy(struct net_device *dev, struct rtl8169_private *tp)
 
        rtl_hw_phy_config(dev);
 
-       dprintk("Set MAC Reg C+CR Offset 0x82h = 0x01h\n");
-       RTL_W8(0x82, 0x01);
+       if (tp->mac_version <= RTL_GIGA_MAC_VER_06) {
+               dprintk("Set MAC Reg C+CR Offset 0x82h = 0x01h\n");
+               RTL_W8(0x82, 0x01);
+       }
 
        pci_write_config_byte(tp->pci_dev, PCI_LATENCY_TIMER, 0x40);
 

--------------------
--------------------

It only remains other (cosmetic?) not-linux-only issue: the *E chip-sets have
a built in 100Mb/s transceiver

http://www.realtek.com.tw/products/productsView.aspx?Langid=1&PNid=14&PFid=7&Level=5&Conn=4&ProdID=19

but the driver advertises 1G:

Settings for eth0:
	Supported ports: [ TP ]
	Supported link modes:   10baseT/Half 10baseT/Full 
	                        100baseT/Half 100baseT/Full 
	                        1000baseT/Full 
	Supports auto-negotiation: Yes
	Advertised link modes:  10baseT/Half 10baseT/Full 
	                        100baseT/Half 100baseT/Full 
	                        1000baseT/Full 
	Advertised auto-negotiation: Yes
	Speed: 100Mb/s
	Duplex: Full
	Port: Twisted Pair
	PHYAD: 0
	Transceiver: internal
	Auto-negotiation: on
	Supports Wake-on: pumbg
	Wake-on: g
	Current message level: 0x00000033 (51)
	Link detected: yes
   
I had heard that a many confused people/helpdesks hopelessly send
around the globe Laptops to repair their nonexistent 1G PHY ;-)


Thanks a lot everyone involved!
        Martin Capitanio

