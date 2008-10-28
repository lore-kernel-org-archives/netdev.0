From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] PCI: Limit VPD length for Broadcom 5708S
Date: Tue, 28 Oct 2008 07:21:19 +0100
Message-ID: <4906AF5F.9040704@cosmosbay.com>
References: <48920413.6080508@cosmosbay.com> <4906405F.6080708@cosmosbay.com> <1225164385.3977.11.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "willy@linux.intel.com" <willy@linux.intel.com>,
	"jbarnes@virtuousgeek.org" <jbarnes@virtuousgeek.org>,
	linux kernel <linux-kernel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Michael Chan <mchan@broadcom.com>, yu.zhao@intel.com
To: Benjamin Li <benli@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:46198 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752513AbYJ1Geg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2008 02:34:36 -0400
In-Reply-To: <1225164385.3977.11.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Benjamin Li a =E9crit :
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

I did a git bisect this morning :

$ git bisect good
201de56eb22f1ff3f36804bc70cbff220b50f067 is first bad commit
commit 201de56eb22f1ff3f36804bc70cbff220b50f067
Author: Zhao, Yu <yu.zhao@intel.com>
Date:   Mon Oct 13 19:49:55 2008 +0800

    PCI: centralize the capabilities code in probe.c

    This patch centralizes the initialization and release functions of
    various PCI capabilities in probe.c, which makes the introduction
    of new capability support functions cleaner in the future.

    Signed-off-by: Yu Zhao <yu.zhao@intel.com>
    Signed-off-by: Jesse Barnes <jbarnes@virtuousgeek.org>

:040000 040000 2491e9db72bd403b118fd05030af759e5299cae9 8ffd2fc80eff495=
e4fd4b46ed97d10cb7bf92f3b M      drivers

$ git bisect log
git bisect start
# good: [3fa8749e584b55f1180411ab1b51117190bac1e5] Linux 2.6.27
git bisect good 3fa8749e584b55f1180411ab1b51117190bac1e5
# good: [3fa8749e584b55f1180411ab1b51117190bac1e5] Linux 2.6.27
git bisect good 3fa8749e584b55f1180411ab1b51117190bac1e5
# good: [3fa8749e584b55f1180411ab1b51117190bac1e5] Linux 2.6.27
git bisect good 3fa8749e584b55f1180411ab1b51117190bac1e5
# bad: [8b5f12d04b2e93842f3dda01f029842047bf3f81] syncookies: fix inclu=
sion of tcp options in syn-ack
git bisect bad 8b5f12d04b2e93842f3dda01f029842047bf3f81
# bad: [8b5f12d04b2e93842f3dda01f029842047bf3f81] syncookies: fix inclu=
sion of tcp options in syn-ack
git bisect bad 8b5f12d04b2e93842f3dda01f029842047bf3f81
# good: [cf2fa66055d718ae13e62451bb546505f63906a2] Merge branch 'for_li=
nus' of git://git.kernel.org/pub/scm/linux/kernel/git/mchehab/linux-2.6
git bisect good cf2fa66055d718ae13e62451bb546505f63906a2
# good: [01e8ef11bc1a74e65678ed55795f59266d4add01] x86: sysfs: kill own=
er field from attribute
git bisect good 01e8ef11bc1a74e65678ed55795f59266d4add01
# bad: [9779a8325a9bbf4ccd3853e0e4064984cf9da9c9] Merge branch 'for-ups=
tream' of git://git.kernel.org/pub/scm/linux/kernel/git/dvrabel/uwb
git bisect bad 9779a8325a9bbf4ccd3853e0e4064984cf9da9c9
# good: [7110879cf2afbfb7af79675f5ff109e63d631c25] Merge branch 'core-f=
ixes-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/tip/li=
nux-2.6-tip
git bisect good 7110879cf2afbfb7af79675f5ff109e63d631c25
# good: [92b29b86fe2e183d44eb467e5e74a5f718ef2e43] Merge branch 'tracin=
g-v28-for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/tip/l=
inux-2.6-tip
git bisect good 92b29b86fe2e183d44eb467e5e74a5f718ef2e43
# bad: [72441bdc76f7f71d7b75cdaa48f26dbb1f3d932e] Merge branch 'release=
' of git://git.kernel.org/pub/scm/linux/kernel/git/aegl/linux-2.6
git bisect bad 72441bdc76f7f71d7b75cdaa48f26dbb1f3d932e
# bad: [e3d2f927f788adcdabc42f8a1616f6cc56c53bbe] Merge git://git.kerne=
l.org/pub/scm/linux/kernel/git/kyle/parisc-2.6
git bisect bad e3d2f927f788adcdabc42f8a1616f6cc56c53bbe
# bad: [201de56eb22f1ff3f36804bc70cbff220b50f067] PCI: centralize the c=
apabilities code in probe.c
git bisect bad 201de56eb22f1ff3f36804bc70cbff220b50f067
# good: [7f2feec140f1f1e4f701e013a2bf8284a9ec2a3c] PCI: pciehp: replace=
 printk with dev_printk
git bisect good 7f2feec140f1f1e4f701e013a2bf8284a9ec2a3c
# good: [c8761fe80ed052634153438405c9048611ae7ae1] PCI: fix hotplug get=
_##name return value problem
git bisect good c8761fe80ed052634153438405c9048611ae7ae1
# good: [022edd86d7c864bc8fadc3c8ac4e6a464472ab05] PCI: use resource_si=
ze() everywhere.
git bisect good 022edd86d7c864bc8fadc3c8ac4e6a464472ab05
# good: [e354597cce8d219d135d65e585dc4f30323486b9] PCI: fix 64-vbit pre=
fetchable memory resource BARs
git bisect good e354597cce8d219d135d65e585dc4f30323486b9
# good: [280c73d3691fb182fa55b0160737c2c0feb79471] PCI: centralize the =
capabilities code in pci-sysfs.c
git bisect good 280c73d3691fb182fa55b0160737c2c0feb79471



> -Ben
>=20
> On Mon, 2008-10-27 at 15:27 -0700, Eric Dumazet wrote:
>> Eric Dumazet a =E9crit :
>>> While trying to upgrade kernel from 2.6.25 to 2.6.26 on a ProLiant=20
>>> BL460c G1,
>>> I faced this problem on integrated Broadcom 5708S NIC when trying t=
o UP=20
>>> them.
>>>
>>> bnx2: fw sync timeout, reset code =3D 1030003
>>>
>>> I noticed that commit 99cb233d60cbe644203f19938c729ea2bb004d70 (PCI=
:=20
>>> Limit VPD read/write lengths for Broadcom 5706, 5708, 5709 rev.A)
>>> was probably a good candidate to solve the problem.
>>>
>>> Apparently, it added PCI quirks for a list of Broadcom NICs, but
>>> quirk_brcm_570x_limit_vpd() ignores part of them.
>>>
>>> I found the following patch useful to restore correct operation on =
my=20
>>> machine.
>>>
>>> Some information about this nic :
>>>
>>> 03:00.0 Ethernet controller: Broadcom Corporation NetXtreme II BCM5=
708S=20
>>> Gigabit Ethernet (rev 12)
>>>        Subsystem: Hewlett-Packard Company NC373i Integrated=20
>>> Multifunction Gigabit Server Adapter
>>>        Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV+ VGASnoop-=20
>>> ParErr+ Stepping- SERR+ FastB2B-
>>>        Status: Cap+ 66Mhz+ UDF- FastB2B+ ParErr- DEVSEL=3Dmedium >T=
Abort-=20
>>> <TAbort- <MAbort- >SERR- <PERR-
>>>        Latency: 64 (16000ns min), Cache Line Size 10
>>>        Interrupt: pin A routed to IRQ 222
>>>        Region 0: Memory at f6000000 (64-bit, non-prefetchable) [siz=
e=3D32M]
>>>        [virtual] Expansion ROM at d1200000 [disabled] [size=3D16K]
>>>        Capabilities: [40] PCI-X non-bridge device.
>>>                Command: DPERE- ERO- RBC=3D0 OST=3D4
>>>                Status: Bus=3D3 Dev=3D0 Func=3D0 64bit+ 133MHz+ SCD-=
 USC-,=20
>>> DC=3Dsimple, DMMRBC=3D0, DMOST=3D4, DMCRS=3D2, RSCEM-
>>>        Capabilities: [48] Power Management version 2
>>>                Flags: PMEClk- DSI- D1- D2- AuxCurrent=3D0mA=20
>>> PME(D0-,D1-,D2-,D3hot+,D3cold+)
>>>                Status: D0 PME-Enable- DSel=3D0 DScale=3D1 PME-
>>>        Capabilities: [50] Vital Product Data
>>>        Capabilities: [58] Message Signalled Interrupts: 64bit+ Queu=
e=3D0/0=20
>>> Enable+
>>>                Address: 00000000feeff00c  Data: 4179
>>>
>>> after applying patch :
>>>
>>> # hexdump -C=20
>>> "/sys/devices/pci0000:00/0000:00:1c.0/0000:02:00.0/0000:03:00.0/vpd=
"
>>> 00000000  82 2f 00 48 50 20 4e 43  33 37 33 69 20 4d 75 6c  |./.HP=20
>>> NC373i Mul|
>>> 00000010  74 69 66 75 6e 63 74 69  6f 6e 20 47 69 67 61 62  |tifunc=
tion=20
>>> Gigab|
>>> 00000020  69 74 20 53 65 72 76 65  72 20 41 64 61 70 74 65  |it Ser=
ver=20
>>> Adapte|
>>> 00000030  72 00 90 4a 00 50 4e 03  4e 2f 41 45 43 03 4e 2f =20
>>> |r..J.PN.N/AEC.N/|
>>> 00000040  41 53 4e 0a 30 31 32 33  34 35 36 37 38 39 4d 4e =20
>>> |ASN.0123456789MN|
>>> 00000050  04 31 30 33 43 52 56 26  a2 00 00 00 00 00 00 00 =20
>>> |.103CRV&........|
>>> 00000060  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00 =20
>>> |................|
>>> 00000070  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 78 =20
>>> |...............x|
>>> 00000080
>>>
>>> Patch against current Linus tree, should also be sent for linux-2.6=
=2E26.2=20
>>> inclusion.
>>>
>>> I have no idea if 5706S and 5709S also needs this truncation of VPD=
 length
>>>
>>> Thank you
>>>
>>> [PATCH] PCI: Limit VPD length for Broadcom 5708S
>>>
>>> BCM5708S wont work correctly unless VPD length truncated to 128
>>>
>>> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
>>>
>>> diff --git a/drivers/pci/quirks.c b/drivers/pci/quirks.c
>>> index 0fb3650..59667e5 100644
>>> --- a/drivers/pci/quirks.c
>>> +++ b/drivers/pci/quirks.c
>>> @@ -1756,9 +1756,12 @@ DECLARE_PCI_FIXUP_EARLY(PCI_VENDOR_ID_VIA,=20
>>> 0x324e, quirk_via_cx700_pci_parking_c
>>>  */
>>> static void __devinit quirk_brcm_570x_limit_vpd(struct pci_dev *dev=
)
>>> {
>>> -    /*  Only disable the VPD capability for 5706, 5708, and 5709 r=
ev. A */
>>> +    /*
>>> +     * Only disable the VPD capability for 5706, 5708, 5708S and 5=
709=20
>>> rev. A
>>> +     */
>>>     if ((dev->device =3D=3D PCI_DEVICE_ID_NX2_5706) ||
>>>         (dev->device =3D=3D PCI_DEVICE_ID_NX2_5708) ||
>>> +        (dev->device =3D=3D PCI_DEVICE_ID_NX2_5708S) ||
>>>         ((dev->device =3D=3D PCI_DEVICE_ID_NX2_5709) &&
>>>          (dev->revision & 0xf0) =3D=3D 0x0)) {
>>>         if (dev->vpd)
>>>
>> Hi all
>>
>> Just tried linux-2.6.28-rc2 on same platform.
>>
>> Same problem again...
>>
>> Broadcom NetXtreme II Gigabit Ethernet Driver bnx2 v1.8.1 (Oct 7, 20=
08)
>> bnx2 0000:03:00.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
>> eth0: Broadcom NetXtreme II BCM5708 1000Base-SX (B2) PCI-X 64-bit 13=
3MHz found at mem f6000000, IRQ 16, node addr 00:1e:0b:ec:d3:dc
>> bnx2 0000:07:00.0: PCI INT A -> GSI 16 (level, low) -> IRQ 16
>> eth1: Broadcom NetXtreme II BCM5708 1000Base-SX (B2) PCI-X 64-bit 13=
3MHz found at mem fa000000, IRQ 16, node addr 00:1e:0b:ec:d3:d2
>> bnx2 0000:03:00.0: irq 45 for MSI/MSI-X
>> bnx2: fw sync timeout, reset code =3D 1030003
>> bnx2 0000:07:00.0: irq 45 for MSI/MSI-X
>> bnx2: fw sync timeout, reset code =3D 1030003
>> bnx2 0000:03:00.0: irq 45 for MSI/MSI-X
>> bnx2: fw sync timeout, reset code =3D 1030006
>>
>>
>> 2.6.27.4 is running fine on this machine
>>
>> Any ideas ?
>>
>> Thank you
>>
>> Eric
>>
>>
>>
>>
>=20
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
>=20


