From: Gregory Haskins <ghaskins@novell.com>
Subject: Re: [RFC PATCH 00/17] virtual-bus
Date: Wed, 01 Apr 2009 16:29:57 -0400
Message-ID: <49D3CEC5.20606@novell.com>
References: <20090331184057.28333.77287.stgit@dev.haskins.net> <87ab71monw.fsf@basil.nowhere.org> <49D35825.3050001@novell.com> <20090401132340.GT11935@one.firstfloor.org> <49D37805.1060301@novell.com> <20090401170103.GU11935@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig1B3BAE7566CC48A462F2FE08"
Cc: linux-kernel@vger.kernel.org, agraf@suse.de, pmullaney@novell.com,
	pmorreale@novell.com, anthony@codemonkey.ws, rusty@rustcorp.com.au,
	netdev@vger.kernel.org, kvm@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20090401170103.GU11935@one.firstfloor.org>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig1B3BAE7566CC48A462F2FE08
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Andi Kleen wrote:
> On Wed, Apr 01, 2009 at 10:19:49AM -0400, Gregory Haskins wrote:
>  =20
>>>>    =20
>>>>        =20
>>> But surely you must have some specific use case in mind? Something
>>> that it does better than the various methods that are available
>>> today. Or rather there must be some problem you're trying
>>> to solve. I'm just not sure what that problem exactly is.
>>>  =20
>>>      =20
>> Performance.  We are trying to create a high performance IO infrastruc=
ture.
>>    =20
>
> Ok. So the goal is to bypass user space qemu completely for better
> performance. Can you please put this into the initial patch
> description?
>  =20
Yes, good point.  I will be sure to be more explicit in the next rev.

>  =20
>> So the administrator can then set these attributes as
>> desired to manipulate the configuration of the instance of the device,=

>> on a per device basis.
>>    =20
>
> How would the guest learn of any changes in there?
>  =20
The only events explicitly supported by the infrastructure of this
nature would be device-add and device-remove.  So when an admin adds or
removes a device to a bus, the guest would see driver::probe() and
driver::remove() callbacks, respectively.  All other events are left (by
design) to be handled by the device ABI itself, presumably over the
provided shm infrastructure.

So for instance, I have on my todo list to add a third shm-ring for
events in the venet ABI.   One of the event-types I would like to
support is LINK_UP and LINK_DOWN.  These events would be coupled to the
administrative manipulation of the "enabled" attribute in sysfs.  Other
event-types could be added as needed/appropriate.

I decided to do it this way because I felt it didn't make sense for me
to expose the attributes directly, since they are often back-end
specific anyway.   Therefore I leave it to the device-specific ABI which
has all the necessary tools for async events built in.


> I think the interesting part would be how e.g. a vnet device
> would be connected to the outside interfaces.
>  =20

Ah, good question.  This ties into the statement I made earlier about
how presumably the administrative agent would know what a module is and
how it works.  As part of this, they would also handle any kind of
additional work, such as wiring the backend up.  Here is a script that I
use for testing that demonstrates this:

------------------
#!/bin/bash

set -e

modprobe venet-tap
mount -t configfs configfs /config

bridge=3Dvbus-br0

brctl addbr $bridge
brctl setfd $bridge 0
ifconfig $bridge up

createtap()
{
    mkdir /config/vbus/devices/$1-dev
    echo venet-tap > /config/vbus/devices/$1-dev/type
    mkdir /config/vbus/instances/$1-bus
    ln -s /config/vbus/devices/$1-dev /config/vbus/instances/$1-bus
    echo 1 > /sys/vbus/devices/$1-dev/enabled

    ifname=3D$(cat /sys/vbus/devices/$1-dev/ifname)
    ifconfig $ifname up
    brctl addif $bridge $ifname
}

createtap client
createtap server

--------------------

This script creates two buses ("client-bus" and "server-bus"),
instantiates a single venet-tap on each of them, and then "wires" them
together with a private bridge instance called "vbus-br0".  To complete
the picture here, you would want to launch two kvms, one of each of the
client-bus/server-bus instances.  You can do this via /proc/$pid/vbus.  E=
=2Eg.

# (echo client-bus > /proc/self/vbus; qemu-kvm -hda client.img....)
# (echo server-bus > /proc/self/vbus; qemu-kvm -hda server.img....)

(And as noted, someday qemu will be able to do all the setup that the
script did, natively.  It would wire whatever tap it created to an
existing bridge with qemu-ifup, just like we do for tun-taps today)

One of the key details is where I do "ifname=3D$(cat
/sys/vbus/devices/$1-dev/ifname)".  The "ifname" attribute of the
venet-tap is a read-only attribute that reports back the netif interface
name that was returned when the device did a register_netdev() (e.g.
"eth3").  This register_netdev() operation occurs as a result of echoing
the "1" into the "enabled" attribute.  Deferring the registration until
the admin explicitly does an "enable" gives the admin a chance to change
the MAC address of the virtual-adapter before it is registered (note:
the current code doesnt support rw on the mac attributes yet..i need a
parser first).


>  =20
>> So the admin would instantiate this "vdisk" device and do:
>>
>> 'echo /path/to/my/exported/disk.dat > /sys/vbus/devices/foo/src_path'
>>    =20
>
> So it would act like a loop device? Would you reuse the loop device
> or write something new?
>  =20

Well, keeping in mind that I haven't even looked at writing a block
device for this infrastructure yet....my blanket statement would be
"lets reuse as much as possible" ;)  If the existing loop infrastructure
would work here, great!

> How about VFS mount name spaces?
>  =20

Yeah, ultimately I would love to be able to support a fairly wide range
of the normal userspace/kernel ABI through this mechanism.  In fact, one
of my original design goals was to somehow expose the syscall ABI
directly via some kind of syscall proxy device on the bus.  I have since
backed away from that idea once I started thinking about things some
more and realized that a significant number of system calls are really
inappropriate for a guest type environment due to their ability to
block.   We really dont want a vcpu to block.....however, the AIO type
system calls on the other hand, have much more promise.  ;)  TBD.

For right now I am focused more on the explicit virtual-device type
transport (disk, net, etc).  But in theory we should be able to express
a fairly broad range of services in terms of the call()/shm() interfaces.=


-Greg



--------------enig1B3BAE7566CC48A462F2FE08
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.9 (GNU/Linux)
Comment: Using GnuPG with SUSE - http://enigmail.mozdev.org

iEYEARECAAYFAknTzsUACgkQlOSOBdgZUxmjzQCgjlMwTntgSxD4auwc00yBic7u
4yMAoIRFoV75+8z386yF0MbqQ5rZxsqs
=QGYz
-----END PGP SIGNATURE-----

--------------enig1B3BAE7566CC48A462F2FE08--
