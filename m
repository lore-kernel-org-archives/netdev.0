From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 4/4] mlx4: Disable HA for SRIOV PF RoCE devices
Date: Wed, 24 Jun 2015 18:22:03 +0300
Message-ID: <1435159323-10028-5-git-send-email-ogerlitz@mellanox.com>
References: <1435159323-10028-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Ido Shamay <idos@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:56567 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752542AbbFXPWe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Jun 2015 11:22:34 -0400
In-Reply-To: <1435159323-10028-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When in HA mode, the driver exposes an IB (RoCE) device instance with only
one port. Under SRIOV, the existing implementation doesn't go well with
the PF RoCE driver's role of Special QPs Para-Virtualization and such.

As such, disable HA for the mlx4 PF RoCE device in SRIOV mode.

Fixes: a57500903093 ('IB/mlx4: Add port aggregation support')
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/intf.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/intf.c b/drivers/net/ethernet/mellanox/mlx4/intf.c
index 6fce587..0d80aed 100644
--- a/drivers/net/ethernet/mellanox/mlx4/intf.c
+++ b/drivers/net/ethernet/mellanox/mlx4/intf.c
@@ -93,8 +93,14 @@ int mlx4_register_interface(struct mlx4_interface *intf)
 	mutex_lock(&intf_mutex);
 
 	list_add_tail(&intf->list, &intf_list);
-	list_for_each_entry(priv, &dev_list, dev_list)
+	list_for_each_entry(priv, &dev_list, dev_list) {
+		if (mlx4_is_mfunc(&priv->dev) && (intf->flags & MLX4_INTFF_BONDING)) {
+			mlx4_dbg(&priv->dev,
+				 "SRIOV, disabling HA mode for intf proto %d\n", intf->protocol);
+			intf->flags &= ~MLX4_INTFF_BONDING;
+		}
 		mlx4_add_device(intf, priv);
+	}
 
 	mutex_unlock(&intf_mutex);
 
-- 
2.3.7
