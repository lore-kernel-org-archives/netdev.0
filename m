From: "Rustad, Mark D" <mark.d.rustad@intel.com>
Subject: Re: [Intel-wired-lan] [PATCH] pci: Use a bus-global mutex to
 protect VPD operations
Date: Tue, 19 May 2015 18:28:36 +0000
Message-ID: <E9012788-257F-4C44-B7F1-789B94423924@intel.com>
References: <20150519000037.56109.68356.stgit@mdrustad-wks.jf.intel.com>
 <555B78F7.60908@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
	boundary="Apple-Mail=_9B7E90BA-BE9E-476E-BAC3-4C72E79E5243";
	protocol="application/pgp-signature"; micalg=pgp-sha256
Cc: "bhelgaas@google.com" <bhelgaas@google.com>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <555B78F7.60908@redhat.com>
Content-Language: en-US
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Apple-Mail=_9B7E90BA-BE9E-476E-BAC3-4C72E79E5243
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=windows-1252

> On May 19, 2015, at 10:55 AM, Alexander Duyck =
<alexander.h.duyck@redhat.com> wrote:
>=20
> On 05/18/2015 05:00 PM, Mark D Rustad wrote:
>> Some devices have a problem with concurrent VPD access to different
>> functions of the same physical device, so move the protecting mutex
>> from the pci_vpd structure to the pci_bus structure. There are a
>> number of reports on support sites for a variety of devices from
>> various vendors getting the "vpd r/w failed" message. This is likely
>> to at least fix some of them. Thanks to Shannon Nelson for helping
>> to come up with this approach.
>>=20
>> Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
>> Acked-by: Shannon Nelson <shannon.nelson@intel.com>
>> Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>=20
> Instead of moving the mutex lock around you would be much better =
served by simply removing the duplicate VPD entries for a given device =
in a PCIe quirk.  Then you can save yourself the extra pain and effort =
of having to deal with serialized VPD accesses for a multifunction =
device.
>=20
> The logic for the quirk should be fairly simple.
>  1.  Scan for any other devices with VPD that share the same bus and =
device number.
>  2.  If bdf is equal to us keep searching.
>  3.  If bdf is less than our bdf we release our VPD area and set VPD =
pointer to NULL.

I could do that. If this issue only affected Intel devices, I would be =
more inclined to consider something like that. I am avoiding discussing =
other vendors directly, so please go and do a Google search on "vpd r/w =
failed" and see if you really want to quirk all those devices. It isn't =
just Intel and it isn't just networking.

If after doing that you still feel that this isn't the best solution, I =
can go and cook up something much bigger (I already had two much bigger =
patches that I abandoned in favor of this approach). Bear in mind that =
the quirk code is dead weight in all the kernels.

As you said in another message, VPD is not that vital. Given that, I =
would think that some possible needless synchronization that resolves =
real problems for many devices should be acceptable. If it was =
synchronizing all config space or something that would be different, but =
this is just VPD.

--
Mark Rustad, Networking Division, Intel Corporation


--Apple-Mail=_9B7E90BA-BE9E-476E-BAC3-4C72E79E5243
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="signature.asc"
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - http://gpgtools.org

iQIcBAEBCAAGBQJVW4DTAAoJEDwO/+eO4+5ukCUP/13z2L/BrCT+npVmQAyviF9C
oMASQ/BV8XYvy7pGB7XrrrlEUJW/YUIaOcpkPCgZmIzBmHf9fOggwreR8IUulPaE
+zTA+V7Q0ccBmTpIv8Ka3G7WzSnjMH7U/VSNFNhAtNcxrd2xoRljlxdReTjenHeD
dnEUrROXearADA8L6oxj6jzvWX/ktn6pww9wtwz+/F7HQ8Srow6XlujpOe18aODm
8/Cce+Zfe8Pbm5GmjRft05XHT7z6C99g2V0fklGqpXj9DYz6PPb6ysMMU6snBmFc
fpJayYTui7n89lhbiVzn7FGmMCPStl/Cdxfr6b/AF9EP+DherrBs6TB5Zcdy9+u0
Kei7DKOOoDCC0qDCsZAxKMTVXb7nudcpr5phdJYc/hYc8yEJr4vuSDk48dVMFS2l
JbyHPU4x4jYDVeJrinoAZZo2W5qWwFYduxbc7lJi6tewZOfg2pRj1b9myU+PyuA2
JG27nZQigk/s3HRk4O8m8hi4ee3XJGEsawvjaV86DherVt2erCs9IUYuMoIrR85F
pSYww9eE8nIOF/oi8S9j92n7ZnF3usUnBsHXGgC+qagsv7xBG3kywE1T79OLWpy8
nWH1R00291KuTc7/dds6PfbpkWJ/QQnEzxNkTYUqYx4SIRYRRnpXHIoGr0I0GCVa
APFLQQs9WkuFBFoIy+bU
=eTfZ
-----END PGP SIGNATURE-----

--Apple-Mail=_9B7E90BA-BE9E-476E-BAC3-4C72E79E5243--
