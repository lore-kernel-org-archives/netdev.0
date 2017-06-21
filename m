From: Leon Romanovsky <leon@kernel.org>
Subject: [PATCH rdma-next 07/19] RDMA/core: Add iterator over ib_devices
Date: Wed, 21 Jun 2017 09:05:16 +0300
Message-ID: <20170621060528.3752-8-leon@kernel.org>
References: <20170621060528.3752-1-leon@kernel.org>
Cc: linux-rdma@vger.kernel.org,
        Chien Tin Tung <chien.tin.tung@intel.com>,
        Steve Wise <swise@opengridcomputing.com>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Jiri Pirko <jiri@mellanox.com>,
        Ariel Almog <ariela@mellanox.com>,
        Linux Netdev <netdev@vger.kernel.org>,
        Leon Romanovsky <leonro@mellanox.com>
To: Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:57780 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751688AbdFUGGA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 21 Jun 2017 02:06:00 -0400
In-Reply-To: <20170621060528.3752-1-leon@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Leon Romanovsky <leonro@mellanox.com>

The coming nldev needs iterate over all IB devices in the system
and in order do not expose the ib_devices list outside the devices.c,
it is necessary to provide function iterator.

Current version is written explicitly for nldev callback to avoid
over-engineering at this stage, but it can be easily extended for
other types.

Signed-off-by: Leon Romanovsky <leonro@mellanox.com>
---
 drivers/infiniband/core/core_priv.h |  8 ++++++++
 drivers/infiniband/core/device.c    | 25 +++++++++++++++++++++++++
 2 files changed, 33 insertions(+)

diff --git a/drivers/infiniband/core/core_priv.h b/drivers/infiniband/core/core_priv.h
index cb7d372e4bdf..4a150c4be175 100644
--- a/drivers/infiniband/core/core_priv.h
+++ b/drivers/infiniband/core/core_priv.h
@@ -92,6 +92,14 @@ void ib_enum_all_roce_netdevs(roce_netdev_filter filter,
 			      roce_netdev_callback cb,
 			      void *cookie);
 
+typedef int (*nldev_callback)(struct ib_device *device,
+			      struct sk_buff *skb,
+			      struct netlink_callback *cb,
+			      unsigned int idx);
+
+int ib_enum_all_devs(nldev_callback nldev_cb, struct sk_buff *skb,
+		     struct netlink_callback *cb);
+
 enum ib_cache_gid_default_mode {
 	IB_CACHE_GID_DEFAULT_MODE_SET,
 	IB_CACHE_GID_DEFAULT_MODE_DELETE
diff --git a/drivers/infiniband/core/device.c b/drivers/infiniband/core/device.c
index 5326dcc6ede7..7a799fc90348 100644
--- a/drivers/infiniband/core/device.c
+++ b/drivers/infiniband/core/device.c
@@ -815,6 +815,31 @@ void ib_enum_all_roce_netdevs(roce_netdev_filter filter,
 }
 
 /**
+ * ib_enum_all_devs - enumerate all ib_devices
+ * @cb: Callback to call for each found ib_device
+ *
+ * Enumerates all ib_devices and calls callback() on each device.
+ */
+int ib_enum_all_devs(nldev_callback nldev_cb, struct sk_buff *skb,
+		     struct netlink_callback *cb)
+{
+	struct ib_device *dev;
+	unsigned int idx = 0;
+	int ret = 0;
+
+	down_read(&lists_rwsem);
+	list_for_each_entry(dev, &device_list, core_list) {
+		ret = nldev_cb(dev, skb, cb, idx);
+		if (ret)
+			break;
+		idx++;
+	}
+
+	up_read(&lists_rwsem);
+	return ret;
+}
+
+/**
  * ib_query_pkey - Get P_Key table entry
  * @device:Device to query
  * @port_num:Port number to query
-- 
2.13.1
