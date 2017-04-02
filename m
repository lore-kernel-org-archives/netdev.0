From: Sagi Grimberg <sagi@grimberg.me>
Subject: [PATCH rfc 3/6] RDMA/core: expose affinity mappings per completion vector
Date: Sun,  2 Apr 2017 16:41:29 +0300
Message-ID: <1491140492-25703-4-git-send-email-sagi@grimberg.me>
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

This will allow ULPs to intelligently locate threads based
on completion vector cpu affinity mappings. In case the
driver does not expose a get_vector_affinity callout, return
NULL so the caller can maintain a fallback logic.

Signed-off-by: Sagi Grimberg <sagi@grimberg.me>
---
 include/rdma/ib_verbs.h | 24 ++++++++++++++++++++++++
 1 file changed, 24 insertions(+)

diff --git a/include/rdma/ib_verbs.h b/include/rdma/ib_verbs.h
index 0f1813c13687..d44b62791c64 100644
--- a/include/rdma/ib_verbs.h
+++ b/include/rdma/ib_verbs.h
@@ -2150,6 +2150,8 @@ struct ib_device {
 	 */
 	int (*get_port_immutable)(struct ib_device *, u8, struct ib_port_immutable *);
 	void (*get_dev_fw_str)(struct ib_device *, char *str, size_t str_len);
+	const struct cpumask *(*get_vector_affinity)(struct ib_device *ibdev,
+						     int comp_vector);
 };
 
 struct ib_client {
@@ -3377,4 +3379,26 @@ void ib_drain_qp(struct ib_qp *qp);
 
 int ib_resolve_eth_dmac(struct ib_device *device,
 			struct ib_ah_attr *ah_attr);
+
+/**
+ * ib_get_vector_affinity - Get the affinity mappings of a given completion
+ *   vector
+ * @device:         the rdma device
+ * @comp_vector:    index of completion vector
+ *
+ * Returns NULL on failure, otherwise a corresponding cpu map of the
+ * completion vector (returns all-cpus map if the device driver doesn't
+ * implement get_vector_affinity).
+ */
+static inline const struct cpumask *
+ib_get_vector_affinity(struct ib_device *device, int comp_vector)
+{
+	if (comp_vector > device->num_comp_vectors ||
+	    !device->get_vector_affinity)
+		return NULL;
+
+	return device->get_vector_affinity(device, comp_vector);
+
+}
+
 #endif /* IB_VERBS_H */
-- 
2.7.4
