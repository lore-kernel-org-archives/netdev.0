From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 1/2] net/mlx4_core: Don't give VFs MAC addresses which are derived from the PF MAC
Date: Thu,  1 Aug 2013 19:55:00 +0300
Message-ID: <1375376101-20435-2-git-send-email-ogerlitz@mellanox.com>
References: <1375376101-20435-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, amirv@mellanox.com,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:45206 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755883Ab3HAQy1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Aug 2013 12:54:27 -0400
In-Reply-To: <1375376101-20435-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the user has not assigned a MAC address to a VM, then don't give it MAC which
is based on the PF one. The current derivation scheme is wrong and leads to VM
MAC collisions when the number of cards/hypervisors becomes big enough.

Instead, just give it zeros and let them figure out what to do with that.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/fw.c |   11 +----------
 1 files changed, 1 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
index 8873d68..6fc6dab 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
@@ -845,16 +845,7 @@ int mlx4_QUERY_PORT_wrapper(struct mlx4_dev *dev, int slave,
 			   MLX4_CMD_NATIVE);
 
 	if (!err && dev->caps.function != slave) {
-		/* if config MAC in DB use it */
-		if (priv->mfunc.master.vf_oper[slave].vport[vhcr->in_modifier].state.mac)
-			def_mac = priv->mfunc.master.vf_oper[slave].vport[vhcr->in_modifier].state.mac;
-		else {
-			/* set slave default_mac address */
-			MLX4_GET(def_mac, outbox->buf, QUERY_PORT_MAC_OFFSET);
-			def_mac += slave << 8;
-			priv->mfunc.master.vf_admin[slave].vport[vhcr->in_modifier].mac = def_mac;
-		}
-
+		def_mac = priv->mfunc.master.vf_oper[slave].vport[vhcr->in_modifier].state.mac;
 		MLX4_PUT(outbox->buf, def_mac, QUERY_PORT_MAC_OFFSET);
 
 		/* get port type - currently only eth is enabled */
-- 
1.7.1
