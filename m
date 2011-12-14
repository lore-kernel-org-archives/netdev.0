From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Wed, 14 Dec 2011 13:25:58 +1100
Message-ID: <20111214132558.d9ffe5dfb2f09089cec4a21f@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Wed__14_Dec_2011_13_25_58_+1100_Xkr.ZDFhE3ks.Lle"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Antonio Quartulli <ordex@autistici.org>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Wed__14_Dec_2011_13_25_58_+1100_Xkr.ZDFhE3ks.Lle
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got conflicts in
net/batman-adv/translation-table.c between commits 03fc3070457d
("batman-adv: in case of roaming mark the client with TT_CLIENT_ROAM")
and 797399b415b7 ("batman-adv: delete global entry in case of roaming")
from the net tree and commit 48100bac89a6 ("batman-adv: create a common
substructure for tt_global/local_entry") from the net-next tree.

I fixed it up (I think - see below) and can carry the fix as necessary.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc net/batman-adv/translation-table.c
index 5f09a57,cc87acf..0000000
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@@ -245,12 -242,10 +242,12 @@@ void tt_local_add(struct net_device *so
  	if (tt_global_entry) {
  		/* This node is probably going to update its tt table */
  		tt_global_entry->orig_node->tt_poss_change =3D true;
 -		/* The global entry has to be marked as PENDING and has to be
 +		/* The global entry has to be marked as ROAMING and has to be
  		 * kept for consistency purpose */
- 		tt_global_entry->flags |=3D TT_CLIENT_ROAM;
 -		tt_global_entry->common.flags |=3D TT_CLIENT_PENDING;
++		tt_global_entry->common.flags |=3D TT_CLIENT_ROAM;
 +		tt_global_entry->roam_at =3D jiffies;
 +
- 		send_roam_adv(bat_priv, tt_global_entry->addr,
+ 		send_roam_adv(bat_priv, tt_global_entry->common.addr,
  			      tt_global_entry->orig_node);
  	}
  out:
@@@ -704,21 -668,9 +671,21 @@@ void tt_global_del(struct bat_priv *bat
 =20
  	if (tt_global_entry->orig_node =3D=3D orig_node) {
  		if (roaming) {
 -			tt_global_entry->common.flags |=3D TT_CLIENT_ROAM;
 -			tt_global_entry->roam_at =3D jiffies;
 -			goto out;
 +			/* if we are deleting a global entry due to a roam
 +			 * event, there are two possibilities:
 +			 * 1) the client roamed from node A to node B =3D> we mark
 +			 *    it with TT_CLIENT_ROAM, we start a timer and we
 +			 *    wait for node B to claim it. In case of timeout
 +			 *    the entry is purged.
 +			 * 2) the client roamed to us =3D> we can directly delete
 +			 *    the global entry, since it is useless now. */
 +			tt_local_entry =3D tt_local_hash_find(bat_priv,
 -							tt_global_entry->addr);
++							tt_global_entry->common.addr);
 +			if (!tt_local_entry) {
- 				tt_global_entry->flags |=3D TT_CLIENT_ROAM;
++				tt_global_entry->common.flags |=3D TT_CLIENT_ROAM;
 +				tt_global_entry->roam_at =3D jiffies;
 +				goto out;
 +			}
  		}
  		_tt_global_del(bat_priv, tt_global_entry, message);
  	}

--Signature=_Wed__14_Dec_2011_13_25_58_+1100_Xkr.ZDFhE3ks.Lle
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBCAAGBQJO6Ak2AAoJEECxmPOUX5FE8oYP/Rsm4XNUuKNXI/Pjs+SVLAUQ
rZKDgD1vmngGmjaMbUCWyr/n3CPObgphlFKY4wmKcoHaZZwQzHsOE+nkt1kuER8H
EAFo4mBS6eZzIf1cHB5lnXu8cCLkC7J72yiH3Eo37eQLGqx/jgYl9+VN3J2aXRIc
ZGZO5syB1tIWAbVDKzaBdK+iGtABZt7SRDxZDgk1RYPyVQCNG5FGxBCbU9SZgASI
kZ1BniWsvl4kgiz+CdZdN2KC4dMYNGH25E7rNbyS11C3pUb8fq1o4ZAwFWMqCQUH
voCWS9XurXdJDa9dzRlyMgpYOm1Bf0iY34IX6Lcl4ylr68hFaIWZYLH7yEtMSM5d
WFWvXZYGmGkuyn+XGFen/3WUWVw+3u3ddMrmtnki45kVeaFfV3Zj+WNX05lnytp6
+Sw0iCT8ilDp4M2dmhwFjg998ifaoAt1hwm4k/mqKNNxKx44T8SmubY+FeckQvHJ
U00KbPEQLiaCqPzREWx+XZAmFkqtXCBJ3Rlud/GInkFpLPerNx9Qvy0Dd3YzA/GB
9ILC8lnYkdgU3u0DWXYXnZ5/WAYpZqEWdnmkD3zGCEwh2QicM5CszNI7m1WGDbqj
1EKa3r/7pmu4rPNBr1k0qzySFaVTAaUMjcfHICfx/UeBrjur+6+qHsJPtfzSTQdq
FYiyh7UO6ED48JCSOclo
=5uUp
-----END PGP SIGNATURE-----

--Signature=_Wed__14_Dec_2011_13_25_58_+1100_Xkr.ZDFhE3ks.Lle--
