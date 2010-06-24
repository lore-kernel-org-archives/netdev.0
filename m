From: Vasanthy Kolluri <vkolluri@cisco.com>
Subject: [net-next-2.6 PATCH 02/10] enic: Bug Fix: Change hardware ingress
	vlan rewrite mode
Date: Thu, 24 Jun 2010 13:49:51 -0700
Message-ID: <20100624204930.22595.18571.stgit@savbu-pc100.cisco.com>
References: <20100624204723.22595.42990.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, scofeldm@cisco.com, vkolluri@cisco.com,
	roprabhu@cisco.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-1.cisco.com ([171.71.176.70]:44524 "EHLO
	sj-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755743Ab0FXUtv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jun 2010 16:49:51 -0400
In-Reply-To: <20100624204723.22595.42990.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasanthy Kolluri <vkolluri@cisco.com>

The current ingress vlan rewrite mode setting lets the hardware strip off
the tag control information of a packet received on native vlan. As a
result, the priority bits are also lost. The fix is to change the ingress
vlan rewrite mode setting such that the complete tag control information is
retained for packets that belong to native vlan.

Signed-off-by: Scott Feldman <scofeldm@cisco.com>
Signed-off-by: Vasanthy Kolluri <vkolluri@cisco.com>
Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
---
 drivers/net/enic/cq_enet_desc.h |   16 ++++++++++++++--
 drivers/net/enic/enic_main.c    |   31 ++++++++++++++++++++++++++-----
 drivers/net/enic/vnic_dev.c     |   14 ++++++++++++++
 drivers/net/enic/vnic_dev.h     |    2 ++
 drivers/net/enic/vnic_devcmd.h  |   12 ++++++++++++
 5 files changed, 68 insertions(+), 7 deletions(-)

diff --git a/drivers/net/enic/cq_enet_desc.h b/drivers/net/enic/cq_enet_desc.h
index 337d194..f2d98bb 100644
--- a/drivers/net/enic/cq_enet_desc.h
+++ b/drivers/net/enic/cq_enet_desc.h
@@ -73,6 +73,15 @@ struct cq_enet_rq_desc {
 #define CQ_ENET_RQ_DESC_FLAGS_TRUNCATED             (0x1 << 14)
 #define CQ_ENET_RQ_DESC_FLAGS_VLAN_STRIPPED         (0x1 << 15)
 
+#define CQ_ENET_RQ_DESC_VLAN_TCI_VLAN_BITS          12
+#define CQ_ENET_RQ_DESC_VLAN_TCI_VLAN_MASK \
+	((1 << CQ_ENET_RQ_DESC_VLAN_TCI_VLAN_BITS) - 1)
+#define CQ_ENET_RQ_DESC_VLAN_TCI_CFI_MASK           (0x1 << 12)
+#define CQ_ENET_RQ_DESC_VLAN_TCI_USER_PRIO_BITS     3
+#define CQ_ENET_RQ_DESC_VLAN_TCI_USER_PRIO_MASK \
+	((1 << CQ_ENET_RQ_DESC_VLAN_TCI_USER_PRIO_BITS) - 1)
+#define CQ_ENET_RQ_DESC_VLAN_TCI_USER_PRIO_SHIFT    13
+
 #define CQ_ENET_RQ_DESC_FCOE_SOF_BITS               4
 #define CQ_ENET_RQ_DESC_FCOE_SOF_MASK \
 	((1 << CQ_ENET_RQ_DESC_FCOE_SOF_BITS) - 1)
@@ -96,7 +105,7 @@ static inline void cq_enet_rq_desc_dec(struct cq_enet_rq_desc *desc,
 	u8 *type, u8 *color, u16 *q_number, u16 *completed_index,
 	u8 *ingress_port, u8 *fcoe, u8 *eop, u8 *sop, u8 *rss_type,
 	u8 *csum_not_calc, u32 *rss_hash, u16 *bytes_written, u8 *packet_error,
-	u8 *vlan_stripped, u16 *vlan, u16 *checksum, u8 *fcoe_sof,
+	u8 *vlan_stripped, u16 *vlan_tci, u16 *checksum, u8 *fcoe_sof,
 	u8 *fcoe_fc_crc_ok, u8 *fcoe_enc_error, u8 *fcoe_eof,
 	u8 *tcp_udp_csum_ok, u8 *udp, u8 *tcp, u8 *ipv4_csum_ok,
 	u8 *ipv6, u8 *ipv4, u8 *ipv4_fragment, u8 *fcs_ok)
@@ -136,7 +145,10 @@ static inline void cq_enet_rq_desc_dec(struct cq_enet_rq_desc *desc,
 	*vlan_stripped = (bytes_written_flags &
 		CQ_ENET_RQ_DESC_FLAGS_VLAN_STRIPPED) ? 1 : 0;
 
-	*vlan = le16_to_cpu(desc->vlan);
+	/*
+	 * Tag Control Information(16) = user_priority(3) + cfi(1) + vlan(12)
+	 */
+	*vlan_tci = le16_to_cpu(desc->vlan);
 
 	if (*fcoe) {
 		*fcoe_sof = (u8)(le16_to_cpu(desc->checksum_fcoe) &
diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.c
index c2b848f..7f98af1 100644
--- a/drivers/net/enic/enic_main.c
+++ b/drivers/net/enic/enic_main.c
@@ -1300,7 +1300,7 @@ static void enic_rq_indicate_buf(struct vnic_rq *rq,
 	u8 tcp_udp_csum_ok, udp, tcp, ipv4_csum_ok;
 	u8 ipv6, ipv4, ipv4_fragment, fcs_ok, rss_type, csum_not_calc;
 	u8 packet_error;
-	u16 q_number, completed_index, bytes_written, vlan, checksum;
+	u16 q_number, completed_index, bytes_written, vlan_tci, checksum;
 	u32 rss_hash;
 
 	if (skipped)
@@ -1315,7 +1315,7 @@ static void enic_rq_indicate_buf(struct vnic_rq *rq,
 		&type, &color, &q_number, &completed_index,
 		&ingress_port, &fcoe, &eop, &sop, &rss_type,
 		&csum_not_calc, &rss_hash, &bytes_written,
-		&packet_error, &vlan_stripped, &vlan, &checksum,
+		&packet_error, &vlan_stripped, &vlan_tci, &checksum,
 		&fcoe_sof, &fcoe_fc_crc_ok, &fcoe_enc_error,
 		&fcoe_eof, &tcp_udp_csum_ok, &udp, &tcp,
 		&ipv4_csum_ok, &ipv6, &ipv4, &ipv4_fragment,
@@ -1350,14 +1350,15 @@ static void enic_rq_indicate_buf(struct vnic_rq *rq,
 
 		skb->dev = netdev;
 
-		if (enic->vlan_group && vlan_stripped) {
+		if (enic->vlan_group && vlan_stripped &&
+			(vlan_tci & CQ_ENET_RQ_DESC_VLAN_TCI_VLAN_MASK)) {
 
 			if (netdev->features & NETIF_F_GRO)
 				vlan_gro_receive(&enic->napi, enic->vlan_group,
-					vlan, skb);
+					vlan_tci, skb);
 			else
 				vlan_hwaccel_receive_skb(skb,
-					enic->vlan_group, vlan);
+					enic->vlan_group, vlan_tci);
 
 		} else {
 
@@ -1879,6 +1880,18 @@ static int enic_set_niccfg(struct enic *enic)
 		ig_vlan_strip_en);
 }
 
+int enic_dev_set_ig_vlan_rewrite_mode(struct enic *enic)
+{
+	int err;
+
+	spin_lock(&enic->devcmd_lock);
+	err = vnic_dev_set_ig_vlan_rewrite_mode(enic->vdev,
+		IG_VLAN_REWRITE_MODE_PRIORITY_TAG_DEFAULT_VLAN);
+	spin_unlock(&enic->devcmd_lock);
+
+	return err;
+}
+
 static void enic_reset(struct work_struct *work)
 {
 	struct enic *enic = container_of(work, struct enic, reset);
@@ -1898,6 +1911,7 @@ static void enic_reset(struct work_struct *work)
 	enic_reset_mcaddrs(enic);
 	enic_init_vnic_resources(enic);
 	enic_set_niccfg(enic);
+	enic_dev_set_ig_vlan_rewrite_mode(enic);
 	enic_open(enic->netdev);
 
 	rtnl_unlock();
@@ -2110,6 +2124,13 @@ int enic_dev_init(struct enic *enic)
 		goto err_out_free_vnic_resources;
 	}
 
+	err = enic_dev_set_ig_vlan_rewrite_mode(enic);
+	if (err) {
+		printk(KERN_ERR PFX
+			"Failed to set ingress vlan rewrite mode, aborting.\n");
+		goto err_out_free_vnic_resources;
+	}
+
 	switch (vnic_dev_get_intr_mode(enic->vdev)) {
 	default:
 		netif_napi_add(netdev, &enic->napi, enic_poll, 64);
diff --git a/drivers/net/enic/vnic_dev.c b/drivers/net/enic/vnic_dev.c
index e0d3328..e3742fa 100644
--- a/drivers/net/enic/vnic_dev.c
+++ b/drivers/net/enic/vnic_dev.c
@@ -564,6 +564,20 @@ int vnic_dev_del_addr(struct vnic_dev *vdev, u8 *addr)
 	return err;
 }
 
+int vnic_dev_set_ig_vlan_rewrite_mode(struct vnic_dev *vdev,
+	u8 ig_vlan_rewrite_mode)
+{
+	u64 a0 = ig_vlan_rewrite_mode, a1 = 0;
+	int wait = 1000;
+	int err;
+
+	err = vnic_dev_cmd(vdev, CMD_IG_VLAN_REWRITE_MODE, &a0, &a1, wait);
+	if (err == ERR_ECMDUNKNOWN)
+		return 0;
+
+	return err;
+}
+
 int vnic_dev_raise_intr(struct vnic_dev *vdev, u16 intr)
 {
 	u64 a0 = intr, a1 = 0;
diff --git a/drivers/net/enic/vnic_dev.h b/drivers/net/enic/vnic_dev.h
index caccce3..780c3cd 100644
--- a/drivers/net/enic/vnic_dev.h
+++ b/drivers/net/enic/vnic_dev.h
@@ -133,6 +133,8 @@ void vnic_dev_set_intr_mode(struct vnic_dev *vdev,
 	enum vnic_dev_intr_mode intr_mode);
 enum vnic_dev_intr_mode vnic_dev_get_intr_mode(struct vnic_dev *vdev);
 void vnic_dev_unregister(struct vnic_dev *vdev);
+int vnic_dev_set_ig_vlan_rewrite_mode(struct vnic_dev *vdev,
+	u8 ig_vlan_rewrite_mode);
 struct vnic_dev *vnic_dev_register(struct vnic_dev *vdev,
 	void *priv, struct pci_dev *pdev, struct vnic_dev_bar *bar,
 	unsigned int num_bars);
diff --git a/drivers/net/enic/vnic_devcmd.h b/drivers/net/enic/vnic_devcmd.h
index d78bbcc..c5ff4ff 100644
--- a/drivers/net/enic/vnic_devcmd.h
+++ b/drivers/net/enic/vnic_devcmd.h
@@ -211,6 +211,12 @@ enum vnic_devcmd_cmd {
 	 * in: (u16)a0=interrupt number to assert
 	 */
 	CMD_IAR			= _CMDCNW(_CMD_DIR_WRITE, _CMD_VTYPE_ALL, 38),
+
+	/*
+	 * Set hw ingress packet vlan rewrite mode:
+	 * in:  (u32)a0=new vlan rewrite mode
+	 * out: (u32)a0=old vlan rewrite mode */
+	CMD_IG_VLAN_REWRITE_MODE = _CMDC(_CMD_DIR_RW, _CMD_VTYPE_ENET, 41),
 };
 
 /* flags for CMD_OPEN */
@@ -226,6 +232,12 @@ enum vnic_devcmd_cmd {
 #define CMD_PFILTER_PROMISCUOUS		0x08
 #define CMD_PFILTER_ALL_MULTICAST	0x10
 
+/* rewrite modes for CMD_IG_VLAN_REWRITE_MODE */
+#define IG_VLAN_REWRITE_MODE_DEFAULT_TRUNK              0
+#define IG_VLAN_REWRITE_MODE_UNTAG_DEFAULT_VLAN         1
+#define IG_VLAN_REWRITE_MODE_PRIORITY_TAG_DEFAULT_VLAN  2
+#define IG_VLAN_REWRITE_MODE_PASS_THRU                  3
+
 enum vnic_devcmd_status {
 	STAT_NONE = 0,
 	STAT_BUSY = 1 << 0,	/* cmd in progress */

