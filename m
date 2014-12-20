From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [linux-nics] [PATCH]e100 in linux-3.18.0: some potential bugs
Date: Sat, 20 Dec 2014 02:18:09 -0800
Message-ID: <1419070689.2461.79.camel@jtkirshe-mobl.home>
References: <000001d01c28$41c937c0$c55ba740$@163.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-KeWjCblBHk0ueDpR2zUZ"
Cc: todd.fujinaka@intel.com, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, linux.nics@intel.com,
	Linux-nics@isotope.jf.intel.com
To: Jia-Ju Bai <baijiaju1990@163.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:21433 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750831AbaLTKSL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Dec 2014 05:18:11 -0500
In-Reply-To: <000001d01c28$41c937c0$c55ba740$@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-KeWjCblBHk0ueDpR2zUZ
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2014-12-20 at 15:40 +0800, Jia-Ju Bai wrote:
> I have actually tested e100 driver on the real hardware(Intel 82559
> PCI
> Ethernet Controller), and find some bugs:
> The target file is drivers/net/ethernet/intel/e100.c, which is used to
> build
> e100.ko.
>=20
> (1) The function pci_pool_create is called by e100_probe when
> initializing
> the ethernet card driver. But when pci_pool_create is failed, which
> means
> that it returns NULL to nic->cbs_pool, the system crash will happen.
> Because
> pci_pool_alloc (in e100_alloc_cbs in e100_up in e100_open) need to use
> nic->cbs_pool to allocate the resource, but it is NULL. I suggest that
> a
> check can be added in the code to detect whether pci_pool_create
> returns
> NULL.
> (2) In the normal process, netif_napi_add is called in e100_probe, but
> netif_napi_del is not called in e100_remove. However, many other
> ethernet
> card drivers call them in pairs, even in the error handling paths,
> such as
> r8169 and igb.
>=20
> Meanwhile, I also write the patch to fix the bugs. I have run the
> patch on
> the hardware, it can work normally and fix the above bugs.

Did you actually experience an issue?  Or is this a theoretical issue
that was never actually seen?

>=20
> diff --git a/drivers/net/ethernet/intel/e100.c
> b/drivers/net/ethernet/intel/e100.c
> index 781065e..2631d3f 100644
> --- a/drivers/net/ethernet/intel/e100.c
> +++ b/drivers/net/ethernet/intel/e100.c
> @@ -2969,6 +2969,11 @@ static int e100_probe(struct pci_dev *pdev,
> const
> struct pci_device_id *ent)
>                            nic->params.cbs.max * sizeof(struct cb),
>                            sizeof(u32),
>                            0);
> +       if(!(nic->cbs_pool))
> +       {
> +               err =3D -ENOMEM;
> +               goto err_out_pool;
> +       }
>         netif_info(nic, probe, nic->netdev,

Minor nit-pick but your open bracket needs to be on the same line as the
if statement AND you need a space between the 'if' and ().  So the above
code should look like:
	if (!nic->cbs_pool) {
		err =3D -ENOMEM;
		goto err_out_pool;
	}

--=-KeWjCblBHk0ueDpR2zUZ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUlUzhAAoJEOVv75VaS+3OnRwQAIPR71wpVKDCIP8k4cbmprzW
83DbTTK8dFdclBKuBsxxgsZlnfBVH8mrO0aq2A/nckr398OhlnopOokv66/k+WvW
xZwMczTK5mtxes0io7YvNANVBmDytLVVgqgyse8TNnOwNKxMfCIvFBMM6+AsVl8Z
us7fVf+DPE/6aftyjiZIuLN+3benPClf/MFYHpR9xqzmxpaJxRxNBXTVagdOGck5
LNSUjRRJV/oQQ27aGl0lcmeaZ5V9Gtz7hohcmA3K0gm/Bi+dC4PTAT/yrAIA81UK
rkXK6hN+YR5YQw86l+460AX8q+dzOpUQ8RPCH6urhHt8kbm1O/evnKQdcO5Lny1A
9CnaR3r/d8ZAb0vy0yU+15ZsI9hPeBYdHI8sq9FuwoedCw7RbU+Gpuiq2JKLMhBt
FN7nauBS1uSOMSgnxAXNYyzAP+eLPg4sIdGOdpqwbYfoCBkOtaqhVwVCsofcCP05
4ey9sapWPzky756ImqeecJDlQA1cyqIhxik4wmgz6+ST9AtzXdezrwFYQpH0Pb44
sTbtoC7q/oLjyQ4+75ZJMhocYofZKepNQgl+JgiNeqmEO3v08ToJhF0UfdiApY8T
+fFJawZsO72A+tOXIhPDzYH7V9TSojZW/hwkX66a/BRYHONNSSfVmuXiLHVlKeTQ
tZEIHpu4L4In1D3ni8v3
=/6KO
-----END PGP SIGNATURE-----

--=-KeWjCblBHk0ueDpR2zUZ--
