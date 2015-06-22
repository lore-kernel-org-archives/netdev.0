From: Haggai Eran <haggaie@mellanox.com>
Subject: [PATCH v1 01/12] IB/core: pass client data to remove() callbacks
Date: Mon, 22 Jun 2015 15:42:30 +0300
Message-ID: <1434976961-27424-2-git-send-email-haggaie@mellanox.com>
References: <1434976961-27424-1-git-send-email-haggaie@mellanox.com>
Cc: linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
	Liran Liss <liranl@mellanox.com>,
	Guy Shapiro <guysh@mellanox.com>,
	Shachar Raindel <raindel@mellanox.com>,
	Yotam Kenneth <yotamke@mellanox.com>,
	Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
	Haggai Eran <haggaie@mellanox.com>
To: Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:52094 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S932390AbbFVMnH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Jun 2015 08:43:07 -0400
In-Reply-To: <1434976961-27424-1-git-send-email-haggaie@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

An ib_client callback that is called with the lists_rwsem locked only for
read is protected from changes to the IB client lists, but not from
ib_unregister_device() freeing its client data. This is because
ib_unregister_device() will remove the device from the device list with
lists_rwsem locked for write, but perform the rest of the cleanup,
including the call to remove() without that lock.

This can cause the remove() callback and the second callback to race when
accessing the private client data.

To solve this, make sure ib_get_client_data() returns NULL before releasing
lists_rwsem in ib_unregister_device(). Since remove() also needs access to
the client data, change the remove callback to accept it as a parameter.

Signed-off-by: Haggai Eran <haggaie@mellanox.com>
---
 drivers/infiniband/core/cache.c           |  2 +-
 drivers/infiniband/core/cm.c              |  7 +++----
 drivers/infiniband/core/cma.c             |  7 +++----
 drivers/infiniband/core/device.c          | 27 +++++++++++++++------------
 drivers/infiniband/core/mad.c             |  2 +-
 drivers/infiniband/core/multicast.c       |  7 +++----
 drivers/infiniband/core/sa_query.c        |  6 +++---
 drivers/infiniband/core/ucm.c             |  6 +++---
 drivers/infiniband/core/user_mad.c        |  6 +++---
 drivers/infiniband/core/uverbs_main.c     |  6 +++---
 drivers/infiniband/ulp/ipoib/ipoib_main.c |  7 +++----
 drivers/infiniband/ulp/srp/ib_srp.c       |  6 +++---
 drivers/infiniband/ulp/srpt/ib_srpt.c     |  5 ++---
 include/rdma/ib_verbs.h                   |  6 +++++-
 net/rds/ib.c                              |  8 ++------
 net/rds/ib_send.c                         |  3 ---
 net/rds/iw.c                              | 11 ++++++-----
 net/rds/iw_cm.c                           | 18 ++++++++++++++----
 net/rds/iw_send.c                         |  4 ++++
 19 files changed, 77 insertions(+), 67 deletions(-)

diff --git a/drivers/infiniband/core/cache.c b/drivers/infiniband/core/cache.c
index 871da832d016..c93af66cc091 100644
--- a/drivers/infiniband/core/cache.c
+++ b/drivers/infiniband/core/cache.c
@@ -394,7 +394,7 @@ err:
 	kfree(device->cache.lmc_cache);
 }
 
-static void ib_cache_cleanup_one(struct ib_device *device)
+static void ib_cache_cleanup_one(struct ib_device *device, void *client_data)
 {
 	int p;
 
diff --git a/drivers/infiniband/core/cm.c b/drivers/infiniband/core/cm.c
index 32063add9280..0103534472e0 100644
--- a/drivers/infiniband/core/cm.c
+++ b/drivers/infiniband/core/cm.c
@@ -58,7 +58,7 @@ MODULE_DESCRIPTION("InfiniBand CM");
 MODULE_LICENSE("Dual BSD/GPL");
 
 static void cm_add_one(struct ib_device *device);
-static void cm_remove_one(struct ib_device *device);
+static void cm_remove_one(struct ib_device *device, void *client_data);
 
 static struct ib_client cm_client = {
 	.name   = "cm",
@@ -3846,9 +3846,9 @@ free:
 	kfree(cm_dev);
 }
 
-static void cm_remove_one(struct ib_device *ib_device)
+static void cm_remove_one(struct ib_device *ib_device, void *client_data)
 {
-	struct cm_device *cm_dev;
+	struct cm_device *cm_dev = client_data;
 	struct cm_port *port;
 	struct ib_port_modify port_modify = {
 		.clr_port_cap_mask = IB_PORT_CM_SUP
@@ -3856,7 +3856,6 @@ static void cm_remove_one(struct ib_device *ib_device)
 	unsigned long flags;
 	int i;
 
-	cm_dev = ib_get_client_data(ib_device, &cm_client);
 	if (!cm_dev)
 		return;
 
diff --git a/drivers/infiniband/core/cma.c b/drivers/infiniband/core/cma.c
index 3b943b700a63..df456b6beb40 100644
--- a/drivers/infiniband/core/cma.c
+++ b/drivers/infiniband/core/cma.c
@@ -94,7 +94,7 @@ const char *rdma_event_msg(enum rdma_cm_event_type event)
 EXPORT_SYMBOL(rdma_event_msg);
 
 static void cma_add_one(struct ib_device *device);
-static void cma_remove_one(struct ib_device *device);
+static void cma_remove_one(struct ib_device *device, void *client_data);
 
 static struct ib_client cma_client = {
 	.name   = "cma",
@@ -3541,11 +3541,10 @@ static void cma_process_remove(struct cma_device *cma_dev)
 	wait_for_completion(&cma_dev->comp);
 }
 
-static void cma_remove_one(struct ib_device *device)
+static void cma_remove_one(struct ib_device *device, void *client_data)
 {
-	struct cma_device *cma_dev;
+	struct cma_device *cma_dev = client_data;
 
-	cma_dev = ib_get_client_data(device, &cma_client);
 	if (!cma_dev)
 		return;
 
diff --git a/drivers/infiniband/core/device.c b/drivers/infiniband/core/device.c
index f08d438205ed..c62974187b5c 100644
--- a/drivers/infiniband/core/device.c
+++ b/drivers/infiniband/core/device.c
@@ -340,7 +340,7 @@ EXPORT_SYMBOL(ib_register_device);
  */
 void ib_unregister_device(struct ib_device *device)
 {
-	struct ib_client *client;
+	struct list_head client_data_list;
 	struct ib_client_data *context, *tmp;
 	unsigned long flags;
 
@@ -348,21 +348,22 @@ void ib_unregister_device(struct ib_device *device)
 
 	down_write(&lists_rwsem);
 	list_del(&device->core_list);
+	spin_lock_irqsave(&device->client_data_lock, flags);
+	list_cut_position(&client_data_list, &device->client_data_list,
+			  device->client_data_list.prev);
+	spin_unlock_irqrestore(&device->client_data_lock, flags);
 	up_write(&lists_rwsem);
 
-	list_for_each_entry_reverse(client, &client_list, list)
-		if (client->remove)
-			client->remove(device);
+	list_for_each_entry_safe(context, tmp, &client_data_list, list) {
+		if (context->client->remove)
+			context->client->remove(device, context->data);
+		kfree(context);
+	}
 
 	mutex_unlock(&device_mutex);
 
 	ib_device_unregister_sysfs(device);
 
-	spin_lock_irqsave(&device->client_data_lock, flags);
-	list_for_each_entry_safe(context, tmp, &device->client_data_list, list)
-		kfree(context);
-	spin_unlock_irqrestore(&device->client_data_lock, flags);
-
 	device->reg_state = IB_DEV_UNREGISTERED;
 }
 EXPORT_SYMBOL(ib_unregister_device);
@@ -412,6 +413,7 @@ void ib_unregister_client(struct ib_client *client)
 {
 	struct ib_client_data *context, *tmp;
 	struct ib_device *device;
+	void *client_data = NULL;
 	unsigned long flags;
 
 	mutex_lock(&device_mutex);
@@ -421,16 +423,17 @@ void ib_unregister_client(struct ib_client *client)
 	up_write(&lists_rwsem);
 
 	list_for_each_entry(device, &device_list, core_list) {
-		if (client->remove)
-			client->remove(device);
-
 		spin_lock_irqsave(&device->client_data_lock, flags);
 		list_for_each_entry_safe(context, tmp, &device->client_data_list, list)
 			if (context->client == client) {
+				client_data = context->data;
 				list_del(&context->list);
 				kfree(context);
 			}
 		spin_unlock_irqrestore(&device->client_data_lock, flags);
+
+		if (client->remove)
+			client->remove(device, client_data);
 	}
 
 	mutex_unlock(&device_mutex);
diff --git a/drivers/infiniband/core/mad.c b/drivers/infiniband/core/mad.c
index a4b1466c1bf6..3341510506d3 100644
--- a/drivers/infiniband/core/mad.c
+++ b/drivers/infiniband/core/mad.c
@@ -3340,7 +3340,7 @@ error:
 	}
 }
 
-static void ib_mad_remove_device(struct ib_device *device)
+static void ib_mad_remove_device(struct ib_device *device, void *client_data)
 {
 	int start, end, i;
 
diff --git a/drivers/infiniband/core/multicast.c b/drivers/infiniband/core/multicast.c
index 1244f02a5c6d..0e0715889768 100644
--- a/drivers/infiniband/core/multicast.c
+++ b/drivers/infiniband/core/multicast.c
@@ -43,7 +43,7 @@
 #include "sa.h"
 
 static void mcast_add_one(struct ib_device *device);
-static void mcast_remove_one(struct ib_device *device);
+static void mcast_remove_one(struct ib_device *device, void *client_data);
 
 static struct ib_client mcast_client = {
 	.name   = "ib_multicast",
@@ -844,13 +844,12 @@ static void mcast_add_one(struct ib_device *device)
 	ib_register_event_handler(&dev->event_handler);
 }
 
-static void mcast_remove_one(struct ib_device *device)
+static void mcast_remove_one(struct ib_device *device, void *client_data)
 {
-	struct mcast_device *dev;
+	struct mcast_device *dev = client_data;
 	struct mcast_port *port;
 	int i;
 
-	dev = ib_get_client_data(device, &mcast_client);
 	if (!dev)
 		return;
 
diff --git a/drivers/infiniband/core/sa_query.c b/drivers/infiniband/core/sa_query.c
index 0fae85062a65..f691be308fc4 100644
--- a/drivers/infiniband/core/sa_query.c
+++ b/drivers/infiniband/core/sa_query.c
@@ -107,7 +107,7 @@ struct ib_sa_mcmember_query {
 };
 
 static void ib_sa_add_one(struct ib_device *device);
-static void ib_sa_remove_one(struct ib_device *device);
+static void ib_sa_remove_one(struct ib_device *device, void *client_data);
 
 static struct ib_client sa_client = {
 	.name   = "sa",
@@ -1225,9 +1225,9 @@ free:
 	return;
 }
 
-static void ib_sa_remove_one(struct ib_device *device)
+static void ib_sa_remove_one(struct ib_device *device, void *client_data)
 {
-	struct ib_sa_device *sa_dev = ib_get_client_data(device, &sa_client);
+	struct ib_sa_device *sa_dev = client_data;
 	int i;
 
 	if (!sa_dev)
diff --git a/drivers/infiniband/core/ucm.c b/drivers/infiniband/core/ucm.c
index 62c24b1452b8..2ce29cd43639 100644
--- a/drivers/infiniband/core/ucm.c
+++ b/drivers/infiniband/core/ucm.c
@@ -109,7 +109,7 @@ enum {
 #define IB_UCM_BASE_DEV MKDEV(IB_UCM_MAJOR, IB_UCM_BASE_MINOR)
 
 static void ib_ucm_add_one(struct ib_device *device);
-static void ib_ucm_remove_one(struct ib_device *device);
+static void ib_ucm_remove_one(struct ib_device *device, void *client_data);
 
 static struct ib_client ucm_client = {
 	.name   = "ucm",
@@ -1310,9 +1310,9 @@ err:
 	return;
 }
 
-static void ib_ucm_remove_one(struct ib_device *device)
+static void ib_ucm_remove_one(struct ib_device *device, void *client_data)
 {
-	struct ib_ucm_device *ucm_dev = ib_get_client_data(device, &ucm_client);
+	struct ib_ucm_device *ucm_dev = client_data;
 
 	if (!ucm_dev)
 		return;
diff --git a/drivers/infiniband/core/user_mad.c b/drivers/infiniband/core/user_mad.c
index 35567fffaa4e..57f281f8d686 100644
--- a/drivers/infiniband/core/user_mad.c
+++ b/drivers/infiniband/core/user_mad.c
@@ -133,7 +133,7 @@ static DEFINE_SPINLOCK(port_lock);
 static DECLARE_BITMAP(dev_map, IB_UMAD_MAX_PORTS);
 
 static void ib_umad_add_one(struct ib_device *device);
-static void ib_umad_remove_one(struct ib_device *device);
+static void ib_umad_remove_one(struct ib_device *device, void *client_data);
 
 static void ib_umad_release_dev(struct kobject *kobj)
 {
@@ -1322,9 +1322,9 @@ free:
 	kobject_put(&umad_dev->kobj);
 }
 
-static void ib_umad_remove_one(struct ib_device *device)
+static void ib_umad_remove_one(struct ib_device *device, void *client_data)
 {
-	struct ib_umad_device *umad_dev = ib_get_client_data(device, &umad_client);
+	struct ib_umad_device *umad_dev = client_data;
 	int i;
 
 	if (!umad_dev)
diff --git a/drivers/infiniband/core/uverbs_main.c b/drivers/infiniband/core/uverbs_main.c
index f6eef2da7097..46c92294afa5 100644
--- a/drivers/infiniband/core/uverbs_main.c
+++ b/drivers/infiniband/core/uverbs_main.c
@@ -128,7 +128,7 @@ static int (*uverbs_ex_cmd_table[])(struct ib_uverbs_file *file,
 };
 
 static void ib_uverbs_add_one(struct ib_device *device);
-static void ib_uverbs_remove_one(struct ib_device *device);
+static void ib_uverbs_remove_one(struct ib_device *device, void *client_data);
 
 static void ib_uverbs_release_dev(struct kref *ref)
 {
@@ -948,9 +948,9 @@ err:
 	return;
 }
 
-static void ib_uverbs_remove_one(struct ib_device *device)
+static void ib_uverbs_remove_one(struct ib_device *device, void *client_data)
 {
-	struct ib_uverbs_device *uverbs_dev = ib_get_client_data(device, &uverbs_client);
+	struct ib_uverbs_device *uverbs_dev = client_data;
 
 	if (!uverbs_dev)
 		return;
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_main.c b/drivers/infiniband/ulp/ipoib/ipoib_main.c
index da149c278cb8..d128432f226d 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_main.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_main.c
@@ -89,7 +89,7 @@ struct workqueue_struct *ipoib_workqueue;
 struct ib_sa_client ipoib_sa_client;
 
 static void ipoib_add_one(struct ib_device *device);
-static void ipoib_remove_one(struct ib_device *device);
+static void ipoib_remove_one(struct ib_device *device, void *client_data);
 static void ipoib_neigh_reclaim(struct rcu_head *rp);
 
 static struct ib_client ipoib_client = {
@@ -1720,12 +1720,11 @@ static void ipoib_add_one(struct ib_device *device)
 	ib_set_client_data(device, &ipoib_client, dev_list);
 }
 
-static void ipoib_remove_one(struct ib_device *device)
+static void ipoib_remove_one(struct ib_device *device, void *client_data)
 {
 	struct ipoib_dev_priv *priv, *tmp;
-	struct list_head *dev_list;
+	struct list_head *dev_list = client_data;
 
-	dev_list = ib_get_client_data(device, &ipoib_client);
 	if (!dev_list)
 		return;
 
diff --git a/drivers/infiniband/ulp/srp/ib_srp.c b/drivers/infiniband/ulp/srp/ib_srp.c
index eada8f758ad4..335bdf53670e 100644
--- a/drivers/infiniband/ulp/srp/ib_srp.c
+++ b/drivers/infiniband/ulp/srp/ib_srp.c
@@ -131,7 +131,7 @@ MODULE_PARM_DESC(ch_count,
 		 "Number of RDMA channels to use for communication with an SRP target. Using more than one channel improves performance if the HCA supports multiple completion vectors. The default value is the minimum of four times the number of online CPU sockets and the number of completion vectors supported by the HCA.");
 
 static void srp_add_one(struct ib_device *device);
-static void srp_remove_one(struct ib_device *device);
+static void srp_remove_one(struct ib_device *device, void *client_data);
 static void srp_recv_completion(struct ib_cq *cq, void *ch_ptr);
 static void srp_send_completion(struct ib_cq *cq, void *ch_ptr);
 static int srp_cm_handler(struct ib_cm_id *cm_id, struct ib_cm_event *event);
@@ -3471,13 +3471,13 @@ free_attr:
 	kfree(dev_attr);
 }
 
-static void srp_remove_one(struct ib_device *device)
+static void srp_remove_one(struct ib_device *device, void *client_data)
 {
 	struct srp_device *srp_dev;
 	struct srp_host *host, *tmp_host;
 	struct srp_target_port *target;
 
-	srp_dev = ib_get_client_data(device, &srp_client);
+	srp_dev = client_data;
 	if (!srp_dev)
 		return;
 
diff --git a/drivers/infiniband/ulp/srpt/ib_srpt.c b/drivers/infiniband/ulp/srpt/ib_srpt.c
index 0b2857b1b112..54da6e8ddfa1 100644
--- a/drivers/infiniband/ulp/srpt/ib_srpt.c
+++ b/drivers/infiniband/ulp/srpt/ib_srpt.c
@@ -3335,12 +3335,11 @@ err:
 /**
  * srpt_remove_one() - InfiniBand device removal callback function.
  */
-static void srpt_remove_one(struct ib_device *device)
+static void srpt_remove_one(struct ib_device *device, void *client_data)
 {
-	struct srpt_device *sdev;
+	struct srpt_device *sdev = client_data;
 	int i;
 
-	sdev = ib_get_client_data(device, &srpt_client);
 	if (!sdev) {
 		pr_info("%s(%s): nothing to do.\n", __func__, device->name);
 		return;
diff --git a/include/rdma/ib_verbs.h b/include/rdma/ib_verbs.h
index 986fddb08579..1767a11e86fd 100644
--- a/include/rdma/ib_verbs.h
+++ b/include/rdma/ib_verbs.h
@@ -1760,7 +1760,7 @@ struct ib_device {
 struct ib_client {
 	char  *name;
 	void (*add)   (struct ib_device *);
-	void (*remove)(struct ib_device *);
+	void (*remove)(struct ib_device *, void *client_data);
 
 	struct list_head list;
 };
@@ -1776,6 +1776,10 @@ void ib_unregister_device(struct ib_device *device);
 int ib_register_client   (struct ib_client *client);
 void ib_unregister_client(struct ib_client *client);
 
+/* Returns the client data stored by ib_set_client_data, or NULL if the data
+ * is not available.
+ *
+ * May return NULL before the call to ib_client.remove(). */
 void *ib_get_client_data(struct ib_device *device, struct ib_client *client);
 void  ib_set_client_data(struct ib_device *device, struct ib_client *client,
 			 void *data);
diff --git a/net/rds/ib.c b/net/rds/ib.c
index ba2dffeff608..e005aeff1f7d 100644
--- a/net/rds/ib.c
+++ b/net/rds/ib.c
@@ -230,19 +230,15 @@ struct rds_ib_device *rds_ib_get_client_data(struct ib_device *device)
  *
  * This can be called at any time and can be racing with any other RDS path.
  */
-static void rds_ib_remove_one(struct ib_device *device)
+static void rds_ib_remove_one(struct ib_device *device, void *client_data)
 {
-	struct rds_ib_device *rds_ibdev;
+	struct rds_ib_device *rds_ibdev = client_data;
 
-	rds_ibdev = ib_get_client_data(device, &rds_ib_client);
 	if (!rds_ibdev)
 		return;
 
 	rds_ib_dev_shutdown(rds_ibdev);
 
-	/* stop connection attempts from getting a reference to this device. */
-	ib_set_client_data(device, &rds_ib_client, NULL);
-
 	down_write(&rds_ib_devices_lock);
 	list_del_rcu(&rds_ibdev->list);
 	up_write(&rds_ib_devices_lock);
diff --git a/net/rds/ib_send.c b/net/rds/ib_send.c
index 5d0a704fa039..a0b600a6e44d 100644
--- a/net/rds/ib_send.c
+++ b/net/rds/ib_send.c
@@ -759,14 +759,11 @@ int rds_ib_xmit_atomic(struct rds_connection *conn, struct rm_atomic_op *op)
 	struct rds_ib_connection *ic = conn->c_transport_data;
 	struct rds_ib_send_work *send = NULL;
 	struct ib_send_wr *failed_wr;
-	struct rds_ib_device *rds_ibdev;
 	u32 pos;
 	u32 work_alloc;
 	int ret;
 	int nr_sig = 0;
 
-	rds_ibdev = ib_get_client_data(ic->i_cm_id->device, &rds_ib_client);
-
 	work_alloc = rds_ib_ring_alloc(&ic->i_send_ring, 1, &pos);
 	if (work_alloc != 1) {
 		rds_ib_ring_unalloc(&ic->i_send_ring, work_alloc);
diff --git a/net/rds/iw.c b/net/rds/iw.c
index 589935661d66..3ebd7fbb8b7a 100644
--- a/net/rds/iw.c
+++ b/net/rds/iw.c
@@ -125,12 +125,11 @@ free_attr:
 	kfree(dev_attr);
 }
 
-static void rds_iw_remove_one(struct ib_device *device)
+static void rds_iw_remove_one(struct ib_device *device, void *client_data)
 {
-	struct rds_iw_device *rds_iwdev;
+	struct rds_iw_device *rds_iwdev = client_data;
 	struct rds_iw_cm_id *i_cm_id, *next;
 
-	rds_iwdev = ib_get_client_data(device, &rds_iw_client);
 	if (!rds_iwdev)
 		return;
 
@@ -192,8 +191,10 @@ static int rds_iw_conn_info_visitor(struct rds_connection *conn,
 		rds_iwdev = ib_get_client_data(ic->i_cm_id->device, &rds_iw_client);
 		iinfo->max_send_wr = ic->i_send_ring.w_nr;
 		iinfo->max_recv_wr = ic->i_recv_ring.w_nr;
-		iinfo->max_send_sge = rds_iwdev->max_sge;
-		rds_iw_get_mr_info(rds_iwdev, iinfo);
+		if (rds_iwdev) {
+			iinfo->max_send_sge = rds_iwdev->max_sge;
+			rds_iw_get_mr_info(rds_iwdev, iinfo);
+		}
 	}
 	return 1;
 }
diff --git a/net/rds/iw_cm.c b/net/rds/iw_cm.c
index 8f486fa32079..8837131c14b0 100644
--- a/net/rds/iw_cm.c
+++ b/net/rds/iw_cm.c
@@ -85,10 +85,13 @@ void rds_iw_cm_connect_complete(struct rds_connection *conn, struct rdma_cm_even
 
 	/* update ib_device with this local ipaddr & conn */
 	rds_iwdev = ib_get_client_data(ic->i_cm_id->device, &rds_iw_client);
-	err = rds_iw_update_cm_id(rds_iwdev, ic->i_cm_id);
-	if (err)
-		printk(KERN_ERR "rds_iw_update_ipaddr failed (%d)\n", err);
-	rds_iw_add_conn(rds_iwdev, conn);
+	if (rds_iwdev) {
+		err = rds_iw_update_cm_id(rds_iwdev, ic->i_cm_id);
+		if (err)
+			printk(KERN_ERR "rds_iw_update_ipaddr failed (%d)\n",
+			       err);
+		rds_iw_add_conn(rds_iwdev, conn);
+	}
 
 	/* If the peer gave us the last packet it saw, process this as if
 	 * we had received a regular ACK. */
@@ -445,6 +448,8 @@ int rds_iw_cm_handle_connect(struct rdma_cm_id *cm_id,
 	cm_id->context = conn;
 
 	rds_iwdev = ib_get_client_data(cm_id->device, &rds_iw_client);
+	if (!rds_iwdev)
+		goto out;
 	ic->i_dma_local_lkey = rds_iwdev->dma_local_lkey;
 
 	/* We got halfway through setting up the ib_connection, if we
@@ -549,6 +554,11 @@ int rds_iw_conn_connect(struct rds_connection *conn)
 	}
 
 	rds_iwdev = ib_get_client_data(ic->i_cm_id->device, &rds_iw_client);
+	if (!rds_iwdev) {
+		rdma_destroy_id(ic->i_cm_id);
+		ic->i_cm_id = NULL;
+		goto out;
+	}
 	ic->i_dma_local_lkey = rds_iwdev->dma_local_lkey;
 
 	dest.sin_family = AF_INET;
diff --git a/net/rds/iw_send.c b/net/rds/iw_send.c
index 334fe98c5084..f3944a1ca76c 100644
--- a/net/rds/iw_send.c
+++ b/net/rds/iw_send.c
@@ -809,6 +809,10 @@ int rds_iw_xmit_rdma(struct rds_connection *conn, struct rm_rdma_op *op)
 	int num_sge;
 
 	rds_iwdev = ib_get_client_data(ic->i_cm_id->device, &rds_iw_client);
+	if (!rds_iwdev) {
+		ret = -ENODEV;
+		goto out;
+	}
 
 	/* map the message the first time we see it */
 	if (!op->op_mapped) {
-- 
1.7.11.2
