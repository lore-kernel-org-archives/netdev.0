From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [patch net-next v6 4/4] igb/igbvf: implement
 ndo_get_phys_port_id
Date: Thu, 22 Aug 2013 03:39:10 -0700
Message-ID: <1377167950.3939.57.camel@jtkirshe-mobl>
References: <1375114612-537-1-git-send-email-jiri@resnulli.us>
	 <1375114612-537-5-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-1IQRKySvES9Tlxp9j7Zl"
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	stephen@networkplumber.org, Narendra_K@Dell.com,
	bhutchings@solarflare.com, or.gerlitz@gmail.com,
	carolyn.wyborny@intel.com, gregory.v.rose@intel.com,
	vyasevic@redhat.com, amwang@redhat.com, johannes@sipsolutions.net
To: Jiri Pirko <jiri@resnulli.us>, aaron.f.brown@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:63337 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752489Ab3HVKjY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Aug 2013 06:39:24 -0400
In-Reply-To: <1375114612-537-5-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-1IQRKySvES9Tlxp9j7Zl
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2013-07-29 at 18:16 +0200, Jiri Pirko wrote:
> igb driver generated random number which will identify physical port.
> This id is available via ndo_get_phys_port_id directly on igb netdev.
> Also, id is passed to igbvf using mailbox. After that, it is available
> via
> ndo_get_phys_port_id on igbvf netdev as well.
>=20
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> ---
>  drivers/net/ethernet/intel/igb/e1000_mbx.h |  1 +
>  drivers/net/ethernet/intel/igb/igb.h       |  3 +++
>  drivers/net/ethernet/intel/igb/igb_main.c  | 37
> ++++++++++++++++++++++++++++-
>  drivers/net/ethernet/intel/igbvf/igbvf.h   |  4 ++++
>  drivers/net/ethernet/intel/igbvf/mbx.h     |  1 +
>  drivers/net/ethernet/intel/igbvf/netdev.c  | 38
> ++++++++++++++++++++++++++++++
>  drivers/net/ethernet/intel/igbvf/vf.c      | 34
> ++++++++++++++++++++++++++
>  drivers/net/ethernet/intel/igbvf/vf.h      |  1 +
>  8 files changed, 118 insertions(+), 1 deletion(-)

Jiri-

Validation ran into a couple of issues with this patch.  Here is what
Aaron found when testing this patch...

Aaron Brown wrote:
I think I have to fail this, it seems to have an issue with
initialization.  When I first create a vf via sysfs the pys_port_id file
is created along with the other sysfs files for the vf, however an
attempt to cat out the value returns " Operation not supported".  At
this point the vf is still down, if I bring it up (or simply unload /
reload the igbvf driver) I can then cat the file successfully and the vf
interface phys_port_id matches the phys_port_id of the pf.  This is
testing from bare metal, a console session showing this behavior
follows:

u1304:[0]/sys> find . -iname phys_port_id
./devices/pci0000:00/0000:00:01.0/0000:07:00.0/net/eth0/phys_port_id
./devices/pci0000:00/0000:00:01.0/0000:07:00.1/net/eth1/phys_port_id
./devices/virtual/net/sit0/phys_port_id
./devices/virtual/net/lo/phys_port_id
u1304:[0]/sys> cat devices/pci0000:00/0000:00:01.0/0000:07:00.0/net/eth0/ph=
ys_port_id
5ece9fbd9cd51546982e15c1f2c11e25
u1304:[0]/sys>

So far so good, now make a few vfs and check for new phys_port_id sysfs fil=
es.

u1304:[0]/sys> find . -iname sriov_numvfs
./devices/pci0000:00/0000:00:01.0/0000:07:00.0/sriov_numvfs
./devices/pci0000:00/0000:00:01.0/0000:07:00.1/sriov_numvfs
u1304:[0]/sys> echo 2 > devices/pci0000:00/0000:00:01.0/0000:07:00.0/sriov_=
numvfs
u1304:[0]/sys> find . -iname phys_port_id                                  =
     ./devices/pci0000:00/0000:00:01.0/0000:07:00.0/net/eth0/phys_port_id
./devices/pci0000:00/0000:00:01.0/0000:07:00.1/net/eth1/phys_port_id
./devices/pci0000:00/0000:00:01.0/0000:07:10.0/net/eth2/phys_port_id
./devices/pci0000:00/0000:00:01.0/0000:07:10.2/net/eth3/phys_port_id
./devices/virtual/net/sit0/phys_port_id
./devices/virtual/net/lo/phys_port_id
u1304:[0]/sys>

The first vf is eth2, attempt to cat out it's phys_port_id

u1304:[0]/sys> cat ./devices/pci0000:00/0000:00:01.0/0000:07:10.0/net/eth2/=
phys_port_id
cat: ./devices/pci0000:00/0000:00:01.0/0000:07:10.0/net/eth2/phys_port_id: =
Operation not supported
u1304:[0]/sys>

But, if I bring the interface up (or unload / load the igbvf driver) I then=
 am able to cat the phys_port_id of the vf and it matches the phys_port_id =
of the physical interface.

u1304:[0]/sys> ifconfig eth2 u1304-2
u1304:[0]/sys> cat ./devices/pci0000:00/0000:00:01.0/0000:07:10.0/net/eth2/=
phys_port_id
5ece9fbd9cd51546982e15c1f2c11e25
u1304:[0]/sys>

--=-1IQRKySvES9Tlxp9j7Zl
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.14 (GNU/Linux)

iQIcBAABCgAGBQJSFepOAAoJEOVv75VaS+3OWaIP/i5nTJqu2KGGmusOjWGPh9mD
p3EUMeNvITANH8Tqlz52hZ8wacvR5U17n2W2D2qITHxjYtOPjbaMCaCLwA2rfIjA
wOzml9c0pcQDSzarDR0NwELlehFOLvMkE0u0ZjeSXjZ7LndbNB0sevw1qYqif5GD
j7Pgr/DKL6YfdP1jV7jcbissR/2GsdLxOohND/7jLajgOihEllfWGoJNT++V+q5K
RBFIly7+Y/+cjH9HbqUh5A03MGUdJxFTIDnPQKzi29ugoyF8lpIRFzIcFHRGcOTO
d+uANwItyvH8DawybfugwhaaPsW9bSrE3SapW4L2GxeNtNwmNZvvXn/A0DwB18k4
SyZsIUAU7Eie7uGsI/DkTLf29iUNGzx7q4BIS6DcgVYg8TmJhn88Nf57W/87BOoc
t6YNnelff5NGAY+xpNidZdmNkute/rhVOeTbr3dGjCrFXNbsErFwQw8TfHHne8Dr
8Z9tNWxRn3LILxhotdt4RwXAuD5ruQhfvdWk8p0EPvdHJoiX2usRIPGnFFzma2Md
jETOvOulRokRp9MCvfcOTswhCM5DVTejKE+LxIzl6PqLA4JnnM6IEFJUOEZ9Zq++
WtFRAZJk+b0/Xr6uJDhoj/Lar2fjRdVej6LSufSdxCGWSYSdKWr9xDbUxSxI8T5n
pukAIb09jfpRMSAf7jd3
=1qrB
-----END PGP SIGNATURE-----

--=-1IQRKySvES9Tlxp9j7Zl--
