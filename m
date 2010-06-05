From: =?UTF-8?B?VGltbyBUZXLDpHM=?= <timo.teras@iki.fi>
Subject: [PATCH] Re: still having r8169 woes with XID 18000000
Date: Sat, 05 Jun 2010 10:39:55 +0300
Message-ID: <4C09FF4B.4050601@iki.fi>
References: <4C08ED47.1030800@iki.fi> <20100604123641.ED8154CD45@orbit.nwl.cc> <4C08F953.1050800@iki.fi> <20100604134351.7981F4CD45@orbit.nwl.cc> <4C09387F.1050403@iki.fi> <4C09611B.2090805@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Phil Sutter <phil@nwl.cc>,
	=?UTF-8?B?ZnJhbsOnb2lzIHJvbWlldQ==?= <romieu@fr.zoreil.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.25]:12533 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755249Ab0FEHjy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jun 2010 03:39:54 -0400
Received: by ey-out-2122.google.com with SMTP id 25so131266eya.19
        for <netdev@vger.kernel.org>; Sat, 05 Jun 2010 00:39:53 -0700 (PDT)
In-Reply-To: <4C09611B.2090805@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/04/2010 11:24 PM, Timo Ter=C3=A4s wrote:
> On 06/04/2010 08:31 PM, Timo Ter=C3=A4s wrote:
> r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
> r8169 0000:00:09.0: PCI->APIC IRQ transform: INT A -> IRQ 18
> r8169 0000:00:09.0: no PCI Express capability
> eth0: RTL8169sc/8110sc at 0xf835c000, 00:30:18:a6:2b:6c, XID 18000000=
 IRQ 18
> r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
> r8169 0000:00:0b.0: PCI->APIC IRQ transform: INT A -> IRQ 19
> r8169 0000:00:0b.0: no PCI Express capability
> eth1: RTL8169sc/8110sc at 0xf8360000, 00:30:18:a6:2b:6d, XID 18000000=
 IRQ 19
> r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
> r8169 0000:00:0c.0: PCI->APIC IRQ transform: INT A -> IRQ 16
> r8169 0000:00:0c.0: no PCI Express capability
> eth2: RTL8169sc/8110sc at 0xf8364000, 00:30:18:a6:2b:6e, XID 18000000=
 IRQ 16
> r8169: mdio_write(f8364000, 0x00000003, 0000000a1) required 2000 cycl=
es
> r8169: mdio_write(f8364000, 0x00000000, 000001000) required 2000 cycl=
es
> r8169: mdio_write(f8364000, 0x00000000, 00000a0ff) required 2000 cycl=
es
> r8169: mdio_write(f8364000, 0x00000014, 00000fb54) required 2000 cycl=
es
>=20
> And eth2 was not working. Reloading the module gave a lot of other
> mdio_write and mdio_read errors.
>=20
> It seems to be pretty random when the errors occur, but that's the
> reason why the NIC stops working: mdio_write() fails (one or more tim=
es)
> at some crucial point of the board specific phy config code resulting=
 in
> bad state.
>=20
> Any ideas how to debug this further?

Ok, I compared Realtek's and the in-tree driver. The only essential
difference is that Realtek driver uses udelay(100) in mdio_write()'s
busy polling loop where as the in-tree uses udelay(25). And that seems
to be the magic difference! Using udelay(100) fixes this!

I'm guessing that the phy needs slight delay between consecutive
mdio_write's even if it has advertised that the write has been
completed. And yes, just adding a small delay in the end of mdio_write
does seem to work too.

=46rancois, you think the below patch is ok? Should I send it as proper=
ly
formatted commit?

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 217e709..6db62bf 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -559,6 +559,7 @@ static void mdio_write(void __iomem *ioaddr,
 			break;
 		udelay(25);
 	}
+	udelay(25);
 }

 static int mdio_read(void __iomem *ioaddr, int reg_addr)
