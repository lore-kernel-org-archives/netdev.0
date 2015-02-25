From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net v3] e1000: add dummy allocator to fix race condition
 between mtu change and netpoll
Date: Wed, 25 Feb 2015 14:31:26 -0800
Message-ID: <1424903486.2622.14.camel@jtkirshe-mobl>
References: <1424863598-27187-1-git-send-email-sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-35HRMJSFBdwmWYQiO3Tm"
Cc: linux.nics@intel.com, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:33827 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753024AbbBYWbt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Feb 2015 17:31:49 -0500
In-Reply-To: <1424863598-27187-1-git-send-email-sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-35HRMJSFBdwmWYQiO3Tm
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2015-02-25 at 12:26 +0100, Sabrina Dubroca wrote:
> There is a race condition between e1000_change_mtu's cleanups and
> netpoll, when we change the MTU across jumbo size:
>=20
> Changing MTU frees all the rx buffers:
>     e1000_change_mtu -> e1000_down -> e1000_clean_all_rx_rings ->
>         e1000_clean_rx_ring
>=20
> Then, close to the end of e1000_change_mtu:
>     pr_info -> ... -> netpoll_poll_dev -> e1000_clean ->
>         e1000_clean_rx_irq -> e1000_alloc_rx_buffers ->
> e1000_alloc_frag
>=20
> And when we come back to do the rest of the MTU change:
>     e1000_up -> e1000_configure -> e1000_configure_rx ->
>         e1000_alloc_jumbo_rx_buffers
>=20
> alloc_jumbo finds the buffers already !=3D NULL, since data (shared with
> page in e1000_rx_buffer->rxbuf) has been re-alloc'd, but it's garbage,
> or at least not what is expected when in jumbo state.
>=20
> This results in an unusable adapter (packets don't get through), and a
> NULL pointer dereference on the next call to e1000_clean_rx_ring
> (other mtu change, link down, shutdown):
>=20
> BUG: unable to handle kernel NULL pointer dereference at
> (null)
> IP: [<ffffffff81194d6e>] put_compound_page+0x7e/0x330
>=20
>     [...]
>=20
> Call Trace:
>  [<ffffffff81195445>] put_page+0x55/0x60
>  [<ffffffff815d9f44>] e1000_clean_rx_ring+0x134/0x200
>  [<ffffffff815da055>] e1000_clean_all_rx_rings+0x45/0x60
>  [<ffffffff815df5e0>] e1000_down+0x1c0/0x1d0
>  [<ffffffff811e2260>] ? deactivate_slab+0x7f0/0x840
>  [<ffffffff815e21bc>] e1000_change_mtu+0xdc/0x170
>  [<ffffffff81647050>] dev_set_mtu+0xa0/0x140
>  [<ffffffff81664218>] do_setlink+0x218/0xac0
>  [<ffffffff814459e9>] ? nla_parse+0xb9/0x120
>  [<ffffffff816652d0>] rtnl_newlink+0x6d0/0x890
>  [<ffffffff8104f000>] ? kvm_clock_read+0x20/0x40
>  [<ffffffff810a2068>] ? sched_clock_cpu+0xa8/0x100
>  [<ffffffff81663802>] rtnetlink_rcv_msg+0x92/0x260
>=20
> By setting the allocator to a dummy version, netpoll can't mess up our
> rx buffers.  The allocator is set back to a sane value in
> e1000_configure_rx.
>=20
> Fixes: edbbb3ca1077 ("e1000: implement jumbo receive with partial
> descriptors")
> Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
>=20
> ---
>=20
> v2: Eric Dumazet suggested to remove the forward declaration of
>        e1000_alloc_dummy_rx_buffers
> v3: cleanup whitespace from v1
>=20
>  drivers/net/ethernet/intel/e1000/e1000_main.c | 10 +++++++++-
>  1 file changed, 9 insertions(+), 1 deletion(-)

I have update the patch in my queue, to this latest version.  Thanks

--=-35HRMJSFBdwmWYQiO3Tm
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJU7k0+AAoJEOVv75VaS+3Oes0P/2P5FOcksz7Zm2zshmeRgolv
gcHbch+HedjwyfWDiu3CuQqN6qXAxmP8a3/3kXYss+uzmjYWUfiqlDsbaq3m7wfK
EdgNvn2hgNQu7150B3Jdd5WxAlNn++w78+Dvlc/FAwC/LyVBJGDdMGO5aCFBlpa8
muTNc106OMmKGJv000S/TSypqkMAOZJSOas6b+pyQPaS4jwDiVK41rhenQduCKAg
lRbYJRi6Is/+1C3dq/ypTE/vxYAUccy1OQrWVsxYzwP1AwkrY+wXNZq77XHtOtEL
KoQrZZeIh35Q5ZQMONoWOUXdnqsBlyRp5Hik3NcL41ODxzKlDaxCEP2On0CeCpTz
O5hJRVGzwiMGNcfYPnVYoOByWrb5ouWDQfoLkfrTwr8zN1Yd1VqP+Va14c9VqZba
URwuo4jdjoKO0PN8ChMBSVkZo+RMSCbYPCb5h+49Nbjk7dfyJjr4Jqn2O1t/2Vat
LtvzNmalKt9GSpRhM0Gct4TuiXe/UZBBAJooRaZpUi72L6FQsakTcNr18NrP95gS
1fBTIZ5r94XXXHQdWtNKShIMOTgqo1ROopTM3jCWdi/BWHHkgKc+gYhJsxUPaKRc
gkJp5A81if+3sRj6l51+RKDSL7gGA0XmOlCyyjqK7RDfhAwu/td/wZ7UfGLaCHCc
izpAgVV78SybfLSKkEhx
=Kn/V
-----END PGP SIGNATURE-----

--=-35HRMJSFBdwmWYQiO3Tm--
