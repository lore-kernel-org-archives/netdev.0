From: Sebastian Reichel <sre@kernel.org>
Subject: Re: wl1251 & mac address & calibration data
Date: Thu, 24 Nov 2016 19:11:39 +0100
Message-ID: <20161124181138.4i6ehkpohjxfgpbn@earth>
References: <201611111820.52072@pali>
 <20161124152045.GK13735@pali>
 <20161124160830.kdpbonsz3l26uuo5@earth>
 <201611241749.33681@pali>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
        protocol="application/pgp-signature"; boundary="ectbp4bp3wodyn6s"
Cc: Pavel Machek <pavel@ucw.cz>,
        Michal Kazior <michal.kazior@tieto.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        Ivaylo Dimitrov <ivo.g.dimitrov.75@gmail.com>,
        Aaro Koskinen <aaro.koskinen@iki.fi>,
        Tony Lindgren <tony@atomide.com>,
        linux-wireless <linux-wireless@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        linux-kernel@vger.kernel.org
To: Pali =?iso-8859-1?Q?Roh=E1r?= <pali.rohar@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201611241749.33681@pali>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--ectbp4bp3wodyn6s
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

On Thu, Nov 24, 2016 at 05:49:33PM +0100, Pali Roh=C3=A1r wrote:
> On Thursday 24 November 2016 17:08:30 Sebastian Reichel wrote:
> > On Thu, Nov 24, 2016 at 04:20:45PM +0100, Pali Roh=C3=A1r wrote:
> > > On Thursday 24 November 2016 16:13:17 Sebastian Reichel wrote:
> > > > On Thu, Nov 24, 2016 at 09:33:29AM +0100, Pali Roh=C3=A1r wrote:
> > > > > On Thursday 24 November 2016 08:51:04 Pavel Machek wrote:
> > > > > > > > "ifconfig hw ether XX" normally sets the address. I guess
> > > > > > > > that's ioctl?
> > > > > > >=20
> > > > > > > This sets temporary address and it is ioctl. IIRC same as
> > > > > > > what ethtool uses. (ifconfig is already deprecated).
> > > > > > >=20
> > > > > > > > And I guess we should use similar mechanism for permanent
> > > > > > > > address.
> > > > > > >=20
> > > > > > > I'm not sure here... Above ioctl =E2=86=91=E2=86=91=E2=86=91 =
is for changing
> > > > > > > temporary mac address. But here we do not want to change
> > > > > > > permanent mac address. We want to tell kernel driver
> > > > > > > current permanent mac address which is stored
> > > > > >=20
> > > > > > Well... I'd still use similar mechanism :-).
> > > > >=20
> > > > > Thats problematic, because in time when wlan0 interface is
> > > > > registered into system and visible in ifconfig output it
> > > > > already needs to have permanent mac address assigned.
> > > > >=20
> > > > > We should assign permanent mac address before wlan0 of wl1251
> > > > > is registered into system.
> > > >=20
> > > > You can just add the MAC address to the NVS data, which is also
> > > > required for the device initialization.
> > >=20
> > > NVS data file has fixed size, there is IIRC no place for it.
> > >=20
> > > But one of my suggestion was to use another request_firmware for
> > > MAC address. So this is similar to what you are proposing, as NVS
> > > data are loaded by request_firmware too...
> >=20
> > Just append it to NVS data and modify the size check accordingly?
>=20
> First that would mean to have request_firmware() function which will not=
=20
> use direct VFS access, but instead use userspace helper.

Permanent MAC is device specific init data, NVS is device specific
init data =3D> load together.

The userspace helper stuff is only needed to get the data from
the NAND calibration area on the fly.

> NVS data file with some default values (not suitable for usage) is=20
> already present in linux-firmware and available in /lib/firmware/...

You mentioned NVS data is fixed size, so this should be enough?

switch(loaded_size)
    case IMAGE_SIZE + MAC_SIZE:
        /* extract mac */
        /* fallthrough */
    case IMAGE_SIZE:
        /* load NVS */
        break;
    default:
        /* fail */
}

> Also I'm not sure if such thing is allowed by license:
> https://git.kernel.org/cgit/linux/kernel/git/firmware/linux-firmware.git/=
tree/LICENCE.ti-connectivity

concating data is not a modification, otherwise you can't
put the file in a filesystem.

> > > > I wonder if those information could be put into DT. Iirc some
> > > > network devices get their MAC address from DT. Maybe we can add
> > > > all NVS info to DT? How much data is it?
> > >=20
> > > Proprietary, signed and closed bootloader NOLO does not support DT.
> > > So for booting you need to append DTS file to kernel image.
> >=20
> > Yeah, so NOLO without U-Boot will depend on userspace to fixup DT.
> >=20
> > > U-Boot is optional and can be used as intermediate bootloader
> > > between NOLO and kernel. But still it has problems with reading
> > > from nand, so cannot read NVS data nor MAC address.
> >=20
> > It may in the future?
>=20
> I already tried that, but I failed. I was not able to access N900's nand=
=20
> from u-boot. No idea where was problem...
>
> And if somebody fix onenand in u-boot, then needs to reimplement Nokia's=
=20
> proprietary parser of that partition where is stored NVS and mac address=
=20
> && make this support in upstream u-boot.

Are we talking about this?

https://github.com/community-ssu/libcal/blob/master/cal.c

That's ~1k loc for read-only. Getting NAND working looks harder than
porting this to me.

> So... I doubt it will be in any future.
>=20
> + no men power

yeah :(

But with that reasoning you should just extract the NVS data
=66rom NAND and put it in your rootfs.

> > > > Userspace application can add all those information to the DT
> > > > using a DT overlay. Also the u-boot could parse and add it at
> > > > some point in the future.
> > >=20
> > > In case when wl1251 is statically linked into kernel image, it is
> > > loaded and initialized before even userspace applications starts.
> > >=20
> > > So no... adding NVS data or MAC address into DT or DT overlay is
> > > not a solution.
> >=20
> > Actually with data loaded from DT you *can* load data quite early in
> > the boot process, while your suggestions always require userspace.
> > So you argument against yourself?
>=20
> You cannot add DTS in uboot (no support).

AFAIK that's supported:

http://www.denx.de/wiki/DULG/LinuxFDTBlob

"Note that U-Boot makes some automatic modifications to the blob
before passing it to the kernel - mainly adding and modifying
information that is learnt at run-time."

> And if you modify DTS on running kernel from userspace, then it is
> too late when wl1251 is statically linked into kernel image.
>=20
> wl1251 will not wait until some userspace modify DTS and add data...

if (nvs info missing)
    return -EPROBE_DEFER;

> But request_firmware() in fallback mode *can* wait for userspace so=20
> wl1251 can postpone its operation until mdev/udev/whatever starts=20
> listening for events and push needed firmware data to kernel.

As you said one workaround is waiting. That's not a solution, that
only works with request_firmware().

> So no, there is no argument against... request_firmware() in fallback=20
> mode with userspace helper is by design blocking and waiting for=20
> userspace. But waiting for some change in DTS in kernel is just=20
> nonsense.

I would just mark the wlan device with status =3D "disabled" and
enable it in the overlay together with adding the NVS & MAC info.

-- Sebastian

--ectbp4bp3wodyn6s
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCgAdFiEE72YNB0Y/i3JqeVQT2O7X88g7+poFAlg3LVYACgkQ2O7X88g7
+pqbiA/8Czithcg0DaKkbAfDLz1ctqkFU3AfS7/etyIwHcOMjL4vAhnqiidguSM0
0cNIfb7GmFj+JIHPpKgb/HFUXg3vEPTgGcKbMr8VlHliIO34tOVIhmp2omnY+1aq
xVtyOHxT4fhGXaKCrg3k3zHmZmhYJ0SCQkIUM8ARcTOF7/ypjOpgy3cudIKCyeKx
fqBYsK8mZWiK5lx4IhaHT/hUffU7G8qYaetpl6ZhwFlgZA4jmJhI0/KWzmHIvUyJ
gGE2Mx8a/sq5KDGuPmB8NesszHO0NalJJxYLk+XTsVtZg94nssp1JZ0jyc79Zz89
swqQr3819meKnUcErr9n5Ox/yOas4illFQkPLA5sCU7tW4v9kugQinYupXNx8Pg9
ofZj3Yw7re5g4dUJ8rBfvBALYsghEv9TPNDaAcqT+jVU3UkhUBMEUQMapE1X2wzX
Bzqd3qMyKU0s1FJnGEv9S7bWNe0yxETY7paCX9nB1gFZv8fa9dIzu4MPhJZJqSYl
6Io5t7KZ1SWizKvXd0PEcKQqIA0vume0lozzaakDAaP6YfO092TybKH/Ek7miLyH
GsznXB5XIOyNC4IUTQ5gytSxAeEEsHfIyf85mDVEzUYzayOXg/NRiLJRXExl0mHf
c7PpCK9ct3QsqOAOyBaMOg+5k6pYPtOcnpUEfNruJ+RhSWCzHv4=
=wvHN
-----END PGP SIGNATURE-----

--ectbp4bp3wodyn6s--
