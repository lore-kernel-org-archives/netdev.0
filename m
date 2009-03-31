From: Gregory Haskins <ghaskins@novell.com>
Subject: Re: [RFC PATCH 15/17] kvm: add dynamic IRQ support
Date: Tue, 31 Mar 2009 16:32:19 -0400
Message-ID: <49D27DD3.5080609@novell.com>
References: <20090331184057.28333.77287.stgit@dev.haskins.net> <20090331184405.28333.59205.stgit@dev.haskins.net> <49D26CFE.1060700@redhat.com> <49D2718F.9070203@novell.com> <49D27950.9020801@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigDFA0C49CA6F4D0EA40ADD7FF"
Cc: linux-kernel@vger.kernel.org, agraf@suse.de, pmullaney@novell.com,
	pmorreale@novell.com, anthony@codemonkey.ws, rusty@rustcorp.com.au,
	netdev@vger.kernel.org, kvm@vger.kernel.org
To: Avi Kivity <avi@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from victor.provo.novell.com ([137.65.250.26]:58426 "EHLO
	victor.provo.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751397AbZCaUaH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2009 16:30:07 -0400
In-Reply-To: <49D27950.9020801@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigDFA0C49CA6F4D0EA40ADD7FF
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Avi Kivity wrote:
> Gregory Haskins wrote:
>>> - works with all guests
>>> - supports hotplug/hotunplug, udev, sysfs, module autoloading, ...
>>> - supported in all OSes
>>> - someone else maintains it
>>>    =20
>> These points are all valid, and I really struggled with this particula=
r
>> part of the design.  The entire vbus design only requires one IRQ for
>> the entire guest,
>
> Won't this have scaling issues?  One IRQ means one target vcpu.=20
> Whereas I'd like virtio devices to span multiple queues, each queue
> with its own MSI IRQ.
Hmm..you know I hadnt really thought of it that way, but you have a
point.  To clarify, my design actually uses one IRQ per "eventq", where
we can have an arbitrary number of eventq's defined (note: today I only
define one eventq, however).  An eventq is actually a shm-ring construct
where I can pass events up to the host like "device added" or "ring X
signaled".  Each individual device based virtio-ring would then
aggregates "signal" events onto this eventq mechanism to actually inject
events to the host.  Only the eventq itself injects an actual IRQ to the
assigned vcpu.

My intended use of multiple eventqs was for prioritization of different
rings.  For instance, we could define 8 priority levels, each with its
own ring/irq.  That way, a virtio-net that supports something like
802.1p could define 8 virtio-rings, one for each priority level.

But this scheme is more targeted at prioritization than per vcpu
irq-balancing.  I support the eventq construct I proposed could still be
used in this fashion since each has its own routable IRQ.  However, I
would have to think about that some more because it is beyond the design
spec.

The good news is that the decision to use the "eventq+irq" approach is
completely contained in the kvm-host+guest.patch.  We could easily
switch to a 1:1 irq:shm-signal if we wanted to, and the device/drivers
would work exactly the same without modification.

>   Also, the single IRQ handler will need to scan for all potential IRQ
> sources.  Even if implemented carefully, this will cause many
> cacheline bounces.
Well, no, I think this part is covered.  As mentioned above, we use a
queuing technique so there is no scanning needed.  Ultimately I would
love to adapt a similar technique to optionally replace the LAPIC.  That
way we can avoid the EOI trap and just consume the next interrupt (if
applicable) from the shm-ring.

>
>>  so its conceivable that I could present a simple
>> "dummy" PCI device with some "VBUS" type PCI-ID, just to piggy back on=

>> the IRQ routing logic.  Then userspace could simply pass the IRQ routi=
ng
>> info down to the kernel with an ioctl, or something similar.
>>  =20
>
> Xen does something similar, I believe.
>
>> I think ultimately I was trying to stay away from PCI in general becau=
se
>> I want to support environments that do not have PCI.  However, for the=

>> kvm-transport case (at least on x86) this isnt really a constraint.
>>
>>  =20
>
> s/PCI/the native IRQ solution for your platform/. virtio has the same
> problem; on s390 we use the native (if that word ever applies to s390)
> interrupt and device discovery mechanism.

yeah, I agree.  We can contain the "exposure" of PCI to just platforms
within KVM that care about it.

-Greg



--------------enigDFA0C49CA6F4D0EA40ADD7FF
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.9 (GNU/Linux)
Comment: Using GnuPG with SUSE - http://enigmail.mozdev.org

iEYEARECAAYFAknSfdMACgkQlOSOBdgZUxn8GwCfY7jZSPBYT0FsCZBduhCRbqq2
+s8AnRMt7qWgoBuRKiHXbxo+3BLygXZr
=cuZA
-----END PGP SIGNATURE-----

--------------enigDFA0C49CA6F4D0EA40ADD7FF--
