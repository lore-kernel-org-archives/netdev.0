From: Gregory Haskins <gregory.haskins@gmail.com>
Subject: Re: [GIT PULL] AlacrityVM guest drivers for 2.6.33
Date: Sun, 27 Dec 2009 09:29:47 -0500
Message-ID: <4B376F5B.9050402@gmail.com>
References: <4B1D4F29.8020309@gmail.com> <87637zdy9g.fsf@basil.nowhere.org> <4B30E654.40702@codemonkey.ws> <200912221701.56840.bzolnier@gmail.com> <4B30F214.80206@codemonkey.ws> <20091223065129.GA19600@elte.hu> <4B3248F9.5030504@gmail.com> <4B327F3A.9020101@redhat.com> <4B328535.5040105@redhat.com> <4B33361E.3000605@gmail.com> <4B3729ED.50006@redhat.com> <4B376276.3020105@gmail.com> <4B3765D2.5020805@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig6B874E28D1DB7129EFA76184"
Cc: Ingo Molnar <mingo@elte.hu>,
	Anthony Liguori <anthony@codemonkey.ws>,
	Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>,
	Andi Kleen <andi@firstfloor.org>, kvm@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	torvalds@linux-foundation.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org,
	"alacrityvm-devel@lists.sourceforge.net"
	<alacrityvm-devel@lists.sourceforge.net>
To: Avi Kivity <avi@redhat.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752311AbZL0O3z@vger.kernel.org>
In-Reply-To: <4B3765D2.5020805@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig6B874E28D1DB7129EFA76184
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 12/27/09 8:49 AM, Avi Kivity wrote:
> On 12/27/2009 03:34 PM, Gregory Haskins wrote:
>> On 12/27/09 4:33 AM, Avi Kivity wrote:
>>  =20
>>> On 12/24/2009 11:36 AM, Gregory Haskins wrote:
>>>    =20
>>>>> As a twist on this, the VMware paravirt driver interface is so
>>>>> hardware-like that they're getting hardware vendors to supply cards=

>>>>> that
>>>>> implement it.  Try that with a pure software approach.
>>>>>
>>>>>         =20
>>>> Any hardware engineer (myself included) will tell you that, generall=
y
>>>> speaking, what you can do in hardware you can do in software (think =
of
>>>> what QEMU does today, for instance).  It's purely a cost/performance=

>>>> tradeoff.
>>>>
>>>> I can at least tell you that is true of vbus.  Anything on the vbus
>>>> side
>>>> would be equally eligible for a hardware implementation, though
>>>> there is
>>>> not reason to do this today since we have equivalent functionality i=
n
>>>> baremetal already.
>>>>       =20
>>> There's a huge difference in the probability of vmware getting cards =
to
>>> their spec, or x86 vendors improving interrupt delivery to guests,
>>> compared to vbus being implemented in hardware.
>>>     =20
>> Thats not relevant, however.  I said in the original quote that you
>> snipped that I made it a software design on purpose, and you tried to
>> somehow paint that as a negative because vmware made theirs
>> "hardware-like" and you implied it could not be done with my approach
>> with the statement "try that with a pure software approach".  And the
>> bottom line is that the statement is incorrect and/or misleading.
>>   =20
>=20
> It's not incorrect.

At the very best it's misleading.

> VMware stuck to the pci specs and as a result they
> can have hardware implement their virtual NIC protocol.  For vbus this
> is much harder

Not really.

> to do since you need a side-channel between different
> cards to coordinate interrupt delivery.  In theory you can do eveything=

> if you don't consider practicalities.

pci based designs, such as vmware and virtio-pci arent free of this
notion either.  They simply rely on APIC emulation for the irq-chip, and
it just so happens that vbus implements a different irq-chip (more
specifically, the connector that we employ between the guest and vbus
does).  On one hand, you have the advantage of the guest already
supporting the irq-chip ABI, and on other other, you have an optimized
(e.g. shared memory based inject/ack) and feature enhanced ABI
(interrupt priority, no IDT constraints, etc).  The are pros and cons to
either direction, but the vbus project charter is to go for maximum
performance and features, so that is acceptable to us.


>=20
> That's a digression, though, I'm not suggesting we'll see virtio
> hardware or that this is a virtio/pci advantage vs. vbus.  It's an
> anecdote showing that sticking with specs has its advantages.

It also has distinct disadvantages.  For instance, the PCI spec is
gigantic, yet almost none of it is needed to do the job here.  When you
are talking full-virt, you are left with no choice.  With para-virt, you
do have a choice, and the vbus-connector for AlacrityVM capitalizes on th=
is.

As an example, think about all the work that went into emulating the PCI
chipset, the APIC chipset, MSI-X support, irq-routing, etc, when all you
needed was a simple event-queue to indicate that an event (e.g. an
"interrupt") occurred.

This is an example connector in vbus:

http://git.kernel.org/?p=3Dlinux/kernel/git/ghaskins/alacrityvm/linux-2.6=
=2Egit;a=3Dblob;f=3Dkernel/vbus/connectors/null.c;h=3Db6d16cb68b7e49e0752=
8278bc9f5b73e1dac0c2f;hb=3DHEAD

It encapsulates all of hotplug, signal (interrupt) routing, and memory
routing for both sides of the "link" in 584 lines of code.  And that
also implicitly brings in device discovery and configuration since that
is covered by the vbus framework.  Try doing that with PCI, especially
when you are not already under the qemu umbrella, and the "standards
based" approach suddenly doesn't look very attractive.

>=20
> wrt pci vs vbus, the difference is in the ability to use improvements i=
n
> interrupt delivery accelerations in virt hardware.

Most of which will also apply to the current vbus design as well since
at some point I have to have an underlying IDT mechanism too, btw.

>  If this happens,
> virtio/pci can immediately take advantage of it, while vbus has to stic=
k
> with software delivery for backward compatibility, and all that code
> becomes a useless support burden.
>

The shared-memory path will always be the fastest anyway, so I am not
too worried about it.  But vbus supports feature negotiation, so we can
always phase that out if need be, same as anything else.

> As an example of what hardware can do when it really sets its mind to
> it, s390 can IPI from vcpu to vcpu without exiting to the host.

Great!  I am just not in the practice of waiting for hardware to cover
sloppy software.  There is a ton of impracticality in doing so, such as
the fact that the hardware, even once available, will not be ubiquitous
instantly.

>=20
>>>> The only motiviation is if you wanted to preserve
>>>> ABI etc, which is what vmware is presumably after.  However, I am no=
t
>>>> advocating this as necessary at this juncture.
>>>>
>>>>       =20
>>> Maybe AlacrityVM users don't care about compatibility, but my users d=
o.
>>>     =20
>> Again, not relevant to this thread.  Making your interface
>> "hardware-like" buys you nothing in the end, as you ultimately need to=

>> load drivers in the guest either way, and any major OS lets you extend=

>> both devices and buses with relative ease.  The only counter example
>> would be if you truly were "hardware-exactly" like e1000 emulation, bu=
t
>> we already know that this means it is hardware centric and not
>> "exit-rate aware" and would perform poorly.  Otherwise "compatible" is=

>> purely a point on the time line (for instance, the moment virtio-pci A=
BI
>> shipped), not an architectural description such as "hardware-like".
>>   =20
>=20
> True, not related to the thread.  But it is a problem.

Agreed.  It is a distinct disadvantage to switching.  Note that I am not
advocating that we need to switch.  virtio-pci can coexist peacefully
from my perspective, and AlacrityVM does exactly this.

-Greg


--------------enig6B874E28D1DB7129EFA76184
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.11 (Darwin)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAks3b1sACgkQP5K2CMvXmqF+SACeKHP0hftW5ptgrXqv0x5T1G48
3zIAoIiUinXLlgpXQTsKrpSZ6sCaqPws
=l0Qu
-----END PGP SIGNATURE-----

--------------enig6B874E28D1DB7129EFA76184--
