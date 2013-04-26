From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the net-next tree
Date: Fri, 26 Apr 2013 13:48:14 +1000
Message-ID: <20130426134814.17f27efe88073999dcf634bb@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Fri__26_Apr_2013_13_48_14_+1000_tfNgrNkL5_u/K9uU"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>,
	Ajit Khaparde <ajit.khaparde@emulex.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Fri__26_Apr_2013_13_48_14_+1000_tfNgrNkL5_u/K9uU
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

After merging the net-next tree, today's linux-next build (powerpc
ppc64_defconfig) failed like this:

drivers/net/ethernet/emulex/benet/be_main.c: In function 'be_insert_vlan_in=
_pkt':
drivers/net/ethernet/emulex/benet/be_main.c:786:3: error: too few arguments=
 to function '__vlan_put_tag'
include/linux/if_vlan.h:220:31: note: declared here
drivers/net/ethernet/emulex/benet/be_main.c:796:3: error: too few arguments=
 to function '__vlan_put_tag'
include/linux/if_vlan.h:220:31: note: declared here

Caused by comt interaction of commit 86a9bad3ab6b ("net: vlan: add
protocol argument to packet tagging functions") from the net-next tree
and commit bc0c3405abbb ("be2net: fix a Tx stall bug caused by a specific
ipv6 packet") from the net tree.

I applied the following merge fix patch:

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Fri, 26 Apr 2013 13:45:23 +1000
Subject: [PATCH] be2net: merge fix for __vlan_put_tag() API change

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 drivers/net/ethernet/emulex/benet/be_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethe=
rnet/emulex/benet/be_main.c
index 768a7d1..d6ab777 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -783,7 +783,7 @@ static struct sk_buff *be_insert_vlan_in_pkt(struct be_=
adapter *adapter,
 	}
=20
 	if (vlan_tag) {
-		skb =3D __vlan_put_tag(skb, vlan_tag);
+		skb =3D __vlan_put_tag(skb, htons(ETH_P_8021Q), vlan_tag);
 		if (unlikely(!skb))
 			return skb;
=20
@@ -793,7 +793,7 @@ static struct sk_buff *be_insert_vlan_in_pkt(struct be_=
adapter *adapter,
 	/* Insert the outer VLAN, if any */
 	if (adapter->qnq_vid) {
 		vlan_tag =3D adapter->qnq_vid;
-		skb =3D __vlan_put_tag(skb, vlan_tag);
+		skb =3D __vlan_put_tag(skb, htons(ETH_P_8021Q), vlan_tag);
 		if (unlikely(!skb))
 			return skb;
 		if (skip_hw_vlan)
--=20
1.8.1

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Fri__26_Apr_2013_13_48_14_+1000_tfNgrNkL5_u/K9uU
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJRefj+AAoJEECxmPOUX5FEyfkP/Ahr0BUlZ/QLZwjK0Mp9MN7w
ifZR+rUPKANkR1B+Szhq79A46UKpYQ4xttkhYlqLJM0p1t7NByS2udUt6OjioNTb
FCD6MKFzB/u7Ye9LLcnIe56C92DJws0cvlx2ky8UuWyR2wHizCXI2iC80+eYbI5J
ZxBCaG9YpHwfAA9wuOL6RRMkOOlt5BUebE9Ip535Y8qnpfNV+9j8mwkagwomRc00
GFkP2r/OpYxqVKAVeZQVE0kwwQp/u600UO5QFEJTypxKUWQ14MBB+UQfM07nggBg
L9HJnC11/ezz2LWRBi37V7FNtDB0tclLstI5lxv2a/NLrfBApkRYJOYAKtqRP1X5
eAQHLVNtH4PxLr+S3sdJTsmDMpxwggdT6VpI+RhTYTSm5nxF4+3f0/H34PWK2Q14
NKLFj8HvKzmb4Zus+wwDJyFojD6iVVJM99GGJjZw379WOvZ4lqfSGNptT5V+oSoZ
xZEsZ7j3xAtqpysNECH288RSnR4JiI5LT/LNoFf724x9sro1Dyd7qhlS7sdYT+Xr
Hbxj6mNXBbHjvroRIY7pgJtn5Sk4+Jr1zxni94HL3pSpWllcm7ExC3yOcl689stq
CwfUCSLLSHHPFd68a/sU+vv3m5E4329uiDuG/xUBRkw1czbDuHBJiNR8WX5Fjsnn
riAN+0dqPjIY+Sse2Diz
=hpJh
-----END PGP SIGNATURE-----

--Signature=_Fri__26_Apr_2013_13_48_14_+1000_tfNgrNkL5_u/K9uU--
