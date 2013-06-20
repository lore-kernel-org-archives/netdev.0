From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Thu, 20 Jun 2013 12:58:23 +1000
Message-ID: <20130620125823.da633b21e33688372729b9c0@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Thu__20_Jun_2013_12_58_23_+1000_PWJKQjTJ.dTkhSk1"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Johannes Berg <johannes.berg@intel.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Thu__20_Jun_2013_12_58_23_+1000_PWJKQjTJ.dTkhSk1
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
net/wireless/nl80211.c between commit 3a5a423bb958 ("nl80211: fix attrbuf
access race by allocating a separate one") from the net tree and commit
5fe231e87372 ("cfg80211: vastly simplify locking") from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc net/wireless/nl80211.c
index b14b7e3,31d265f..0000000
--- a/net/wireless/nl80211.c
+++ b/net/wireless/nl80211.c
@@@ -1564,17 -1527,12 +1527,17 @@@ static int nl80211_dump_wiphy(struct sk
  	struct cfg80211_registered_device *dev;
  	s64 filter_wiphy =3D -1;
  	bool split =3D false;
 -	struct nlattr **tb =3D nl80211_fam.attrbuf;
 +	struct nlattr **tb;
  	int res;
 =20
 +	/* will be zeroed in nlmsg_parse() */
 +	tb =3D kmalloc(sizeof(*tb) * (NL80211_ATTR_MAX + 1), GFP_KERNEL);
 +	if (!tb)
 +		return -ENOMEM;
 +
- 	mutex_lock(&cfg80211_mutex);
+ 	rtnl_lock();
  	res =3D nlmsg_parse(cb->nlh, GENL_HDRLEN + nl80211_fam.hdrsize,
 -			  tb, nl80211_fam.maxattr, nl80211_policy);
 +			  tb, NL80211_ATTR_MAX, nl80211_policy);
  	if (res =3D=3D 0) {
  		split =3D tb[NL80211_ATTR_SPLIT_WIPHY_DUMP];
  		if (tb[NL80211_ATTR_WIPHY])
@@@ -1586,11 -1544,8 +1549,10 @@@
  			int ifidx =3D nla_get_u32(tb[NL80211_ATTR_IFINDEX]);
 =20
  			netdev =3D dev_get_by_index(sock_net(skb->sk), ifidx);
 -			if (!netdev)
 +			if (!netdev) {
- 				mutex_unlock(&cfg80211_mutex);
 +				kfree(tb);
  				return -ENODEV;
 +			}
  			if (netdev->ieee80211_ptr) {
  				dev =3D wiphy_to_dev(
  					netdev->ieee80211_ptr->wiphy);

--Signature=_Thu__20_Jun_2013_12_58_23_+1000_PWJKQjTJ.dTkhSk1
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.20 (GNU/Linux)

iQIcBAEBCAAGBQJRwm/TAAoJEECxmPOUX5FEIi8P/3l0DTQM8UM86ZGuhxaMeK3x
Q0elirtp3arstUZWMU0eMgVteN9HZgdEHajxtNKhVbPjU/pRIcAdEC04CWPuu5NL
yfChxQLuL+tmQljvvkwcRwu4oRorHPMvmOFq5K9rSRtjYXJsOKBv/sabdPVhaFU2
gdnWPf5h13oOy3gtINVhxr7PpRNTTHviyB9omTlKC9ULOE7oPS8Pc5LK0fiQu2xs
VwRXJgz2KACUI9VS9jXTGa5U8EjoBYUAQ6twKT+OXQ485tv8UR43GvXfT8/eWGLl
QEINXpsftfxCnDwfSl9HlFW+F5Q7v8h7Pd+L9m9PcbMNfzaVfbs/eiM3Qsu6pBri
24tn56/g8nVN+siE+dknk8lUL3pRwNqBZrtuWh2WTGGKyHZUQyVJlrMdza3bpltx
dyBckoxNKoc/8S6hdhdeW8AWPv6Kucoy/Mf1x26rmRV3gIrVlTTVZRfqxiIT1+o1
/M2mUq5qXTiXeKrCkuNjzVqy4rJhQp0Qq8RqRg/yaJ0aF74eJewawynmucecXm2O
RBe4tNRXD/Q6xhO7xPUcxxUaJhARRdf4SyVQmSAFqhmPP3DyAdaLWhY+WCnU8tuE
lq4MERh3CkIeNFabOMlFeS8rxj+36rwo6HHw962Dcu49Uwrpvy8nGnjqKzUbd3L8
46ltbolgrUvghoVjwRD8
=dE0T
-----END PGP SIGNATURE-----

--Signature=_Thu__20_Jun_2013_12_58_23_+1000_PWJKQjTJ.dTkhSk1--
