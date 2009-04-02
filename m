From: Gregory Haskins <ghaskins@novell.com>
Subject: Re: [RFC PATCH 00/17] virtual-bus
Date: Wed, 01 Apr 2009 22:27:28 -0400
Message-ID: <49D42290.1000907@novell.com>
References: <20090331184057.28333.77287.stgit@dev.haskins.net> <200904011638.45135.rusty@rustcorp.com.au> <49D3518B.1030403@novell.com> <200904021154.14082.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigE958B7CA7BC9D8E8DE545103"
Cc: linux-kernel@vger.kernel.org, agraf@suse.de, pmullaney@novell.com,
	pmorreale@novell.com, anthony@codemonkey.ws,
	netdev@vger.kernel.org, kvm@vger.kernel.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <200904021154.14082.rusty@rustcorp.com.au>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigE958B7CA7BC9D8E8DE545103
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: quoted-printable

Rusty Russell wrote:
> On Wednesday 01 April 2009 22:05:39 Gregory Haskins wrote:
>  =20
>> Rusty Russell wrote:
>>    =20
>>> I could dig through the code, but I'll ask directly: what heuristic d=
o
>>> you use for notification prevention in your venet_tap driver?
>>>      =20
>> I am not 100% sure I know what you mean with "notification prevention"=
,
>> but let me take a stab at it.
>>    =20
>
> Good stab :)
>
>  =20
>> I only signal back to the guest to reclaim its skbs every 10
>> packets, or if I drain the queue, whichever comes first (note to self:=

>> make this # configurable).
>>    =20
>
> Good stab, though I was referring to guest->host signals (I'll assume
> you use a similar scheme there).
>  =20
Oh, actually no.  The guest->host path only uses the "bidir napi" thing
I mentioned.  So first packet hypercalls the host immediately with no
delay, schedules my host-side "rx" thread, disables subsequent
hypercalls, and returns to the guest.  If the guest tries to send
another packet before the time it takes the host to drain all queued
skbs (in this case, 1), it will simply queue it to the ring with no
additional hypercalls.    Like typical napi ingress processing, the host
will leave hypercalls disabled until it finds the ring empty, so this
process can continue indefinitely until the host catches up.  Once fully
drained,  the host will re-enable the hypercall channel and subsequent
transmissions will repeat the original process.

In summary, infrequent transmissions will tend to have one hypercall per
packet.  Bursty transmissions will have one hypercall per burst
(starting immediately with the first packet).  In both cases, we
minimize the latency to get the first packet "out the door".

So really the only place I am using a funky heuristic is the modulus 10
operation for tx-complete going host->guest.  The rest are kind of
standard napi event mitigation techniques.

> You use a number of packets, qemu uses a timer (150usec), lguest uses a=

> variable timer (starting at 500usec, dropping by 1 every time but incre=
asing
> by 10 every time we get fewer packets than last time).
>
> So, if the guest sends two packets and stops, you'll hang indefinitely?=

>  =20
Shouldn't, no.  The host will send tx-complete interrupts at *max* every
10 packets, but if it drains the queue before the modulus 10 expires, it
will send a tx-complete immediately, right before it re-enables
hypercalls.  So there is no hang, and there is no delay.

For reference, here is the modulus 10 signaling
(./drivers/vbus/devices/venet-tap.c, line 584):

http://git.kernel.org/?p=3Dlinux/kernel/git/ghaskins/vbus/linux-2.6.git;a=
=3Dblob;f=3Ddrivers/vbus/devices/venet-tap.c;h=3D0ccb7ed94a1a8edd0cca2694=
88f940f40fce20df;hb=3Dmaster#l584

Here is the one that happens after the queue is fully drained (line 593)

http://git.kernel.org/?p=3Dlinux/kernel/git/ghaskins/vbus/linux-2.6.git;a=
=3Dblob;f=3Ddrivers/vbus/devices/venet-tap.c;h=3D0ccb7ed94a1a8edd0cca2694=
88f940f40fce20df;hb=3Dmaster#l593

and finally, here is where I re-enable hypercalls (or system calls if
the driver is in userspace, etc)

http://git.kernel.org/?p=3Dlinux/kernel/git/ghaskins/vbus/linux-2.6.git;a=
=3Dblob;f=3Ddrivers/vbus/devices/venet-tap.c;h=3D0ccb7ed94a1a8edd0cca2694=
88f940f40fce20df;hb=3Dmaster#l600

> That's why we use a timer, otherwise any mitigation scheme has this iss=
ue.
>  =20

I'm not sure I follow.  I don't think I need a timer at all using this
scheme, but perhaps I am missing something?

Thanks Rusty!
-Greg




--------------enigE958B7CA7BC9D8E8DE545103
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.9 (GNU/Linux)
Comment: Using GnuPG with SUSE - http://enigmail.mozdev.org

iEYEARECAAYFAknUIpAACgkQlOSOBdgZUxmuSACeJnmTEVNFs9EcJHe9ECwdKEyh
v3kAn3n7AQBFlv85lMCx/rQHiIRD62Xs
=D2p+
-----END PGP SIGNATURE-----

--------------enigE958B7CA7BC9D8E8DE545103--
