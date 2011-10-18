From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 1/6 V2] mlx4: Fix vlan table overflow
Date: Tue, 18 Oct 2011 13:50:29 +0200
Message-ID: <4E9D6805.9030205@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog118.obsmtp.com ([207.126.144.145]:37999 "HELO
	eu1sys200aog118.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1757935Ab1JRN6X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2011 09:58:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Prevent overflow when trying to register more Vlans then the Vlan table in
HW is configured to.
Need to take into acount that the first 2 entries are reserved.

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/ethernet/mellanox/mlx4/port.c |   15 ++++++++-------
 1 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/port.c b/drivers/net/ethernet/mellanox/mlx4/port.c
index 609e0ec..163a314 100644
--- a/drivers/net/ethernet/mellanox/mlx4/port.c
+++ b/drivers/net/ethernet/mellanox/mlx4/port.c
@@ -65,7 +65,7 @@ void mlx4_init_vlan_table(struct mlx4_dev *dev, struct mlx4_vlan_table *table)
 		table->entries[i] = 0;
 		table->refs[i]	 = 0;
 	}
-	table->max   = 1 << dev->caps.log_num_vlans;
+	table->max   = (1 << dev->caps.log_num_vlans) - MLX4_VLAN_REGULAR;
 	table->total = 0;
 }
 
@@ -354,6 +354,13 @@ int mlx4_register_vlan(struct mlx4_dev *dev, u8 port, u16 vlan, int *index)
 	int free = -1;
 
 	mutex_lock(&table->mutex);
+
+	if (table->total == table->max) {
+		/* No free vlan entries */
+		err = -ENOSPC;
+		goto out;
+	}
+
 	for (i = MLX4_VLAN_REGULAR; i < MLX4_MAX_VLAN_NUM; i++) {
 		if (free < 0 && (table->refs[i] == 0)) {
 			free = i;
@@ -375,12 +382,6 @@ int mlx4_register_vlan(struct mlx4_dev *dev, u8 port, u16 vlan, int *index)
 		goto out;
 	}
 
-	if (table->total == table->max) {
-		/* No free vlan entries */
-		err = -ENOSPC;
-		goto out;
-	}
-
 	/* Register new MAC */
 	table->refs[free] = 1;
 	table->entries[free] = cpu_to_be32(vlan | MLX4_VLAN_VALID);
-- 
1.7.7
