From: Doug Ledford <dledford@redhat.com>
Subject: Re: [patch net-next RFC 0/6] Introduce devlink interface and first
 drivers to use it
Date: Mon, 8 Feb 2016 14:00:14 -0500
Message-ID: <56B8E5BE.40802@redhat.com>
References: <1454496482-13961-1-git-send-email-jiri@resnulli.us>
 <56B7A69B.5040101@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="TOWaVCipmLWn2HprcX6DCQHDv1nhL22Le"
Cc: netdev@vger.kernel.org, davem@davemloft.net, idosch@mellanox.com,
	eladr@mellanox.com, yotamg@mellanox.com, ogerlitz@mellanox.com,
	yishaih@mellanox.com, sean.hefty@intel.com,
	hal.rosenstock@gmail.com, eugenia@mellanox.com,
	nikolay@cumulusnetworks.com, hadarh@mellanox.com, jhs@mojatatu.com,
	john.fastabend@gmail.com, jeffrey.t.kirsher@intel.com,
	jbenc@redhat.com
To: roopa <roopa@cumulusnetworks.com>, Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54471 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751197AbcBHTAS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Feb 2016 14:00:18 -0500
In-Reply-To: <56B7A69B.5040101@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--TOWaVCipmLWn2HprcX6DCQHDv1nhL22Le
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 02/07/2016 03:18 PM, roopa wrote:
> On 2/3/16, 2:47 AM, Jiri Pirko wrote:
>> From: Jiri Pirko <jiri@mellanox.com>
>>
>> There a is need for some userspace API that would allow to expose thin=
gs
>> that are not directly related to any device class like net_device of
>> ib_device, but rather chip-wide/switch-ASIC-wide stuff.
>>
>> Use cases:
>> 1) get/set of port type (Ethernet/InfiniBand)
>> 2) monitoring of hardware messages to and from chip
>> 3) setting up port splitters - split port into multiple ones and squas=
h again,
>>    enables usage of splitter cable
>> 4) setting up shared buffers - shared among multiple ports within one =
chip
>>
>> First patch of this set introduces a new generic Netlink based interfa=
ce,
>> called "devlink". It is similar to nl80211 model and it is heavily
>> influenced by it, including the API definition. The devlink introducti=
on patch
>> implements use cases 1) and 2). Other 2 are in development atm and wil=
l
>> be addressed by follow-ups.
>>
>> It is very convenient for drivers to use devlink, as you can see in ot=
her
>> patches in this set.
>>
>> Counterpart for devlink is userspace tool called "dl". Command line in=
terface
>> and outputs are derived from "ip" tool so it should be easy for users =
to get
>> used to it.
>>
>> It is available here:
>> https://github.com/jpirko/devlink
>=20
> Jiri, thanks for this series!. Something like this is definitely needed=
 for chip specific data. But i thought we were going to limit it to chip =
specific global attributes that cannot be set on a port.
>>
>> Example usage:
>> butter:~$ dl help
>> Usage: dl [ OPTIONS ] OBJECT { COMMAND | help }
>> where  OBJECT :=3D { dev | port | monitor }
>>        OPTIONS :=3D { -v/--verbose }
>>
>> butter:~$ dl dev show
>> 0: devlink0: bus pci dev 0000:01:00.0
>>
>> butter:~$ dl port help
>> Usage: dl port show [DEV/PORT_INDEX]
>> Usage: dl port set DEV/PORT_INDEX [ type { eth | ib | auto} ]
>=20
> I don't think we should include port specific attributes in this api. p=
orts are netdevs and they should still continue to use 'ip link set'.

That's not true.  InfiniBand ports don't have a netdev (unless you load
IPoIB, and then it's an emulated netdev, but the actual port itself has
none).  So as a general rule, you can never run ip link set on an
InfiniBand port.  You can run ip link set on the IPoIB device on that
port, but the features/bits you can set that way are specific to the
IPoIB device and not the parent IB device.

With that in mind, there has been discussions around the SRIOV settings
on InfiniBand ports.  If you have an Ethernet device, there are well
defined means of setting the parameters of the VFs via the PF.  Since an
InfiniBand device doesn't have a netdev, we are currently rolling our
own methods.  A couple solutions have been floated, neither one has been
coded up.  One was to use netlink directly on the InfiniBand PF to set
VF features, but that goes back to the problem that there is no netdev
for the IB port, so we would have to either register a fake dev or
something.  The other idea was to make IPoIB devices mandatory if you
have SRIOV IB devices, and then use the IPoIB device as the netdev to
configure and then add some new entry points for configuring IB devices
via an IPoIB netdev.  There are obvious differences, such as the VF GID
length would not come even close to being the same as the IPoIB dev's
netdev MAC length, possibly multiple P_Keys need configured on the VF
while the IPoIB dev has a single fixed P_Key per device, etc.  But the
whole making IPoIB mandatory and then using one class of PF device to
configure a different class of VF device is obviously just a really ugly
hack.

> So, why not just introduce a rtnetlink ops abstraction for switch ports=
 ?. Example:
>=20
> static struct rtnl_link_ops swport_link_ops __read_mostly =3D {
>         .kind           =3D 'swport',
>         .setup          =3D swport_setup,
>         .validate       =3D swport_validate,
> };
>=20
> IFLA_INFO_KIND =3D swport
> IFLA_INFO_DATA =3D {
>             IFLA_SWPORT_KIND =3D 'mlx'
>             IFLA_SWPORT_TYPE, /* u16 */
>             IFLA_SWPORT_DESIRED_TYPE, /* u16 */
>=20
>             ... more ...
> }
>=20
> IFLA_INFO_DATA can be redirected to the specific switch driver at the s=
witchdev ops/api layer.
>=20
> ip link set dev swp1 swport_type eth swport_desired_type <blah>
>=20
> Taking this one step further, the port splitter management can be done =
in user-space:
> And, users/switch port management infra can use 'ip link add type swpor=
t ...' to create required switch ports.
>=20
> Thanks,
> Roopa
>=20
>=20
>=20
>             =20
>=20


--=20
Doug Ledford <dledford@redhat.com>
              GPG KeyID: 0E572FDD



--TOWaVCipmLWn2HprcX6DCQHDv1nhL22Le
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBCAAGBQJWuOW+AAoJELgmozMOVy/dE98QAK4aw2Cp9AFh14IyF8i7eEMp
7lhRN7z/oOBxx5sEgQ66ZQXU/2IDov4vm9dS33x1F6+YkrRmbV0vntB54VlZELEF
aiiKHn1+6KoHDvd7XC3aQJsQ0Y2SBgJ7hy4wQFAgbZY45I+VWZIHB4eseDZLZ1w8
NmU2FBBR07QYYTfKnKLvLIK5U6YJynMrSh0sEm/8ugb2VgofVxBMotNDmwOIUeLl
6qDo7nqI/WriRRd0jtgTStN7sdBFDcxXeZ7xTSJBQu1U64N58rhtLsDJK5nlW6YS
5W3HJfs6d4/BPByhxpnxHqLndSw1fzRrnhqcYyy924VxMGugEnJ0eGrMODLlxZIm
T0YU4+saT+oL94CQSbBklsg0d0PrIgYsfNN1emAdyKSmoyvIeHndcPfXRwpvjfAU
K/9fPbpqWMZQZscD5bLnRZtHQ7xs3r2YCGE+rQKkV1UxnKiLNyAgHpzrGMuVElMu
IvRQCGLQR1YuSd6058+7F9GBxcDrFfiyOpm7N4Ed4k+PLHkFAS9iNZFPpyh/8Hb8
UIlYXtJhW+NJKMFvLX5ERLRbdmdJCC9Foav/a6ArsWk4bQzAGsNPj/L6gvUDHtH4
lfBERLf9hoqpHbV6cbKkFz1sv4UCWC8446pEKjeZJNq0xJA9QF1EW+R6KW6Gc9j/
Hu0BjKaoKA3C2GTAPjZL
=qBRj
-----END PGP SIGNATURE-----

--TOWaVCipmLWn2HprcX6DCQHDv1nhL22Le--
