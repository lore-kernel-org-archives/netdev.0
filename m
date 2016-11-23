From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] mlx4: do not use priv->stats_lock in
 mlx4_en_auto_moderation()
Date: Wed, 23 Nov 2016 09:46:52 -0800
Message-ID: <1479923212.8455.515.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Tariq Toukan <tariqt@mellanox.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33875 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S938687AbcKWRqz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2016 12:46:55 -0500
Received: by mail-pf0-f193.google.com with SMTP id y68so904357pfb.1
        for <netdev@vger.kernel.org>; Wed, 23 Nov 2016 09:46:54 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Per RX ring packets/bytes counters are not protected by global
priv->stats_lock.

Better not confuse the reader, and use READ_ONCE() to show we read
these counters without surrounding synchronization.

Interrupt moderation is best effort, and we do not really care of
ultra precise counters.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |    6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 9a807e93c9fdd81e61e561208aa1480a244d0bdb..b964bdcd4ae509a7e693215e8b32f040218e252c 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -1391,10 +1391,8 @@ static void mlx4_en_auto_moderation(struct mlx4_en_priv *priv)
 		return;
 
 	for (ring = 0; ring < priv->rx_ring_num; ring++) {
-		spin_lock_bh(&priv->stats_lock);
-		rx_packets = priv->rx_ring[ring]->packets;
-		rx_bytes = priv->rx_ring[ring]->bytes;
-		spin_unlock_bh(&priv->stats_lock);
+		rx_packets = READ_ONCE(priv->rx_ring[ring]->packets);
+		rx_bytes = READ_ONCE(priv->rx_ring[ring]->bytes);
 
 		rx_pkt_diff = ((unsigned long) (rx_packets -
 				priv->last_moder_packets[ring]));
