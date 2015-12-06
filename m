From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 1/6] net/mlx4_core: Use both physical ports to set the VF link state
Date: Sun,  6 Dec 2015 18:07:38 +0200
Message-ID: <1449418063-8111-2-git-send-email-ogerlitz@mellanox.com>
References: <1449418063-8111-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Tal Alon <talal@mellanox.com>,
	Majd Dibbiny <majd@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Moni Shoua <monis@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:51565 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753117AbbLFQIJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Dec 2015 11:08:09 -0500
In-Reply-To: <1449418063-8111-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In HA mode, the link state for VFs for which the policy is "auto"
(i.e. follow the physical link state) should be ORed from both ports.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Reviewed-by: Jack Morgenstein <jackm@dev.mellanox.co.il>
---
 drivers/net/ethernet/mellanox/mlx4/fw.c | 12 +++++++++++-
 drivers/net/ethernet/mellanox/mlx4/fw.h |  1 +
 2 files changed, 12 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.c b/drivers/net/ethernet/mellanox/mlx4/fw.c
index 90db94e..2c2baab 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.c
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.c
@@ -1104,6 +1104,7 @@ int mlx4_QUERY_PORT(struct mlx4_dev *dev, int port, struct mlx4_port_cap *port_c
 			goto out;
 
 		MLX4_GET(field, outbox, QUERY_PORT_SUPPORTED_TYPE_OFFSET);
+		port_cap->link_state = (field & 0x80) >> 7;
 		port_cap->supported_port_types = field & 3;
 		port_cap->suggested_type = (field >> 3) & 1;
 		port_cap->default_sense = (field >> 4) & 1;
@@ -1310,6 +1311,15 @@ int mlx4_QUERY_PORT_wrapper(struct mlx4_dev *dev, int slave,
 			port_type |= MLX4_PORT_LINK_UP_MASK;
 		else if (IFLA_VF_LINK_STATE_DISABLE == admin_link_state)
 			port_type &= ~MLX4_PORT_LINK_UP_MASK;
+		else if (IFLA_VF_LINK_STATE_AUTO == admin_link_state && mlx4_is_bonded(dev)) {
+			int other_port = (port == 1) ? 2 : 1;
+			struct mlx4_port_cap port_cap;
+
+			err = mlx4_QUERY_PORT(dev, other_port, &port_cap);
+			if (err)
+				goto out;
+			port_type |= (port_cap.link_state << 7);
+		}
 
 		MLX4_PUT(outbox->buf, port_type,
 			 QUERY_PORT_SUPPORTED_TYPE_OFFSET);
@@ -1325,7 +1335,7 @@ int mlx4_QUERY_PORT_wrapper(struct mlx4_dev *dev, int slave,
 		MLX4_PUT(outbox->buf, short_field,
 			 QUERY_PORT_CUR_MAX_PKEY_OFFSET);
 	}
-
+out:
 	return err;
 }
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/fw.h b/drivers/net/ethernet/mellanox/mlx4/fw.h
index 08de555..7ea258a 100644
--- a/drivers/net/ethernet/mellanox/mlx4/fw.h
+++ b/drivers/net/ethernet/mellanox/mlx4/fw.h
@@ -44,6 +44,7 @@ struct mlx4_mod_stat_cfg {
 };
 
 struct mlx4_port_cap {
+	u8  link_state;
 	u8  supported_port_types;
 	u8  suggested_type;
 	u8  default_sense;
-- 
2.3.7
