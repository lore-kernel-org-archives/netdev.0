From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 13/13] mlx5: Enable mutual support for IB and Ethernet
Date: Thu,  4 Jun 2015 19:30:48 +0300
Message-ID: <1433435448-4937-14-git-send-email-ogerlitz@mellanox.com>
References: <1433435448-4937-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Majd Dibbiny <majd@mellanox.com>,
	Haggai Abramonvsky <hagaya@mellanox.com>,
	Tal Alon <talal@mellanox.com>, Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:47742 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S932307AbbFDQbc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Jun 2015 12:31:32 -0400
In-Reply-To: <1433435448-4937-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Haggai Abramonvsky <hagaya@mellanox.com>

Ethernet functionality is only available when working in ISSI > 0 mode.

Previously, the IB driver wasn't ready to work on that mode, and hence
building both the IB driver and the Ethernet functionality in the core
driver were disallowed by Kconfigs.

Now, once we have all the pre-steps in place, we can remove this limitation.

The last steps in the IB driver for getting that setup to work are:
create dummy SRQ for the driver's use (until now we could use XRC_SRQ
as SRQ and XRC_SRQ, after moving to ISSI > 0, we separate XRC SRQs from
basic SRQs) and adapt the create QP function to be compatible with ISSI > 0.

Signed-off-by: Haggai Abramovsky <hagaya@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/infiniband/hw/mlx5/main.c               |   22 ++++++++++++++++++++++
 drivers/infiniband/hw/mlx5/mlx5_ib.h            |    1 +
 drivers/infiniband/hw/mlx5/qp.c                 |    3 ++-
 drivers/net/ethernet/mellanox/mlx5/core/Kconfig |    2 +-
 drivers/net/ethernet/mellanox/mlx5/core/qp.c    |    7 +++++++
 5 files changed, 33 insertions(+), 2 deletions(-)

diff --git a/drivers/infiniband/hw/mlx5/main.c b/drivers/infiniband/hw/mlx5/main.c
index f829692..d4dea86 100644
--- a/drivers/infiniband/hw/mlx5/main.c
+++ b/drivers/infiniband/hw/mlx5/main.c
@@ -1324,8 +1324,29 @@ static int create_dev_resources(struct mlx5_ib_resources *devr)
 	atomic_inc(&devr->p0->usecnt);
 	atomic_set(&devr->s0->usecnt, 0);
 
+	memset(&attr, 0, sizeof(attr));
+	attr.attr.max_sge = 1;
+	attr.attr.max_wr = 1;
+	attr.srq_type = IB_SRQT_BASIC;
+	devr->s1 = mlx5_ib_create_srq(devr->p0, &attr, NULL);
+	if (IS_ERR(devr->s1)) {
+		ret = PTR_ERR(devr->s1);
+		goto error5;
+	}
+	devr->s1->device	= &dev->ib_dev;
+	devr->s1->pd		= devr->p0;
+	devr->s1->uobject       = NULL;
+	devr->s1->event_handler = NULL;
+	devr->s1->srq_context   = NULL;
+	devr->s1->srq_type      = IB_SRQT_BASIC;
+	devr->s1->ext.xrc.cq	= devr->c0;
+	atomic_inc(&devr->p0->usecnt);
+	atomic_set(&devr->s0->usecnt, 0);
+
 	return 0;
 
+error5:
+	mlx5_ib_destroy_srq(devr->s0);
 error4:
 	mlx5_ib_dealloc_xrcd(devr->x1);
 error3:
@@ -1340,6 +1361,7 @@ error0:
 
 static void destroy_dev_resources(struct mlx5_ib_resources *devr)
 {
+	mlx5_ib_destroy_srq(devr->s1);
 	mlx5_ib_destroy_srq(devr->s0);
 	mlx5_ib_dealloc_xrcd(devr->x0);
 	mlx5_ib_dealloc_xrcd(devr->x1);
diff --git a/drivers/infiniband/hw/mlx5/mlx5_ib.h b/drivers/infiniband/hw/mlx5/mlx5_ib.h
index f731b25..873dc35 100644
--- a/drivers/infiniband/hw/mlx5/mlx5_ib.h
+++ b/drivers/infiniband/hw/mlx5/mlx5_ib.h
@@ -415,6 +415,7 @@ struct mlx5_ib_resources {
 	struct ib_xrcd	*x1;
 	struct ib_pd	*p0;
 	struct ib_srq	*s0;
+	struct ib_srq	*s1;
 };
 
 struct mlx5_ib_dev {
diff --git a/drivers/infiniband/hw/mlx5/qp.c b/drivers/infiniband/hw/mlx5/qp.c
index 15fd485..203c8a4 100644
--- a/drivers/infiniband/hw/mlx5/qp.c
+++ b/drivers/infiniband/hw/mlx5/qp.c
@@ -1012,7 +1012,8 @@ static int create_qp_common(struct mlx5_ib_dev *dev, struct ib_pd *pd,
 			in->ctx.rq_type_srqn |= cpu_to_be32(to_msrq(init_attr->srq)->msrq.srqn);
 		} else {
 			in->ctx.xrcd = cpu_to_be32(to_mxrcd(devr->x1)->xrcdn);
-			in->ctx.rq_type_srqn |= cpu_to_be32(to_msrq(devr->s0)->msrq.srqn);
+			in->ctx.rq_type_srqn |=
+				cpu_to_be32(to_msrq(devr->s1)->msrq.srqn);
 		}
 	}
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/Kconfig b/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
index 0d7aef0..158c88c 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
+++ b/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
@@ -12,7 +12,7 @@ config MLX5_CORE
 
 config MLX5_CORE_EN
 	bool "Mellanox Technologies ConnectX-4 Ethernet support"
-	depends on MLX5_INFINIBAND=n && NETDEVICES && ETHERNET && PCI && MLX5_CORE
+	depends on NETDEVICES && ETHERNET && PCI && MLX5_CORE
 	default n
 	---help---
 	  Ethernet support in Mellanox Technologies ConnectX-4 NIC.
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/qp.c b/drivers/net/ethernet/mellanox/mlx5/core/qp.c
index dc7dbf7..8b494b5 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/qp.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/qp.c
@@ -187,10 +187,17 @@ int mlx5_core_create_qp(struct mlx5_core_dev *dev,
 	struct mlx5_destroy_qp_mbox_in din;
 	struct mlx5_destroy_qp_mbox_out dout;
 	int err;
+	void *qpc;
 
 	memset(&out, 0, sizeof(out));
 	in->hdr.opcode = cpu_to_be16(MLX5_CMD_OP_CREATE_QP);
 
+	if (dev->issi) {
+		qpc = MLX5_ADDR_OF(create_qp_in, in, qpc);
+		/* 0xffffff means we ask to work with cqe version 0 */
+		MLX5_SET(qpc, qpc, user_index, 0xffffff);
+	}
+
 	err = mlx5_cmd_exec(dev, in, inlen, &out, sizeof(out));
 	if (err) {
 		mlx5_core_warn(dev, "ret %d\n", err);
-- 
1.7.1
