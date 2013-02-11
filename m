From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the akpm tree
Date: Mon, 11 Feb 2013 18:13:32 +1100
Message-ID: <20130211181332.ecf1cad33b04b3872b685620@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Mon__11_Feb_2013_18_13_32_+1100_Jyg6Hq9XwyxGdTPj"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Yan Burman <yanb@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Sasha Levin <sasha.levin@oracle.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Mon__11_Feb_2013_18_13_32_+1100_Jyg6Hq9XwyxGdTPj
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

After merging the akpm tree, today's linux-next build (powerpc
ppc64_defconfig) failed like this:

drivers/net/ethernet/mellanox/mlx4/en_rx.c: In function 'mlx4_en_process_rx=
_cq':
drivers/net/ethernet/mellanox/mlx4/en_rx.c:628:53: error: macro "hlist_for_=
each_entry_rcu" passed 4 arguments, but takes just 3
drivers/net/ethernet/mellanox/mlx4/en_rx.c:628:5: error: 'hlist_for_each_en=
try_rcu' undeclared (first use in this function)
drivers/net/ethernet/mellanox/mlx4/en_rx.c:628:55: error: expected ';' befo=
re '{' token

Caused by commit c07cb4b0ab78 ("net/mlx4_en: Manage hash of MAC addresses
per port") from the net-next tree interacting with commit "hlist: drop
the node parameter from iterators" from the akpm tree.

I applied the following merge fix patch for today:

=46rom 7a10f5e7e8d1232d618307d568ea9a78dc4680bb Mon Sep 17 00:00:00 2001
From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Mon, 11 Feb 2013 18:01:23 +1100
Subject: [PATCH] net/mlx4_en: fix up for hlist_for_each_entry_rcu API change

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 drivers/net/ethernet/mellanox/mlx4/en_rx.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ether=
net/mellanox/mlx4/en_rx.c
index ce38654..19a9c05 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -617,7 +617,6 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struc=
t mlx4_en_cq *cq, int bud
=20
 			if (is_multicast_ether_addr(ethh->h_dest)) {
 				struct mlx4_mac_entry *entry;
-				struct hlist_node *n;
 				struct hlist_head *bucket;
 				unsigned int mac_hash;
=20
@@ -625,7 +624,7 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struc=
t mlx4_en_cq *cq, int bud
 				mac_hash =3D ethh->h_source[MLX4_EN_MAC_HASH_IDX];
 				bucket =3D &priv->mac_hash[mac_hash];
 				rcu_read_lock();
-				hlist_for_each_entry_rcu(entry, n, bucket, hlist) {
+				hlist_for_each_entry_rcu(entry, bucket, hlist) {
 					if (ether_addr_equal_64bits(entry->mac,
 								    ethh->h_source)) {
 						rcu_read_unlock();
--=20
1.8.1

That then lead to these:

drivers/net/ethernet/mellanox/mlx4/en_netdev.c: In function 'mlx4_en_put_qp=
':
drivers/net/ethernet/mellanox/mlx4/en_netdev.c:582:57: error: macro "hlist_=
for_each_entry_safe" passed 5 arguments, but takes just 4
drivers/net/ethernet/mellanox/mlx4/en_netdev.c:582:3: error: 'hlist_for_eac=
h_entry_safe' undeclared (first use in this function)
drivers/net/ethernet/mellanox/mlx4/en_netdev.c:582:59: error: expected ';' =
before '{' token
drivers/net/ethernet/mellanox/mlx4/en_netdev.c: In function 'mlx4_en_replac=
e_mac':
drivers/net/ethernet/mellanox/mlx4/en_netdev.c:615:57: error: macro "hlist_=
for_each_entry_safe" passed 5 arguments, but takes just 4
drivers/net/ethernet/mellanox/mlx4/en_netdev.c:615:3: error: 'hlist_for_eac=
h_entry_safe' undeclared (first use in this function)
drivers/net/ethernet/mellanox/mlx4/en_netdev.c:615:59: error: expected ';' =
before '{' token
drivers/net/ethernet/mellanox/mlx4/en_netdev.c: In function 'mlx4_en_do_uc_=
filter':
drivers/net/ethernet/mellanox/mlx4/en_netdev.c:1037:57: error: macro "hlist=
_for_each_entry_safe" passed 5 arguments, but takes just 4
drivers/net/ethernet/mellanox/mlx4/en_netdev.c:1037:3: error: 'hlist_for_ea=
ch_entry_safe' undeclared (first use in this function)
drivers/net/ethernet/mellanox/mlx4/en_netdev.c:1037:59: error: expected ';'=
 before '{' token
drivers/net/ethernet/mellanox/mlx4/en_netdev.c:1080:47: error: macro "hlist=
_for_each_entry" passed 4 arguments, but takes just 3
drivers/net/ethernet/mellanox/mlx4/en_netdev.c:1080:3: error: 'hlist_for_ea=
ch_entry' undeclared (first use in this function)
drivers/net/ethernet/mellanox/mlx4/en_netdev.c:1080:49: error: expected ';'=
 before '{' token

For which I applied this:

=46rom 8b8154323c7a63c29bb2d7613742ca2bb417efc3 Mon Sep 17 00:00:00 2001
From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Mon, 11 Feb 2013 18:10:36 +1100
Subject: [PATCH] net/mlx4_en: second fix up for hlist_for_each_entry_rcu API
 change

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/e=
thernet/mellanox/mlx4/en_netdev.c
index 77c4f55..bb53a72 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -573,13 +573,13 @@ static void mlx4_en_put_qp(struct mlx4_en_priv *priv)
=20
 	if (dev->caps.steering_mode !=3D MLX4_STEERING_MODE_A0) {
 		struct mlx4_mac_entry *entry;
-		struct hlist_node *n, *tmp;
+		struct hlist_node *tmp;
 		struct hlist_head *bucket;
 		unsigned int mac_hash;
=20
 		mac_hash =3D priv->dev->dev_addr[MLX4_EN_MAC_HASH_IDX];
 		bucket =3D &priv->mac_hash[mac_hash];
-		hlist_for_each_entry_safe(entry, n, tmp, bucket, hlist) {
+		hlist_for_each_entry_safe(entry, tmp, bucket, hlist) {
 			if (ether_addr_equal_64bits(entry->mac,
 						    priv->dev->dev_addr)) {
 				en_dbg(DRV, priv, "Releasing qp: port %d, MAC %pM, qpn %d\n",
@@ -608,11 +608,11 @@ static int mlx4_en_replace_mac(struct mlx4_en_priv *p=
riv, int qpn,
 		struct hlist_head *bucket;
 		unsigned int mac_hash;
 		struct mlx4_mac_entry *entry;
-		struct hlist_node *n, *tmp;
+		struct hlist_node *tmp;
 		u64 prev_mac_u64 =3D mlx4_en_mac_to_u64(prev_mac);
=20
 		bucket =3D &priv->mac_hash[prev_mac[MLX4_EN_MAC_HASH_IDX]];
-		hlist_for_each_entry_safe(entry, n, tmp, bucket, hlist) {
+		hlist_for_each_entry_safe(entry, tmp, bucket, hlist) {
 			if (ether_addr_equal_64bits(entry->mac, prev_mac)) {
 				mlx4_en_uc_steer_release(priv, entry->mac,
 							 qpn, entry->reg_id);
@@ -1018,7 +1018,7 @@ static void mlx4_en_do_uc_filter(struct mlx4_en_priv =
*priv,
 {
 	struct netdev_hw_addr *ha;
 	struct mlx4_mac_entry *entry;
-	struct hlist_node *n, *tmp;
+	struct hlist_node *tmp;
 	bool found;
 	u64 mac;
 	int err =3D 0;
@@ -1034,7 +1034,7 @@ static void mlx4_en_do_uc_filter(struct mlx4_en_priv =
*priv,
 	/* find what to remove */
 	for (i =3D 0; i < MLX4_EN_MAC_HASH_SIZE; ++i) {
 		bucket =3D &priv->mac_hash[i];
-		hlist_for_each_entry_safe(entry, n, tmp, bucket, hlist) {
+		hlist_for_each_entry_safe(entry, tmp, bucket, hlist) {
 			found =3D false;
 			netdev_for_each_uc_addr(ha, dev) {
 				if (ether_addr_equal_64bits(entry->mac,
@@ -1077,7 +1077,7 @@ static void mlx4_en_do_uc_filter(struct mlx4_en_priv =
*priv,
 	netdev_for_each_uc_addr(ha, dev) {
 		found =3D false;
 		bucket =3D &priv->mac_hash[ha->addr[MLX4_EN_MAC_HASH_IDX]];
-		hlist_for_each_entry(entry, n, bucket, hlist) {
+		hlist_for_each_entry(entry, bucket, hlist) {
 			if (ether_addr_equal_64bits(entry->mac, ha->addr)) {
 				found =3D true;
 				break;
--=20
1.8.1

I will add these to the end of the akpm tree tomorrow.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Mon__11_Feb_2013_18_13_32_+1100_Jyg6Hq9XwyxGdTPj
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJRGJocAAoJEECxmPOUX5FEJKcP/0AHsdc6vU/1M/E6+PxNxWie
Qm/T0CXkwq4LKsglY3dm4RUXrjC+PUOtCFU+IcUfNDya+7hwn4uVqWEx4CMI1Vh6
jvzKSXWG0Dc59lnGk9xgWErPcJF82CO/ttazoqFR59dpYSQvsj53BP2MV0jssgvG
areNlVE7Elu76a5EkVBMrub9XY8W2PPGiRY5VqUI/hsWxOgmJuAClBAdhW3YiwiP
CsF3zawdX43bWoY1FNK1/YDZUnW2jpXrHhuUn20pLLjPgNwNVV4C4kyI92efcMf3
lxDla/vfEAoCUaKo15suIBgqrauyyOaTT8jutXaQeAirlUoYgHMpECjkGqh9jImY
zMZ4EefcvxEp2N/lNhUX0l8VVihW48by62S449ajvWqrpgDO8bCMXUI4Mg02VAro
M8/UjZzvninGZlrOdpdC70d+Z7XygEeKdQBX7ETTVioeKDhN08DFRzilP7KNhuJT
bBmE09ANjDVJmdbOHq3DntQzLtPWk2QmmqxOLNT/eVOoraOIrSc/3nKCKWvl7gdG
+P9+a6Gdr4Wvn6U+vtMdL1v6MoxxTqU1mgdwYv/7+AqP/fHc9EEZ3lQJ9kwZIRB+
tTzsZh/l6+Kn+ir+1G3VaVztACiNs1MOfTvbcgiEo5T+ZPbXP8fq+hhU9Wk1RE1o
evOqXt4MOJCCbJrAnv2p
=MXYs
-----END PGP SIGNATURE-----

--Signature=_Mon__11_Feb_2013_18_13_32_+1100_Jyg6Hq9XwyxGdTPj--
