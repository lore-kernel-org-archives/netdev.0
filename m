From: David Ahern <dsa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>
Subject: [PATCH net-next 04/11] IB/core: Flip to the new dev walk API
Date: Mon, 17 Oct 2016 19:15:46 -0700
Message-ID: <1476756953-30923-5-git-send-email-dsa@cumulusnetworks.com>
References: <1476756953-30923-1-git-send-email-dsa@cumulusnetworks.com>
Cc: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
        hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        j.vosburgh-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, vfalico-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org,
        jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, intel-wired-lan-qjLDD68F18P21nG7glBr7A@public.gmane.org,
        David Ahern <dsa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>
To: jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1476756953-30923-1-git-send-email-dsa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Convert rdma_is_upper_dev_rcu, handle_netdev_upper and
ipoib_get_net_dev_match_addr to the new upper device walk API.
This is just a code conversion; no functional change is intended.

v2
- removed typecast of data

Signed-off-by: David Ahern <dsa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>
---
 drivers/infiniband/core/core_priv.h     |  9 +------
 drivers/infiniband/core/roce_gid_mgmt.c | 42 ++++++++++++++++++---------------
 2 files changed, 24 insertions(+), 27 deletions(-)

diff --git a/drivers/infiniband/core/core_priv.h b/drivers/infiniband/core/core_priv.h
index 19d499dcab76..0c0bea091de8 100644
--- a/drivers/infiniband/core/core_priv.h
+++ b/drivers/infiniband/core/core_priv.h
@@ -127,14 +127,7 @@ void ib_cache_release_one(struct ib_device *device);
 static inline bool rdma_is_upper_dev_rcu(struct net_device *dev,
 					 struct net_device *upper)
 {
-	struct net_device *_upper = NULL;
-	struct list_head *iter;
-
-	netdev_for_each_all_upper_dev_rcu(dev, _upper, iter)
-		if (_upper == upper)
-			break;
-
-	return _upper == upper;
+	return netdev_has_upper_dev_all_rcu(dev, upper);
 }
 
 int addr_init(void);
diff --git a/drivers/infiniband/core/roce_gid_mgmt.c b/drivers/infiniband/core/roce_gid_mgmt.c
index 06556c34606d..3a64a0881882 100644
--- a/drivers/infiniband/core/roce_gid_mgmt.c
+++ b/drivers/infiniband/core/roce_gid_mgmt.c
@@ -437,6 +437,28 @@ static void callback_for_addr_gid_device_scan(struct ib_device *device,
 			  &parsed->gid_attr);
 }
 
+struct upper_list {
+	struct list_head list;
+	struct net_device *upper;
+};
+
+static int netdev_upper_walk(struct net_device *upper, void *data)
+{
+	struct upper_list *entry = kmalloc(sizeof(*entry), GFP_ATOMIC);
+	struct list_head *upper_list = data;
+
+	if (!entry) {
+		pr_info("roce_gid_mgmt: couldn't allocate entry to delete ndev\n");
+		return 0;
+	}
+
+	list_add_tail(&entry->list, upper_list);
+	dev_hold(upper);
+	entry->upper = upper;
+
+	return 0;
+}
+
 static void handle_netdev_upper(struct ib_device *ib_dev, u8 port,
 				void *cookie,
 				void (*handle_netdev)(struct ib_device *ib_dev,
@@ -444,30 +466,12 @@ static void handle_netdev_upper(struct ib_device *ib_dev, u8 port,
 						      struct net_device *ndev))
 {
 	struct net_device *ndev = (struct net_device *)cookie;
-	struct upper_list {
-		struct list_head list;
-		struct net_device *upper;
-	};
-	struct net_device *upper;
-	struct list_head *iter;
 	struct upper_list *upper_iter;
 	struct upper_list *upper_temp;
 	LIST_HEAD(upper_list);
 
 	rcu_read_lock();
-	netdev_for_each_all_upper_dev_rcu(ndev, upper, iter) {
-		struct upper_list *entry = kmalloc(sizeof(*entry),
-						   GFP_ATOMIC);
-
-		if (!entry) {
-			pr_info("roce_gid_mgmt: couldn't allocate entry to delete ndev\n");
-			continue;
-		}
-
-		list_add_tail(&entry->list, &upper_list);
-		dev_hold(upper);
-		entry->upper = upper;
-	}
+	netdev_walk_all_upper_dev_rcu(ndev, netdev_upper_walk, &upper_list);
 	rcu_read_unlock();
 
 	handle_netdev(ib_dev, port, ndev);
-- 
2.1.4

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
