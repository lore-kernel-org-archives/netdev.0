From: Sagi Grimberg <sagi@grimberg.me>
Subject: [PATCH v1 3/4] nvme-rdma: use inet_pton_with_scope helper
Date: Mon, 27 Feb 2017 19:39:23 +0200
Message-ID: <1488217164-9221-4-git-send-email-sagi@grimberg.me>
References: <1488217164-9221-1-git-send-email-sagi@grimberg.me>
To: linux-nvme@lists.infradead.org, target-devel@vger.kernel.org,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:54022 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751364AbdB0Rlu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Feb 2017 12:41:50 -0500
In-Reply-To: <1488217164-9221-1-git-send-email-sagi@grimberg.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Sagi Grimberg <sagi@grimberg.me>
---
 drivers/nvme/host/rdma.c | 63 +++++++++++++++---------------------------------
 1 file changed, 19 insertions(+), 44 deletions(-)

diff --git a/drivers/nvme/host/rdma.c b/drivers/nvme/host/rdma.c
index 49b2121af689..3f4c49969f55 100644
--- a/drivers/nvme/host/rdma.c
+++ b/drivers/nvme/host/rdma.c
@@ -129,14 +129,8 @@ struct nvme_rdma_ctrl {
 	u64			cap;
 	u32			max_fr_pages;
 
-	union {
-		struct sockaddr addr;
-		struct sockaddr_in addr_in;
-	};
-	union {
-		struct sockaddr src_addr;
-		struct sockaddr_in src_addr_in;
-	};
+	struct sockaddr_storage addr;
+	struct sockaddr_storage src_addr;
 
 	struct nvme_ctrl	ctrl;
 };
@@ -571,11 +565,12 @@ static int nvme_rdma_init_queue(struct nvme_rdma_ctrl *ctrl,
 		return PTR_ERR(queue->cm_id);
 	}
 
-	queue->cm_error = -ETIMEDOUT;
 	if (ctrl->ctrl.opts->mask & NVMF_OPT_HOST_TRADDR)
-		src_addr = &ctrl->src_addr;
+		src_addr = (struct sockaddr *)&ctrl->src_addr;
 
-	ret = rdma_resolve_addr(queue->cm_id, src_addr, &ctrl->addr,
+	queue->cm_error = -ETIMEDOUT;
+	ret = rdma_resolve_addr(queue->cm_id, src_addr,
+			(struct sockaddr *)&ctrl->addr,
 			NVME_RDMA_CONNECT_TIMEOUT_MS);
 	if (ret) {
 		dev_info(ctrl->ctrl.device,
@@ -1857,27 +1852,13 @@ static int nvme_rdma_create_io_queues(struct nvme_rdma_ctrl *ctrl)
 	return ret;
 }
 
-static int nvme_rdma_parse_ipaddr(struct sockaddr_in *in_addr, char *p)
-{
-	u8 *addr = (u8 *)&in_addr->sin_addr.s_addr;
-	size_t buflen = strlen(p);
-
-	/* XXX: handle IPv6 addresses */
-
-	if (buflen > INET_ADDRSTRLEN)
-		return -EINVAL;
-	if (in4_pton(p, buflen, addr, '\0', NULL) == 0)
-		return -EINVAL;
-	in_addr->sin_family = AF_INET;
-	return 0;
-}
-
 static struct nvme_ctrl *nvme_rdma_create_ctrl(struct device *dev,
 		struct nvmf_ctrl_options *opts)
 {
 	struct nvme_rdma_ctrl *ctrl;
 	int ret;
 	bool changed;
+	char *port;
 
 	ctrl = kzalloc(sizeof(*ctrl), GFP_KERNEL);
 	if (!ctrl)
@@ -1885,34 +1866,28 @@ static struct nvme_ctrl *nvme_rdma_create_ctrl(struct device *dev,
 	ctrl->ctrl.opts = opts;
 	INIT_LIST_HEAD(&ctrl->list);
 
-	ret = nvme_rdma_parse_ipaddr(&ctrl->addr_in, opts->traddr);
+	if (opts->mask & NVMF_OPT_TRSVCID)
+		port = opts->trsvcid;
+	else
+		port = __stringify(NVME_RDMA_IP_PORT);
+
+	ret = inet_pton_with_scope(&init_net, AF_UNSPEC,
+			opts->traddr, port, &ctrl->addr);
 	if (ret) {
-		pr_err("malformed IP address passed: %s\n", opts->traddr);
+		pr_err("malformed address passed: %s:%s\n", opts->traddr, port);
 		goto out_free_ctrl;
 	}
 
 	if (opts->mask & NVMF_OPT_HOST_TRADDR) {
-		ret = nvme_rdma_parse_ipaddr(&ctrl->src_addr_in,
-				opts->host_traddr);
+		ret = inet_pton_with_scope(&init_net, AF_UNSPEC,
+			opts->host_traddr, NULL, &ctrl->src_addr);
 		if (ret) {
-			pr_err("malformed src IP address passed: %s\n",
+			pr_err("malformed src address passed: %s\n",
 			       opts->host_traddr);
 			goto out_free_ctrl;
 		}
 	}
 
-	if (opts->mask & NVMF_OPT_TRSVCID) {
-		u16 port;
-
-		ret = kstrtou16(opts->trsvcid, 0, &port);
-		if (ret)
-			goto out_free_ctrl;
-
-		ctrl->addr_in.sin_port = cpu_to_be16(port);
-	} else {
-		ctrl->addr_in.sin_port = cpu_to_be16(NVME_RDMA_IP_PORT);
-	}
-
 	ret = nvme_init_ctrl(&ctrl->ctrl, dev, &nvme_rdma_ctrl_ops,
 				0 /* no quirks, we're perfect! */);
 	if (ret)
@@ -1977,7 +1952,7 @@ static struct nvme_ctrl *nvme_rdma_create_ctrl(struct device *dev,
 	changed = nvme_change_ctrl_state(&ctrl->ctrl, NVME_CTRL_LIVE);
 	WARN_ON_ONCE(!changed);
 
-	dev_info(ctrl->ctrl.device, "new ctrl: NQN \"%s\", addr %pISp\n",
+	dev_info(ctrl->ctrl.device, "new ctrl: NQN \"%s\", addr %pISpcs\n",
 		ctrl->ctrl.opts->subsysnqn, &ctrl->addr);
 
 	kref_get(&ctrl->ctrl.kref);
-- 
2.7.4
