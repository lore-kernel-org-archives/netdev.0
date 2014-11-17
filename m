From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net] ixgbe: fix use after free adapter->state test in
 ixgbe_remove/ixgbe_probe
Date: Mon, 17 Nov 2014 15:48:14 -0800
Message-ID: <1416268094.2983.13.camel@jtkirshe-mobl.jf.intel.com>
References: <1416267827-11545-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-h+iCeDDZnyQ54p79gaFz"
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Mark Rustad <mark.d.rustad@intel.com>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:41882 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751836AbaKQXsP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Nov 2014 18:48:15 -0500
In-Reply-To: <1416267827-11545-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-h+iCeDDZnyQ54p79gaFz
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2014-11-18 at 00:43 +0100, Daniel Borkmann wrote:
> While working on a different issue, I noticed an annoying use
> after free bug on my machine when unloading the ixgbe driver:
>=20
> [ 8642.318797] ixgbe 0000:02:00.1: removed PHC on p2p2
> [ 8642.742716] ixgbe 0000:02:00.1: complete
> [ 8642.743784] BUG: unable to handle kernel paging request at
> ffff8807d3740a90
> [ 8642.744828] IP: [<ffffffffa01c77dc>] ixgbe_remove+0xfc/0x1b0
> [ixgbe]
> [ 8642.745886] PGD 20c6067 PUD 81c1f6067 PMD 81c15a067 PTE
> 80000007d3740060
> [ 8642.746956] Oops: 0002 [#1] SMP DEBUG_PAGEALLOC
> [ 8642.748039] Modules linked in: [...]
> [ 8642.752929] CPU: 1 PID: 1225 Comm: rmmod Not tainted 3.18.0-rc2+
> #49
> [ 8642.754203] Hardware name: Supermicro X10SLM-F/X10SLM-F, BIOS 1.1b
> 11/01/2013
> [ 8642.755505] task: ffff8807e34d3fe0 ti: ffff8807b7204000 task.ti:
> ffff8807b7204000
> [ 8642.756831] RIP: 0010:[<ffffffffa01c77dc>]  [<ffffffffa01c77dc>]
> ixgbe_remove+0xfc/0x1b0 [ixgbe]
> [...]
> [ 8642.774335] Stack:
> [ 8642.775805]  ffff8807ee824098 ffff8807ee824098 ffffffffa01f3000
> ffff8807ee824000
> [ 8642.777326]  ffff8807b7207e18 ffffffff8137720f ffff8807ee824098
> ffff8807ee824098
> [ 8642.778848]  ffffffffa01f3068 ffff8807ee8240f8 ffff8807b7207e38
> ffffffff8144180f
> [ 8642.780365] Call Trace:
> [ 8642.781869]  [<ffffffff8137720f>] pci_device_remove+0x3f/0xc0
> [ 8642.783395]  [<ffffffff8144180f>] __device_release_driver+0x7f/0xf0
> [ 8642.784876]  [<ffffffff814421f8>] driver_detach+0xb8/0xc0
> [ 8642.786352]  [<ffffffff814414a9>] bus_remove_driver+0x59/0xe0
> [ 8642.787783]  [<ffffffff814429d0>] driver_unregister+0x30/0x70
> [ 8642.789202]  [<ffffffff81375c65>] pci_unregister_driver+0x25/0xa0
> [ 8642.790657]  [<ffffffffa01eb38e>] ixgbe_exit_module+0x1c/0xc8e
> [ixgbe]
> [ 8642.792064]  [<ffffffff810f93a2>] SyS_delete_module+0x132/0x1c0
> [ 8642.793450]  [<ffffffff81012c61>] ? do_notify_resume+0x61/0xa0
> [ 8642.794837]  [<ffffffff816d2029>] system_call_fastpath+0x12/0x17
>=20
> The issue is that test_and_set_bit() done on adapter->state is being
> performed *after* the netdevice has been freed via free_netdev().
>=20
> When netdev is being allocated on initialization time, it allocates
> a private area, here struct ixgbe_adapter, that resides after the
> net_device structure. In ixgbe_probe(), the device init routine,
> we set up the adapter after alloc_etherdev_mq() on the private area
> and add a reference for the pci_dev as well via pci_set_drvdata().
>=20
> Both in the error path of ixgbe_probe(), but also on module unload
> when ixgbe_remove() is being called, commit 41c62843eb6a accesses
> adapter after free_netdev(). The patch stores the result in a bool
> and thus fixes above oops on my side.
>=20
> Fixes: 41c62843eb6a ("ixgbe: Fix rcu warnings induced by LER")
> Cc: Mark Rustad <mark.d.rustad@intel.com>
> Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> ---
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 8 ++++++--
>  1 file changed, 6 insertions(+), 2 deletions(-)

Thanks Daniel, I will add your patch to my net queue.

--=-h+iCeDDZnyQ54p79gaFz
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUaok+AAoJEOVv75VaS+3O0dQP/jWFZeRq2W7D3g7W3pNtZh5j
rg1KJ8vkP0HKY/gW0yu5WlFqfiHne3d6mdmrwefI+zA6U4FJhCpdBYz9KUPAKoB0
yjdxGOwffcjqSoNvmzpGh5/16E3p6DYctl0yYElGKoHxbl/N89J6gHrk+GufGZ8m
BsF6DHJD5g4a0j5nDW/wYHf/dC383Bybo1hNJPQgikOiRbwijA29pwYDmqMPk+Ag
LSnY2J/dKOz1NHMAHhsnHJ7YRd9otKQovSBdMz+uJJ7959pfMaN3Czgt0id2GlZr
1N0SiHaxoBfrHEGtbuX8p5rZW00iQbRVvsMfsaUju+PfbLSfheMXsludlL3BH7Ob
XvZDi9lIFSkN7LjGx1cPLTamS3NN+oSmgOiKBRRl6mxrfHF1fA1T9JK1XuHFVJVP
RMpfzmysOWVBb2TG26tR6tup2o3jv6ndBbo5A2z2ceMjtiUlA8QS93M0hBoxMApV
PdrKTBvmk3X6wN+2X4R9DraXfAVXtRY8Hc2+t33hIvAFZUwV7IA430tr1rSOj3s3
AGs5L5IhsDDjgwNK/Nw1+dqu9VgneOrKeh3Vzz7uwyByJd8E6lG6SPE54AIYjDQA
f0wh7vEsNr52sJSuIID7xxRgfBlELiCvTqrB4CxJ38DkEgcOQh4V8c2mn+bPbKjt
4m+AAf7EWPhkhkWyFgdO
=KFOh
-----END PGP SIGNATURE-----

--=-h+iCeDDZnyQ54p79gaFz--
