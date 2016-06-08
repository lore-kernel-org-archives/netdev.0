From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net/mlx4_en: fix ethtool -x
Date: Tue, 07 Jun 2016 21:24:18 -0700
Message-ID: <1465359858.24873.35.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1464195039-5098-1-git-send-email-edumazet@google.com>
	 <1464195039-5098-5-git-send-email-edumazet@google.com>
	 <6320ccdc-d369-c08c-c959-6c8ed9b88d10@gmail.com>
	 <1464267580.5939.83.camel@edumazet-glaptop3.roam.corp.google.com>
	 <1464979969.5939.200.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>,
	Eric Dumazet <edumazet@google.com>,
	"David S . Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Willem de Bruijn <willemb@google.com>,
	Eugenia Emantayev <eugenia@mellanox.com>,
	Wei Wang <weiwan@google.com>
To: Tariq Toukan <ttoukan.linux@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:36012 "EHLO
	mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751194AbcFHEYV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2016 00:24:21 -0400
Received: by mail-pa0-f68.google.com with SMTP id fg1so15562769pad.3
        for <netdev@vger.kernel.org>; Tue, 07 Jun 2016 21:24:21 -0700 (PDT)
In-Reply-To: <1464979969.5939.200.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <edumazet@google.com>

mlx4 RSS is limited to spread incoming packets to a power of two number
of queues.

An uniformly distibuted traffic would be split on queues 0 to N-1, N
being a power of two, each queue having a 1/N weight.

If number of RX queues is not a power of two, upper RX queues do not
receive traffic.

ethtool -x is lying, because it pretends some queues have higher weight=
=2E

Before patch:

lpaa24:~# ethtool -L eth1 rx 24
lpaa24:~# ethtool -x eth1
RX flow hash indirection table for eth1 with 24 RX ring(s):
    0:      0     1     2     3     4     5     6     7
    8:      8     9    10    11    12    13    14    15
   16:      0     1     2     3     4     5     6     7
RSS hash key:
e0:7c:3a:89:07:55:b6:58:69:cc:f4:e5:24:62:e3:25:88:6c:42:5b:d2:cb:9a:d2=
:e0:06:e1:dc:f9:09:a1:89:0f:a0:30:43:73:6f:0c:b6

If this information was correct, user space tools could expect queues 0
to 7 to receive twice more traffic than queues 8 to 15

After patch :

lpaa24:~# ethtool -L eth1 rx 24
lpaa24:~# ethtool -x eth1     =20
RX flow hash indirection table for eth1 with 24 RX ring(s):
    0:      0     1     2     3     4     5     6     7
    8:      8     9    10    11    12    13    14    15
RSS hash key:
da:7b:09:60:f1:ac:67:b4:d0:72:d4:ec:a2:e5:80:0a:ad:50:22:1a:f8:f9:66:54=
:5f:22:45:c3:88:f4:57:82:c1:c1:90:ed:70:cb:40:ce
lpaa24:~# ethtool -X eth1 equal 8
lpaa24:~# ethtool -x eth1=20
RX flow hash indirection table for eth1 with 24 RX ring(s):
    0:      0     1     2     3     4     5     6     7
    8:      0     1     2     3     4     5     6     7
RSS hash key:
da:7b:09:60:f1:ac:67:b4:d0:72:d4:ec:a2:e5:80:0a:ad:50:22:1a:f8:f9:66:54=
:5f:22:45:c3:88:f4:57:82:c1:c1:90:ed:70:cb:40:ce

Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Maciej =C5=BBenczykowski <maze@google.com>
Cc: Eugenia Emantayev <eugenia@mellanox.com>
Cc: Wei Wang <weiwan@google.com>
Cc: Willem de Bruijn <willemb@google.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c |   25 ++++++--------
 1 file changed, 12 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c b/drivers/=
net/ethernet/mellanox/mlx4/en_ethtool.c
index fc95affaf76b..51a2e8252b82 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
@@ -1107,7 +1107,7 @@ static u32 mlx4_en_get_rxfh_indir_size(struct net=
_device *dev)
 {
 	struct mlx4_en_priv *priv =3D netdev_priv(dev);
=20
-	return priv->rx_ring_num;
+	return rounddown_pow_of_two(priv->rx_ring_num);
 }
=20
 static u32 mlx4_en_get_rxfh_key_size(struct net_device *netdev)
@@ -1141,19 +1141,17 @@ static int mlx4_en_get_rxfh(struct net_device *=
dev, u32 *ring_index, u8 *key,
 			    u8 *hfunc)
 {
 	struct mlx4_en_priv *priv =3D netdev_priv(dev);
-	struct mlx4_en_rss_map *rss_map =3D &priv->rss_map;
-	int rss_rings;
-	size_t n =3D priv->rx_ring_num;
+	u32 n =3D mlx4_en_get_rxfh_indir_size(dev);
+	u32 i, rss_rings;
 	int err =3D 0;
=20
-	rss_rings =3D priv->prof->rss_rings ?: priv->rx_ring_num;
-	rss_rings =3D 1 << ilog2(rss_rings);
+	rss_rings =3D priv->prof->rss_rings ?: n;
+	rss_rings =3D rounddown_pow_of_two(rss_rings);
=20
-	while (n--) {
+	for (i =3D 0; i < n; i++) {
 		if (!ring_index)
 			break;
-		ring_index[n] =3D rss_map->qps[n % rss_rings].qpn -
-			rss_map->base_qpn;
+		ring_index[i] =3D i % rss_rings;
 	}
 	if (key)
 		memcpy(key, priv->rss_key, MLX4_EN_RSS_KEY_SIZE);
@@ -1166,6 +1164,7 @@ static int mlx4_en_set_rxfh(struct net_device *de=
v, const u32 *ring_index,
 			    const u8 *key, const u8 hfunc)
 {
 	struct mlx4_en_priv *priv =3D netdev_priv(dev);
+	u32 n =3D mlx4_en_get_rxfh_indir_size(dev);
 	struct mlx4_en_dev *mdev =3D priv->mdev;
 	int port_up =3D 0;
 	int err =3D 0;
@@ -1175,18 +1174,18 @@ static int mlx4_en_set_rxfh(struct net_device *=
dev, const u32 *ring_index,
 	/* Calculate RSS table size and make sure flows are spread evenly
 	 * between rings
 	 */
-	for (i =3D 0; i < priv->rx_ring_num; i++) {
+	for (i =3D 0; i < n; i++) {
 		if (!ring_index)
-			continue;
+			break;
 		if (i > 0 && !ring_index[i] && !rss_rings)
 			rss_rings =3D i;
=20
-		if (ring_index[i] !=3D (i % (rss_rings ?: priv->rx_ring_num)))
+		if (ring_index[i] !=3D (i % (rss_rings ?: n)))
 			return -EINVAL;
 	}
=20
 	if (!rss_rings)
-		rss_rings =3D priv->rx_ring_num;
+		rss_rings =3D n;
=20
 	/* RSS table size must be an order of 2 */
 	if (!is_power_of_2(rss_rings))
