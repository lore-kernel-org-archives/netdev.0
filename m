From: Richard Yao <ryao@gentoo.org>
Subject: Re: Latest version of zero-copy fix
Date: Mon, 10 Feb 2014 20:31:11 -0500
Message-ID: <52F97D5F.4040100@gentoo.org>
References: <20140210.152150.574073124161003333.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="j90s798dAOIAWh50EuKepsubOAGj6F4SA"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:49379 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751291AbaBKBb0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Feb 2014 20:31:26 -0500
In-Reply-To: <20140210.152150.574073124161003333.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--j90s798dAOIAWh50EuKepsubOAGj6F4SA
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 02/10/2014 06:21 PM, David Miller wrote:
>=20
> So now the patch only tests is_vmalloc_addr(), did you test this
> version with the situation that triggers the given backtrace?
>=20
> [<ffffffff814878ce>] p9_virtio_zc_request+0x45e/0x510
> [<ffffffff814814ed>] p9_client_zc_rpc.constprop.16+0xfd/0x4f0
> [<ffffffff814839dd>] p9_client_read+0x15d/0x240
> [<ffffffff811c8440>] v9fs_fid_readn+0x50/0xa0
> [<ffffffff811c84a0>] v9fs_file_readn+0x10/0x20
> [<ffffffff811c84e7>] v9fs_file_read+0x37/0x70
> [<ffffffff8114e3fb>] vfs_read+0x9b/0x160
> [<ffffffff81153571>] kernel_read+0x41/0x60
> [<ffffffff810c83ab>] copy_module_from_fd.isra.34+0xfb/0x180
>=20
> This is reading from v9fs into a module address.
>=20
> It's going generate the same backtrace with your fix.
>=20
> I don't think the situation was sufficiently explained to Linus.  In
> fact, I didn't see the above backtrace mentioned at all.
>=20

I have tested it against Linux 3.13.0 and I can confirm that it solves
the problem. In fact, this was the original patch in December before I
made the last minute change to is_module_or_vmalloc_addr() only after
deciding that is_vmalloc_addr() was not general enough.

Linus' response had two key points. Linus' first point was that my
generalization of is_vmalloc_addr() to is_module_or_vmalloc_addr() was
unnecessary to fix this problem because the order of events is as follows=
:

1. We allocate a temporary buffer with vmalloc().
2. We read the module into that buffer.
3. We copy the module from that buffer into its final location.

Linus' second point was that my generalization permitted IO to be done
to a region of memory where IO operations should never be done. When I
wrote this back in December, I wanted to write as general a fix as
possible because Alexander Graf had pointed out to me that there had
Will Deacon had written a patch that should have included this, but
neglected it and I was afraid that that would become a cycle.

Linus' clear explanation of why this is a bad idea changed my mind, so I
submitted the original form of this patch with an updated commit message.=



--j90s798dAOIAWh50EuKepsubOAGj6F4SA
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBAgAGBQJS+X1sAAoJECDuEZm+6Exk2BQP/jslesVNVNPumHQDF6oYDTU1
hvrc5opTWxULRVONrySQaajAULrpsn/wayxCCwQp+J5ogS+nCYflw8K/F2zFwOvi
lydPHaQj92KPnijrU+cCcCBdwtfXmhJFk4t3bwje0dDHcV8C645HXOkg4NkGyVma
X3J0xwgJYLemVegkpjStyMR4rkHVv1rnKrj15eByBM/9rzyeVblDgbdH3kcv+Eko
/3YwtgguJ4PUNARQhvV17jkHWt3oQmittIpg6MT3r9GgltW/blWi83i2SpXO7Vb7
rzkeF+MAtKqiifBDXfzDGptFrp0N6epYddUIVX5wouvY59UZSpis/eZVcJZpd7Bb
gbVUr+bNrLtM125RiKyC/6BcTiFHuV1BV/S5um8/FhB2ZMfAO85y/uQVK7rWRkqs
LSWc7ufbKcYS0wRrwYTyN/0tObZYYgD2/14tul3wlgpAsNuay9ynVkwfY1RvozIc
80m+gvf83fKqmBEetR7weNKPGlwI/1wq3d1qfkS6B7uR9dGw+6JztZikptfBKSMT
iXKxFHU0t9Y0GK+kZrEHyjvNYd3MqJiFKE2U209888WaeBYuHJCZ4GApO9vvaUpv
I8UbCKzoz6IsUX/Bq89x/KB9glNDX2khP1JCYeYvxvW/2MEUYdfV1h2+c3WZ2JQd
SHAXT/IfXLYdvVzU9ADu
=7Gx5
-----END PGP SIGNATURE-----

--j90s798dAOIAWh50EuKepsubOAGj6F4SA--
