From: Gregory Haskins <ghaskins@novell.com>
Subject: Re: [RFC PATCH 00/17] virtual-bus
Date: Wed, 01 Apr 2009 08:03:49 -0400
Message-ID: <49D35825.3050001@novell.com>
References: <20090331184057.28333.77287.stgit@dev.haskins.net> <87ab71monw.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigB8DC867B88B8805F65F8D5B2"
Cc: linux-kernel@vger.kernel.org, agraf@suse.de, pmullaney@novell.com,
	pmorreale@novell.com, anthony@codemonkey.ws, rusty@rustcorp.com.au,
	netdev@vger.kernel.org, kvm@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from victor.provo.novell.com ([137.65.250.26]:47104 "EHLO
	victor.provo.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754302AbZDAMBb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2009 08:01:31 -0400
In-Reply-To: <87ab71monw.fsf@basil.nowhere.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigB8DC867B88B8805F65F8D5B2
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Andi Kleen wrote:
> Gregory Haskins <ghaskins@novell.com> writes:
>
> What might be useful is if you could expand a bit more on what the high=
 level
> use cases for this.=20
>
> Questions that come to mind and that would be good to answer:
>
> This seems to be aimed at having multiple VMs talk
> to each other, but not talk to the rest of the world, correct?=20
> Is that a common use case?=20
>  =20

Actually we didn't design specifically for either type of environment.=20
I think it would, in fact, be well suited to either type of
communication model, even concurrently (e.g. an intra-vm ipc channel
resource could live right on the same bus as a virtio-net and a
virtio-disk resource)

> Wouldn't they typically have a default route  anyways and be able to ta=
lk to each=20
> other this way?=20
> And why can't any such isolation be done with standard firewalling? (it=
's known that=20
> current iptables has some scalability issues, but there's work going on=
 right
> now to fix that).=20
>  =20
vbus itself, and even some of the higher level constructs we apply on
top of it (like venet) are at a different scope than I think what you
are getting at above.  Yes, I suppose you could create a private network
using the existing virtio-net + iptables.  But you could also do the
same using virtio-net and a private bridge devices as well.  That is not
what we are trying to address.

What we *are* trying to address is making an easy way to declare virtual
resources directly in the kernel so that they can be accessed more
efficiently.  Contrast that to the way its done today, where the models
live in, say, qemu userspace.

So instead of having
guest->host->qemu::virtio-net->tap->[iptables|bridge], you simply have
guest->host->[iptables|bridge].  How you make your private network (if
that is what you want to do) is orthogonal...its the path to get there
that we changed.

> What would be the use cases for non networking devices?
>
> How would the interfaces to the user look like?
>  =20

I am not sure if you are asking about the guests perspective or the
host-administators perspective.

First now lets look at the low-level device interface from the guests
perspective.  We can cover the admin perspective in a separate doc, if
need be.

Each device in vbus supports two basic verbs: CALL, and SHM

int (*call)(struct vbus_device_proxy *dev, u32 func,
            void *data, size_t len, int flags);

int (*shm)(struct vbus_device_proxy *dev, int id, int prio,
           void *ptr, size_t len,
           struct shm_signal_desc *sigdesc, struct shm_signal **signal,
           int flags);

CALL provides a synchronous method for invoking some verb on the device
(defined by "func") with some arbitrary data.  The namespace for "func"
is part of the ABI for the device in question.  It is analogous to an
ioctl, with the primary difference being that its remotable (it invokes
from the guest driver across to the host device).

SHM provides a way to register shared-memory with the device which can
be used for asynchronous communication.  The memory is always owned by
the "north" (the guest), while the "south" (the host) simply maps it
into its address space.  You can optionally establish a shm_signal
object on this memory for signaling in either direction, and I
anticipate most shm regions will use this feature.  Each shm region has
an "id" namespace, which like the "func" namespace from the CALL method
is completely owned by the device ABI.  For example, we have might have
id's of "RX-RING" and "TX-RING", etc.

=46rom there, we can (hopefully) build an arbitrary type of IO service to=

map on top.  So for instance, for venet-tap, we have CALL verbs for
things like MACQUERY, and LINKUP, and we have SHM ids for RX-QUEUE and
TX-QUEUE.  We can write a driver that speaks this ABI on the bottom
edge, and presents a normal netif interface on the top edge.  So the
actual consumption of these resources can look just like another other
resource of a similar type.

-Greg


--------------enigB8DC867B88B8805F65F8D5B2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.9 (GNU/Linux)
Comment: Using GnuPG with SUSE - http://enigmail.mozdev.org

iEYEARECAAYFAknTWCUACgkQlOSOBdgZUxkqbACcDXBZAmQOVVarZNJ82bXiNqHe
RHkAnjyIKtjLd5IhLfhVjGEbvo/sFJ2h
=QKxy
-----END PGP SIGNATURE-----

--------------enigB8DC867B88B8805F65F8D5B2--
