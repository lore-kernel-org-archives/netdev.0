From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Mon, 6 Jan 2014 15:35:48 +1100
Message-ID: <20140106153548.0550a4f9753ec61cd53fa53e@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Mon__6_Jan_2014_15_35_48_+1100_M3taVUsPX=IFzAXn"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Li RongQing <roy.qing.li@gmail.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Mon__6_Jan_2014_15_35_48_+1100_M3taVUsPX=IFzAXn
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
net/ipv6/ip6_tunnel.c between commit abb6013cca14 ("ipv6: fix the use of
pcpu_tstats in ip6_tunnel") from the net tree and commit 8f84985fec10
("net: unify the pcpu_tstats and br_cpu_netstats as one") from the
net-next tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc net/ipv6/ip6_tunnel.c
index 7881965a8248,02894216a46d..000000000000
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@@ -103,25 -101,17 +101,26 @@@ struct ip6_tnl_net=20
 =20
  static struct net_device_stats *ip6_get_stats(struct net_device *dev)
  {
- 	struct pcpu_tstats tmp, sum =3D { 0 };
 -	struct pcpu_sw_netstats sum =3D { 0 };
++	struct pcpu_sw_netstats tmp, sum =3D { 0 };
  	int i;
 =20
  	for_each_possible_cpu(i) {
 +		unsigned int start;
- 		const struct pcpu_tstats *tstats =3D per_cpu_ptr(dev->tstats, i);
+ 		const struct pcpu_sw_netstats *tstats =3D
+ 						   per_cpu_ptr(dev->tstats, i);
 =20
 -		sum.rx_packets +=3D tstats->rx_packets;
 -		sum.rx_bytes   +=3D tstats->rx_bytes;
 -		sum.tx_packets +=3D tstats->tx_packets;
 -		sum.tx_bytes   +=3D tstats->tx_bytes;
 +		do {
 +			start =3D u64_stats_fetch_begin_bh(&tstats->syncp);
 +			tmp.rx_packets =3D tstats->rx_packets;
 +			tmp.rx_bytes =3D tstats->rx_bytes;
 +			tmp.tx_packets =3D tstats->tx_packets;
 +			tmp.tx_bytes =3D  tstats->tx_bytes;
 +		} while (u64_stats_fetch_retry_bh(&tstats->syncp, start));
 +
 +		sum.rx_packets +=3D tmp.rx_packets;
 +		sum.rx_bytes   +=3D tmp.rx_bytes;
 +		sum.tx_packets +=3D tmp.tx_packets;
 +		sum.tx_bytes   +=3D tmp.tx_bytes;
  	}
  	dev->stats.rx_packets =3D sum.rx_packets;
  	dev->stats.rx_bytes   =3D sum.rx_bytes;

--Signature=_Mon__6_Jan_2014_15_35_48_+1100_M3taVUsPX=IFzAXn
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJSyjKlAAoJEMDTa8Ir7ZwVJHcP/11Bg5UPrSZ0EIUvwYmMmSjS
NGqvC1VRok7ljHxCOc0v+7qth+gKAlWDud9+K60/EuyDK3KFF3rY4zckrcualJnj
0ozwBNy+N2aBtbK2jlrvy/qMLJMdA9T2MSFJodxbXt6jfVfstHP1uat/WcdveiuI
C/rIpm38mPs8EeR1RgdMBZ1G4w5rqRvWaBCqDpv+Ed5ihDVGLa9qftbQtlMr5348
UWuTgeU1g1ttPNYuMvmIJxpP2A1fc2n0S642EOtx1BMoLWO+s4dG0BGT8R6goo4U
YMpvIVzzYwRNEHuzMpNeFpCoDr/8OdfDaRkk7iVu3PhdZPf2uVRmCoH93u9N0vPs
TdmdpfjocSYoiBwmoGxPan3RuhUNy8JmpMaE/bLdP6V1T0c2iNua5eyxsrvaq2+B
DNDfnUqbDOY4K/8s5KyJmstYUaIR/Z5HRpgDCXW9yvXgIlxFtYdsGyckSwA+0z7+
judqemhEyzItzPnZy5sA7LNP+6MlvS9/2Ai3UvC9lYBbgPemPnHyjwkz6M4xCc0U
vuo9PUw/e0XjGKvhpDAB4LaLnIA0KoZ+deafKaBT/1KcpBAqu+acGSjEfeGskt0S
/IhKPyXmLYtHC0MLy7PTN+i7IhF3QA5+Ex/yLde2EAQs2Qr85BK9C9luUzKNChW2
iQOGFEsZUXUnGUD+2XJ4
=UD9q
-----END PGP SIGNATURE-----

--Signature=_Mon__6_Jan_2014_15_35_48_+1100_M3taVUsPX=IFzAXn--
