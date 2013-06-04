From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the wireless-next tree with the net
 tree
Date: Tue, 4 Jun 2013 12:43:47 +1000
Message-ID: <20130604124347.9b994e150e2f37c9be9f32ad@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Tue__4_Jun_2013_12_43_47_+1000_kxrouT8PMJc4_mQZ"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Felix Fietkau <nbd@openwrt.org>,
	Helmut Schaa <helmut.schaa@googlemail.com>,
	Johannes Berg <johannes.berg@intel.com>,
	Jakub Kicinski <kubakici@wp.pl>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Tue__4_Jun_2013_12_43_47_+1000_kxrouT8PMJc4_mQZ
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi John,

Today's linux-next merge of the wireless-next tree got a conflict in
net/mac80211/iface.c between commit ac20976dcaee ("mac80211: Allow single
vif mac address change with addr_mask") from the net tree and commit
31eba5bc56a9 ("mac80211: support active monitor interfaces") from the
wireless-next tree.

I fixed it up (I think - see below) and can carry the fix as necessary
(no action is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc net/mac80211/iface.c
index 7c3ba86,7cabaf2..0000000
--- a/net/mac80211/iface.c
+++ b/net/mac80211/iface.c
@@@ -159,10 -159,10 +159,11 @@@ static int ieee80211_change_mtu(struct=20
  	return 0;
  }
 =20
- static int ieee80211_verify_mac(struct ieee80211_sub_if_data *sdata, u8 *=
addr)
 -static int ieee80211_verify_mac(struct ieee80211_local *local, u8 *addr,
++static int ieee80211_verify_mac(struct ieee80211_sub_if_data *sdata, u8 *=
addr,
+ 				bool check_dup)
  {
 -	struct ieee80211_sub_if_data *sdata;
 +	struct ieee80211_local *local =3D sdata->local;
 +	struct ieee80211_sub_if_data *iter;
  	u64 new, mask, tmp;
  	u8 *m;
  	int ret =3D 0;
@@@ -180,16 -180,16 +181,19 @@@
  		((u64)m[2] << 3*8) | ((u64)m[3] << 2*8) |
  		((u64)m[4] << 1*8) | ((u64)m[5] << 0*8);
 =20
+ 	if (!check_dup)
+ 		return ret;
 =20
  	mutex_lock(&local->iflist_mtx);
 -	list_for_each_entry(sdata, &local->interfaces, list) {
 -		if (sdata->vif.type =3D=3D NL80211_IFTYPE_MONITOR &&
 -		    !(sdata->u.mntr_flags & MONITOR_FLAG_ACTIVE))
 +	list_for_each_entry(iter, &local->interfaces, list) {
 +		if (iter =3D=3D sdata)
  			continue;
 =20
- 		if (iter->vif.type =3D=3D NL80211_IFTYPE_MONITOR)
 -		m =3D sdata->vif.addr;
++		if (iter->vif.type =3D=3D NL80211_IFTYPE_MONITOR &&
++		    !(iter->u.mntr_flags & MONITOR_FLAG_ACTIVE))
 +			continue;
 +
 +		m =3D iter->vif.addr;
  		tmp =3D	((u64)m[0] << 5*8) | ((u64)m[1] << 4*8) |
  			((u64)m[2] << 3*8) | ((u64)m[3] << 2*8) |
  			((u64)m[4] << 1*8) | ((u64)m[5] << 0*8);
@@@ -213,7 -214,11 +218,11 @@@ static int ieee80211_change_mac(struct=20
  	if (ieee80211_sdata_running(sdata))
  		return -EBUSY;
 =20
- 	ret =3D ieee80211_verify_mac(sdata, sa->sa_data);
+ 	if (sdata->vif.type =3D=3D NL80211_IFTYPE_MONITOR &&
+ 	    !(sdata->u.mntr_flags & MONITOR_FLAG_ACTIVE))
+ 		check_dup =3D false;
+=20
 -	ret =3D ieee80211_verify_mac(sdata->local, sa->sa_data, check_dup);
++	ret =3D ieee80211_verify_mac(sdata, sa->sa_data, check_dup);
  	if (ret)
  		return ret;
 =20

--Signature=_Tue__4_Jun_2013_12_43_47_+1000_kxrouT8PMJc4_mQZ
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.20 (GNU/Linux)

iQIcBAEBCAAGBQJRrVRjAAoJEECxmPOUX5FE/TcP/R7rrsYkvqKPEFKfCmQTbQow
NaRNFfyI//lsNoqn/SxgvUL2Z6jyaPLzIrjw1gjO0h2+xPkZXChTOwwke+q0WOhJ
SvUt8uLenTOLwHDsGDcV/KvhqdTkF4gCpqAxz9F5xAUzeg7Zzv0PJRRiY8rN8/Zi
Tc70GxyimcnjbhDrzclUCoR5C1akXBdLIPzStKNPzDLm6doWUwe3pgWEVC4nFRg5
Na0a+E4iAh2qPUGZnhkLsqz0l8ysBqla6o0kxT0nMBNe4Ii7OHtbwPuoIIU1NUGC
l0wRYrjTzqAaYNuiKJeqVZw50EFBfXQU/XndPOKeLvNujGhSL3Crej1SozXLICUc
M7DU7Dz4AYbSMoggRklTl7PwURuAgcIRp2SnPyqmc/psAFwotsrJGFb3cwrbrQtV
VTbNtHP0GZYg5nR6cZZrfkxwl7bsjq6eByAs0xyBV+ePp2cn2H5FSFJwd6AI/kjr
S+YGHFBN/TxyfzBlz+ZQEAnfOYsislAqUCuA949TS6DMBjWSvp+c1xLw+QY28Rn5
qpTYKBRiFJBKFCf4Nf7ikWMpgbgjleWH5UV1UC1rM1GNXNxA99tRpImqmW4xbOPt
iontwmpaiTb2Q/1tnnrTBaV50xxlvf2f9zCfx6vDt4kW5RdgHvuIUM7dgItqaE4c
X6fP52I90UylE5+kex6t
=AnC/
-----END PGP SIGNATURE-----

--Signature=_Tue__4_Jun_2013_12_43_47_+1000_kxrouT8PMJc4_mQZ--
