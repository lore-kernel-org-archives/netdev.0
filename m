From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH V1 net-next 3/8] net/mlx4: Add reference counting to MAC registeration
Date: Thu, 25 Apr 2013 18:22:25 +0300
Message-ID: <1366903350-9096-4-git-send-email-ogerlitz@mellanox.com>
References: <1366903350-9096-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, amirv@mellanox.com,
	Rony Efraim <ronye@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog103.obsmtp.com ([207.126.144.115]:47570 "EHLO
	eu1sys200aog103.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754811Ab3DYPWj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 11:22:39 -0400
In-Reply-To: <1366903350-9096-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rony Efraim <ronye@mellanox.com>

Add reference counting to the driver MAC registeration code. This would
be needed for cases where a mac is registered from more than once, e.g
when both the host and the VM driver register the same mac, the host
for mac spoof protection purposes and the VM for its regular needs.

Signed-off-by: Rony Efraim <ronye@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/port.c |   15 ++++++++++-----
 1 files changed, 10 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/port.c b/drivers/net/ethernet/mellanox/mlx4/port.c
index 4b6aad3..d3408ad 100644
--- a/drivers/net/ethernet/mellanox/mlx4/port.c
+++ b/drivers/net/ethernet/mellanox/mlx4/port.c
@@ -141,8 +141,9 @@ int __mlx4_register_mac(struct mlx4_dev *dev, u8 port, u64 mac)
 		}
 
 		if (mac == (MLX4_MAC_MASK & be64_to_cpu(table->entries[i]))) {
-			/* MAC already registered, Must not have duplicates */
-			err = -EEXIST;
+			/* MAC already registered, increment ref count */
+			err = i;
+			++table->refs[i];
 			goto out;
 		}
 	}
@@ -165,7 +166,7 @@ int __mlx4_register_mac(struct mlx4_dev *dev, u8 port, u64 mac)
 		table->entries[free] = 0;
 		goto out;
 	}
-
+	table->refs[free] = 1;
 	err = free;
 	++table->total;
 out:
@@ -206,12 +207,16 @@ void __mlx4_unregister_mac(struct mlx4_dev *dev, u8 port, u64 mac)
 	struct mlx4_mac_table *table = &info->mac_table;
 	int index;
 
-	index = find_index(dev, table, mac);
-
 	mutex_lock(&table->mutex);
+	index = find_index(dev, table, mac);
 
 	if (validate_index(dev, table, index))
 		goto out;
+	if (--table->refs[index]) {
+		mlx4_dbg(dev, "Have more references for index %d,"
+			 "no need to modify mac table\n", index);
+		goto out;
+	}
 
 	table->entries[index] = 0;
 	mlx4_set_port_mac_table(dev, port, table->entries);
-- 
1.7.1
