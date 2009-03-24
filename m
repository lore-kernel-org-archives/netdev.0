From: Scott James Remnant <scott@ubuntu.com>
Subject: Re: Network Device Naming mechanism and policy
Date: Tue, 24 Mar 2009 17:02:19 +0000
Message-ID: <1237914139.22009.18.camel@quest>
References: <20090324154617.GA16332@auslistsprd01.us.dell.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-0XiESFhSqq8PLyGJHAgy"
Cc: netdev@vger.kernel.org, linux-hotplug@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Matt Domsch <Matt_Domsch@dell.com>
Return-path: <linux-hotplug-owner@vger.kernel.org>
In-Reply-To: <20090324154617.GA16332@auslistsprd01.us.dell.com>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-0XiESFhSqq8PLyGJHAgy
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2009-03-24 at 10:46 -0500, Matt Domsch wrote:

>    b) udev may run modprobes in parallel.  It guarantees that the
>       events and modprobes are begun in order, but makes no guarantee
>       that one event's modprobe completes before beginning a second
>       modprobe.  This leads to naming races in the kernel, as drivers
>       begun in parallel, which discover their own devices, present
>       them to the kernel for name assignment.
>=20
Also bear in mind that a module completing init() does not necessarily
mean that the interfaces have been created.  If the driver requires
firmware, it will call out to userspace, and may not register the
interface until well afterwards.

One could even construct a pathological case where only a virtual device
was registered, and userspace was required to add logical interfaces
(most likely in a udev rule).

> 2) udev may have rules to change the device names.  This is most often
>    seen in the '70-persistent-net.rules' file.  Here we have
>    additional challenges:
>=20
>    a) this does not exist the first time devices are discovered; the
>       naming may be incorrect during first discovery, leading to the
>       names being permanently incorrect (unless this file is edited).
>=20
Well, the obvious fix to this is to make sure the names are always
correct :)

>    c) udev may not always be able to change a device's name.  If udev
>       uses the kernel assignment namespace (ethN), then a rename of
>       eth0->eth1 may require renaming eth1->eth0 (or something else).
>       Udev operates on a single device instance at a time, it becomes
>       difficult to switch names around for multiple devices, within
>       the single namespace.
>=20
Actually udev handles this by using a temporary name.  When renaming
eth0->eth1 it actually uses an intermediate name first.  This allows it
to simultaneously swap eth0<->eth1 since one unblocks the other
(actually both unblock each other).

There is a failure case where two devices both end up trying to get the
same name, in which case one will lock with a "_rename" name.  There was
an early debate in Ubuntu when we first wrote this code about using
later names (eth2, eth3, etc.) but we realised that just hides the
problem (and it happens again if you plug in a pccard or something that
wants eth2).

Since this is always a bug, making the problem visible was a "good
thing".

> biosdevname (http://linux.dell.com/projects.shtml#biosdevname) takes a
> stab at this.  It can be integrated into udev, such that the
> 70-persistent-net.rules file is never used, and the naming for each
> device comes from several different policies.  Its primary drawback is
> that it changes the device namespace, which some sysadmins, and tools,
> may not like.  Names for devices become eth_s0_0 for the first
> onboard NIC, eth_s0_1 for the second; eth_s3_3 for the fourth port
> on PCI Slot #3, etc.
>=20
While this works for PCI slots, it already doesn't scale to other buses.
For example what slot number is the pccard slot?  If you have two
different pccard devices, would they get assigned the same name (udev
currently assigns them different names).

Now consider USB.  Would the device name change depending on which USB
port you plugged it into?  Or is USB just a single slot, in which case
what happens when you have two USB ethernet devices?

The Apple USB Ethernet device in my iPhone is not the USB Wireless
adapter I own, both have very different networking configurations.

it's not ideal in the laptop world.  Consider a user with two different=20

> Option 3: INSERT YOUR IDEA HERE
>=20
I quite liked the idea of /dev/eth0, then we could just use symlinks.

Scott
--=20
Scott James Remnant
scott@ubuntu.com

--=-0XiESFhSqq8PLyGJHAgy
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEABECAAYFAknJEhsACgkQSnQiFMl4yK7JiQCfXV1ZjDI3yuvJV4fpusS3hK1P
r7EAoLCDcnV4A02DD694ovmC1cxjySib
=HQPX
-----END PGP SIGNATURE-----

--=-0XiESFhSqq8PLyGJHAgy--

