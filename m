From: Gregory Haskins <ghaskins@novell.com>
Subject: Re: [RFC PATCH 15/17] kvm: add dynamic IRQ support
Date: Tue, 31 Mar 2009 15:39:59 -0400
Message-ID: <49D2718F.9070203@novell.com>
References: <20090331184057.28333.77287.stgit@dev.haskins.net> <20090331184405.28333.59205.stgit@dev.haskins.net> <49D26CFE.1060700@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig5C8B0AB03AD9C6BA9D8D181F"
Cc: linux-kernel@vger.kernel.org, agraf@suse.de, pmullaney@novell.com,
	pmorreale@novell.com, anthony@codemonkey.ws, rusty@rustcorp.com.au,
	netdev@vger.kernel.org, kvm@vger.kernel.org
To: Avi Kivity <avi@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <49D26CFE.1060700@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig5C8B0AB03AD9C6BA9D8D181F
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Avi Kivity wrote:
> Gregory Haskins wrote:
>> This patch provides the ability to dynamically declare and map an
>> interrupt-request handle to an x86 8-bit vector.
>>
>> Problem Statement: Emulated devices (such as PCI, ISA, etc) have
>> interrupt routing done via standard PC mechanisms (MP-table, ACPI,
>> etc).  However, we also want to support a new class of devices
>> which exist in a new virtualized namespace and therefore should
>> not try to piggyback on these emulated mechanisms.  Rather, we
>> create a way to dynamically register interrupt resources that
>> acts indepent of the emulated counterpart.
>>
>> On x86, a simplistic view of the interrupt model is that each core
>> has a local-APIC which can recieve messages from APIC-compliant
>> routing devices (such as IO-APIC and MSI) regarding details about
>> an interrupt (such as which vector to raise).  These routing devices
>> are controlled by the OS so they may translate a physical event
>> (such as "e1000: raise an RX interrupt") to a logical destination
>> (such as "inject IDT vector 46 on core 3").  A dynirq is a virtual
>> implementation of such a router (think of it as a virtual-MSI, but
>> without the coupling to an existing standard, such as PCI).
>>
>> The model is simple: A guest OS can allocate the mapping of "IRQ"
>> handle to "vector/core" in any way it sees fit, and provide this
>> information to the dynirq module running in the host.  The assigned
>> IRQ then becomes the sole handle needed to inject an IDT vector
>> to the guest from a host.  A host entity that wishes to raise an
>> interrupt simple needs to call kvm_inject_dynirq(irq) and the routing
>> is performed transparently.
>>  =20
>
> A major disadvantage of dynirq is that it will only work on guests
> which have been ported to it.  So this will only be useful on newer
> Linux, and will likely never work with Windows guests.
>
> Why is having an emulated PCI device so bad?  We found that it has
> several advantages:
> - works with all guests
> - supports hotplug/hotunplug, udev, sysfs, module autoloading, ...
> - supported in all OSes
> - someone else maintains it
These points are all valid, and I really struggled with this particular
part of the design.  The entire vbus design only requires one IRQ for
the entire guest, so its conceivable that I could present a simple
"dummy" PCI device with some "VBUS" type PCI-ID, just to piggy back on
the IRQ routing logic.  Then userspace could simply pass the IRQ routing
info down to the kernel with an ioctl, or something similar.

Ultimately I wasn't sure whether I wanted all that goo just to get an
IRQ assignment...but on the other hand, we have all this goo to build
one in the first place, and its half on the guest side which has the
disadvantages you mention.  So perhaps this should go in favor of a
PCI-esqe type solution, as I think you are suggesting.

I think ultimately I was trying to stay away from PCI in general because
I want to support environments that do not have PCI.  However, for the
kvm-transport case (at least on x86) this isnt really a constraint.

>
> See also the kvm irq routing work, merged into 2.6.30, which does a
> small part of what you're describing (the "sole handle" part,
> specifically).

I will take a look, thanks!

(I wish I wish you had accepted those irq patches I wrote a while back.=20
It had the foundation for this type of stuff all built in.  But alas, I
think it was before its time, and I didn't do a good job of explaining
my future plans....) ;)

Regards,
-Greg





--------------enig5C8B0AB03AD9C6BA9D8D181F
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.9 (GNU/Linux)
Comment: Using GnuPG with SUSE - http://enigmail.mozdev.org

iEYEARECAAYFAknScY8ACgkQlOSOBdgZUxmxtQCfVF8Oe0I62LkhTdYyu/+WxseR
TsgAn0Dfd78oMnbbGy6N152wV/6NDV9Y
=cE/f
-----END PGP SIGNATURE-----

--------------enig5C8B0AB03AD9C6BA9D8D181F--
