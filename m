From: Govindarajulu Varadarajan <gvaradar@cisco.com>
Subject: [PATCH 1/3 v2 net-next] enic: add devcmds for vxlan offload
Date: Wed,  8 Feb 2017 16:43:07 -0800
Message-ID: <20170209004309.1225-2-gvaradar@cisco.com>
References: <20170209004309.1225-1-gvaradar@cisco.com>
Cc: benve@cisco.com, Govindarajulu Varadarajan <gvaradar@cisco.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcdn-iport-7.cisco.com ([173.37.86.78]:29293 "EHLO
        rcdn-iport-7.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751636AbdBIBY6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 20:24:58 -0500
In-Reply-To: <20170209004309.1225-1-gvaradar@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds devcmds needed for vxlan offload. Implement 3 new devcmd

overlay_offload_ctrl: enable/disable offload
overlay_offload_cfg: update offload udp port number
get_supported_feature_ver: get hw supported offload version. Each
			   version has different bitmap for csum_ok/encap

Signed-off-by: Govindarajulu Varadarajan <gvaradar@cisco.com>
---
 drivers/net/ethernet/cisco/enic/vnic_dev.c    | 34 ++++++++++++++++++
 drivers/net/ethernet/cisco/enic/vnic_dev.h    |  5 +++
 drivers/net/ethernet/cisco/enic/vnic_devcmd.h | 51 +++++++++++++++++++++++++++
 drivers/net/ethernet/cisco/enic/vnic_enet.h   |  1 +
 4 files changed, 91 insertions(+)

diff --git a/drivers/net/ethernet/cisco/enic/vnic_dev.c b/drivers/net/ethernet/cisco/enic/vnic_dev.c
index 8f27df3207bc..1841ad45d215 100644
--- a/drivers/net/ethernet/cisco/enic/vnic_dev.c
+++ b/drivers/net/ethernet/cisco/enic/vnic_dev.c
@@ -1247,3 +1247,37 @@ int vnic_dev_classifier(struct vnic_dev *vdev, u8 cmd, u16 *entry,
 
 	return ret;
 }
+
+int vnic_dev_overlay_offload_ctrl(struct vnic_dev *vdev, u8 overlay, u8 config)
+{
+	u64 a0 = overlay;
+	u64 a1 = config;
+	int wait = 1000;
+
+	return vnic_dev_cmd(vdev, CMD_OVERLAY_OFFLOAD_CTRL, &a0, &a1, wait);
+}
+
+int vnic_dev_overlay_offload_cfg(struct vnic_dev *vdev, u8 overlay,
+				 u16 vxlan_udp_port_number)
+{
+	u64 a1 = vxlan_udp_port_number;
+	u64 a0 = overlay;
+	int wait = 1000;
+
+	return vnic_dev_cmd(vdev, CMD_OVERLAY_OFFLOAD_CFG, &a0, &a1, wait);
+}
+
+int vnic_dev_get_supported_feature_ver(struct vnic_dev *vdev, u8 feature,
+				       u64 *supported_versions)
+{
+	u64 a0 = feature;
+	int wait = 1000;
+	u64 a1 = 0;
+	int ret;
+
+	ret = vnic_dev_cmd(vdev, CMD_GET_SUPP_FEATURE_VER, &a0, &a1, wait);
+	if (!ret)
+		*supported_versions = a0;
+
+	return ret;
+}
diff --git a/drivers/net/ethernet/cisco/enic/vnic_dev.h b/drivers/net/ethernet/cisco/enic/vnic_dev.h
index 54156c484424..9d43d6bb9907 100644
--- a/drivers/net/ethernet/cisco/enic/vnic_dev.h
+++ b/drivers/net/ethernet/cisco/enic/vnic_dev.h
@@ -179,5 +179,10 @@ int vnic_dev_set_mac_addr(struct vnic_dev *vdev, u8 *mac_addr);
 int vnic_dev_classifier(struct vnic_dev *vdev, u8 cmd, u16 *entry,
 			struct filter *data);
 int vnic_devcmd_init(struct vnic_dev *vdev);
+int vnic_dev_overlay_offload_ctrl(struct vnic_dev *vdev, u8 overlay, u8 config);
+int vnic_dev_overlay_offload_cfg(struct vnic_dev *vdev, u8 overlay,
+				 u16 vxlan_udp_port_number);
+int vnic_dev_get_supported_feature_ver(struct vnic_dev *vdev, u8 feature,
+				       u64 *supported_versions);
 
 #endif /* _VNIC_DEV_H_ */
diff --git a/drivers/net/ethernet/cisco/enic/vnic_devcmd.h b/drivers/net/ethernet/cisco/enic/vnic_devcmd.h
index 2a812880b884..d83880b0d468 100644
--- a/drivers/net/ethernet/cisco/enic/vnic_devcmd.h
+++ b/drivers/net/ethernet/cisco/enic/vnic_devcmd.h
@@ -406,6 +406,31 @@ enum vnic_devcmd_cmd {
 	 * in: (u32) a0=Queue Pair number
 	 */
 	CMD_QP_STATS_CLEAR = _CMDC(_CMD_DIR_WRITE, _CMD_VTYPE_ENET, 63),
+
+	/* Use this devcmd for agreeing on the highest common version supported
+	 * by both driver and fw for features who need such a facility.
+	 * in:	(u64) a0 = feature (driver requests for the supported versions
+	 *	on this feature)
+	 * out: (u64) a0 = bitmap of all supported versions for that feature
+	 */
+	CMD_GET_SUPP_FEATURE_VER = _CMDC(_CMD_DIR_RW, _CMD_VTYPE_ENET, 69),
+
+	/* Control (Enable/Disable) overlay offloads on the given vnic
+	 * in: (u8) a0 = OVERLAY_FEATURE_NVGRE : NVGRE
+	 *	    a0 = OVERLAY_FEATURE_VXLAN : VxLAN
+	 * in: (u8) a1 = OVERLAY_OFFLOAD_ENABLE : Enable or
+	 *	    a1 = OVERLAY_OFFLOAD_DISABLE : Disable or
+	 *	    a1 = OVERLAY_OFFLOAD_ENABLE_V2 : Enable with version 2
+	 */
+	CMD_OVERLAY_OFFLOAD_CTRL = _CMDC(_CMD_DIR_WRITE, _CMD_VTYPE_ENET, 72),
+
+	/* Configuration of overlay offloads feature on a given vNIC
+	 * in: (u8) a0 = DEVCMD_OVERLAY_NVGRE : NVGRE
+	 *	    a0 = DEVCMD_OVERLAY_VXLAN : VxLAN
+	 * in: (u8) a1 = VXLAN_PORT_UPDATE : VxLAN
+	 * in: (u16) a2 = unsigned short int port information
+	 */
+	CMD_OVERLAY_OFFLOAD_CFG = _CMDC(_CMD_DIR_WRITE, _CMD_VTYPE_ENET, 73),
 };
 
 /* CMD_ENABLE2 flags */
@@ -657,4 +682,30 @@ struct devcmd2_result {
 #define DEVCMD2_RING_SIZE	32
 #define DEVCMD2_DESC_SIZE	128
 
+enum overlay_feature_t {
+	OVERLAY_FEATURE_NVGRE = 1,
+	OVERLAY_FEATURE_VXLAN,
+	OVERLAY_FEATURE_MAX,
+};
+
+enum overlay_ofld_cmd {
+	OVERLAY_OFFLOAD_ENABLE,
+	OVERLAY_OFFLOAD_DISABLE,
+	OVERLAY_OFFLOAD_ENABLE_P2,
+	OVERLAY_OFFLOAD_MAX,
+};
+
+#define OVERLAY_CFG_VXLAN_PORT_UPDATE	0
+
+/* Use this enum to get the supported versions for each of these features
+ * If you need to use the devcmd_get_supported_feature_version(), add
+ * the new feature into this enum and install function handler in devcmd.c
+ */
+enum vic_feature_t {
+	VIC_FEATURE_VXLAN,
+	VIC_FEATURE_RDMA,
+	VIC_FEATURE_VXLAN_PATCH,
+	VIC_FEATURE_MAX,
+};
+
 #endif /* _VNIC_DEVCMD_H_ */
diff --git a/drivers/net/ethernet/cisco/enic/vnic_enet.h b/drivers/net/ethernet/cisco/enic/vnic_enet.h
index 75aced2de869..7d6fbb5635a4 100644
--- a/drivers/net/ethernet/cisco/enic/vnic_enet.h
+++ b/drivers/net/ethernet/cisco/enic/vnic_enet.h
@@ -48,6 +48,7 @@ struct vnic_enet_config {
 #define VENETF_RSSHASH_IPV6_EX	0x200	/* Hash on IPv6 extended fields */
 #define VENETF_RSSHASH_TCPIPV6_EX 0x400	/* Hash on TCP + IPv6 ext. fields */
 #define VENETF_LOOP		0x800	/* Loopback enabled */
+#define VENETF_VXLAN		0x10000	/* VxLAN offload */
 
 #define VENET_INTR_TYPE_MIN	0	/* Timer specs min interrupt spacing */
 #define VENET_INTR_TYPE_IDLE	1	/* Timer specs idle time before irq */
-- 
2.11.0
