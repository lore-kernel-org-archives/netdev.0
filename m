From: "Benjamin Li" <benli@broadcom.com>
Subject: Re: [PATCH] PCI: Limit VPD length for Broadcom 5708S
Date: Tue, 28 Oct 2008 09:25:30 -0700
Message-ID: <1225211130.3980.7.camel@dhcp-10-12-136-136.broadcom.com>
References: <48920413.6080508@cosmosbay.com>
 <4906405F.6080708@cosmosbay.com> <1225164385.3977.11.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "willy@linux.intel.com" <willy@linux.intel.com>,
	"jbarnes@virtuousgeek.org" <jbarnes@virtuousgeek.org>,
	"linux kernel" <linux-kernel@vger.kernel.org>,
	"Linux Netdev List" <netdev@vger.kernel.org>,
	"Michael Chan" <mchan@broadcom.com>
To: "Eric Dumazet" <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3456 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752859AbYJ1QZm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2008 12:25:42 -0400
In-Reply-To: <1225164385.3977.11.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

I think this is the commit that broke the Broadcom NIC VPD quirk fix.

http://git.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux-2.6.git;a=3D=
commit;h=3D201de56eb22f1ff3f36804bc70cbff220b50f067

This is because the quirk relied on pci_vpd_pci22_init() being called
before pci_fixup_device() is called.

Now pci_fixup_device() is being called before pci_vpd_pci22_init().
Because of this reordering, dev->vpd is NULL rendering the quirk
ineffective.

I will work on a solution and keep you posted.

Thanks again.

-Ben


On Mon, 2008-10-27 at 20:26 -0700, Benjamin Li wrote:
> Hi Eric,
>=20
> It looks like the same problem again: we are reading past a valid VPD
> address.
>=20
> After some initial debugging, it looks like dev->vpd is NULL when the
> Broadcom 5706C/5706S/5708C/570S/5709 quirk is called.  Because of thi=
s
> dev->vpd->len is never set to the proper length to limit the VPD read=
s.
> I will debug further to determine what has changed.
>=20
> Thanks again for pointing out the problem.
>=20
> -Ben
>=20
> On Mon, 2008-10-27 at 15:27 -0700, Eric Dumazet wrote:
> > Eric Dumazet a =E9crit :
> > > While trying to upgrade kernel from 2.6.25 to 2.6.26 on a ProLian=
t=20
> > > BL460c G1,
> > > I faced this problem on integrated Broadcom 5708S NIC when trying=
 to UP=20
> > > them.
> > >=20
> > > bnx2: fw sync timeout, reset code =3D 1030003
> > >=20
> > > I noticed that commit 99cb233d60cbe644203f19938c729ea2bb004d70 (P=
CI:=20
> > > Limit VPD read/write lengths for Broadcom 5706, 5708, 5709 rev.A)
> > > was probably a good candidate to solve the problem.
> > >=20
> > > Apparently, it added PCI quirks for a list of Broadcom NICs, but
> > > quirk_brcm_570x_limit_vpd() ignores part of them.
> > >=20
> > > I found the following patch useful to restore correct operation o=
n my=20
> > > machine.
> > >=20
> > > Some information about this nic :
> > >=20
> > > 03:00.0 Ethernet controller: Broadcom Corporation NetXtreme II BC=
M5708S=20
> > > Gigabit Ethernet (rev 12)
> > >        Subsystem: Hewlett-Packard Company NC373i Integrated=20
> > > Multifunction Gigabit Server Adapter
> > >        Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop=
-=20
> > > ParErr+ Stepping- SERR+ FastB2B-
> > >        Status: Cap+ 66Mhz+ UDF- FastB2B+ ParErr- DEVSEL=3Dmedium =
>TAbort-=20
> > > <TAbort- <MAbort- >SERR- <PERR-
> > >        Latency: 64 (16000ns min), Cache Line Size 10
> > >        Interrupt: pin A routed to IRQ 222
> > >        Region 0: Memory at f6000000 (64-bit, non-prefetchable) [s=
ize=3D32M]
> > >        [virtual] Expansion ROM at d1200000 [disabled] [size=3D16K=
]
> > >        Capabilities: [40] PCI-X non-bridge device.
> > >                Command: DPERE- ERO- RBC=3D0 OST=3D4
> > >                Status: Bus=3D3 Dev=3D0 Func=3D0 64bit+ 133MHz+ SC=
D- USC-,=20
> > > DC=3Dsimple, DMMRBC=3D0, DMOST=3D4, DMCRS=3D2, RSCEM-
> > >        Capabilities: [48] Power Management version 2
> > >                Flags: PMEClk- DSI- D1- D2- AuxCurrent=3D0mA=20
> > > PME(D0-,D1-,D2-,D3hot+,D3cold+)
> > >                Status: D0 PME-Enable- DSel=3D0 DScale=3D1 PME-
> > >        Capabilities: [50] Vital Product Data
> > >        Capabilities: [58] Message Signalled Interrupts: 64bit+ Qu=
eue=3D0/0=20
> > > Enable+
> > >                Address: 00000000feeff00c  Data: 4179
> > >=20
> > > after applying patch :
> > >=20
> > > # hexdump -C=20
> > > "/sys/devices/pci0000:00/0000:00:1c.0/0000:02:00.0/0000:03:00.0/v=
pd"
> > > 00000000  82 2f 00 48 50 20 4e 43  33 37 33 69 20 4d 75 6c  |./.H=
P=20
> > > NC373i Mul|
> > > 00000010  74 69 66 75 6e 63 74 69  6f 6e 20 47 69 67 61 62  |tifu=
nction=20
> > > Gigab|
> > > 00000020  69 74 20 53 65 72 76 65  72 20 41 64 61 70 74 65  |it S=
erver=20
> > > Adapte|
> > > 00000030  72 00 90 4a 00 50 4e 03  4e 2f 41 45 43 03 4e 2f =20
> > > |r..J.PN.N/AEC.N/|
> > > 00000040  41 53 4e 0a 30 31 32 33  34 35 36 37 38 39 4d 4e =20
> > > |ASN.0123456789MN|
> > > 00000050  04 31 30 33 43 52 56 26  a2 00 00 00 00 00 00 00 =20
> > > |.103CRV&........|
> > > 00000060  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00 =20
> > > |................|
> > > 00000070  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 78 =20
> > > |...............x|
> > > 00000080
> > >=20
> > > Patch against current Linus tree, should also be sent for linux-2=
=2E6.26.2=20
> > > inclusion.
> > >=20
> > > I have no idea if 5706S and 5709S also needs this truncation of V=
PD length
> > >=20
> > > Thank you
> > >=20
> > > [PATCH] PCI: Limit VPD length for Broadcom 5708S
> > >=20
> > > BCM5708S wont work correctly unless VPD length truncated to 128
> > >=20
> > > Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
> > >=20
> > > diff --git a/drivers/pci/quirks.c b/drivers/pci/quirks.c
> > > index 0fb3650..59667e5 100644
> > > --- a/drivers/pci/quirks.c
> > > +++ b/drivers/pci/quirks.c
> > > @@ -1756,9 +1756,12 @@ DECLARE_PCI_FIXUP_EARLY(PCI_VENDOR_ID_VIA,=
=20
> > > 0x324e, quirk_via_cx700_pci_parking_c
> > >  */
> > > static void __devinit quirk_brcm_570x_limit_vpd(struct pci_dev *d=
ev)
> > > {
> > > -    /*  Only disable the VPD capability for 5706, 5708, and 5709=
 rev. A */
> > > +    /*
> > > +     * Only disable the VPD capability for 5706, 5708, 5708S and=
 5709=20
> > > rev. A
> > > +     */
> > >     if ((dev->device =3D=3D PCI_DEVICE_ID_NX2_5706) ||
> > >         (dev->device =3D=3D PCI_DEVICE_ID_NX2_5708) ||
> > > +        (dev->device =3D=3D PCI_DEVICE_ID_NX2_5708S) ||
> > >         ((dev->device =3D=3D PCI_DEVICE_ID_NX2_5709) &&
> > >          (dev->revision & 0xf0) =3D=3D 0x0)) {
> > >         if (dev->vpd)
> > >=20
> >=20
> > Hi all
> >=20
> > Just tried linux-2.6.28-rc2 on same platform.
> >=20
> > Same problem again...
> >=20
> > Broadcom NetXtreme II Gigabit Ethernet Driver bnx2 v1.8.1 (Oct 7, 2=
008)
> > bnx2 0000:03:00.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
> > eth0: Broadcom NetXtreme II BCM5708 1000Base-SX (B2) PCI-X 64-bit 1=
33MHz found at mem f6000000, IRQ 16, node addr 00:1e:0b:ec:d3:dc
> > bnx2 0000:07:00.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
> > eth1: Broadcom NetXtreme II BCM5708 1000Base-SX (B2) PCI-X 64-bit 1=
33MHz found at mem fa000000, IRQ 16, node addr 00:1e:0b:ec:d3:d2
> > bnx2 0000:03:00.0: irq 45 for MSI/MSI-X
> > bnx2: fw sync timeout, reset code =3D 1030003
> > bnx2 0000:07:00.0: irq 45 for MSI/MSI-X
> > bnx2: fw sync timeout, reset code =3D 1030003
> > bnx2 0000:03:00.0: irq 45 for MSI/MSI-X
> > bnx2: fw sync timeout, reset code =3D 1030006
> >=20
> >=20
> > 2.6.27.4 is running fine on this machine
> >=20
> > Any ideas ?
> >=20
> > Thank you
> >=20
> > Eric
> >=20
> >=20
> >=20
> >=20


