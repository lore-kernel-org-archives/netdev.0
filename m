From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 04/11] IB/core: Flip to the new dev walk API
Date: Wed, 12 Oct 2016 13:51:52 -0700
Message-ID: <1476305519-28833-5-git-send-email-dsa@cumulusnetworks.com>
References: <1476305519-28833-1-git-send-email-dsa@cumulusnetworks.com>
Cc: dledford@redhat.com, sean.hefty@intel.com,
        hal.rosenstock@gmail.com, linux-rdma@vger.kernel.org,
        j.vosburgh@gmail.com, vfalico@gmail.com, andy@greyhouse.net,
        jeffrey.t.kirsher@intel.com, intel-wired-lan@lists.osuosl.org,
        David Ahern <dsa@cumulusnetworks.com>
To: jiri@mellanox.com, netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:33167 "EHLO
        mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934192AbcJLUwO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Oct 2016 16:52:14 -0400
Received: by mail-pf0-f175.google.com with SMTP id 128so23973211pfz.0
        for <netdev@vger.kernel.org>; Wed, 12 Oct 2016 13:52:13 -0700 (PDT)
In-Reply-To: <1476305519-28833-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert rdma_is_upper_dev_rcu, handle_netdev_upper and
ipoib_get_net_dev_match_addr to the new upper device walk API.
This is just a move to the new API; no functional change is intended.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
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
index 06556c34606d..db759a68d948 100644
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
+	struct list_head *upper_list = (struct list_head *)data;
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
