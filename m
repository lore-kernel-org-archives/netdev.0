From: Gregory Haskins <ghaskins@novell.com>
Subject: Re: [RFC PATCH 00/17] virtual-bus
Date: Fri, 03 Apr 2009 09:13:53 -0400
Message-ID: <49D60B91.6010503@novell.com>
References: <20090331184057.28333.77287.stgit@dev.haskins.net> <87ab71monw.fsf@basil.nowhere.org> <49D35825.3050001@novell.com> <20090401132340.GT11935@one.firstfloor.org> <49D37805.1060301@novell.com> <20090401170103.GU11935@one.firstfloor.org> <49D3B64F.6070703@codemonkey.ws> <49D3D7EE.4080202@novell.com> <49D46089.5040204@redhat.com> <49D497A1.4090900@novell.com> <49D4A4EB.8020105@redhat.com> <49D4AE0C.3000604@novell.com> <49D4B2C0.5060906@redhat.com> <49D4B594.6080703@novell.com> <49D4B8B4.4020003@redhat.com> <49D4BF70.1060301@novell.com> <49D4C191.2070502@redhat.com> <49D4CAA7.3020004@novell.com> <49D4CC61.6010105@redhat.com> <49D4CEB1.9020001@redhat.com> <49D4D075.9010702@codemonkey.ws> <49D4E33F.5000303@codemonkey.ws> <49D5FAFD.1010102@novell.com> <49D5FDF9.7090602@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig733D7CCCD7B65DB61A41A28C"
Cc: Anthony Liguori <anthony@codemonkey.ws>,
	Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org,
	agraf@suse.de, pmullaney@novell.com, pmorreale@novell.com,
	rusty@rustcorp.com.au, netdev@vger.kernel.org, kvm@vger.kernel.org
To: Avi Kivity <avi@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from victor.provo.novell.com ([137.65.250.26]:37970 "EHLO
	victor.provo.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752667AbZDCNLo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Apr 2009 09:11:44 -0400
In-Reply-To: <49D5FDF9.7090602@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig733D7CCCD7B65DB61A41A28C
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Avi Kivity wrote:
> Gregory Haskins wrote:
>> So again, I am proposing for consideration of accepting my work (eithe=
r
>> in its current form, or something we agree on after the normal review
>> process) not only on the basis of the future development of the
>> platform, but also to keep current components in their running to thei=
r
>> full potential.  I will again point out that the code is almost
>> completely off to the side, can be completely disabled with config
>> options, and I will maintain it.  Therefore the only real impact is to=

>> people who care to even try it, and to me.
>>  =20
>
> Your work is a whole stack.  Let's look at the constituents.
>
> - a new virtual bus for enumerating devices.
>
> Sorry, I still don't see the point.  It will just make writing drivers
> more difficult.  The only advantage I've heard from you is that it
> gets rid of the gunk.  Well, we still have to support the gunk for
> non-pv devices so the gunk is basically free.  The clean version is
> expensive since we need to port it to all guests and implement
> exciting features like hotplug.
My real objection to PCI is fast-path related.  I don't object, per se,
to using PCI for discovery and hotplug.  If you use PCI just for these
types of things, but then allow fastpath to use more hypercall oriented
primitives, then I would agree with you.  We can leave PCI emulation in
user-space, and we get it for free, and things are relatively tidy.

Its once you start requiring that we stay ABI compatible with something
like the existing virtio-net in x86 KVM where I think it starts to get
ugly when you try to move it into the kernel.  So that is what I had a
real objection to.  I think as long as we are not talking about trying
to make something like that work, its a much more viable prospect.

So what I propose is the following:=20

1) The core vbus design stays the same (or close to it)
2) the vbus-proxy and kvm-guest patch go away
3) the kvm-host patch changes to work with coordination from the
userspace-pci emulation for things like MSI routing
4) qemu will know to create some MSI shim 1:1 with whatever it
instantiates on the bus (and can communicate changes
5) any drivers that are written for these new PCI-IDs that might be
present are allowed to use a hypercall ABI to talk after they have been
probed for that ID (e.g. they are not limited to PIO or MMIO BAR type
access methods).

Once I get here, I might have greater clarity to see how hard it would
make to emulate fast path components as well.  It might be easier than I
think.

This is all off the cuff so it might need some fine tuning before its
actually workable.

Does that sound reasonable?

>
> - finer-grained point-to-point communication abstractions
>
> Where virtio has ring+signalling together, you layer the two.  For
> networking, it doesn't matter.  For other applications, it may be
> helpful, perhaps you have something in mind.

Yeah, actually.  Thanks for bringing that up.

So the reason why signaling and the ring are distinct constructs in the
design is to facilitate constructs other than rings.  For instance,
there may be some models where having a flat shared page is better than
a ring.  A ring will naturally preserve all values in flight, where as a
flat shared page would not (last update is always current).  There are
some algorithms where a previously posted value is obsoleted by an
update, and therefore rings are inherently bad for this update model.=20
And as we know, there are plenty of algorithms where a ring works
perfectly.  So I wanted that flexibility to be able to express both.

One of the things I have in mind for the flat page model is that RT vcpu
priority thing.  Another thing I am thinking of is coming up with a PV
LAPIC type replacement (where we can avoid doing the EOI trap by having
the PICs state shared).

>
> - your "bidirectional napi" model for the network device
>
> virtio implements exactly the same thing, except for the case of tx
> mitigation, due to my (perhaps pig-headed) rejection of doing things
> in a separate thread, and due to the total lack of sane APIs for
> packet traffic.

Yeah, and this part is not vbus, nor in-kernel specific.  That was just
a design element of venet-tap.  Though note, I did design the
vbus/shm-signal infrastructure with rich support for such a notion in
mind, so it wasn't accidental or anything like that.

>
> - a kernel implementation of the host networking device
>
> Given the continuous rejection (or rather, their continuous
> non-adoption-and-implementation) of my ideas re zerocopy networking
> aio, that seems like a pragmatic approach.  I wish it were otherwise.

Well, that gives me hope, at least ;)


>
> - a promise of more wonderful things yet to come
>
> Obviously I can't evaluate this.

Right, sorry.  I wish I had more concrete examples to show you, but we
only have the venet-tap working at this time.  I was going for the
"release early/often" approach in getting the core reviewed before we
got too far down a path, but perhaps that was the wrong thing in this
case.  We will certainly be sending updates as we get some of the more
advanced models and concepts working.

-Greg


--------------enig733D7CCCD7B65DB61A41A28C
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.9 (GNU/Linux)
Comment: Using GnuPG with SUSE - http://enigmail.mozdev.org

iEYEARECAAYFAknWC5EACgkQlOSOBdgZUxlXgwCeORkzOrdfBvNx3pOdpQeAAXBr
++sAn1jN7EeqGm+D3diQiRjZt4bxVKWH
=tiRP
-----END PGP SIGNATURE-----

--------------enig733D7CCCD7B65DB61A41A28C--
