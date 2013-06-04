From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 4/4] net/mlx4_core: Keep VF assigned MAC in the PF admin table
Date: Tue,  4 Jun 2013 18:13:29 +0300
Message-ID: <1370358809-7484-5-git-send-email-ogerlitz@mellanox.com>
References: <1370358809-7484-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, amirv@mellanox.com,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:59265 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755786Ab3FDPTO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Jun 2013 11:19:14 -0400
In-Reply-To: <1370358809-7484-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

MAC addresses assigned by the PF to VFs were not kept in the PF driver
admin table. As a result, displaying the VF MACs from the PF interface
to user space showed zero address where in fact the VF got non-zero
address from the PF, fix that.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/fw.c |   10 +++++++---
 1 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
index 58a8e53..2c97901 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
@@ -840,12 +840,16 @@ int mlx4_QUERY_PORT_wrapper(struct mlx4_dev *dev, int slave,
 			   MLX4_CMD_NATIVE);
 
 	if (!err && dev->caps.function != slave) {
-		/* set slave default_mac address */
-		MLX4_GET(def_mac, outbox->buf, QUERY_PORT_MAC_OFFSET);
-		def_mac += slave << 8;
 		/* if config MAC in DB use it */
 		if (priv->mfunc.master.vf_oper[slave].vport[vhcr->in_modifier].state.mac)
 			def_mac = priv->mfunc.master.vf_oper[slave].vport[vhcr->in_modifier].state.mac;
+		else {
+			/* set slave default_mac address */
+			MLX4_GET(def_mac, outbox->buf, QUERY_PORT_MAC_OFFSET);
+			def_mac += slave << 8;
+			priv->mfunc.master.vf_admin[slave].vport[vhcr->in_modifier].mac = def_mac;
+		}
+
 		MLX4_PUT(outbox->buf, def_mac, QUERY_PORT_MAC_OFFSET);
 
 		/* get port type - currently only eth is enabled */
-- 
1.7.1
