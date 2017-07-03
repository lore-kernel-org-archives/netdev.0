From: Leon Romanovsky <leon@kernel.org>
Subject: [PATCH rdma-next V2 08/27] RDMA/core: Add and expose static device index
Date: Mon,  3 Jul 2017 09:28:11 +0300
Message-ID: <20170703062830.30361-9-leon@kernel.org>
References: <20170703062830.30361-1-leon@kernel.org>
Cc: linux-rdma@vger.kernel.org,
        Stephen Hemminger <stephen@networkplumber.org>,
        Ariel Almog <ariela@mellanox.com>,
        Linux Netdev <netdev@vger.kernel.org>,
        Leon Romanovsky <leonro@mellanox.com>
To: Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:59396 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751902AbdGCG3M (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 3 Jul 2017 02:29:12 -0400
In-Reply-To: <20170703062830.30361-1-leon@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Leon Romanovsky <leonro@mellanox.com>

This patch adds static device index in similar fashion to
already available in netdev world (struct net->ifindex).

In downstream patches, the RDMA nelink will use this idx-to-ib_device
conversion, so as part of this commit, we are exposing the translation
function to be visible for IB/core users.

Signed-off-by: Leon Romanovsky <leonro@mellanox.com>
---
 drivers/infiniband/core/core_priv.h |  4 ++++
 drivers/infiniband/core/device.c    | 37 ++++++++++++++++++++++++++++++++++++-
 include/rdma/ib_verbs.h             |  2 ++
 3 files changed, 42 insertions(+), 1 deletion(-)

diff --git a/drivers/infiniband/core/core_priv.h b/drivers/infiniband/core/core_priv.h
index 8cc7a844eb01..8733c26258b2 100644
--- a/drivers/infiniband/core/core_priv.h
+++ b/drivers/infiniband/core/core_priv.h
@@ -194,4 +194,8 @@ int ib_nl_handle_set_timeout(struct sk_buff *skb,
 int ib_nl_handle_ip_res_resp(struct sk_buff *skb,
 			     struct netlink_callback *cb);
 
+struct ib_device *__ib_device_get_by_index(u32 ifindex);
+/* RDMA device netlink */
+void nldev_init(void);
+void nldev_exit(void);
 #endif /* _CORE_PRIV_H */
diff --git a/drivers/infiniband/core/device.c b/drivers/infiniband/core/device.c
index 7a799fc90348..7ff65d766d86 100644
--- a/drivers/infiniband/core/device.c
+++ b/drivers/infiniband/core/device.c
@@ -124,6 +124,17 @@ static int ib_device_check_mandatory(struct ib_device *device)
 	return 0;
 }
 
+struct ib_device *__ib_device_get_by_index(u32 index)
+{
+	struct ib_device *device;
+
+	list_for_each_entry(device, &device_list, core_list)
+		if (device->index == index)
+			return device;
+
+	return NULL;
+}
+
 static struct ib_device *__ib_device_get_by_name(const char *name)
 {
 	struct ib_device *device;
@@ -135,7 +146,6 @@ static struct ib_device *__ib_device_get_by_name(const char *name)
 	return NULL;
 }
 
-
 static int alloc_name(char *name)
 {
 	unsigned long *inuse;
@@ -326,6 +336,30 @@ void ib_get_device_fw_str(struct ib_device *dev, char *str, size_t str_len)
 EXPORT_SYMBOL(ib_get_device_fw_str);
 
 /**
+ *	__dev_new_index	-	allocate an device index
+ *
+ *	Returns a suitable unique value for a new device interface
+ *	number.  It assumes that there are less than 2^32-1 ib devices
+ *	will be present in the system.
+ */
+static u32 __dev_new_index(void)
+{
+	/*
+	 * The device index to allow stable naming.
+	 * Similar to struct net -> ifindex.
+	 */
+	static u32 index;
+
+	for (;;) {
+		if (!(++index))
+			index = 1;
+
+		if (!__ib_device_get_by_index(index))
+			return index;
+	}
+}
+
+/**
  * ib_register_device - Register an IB device with IB core
  * @device:Device to register
  *
@@ -417,6 +451,7 @@ int ib_register_device(struct ib_device *device,
 		if (client->add && !add_client_context(device, client))
 			client->add(device);
 
+	device->index = __dev_new_index();
 	down_write(&lists_rwsem);
 	list_add_tail(&device->core_list, &device_list);
 	up_write(&lists_rwsem);
diff --git a/include/rdma/ib_verbs.h b/include/rdma/ib_verbs.h
index ba8314ec5768..b73120727d60 100644
--- a/include/rdma/ib_verbs.h
+++ b/include/rdma/ib_verbs.h
@@ -2237,6 +2237,8 @@ struct ib_device {
 	struct rdmacg_device         cg_device;
 #endif
 
+	u32                          index;
+
 	/**
 	 * The following mandatory functions are used only at device
 	 * registration.  Keep functions such as these at the end of this
-- 
2.13.2
