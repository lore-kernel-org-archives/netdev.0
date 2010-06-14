From: =?ISO-8859-15?Q?Thomas_B=E4chler?= <thomas@archlinux.org>
Subject: [2.6.35-rc3 regression] TCP connections on 'lo' interface randomly
 stall
Date: Mon, 14 Jun 2010 20:10:27 +0200
Message-ID: <4C167093.2030308@archlinux.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="------------enig0E745B6FA7B0E9915C32A877"
To: "David S. Miller" <davem@davemloft.net>,
	John Fastabend <john.r.fastabend@intel.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig0E745B6FA7B0E9915C32A877
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: quoted-printable

With 2.6.35-rc3, I cannot use TCP over the 'lo' interface any more. This
is reproduced easily by running 'ssh localhost' and executing a few
commands inside the ssh session (if you are able to log in, 'ls -lhFR /'
does a good job) - the connection will stall completely after a very
short time. As far as I can see, all applications are affected.

It also seems that once a service is "stalled", I cannot open a new
connection to the same TCP port anymore. However, I can open a
connection to a different port until that one is stalled, too.

Running wireshark, I can see that TCP retransmissions are sent, but
never acknowledged.

Bisection (starting with 7908a9e as good and v2.6.35-rc3 as bad) leads
to the following commit. Please CC me on replies to this issue. Thanks
for your help.

commit 597a264b1a9c7e36d1728f677c66c5c1f7e3b837
Author: John Fastabend <john.r.fastabend@intel.com>
Date:   Thu Jun 3 09:30:11 2010 +0000

    net: deliver skbs on inactive slaves to exact matches

    Currently, the accelerated receive path for VLAN's will
    drop packets if the real device is an inactive slave and
    is not one of the special pkts tested for in
    skb_bond_should_drop().  This behavior is different then
    the non-accelerated path and for pkts over a bonded vlan.

    For example,

    vlanx -> bond0 -> ethx

    will be dropped in the vlan path and not delivered to any
    packet handlers at all.  However,

    bond0 -> vlanx -> ethx

    and

    bond0 -> ethx

    will be delivered to handlers that match the exact dev,
    because the VLAN path checks the real_dev which is not a
    slave and netif_recv_skb() doesn't drop frames but only
    delivers them to exact matches.

    This patch adds a sk_buff flag which is used for tagging
    skbs that would previously been dropped and allows the
    skb to continue to skb_netif_recv().  Here we add
    logic to check for the deliver_no_wcard flag and if it
    is set only deliver to handlers that match exactly.  This
    makes both paths above consistent and gives pkt handlers
    a way to identify skbs that come from inactive slaves.
    Without this patch in some configurations skbs will be
    delivered to handlers with exact matches and in others
    be dropped out right in the vlan path.

    I have tested the following 4 configurations in failover modes
    and load balancing modes.

    # bond0 -> ethx

    # vlanx -> bond0 -> ethx

    # bond0 -> vlanx -> ethx

    # bond0 -> ethx
                |
      vlanx -> --

    Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>


--------------enig0E745B6FA7B0E9915C32A877
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEAREIAAYFAkwWcJQACgkQEda5KzHP/VDWtgCgt20soZcPEd8dPAENrBhrPZoI
bbgAn1FSKH9tiLjPxPODpVCN1iDhuOsL
=mJ5g
-----END PGP SIGNATURE-----

--------------enig0E745B6FA7B0E9915C32A877--
