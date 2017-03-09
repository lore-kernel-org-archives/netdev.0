From: Sagi Grimberg <sagi@grimberg.me>
Subject: [PATCH v3 2/4] nvmet-rdma: use generic inet_pton_with_scope
Date: Thu,  9 Mar 2017 14:49:51 +0200
Message-ID: <1489063793-12838-3-git-send-email-sagi@grimberg.me>
References: <1489063793-12838-1-git-send-email-sagi@grimberg.me>
Cc: Christoph Hellwig <hch@lst.de>
To: linux-nvme@lists.infradead.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:54450 "EHLO
        merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750770AbdCIMuA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Mar 2017 07:50:00 -0500
In-Reply-To: <1489063793-12838-1-git-send-email-sagi@grimberg.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of parsing address strings, use a generic
helper. This also adds ipv6 (with address scopes)
support.

Reviewed-by: Christoph Hellwig <hch@lst.de>
Signed-off-by: Sagi Grimberg <sagi@grimberg.me>
---
 drivers/nvme/target/rdma.c | 42 +++++++++++++++++++++++++++++-------------
 1 file changed, 29 insertions(+), 13 deletions(-)

diff --git a/drivers/nvme/target/rdma.c b/drivers/nvme/target/rdma.c
index 9aa1da3778b3..973b674ab55b 100644
--- a/drivers/nvme/target/rdma.c
+++ b/drivers/nvme/target/rdma.c
@@ -1429,12 +1429,16 @@ static void nvmet_rdma_delete_ctrl(struct nvmet_ctrl *ctrl)
 static int nvmet_rdma_add_port(struct nvmet_port *port)
 {
 	struct rdma_cm_id *cm_id;
-	struct sockaddr_in addr_in;
-	u16 port_in;
+	struct sockaddr_storage addr = { };
+	__kernel_sa_family_t af;
 	int ret;
 
 	switch (port->disc_addr.adrfam) {
 	case NVMF_ADDR_FAMILY_IP4:
+		af = AF_INET;
+		break;
+	case NVMF_ADDR_FAMILY_IP6:
+		af = AF_INET6;
 		break;
 	default:
 		pr_err("address family %d not supported\n",
@@ -1442,13 +1446,13 @@ static int nvmet_rdma_add_port(struct nvmet_port *port)
 		return -EINVAL;
 	}
 
-	ret = kstrtou16(port->disc_addr.trsvcid, 0, &port_in);
-	if (ret)
+	ret = inet_pton_with_scope(&init_net, af, port->disc_addr.traddr,
+			port->disc_addr.trsvcid, &addr);
+	if (ret) {
+		pr_err("malformed ip/port passed: %s:%s\n",
+			port->disc_addr.traddr, port->disc_addr.trsvcid);
 		return ret;
-
-	addr_in.sin_family = AF_INET;
-	addr_in.sin_addr.s_addr = in_aton(port->disc_addr.traddr);
-	addr_in.sin_port = htons(port_in);
+	}
 
 	cm_id = rdma_create_id(&init_net, nvmet_rdma_cm_handler, port,
 			RDMA_PS_TCP, IB_QPT_RC);
@@ -1457,20 +1461,32 @@ static int nvmet_rdma_add_port(struct nvmet_port *port)
 		return PTR_ERR(cm_id);
 	}
 
-	ret = rdma_bind_addr(cm_id, (struct sockaddr *)&addr_in);
+	/*
+	 * Allow both IPv4 and IPv6 sockets to bind a single port
+	 * at the same time.
+	 */
+	ret = rdma_set_afonly(cm_id, 1);
+	if (ret) {
+		pr_err("rdma_set_afonly failed (%d)\n", ret);
+		goto out_destroy_id;
+	}
+
+	ret = rdma_bind_addr(cm_id, (struct sockaddr *)&addr);
 	if (ret) {
-		pr_err("binding CM ID to %pISpc failed (%d)\n", &addr_in, ret);
+		pr_err("binding CM ID to %pISpcs failed (%d)\n",
+			(struct sockaddr *)&addr, ret);
 		goto out_destroy_id;
 	}
 
 	ret = rdma_listen(cm_id, 128);
 	if (ret) {
-		pr_err("listening to %pISpc failed (%d)\n", &addr_in, ret);
+		pr_err("listening to %pISpcs failed (%d)\n",
+			(struct sockaddr *)&addr, ret);
 		goto out_destroy_id;
 	}
 
-	pr_info("enabling port %d (%pISpc)\n",
-		le16_to_cpu(port->disc_addr.portid), &addr_in);
+	pr_info("enabling port %d (%pISpcs)\n",
+		le16_to_cpu(port->disc_addr.portid), (struct sockaddr *)&addr);
 	port->priv = cm_id;
 	return 0;
 
-- 
2.7.4
