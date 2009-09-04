From: Scott Feldman <scofeldm@cisco.com>
Subject: [net-next PATCH 07/11] enic: provision for multiple Rx/Tx queues;
	prepare for RSS support
Date: Thu, 03 Sep 2009 20:02:24 -0700
Message-ID: <20090904030224.5047.81973.stgit@palito_client100.nuovasystems.com>
References: <20090904030046.5047.46509.stgit@palito_client100.nuovasystems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-1.cisco.com ([171.71.176.70]:44977 "EHLO
	sj-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932748AbZIDDCV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2009 23:02:21 -0400
In-Reply-To: <20090904030046.5047.46509.stgit@palito_client100.nuovasystems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

enic: provision for multiple Rx/Tx queues; prepare for RSS support

Provision for multiple Rx/Tx queues.  Max of 8 WQs and 8 RQs.  Max for
completion queue is 8+8=16 and max for interrupt resources is 8+8+2.

Add driver/firmware interface for setting up RSS secret key and indirection
table.

Signed-off-by: Scott Feldman <scofeldm@cisco.com>
---
 drivers/net/enic/enic.h      |   16 ++++++++++------
 drivers/net/enic/enic_main.c |    6 +++---
 drivers/net/enic/enic_res.c  |   33 ++++++++++++++++++++++++++++-----
 drivers/net/enic/enic_res.h  |    2 ++
 drivers/net/enic/vnic_nic.h  |    7 +++++++
 5 files changed, 50 insertions(+), 14 deletions(-)

diff --git a/drivers/net/enic/enic.h b/drivers/net/enic/enic.h
index f7c5b33..e1c2076 100644
--- a/drivers/net/enic/enic.h
+++ b/drivers/net/enic/enic.h
@@ -29,6 +29,7 @@
 #include "vnic_cq.h"
 #include "vnic_intr.h"
 #include "vnic_stats.h"
+#include "vnic_nic.h"
 #include "vnic_rss.h"
 
 #define DRV_NAME		"enic"
@@ -42,17 +43,20 @@
 
 #define ENIC_BARS_MAX		6
 
+#define ENIC_WQ_MAX		8
+#define ENIC_RQ_MAX		8
+#define ENIC_CQ_MAX		(ENIC_WQ_MAX + ENIC_RQ_MAX)
+#define ENIC_INTR_MAX		(ENIC_CQ_MAX + 2)
+
 enum enic_cq_index {
 	ENIC_CQ_RQ,
 	ENIC_CQ_WQ,
-	ENIC_CQ_MAX,
 };
 
 enum enic_intx_intr_index {
 	ENIC_INTX_WQ_RQ,
 	ENIC_INTX_ERR,
 	ENIC_INTX_NOTIFY,
-	ENIC_INTX_MAX,
 };
 
 enum enic_msix_intr_index {
@@ -90,13 +94,13 @@ struct enic {
 	u32 port_mtu;
 
 	/* work queue cache line section */
-	____cacheline_aligned struct vnic_wq wq[1];
-	spinlock_t wq_lock[1];
+	____cacheline_aligned struct vnic_wq wq[ENIC_WQ_MAX];
+	spinlock_t wq_lock[ENIC_WQ_MAX];
 	unsigned int wq_count;
 	struct vlan_group *vlan_group;
 
 	/* receive queue cache line section */
-	____cacheline_aligned struct vnic_rq rq[1];
+	____cacheline_aligned struct vnic_rq rq[ENIC_RQ_MAX];
 	unsigned int rq_count;
 	int (*rq_alloc_buf)(struct vnic_rq *rq);
 	u64 rq_truncated_pkts;
@@ -106,7 +110,7 @@ struct enic {
 	struct net_lro_desc lro_desc[ENIC_LRO_MAX_DESC];
 
 	/* interrupt resource cache line section */
-	____cacheline_aligned struct vnic_intr intr[ENIC_MSIX_MAX];
+	____cacheline_aligned struct vnic_intr intr[ENIC_INTR_MAX];
 	unsigned int intr_count;
 	u32 __iomem *legacy_pba;		/* memory-mapped */
 
diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.c
index 139c380..6068904 100644
--- a/drivers/net/enic/enic_main.c
+++ b/drivers/net/enic/enic_main.c
@@ -1585,7 +1585,7 @@ static int enic_set_niccfg(struct enic *enic)
 	const u8 ig_vlan_strip_en = 1;
 
 	/* Enable VLAN tag stripping.  RSS not enabled (yet).
-	*/
+	 */
 
 	return enic_set_nic_cfg(enic,
 		rss_default_cpu, rss_hash_type,
@@ -1620,8 +1620,8 @@ static void enic_reset(struct work_struct *work)
 
 static int enic_set_intr_mode(struct enic *enic)
 {
-	unsigned int n = ARRAY_SIZE(enic->rq);
-	unsigned int m = ARRAY_SIZE(enic->wq);
+	unsigned int n = 1;
+	unsigned int m = 1;
 	unsigned int i;
 
 	/* Set interrupt mode (INTx, MSI, MSI-X) depending
diff --git a/drivers/net/enic/enic_res.c b/drivers/net/enic/enic_res.c
index e5fc938..3211114 100644
--- a/drivers/net/enic/enic_res.c
+++ b/drivers/net/enic/enic_res.c
@@ -156,6 +156,22 @@ int enic_set_nic_cfg(struct enic *enic, u8 rss_default_cpu, u8 rss_hash_type,
 	return vnic_dev_cmd(enic->vdev, CMD_NIC_CFG, &a0, &a1, wait);
 }
 
+int enic_set_rss_key(struct enic *enic, dma_addr_t key_pa, u64 len)
+{
+	u64 a0 = (u64)key_pa, a1 = len;
+	int wait = 1000;
+
+	return vnic_dev_cmd(enic->vdev, CMD_RSS_KEY, &a0, &a1, wait);
+}
+
+int enic_set_rss_cpu(struct enic *enic, dma_addr_t cpu_pa, u64 len)
+{
+	u64 a0 = (u64)cpu_pa, a1 = len;
+	int wait = 1000;
+
+	return vnic_dev_cmd(enic->vdev, CMD_RSS_CPU, &a0, &a1, wait);
+}
+
 void enic_free_vnic_resources(struct enic *enic)
 {
 	unsigned int i;
@@ -172,11 +188,18 @@ void enic_free_vnic_resources(struct enic *enic)
 
 void enic_get_res_counts(struct enic *enic)
 {
-	enic->wq_count = vnic_dev_get_res_count(enic->vdev, RES_TYPE_WQ);
-	enic->rq_count = vnic_dev_get_res_count(enic->vdev, RES_TYPE_RQ);
-	enic->cq_count = vnic_dev_get_res_count(enic->vdev, RES_TYPE_CQ);
-	enic->intr_count = vnic_dev_get_res_count(enic->vdev,
-		RES_TYPE_INTR_CTRL);
+	enic->wq_count = min_t(int,
+		vnic_dev_get_res_count(enic->vdev, RES_TYPE_WQ),
+		ENIC_WQ_MAX);
+	enic->rq_count = min_t(int,
+		vnic_dev_get_res_count(enic->vdev, RES_TYPE_RQ),
+		ENIC_RQ_MAX);
+	enic->cq_count = min_t(int,
+		vnic_dev_get_res_count(enic->vdev, RES_TYPE_CQ),
+		ENIC_CQ_MAX);
+	enic->intr_count = min_t(int,
+		vnic_dev_get_res_count(enic->vdev, RES_TYPE_INTR_CTRL),
+		ENIC_INTR_MAX);
 
 	printk(KERN_INFO PFX "vNIC resources avail: "
 		"wq %d rq %d cq %d intr %d\n",
diff --git a/drivers/net/enic/enic_res.h b/drivers/net/enic/enic_res.h
index 7bf272f..abc1974 100644
--- a/drivers/net/enic/enic_res.h
+++ b/drivers/net/enic/enic_res.h
@@ -139,6 +139,8 @@ void enic_del_vlan(struct enic *enic, u16 vlanid);
 int enic_set_nic_cfg(struct enic *enic, u8 rss_default_cpu, u8 rss_hash_type,
 	u8 rss_hash_bits, u8 rss_base_cpu, u8 rss_enable, u8 tso_ipid_split_en,
 	u8 ig_vlan_strip_en);
+int enic_set_rss_key(struct enic *enic, dma_addr_t key_pa, u64 len);
+int enic_set_rss_cpu(struct enic *enic, dma_addr_t cpu_pa, u64 len);
 void enic_get_res_counts(struct enic *enic);
 void enic_init_vnic_resources(struct enic *enic);
 int enic_alloc_vnic_resources(struct enic *);
diff --git a/drivers/net/enic/vnic_nic.h b/drivers/net/enic/vnic_nic.h
index dadf26f..eeaf329 100644
--- a/drivers/net/enic/vnic_nic.h
+++ b/drivers/net/enic/vnic_nic.h
@@ -41,6 +41,13 @@
 #define NIC_CFG_IG_VLAN_STRIP_EN_MASK_FIELD	1UL
 #define NIC_CFG_IG_VLAN_STRIP_EN_SHIFT		24
 
+#define NIC_CFG_RSS_HASH_TYPE_IPV4		(1 << 0)
+#define NIC_CFG_RSS_HASH_TYPE_TCP_IPV4		(1 << 1)
+#define NIC_CFG_RSS_HASH_TYPE_IPV6		(1 << 2)
+#define NIC_CFG_RSS_HASH_TYPE_TCP_IPV6		(1 << 3)
+#define NIC_CFG_RSS_HASH_TYPE_IPV6_EX		(1 << 4)
+#define NIC_CFG_RSS_HASH_TYPE_TCP_IPV6_EX	(1 << 5)
+
 static inline void vnic_set_nic_cfg(u32 *nic_cfg,
 	u8 rss_default_cpu, u8 rss_hash_type,
 	u8 rss_hash_bits, u8 rss_base_cpu,

