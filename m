From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Fri, 19 Apr 2013 12:53:04 +1000
Message-ID: <20130419125304.9980f9b037abf00bef7b6f8c@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Fri__19_Apr_2013_12_53_04_+1000_pinOPf3L1G/h48ph"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Antonio Quartulli <ordex@autistici.org>,
	Marek Lindner <lindner_marek@yahoo.de>,
	Martin =?UTF-8?B?SHVuZGViw7hsbA==?= <martin@hundeboll.net>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Fri__19_Apr_2013_12_53_04_+1000_pinOPf3L1G/h48ph
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
net/batman-adv/routing.c between commit fe8a93b95145 ("batman-adv: make
is_my_mac() check for the current mesh only") from the net tree and
commits f86ce0ad107b ("batman-adv: Return reason for failure in
batadv_check_unicast_packet()") and 612d2b4fe0a1 ("batman-adv: network
coding - save overheard and tx packets for decoding") from the net-next
tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc net/batman-adv/routing.c
index 319f290,8f88967..0000000
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@@ -548,8 -549,17 +549,19 @@@ batadv_find_ifalter_router(struct batad
  	return router;
  }
 =20
+ /**
+  * batadv_check_unicast_packet - Check for malformed unicast packets
++ * @batpriv: some description ...
+  * @skb: packet to check
+  * @hdr_size: size of header to pull
+  *
+  * Check for short header and bad addresses in given packet. Returns nega=
tive
+  * value when check fails and 0 otherwise. The negative value depends on =
the
+  * reason: -ENODATA for bad header, -EBADR for broadcast destination or s=
ource,
+  * and -EREMOTE for non-local (other host) destination.
+  */
 -static int batadv_check_unicast_packet(struct sk_buff *skb, int hdr_size)
 +static int batadv_check_unicast_packet(struct batadv_priv *bat_priv,
 +				       struct sk_buff *skb, int hdr_size)
  {
  	struct ethhdr *ethhdr;
 =20
@@@ -565,11 -575,11 +577,11 @@@
 =20
  	/* packet with broadcast sender address */
  	if (is_broadcast_ether_addr(ethhdr->h_source))
- 		return -1;
+ 		return -EBADR;
 =20
  	/* not for me */
 -	if (!batadv_is_my_mac(ethhdr->h_dest))
 +	if (!batadv_is_my_mac(bat_priv, ethhdr->h_dest))
- 		return -1;
+ 		return -EREMOTE;
 =20
  	return 0;
  }
@@@ -1046,7 -1058,16 +1061,16 @@@ int batadv_recv_unicast_packet(struct s
  	if (is4addr)
  		hdr_size =3D sizeof(*unicast_4addr_packet);
 =20
- 	if (batadv_check_unicast_packet(bat_priv, skb, hdr_size) < 0)
+ 	/* function returns -EREMOTE for promiscuous packets */
 -	check =3D batadv_check_unicast_packet(skb, hdr_size);
++	check =3D batadv_check_unicast_packet(bat_priv, skb, hdr_size);
+=20
+ 	/* Even though the packet is not for us, we might save it to use for
+ 	 * decoding a later received coded packet
+ 	 */
+ 	if (check =3D=3D -EREMOTE)
+ 		batadv_nc_skb_store_sniffed_unicast(bat_priv, skb);
+=20
+ 	if (check < 0)
  		return NET_RX_DROP;
 =20
  	if (!batadv_check_unicast_ttvn(bat_priv, skb))

--Signature=_Fri__19_Apr_2013_12_53_04_+1000_pinOPf3L1G/h48ph
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJRcLGQAAoJEECxmPOUX5FEW/MP/2MTNpJyYB09OH+f1KMI4Vra
R1LtHLig3DFwCeAff9FMIt659C7XJIQLTERXO4SL6YLz742uJMU9D6edBl1H2acJ
zcz24mMgjIAqAWN8VxndCzGxA6GAmXU2l/b7kYUyGWjFVq3TAnM7MrgxM7uMzipU
uV3vd6dJlvbdST83Tj0NuzdvNBwVo2luVSdtnj3UW6x8w9TOUMD3HN+k0mD3l5iE
fvipSzsJ/WjTiISAiixoA6cOMx2RF3NsBtO985LDbZMXAnMknECkYHnZYSwbIck7
WOrJ3AU4M+Z1YOLCWHdTLfJLU4kW4gLvcboogq6FwRFGQVjOvkrsYlhY5lVI8tKm
5TNYNu4FTXRfvu35CZvJVcn/vd8wGkQvJDZTEsTryYyoXz7MHgCqIX9NZJAxPgj2
n/VXnlzzoKVqGhigPziddSzHQai8zL3OwOaNd7vLN0wt9ZQNYJRUpiYQZEbFHBOe
wzYnnJhwT0Nz5pK6vGrpSnH9PyP9+nxZjdrKVnhO0g4q4VUAMxjinjjIxYnjPrce
QDyowgum5nPEqtQRFEb1A35lYO0DHECOeWcIuadPQDU6obh3/2xwwC6eL477levQ
rX0EOB+5Yv8BYylHiD8xvZVradu3R9JAuwq9ctJ47sDxWJrZ1g7zGbb5yvnrN0Pc
Z5X4UMmPAOjwNJtzPE42
=k11x
-----END PGP SIGNATURE-----

--Signature=_Fri__19_Apr_2013_12_53_04_+1000_pinOPf3L1G/h48ph--
