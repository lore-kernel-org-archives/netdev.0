From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [linux-nics] [PATCH] e1000e in linux-3.18.0: some potential bugs
Date: Sat, 20 Dec 2014 02:22:32 -0800
Message-ID: <1419070952.2461.82.camel@jtkirshe-mobl.home>
References: <000f01d01c2b$4af1b3b0$e0d51b10$@163.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-ZS0c5FxUOSx6qnNC9Nv2"
Cc: todd.fujinaka@intel.com, netdev@vger.kernel.org,
	e1000-devel@lists.sourceforge.net, linux.nics@intel.com
To: Jia-Ju Bai <baijiaju1990@163.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:42539 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750831AbaLTKWd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Dec 2014 05:22:33 -0500
In-Reply-To: <000f01d01c2b$4af1b3b0$e0d51b10$@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-ZS0c5FxUOSx6qnNC9Nv2
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2014-12-20 at 16:02 +0800, Jia-Ju Bai wrote:
> I have actually tested e1000e driver on the real hardware(Intel
> 82572EI
> PCI-E Gigabit Ethernet Controller), and find some potential bugs:
> The target file is drivers/net/ethernet/intel/e1000e/netdev.c, which
> is used
> to build e1000e.ko.
>=20
> (1) In the normal process, netif_napi_add is called in e1000_probe,
> but
> netif_napi_del is not called in e1000_remove. However, many other
> ethernet
> card drivers call them in pairs, even in the error handling paths,
> such as
> r8169 and igb.
>=20
> (2) The function vzalloc is called by e1000e_setup_rx_resources (in
> e1000_open) when initializing the ethernet card driver. But when
> vzalloc is
> failed, "err" segment in e1000e_setup_rx_resources is executed to
> return and
> then e1000e_free_tx_resources in "err_setup_rx" segment in e1000_open
> is
> executed to halt. However, "writel(0, tx_ring->head)" statement in
> e1000_clean_tx_ring in e1000e_free_tx_resources will cause system
> crash,
> because "tx_ring->head" is not assigned the value. In the code,
> "tx_ring->head" is initialized in e1000_configure_tx in
> e1000_configure
> after the e1000e_setup_rx_resources.
> (3) The same system crashes happens, when kcalloc in
> e1000e_setup_rx_resources is failed(returns NULL).
> (4) The same system crashes happens, when e1000_alloc_ring_dma in
> e1000e_setup_rx_resources is failed(returns error code).
>=20
> (5) In the normal process of e1000e, pci_enable_pcie_error_reporting
> and
> pci_disable_pcie_error_reporting is called in pairs in e1000_probe and
> e1000_remove. However, when pci_enable_pcie_error_reporting has been
> called
> and pci_save_state in e1000_probe is failed, "err_alloc_etherdev"
> segment in
> e1000_probe is executed immediately to exit, but
> pci_disable_pcie_error_reporting is not called.
> (6) The same situation happens when alloc_etherdev_mqs in e1000_probe
> is
> failed.
> (7) The same situation happens when ioremap in e1000_probe is failed.
> (8) The same situation happens when e1000_sw_init in e1000_probe is
> failed.
> (9) The same situation happens when register_netdev in e1000_probe is
> failed.
>=20
> (10) When request_irq in e1000_request_irq is failed,
> pm_qos_add_request in
> e1000_open is called, but pm_qos_remove_request is not called.
>=20
> Meanwhile, I also write the patch to fix the bugs. I have run the
> patch on
> the hardware, it can work normally and fix the above bugs.

Again, is this an issue you saw or a theoretical issue?

>=20
> diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c
> b/drivers/net/ethernet/intel/e1000e/netdev.c
> index 247335d..02d1e67 100644
> --- a/drivers/net/ethernet/intel/e1000e/netdev.c
> +++ b/drivers/net/ethernet/intel/e1000e/netdev.c
> @@ -2444,6 +2444,8 @@ static void e1000_clean_tx_ring(struct
> e1000_ring
> *tx_ring)
>         tx_ring->next_to_use =3D 0;
>         tx_ring->next_to_clean =3D 0;
> =20
> +       if(!(tx_ring->head))
> +               return;

Need a space between the 'if' and the ().  Please check your patches by
running checkpatch.pl on them before sending them out.

--=-ZS0c5FxUOSx6qnNC9Nv2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUlU3oAAoJEOVv75VaS+3OzusQAI2b1/4lPMmhLTmtlRJMF4Wi
ymbHyEbFsRTPahsrHGbh8oGZFCbpU9ggBHvqVfYf1N6s0QnDF2m2yG89ERH7aWxJ
yvrqMStRs/I13PyApgjhsXn3th1FbuxRVqBX3pODge7IWHmPYDHcPTuYNzH06IAi
trayFF3CmGtBtCy2z5G5O6Fm0uq+sXdo6HrqW2LJ9O9kUpHOpZOzLfIAJ5WIRdv6
Skdfgo9K+3josfSoShgfk7yes1r9XFOVM7UG0QjCH5b/gDXtxlJvU3GFyolIHI+/
fyd1IeAEFAVuDnqSfkownH61vYSOngqR892vnN9E3xKtpn3peomNL7Xz+ogtqW9W
Zg5gQyK8F5lIPYc1Hxt2N1EKXT67Ks6kzCbOTyqBKMMXv5lVIRI+FE2BQRDW95ak
zAU4IhKk8+phBsNJNzt38Bw0fynubzWSllgpO0TBvAzbGPfR83wgYuLFh2wubpJd
X55b70Z7sffqbMlPn2bAYH0DyvUMKPcy+QBRbNHuvQniLF/9xO+LswXFajcGQUPN
HN22bsrtMsYJLvgpf+53Kd2d8ZY+i2BLFNFzQKqaPMziowOARdGb8ULr+NurOe8s
PIKxVyjqmMIljZfy+HPrdTAkFJ3ZyEMzqZhw4Kz+3KiadJXY3Mr5jGIsugt1snpX
Url8ZXqOLfQFYpfnuwh7
=Gxcw
-----END PGP SIGNATURE-----

--=-ZS0c5FxUOSx6qnNC9Nv2--
