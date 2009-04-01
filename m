From: Gregory Haskins <ghaskins@novell.com>
Subject: Re: [RFC PATCH 00/17] virtual-bus
Date: Wed, 01 Apr 2009 19:05:03 -0400
Message-ID: <49D3F31F.8010705@novell.com>
References: <20090331184057.28333.77287.stgit@dev.haskins.net> <87ab71monw.fsf@basil.nowhere.org> <49D35825.3050001@novell.com> <20090401132340.GT11935@one.firstfloor.org> <49D37805.1060301@novell.com> <20090401170103.GU11935@one.firstfloor.org> <49D3CEC5.20606@novell.com> <20090401222352.GY11935@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig32B6C464D23A120C2C4B026E"
Cc: linux-kernel@vger.kernel.org, agraf@suse.de, pmullaney@novell.com,
	pmorreale@novell.com, anthony@codemonkey.ws, rusty@rustcorp.com.au,
	netdev@vger.kernel.org, kvm@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from victor.provo.novell.com ([137.65.250.26]:59212 "EHLO
	victor.provo.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757304AbZDAXCw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2009 19:02:52 -0400
In-Reply-To: <20090401222352.GY11935@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig32B6C464D23A120C2C4B026E
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Andi Kleen wrote:
> On Wed, Apr 01, 2009 at 04:29:57PM -0400, Gregory Haskins wrote:
>  =20
>>> description?
>>>  =20
>>>      =20
>> Yes, good point.  I will be sure to be more explicit in the next rev.
>>
>>    =20
>>>  =20
>>>      =20
>>>> So the administrator can then set these attributes as
>>>> desired to manipulate the configuration of the instance of the devic=
e,
>>>> on a per device basis.
>>>>    =20
>>>>        =20
>>> How would the guest learn of any changes in there?
>>>  =20
>>>      =20
>> The only events explicitly supported by the infrastructure of this
>> nature would be device-add and device-remove.  So when an admin adds o=
r
>> removes a device to a bus, the guest would see driver::probe() and
>> driver::remove() callbacks, respectively.  All other events are left (=
by
>> design) to be handled by the device ABI itself, presumably over the
>> provided shm infrastructure.
>>    =20
>
> Ok so you rely on a transaction model where everything is set up
> before it is somehow comitted to the guest? I hope that is made
> explicit in the interface somehow.
>  =20
Well, its not an explicit transaction model, but I guess you could think
of it that way.

Generally you set the device up before you launch the guest.  By the
time the guest loads and tries to scan the bus for the initial
discovery, all the devices would be ready to go.

This does bring up the question of hotswap.  Today we fully support
hotswap in and out, but leaving this "enabled" transaction to the
individual device means that the device-id would be visible in the bus
namespace before the device may want to actually communicate.  Hmmm

Perhaps I need to build this in as a more explicit "enabled"
feature...and the guest will not see the driver::probe() until this happe=
ns.

>  =20
>> This script creates two buses ("client-bus" and "server-bus"),
>> instantiates a single venet-tap on each of them, and then "wires" them=

>> together with a private bridge instance called "vbus-br0".  To complet=
e
>> the picture here, you would want to launch two kvms, one of each of th=
e
>> client-bus/server-bus instances.  You can do this via /proc/$pid/vbus.=
  E.g.
>>
>> # (echo client-bus > /proc/self/vbus; qemu-kvm -hda client.img....)
>> # (echo server-bus > /proc/self/vbus; qemu-kvm -hda server.img....)
>>
>> (And as noted, someday qemu will be able to do all the setup that the
>> script did, natively.  It would wire whatever tap it created to an
>> existing bridge with qemu-ifup, just like we do for tun-taps today)
>>    =20
>
> The usual problem with that is permissions. Just making qemu-ifup suid
> it not very nice.  It would be good if any new design addressed this.
>  =20

Well, its kind of out of my control.  venet-tap ultimately creates a
simple netif interface which we must do something with.  Once its
created, "wiring" it up to something like a linux-bridge is no different
than something like a tun-tap, so the qemu-ifup requirement doesn't chang=
e.

The one thing I can think of is it would be possible to build a
"venet-switch" module, and this could be done without using brctl or
qemu-ifup...but then I would lose all the benefits of re-using that
infrastructure.  I do not recommend we actually do this, but it would
technically be a way to address your concern.


>  =20
>> the current code doesnt support rw on the mac attributes yet..i need a=

>> parser first).
>>    =20
>
> parser in kernel space always sounds scary to me.
>  =20
Heh..why do you think I keep procrastinating ;)

>
>  =20
>> Yeah, ultimately I would love to be able to support a fairly wide rang=
e
>> of the normal userspace/kernel ABI through this mechanism.  In fact, o=
ne
>> of my original design goals was to somehow expose the syscall ABI
>> directly via some kind of syscall proxy device on the bus.  I have sin=
ce
>>    =20
>
> That sounds really scary for security.=20
>
>
>  =20
>> backed away from that idea once I started thinking about things some
>> more and realized that a significant number of system calls are really=

>> inappropriate for a guest type environment due to their ability to
>> block.   We really dont want a vcpu to block.....however, the AIO type=

>>    =20
>
> Not only because of blocking, but also because of security issues.
> After all one of the usual reasons to run a guest is security isolation=
=2E
>  =20
Oh yeah, totally agreed.  Not that I am advocating this, because I have
abandoned the idea.  But back when I was thinking of this, I would have
addressed the security with the vbus and syscall-proxy-device objects
themselves.  E.g. if you dont instantiate a syscall-proxy-device on the
bus, the guest wouldnt have access to syscalls at all.   And you could
put filters into the module to limit what syscalls were allowed, which
UID to make the guest appear as, etc.

> In general the more powerful the guest API the more risky it is, so som=
e
> self moderation is probably a good thing.
>  =20
:)

-Greg


--------------enig32B6C464D23A120C2C4B026E
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.9 (GNU/Linux)
Comment: Using GnuPG with SUSE - http://enigmail.mozdev.org

iEYEARECAAYFAknT8x8ACgkQlOSOBdgZUxla+wCeOmiZgJaxTRDmAsK237O/4C/k
Xf4AmwQP8jTNo/afgFRdBsZ47784XIpd
=HYZv
-----END PGP SIGNATURE-----

--------------enig32B6C464D23A120C2C4B026E--
