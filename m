From: Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 07/11] IB/cma: Helper functions to access port space IDRs
Date: Mon, 15 Jun 2015 11:47:12 +0300
Message-ID: <1434358036-15526-8-git-send-email-haggaie@mellanox.com>
References: <1434358036-15526-1-git-send-email-haggaie@mellanox.com>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Liran Liss <liranl-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Shachar Raindel <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Yotam Kenneth <yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>,
	Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1434358036-15526-1-git-send-email-haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Add helper functions to access the IDRs by port-space and port number.

Pass around the port-space enum in cma.c instead of using pointers to
port-space IDRs.

Signed-off-by: Haggai Eran <haggaie-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Yotam Kenneth <yotamke-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Shachar Raindel <raindel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Guy Shapiro <guysh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
---
 drivers/infiniband/core/cma.c | 81 ++++++++++++++++++++++++++++++++-----------
 1 file changed, 60 insertions(+), 21 deletions(-)

diff --git a/drivers/infiniband/core/cma.c b/drivers/infiniband/core/cma.c
index bc061987485d..bb90d462f819 100644
--- a/drivers/infiniband/core/cma.c
+++ b/drivers/infiniband/core/cma.c
@@ -113,6 +113,22 @@ static DEFINE_IDR(udp_ps);
 static DEFINE_IDR(ipoib_ps);
 static DEFINE_IDR(ib_ps);
 
+static struct idr *cma_idr(enum rdma_port_space ps)
+{
+	switch (ps) {
+	case RDMA_PS_TCP:
+		return &tcp_ps;
+	case RDMA_PS_UDP:
+		return &udp_ps;
+	case RDMA_PS_IPOIB:
+		return &ipoib_ps;
+	case RDMA_PS_IB:
+		return &ib_ps;
+	default:
+		return NULL;
+	}
+}
+
 struct cma_device {
 	struct list_head	list;
 	struct ib_device	*device;
@@ -122,11 +138,33 @@ struct cma_device {
 };
 
 struct rdma_bind_list {
-	struct idr		*ps;
+	enum rdma_port_space	ps;
 	struct hlist_head	owners;
 	unsigned short		port;
 };
 
+static int cma_ps_alloc(enum rdma_port_space ps,
+			struct rdma_bind_list *bind_list, int snum)
+{
+	struct idr *idr = cma_idr(ps);
+
+	return idr_alloc(idr, bind_list, snum, snum + 1, GFP_KERNEL);
+}
+
+static struct rdma_bind_list *cma_ps_find(enum rdma_port_space ps, int snum)
+{
+	struct idr *idr = cma_idr(ps);
+
+	return idr_find(idr, snum);
+}
+
+static void cma_ps_remove(enum rdma_port_space ps, int snum)
+{
+	struct idr *idr = cma_idr(ps);
+
+	idr_remove(idr, snum);
+}
+
 enum {
 	CMA_OPTION_AFONLY,
 };
@@ -1053,7 +1091,7 @@ static void cma_release_port(struct rdma_id_private *id_priv)
 	mutex_lock(&lock);
 	hlist_del(&id_priv->node);
 	if (hlist_empty(&bind_list->owners)) {
-		idr_remove(bind_list->ps, bind_list->port);
+		cma_ps_remove(bind_list->ps, bind_list->port);
 		kfree(bind_list);
 	}
 	mutex_unlock(&lock);
@@ -2349,8 +2387,8 @@ static void cma_bind_port(struct rdma_bind_list *bind_list,
 	hlist_add_head(&id_priv->node, &bind_list->owners);
 }
 
-static int cma_alloc_port(struct idr *ps, struct rdma_id_private *id_priv,
-			  unsigned short snum)
+static int cma_alloc_port(enum rdma_port_space ps,
+			  struct rdma_id_private *id_priv, unsigned short snum)
 {
 	struct rdma_bind_list *bind_list;
 	int ret;
@@ -2359,7 +2397,7 @@ static int cma_alloc_port(struct idr *ps, struct rdma_id_private *id_priv,
 	if (!bind_list)
 		return -ENOMEM;
 
-	ret = idr_alloc(ps, bind_list, snum, snum + 1, GFP_KERNEL);
+	ret = cma_ps_alloc(ps, bind_list, snum);
 	if (ret < 0)
 		goto err;
 
@@ -2372,7 +2410,8 @@ err:
 	return ret == -ENOSPC ? -EADDRNOTAVAIL : ret;
 }
 
-static int cma_alloc_any_port(struct idr *ps, struct rdma_id_private *id_priv)
+static int cma_alloc_any_port(enum rdma_port_space ps,
+			      struct rdma_id_private *id_priv)
 {
 	static unsigned int last_used_port;
 	int low, high, remaining;
@@ -2383,7 +2422,7 @@ static int cma_alloc_any_port(struct idr *ps, struct rdma_id_private *id_priv)
 	rover = prandom_u32() % remaining + low;
 retry:
 	if (last_used_port != rover &&
-	    !idr_find(ps, (unsigned short) rover)) {
+	    !cma_ps_find(ps, (unsigned short)rover)) {
 		int ret = cma_alloc_port(ps, id_priv, rover);
 		/*
 		 * Remember previously used port number in order to avoid
@@ -2438,7 +2477,8 @@ static int cma_check_port(struct rdma_bind_list *bind_list,
 	return 0;
 }
 
-static int cma_use_port(struct idr *ps, struct rdma_id_private *id_priv)
+static int cma_use_port(enum rdma_port_space ps,
+			struct rdma_id_private *id_priv)
 {
 	struct rdma_bind_list *bind_list;
 	unsigned short snum;
@@ -2448,7 +2488,7 @@ static int cma_use_port(struct idr *ps, struct rdma_id_private *id_priv)
 	if (snum < PROT_SOCK && !capable(CAP_NET_BIND_SERVICE))
 		return -EACCES;
 
-	bind_list = idr_find(ps, snum);
+	bind_list = cma_ps_find(ps, snum);
 	if (!bind_list) {
 		ret = cma_alloc_port(ps, id_priv, snum);
 	} else {
@@ -2471,25 +2511,24 @@ static int cma_bind_listen(struct rdma_id_private *id_priv)
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
 
@@ -2499,15 +2538,15 @@ static struct idr *cma_select_ib_ps(struct rdma_id_private *id_priv)
 
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
@@ -2520,7 +2559,7 @@ static struct idr *cma_select_ib_ps(struct rdma_id_private *id_priv)
 
 static int cma_get_port(struct rdma_id_private *id_priv)
 {
-	struct idr *ps;
+	enum rdma_port_space ps;
 	int ret;
 
 	if (cma_family(id_priv) != AF_IB)
-- 
1.7.11.2

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
