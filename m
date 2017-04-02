From: Sagi Grimberg <sagi@grimberg.me>
Subject: [PATCH rfc 6/6] nvme-rdma: use intelligent affinity based queue mappings
Date: Sun,  2 Apr 2017 16:41:32 +0300
Message-ID: <1491140492-25703-7-git-send-email-sagi@grimberg.me>
References: <1491140492-25703-1-git-send-email-sagi@grimberg.me>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Christoph Hellwig <hch@lst.de>
To: linux-rdma@vger.kernel.org, linux-nvme@lists.infradead.org,
        linux-block@vger.kernel.org
Return-path: <linux-block-owner@vger.kernel.org>
In-Reply-To: <1491140492-25703-1-git-send-email-sagi@grimberg.me>
Sender: linux-block-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the geneic block layer affinity mapping helper. Also,
limit nr_hw_queues to the rdma device number of irq vectors
as we don't really need more.

Signed-off-by: Sagi Grimberg <sagi@grimberg.me>
---
 drivers/nvme/host/rdma.c | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/drivers/nvme/host/rdma.c b/drivers/nvme/host/rdma.c
index 4aae363943e3..81ee5b1207c8 100644
--- a/drivers/nvme/host/rdma.c
+++ b/drivers/nvme/host/rdma.c
@@ -19,6 +19,7 @@
 #include <linux/string.h>
 #include <linux/atomic.h>
 #include <linux/blk-mq.h>
+#include <linux/blk-mq-rdma.h>
 #include <linux/types.h>
 #include <linux/list.h>
 #include <linux/mutex.h>
@@ -645,10 +646,14 @@ static int nvme_rdma_connect_io_queues(struct nvme_rdma_ctrl *ctrl)
 static int nvme_rdma_init_io_queues(struct nvme_rdma_ctrl *ctrl)
 {
 	struct nvmf_ctrl_options *opts = ctrl->ctrl.opts;
+	struct ib_device *ibdev = ctrl->device->dev;
 	unsigned int nr_io_queues;
 	int i, ret;
 
 	nr_io_queues = min(opts->nr_io_queues, num_online_cpus());
+	nr_io_queues = min_t(unsigned int, nr_io_queues,
+				ibdev->num_comp_vectors);
+
 	ret = nvme_set_queue_count(&ctrl->ctrl, &nr_io_queues);
 	if (ret)
 		return ret;
@@ -1523,6 +1528,13 @@ static void nvme_rdma_complete_rq(struct request *rq)
 	nvme_complete_rq(rq);
 }
 
+static int nvme_rdma_map_queues(struct blk_mq_tag_set *set)
+{
+	struct nvme_rdma_ctrl *ctrl = set->driver_data;
+
+	return blk_mq_rdma_map_queues(set, ctrl->device->dev, 0);
+}
+
 static const struct blk_mq_ops nvme_rdma_mq_ops = {
 	.queue_rq	= nvme_rdma_queue_rq,
 	.complete	= nvme_rdma_complete_rq,
@@ -1532,6 +1544,7 @@ static const struct blk_mq_ops nvme_rdma_mq_ops = {
 	.init_hctx	= nvme_rdma_init_hctx,
 	.poll		= nvme_rdma_poll,
 	.timeout	= nvme_rdma_timeout,
+	.map_queues	= nvme_rdma_map_queues,
 };
 
 static const struct blk_mq_ops nvme_rdma_admin_mq_ops = {
-- 
2.7.4
