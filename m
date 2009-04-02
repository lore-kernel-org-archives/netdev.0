From: Gregory Haskins <ghaskins@novell.com>
Subject: Re: [RFC PATCH 02/17] vbus: add virtual-bus definitions
Date: Thu, 02 Apr 2009 14:13:06 -0400
Message-ID: <49D50032.30907@novell.com>
References: <20090331184057.28333.77287.stgit@dev.haskins.net>	 <20090331184257.28333.64028.stgit@dev.haskins.net> <1238688376.3202.10.camel@achroite>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig2FE8B9968696887F6C42FB35"
Cc: linux-kernel@vger.kernel.org, agraf@suse.de, pmullaney@novell.com,
	pmorreale@novell.com, anthony@codemonkey.ws, rusty@rustcorp.com.au,
	netdev@vger.kernel.org, kvm@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932339AbZDBSLZ@vger.kernel.org>
In-Reply-To: <1238688376.3202.10.camel@achroite>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig2FE8B9968696887F6C42FB35
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Hi Ben

Ben Hutchings wrote:
> On Tue, 2009-03-31 at 14:42 -0400, Gregory Haskins wrote:
> [...]
>  =20
>> +Create a device instance
>> +------------------------
>> +
>> +Devices are instantiated by again utilizing the /config/vbus configfs=
 area.
>> +At first you may suspect that devices are created as subordinate obje=
cts of a
>> +bus/container instance, but you would be mistaken.
>>    =20
>
> This is kind of patronising; why don't you simply lay out how things
> _do_ work?
>  =20

Ya, point taken.  I think that was written really to myself, because my
first design *had* the device as a subordinate object.  Then I realized
later that I didn't like that design :)

I will fix this.

>  =20
>>  Devices are actually
>> +root-level objects in vbus specifically to allow greater flexibility =
in the
>> +association of a device.  For instance, it may be desirable to have a=
 single
>> +device that spans multiple VMs (consider an ethernet switch, or a sha=
red disk
>> +for a cluster).  Therefore, device lifecycles are managed by creating=
/deleting
>> +objects in /config/vbus/devices.
>> +
>> +Note: Creating a device instance is actually a two step process:  We =
need to
>> +give the device instance a unique name, and we also need to give it a=
 specific
>> +device type.  It is hard to express both parameters using standard fi=
lesystem
>> +operations like mkdir, so the design decision was made to require per=
forming
>> +the operation in two steps.
>>    =20
>
> How about exposing a subdir for each device class under
> /config/vbus/devices/ and allowing device creation only within those?
> Two-stage construction is a pain for both users and implementors.
>
>  =20
I am not sure I follow.  It sounds like you are suggesting exactly what
I do today.

> [...]
>  =20
>> +At this point, we are ready to roll.  Pid 4382 has access to a virtua=
l-bus
>> +namespace with one device, id=3D0.  Its type is:
>> +
>> +# cat /sys/vbus/instances/beb4df8f-7483-4028-b3f7-767512e2a18c/device=
s/0/type
>> +virtual-ethernet
>> +
>> +"virtual-ethernet"?  Why is it not "venet-tap"?  Device-classes are a=
llowed to
>>    =20

I think I worded this awkwardly.  A device-class creates a
device-instance.  A device-instance registers one or more interfaces.=20
There are device types (of which I would classify both the device-class
and its instantiated device object as the same "type"), and there are
interface types.  The interface types may overlap across different
device types, as demonstrated below.  I will update the doc to be more
clear, here (assuming I didn't muddle it up even more ;)

>> +register their interfaces under an id that is not required to be the =
same as
>> +their deviceclass.  This supports device polymorphism.   For instance=
,
>> +consider that an interface "virtual-ethernet" may provide basic 802.x=
 packet
>> +exchange.  However, we could have various implementations of a device=
 that
>> +supports the 802.x interface, while having various implementations be=
hind
>> +them.
>>    =20
> [...]
>
> It seems to me that your "device-classes" correspond to drivers and
> "interfaces" correspond to device classes in the LDM.
I don't think that is quite right, but I might be missing your point.=20
All of these objects exist on the "backend", of which there isnt a
specific precedent with LDM to express.  Normally in LDM, you would have
some kind of physical device object in the hardware (say a SATA disk),
and an LDM "block device" that represents it in software.  So we call
the LDM model for that disk a "device" but really its like a proxy or a
software representative of the actual device itself.  And I am not
knocking this designation, as I think it makes a lot of sense.

However, what I will point out is that what we are creating here in vbus
is more akin to the SATA disk itself, not the LDM "block device"
representation of the device.   There was no really great existing way
to express this type of object, which is why I had to create a new
namespace in sysfs.

To dig down into this a little further, the device and interface are
inextricably linked in a relationship very close to this "physical
device" concept.  Therefore the "driver" portion of LDM that you
referenced w.r.t. the device-class doesnt even enter the picture here
(that would actually be up in the guest or userspace, actually.=20
Discussed below).

As an example, consider a e1000 network card.  The PCI-ID and REV for
the e1000 card and the associated ABI are like its "interface".  Whereas
if its a physical card plugged into a physical pci slot, or its an
emulated e1000 inside qemu-kvm are like its device-instance.  In theory,
I can substitute either device-instance transparently with any driver
that understands the ABI associated with the e1000 PCI-ID
interchangeably (assuming all the plumbing is there, etc).  Its the same
deal here.  Taking a little creative license here to use that example in
terms of vbus concepts, I would have a device-class type =3D
"physical-e1000-card", and another "qemu-e1000-model".  I could
instantiate either one of those and they would ultimately register an
interface of type "e1000".

So where traditional LDM starts to play here is actually on the other
side (e.g. the guest).  So the host has this vbus context with our
"e1000" interface registered on it.  When the guest loads, it would
create an LDM "device" object for the e1000, as well as a driver
instance if one was present.  From here, things would look more like
normal LDM concepts that we are used to.

HTH

-Greg



--------------enig2FE8B9968696887F6C42FB35
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.9 (GNU/Linux)
Comment: Using GnuPG with SUSE - http://enigmail.mozdev.org

iEYEARECAAYFAknVADIACgkQlOSOBdgZUxk/5QCfW0O7VCxRCz1CLwvnOqOFxuSg
fTIAoIs7Yj0zdLWifpJvNzmrW6sLOHUj
=e450
-----END PGP SIGNATURE-----

--------------enig2FE8B9968696887F6C42FB35--
