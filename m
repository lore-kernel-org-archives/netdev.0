From: Haggai Eran <haggaie@mellanox.com>
Subject: [PATCH v4 for-next 09/12] IB/cma: Separate port allocation to network namespaces
Date: Sun, 17 May 2015 08:51:05 +0300
Message-ID: <1431841868-28063-10-git-send-email-haggaie@mellanox.com>
References: <1431841868-28063-1-git-send-email-haggaie@mellanox.com>
Cc: linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
	Liran Liss <liranl@mellanox.com>,
	Guy Shapiro <guysh@mellanox.com>,
	Shachar Raindel <raindel@mellanox.com>,
	Yotam Kenneth <yotamke@mellanox.com>,
	Haggai Eran <haggaie@mellanox.com>
To: Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1327.ztomy.com ([193.47.165.129]:34491 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751896AbbEQFwW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 May 2015 01:52:22 -0400
In-Reply-To: <1431841868-28063-1-git-send-email-haggaie@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Keep a struct for each network namespace containing the IDRs for the RDMA
CM port spaces. The struct is created dynamically using the generic_net
mechanism.

This patch is internal infrastructure work for the following patches. In
this patch, init_net is statically used as the network namespace for
the new port-space API.

Signed-off-by: Haggai Eran <haggaie@mellanox.com>
Signed-off-by: Yotam Kenneth <yotamke@mellanox.com>
Signed-off-by: Shachar Raindel <raindel@mellanox.com>
Signed-off-by: Guy Shapiro <guysh@mellanox.com>
---
 drivers/infiniband/core/cma.c | 142 +++++++++++++++++++++++++++++++++---------
 1 file changed, 113 insertions(+), 29 deletions(-)

diff --git a/drivers/infiniband/core/cma.c b/drivers/infiniband/core/cma.c
index dced18975e2e..a4645a16c9f9 100644
--- a/drivers/infiniband/core/cma.c
+++ b/drivers/infiniband/core/cma.c
@@ -44,6 +44,8 @@
 #include <linux/module.h>
 #include <net/route.h>
 
+#include <net/net_namespace.h>
+#include <net/netns/generic.h>
 #include <net/tcp.h>
 #include <net/ipv6.h>
 
@@ -80,10 +82,37 @@ static LIST_HEAD(dev_list);
 static LIST_HEAD(listen_any_list);
 static DEFINE_MUTEX(lock);
 static struct workqueue_struct *cma_wq;
-static DEFINE_IDR(tcp_ps);
-static DEFINE_IDR(udp_ps);
-static DEFINE_IDR(ipoib_ps);
-static DEFINE_IDR(ib_ps);
+static int cma_pernet_id;
+
+struct cma_pernet {
+	struct idr tcp_ps;
+	struct idr udp_ps;
+	struct idr ipoib_ps;
+	struct idr ib_ps;
+};
+
+static struct cma_pernet *cma_pernet(struct net *net)
+{
+	return net_generic(net, cma_pernet_id);
+}
+
+static struct idr *cma_pernet_idr(struct net *net, enum rdma_port_space ps)
+{
+	struct cma_pernet *pernet = cma_pernet(net);
+
+	switch (ps) {
+	case RDMA_PS_TCP:
+		return &pernet->tcp_ps;
+	case RDMA_PS_UDP:
+		return &pernet->udp_ps;
+	case RDMA_PS_IPOIB:
+		return &pernet->ipoib_ps;
+	case RDMA_PS_IB:
+		return &pernet->ib_ps;
+	default:
+		return NULL;
+	}
+}
 
 struct cma_device {
 	struct list_head	list;
@@ -94,11 +123,34 @@ struct cma_device {
 };
 
 struct rdma_bind_list {
-	struct idr		*ps;
+	enum rdma_port_space	ps;
 	struct hlist_head	owners;
 	unsigned short		port;
 };
 
+static int cma_ps_alloc(struct net *net, enum rdma_port_space ps,
+			struct rdma_bind_list *bind_list, int snum)
+{
+	struct idr *idr = cma_pernet_idr(net, ps);
+
+	return idr_alloc(idr, bind_list, snum, snum + 1, GFP_KERNEL);
+}
+
+static struct rdma_bind_list *cma_ps_find(struct net *net,
+					  enum rdma_port_space ps, int snum)
+{
+	struct idr *idr = cma_pernet_idr(net, ps);
+
+	return idr_find(idr, snum);
+}
+
+static void cma_ps_remove(struct net *net, enum rdma_port_space ps, int snum)
+{
+	struct idr *idr = cma_pernet_idr(net, ps);
+
+	idr_remove(idr, snum);
+}
+
 enum {
 	CMA_OPTION_AFONLY,
 };
@@ -1027,7 +1079,7 @@ static void cma_release_port(struct rdma_id_private *id_priv)
 	mutex_lock(&lock);
 	hlist_del(&id_priv->node);
 	if (hlist_empty(&bind_list->owners)) {
-		idr_remove(bind_list->ps, bind_list->port);
+		cma_ps_remove(&init_net, bind_list->ps, bind_list->port);
 		kfree(bind_list);
 	}
 	mutex_unlock(&lock);
@@ -2327,8 +2379,8 @@ static void cma_bind_port(struct rdma_bind_list *bind_list,
 	hlist_add_head(&id_priv->node, &bind_list->owners);
 }
 
-static int cma_alloc_port(struct idr *ps, struct rdma_id_private *id_priv,
-			  unsigned short snum)
+static int cma_alloc_port(enum rdma_port_space ps,
+			  struct rdma_id_private *id_priv, unsigned short snum)
 {
 	struct rdma_bind_list *bind_list;
 	int ret;
@@ -2337,7 +2389,7 @@ static int cma_alloc_port(struct idr *ps, struct rdma_id_private *id_priv,
 	if (!bind_list)
 		return -ENOMEM;
 
-	ret = idr_alloc(ps, bind_list, snum, snum + 1, GFP_KERNEL);
+	ret = cma_ps_alloc(&init_net, ps, bind_list, snum);
 	if (ret < 0)
 		goto err;
 
@@ -2350,7 +2402,8 @@ err:
 	return ret == -ENOSPC ? -EADDRNOTAVAIL : ret;
 }
 
-static int cma_alloc_any_port(struct idr *ps, struct rdma_id_private *id_priv)
+static int cma_alloc_any_port(enum rdma_port_space ps,
+			      struct rdma_id_private *id_priv)
 {
 	static unsigned int last_used_port;
 	int low, high, remaining;
@@ -2361,7 +2414,7 @@ static int cma_alloc_any_port(struct idr *ps, struct rdma_id_private *id_priv)
 	rover = prandom_u32() % remaining + low;
 retry:
 	if (last_used_port != rover &&
-	    !idr_find(ps, (unsigned short) rover)) {
+	    !cma_ps_find(&init_net, ps, (unsigned short)rover)) {
 		int ret = cma_alloc_port(ps, id_priv, rover);
 		/*
 		 * Remember previously used port number in order to avoid
@@ -2416,7 +2469,8 @@ static int cma_check_port(struct rdma_bind_list *bind_list,
 	return 0;
 }
 
-static int cma_use_port(struct idr *ps, struct rdma_id_private *id_priv)
+static int cma_use_port(enum rdma_port_space ps,
+			struct rdma_id_private *id_priv)
 {
 	struct rdma_bind_list *bind_list;
 	unsigned short snum;
@@ -2426,7 +2480,7 @@ static int cma_use_port(struct idr *ps, struct rdma_id_private *id_priv)
 	if (snum < PROT_SOCK && !capable(CAP_NET_BIND_SERVICE))
 		return -EACCES;
 
-	bind_list = idr_find(ps, snum);
+	bind_list = cma_ps_find(&init_net, ps, snum);
 	if (!bind_list) {
 		ret = cma_alloc_port(ps, id_priv, snum);
 	} else {
@@ -2449,25 +2503,24 @@ static int cma_bind_listen(struct rdma_id_private *id_priv)
 	return ret;
 }
 
-static struct idr *cma_select_inet_ps(struct rdma_id_private *id_priv)
+static enum rdma_port_space cma_select_inet_ps(
+		struct rdma_id_private *id_priv)
 {
 	switch (id_priv->id.ps) {
 	case RDMA_PS_TCP:
-		return &tcp_ps;
 	case RDMA_PS_UDP:
-		return &udp_ps;
 	case RDMA_PS_IPOIB:
-		return &ipoib_ps;
 	case RDMA_PS_IB:
-		return &ib_ps;
+		return id_priv->id.ps;
 	default:
-		return NULL;
+
+		return 0;
 	}
 }
 
-static struct idr *cma_select_ib_ps(struct rdma_id_private *id_priv)
+static enum rdma_port_space cma_select_ib_ps(struct rdma_id_private *id_priv)
 {
-	struct idr *ps = NULL;
+	enum rdma_port_space ps = 0;
 	struct sockaddr_ib *sib;
 	u64 sid_ps, mask, sid;
 
@@ -2477,15 +2530,15 @@ static struct idr *cma_select_ib_ps(struct rdma_id_private *id_priv)
 
 	if ((id_priv->id.ps == RDMA_PS_IB) && (sid == (RDMA_IB_IP_PS_IB & mask))) {
 		sid_ps = RDMA_IB_IP_PS_IB;
-		ps = &ib_ps;
+		ps = RDMA_PS_IB;
 	} else if (((id_priv->id.ps == RDMA_PS_IB) || (id_priv->id.ps == RDMA_PS_TCP)) &&
 		   (sid == (RDMA_IB_IP_PS_TCP & mask))) {
 		sid_ps = RDMA_IB_IP_PS_TCP;
-		ps = &tcp_ps;
+		ps = RDMA_PS_TCP;
 	} else if (((id_priv->id.ps == RDMA_PS_IB) || (id_priv->id.ps == RDMA_PS_UDP)) &&
 		   (sid == (RDMA_IB_IP_PS_UDP & mask))) {
 		sid_ps = RDMA_IB_IP_PS_UDP;
-		ps = &udp_ps;
+		ps = RDMA_PS_UDP;
 	}
 
 	if (ps) {
@@ -2498,7 +2551,7 @@ static struct idr *cma_select_ib_ps(struct rdma_id_private *id_priv)
 
 static int cma_get_port(struct rdma_id_private *id_priv)
 {
-	struct idr *ps;
+	enum rdma_port_space ps;
 	int ret;
 
 	if (cma_family(id_priv) != AF_IB)
@@ -3647,6 +3700,35 @@ static const struct ibnl_client_cbs cma_cb_table[] = {
 				       .module = THIS_MODULE },
 };
 
+static int cma_init_net(struct net *net)
+{
+	struct cma_pernet *pernet = cma_pernet(net);
+
+	idr_init(&pernet->tcp_ps);
+	idr_init(&pernet->udp_ps);
+	idr_init(&pernet->ipoib_ps);
+	idr_init(&pernet->ib_ps);
+
+	return 0;
+}
+
+static void cma_exit_net(struct net *net)
+{
+	struct cma_pernet *pernet = cma_pernet(net);
+
+	idr_destroy(&pernet->tcp_ps);
+	idr_destroy(&pernet->udp_ps);
+	idr_destroy(&pernet->ipoib_ps);
+	idr_destroy(&pernet->ib_ps);
+}
+
+static struct pernet_operations cma_pernet_operations = {
+	.init = cma_init_net,
+	.exit = cma_exit_net,
+	.id = &cma_pernet_id,
+	.size = sizeof(struct cma_pernet),
+};
+
 static int __init cma_init(void)
 {
 	int ret;
@@ -3655,6 +3737,10 @@ static int __init cma_init(void)
 	if (!cma_wq)
 		return -ENOMEM;
 
+	ret = register_pernet_subsys(&cma_pernet_operations);
+	if (ret)
+		goto err_wq;
+
 	ib_sa_register_client(&sa_client);
 	rdma_addr_register_client(&addr_client);
 	register_netdevice_notifier(&cma_nb);
@@ -3672,6 +3758,7 @@ err:
 	unregister_netdevice_notifier(&cma_nb);
 	rdma_addr_unregister_client(&addr_client);
 	ib_sa_unregister_client(&sa_client);
+err_wq:
 	destroy_workqueue(cma_wq);
 	return ret;
 }
@@ -3683,11 +3770,8 @@ static void __exit cma_cleanup(void)
 	unregister_netdevice_notifier(&cma_nb);
 	rdma_addr_unregister_client(&addr_client);
 	ib_sa_unregister_client(&sa_client);
+	unregister_pernet_subsys(&cma_pernet_operations);
 	destroy_workqueue(cma_wq);
-	idr_destroy(&tcp_ps);
-	idr_destroy(&udp_ps);
-	idr_destroy(&ipoib_ps);
-	idr_destroy(&ib_ps);
 }
 
 module_init(cma_init);
-- 
1.7.11.2
