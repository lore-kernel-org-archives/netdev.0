From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net 2/3] net/mlx4_en: Avoid adding steering rules with invalid ring
Date: Tue,  9 May 2017 14:45:23 +0300
Message-ID: <1494330324-11752-3-git-send-email-tariqt@mellanox.com>
References: <1494330324-11752-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Talat Batheesh <talatb@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:49006 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752999AbdEILpu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 9 May 2017 07:45:50 -0400
In-Reply-To: <1494330324-11752-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Talat Batheesh <talatb@mellanox.com>

Inserting steering rules with illegal ring is an invalid operation,
block it.

Fixes: 820672812f82 ('net/mlx4_en: Manage flow steering rules with ethtool')
Signed-off-by: Talat Batheesh <talatb@mellanox.com>
Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
index ffbcb27c05e5..ae5fdc2df654 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
@@ -1562,6 +1562,11 @@ static int mlx4_en_flow_replace(struct net_device *dev,
 		qpn = priv->drop_qp.qpn;
 	else if (cmd->fs.ring_cookie & EN_ETHTOOL_QP_ATTACH) {
 		qpn = cmd->fs.ring_cookie & (EN_ETHTOOL_QP_ATTACH - 1);
+		if (qpn < priv->rss_map.base_qpn ||
+		    qpn >= priv->rss_map.base_qpn + priv->rx_ring_num) {
+			en_warn(priv, "rxnfc: QP (0x%x) doesn't exist\n", qpn);
+			return -EINVAL;
+		}
 	} else {
 		if (cmd->fs.ring_cookie >= priv->rx_ring_num) {
 			en_warn(priv, "rxnfc: RX ring (%llu) doesn't exist\n",
-- 
1.8.3.1
