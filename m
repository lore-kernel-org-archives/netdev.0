From: Yevgeny Petrilin <yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
Subject: [PATCH] mlx4: decreasing ref count when removing mac
Date: Thu, 4 Aug 2011 14:05:12 +0300
Message-ID: <4E3A7CE8.4080407@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
To: <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


For older FW versions, when a Mac address removed from Mac table,
we should set 0 for reference count for the corresponding Mac index.
Fixes a bug where removing Mac from the table still left that entry as
invalid.

Signed-off-by: Yevgeny Petrilin <yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
---
 drivers/net/mlx4/port.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/mlx4/port.c b/drivers/net/mlx4/port.c
index 1f95afd..609e0ec 100644
--- a/drivers/net/mlx4/port.c
+++ b/drivers/net/mlx4/port.c
@@ -258,9 +258,12 @@ void mlx4_unregister_mac(struct mlx4_dev *dev, u8 port, int qpn)
 	if (validate_index(dev, table, index))
 		goto out;
 
-	table->entries[index] = 0;
-	mlx4_set_port_mac_table(dev, port, table->entries);
-	--table->total;
+	/* Check whether this address has reference count */
+	if (!(--table->refs[index])) {
+		table->entries[index] = 0;
+		mlx4_set_port_mac_table(dev, port, table->entries);
+		--table->total;
+	}
 out:
 	mutex_unlock(&table->mutex);
 }
-- 
1.6.0.2

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
