From: Eli Cohen <eli-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
Subject: [PATCH] mlx4_en: show device's port used
Date: Tue, 25 May 2010 16:55:48 +0300
Message-ID: <20100525135548.GA12749@mtldesk030.lab.mtl.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Linux RDMA list <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Roland Dreier <rdreier-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>, yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Add a sysfs file under /sys/class/net/<ethx> to show the port number within the
device that this network interface is using. This is needed as ConnectX devices
have two ports and it is useful to know which port the ethernet devices uses.

Signed-off-by: Eli Cohen <eli-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
---
 drivers/net/mlx4/en_netdev.c |   16 ++++++++++++++++
 1 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/drivers/net/mlx4/en_netdev.c b/drivers/net/mlx4/en_netdev.c
index 73c3d20..5d6f811 100644
--- a/drivers/net/mlx4/en_netdev.c
+++ b/drivers/net/mlx4/en_netdev.c
@@ -871,6 +871,16 @@ err:
 	return -ENOMEM;
 }
 
+static ssize_t show_port(struct device *d, struct device_attribute *attr,
+			 char *buf)
+{
+	struct mlx4_en_priv *priv = netdev_priv(to_net_dev(d));
+
+	return sprintf(buf, "%d\n", priv->port);
+	return 0;
+}
+
+static DEVICE_ATTR(port, S_IRUGO, show_port, NULL);
 
 void mlx4_en_destroy_netdev(struct net_device *dev)
 {
@@ -1067,6 +1077,12 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 	en_warn(priv, "Using %d TX rings\n", prof->tx_ring_num);
 	en_warn(priv, "Using %d RX rings\n", prof->rx_ring_num);
 
+	err = device_create_file(&dev->dev, &dev_attr_port);
+	if (err) {
+		mlx4_err(mdev, "failed to create sysfs file\n");
+		goto out;
+	}
+
 	priv->registered = 1;
 	queue_delayed_work(mdev->workqueue, &priv->stats_task, STATS_DELAY);
 	return 0;
-- 
1.7.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
