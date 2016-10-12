From: David Ahern <dsa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>
Subject: [PATCH net-next 08/11] rocker: Flip to the new dev walk API
Date: Wed, 12 Oct 2016 13:51:56 -0700
Message-ID: <1476305519-28833-9-git-send-email-dsa@cumulusnetworks.com>
References: <1476305519-28833-1-git-send-email-dsa@cumulusnetworks.com>
Cc: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
        hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        j.vosburgh-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, vfalico-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org,
        jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, intel-wired-lan-qjLDD68F18P21nG7glBr7A@public.gmane.org,
        David Ahern <dsa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>
To: jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1476305519-28833-1-git-send-email-dsa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Convert rocker to the new dev walk API. This is just a code conversion;
no functional change is intended.

Signed-off-by: David Ahern <dsa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>
---
 drivers/net/ethernet/rocker/rocker_main.c | 31 ++++++++++++++++++++++++-------
 1 file changed, 24 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker_main.c b/drivers/net/ethernet/rocker/rocker_main.c
index 5424fb341613..9310adc0bcbb 100644
--- a/drivers/net/ethernet/rocker/rocker_main.c
+++ b/drivers/net/ethernet/rocker/rocker_main.c
@@ -2839,20 +2839,37 @@ static bool rocker_port_dev_check_under(const struct net_device *dev,
 	return true;
 }
 
+struct rocker_walk_data {
+	struct rocker *rocker;
+	struct rocker_port *port;
+};
+
+static int rocker_lower_dev_walk(struct net_device *lower_dev, void *_data)
+{
+	struct rocker_walk_data *data = (struct rocker_walk_data *)_data;
+	int ret = 0;
+
+	if (rocker_port_dev_check_under(lower_dev, data->rocker)) {
+		data->port = netdev_priv(lower_dev);
+		ret = 1;
+	}
+
+	return ret;
+}
+
 struct rocker_port *rocker_port_dev_lower_find(struct net_device *dev,
 					       struct rocker *rocker)
 {
-	struct net_device *lower_dev;
-	struct list_head *iter;
+	struct rocker_walk_data data;
 
 	if (rocker_port_dev_check_under(dev, rocker))
 		return netdev_priv(dev);
 
-	netdev_for_each_all_lower_dev(dev, lower_dev, iter) {
-		if (rocker_port_dev_check_under(lower_dev, rocker))
-			return netdev_priv(lower_dev);
-	}
-	return NULL;
+	data.rocker = rocker;
+	data.port = NULL;
+	netdev_walk_all_lower_dev(dev, rocker_lower_dev_walk, &data);
+
+	return data.port;
 }
 
 static int rocker_netdevice_event(struct notifier_block *unused,
-- 
2.1.4

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
