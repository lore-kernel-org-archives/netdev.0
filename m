From: Gregory Haskins <ghaskins@novell.com>
Subject: Re: [RFC PATCH 00/17] virtual-bus
Date: Wed, 01 Apr 2009 18:10:17 -0400
Message-ID: <49D3E649.7000906@novell.com>
References: <20090331184057.28333.77287.stgit@dev.haskins.net> <87ab71monw.fsf@basil.nowhere.org> <49D35825.3050001@novell.com> <20090401132340.GT11935@one.firstfloor.org> <49D37805.1060301@novell.com> <20090401170103.GU11935@one.firstfloor.org> <49D3B64F.6070703@codemonkey.ws> <20090401204039.GR18394@sequoia.sous-sol.org> <49D3D88E.3090009@novell.com> <20090401212830.GT18394@sequoia.sous-sol.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigD0083754C1714401B1D42039"
Cc: Anthony Liguori <anthony@codemonkey.ws>,
	Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org,
	agraf@suse.de, pmullaney@novell.com, pmorreale@novell.com,
	rusty@rustcorp.com.au, netdev@vger.kernel.org, kvm@vger.kernel.org
To: Chris Wright <chrisw@sous-sol.org>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20090401212830.GT18394@sequoia.sous-sol.org>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigD0083754C1714401B1D42039
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Chris Wright wrote:
> * Gregory Haskins (ghaskins@novell.com) wrote:
>  =20
>> Note that the design of vbus should prevent any weakening
>>    =20
>
> Could you elaborate?
>  =20

Absolutely.

So you said that something in the kernel could weaken the
protection/isolation.  And I fully agree that whatever we do here has to
be done carefully...more carefully than a userspace derived counterpart,
naturally.

So to address this, I put in various mechanisms to (hopefully? :) ensure
we can still maintain proper isolation, as well as protect the host,
other guests, and other applications from corruption.  Here are some of
the highlights:

*) As I mentioned, a "vbus" is a form of a kernel-resource-container.=20
It is designed so that the view of a vbus is a unique namespace of
device-ids.  Each bus has its own individual namespace that consist
solely of the devices that have been placed on that bus.  The only way
to create a bus, and/or create a device on a bus, is via the
administrative interface on the host.

*) A task can only associate with, at most, one vbus at a time.  This
means that a task can only see the device-id namespace of the devices on
its associated bus and thats it.  This is enforced by the host kernel by
placing a reference to the associated vbus on the task-struct itself.=20
Again, the only way to modify this association is via a host based
administrative operation.  Note that multiple tasks can associate to the
same vbus, which would commonly be used by all threads in an app, or all
vcpus in a guest, etc.

*) the asynchronous nature of the shm/ring interfaces implies we have
the potential for asynchronous faults.  E.g. "crap" in the ring might
not be discovered at the EIP of the guest vcpu when it actually inserts
the crap, but rather later when the host side tries to update the ring.=20
A naive implementation would have the host do a BUG_ON() when it
discovers the discrepancy (note that I still have a few of these to fix
in the venet-tap code).  Instead, what should happen is that we utilize
an asynchronous fault mechanism that allows the guest to always be the
one punished (via something like a machine-check for guests, or SIGABRT
for userspace, etc)

*) "south-to-north path signaling robustness".  Because vbus supports a
variety of different environments, I call guest/userspace "north', and
the host/kernel "south".  When the north wants to communicate with the
kernel, its perfectly ok to stall the north indefinitely if the south is
not ready.  However, it is not really ok to stall the south when
communicating with the north because this is an attack vector.  E.g. a
malicous/broken guest could just stop servicing its ring to cause
threads in the host to jam up.  This is bad. :)  So what we do is we
design all south-to-north signaling paths to be robust against
stalling.  What they do instead is manage backpressure a little bit more
intelligently than simply blocking like they might in the guest.  For
instance, in venet-tap, a "transmit" from netif that has to be injected
in the south-to-north ring when it is full will result in a
netif_stop_queue().   etc.

I cant think of more examples right now, but I will update this list
if/when I come up with more.  I hope that satisfactorily answered your
question, though!

Regards,
-Greg


--------------enigD0083754C1714401B1D42039
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.9 (GNU/Linux)
Comment: Using GnuPG with SUSE - http://enigmail.mozdev.org

iEYEARECAAYFAknT5kkACgkQlOSOBdgZUxn3gwCfXfWVTztWpilr6M6M7kWyncff
7O0An0tJsr5/YaQzQMpjncXQik5bWZ9a
=SUbu
-----END PGP SIGNATURE-----

--------------enigD0083754C1714401B1D42039--
