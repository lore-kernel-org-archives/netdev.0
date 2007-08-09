From: Aurelien Jarno <aurelien@aurel32.net>
Subject: Re: [PATCH] SSB PCI core driver fixes
Date: Thu, 9 Aug 2007 03:09:28 +0200
Message-ID: <20070809010928.GA6351@hall.aurel32.net>
References: <20070809002353.GA4594@hall.aurel32.net> <200708090227.06510.mb@bu3sch.de> <46BA6200.4060306@aurel32.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Michael Buesch <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hall.aurel32.net ([88.191.38.19]:43180 "EHLO hall.aurel32.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755289AbXHIBJc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Aug 2007 21:09:32 -0400
Content-Disposition: inline
In-Reply-To: <46BA6200.4060306@aurel32.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 09, 2007 at 02:38:24AM +0200, Aurelien Jarno wrote:
> Michael Buesch a =E9crit :
> > On Thursday 09 August 2007, Aurelien Jarno wrote:
> >>  - Add some delay between the configuration of the PCI controller=20
> >>    and its registration.
> >=20
> > Why? It is _huge_ and people won't like it ;)
> > At least add a comment why this is needed.
>=20
> It is need, otherwise the PCI controller gets confused, which causes =
a
> reset of the machine. Then CFE goes into a loop booting again and aga=
in
> without being able to get up to the prompt.
>=20
> I agree this is a huge value, so I will try to find the minimum value
> and then add some margin.
>=20
> I will send an updated patch.
>=20

A few experiments have shown that the minimum value is 3ms on my WGT634=
U
machine. I haved changed the value to 10ms in the new patch below, whic=
h
gives some margin, and added a comment.

Aurelien



The patch below against 2.6.23-rc1-mm2 fixes various things on the SSB
PCI core driver:
 - Correctly write the configuration register value in=20
   ssb_extpci_write_config() for len =3D 1 or len =3D 2.
 - Set the PCI_LATENCY_TIMER to handle devices on the PCI bus.
 - Set the PCI arbiter control to internal.
 - Add some delay between the configuration of the PCI controller=20
   and its registration.

Signed-off-by: Aurelien Jarno <aurelien@aurel32.net>

--- a/drivers/ssb/driver_pcicore.c
+++ b/drivers/ssb/driver_pcicore.c
@@ -99,6 +99,9 @@
=20
 	/* Enable PCI bridge BAR1 prefetch and burst */
 	pci_write_config_dword(dev, SSB_BAR1_CONTROL, 3);
+
+	/* Make sure our latency is high enough to handle the devices behind =
us */
+	pci_write_config_byte(dev, PCI_LATENCY_TIMER, 0xa8);
 }
 DECLARE_PCI_FIXUP_EARLY(PCI_ANY_ID, PCI_ANY_ID, ssb_fixup_pcibridge);
=20
@@ -230,7 +233,7 @@
 		val =3D *((const u32 *)buf);
 		break;
 	}
-	writel(*((const u32 *)buf), mmio);
+	writel(val, mmio);
=20
 	err =3D 0;
 unmap:
@@ -311,6 +314,8 @@
 	udelay(150); /* Assertion time demanded by the PCI standard */
 	val |=3D SSB_PCICORE_CTL_RST; /* Deassert RST# */
 	pcicore_write32(pc, SSB_PCICORE_CTL, val);
+	val =3D SSB_PCICORE_ARBCTL_INTERN;
+	pcicore_write32(pc, SSB_PCICORE_ARBCTL, val);
 	udelay(1); /* Assertion time demanded by the PCI standard */
=20
 	/*TODO cardbus mode */
@@ -340,6 +345,9 @@
 	 * The following needs change, if we want to port hostmode
 	 * to non-MIPS platform. */
 	set_io_port_base((unsigned long)ioremap_nocache(SSB_PCI_MEM, 0x040000=
00));
+	/* Give some time to the PCI controller to configure itself with the =
new
+	 * values. Not waiting at this point causes crashes of the machine. *=
/
+	mdelay(10);
 	register_pci_controller(&ssb_pcicore_controller);
 }
=20

--=20
  .''`.  Aurelien Jarno	            | GPG: 1024D/F1BCDB73
 : :' :  Debian developer           | Electrical Engineer
 `. `'   aurel32@debian.org         | aurelien@aurel32.net
   `-    people.debian.org/~aurel32 | www.aurel32.net
