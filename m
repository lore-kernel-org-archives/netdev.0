From: David Ahern <dsa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>
Subject: [PATCH net-next 05/11] IB/ipoib: Flip to new dev walk API
Date: Wed, 12 Oct 2016 13:51:53 -0700
Message-ID: <1476305519-28833-6-git-send-email-dsa@cumulusnetworks.com>
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

Convert ipoib_get_net_dev_match_addr to the new upper device walk API.
This is just a move to the new API; no functional change is intended.

Signed-off-by: David Ahern <dsa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>
---
 drivers/infiniband/ulp/ipoib/ipoib_main.c | 37 +++++++++++++++++++++----------
 1 file changed, 25 insertions(+), 12 deletions(-)

diff --git a/drivers/infiniband/ulp/ipoib/ipoib_main.c b/drivers/infiniband/ulp/ipoib/ipoib_main.c
index 5636fc3da6b8..624855ab7205 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_main.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_main.c
@@ -292,6 +292,25 @@ static struct net_device *ipoib_get_master_net_dev(struct net_device *dev)
 	return dev;
 }
 
+struct ipoib_walk_data {
+	const struct sockaddr *addr;
+	struct net_device *result;
+};
+
+static int ipoib_upper_walk(struct net_device *upper, void *_data)
+{
+	struct ipoib_walk_data *data = (struct ipoib_walk_data *)_data;
+	int ret = 0;
+
+	if (ipoib_is_dev_match_addr_rcu(data->addr, upper)) {
+		dev_hold(upper);
+		data->result = upper;
+		ret = 1;
+	}
+
+	return ret;
+}
+
 /**
  * Find a net_device matching the given address, which is an upper device of
  * the given net_device.
@@ -304,27 +323,21 @@ static struct net_device *ipoib_get_master_net_dev(struct net_device *dev)
 static struct net_device *ipoib_get_net_dev_match_addr(
 		const struct sockaddr *addr, struct net_device *dev)
 {
-	struct net_device *upper,
-			  *result = NULL;
-	struct list_head *iter;
+	struct ipoib_walk_data data = {
+		.addr = addr,
+	};
 
 	rcu_read_lock();
 	if (ipoib_is_dev_match_addr_rcu(addr, dev)) {
 		dev_hold(dev);
-		result = dev;
+		data.result = dev;
 		goto out;
 	}
 
-	netdev_for_each_all_upper_dev_rcu(dev, upper, iter) {
-		if (ipoib_is_dev_match_addr_rcu(addr, upper)) {
-			dev_hold(upper);
-			result = upper;
-			break;
-		}
-	}
+	netdev_walk_all_upper_dev_rcu(dev, ipoib_upper_walk, &data);
 out:
 	rcu_read_unlock();
-	return result;
+	return data.result;
 }
 
 /* returns the number of IPoIB netdevs on top a given ipoib device matching a
-- 
2.1.4

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
