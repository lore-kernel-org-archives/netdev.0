From: Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH v2 08/11] IB/cma: Separate port allocation to network namespaces
Date: Mon, 20 Apr 2015 12:03:39 +0300
Message-ID: <1429520622-10303-9-git-send-email-haggaie@mellanox.com>
References: <1429520622-10303-1-git-send-email-haggaie@mellanox.com>
Cc: Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Liran Liss <liranl-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Shachar Raindel <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Yotam Kenneth <yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1429520622-10303-1-git-send-email-haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Yotam Kenneth <yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>

Keep a radix-tree for the network namespaces we support for each port-space.
Dynamically allocate idr for network namespace upon first bind request for a
port in the (ps, net) tuple.
Destroy the idr when the (ps, net) tuple does not contain any bounded ports.

This patch is internal infrastructure work for the following patch. In
this patch, init_net is statically used as the network namespace for
the new port-space API.

The radix-tree is protected under the same locking that protects the
rest of the port space data. This locking is practically a big, static
mutex lock for the entire module.

Signed-off-by: Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Yotam Kenneth <yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Shachar Raindel <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
---
 drivers/infiniband/core/cma.c | 122 ++++++++++++++++++++++++++++++++++--------
 1 file changed, 99 insertions(+), 23 deletions(-)

diff --git a/drivers/infiniband/core/cma.c b/drivers/infiniband/core/cma.c
index 1ce84a03c883..022b0d0a51cc 100644
--- a/drivers/infiniband/core/cma.c
+++ b/drivers/infiniband/core/cma.c
@@ -39,11 +39,13 @@
 #include <linux/mutex.h>
 #include <linux/random.h>
 #include <linux/idr.h>
+#include <linux/radix-tree.h>
 #include <linux/inetdevice.h>
 #include <linux/slab.h>
 #include <linux/module.h>
 #include <net/route.h>
 
+#include <net/netns/hash.h>
 #include <net/tcp.h>
 #include <net/ipv6.h>
 
@@ -80,10 +82,83 @@ static LIST_HEAD(dev_list);
 static LIST_HEAD(listen_any_list);
 static DEFINE_MUTEX(lock);
 static struct workqueue_struct *cma_wq;
-static DEFINE_IDR(tcp_ps);
-static DEFINE_IDR(udp_ps);
-static DEFINE_IDR(ipoib_ps);
-static DEFINE_IDR(ib_ps);
+static RADIX_TREE(tcp_ps, GFP_KERNEL);
+static RADIX_TREE(udp_ps, GFP_KERNEL);
+static RADIX_TREE(ipoib_ps, GFP_KERNEL);
+static RADIX_TREE(ib_ps, GFP_KERNEL);
+
+static LIST_HEAD(idrs_list);
+
+struct idr_ll {
+	unsigned net_val;
+	struct net *net;
+	struct radix_tree_root *ps;
+	struct idr idr;
+};
+
+static void zap_ps_idr(struct idr_ll *idr_ll)
+{
+	radix_tree_delete(idr_ll->ps, idr_ll->net_val);
+	idr_destroy(&idr_ll->idr);
+	kfree(idr_ll);
+}
+
+static int cma_ps_alloc(struct radix_tree_root *ps, struct net *net, void *ptr,
+			int snum)
+{
+	struct idr_ll *idr_ll;
+	int err;
+	int res;
+
+	idr_ll = radix_tree_lookup(ps, net_hash_mix(net));
+	if (!idr_ll) {
+		idr_ll = kmalloc(sizeof(*idr_ll), GFP_KERNEL);
+		if (!idr_ll)
+			return -ENOMEM;
+		idr_init(&idr_ll->idr);
+		idr_ll->net_val = net_hash_mix(net);
+		idr_ll->net = net;
+		idr_ll->ps = ps;
+		err = radix_tree_insert(ps, idr_ll->net_val, idr_ll);
+		if (err) {
+			idr_destroy(&idr_ll->idr);
+			kfree(idr_ll);
+			return err;
+		}
+	}
+	res = idr_alloc(&idr_ll->idr, ptr, snum, snum + 1, GFP_KERNEL);
+	if (unlikely((res < 0) && idr_is_empty(&idr_ll->idr))) {
+		zap_ps_idr(idr_ll);
+		return res;
+	}
+	return res;
+}
+
+static void *cma_ps_find(struct radix_tree_root *ps, struct net *net, int snum)
+{
+	struct idr_ll *idr_ll;
+
+	idr_ll = radix_tree_lookup(ps, net_hash_mix(net));
+	if (!idr_ll)
+		return NULL;
+	return idr_find(&idr_ll->idr, snum);
+}
+
+static void cma_ps_remove(struct radix_tree_root *ps, struct net *net, int snum)
+{
+	struct idr_ll *idr_ll;
+
+	idr_ll = radix_tree_lookup(ps, net_hash_mix(net));
+	if (unlikely(!idr_ll)) {
+		WARN(1, "cma_ps_removed can't find expected net ns 0x%lx\n",
+		     (unsigned long)net);
+		return;
+	}
+	idr_remove(&idr_ll->idr, snum);
+	if (idr_is_empty(&idr_ll->idr)) {
+		zap_ps_idr(idr_ll);
+	}
+}
 
 struct cma_device {
 	struct list_head	list;
@@ -94,9 +169,9 @@ struct cma_device {
 };
 
 struct rdma_bind_list {
-	struct idr		*ps;
-	struct hlist_head	owners;
-	unsigned short		port;
+	struct radix_tree_root	*ps;
+	struct hlist_head		owners;
+	unsigned short			port;
 };
 
 enum {
@@ -885,7 +960,7 @@ static void cma_release_port(struct rdma_id_private *id_priv)
 	mutex_lock(&lock);
 	hlist_del(&id_priv->node);
 	if (hlist_empty(&bind_list->owners)) {
-		idr_remove(bind_list->ps, bind_list->port);
+		cma_ps_remove(bind_list->ps, &init_net, bind_list->port);
 		kfree(bind_list);
 	}
 	mutex_unlock(&lock);
@@ -2198,8 +2273,8 @@ static void cma_bind_port(struct rdma_bind_list *bind_list,
 	hlist_add_head(&id_priv->node, &bind_list->owners);
 }
 
-static int cma_alloc_port(struct idr *ps, struct rdma_id_private *id_priv,
-			  unsigned short snum)
+static int cma_alloc_port(struct radix_tree_root *ps,
+			  struct rdma_id_private *id_priv, unsigned short snum)
 {
 	struct rdma_bind_list *bind_list;
 	int ret;
@@ -2208,7 +2283,7 @@ static int cma_alloc_port(struct idr *ps, struct rdma_id_private *id_priv,
 	if (!bind_list)
 		return -ENOMEM;
 
-	ret = idr_alloc(ps, bind_list, snum, snum + 1, GFP_KERNEL);
+	ret = cma_ps_alloc(ps, &init_net, bind_list, snum);
 	if (ret < 0)
 		goto err;
 
@@ -2221,7 +2296,8 @@ err:
 	return ret == -ENOSPC ? -EADDRNOTAVAIL : ret;
 }
 
-static int cma_alloc_any_port(struct idr *ps, struct rdma_id_private *id_priv)
+static int cma_alloc_any_port(struct radix_tree_root *ps,
+			      struct rdma_id_private *id_priv)
 {
 	static unsigned int last_used_port;
 	int low, high, remaining;
@@ -2232,7 +2308,7 @@ static int cma_alloc_any_port(struct idr *ps, struct rdma_id_private *id_priv)
 	rover = prandom_u32() % remaining + low;
 retry:
 	if (last_used_port != rover &&
-	    !idr_find(ps, (unsigned short) rover)) {
+	    !cma_ps_find(ps, &init_net, (unsigned short)rover)) {
 		int ret = cma_alloc_port(ps, id_priv, rover);
 		/*
 		 * Remember previously used port number in order to avoid
@@ -2257,6 +2333,8 @@ retry:
  * bind to a specific port, or when trying to listen on a bound port.  In
  * the latter case, the provided id_priv may already be on the bind_list, but
  * we still need to check that it's okay to start listening.
+ *
+ * Assume the bind_list contains only services from the correct name space.
  */
 static int cma_check_port(struct rdma_bind_list *bind_list,
 			  struct rdma_id_private *id_priv, uint8_t reuseaddr)
@@ -2287,7 +2365,8 @@ static int cma_check_port(struct rdma_bind_list *bind_list,
 	return 0;
 }
 
-static int cma_use_port(struct idr *ps, struct rdma_id_private *id_priv)
+static int cma_use_port(struct radix_tree_root *ps,
+			struct rdma_id_private *id_priv)
 {
 	struct rdma_bind_list *bind_list;
 	unsigned short snum;
@@ -2297,7 +2376,7 @@ static int cma_use_port(struct idr *ps, struct rdma_id_private *id_priv)
 	if (snum < PROT_SOCK && !capable(CAP_NET_BIND_SERVICE))
 		return -EACCES;
 
-	bind_list = idr_find(ps, snum);
+	bind_list = cma_ps_find(ps, &init_net, snum);
 	if (!bind_list) {
 		ret = cma_alloc_port(ps, id_priv, snum);
 	} else {
@@ -2320,7 +2399,8 @@ static int cma_bind_listen(struct rdma_id_private *id_priv)
 	return ret;
 }
 
-static struct idr *cma_select_inet_ps(struct rdma_id_private *id_priv)
+static struct radix_tree_root *cma_select_inet_ps(
+		struct rdma_id_private *id_priv)
 {
 	switch (id_priv->id.ps) {
 	case RDMA_PS_TCP:
@@ -2336,9 +2416,9 @@ static struct idr *cma_select_inet_ps(struct rdma_id_private *id_priv)
 	}
 }
 
-static struct idr *cma_select_ib_ps(struct rdma_id_private *id_priv)
+static struct radix_tree_root *cma_select_ib_ps(struct rdma_id_private *id_priv)
 {
-	struct idr *ps = NULL;
+	struct radix_tree_root *ps = NULL;
 	struct sockaddr_ib *sib;
 	u64 sid_ps, mask, sid;
 
@@ -2369,7 +2449,7 @@ static struct idr *cma_select_ib_ps(struct rdma_id_private *id_priv)
 
 static int cma_get_port(struct rdma_id_private *id_priv)
 {
-	struct idr *ps;
+	struct radix_tree_root *ps;
 	int ret;
 
 	if (cma_family(id_priv) != AF_IB)
@@ -3567,10 +3647,6 @@ static void __exit cma_cleanup(void)
 	rdma_addr_unregister_client(&addr_client);
 	ib_sa_unregister_client(&sa_client);
 	destroy_workqueue(cma_wq);
-	idr_destroy(&tcp_ps);
-	idr_destroy(&udp_ps);
-	idr_destroy(&ipoib_ps);
-	idr_destroy(&ib_ps);
 }
 
 module_init(cma_init);
-- 
1.7.11.2

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
