From: Rajesh Borundia <rajesh.borundia@qlogic.com>
Subject: [PATCH net-next 4/4] netxen_nic: Fix estimation of recv MSS in case of LRO
Date: Tue, 8 May 2012 08:01:28 -0700
Message-ID: <1336489288-22347-5-git-send-email-rajesh.borundia@qlogic.com>
References: <1336489288-22347-1-git-send-email-rajesh.borundia@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>,
	Ameen Rahman <ameen.rahman@qlogic.com>,
	Sony Chacko <sony.chacko@qlogic.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from am1ehsobe001.messaging.microsoft.com ([213.199.154.204]:29685
	"EHLO am1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756189Ab2EHPRm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 May 2012 11:17:42 -0400
In-Reply-To: <1336489288-22347-1-git-send-email-rajesh.borundia@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

o Linux stack estimates MSS from skb->len or skb_shinfo(skb)->gso_size.
In case of LRO skb->len is aggregate of len of number of packets hence MSS
obtained using skb->len would be incorrect. Incorrect estimation of recv MSS
would lead to delayed acks in some traffic patterns (which sends two or three
packets and wait for ack and only then send remaining packets). This leads to
drop in performance. Hence we need to set gso_size to MSS obtained from firmware.

o This is fixed recently in firmware hence the MSS is obtained based on
capability. If fw is capable of sending the MSS then only driver sets the gso_size.

Signed-off-by: Rajesh Borundia <rajesh.borundia@qlogic.com>
---
 drivers/net/ethernet/qlogic/netxen/netxen_nic.h    |   10 ++++++++--
 .../net/ethernet/qlogic/netxen/netxen_nic_ctx.c    |    3 +++
 .../net/ethernet/qlogic/netxen/netxen_nic_hdr.h    |    1 +
 .../net/ethernet/qlogic/netxen/netxen_nic_init.c   |    4 +++-
 .../net/ethernet/qlogic/netxen/netxen_nic_main.c   |    9 ++++++++-
 5 files changed, 23 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic.h b/drivers/net/ethernet/qlogic/netxen/netxen_nic.h
index a43a26c..36ae0ae 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic.h
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic.h
@@ -53,8 +53,8 @@
 
 #define _NETXEN_NIC_LINUX_MAJOR 4
 #define _NETXEN_NIC_LINUX_MINOR 0
-#define _NETXEN_NIC_LINUX_SUBVERSION 78
-#define NETXEN_NIC_LINUX_VERSIONID  "4.0.78"
+#define _NETXEN_NIC_LINUX_SUBVERSION 79
+#define NETXEN_NIC_LINUX_VERSIONID  "4.0.79"
 
 #define NETXEN_VERSION_CODE(a, b, c)	(((a) << 24) + ((b) << 16) + (c))
 #define _major(v)	(((v) >> 24) & 0xff)
@@ -419,6 +419,8 @@ struct rcv_desc {
 	(((sts_data) >> 52) & 0x1)
 #define netxen_get_lro_sts_seq_number(sts_data)		\
 	((sts_data) & 0x0FFFFFFFF)
+#define netxen_get_lro_sts_mss(sts_data1)		\
+	((sts_data1 >> 32) & 0x0FFFF)
 
 
 struct status_desc {
@@ -794,6 +796,7 @@ struct netxen_cmd_args {
 #define NX_CAP0_JUMBO_CONTIGUOUS	NX_CAP_BIT(0, 7)
 #define NX_CAP0_LRO_CONTIGUOUS		NX_CAP_BIT(0, 8)
 #define NX_CAP0_HW_LRO			NX_CAP_BIT(0, 10)
+#define NX_CAP0_HW_LRO_MSS		NX_CAP_BIT(0, 21)
 
 /*
  * Context state
@@ -1073,6 +1076,8 @@ typedef struct {
 #define NX_FW_CAPABILITY_FVLANTX		(1 << 9)
 #define NX_FW_CAPABILITY_HW_LRO			(1 << 10)
 #define NX_FW_CAPABILITY_GBE_LINK_CFG		(1 << 11)
+#define NX_FW_CAPABILITY_MORE_CAPS		(1 << 31)
+#define NX_FW_CAPABILITY_2_LRO_MAX_TCP_SEG	(1 << 2)
 
 /* module types */
 #define LINKEVENT_MODULE_NOT_PRESENT			1
@@ -1155,6 +1160,7 @@ typedef struct {
 #define NETXEN_NIC_BRIDGE_ENABLED       0X10
 #define NETXEN_NIC_DIAG_ENABLED		0x20
 #define NETXEN_FW_RESET_OWNER           0x40
+#define NETXEN_FW_MSS_CAP	        0x80
 #define NETXEN_IS_MSI_FAMILY(adapter) \
 	((adapter)->flags & (NETXEN_NIC_MSI_ENABLED | NETXEN_NIC_MSIX_ENABLED))
 
diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_ctx.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_ctx.c
index c86ea12..7f556a8 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_ctx.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_ctx.c
@@ -328,6 +328,9 @@ nx_fw_cmd_create_rx_ctx(struct netxen_adapter *adapter)
 	cap = (NX_CAP0_LEGACY_CONTEXT | NX_CAP0_LEGACY_MN);
 	cap |= (NX_CAP0_JUMBO_CONTIGUOUS | NX_CAP0_LRO_CONTIGUOUS);
 
+	if (adapter->flags & NETXEN_FW_MSS_CAP)
+		cap |= NX_CAP0_HW_LRO_MSS;
+
 	prq->capabilities[0] = cpu_to_le32(cap);
 	prq->host_int_crb_mode =
 		cpu_to_le32(NX_HOST_INT_CRB_MODE_SHARED);
diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_hdr.h b/drivers/net/ethernet/qlogic/netxen/netxen_nic_hdr.h
index a41106b..28e0769 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_hdr.h
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_hdr.h
@@ -776,6 +776,7 @@ enum {
 #define CRB_SW_INT_MASK_3		(NETXEN_NIC_REG(0x1e8))
 
 #define CRB_FW_CAPABILITIES_1		(NETXEN_CAM_RAM(0x128))
+#define CRB_FW_CAPABILITIES_2		(NETXEN_CAM_RAM(0x12c))
 #define CRB_MAC_BLOCK_START		(NETXEN_CAM_RAM(0x1c0))
 
 /*
diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c
index 718b274..0d725dc 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c
@@ -1131,7 +1131,6 @@ netxen_validate_firmware(struct netxen_adapter *adapter)
 		 _build(file_fw_ver));
 		return -EINVAL;
 	}
-
 	val = nx_get_bios_version(adapter);
 	netxen_rom_fast_read(adapter, NX_BIOS_VERSION_OFFSET, (int *)&bios);
 	if ((__force u32)val != bios) {
@@ -1661,6 +1660,9 @@ netxen_process_lro(struct netxen_adapter *adapter,
 
 	length = skb->len;
 
+	if (adapter->flags & NETXEN_FW_MSS_CAP)
+		skb_shinfo(skb)->gso_size  =  netxen_get_lro_sts_mss(sts_data1);
+
 	netif_receive_skb(skb);
 
 	adapter->stats.lro_pkts++;
diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
index 05f3ffe..b025940 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
@@ -1184,6 +1184,7 @@ netxen_nic_attach(struct netxen_adapter *adapter)
 	int err, ring;
 	struct nx_host_rds_ring *rds_ring;
 	struct nx_host_tx_ring *tx_ring;
+	u32 capab2;
 
 	if (adapter->is_up == NETXEN_ADAPTER_UP_MAGIC)
 		return 0;
@@ -1192,6 +1193,13 @@ netxen_nic_attach(struct netxen_adapter *adapter)
 	if (err)
 		return err;
 
+	adapter->flags &= ~NETXEN_FW_MSS_CAP;
+	if (adapter->capabilities & NX_FW_CAPABILITY_MORE_CAPS) {
+		capab2 = NXRD32(adapter, CRB_FW_CAPABILITIES_2);
+		if (capab2 & NX_FW_CAPABILITY_2_LRO_MAX_TCP_SEG)
+			adapter->flags |= NETXEN_FW_MSS_CAP;
+	}
+
 	err = netxen_napi_add(adapter, netdev);
 	if (err)
 		return err;
@@ -1810,7 +1818,6 @@ netxen_tso_check(struct net_device *netdev,
 		flags = FLAGS_VLAN_TAGGED;
 
 	} else if (vlan_tx_tag_present(skb)) {
-
 		flags = FLAGS_VLAN_OOB;
 		vid = vlan_tx_tag_get(skb);
 		netxen_set_tx_vlan_tci(first_desc, vid);
-- 
1.7.3.3
