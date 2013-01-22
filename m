From: sean.hefty@intel.com
Subject: [PATCH v4 3/9] ib/addr: Add AF_IB support to ip_addr_size
Date: Tue, 22 Jan 2013 13:56:31 -0800
Message-ID: <1358891797-14625-4-git-send-email-sean.hefty@intel.com>
References: <1358891797-14625-1-git-send-email-sean.hefty@intel.com>
Cc: Sean Hefty <sean.hefty@intel.com>
To: linux-rdma@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:38023 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753233Ab3AVV5K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jan 2013 16:57:10 -0500
In-Reply-To: <1358891797-14625-1-git-send-email-sean.hefty@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sean Hefty <sean.hefty@intel.com>

Add support for AF_IB to ip_addr_size, and rename the function
to account for the change.  Give the compiler more control over
whether the call should be inline or not by moving the definition
into the .c file, removing the static inline, and exporting it.

Signed-off-by: Sean Hefty <sean.hefty@intel.com>
---
 drivers/infiniband/core/addr.c |   20 ++++++++++++++++++--
 drivers/infiniband/core/cma.c  |   12 ++++++------
 include/rdma/ib_addr.h         |    6 +-----
 3 files changed, 25 insertions(+), 13 deletions(-)

diff --git a/drivers/infiniband/core/addr.c b/drivers/infiniband/core/addr.c
index eaec8d7..e90f2b2 100644
--- a/drivers/infiniband/core/addr.c
+++ b/drivers/infiniband/core/addr.c
@@ -45,6 +45,7 @@
 #include <net/addrconf.h>
 #include <net/ip6_route.h>
 #include <rdma/ib_addr.h>
+#include <rdma/ib.h>
 
 MODULE_AUTHOR("Sean Hefty");
 MODULE_DESCRIPTION("IB Address Translation");
@@ -70,6 +71,21 @@ static LIST_HEAD(req_list);
 static DECLARE_DELAYED_WORK(work, process_req);
 static struct workqueue_struct *addr_wq;
 
+int rdma_addr_size(struct sockaddr *addr)
+{
+	switch (addr->sa_family) {
+	case AF_INET:
+		return sizeof(struct sockaddr_in);
+	case AF_INET6:
+		return sizeof(struct sockaddr_in6);
+	case AF_IB:
+		return sizeof(struct sockaddr_ib);
+	default:
+		return 0;
+	}
+}
+EXPORT_SYMBOL(rdma_addr_size);
+
 void rdma_addr_register_client(struct rdma_addr_client *client)
 {
 	atomic_set(&client->refcount, 1);
@@ -369,12 +385,12 @@ int rdma_resolve_ip(struct rdma_addr_client *client,
 			goto err;
 		}
 
-		memcpy(src_in, src_addr, ip_addr_size(src_addr));
+		memcpy(src_in, src_addr, rdma_addr_size(src_addr));
 	} else {
 		src_in->sa_family = dst_addr->sa_family;
 	}
 
-	memcpy(dst_in, dst_addr, ip_addr_size(dst_addr));
+	memcpy(dst_in, dst_addr, rdma_addr_size(dst_addr));
 	req->addr = addr;
 	req->callback = callback;
 	req->context = context;
diff --git a/drivers/infiniband/core/cma.c b/drivers/infiniband/core/cma.c
index 9e3dc7f..e08f830 100644
--- a/drivers/infiniband/core/cma.c
+++ b/drivers/infiniband/core/cma.c
@@ -1584,7 +1584,7 @@ static void cma_listen_on_dev(struct rdma_id_private *id_priv,
 
 	dev_id_priv->state = RDMA_CM_ADDR_BOUND;
 	memcpy(&id->route.addr.src_addr, &id_priv->id.route.addr.src_addr,
-	       ip_addr_size((struct sockaddr *) &id_priv->id.route.addr.src_addr));
+	       rdma_addr_size((struct sockaddr *) &id_priv->id.route.addr.src_addr));
 
 	cma_attach_to_dev(dev_id_priv, cma_dev);
 	list_add_tail(&dev_id_priv->listen_list, &id_priv->listen_list);
@@ -1989,7 +1989,7 @@ static void addr_handler(int status, struct sockaddr *src_addr,
 		event.status = status;
 	} else {
 		memcpy(&id_priv->id.route.addr.src_addr, src_addr,
-		       ip_addr_size(src_addr));
+		       rdma_addr_size(src_addr));
 		event.event = RDMA_CM_EVENT_ADDR_RESOLVED;
 	}
 
@@ -2079,7 +2079,7 @@ int rdma_resolve_addr(struct rdma_cm_id *id, struct sockaddr *src_addr,
 		return -EINVAL;
 
 	atomic_inc(&id_priv->refcount);
-	memcpy(&id->route.addr.dst_addr, dst_addr, ip_addr_size(dst_addr));
+	memcpy(&id->route.addr.dst_addr, dst_addr, rdma_addr_size(dst_addr));
 	if (cma_any_addr(dst_addr))
 		ret = cma_resolve_loopback(id_priv);
 	else
@@ -2410,7 +2410,7 @@ int rdma_bind_addr(struct rdma_cm_id *id, struct sockaddr *addr)
 			goto err1;
 	}
 
-	memcpy(&id->route.addr.src_addr, addr, ip_addr_size(addr));
+	memcpy(&id->route.addr.src_addr, addr, rdma_addr_size(addr));
 	if (!(id_priv->options & (1 << CMA_OPTION_AFONLY))) {
 		if (addr->sa_family == AF_INET)
 			id_priv->afonly = 1;
@@ -3189,7 +3189,7 @@ int rdma_join_multicast(struct rdma_cm_id *id, struct sockaddr *addr,
 	if (!mc)
 		return -ENOMEM;
 
-	memcpy(&mc->addr, addr, ip_addr_size(addr));
+	memcpy(&mc->addr, addr, rdma_addr_size(addr));
 	mc->context = context;
 	mc->id_priv = id_priv;
 
@@ -3234,7 +3234,7 @@ void rdma_leave_multicast(struct rdma_cm_id *id, struct sockaddr *addr)
 	id_priv = container_of(id, struct rdma_id_private, id);
 	spin_lock_irq(&id_priv->lock);
 	list_for_each_entry(mc, &id_priv->mc_list, list) {
-		if (!memcmp(&mc->addr, addr, ip_addr_size(addr))) {
+		if (!memcmp(&mc->addr, addr, rdma_addr_size(addr))) {
 			list_del(&mc->list);
 			spin_unlock_irq(&id_priv->lock);
 
diff --git a/include/rdma/ib_addr.h b/include/rdma/ib_addr.h
index 9996539..f3ac0f2 100644
--- a/include/rdma/ib_addr.h
+++ b/include/rdma/ib_addr.h
@@ -102,11 +102,7 @@ void rdma_addr_cancel(struct rdma_dev_addr *addr);
 int rdma_copy_addr(struct rdma_dev_addr *dev_addr, struct net_device *dev,
 	      const unsigned char *dst_dev_addr);
 
-static inline int ip_addr_size(struct sockaddr *addr)
-{
-	return addr->sa_family == AF_INET6 ?
-	       sizeof(struct sockaddr_in6) : sizeof(struct sockaddr_in);
-}
+int rdma_addr_size(struct sockaddr *addr);
 
 static inline u16 ib_addr_get_pkey(struct rdma_dev_addr *dev_addr)
 {
-- 
1.7.3
