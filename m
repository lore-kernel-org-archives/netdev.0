From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] PCI: Limit VPD length for Broadcom 5708S
Date: Mon, 27 Oct 2008 23:27:43 +0100
Message-ID: <4906405F.6080708@cosmosbay.com>
References: <48920413.6080508@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: willy@linux.intel.com, jbarnes@virtuousgeek.org,
	linux kernel <linux-kernel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: benli@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp27.orange.fr ([80.12.242.94]:18113 "EHLO smtp27.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751643AbYJ0W1w convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Oct 2008 18:27:52 -0400
In-Reply-To: <48920413.6080508@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet a =E9crit :
> While trying to upgrade kernel from 2.6.25 to 2.6.26 on a ProLiant=20
> BL460c G1,
> I faced this problem on integrated Broadcom 5708S NIC when trying to =
UP=20
> them.
>=20
> bnx2: fw sync timeout, reset code =3D 1030003
>=20
> I noticed that commit 99cb233d60cbe644203f19938c729ea2bb004d70 (PCI:=20
> Limit VPD read/write lengths for Broadcom 5706, 5708, 5709 rev.A)
> was probably a good candidate to solve the problem.
>=20
> Apparently, it added PCI quirks for a list of Broadcom NICs, but
> quirk_brcm_570x_limit_vpd() ignores part of them.
>=20
> I found the following patch useful to restore correct operation on my=
=20
> machine.
>=20
> Some information about this nic :
>=20
> 03:00.0 Ethernet controller: Broadcom Corporation NetXtreme II BCM570=
8S=20
> Gigabit Ethernet (rev 12)
>        Subsystem: Hewlett-Packard Company NC373i Integrated=20
> Multifunction Gigabit Server Adapter
>        Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop-=20
> ParErr+ Stepping- SERR+ FastB2B-
>        Status: Cap+ 66Mhz+ UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >TAb=
ort-=20
> <TAbort- <MAbort- >SERR- <PERR-
>        Latency: 64 (16000ns min), Cache Line Size 10
>        Interrupt: pin A routed to IRQ 222
>        Region 0: Memory at f6000000 (64-bit, non-prefetchable) [size=3D=
32M]
>        [virtual] Expansion ROM at d1200000 [disabled] [size=3D16K]
>        Capabilities: [40] PCI-X non-bridge device.
>                Command: DPERE- ERO- RBC=3D0 OST=3D4
>                Status: Bus=3D3 Dev=3D0 Func=3D0 64bit+ 133MHz+ SCD- U=
SC-,=20
> DC=3Dsimple, DMMRBC=3D0, DMOST=3D4, DMCRS=3D2, RSCEM-
>        Capabilities: [48] Power Management version 2
>                Flags: PMEClk- DSI- D1- D2- AuxCurrent=3D0mA=20
> PME(D0-,D1-,D2-,D3hot+,D3cold+)
>                Status: D0 PME-Enable- DSel=3D0 DScale=3D1 PME-
>        Capabilities: [50] Vital Product Data
>        Capabilities: [58] Message Signalled Interrupts: 64bit+ Queue=3D=
0/0=20
> Enable+
>                Address: 00000000feeff00c  Data: 4179
>=20
> after applying patch :
>=20
> # hexdump -C=20
> "/sys/devices/pci0000:00/0000:00:1c.0/0000:02:00.0/0000:03:00.0/vpd"
> 00000000  82 2f 00 48 50 20 4e 43  33 37 33 69 20 4d 75 6c  |./.HP=20
> NC373i Mul|
> 00000010  74 69 66 75 6e 63 74 69  6f 6e 20 47 69 67 61 62  |tifuncti=
on=20
> Gigab|
> 00000020  69 74 20 53 65 72 76 65  72 20 41 64 61 70 74 65  |it Serve=
r=20
> Adapte|
> 00000030  72 00 90 4a 00 50 4e 03  4e 2f 41 45 43 03 4e 2f =20
> |r..J.PN.N/AEC.N/|
> 00000040  41 53 4e 0a 30 31 32 33  34 35 36 37 38 39 4d 4e =20
> |ASN.0123456789MN|
> 00000050  04 31 30 33 43 52 56 26  a2 00 00 00 00 00 00 00 =20
> |.103CRV&........|
> 00000060  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00 =20
> |................|
> 00000070  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 78 =20
> |...............x|
> 00000080
>=20
> Patch against current Linus tree, should also be sent for linux-2.6.2=
6.2=20
> inclusion.
>=20
> I have no idea if 5706S and 5709S also needs this truncation of VPD l=
ength
>=20
> Thank you
>=20
> [PATCH] PCI: Limit VPD length for Broadcom 5708S
>=20
> BCM5708S wont work correctly unless VPD length truncated to 128
>=20
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
>=20
> diff --git a/drivers/pci/quirks.c b/drivers/pci/quirks.c
> index 0fb3650..59667e5 100644
> --- a/drivers/pci/quirks.c
> +++ b/drivers/pci/quirks.c
> @@ -1756,9 +1756,12 @@ DECLARE_PCI_FIXUP_EARLY(PCI_VENDOR_ID_VIA,=20
> 0x324e, quirk_via_cx700_pci_parking_c
>  */
> static void __devinit quirk_brcm_570x_limit_vpd(struct pci_dev *dev)
> {
> -    /*  Only disable the VPD capability for 5706, 5708, and 5709 rev=
=2E A */
> +    /*
> +     * Only disable the VPD capability for 5706, 5708, 5708S and 570=
9=20
> rev. A
> +     */
>     if ((dev->device =3D=3D PCI_DEVICE_ID_NX2_5706) ||
>         (dev->device =3D=3D PCI_DEVICE_ID_NX2_5708) ||
> +        (dev->device =3D=3D PCI_DEVICE_ID_NX2_5708S) ||
>         ((dev->device =3D=3D PCI_DEVICE_ID_NX2_5709) &&
>          (dev->revision & 0xf0) =3D=3D 0x0)) {
>         if (dev->vpd)
>=20

Hi all

Just tried linux-2.6.28-rc2 on same platform.

Same problem again...

Broadcom NetXtreme II Gigabit Ethernet Driver bnx2 v1.8.1 (Oct 7, 2008)
bnx2 0000:03:00.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
eth0: Broadcom NetXtreme II BCM5708 1000Base-SX (B2) PCI-X 64-bit 133MH=
z found at mem f6000000, IRQ 16, node addr 00:1e:0b:ec:d3:dc
bnx2 0000:07:00.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
eth1: Broadcom NetXtreme II BCM5708 1000Base-SX (B2) PCI-X 64-bit 133MH=
z found at mem fa000000, IRQ 16, node addr 00:1e:0b:ec:d3:d2
bnx2 0000:03:00.0: irq 45 for MSI/MSI-X
bnx2: fw sync timeout, reset code =3D 1030003
bnx2 0000:07:00.0: irq 45 for MSI/MSI-X
bnx2: fw sync timeout, reset code =3D 1030003
bnx2 0000:03:00.0: irq 45 for MSI/MSI-X
bnx2: fw sync timeout, reset code =3D 1030006


2.6.27.4 is running fine on this machine

Any ideas ?

Thank you

Eric



