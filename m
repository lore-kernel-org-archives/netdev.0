From: kxie@chelsio.com
Subject: [PATCH 3/4] cxgb3i: fixed connection over vlan
Date: Thu, 23 Sep 2010 16:43:23 -0700
Message-ID: <201009232343.o8NNhN9e006465@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rranjan@chelsio.com, kxie@chelsio.com,
	James.Bottomley@HansenPartnership.com, michaelc@cs.wisc.edu,
	davem@davemloft.net
To: netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	open-iscsi@googlegroups.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:15952 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751844Ab0IWXne (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Sep 2010 19:43:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[PATCH 3/4] cxgb3i: fixed connection over vlan
          
From: Karen Xie <kxie@chelsio.com>
          
This patch fixed the problem of connecting over VLAN.

Signed-off-by: Karen Xie <kxie@chelsio.com>
---

 drivers/scsi/cxgbi/cxgb3i/cxgb3i.c |   47 +++++++++++++++++++++++++++++++-----
 drivers/scsi/cxgbi/libcxgbi.c      |   37 ++++++----------------------
 drivers/scsi/cxgbi/libcxgbi.h      |    1 +
 3 files changed, 49 insertions(+), 36 deletions(-)


diff --git a/drivers/scsi/cxgbi/cxgb3i/cxgb3i.c b/drivers/scsi/cxgbi/cxgb3i/cxgb3i.c
index a2c207f..a129a17 100644
--- a/drivers/scsi/cxgbi/cxgb3i/cxgb3i.c
+++ b/drivers/scsi/cxgbi/cxgb3i/cxgb3i.c
@@ -589,9 +589,10 @@ static int do_act_open_rpl(struct t3cdev *tdev, struct sk_buff *skb, void *ctx)
 	struct cxgbi_sock *csk = ctx;
 	struct cpl_act_open_rpl *rpl = cplhdr(skb);
 
-	log_debug(1 << CXGBI_DBG_TOE | 1 << CXGBI_DBG_SOCK,
-		"csk 0x%p,%u,0x%lx,%u, status %u.\n",
-		csk, csk->state, csk->flags, csk->atid, rpl->status);
+	pr_info("csk 0x%p,%u,0x%lx,%u, status %u, %pI4:%u-%pI4:%u.\n",
+		csk, csk->state, csk->flags, csk->atid, rpl->status,
+		&csk->saddr.sin_addr.s_addr, ntohs(csk->saddr.sin_port),
+		&csk->daddr.sin_addr.s_addr, ntohs(csk->daddr.sin_port));
 
 	if (rpl->status != CPL_ERR_TCAM_FULL &&
 	    rpl->status != CPL_ERR_CONN_EXIST &&
@@ -662,8 +663,7 @@ static int abort_status_to_errno(struct cxgbi_sock *csk, int abort_reason,
 	switch (abort_reason) {
 	case CPL_ERR_BAD_SYN: /* fall through */
 	case CPL_ERR_CONN_RESET:
-		return csk->state > CTP_ESTABLISHED ?
-			-EPIPE : -ECONNRESET;
+		return csk->state > CTP_ESTABLISHED ? -EPIPE : -ECONNRESET;
 	case CPL_ERR_XMIT_TIMEDOUT:
 	case CPL_ERR_PERSIST_TIMEDOUT:
 	case CPL_ERR_FINWAIT2_TIMEDOUT:
@@ -945,17 +945,44 @@ static void release_offload_resources(struct cxgbi_sock *csk)
 	csk->cdev = NULL;
 }
 
+static void update_address(struct cxgbi_hba *chba)
+{
+	if (chba->ipv4addr) {
+		if (chba->vdev &&
+		    chba->ipv4addr != cxgb3i_get_private_ipv4addr(chba->vdev)) {
+			cxgb3i_set_private_ipv4addr(chba->vdev, chba->ipv4addr);
+			cxgb3i_set_private_ipv4addr(chba->ndev, 0);
+			pr_info("%s set %pI4.\n",
+				chba->vdev->name, &chba->ipv4addr);
+		} else if (chba->ipv4addr !=
+				cxgb3i_get_private_ipv4addr(chba->ndev)) {
+			cxgb3i_set_private_ipv4addr(chba->ndev, chba->ipv4addr);
+			pr_info("%s set %pI4.\n",
+				chba->ndev->name, &chba->ipv4addr);
+		}
+	} else if (cxgb3i_get_private_ipv4addr(chba->ndev)) {
+		if (chba->vdev)
+			cxgb3i_set_private_ipv4addr(chba->vdev, 0);
+		cxgb3i_set_private_ipv4addr(chba->ndev, 0);
+	}
+}
+
 static int init_act_open(struct cxgbi_sock *csk)
 {
 	struct dst_entry *dst = csk->dst;
 	struct cxgbi_device *cdev = csk->cdev;
 	struct t3cdev *t3dev = (struct t3cdev *)cdev->lldev;
 	struct net_device *ndev = cdev->ports[csk->port_id];
+	struct cxgbi_hba *chba = cdev->hbas[csk->port_id];
 	struct sk_buff *skb = NULL;
 
 	log_debug(1 << CXGBI_DBG_TOE | 1 << CXGBI_DBG_SOCK,
 		"csk 0x%p,%u,0x%lx.\n", csk, csk->state, csk->flags);
 
+	update_address(chba);
+	if (chba->ipv4addr)
+		csk->saddr.sin_addr.s_addr = chba->ipv4addr;
+
 	csk->rss_qid = 0;
 	csk->l2t = t3_l2t_get(t3dev, dst->neighbour, ndev);
 	if (!csk->l2t) {
@@ -984,6 +1011,12 @@ static int init_act_open(struct cxgbi_sock *csk)
 	cxgbi_sock_reset_wr_list(csk);
 	csk->err = 0;
 
+	log_debug(1 << CXGBI_DBG_TOE | 1 << CXGBI_DBG_SOCK,
+		"csk 0x%p,%u,0x%lx, %pI4:%u-%pI4:%u.\n",
+		csk, csk->state, csk->flags,
+		&csk->saddr.sin_addr.s_addr, ntohs(csk->saddr.sin_port),
+		&csk->daddr.sin_addr.s_addr, ntohs(csk->daddr.sin_port));
+
 	cxgbi_sock_set_state(csk, CTP_ACTIVE_OPEN);
 	send_act_open_req(csk, skb, csk->l2t);
 	return 0;
@@ -1143,9 +1176,9 @@ static int ddp_alloc_gl_skb(struct cxgbi_ddp_info *ddp, int idx,
 	for (i = 0; i < cnt; i++) {
 		struct sk_buff *skb = alloc_wr(sizeof(struct ulp_mem_io) +
 						PPOD_SIZE, 0, gfp);
-		if (skb) {
+		if (skb)
 			ddp->gl_skb[idx + i] = skb;
-		} else {
+		else {
 			ddp_free_gl_skb(ddp, idx, i);
 			return -ENOMEM;
 		}
diff --git a/drivers/scsi/cxgbi/libcxgbi.c b/drivers/scsi/cxgbi/libcxgbi.c
index 7136fb2..f3fab74 100644
--- a/drivers/scsi/cxgbi/libcxgbi.c
+++ b/drivers/scsi/cxgbi/libcxgbi.c
@@ -195,16 +195,22 @@ EXPORT_SYMBOL_GPL(cxgbi_device_find_by_lldev);
 static struct cxgbi_device *cxgbi_device_find_by_netdev(struct net_device *ndev,
 							int *port)
 {
+	struct net_device *vdev = NULL;
 	struct cxgbi_device *cdev, *tmp;
 	int i;
 
-	if (ndev->priv_flags & IFF_802_1Q_VLAN)
+	if (ndev->priv_flags & IFF_802_1Q_VLAN) {
+		vdev = ndev;
 		ndev = vlan_dev_real_dev(ndev);
+		log_debug(1 << CXGBI_DBG_DEV,
+			"vlan dev %s -> %s.\n", vdev->name, ndev->name);
+	}
 
 	mutex_lock(&cdev_mutex);
 	list_for_each_entry_safe(cdev, tmp, &cdev_list, list_head) {
 		for (i = 0; i < cdev->nports; i++) {
 			if (ndev == cdev->ports[i]) {
+				cdev->hbas[i]->vdev = vdev;
 				mutex_unlock(&cdev_mutex);
 				if (port)
 					*port = i;
@@ -218,24 +224,6 @@ static struct cxgbi_device *cxgbi_device_find_by_netdev(struct net_device *ndev,
 	return NULL;
 }
 
-struct cxgbi_hba *cxgbi_hba_find_by_netdev(struct net_device *dev,
-					struct cxgbi_device *cdev)
-{
-	int i;
-
-	if (dev->priv_flags & IFF_802_1Q_VLAN)
-		dev = vlan_dev_real_dev(dev);
-
-	for (i = 0; i < cdev->nports; i++) {
-		if (cdev->hbas[i]->ndev == dev)
-			return cdev->hbas[i];
-	}
-	log_debug(1 << CXGBI_DBG_DEV,
-		"ndev 0x%p, %s, cdev 0x%p, NO match found.\n",
-		dev, dev->name, cdev);
-	return NULL;
-}
-
 void cxgbi_hbas_remove(struct cxgbi_device *cdev)
 {
 	int i;
@@ -532,12 +520,6 @@ static struct cxgbi_sock *cxgbi_check_route(struct sockaddr *dst_addr)
 			dst->neighbour->dev->name, ndev->name, mtu);
 	}
 
-	if (ndev->priv_flags & IFF_802_1Q_VLAN) {
-		ndev = vlan_dev_real_dev(ndev);
-		pr_info("rt dev %s, vlan -> %s.\n",
-			dst->neighbour->dev->name, ndev->name);
-	}
-
 	cdev = cxgbi_device_find_by_netdev(ndev, &port);
 	if (!cdev) {
 		pr_info("dst %pI4, %s, NOT cxgbi device.\n",
@@ -561,10 +543,7 @@ static struct cxgbi_sock *cxgbi_check_route(struct sockaddr *dst_addr)
 	csk->dst = dst;
 	csk->daddr.sin_addr.s_addr = daddr->sin_addr.s_addr;
 	csk->daddr.sin_port = daddr->sin_port;
-	if (cdev->hbas[port]->ipv4addr)
-		csk->saddr.sin_addr.s_addr = cdev->hbas[port]->ipv4addr;
-	else
-		csk->saddr.sin_addr.s_addr = rt->rt_src;
+	csk->saddr.sin_addr.s_addr = rt->rt_src;
 
 	return csk;
 
diff --git a/drivers/scsi/cxgbi/libcxgbi.h b/drivers/scsi/cxgbi/libcxgbi.h
index 48e6d62..43025b7 100644
--- a/drivers/scsi/cxgbi/libcxgbi.h
+++ b/drivers/scsi/cxgbi/libcxgbi.h
@@ -500,6 +500,7 @@ void cxgbi_sock_free_cpl_skbs(struct cxgbi_sock *);
 
 struct cxgbi_hba {
 	struct net_device *ndev;
+	struct net_device *vdev;	/* vlan dev */
 	struct Scsi_Host *shost;
 	struct cxgbi_device *cdev;
 	__be32 ipv4addr;
