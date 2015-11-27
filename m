From: Michael Heimpold <michael.heimpold@i2se.com>
Subject: Problem with "swinging" ethernet link on i.MX28 based device
Date: Fri, 27 Nov 2015 10:30:26 +0100
Message-ID: <565822B2.30007@i2se.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: lw@karo-electronics.de, fabio.estevam@freescale.com,
	marek.vasut@gmail.com
To: NETDEV <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([217.72.192.74]:52499 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754467AbbK0Jb6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Nov 2015 04:31:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

we at I2SE have developed an i.MX28 based embedded device, called Duckb=
ill.
Regarding ethernet, it is very similar to the FSL mx28evk, i.e. we use =
the same
phy (SMSC LAN8720), we use RMII mode, clock is provided by iMX (not via
external crystal), we have a GPIO to reset the phy and an interrupt GPI=
O.

At the moment, we are using vanilla kernel 4.2.5 with only a fetch patc=
hes - mainly
patches to add the device tree stuff needed and some cherry-picked upst=
ream
patches. Nothing special IMO. You can find it here:
https://github.com/I2SE/linux/tree/v4.2.5-duckbill

After booting the device, we observe on a few devices the ethernet "swi=
nging"
or toggling:
[   15.830759] fec 800f0000.ethernet eth0: Freescale FEC PHY driver [SM=
SC LAN8710/LAN8720] (mii_bus:phy_addr=3D800f0000.etherne:00, irq=3D35)
[   15.843361] IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready
[   17.112867] fec 800f0000.ethernet eth0: Link is Up - 100Mbps/Full - =
flow control rx/tx
[   17.121746] IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes ready
[   17.894416] fec 800f0000.ethernet eth0: Link is Down
[   19.506960] fec 800f0000.ethernet eth0: Link is Up - 100Mbps/Full - =
flow control rx/tx
[   20.294398] fec 800f0000.ethernet eth0: Link is Down
[   21.932365] fec 800f0000.ethernet eth0: Link is Up - 100Mbps/Full - =
flow control rx/tx
[   22.714410] fec 800f0000.ethernet eth0: Link is Down
[   24.357890] fec 800f0000.ethernet eth0: Link is Up - 100Mbps/Full - =
flow control rx/tx
[   25.144400] fec 800f0000.ethernet eth0: Link is Down
[   26.783367] fec 800f0000.ethernet eth0: Link is Up - 100Mbps/Full - =
flow control rx/tx
[   27.564357] fec 800f0000.ethernet eth0: Link is Down
[   29.208846] fec 800f0000.ethernet eth0: Link is Up - 100Mbps/Full - =
flow control rx/tx

However, in U-Boot I can transfer several hundreds of MB without any pr=
oblem,
I can attach the cable/reattach etc. as usual - no obvious problems.
This is the reason, we think that the hardware is ok (and of course, we=
 double-checked
especially the soldering of the affected devices).

This is what I tried so far:
- changed the device tree to not use the interrupt line -> phy is polle=
d periodically
- reverted latest phy changes for LAN8720, i.e.
   d88ecb373bd1877acc43e13311a8e0e6daffc3d2 - "net: phy: smsc: disable =
energy detect mode"
   ff94c742dfeea3110f1e1d27399d728f8494d29e - "net: phy: fix semicolon.=
cocci warnings"
   776829de90c5972895db398993ddfa9417ff8b01 - "net: phy: workaround for=
 buggy cable detection by LAN8700 after cable plugging"
- then I tried the following patch

-snip-
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -936,7 +936,7 @@ fec_restart(struct net_device *ndev)
         if (fep->quirks & FEC_QUIRK_HAS_AVB) {
                 writel(0, fep->hwp + FEC_ECNTRL);
         } else {
- writel(1, fep->hwp + FEC_ECNTRL);
+ //writel(1, fep->hwp + FEC_ECNTRL);
                 udelay(10);
         }
-snap-
The idea behind this patch is: when FEC is resetted, then registers are=
 reset to initial values
and thus FEC is configured for MII. When using ENET_CLK_OUT this result=
s in 25 MHz clock
to phy instead of 50 MHz as required by RMII. At least for a short time=
, there might be
a "glitch". The concern was, that the phy might become stuck by this.

However, nothing of the above improved anything. So, at the moment, I'm
running out of ideas - any help/hint to debug this issue further is rea=
lly appreciated.
Please let me know if I missed some important information.

Mit freundlichen Gr=C3=BC=C3=9Fen / Kind regards
Michael Heimpold
--=20
Software Engineer

I2SE GmbH                           Tel: +49 (0) 341 355667-00
=46riedrich-Ebert-Str. 61             Fax: +49 (0) 341 355667-02
04109 Leipzig
Germany
Web: http://www.i2se.com/           Mail: info@i2se.com
VAT No.: DE 811528334
Amtsgericht Leipzig HRB 23784
Gesch=C3=A4ftsf=C3=BChrer/CEO: Carsten Ziermann

*** Diese E-Mail ist allein f=C3=BCr den bezeichneten Adressaten bestim=
mt. Sie kann rechtlich vertrauliche Informationen enthalten. Wenn Sie d=
iese E-Mail irrt=C3=BCmlich erhalten haben, informieren Sie bitte unver=
z=C3=BCglich den Absender per E-Mail und l=C3=B6schen Sie diese E-Mail =
von Ihrem Computer, ohne Kopien anzufertigen.
Vielen Dank. ***

*** This email is for the exclusive use of the addressee. It may contai=
n legally privileged information. If you have received this message in =
error, please notify the sender by email immediately and delete the mes=
sage from your computer without making any copies.
Thank you. ***
