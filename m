From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 2/3] net/mlx4_en: Handle vxlan steering rules for mac address changes
Date: Wed, 12 Mar 2014 17:16:31 +0200
Message-ID: <1394637392-31104-3-git-send-email-ogerlitz@mellanox.com>
References: <1394637392-31104-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, amirv@mellanox.com,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:38640 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754340AbaCLPQi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Mar 2014 11:16:38 -0400
In-Reply-To: <1394637392-31104-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the device mac address is changed, we must deregister the vxlan
steering rule associated with the previous mac, and register a new
steering rule using the new mac.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index fad4531..ba21261 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -742,6 +742,14 @@ static int mlx4_en_replace_mac(struct mlx4_en_priv *priv, int qpn,
 				err = mlx4_en_uc_steer_add(priv, new_mac,
 							   &qpn,
 							   &entry->reg_id);
+				if (err)
+					return err;
+				if (priv->tunnel_reg_id) {
+					mlx4_flow_detach(priv->mdev->dev, priv->tunnel_reg_id);
+					priv->tunnel_reg_id = 0;
+				}
+				err = mlx4_en_tunnel_steer_add(priv, new_mac, qpn,
+							       &priv->tunnel_reg_id);
 				return err;
 			}
 		}
-- 
1.7.1
