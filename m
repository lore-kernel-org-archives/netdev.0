From: Scott Feldman <scofeldm@cisco.com>
Subject: [net-next PATCH 02/11] enic: workaround A0 erratum
Date: Thu, 03 Sep 2009 20:01:58 -0700
Message-ID: <20090904030158.5047.59037.stgit@palito_client100.nuovasystems.com>
References: <20090904030046.5047.46509.stgit@palito_client100.nuovasystems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:18629 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932681AbZIDDBz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2009 23:01:55 -0400
In-Reply-To: <20090904030046.5047.46509.stgit@palito_client100.nuovasystems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

enic: workaround A0 erratum

A0 revision ASIC has an erratum on the RQ desc cache on chip where the
cache can become corrupted causing pkt buf writes to wrong locations.  The s/w
workaround is to post a dummy RQ desc in the ring every 32 descs, causing a
flush of the cache.  A0 parts are not production, but there are enough of
these parts in the wild in test setups to warrant including workaround.  A1
revision ASIC parts fix erratum.

Signed-off-by: Scott Feldman <scofeldm@cisco.com>
---
 drivers/net/enic/enic_main.c |   50 +++++++++++++++++++++++++++++++++++++++---
 drivers/net/enic/vnic_dev.c  |   19 ++++++++++++++++
 drivers/net/enic/vnic_dev.h  |    8 +++++++
 drivers/net/enic/vnic_rq.h   |    7 +++++-
 4 files changed, 80 insertions(+), 4 deletions(-)

diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.c
index b17fe4b..3d7838d 100644
--- a/drivers/net/enic/enic_main.c
+++ b/drivers/net/enic/enic_main.c
@@ -850,6 +850,50 @@ static int enic_rq_alloc_buf(struct vnic_rq *rq)
 	return 0;
 }
 
+static int enic_rq_alloc_buf_a1(struct vnic_rq *rq)
+{
+	struct rq_enet_desc *desc = vnic_rq_next_desc(rq);
+
+	if (vnic_rq_posting_soon(rq)) {
+
+		/* SW workaround for A0 HW erratum: if we're just about
+		 * to write posted_index, insert a dummy desc
+		 * of type resvd
+		 */
+
+		rq_enet_desc_enc(desc, 0, RQ_ENET_TYPE_RESV2, 0);
+		vnic_rq_post(rq, 0, 0, 0, 0);
+	} else {
+		return enic_rq_alloc_buf(rq);
+	}
+
+	return 0;
+}
+
+static int enic_set_rq_alloc_buf(struct enic *enic)
+{
+	enum vnic_dev_hw_version hw_ver;
+	int err;
+
+	err = vnic_dev_hw_version(enic->vdev, &hw_ver);
+	if (err)
+		return err;
+
+	switch (hw_ver) {
+	case VNIC_DEV_HW_VER_A1:
+		enic->rq_alloc_buf = enic_rq_alloc_buf_a1;
+		break;
+	case VNIC_DEV_HW_VER_A2:
+	case VNIC_DEV_HW_VER_UNKNOWN:
+		enic->rq_alloc_buf = enic_rq_alloc_buf;
+		break;
+	default:
+		return -ENODEV;
+	}
+
+	return 0;
+}
+
 static int enic_get_skb_header(struct sk_buff *skb, void **iphdr,
 	void **tcph, u64 *hdr_flags, void *priv)
 {
@@ -1057,7 +1101,7 @@ static int enic_poll(struct napi_struct *napi, int budget)
 		/* Replenish RQ
 		 */
 
-		vnic_rq_fill(&enic->rq[0], enic_rq_alloc_buf);
+		vnic_rq_fill(&enic->rq[0], enic->rq_alloc_buf);
 
 	} else {
 
@@ -1092,7 +1136,7 @@ static int enic_poll_msix(struct napi_struct *napi, int budget)
 		/* Replenish RQ
 		 */
 
-		vnic_rq_fill(&enic->rq[0], enic_rq_alloc_buf);
+		vnic_rq_fill(&enic->rq[0], enic->rq_alloc_buf);
 
 		/* Return intr event credits for this polling
 		 * cycle.  An intr event is the completion of a
@@ -1268,7 +1312,7 @@ static int enic_open(struct net_device *netdev)
 	}
 
 	for (i = 0; i < enic->rq_count; i++) {
-		err = vnic_rq_fill(&enic->rq[i], enic_rq_alloc_buf);
+		err = vnic_rq_fill(&enic->rq[i], enic->rq_alloc_buf);
 		if (err) {
 			printk(KERN_ERR PFX
 				"%s: Unable to alloc receive buffers.\n",
diff --git a/drivers/net/enic/vnic_dev.c b/drivers/net/enic/vnic_dev.c
index d5c28ef..c8d3fc7 100644
--- a/drivers/net/enic/vnic_dev.c
+++ b/drivers/net/enic/vnic_dev.c
@@ -349,6 +349,25 @@ int vnic_dev_fw_info(struct vnic_dev *vdev,
 	return err;
 }
 
+int vnic_dev_hw_version(struct vnic_dev *vdev, enum vnic_dev_hw_version *hw_ver)
+{
+	struct vnic_devcmd_fw_info *fw_info;
+	int err;
+
+	err = vnic_dev_fw_info(vdev, &fw_info);
+	if (err)
+		return err;
+
+	if (strncmp(fw_info->hw_version, "A1", sizeof("A1")) == 0)
+		*hw_ver = VNIC_DEV_HW_VER_A1;
+	else if (strncmp(fw_info->hw_version, "A2", sizeof("A2")) == 0)
+		*hw_ver = VNIC_DEV_HW_VER_A2;
+	else
+		*hw_ver = VNIC_DEV_HW_VER_UNKNOWN;
+
+	return 0;
+}
+
 int vnic_dev_spec(struct vnic_dev *vdev, unsigned int offset, unsigned int size,
 	void *value)
 {
diff --git a/drivers/net/enic/vnic_dev.h b/drivers/net/enic/vnic_dev.h
index d960edb..db1d63e 100644
--- a/drivers/net/enic/vnic_dev.h
+++ b/drivers/net/enic/vnic_dev.h
@@ -41,6 +41,12 @@ static inline void writeq(u64 val, void __iomem *reg)
 }
 #endif
 
+enum vnic_dev_hw_version {
+	VNIC_DEV_HW_VER_UNKNOWN,
+	VNIC_DEV_HW_VER_A1,
+	VNIC_DEV_HW_VER_A2,
+};
+
 enum vnic_dev_intr_mode {
 	VNIC_DEV_INTR_MODE_UNKNOWN,
 	VNIC_DEV_INTR_MODE_INTX,
@@ -88,6 +94,8 @@ int vnic_dev_cmd(struct vnic_dev *vdev, enum vnic_devcmd_cmd cmd,
 	u64 *a0, u64 *a1, int wait);
 int vnic_dev_fw_info(struct vnic_dev *vdev,
 	struct vnic_devcmd_fw_info **fw_info);
+int vnic_dev_hw_version(struct vnic_dev *vdev,
+	enum vnic_dev_hw_version *hw_ver);
 int vnic_dev_spec(struct vnic_dev *vdev, unsigned int offset, unsigned int size,
 	void *value);
 int vnic_dev_stats_clear(struct vnic_dev *vdev);
diff --git a/drivers/net/enic/vnic_rq.h b/drivers/net/enic/vnic_rq.h
index fd0ef66..f7b5730 100644
--- a/drivers/net/enic/vnic_rq.h
+++ b/drivers/net/enic/vnic_rq.h
@@ -143,6 +143,11 @@ static inline void vnic_rq_post(struct vnic_rq *rq,
 	}
 }
 
+static inline int vnic_rq_posting_soon(struct vnic_rq *rq)
+{
+	return ((rq->to_use->index & VNIC_RQ_RETURN_RATE) == 0);
+}
+
 static inline void vnic_rq_return_descs(struct vnic_rq *rq, unsigned int count)
 {
 	rq->ring.desc_avail += count;
@@ -186,7 +191,7 @@ static inline int vnic_rq_fill(struct vnic_rq *rq,
 {
 	int err;
 
-	while (vnic_rq_desc_avail(rq) > 1) {
+	while (vnic_rq_desc_avail(rq) > 0) {
 
 		err = (*buf_fill)(rq);
 		if (err)

