From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: bond + tc regression ?
Date: Wed, 06 May 2009 12:41:25 +0200
Message-ID: <4A016955.6030901@cosmosbay.com>
References: <1241538358.27647.9.camel@hazard2.francoudi.com> <4A0069F3.5030607@cosmosbay.com> <20090505174135.GA29716@francoudi.com> <4A008A72.6030607@cosmosbay.com> <20090505235008.GA17690@francoudi.com> <4A0105A8.3060707@cosmosbay.com> <20090506102845.GA24920@francoudi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Vladimir Ivashchenko <hazard@francoudi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:49060 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753111AbZEFKl2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2009 06:41:28 -0400
In-Reply-To: <20090506102845.GA24920@francoudi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Vladimir Ivashchenko a =E9crit :
> On Wed, May 06, 2009 at 05:36:08AM +0200, Eric Dumazet wrote:
>=20
>>> Is there any way at least to balance individual NICs on per core ba=
sis?
>>>
>> Problem of this setup is you have four NICS, but two logical devices=
 (bond0
>> & bond1) and a central HTB thing. This essentialy makes flows go thr=
ough the same
>> locks (some rwlocks guarding bonding driver, and others guarding HTB=
 structures).
>>
>> Also when a cpu receives a frame on ethX, it has to forward it on et=
hY, and
>> another lock guards access to TX queue of ethY device. If another cp=
us receives
>> a frame on ethZ and want to forward it to ethY device, this other cp=
u will
>> need same locks and everything slowdown.
>>
>> I am pretty sure you could get good results choosing two cpus sharin=
g same L2
>> cache. L2 on your cpu is 6MB. Another point would be to carefuly cho=
ose size
>> of RX rings on ethX devices. You could try to *reduce* them so that =
number
>> of inflight skb is small enough that everything fits in this 6MB cac=
he.
>>
>> Problem is not really CPU power, but RAM bandwidth. Having two cores=
 instead of one
>> attached to one central memory bank wont increase ram bandwidth, but=
 reduce it.
>=20
> Thanks for the detailed explanation.
>=20
> On the particular server I reported, I worked around the problem by g=
etting rid of classes=20
> and switching to ingress policers.
>=20
> However, I have one central box doing HTB, small amount of classes, b=
ut 850 mbps of
> traffic. The CPU is dual-core 5160 @ 3 Ghz. With 2.6.29 + bond I'm ex=
periencing strange problems=20
> with HTB, under high load borrowing doesn't seem to work properly. Th=
is box has two=20
> BNX2 and two E1000 NICs, and for some reason I cannot force BNX2 to s=
it on a single IRQ -
> even though I put only one CPU into smp_affinity, it keeps balancing =
on both. So I cannot
> figure out if its related to IRQ balancing or not.
>=20
> [root@tshape3 tshaper]# cat /proc/irq/63/smp_affinity
> 01
> [root@tshape3 tshaper]# cat /proc/interrupts | grep eth0
>  63:   44610754   95469129   PCI-MSI-edge      eth0
> [root@tshape3 tshaper]# cat /proc/interrupts | grep eth0
>  63:   44614125   95472512   PCI-MSI-edge      eth0
>=20
> lspci -v:
>=20
> 03:00.0 Ethernet controller: Broadcom Corporation NetXtreme II BCM570=
8 Gigabit Ethernet (rev 12)
>         Subsystem: Hewlett-Packard Company NC373i Integrated Multifun=
ction Gigabit Server Adapter
>         Flags: bus master, 66MHz, medium devsel, latency 64, IRQ 63
>         Memory at f8000000 (64-bit, non-prefetchable) [size=3D32M]
>         [virtual] Expansion ROM at 88200000 [disabled] [size=3D2K]
>         Capabilities: [40] PCI-X non-bridge device
>         Capabilities: [48] Power Management version 2
>         Capabilities: [50] Vital Product Data <?>
>         Capabilities: [58] Message Signalled Interrupts: Mask- 64bit+=
 Queue=3D0/0 Enable+
>         Kernel driver in use: bnx2
>         Kernel modules: bnx2
>=20
>=20
> Any ideas on how to force it on a single CPU ?
>=20
> Thanks for the new patch, I will try it and let you know.
>=20

Yes, its doable but tricky with bnx2, this is a known problem on recent=
 kernels as well.


You must do for example (to bind on CPU 0)

echo 1 >/proc/irq/default_smp_affinity

ifconfig eth1 down
# IRQ of eth1 handled by CPU0 only
echo 1 >/proc/irq/34/smp_affinity
ifconfig eth1 up

ifconfig eth0 down
# IRQ of eth0 handled by CPU0 only
echo 1 >/proc/irq/36/smp_affinity
ifconfig eth0 up


One thing to consider too is the BIOS option you might have, labeled "A=
djacent Sector Prefetch"

This basically tells your cpu to use 128 bytes cache lines, instead of =
64

In your forwarding worload, I believe this extra prefetch can slowdown =
your machine.


