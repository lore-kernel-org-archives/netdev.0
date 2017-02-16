From: Sagi Grimberg <sagi-NQWnxTmZq1alnMjI0IkVqw@public.gmane.org>
Subject: [PATCH rfc 2/4] nvmet-rdma: use generic inet_pton_with_scope
Date: Thu, 16 Feb 2017 19:43:35 +0200
Message-ID: <1487267017-29904-3-git-send-email-sagi@grimberg.me>
References: <1487267017-29904-1-git-send-email-sagi@grimberg.me>
To: linux-nvme-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        target-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1487267017-29904-1-git-send-email-sagi-NQWnxTmZq1alnMjI0IkVqw@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Sagi Grimberg <sagi-NQWnxTmZq1alnMjI0IkVqw@public.gmane.org>
---
 drivers/nvme/target/rdma.c | 42 +++++++++++++++++++++++++++++-------------
 1 file changed, 29 insertions(+), 13 deletions(-)

diff --git a/drivers/nvme/target/rdma.c b/drivers/nvme/target/rdma.c
index 8c3760a78ac0..298db68f2db9 100644
--- a/drivers/nvme/target/rdma.c
+++ b/drivers/nvme/target/rdma.c
@@ -1411,12 +1411,16 @@ static void nvmet_rdma_delete_ctrl(struct nvmet_ctrl *ctrl)
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
@@ -1424,13 +1428,13 @@ static int nvmet_rdma_add_port(struct nvmet_port *port)
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
@@ -1439,20 +1443,32 @@ static int nvmet_rdma_add_port(struct nvmet_port *port)
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

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
