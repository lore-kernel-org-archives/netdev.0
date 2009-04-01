From: Gregory Haskins <ghaskins@novell.com>
Subject: Re: [RFC PATCH 00/17] virtual-bus
Date: Wed, 01 Apr 2009 10:19:49 -0400
Message-ID: <49D37805.1060301@novell.com>
References: <20090331184057.28333.77287.stgit@dev.haskins.net> <87ab71monw.fsf@basil.nowhere.org> <49D35825.3050001@novell.com> <20090401132340.GT11935@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigE518EBCDD1692D247FEAB4DD"
Cc: linux-kernel@vger.kernel.org, agraf@suse.de, pmullaney@novell.com,
	pmorreale@novell.com, anthony@codemonkey.ws, rusty@rustcorp.com.au,
	netdev@vger.kernel.org, kvm@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from victor.provo.novell.com ([137.65.250.26]:56981 "EHLO
	victor.provo.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932996AbZDAORg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2009 10:17:36 -0400
In-Reply-To: <20090401132340.GT11935@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigE518EBCDD1692D247FEAB4DD
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Andi Kleen wrote:
> On Wed, Apr 01, 2009 at 08:03:49AM -0400, Gregory Haskins wrote:
>  =20
>> Andi Kleen wrote:
>>    =20
>>> Gregory Haskins <ghaskins@novell.com> writes:
>>>
>>> What might be useful is if you could expand a bit more on what the hi=
gh level
>>> use cases for this.=20
>>>
>>> Questions that come to mind and that would be good to answer:
>>>
>>> This seems to be aimed at having multiple VMs talk
>>> to each other, but not talk to the rest of the world, correct?=20
>>> Is that a common use case?=20
>>>  =20
>>>      =20
>> Actually we didn't design specifically for either type of environment.=
=20
>>    =20
>
> But surely you must have some specific use case in mind? Something
> that it does better than the various methods that are available
> today. Or rather there must be some problem you're trying
> to solve. I'm just not sure what that problem exactly is.
>  =20
Performance.  We are trying to create a high performance IO infrastructur=
e.

Ideally we would like to see things like virtual-machines have
bare-metal performance (or as close as possible) using just pure
software on commodity hardware.   The data I provided shows that
something like KVM with virtio-net does a good job on throughput even on
10GE, but the latency is several orders of magnitude slower than
bare-metal.   We are addressing this issue and others like it that are a
result of the current design of out-of-kernel emulation.
>  =20
>> What we *are* trying to address is making an easy way to declare virtu=
al
>> resources directly in the kernel so that they can be accessed more
>> efficiently.  Contrast that to the way its done today, where the model=
s
>> live in, say, qemu userspace.
>>
>> So instead of having
>> guest->host->qemu::virtio-net->tap->[iptables|bridge], you simply have=

>> guest->host->[iptables|bridge].  How you make your private network (if=

>>    =20
>
> So is the goal more performance or simplicity or what?
>  =20

(Answered above)

>  =20
>>> What would be the use cases for non networking devices?
>>>
>>> How would the interfaces to the user look like?
>>>  =20
>>>      =20
>> I am not sure if you are asking about the guests perspective or the
>> host-administators perspective.
>>    =20
>
> I was wondering about the host-administrators perspective.
>  =20
Ah, ok.  Sorry about that.  It was probably good to document that other
thing anyway, so no harm.

So about the host-administrator interface.  The whole thing is driven by
configfs, and the basics are already covered in the documentation in
patch 2, so I wont repeat it here.  Here is a reference to the file for
everyone's convenience:

http://git.kernel.org/?p=3Dlinux/kernel/git/ghaskins/vbus/linux-2.6.git;a=
=3Dblob;f=3DDocumentation/vbus.txt;h=3De8a05dafaca2899d37bd4314fb0c7529c1=
67ee0f;hb=3Df43949f7c340bf667e68af6e6a29552e62f59033

So a sufficiently privileged user can instantiate a new bus (e.g.
container) and devices on that bus via configfs operations.  The types
of devices available to instantiate are dictated by whatever vbus-device
modules you have loaded into your particular kernel.  The loaded modules
available are enumerated under /sys/vbus/deviceclass.

Now presumably the administrator knows what a particular module is and
how to configure it before instantiating it.  Once they instantiate it,
it will present an interface in sysfs with a set of attributes.  For
example, an instantiated venet-tap looks like this:

ghaskins@test:~> tree /sys/vbus/devices
/sys/vbus/devices
`-- foo
    |-- class -> ../../deviceclass/venet-tap
    |-- client_mac
    |-- enabled
    |-- host_mac
    |-- ifname
    `-- interfaces
        `-- 0 -> ../../../instances/bar/devices/0


Some of these attributes, like "class" and "interfaces" are default
attributes that are filled in by the infrastructure.  Other attributes,
like "client_mac" and "enabled" are properties defined by the venet-tap
module itself.  So the administrator can then set these attributes as
desired to manipulate the configuration of the instance of the device,
on a per device basis.

So now imagine we have some kind of disk-io vbus device that is designed
to act kind of like a file-loopback device.  It might define an
attribute allowing you to specify the path to the file/block-dev that
you want it to export.

(Warning: completely fictitious "tree" output to follow ;)

ghaskins@test:~> tree /sys/vbus/devices
/sys/vbus/devices
`-- foo
    |-- class -> ../../deviceclass/vdisk
    |-- src_path
    `-- interfaces
        `-- 0 -> ../../../instances/bar/devices/0

So the admin would instantiate this "vdisk" device and do:

'echo /path/to/my/exported/disk.dat > /sys/vbus/devices/foo/src_path'

To point the device to the file on the host that it wants to present as
a vdisk.  Any guest that has access to the particular bus that contains
this device would then see it as a standard "vdisk" ABI device (as if
there where such a thing, yet) and could talk to it using a vdisk
specific driver.

A property of a vbus is that it is inherited by children.  Today, I do
not have direct support in qemu for creating/configuring vbus devices.=20
Instead what I do is I set up the vbus and devices from bash, and then
launch qemu-kvm so it inherits the bus.  Someday (soon, unless you guys
start telling me this whole idea is rubbish ;) I will add support so you
could do things like "-net nic,model=3Dvenet" and that would trigger qemu=

to go out and create the container/device on its own.  TBD.

I hope this helps to clarify!
-Greg


--------------enigE518EBCDD1692D247FEAB4DD
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.9 (GNU/Linux)
Comment: Using GnuPG with SUSE - http://enigmail.mozdev.org

iEYEARECAAYFAknTeAUACgkQlOSOBdgZUxkFQQCggsCcrNcX/aQGhxbf4NAOWX+H
WYEAnRzznBjdbwIOiWyeNWDoMgHETqer
=+Rd0
-----END PGP SIGNATURE-----

--------------enigE518EBCDD1692D247FEAB4DD--
