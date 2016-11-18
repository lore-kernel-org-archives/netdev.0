From: "Vishwanathapura, Niranjana" <niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: [RFC 04/10] IB/hfi-vnic: VNIC Ethernet Management (EM) structure definitions
Date: Fri, 18 Nov 2016 14:42:12 -0800
Message-ID: <1479508938-63799-5-git-send-email-niranjana.vishwanathapura@intel.com>
References: <1479508938-63799-1-git-send-email-niranjana.vishwanathapura@intel.com>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Dennis Dalessandro <dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Niranjana Vishwanathapura <niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Sadanand Warrier <sadanand.warrier-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Tanya K Jajodia <tanya.k.jajodia-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1479508938-63799-1-git-send-email-niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Define VNIC EM MAD structures and the associated macros. These structures
are used for information exchange between VNIC EM agent on the HFI host
and the Ethernet manager.

Change-Id: If4837ec74e5b0eecc81774a52ab92fffea4b6338
Reviewed-by: Dennis Dalessandro <dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Signed-off-by: Niranjana Vishwanathapura <niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Signed-off-by: Sadanand Warrier <sadanand.warrier-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Signed-off-by: Tanya K Jajodia <tanya.k.jajodia-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
---
 .../sw/intel/vnic/hfi_vnic/hfi_vnic_encap.h        | 444 +++++++++++++++++++++
 .../sw/intel/vnic/hfi_vnic/hfi_vnic_internal.h     |  35 +-
 2 files changed, 478 insertions(+), 1 deletion(-)

diff --git a/drivers/infiniband/sw/intel/vnic/hfi_vnic/hfi_vnic_encap.h b/drivers/infiniband/sw/intel/vnic/hfi_vnic/hfi_vnic_encap.h
index 6786cce..9ed5221 100644
--- a/drivers/infiniband/sw/intel/vnic/hfi_vnic/hfi_vnic_encap.h
+++ b/drivers/infiniband/sw/intel/vnic/hfi_vnic/hfi_vnic_encap.h
@@ -52,11 +52,455 @@
  * and decapsulation of Ethernet packets
  */
 
+#include <linux/types.h>
+#include <rdma/ib_mad.h>
+
+/* Maximum number of vnics supported */
+#define HFI_MAX_VPORTS_SUPPORTED 256
+
+/* EMA class version */
+#define HFI_EMA_CLASS_VERSION               0x80
+
+/*
+ * Define the Intel vendor management class for HFI
+ * ETHERNET MANAGEMENT
+ */
+#define HFI_MGMT_CLASS_INTEL_EMA            0x34
+
+/* EM attribute IDs */
+#define HFI_EM_ATTR_CLASS_PORT_INFO                 0x0001
+#define HFI_EM_ATTR_VESWPORT_INFO                   0x0011
+#define HFI_EM_ATTR_VESWPORT_MAC_ENTRIES            0x0012
+#define HFI_EM_ATTR_IFACE_UCAST_MACS                0x0013
+#define HFI_EM_ATTR_IFACE_MCAST_MACS                0x0014
+#define HFI_EM_ATTR_DELETE_VESW                     0x0015
+#define HFI_EM_ATTR_VESWPORT_SUMMARY_COUNTERS       0x0020
+#define HFI_EM_ATTR_VESWPORT_ERROR_COUNTERS         0x0022
+
 #define HFI_VESW_MAX_NUM_DEF_PORT   16
 #define HFI_VNIC_MAX_NUM_PCP        8
 
+#define HFI_VNIC_EMA_DATA    (OPA_MGMT_MAD_SIZE - IB_MGMT_VENDOR_HDR)
+
+/* Defines for vendor specific notice(trap) attributes */
+#define HFI_INTEL_EMA_NOTICE_TYPE_INFO 0x04
+
+/* INTEL OUI */
+#define INTEL_OUI_1 0x00
+#define INTEL_OUI_2 0x06
+#define INTEL_OUI_3 0x6a
+
+/* Trap opcodes sent from VNIC */
+#define HFI_VESWPORT_TRAP_IFACE_UCAST_MAC_CHANGE 0x1
+#define HFI_VESWPORT_TRAP_IFACE_MCAST_MAC_CHANGE 0x2
+#define HFI_VESWPORT_TRAP_ETH_LINK_STATUS_CHANGE 0x3
+
 /* VNIC configured and operational state values */
 #define HFI_VNIC_STATE_DROP_ALL        0x1
 #define HFI_VNIC_STATE_FORWARDING      0x3
 
+/**
+ * struct hfi_vesw_info - HFI vnic switch information
+ * @fabric_id: 10-bit fabric id
+ * @vesw_id: 12-bit virtual ethernet switch id
+ * @def_port_mask: bitmask of default ports
+ * @pkey: partition key
+ * @u_mcast_dlid: unknown multicast dlid
+ * @u_ucast_dlid: array of unknown unicast dlids
+ * @eth_mtu: MTUs for each vlan PCP
+ * @eth_mtu_non_vlan: MTU for non vlan packets
+ */
+struct hfi_vesw_info {
+	__be16  fabric_id;
+	__be16  vesw_id;
+
+	u8      rsvd0[6];
+	__be16  def_port_mask;
+
+	u8      rsvd1[2];
+	__be16  pkey;
+
+	u8      rsvd2[4];
+	__be32  u_mcast_dlid;
+	__be32  u_ucast_dlid[HFI_VESW_MAX_NUM_DEF_PORT];
+
+	u8      rsvd3[44];
+	__be16  eth_mtu[HFI_VNIC_MAX_NUM_PCP];
+	__be16  eth_mtu_non_vlan;
+	u8      rsvd4[2];
+} __packed;
+
+/**
+ * struct hfi_per_veswport_info - HFI vnic per port information
+ * @port_num: port number
+ * @eth_link_status: current ethernet link state
+ * @base_mac_addr: base mac address
+ * @config_state: configured port state
+ * @oper_state: operational port state
+ * @max_mac_tbl_ent: max number of mac table entries
+ * @max_smac_ent: max smac entries in mac table
+ * @mac_tbl_digest: mac table digest
+ * @encap_slid: base slid for the port
+ * @pcp_to_sc_uc: sc by pcp index for unicast ethernet packets
+ * @pcp_to_vl_uc: vl by pcp index for unicast ethernet packets
+ * @pcp_to_sc_mc: sc by pcp index for multicast ethernet packets
+ * @pcp_to_vl_mc: vl by pcp index for multicast ethernet packets
+ * @non_vlan_sc_uc: sc for non-vlan unicast ethernet packets
+ * @non_vlan_vl_uc: vl for non-vlan unicast ethernet packets
+ * @non_vlan_sc_mc: sc for non-vlan multicast ethernet packets
+ * @non_vlan_vl_mc: vl for non-vlan multicast ethernet packets
+ * @uc_macs_gen_count: generation count for unicast macs list
+ * @mc_macs_gen_count: generation count for multicast macs list
+ */
+struct hfi_per_veswport_info {
+	__be32  port_num;
+
+	u8      eth_link_status;
+	u8      rsvd0[3];
+
+	u8      base_mac_addr[ETH_ALEN];
+	u8      config_state;
+	u8      oper_state;
+
+	__be16  max_mac_tbl_ent;
+	__be16  max_smac_ent;
+	__be32  mac_tbl_digest;
+	u8      rsvd1[4];
+
+	__be32  encap_slid;
+
+	u8      pcp_to_sc_uc[HFI_VNIC_MAX_NUM_PCP];
+	u8      pcp_to_vl_uc[HFI_VNIC_MAX_NUM_PCP];
+	u8      pcp_to_sc_mc[HFI_VNIC_MAX_NUM_PCP];
+	u8      pcp_to_vl_mc[HFI_VNIC_MAX_NUM_PCP];
+
+	u8      non_vlan_sc_uc;
+	u8      non_vlan_vl_uc;
+	u8      non_vlan_sc_mc;
+	u8      non_vlan_vl_mc;
+
+	u8      rsvd2[48];
+
+	__be16  uc_macs_gen_count;
+	__be16  mc_macs_gen_count;
+
+	u8      rsvd3[8];
+} __packed;
+
+/**
+ * struct hfi_veswport_info - HFI vnic port information
+ * @vesw: HFI vnic switch information
+ * @vport: HFI vnic per port information
+ *
+ * On host, each of the virtual ethernet ports belongs
+ * to a different virtual ethernet switches.
+ */
+struct hfi_veswport_info {
+	struct hfi_vesw_info          vesw;
+	struct hfi_per_veswport_info  vport;
+};
+
+/**
+ * union __hfi_vnic_dlid_sd - vnic dlid and side data needed.
+ * @sd_is_src_mac: 1 = entry is SMAC, 0 = not SMAC
+ * @dlid: Destination lid corresponding to MAC addr
+ */
+union __hfi_vnic_dlid_sd {
+	struct {
+		u32  sd_reserved    : 5;
+		u32  sd_is_src_mac  : 1;
+		u32  rsvd0          : 2;
+		u32  dlid           : 24;
+	};
+	u32 dw;
+};
+
+/* Same as __hfi_vnic_dlid_sd, but with a big endian attribute */
+union hfi_vnic_dlid_sd {
+	union __hfi_vnic_dlid_sd u;
+	__be32 dw;
+};
+
+/**
+ * struct hfi_veswport_mactable_entry - single entry in the forwarding table
+ * @mac_addr: MAC address
+ * @mac_addr_mask: MAC address bit mask
+ * @dlid_sd: Matching DLID and side data
+ *
+ * On the host each virtual ethernet port will have
+ * a forwarding table. These tables are used to
+ * map a MAC to a LID and other data. For more
+ * details see struct hfi_veswport_mactable_entries.
+ * This is the structure of a single mactable entry
+ */
+struct hfi_veswport_mactable_entry {
+	u8                      mac_addr[ETH_ALEN];
+	u8                      mac_addr_mask[ETH_ALEN];
+	union hfi_vnic_dlid_sd  dlid_sd;
+} __packed;
+
+/**
+ * struct hfi_veswport_mactable - Forwarding table array
+ * @offset: mac table starting offset
+ * @num_entries: Number of entries to get or set
+ * @mac_tbl_digest: mac table digest
+ * @tbl_entries[]: Array of table entries
+ *
+ * The EM sends down this structure in a MAD indicating
+ * the starting offset in the forwarding table that this
+ * entry is to be loaded into and the number of entries
+ * that that this MAD instance contains
+ * The mac_tbl_digest has been added to this MAD structure. It will be set by
+ * the EM and it will be used by the EM to check if there are any
+ * discrepancies with this value and the value
+ * maintained by the EM in the case of VNIC device being deleted or unloaded
+ * A new instantiation of a VNIC will always have a value of zero.
+ * This value is stored as part of the vnic adapter structure and will be
+ * accessed by the GET and SET routines for both the mactable entries and the
+ * veswport info.
+ */
+struct hfi_veswport_mactable {
+	__be16                              offset;
+	__be16                              num_entries;
+	__be32                              mac_tbl_digest;
+	struct hfi_veswport_mactable_entry  tbl_entries[0];
+} __packed;
+
+/**
+ * struct hfi_veswport_summary_counters - summary counters
+ * @vp_instance: vport instance on the HFI port
+ * @vesw_id: virtual ethernet switch id
+ * @veswport_num: virtual ethernet switch port number
+ * @tx_errors: transmit errors
+ * @rx_errors: receive errors
+ * @tx_packets: transmit packets
+ * @rx_packets: receive packets
+ * @tx_bytes: transmit bytes
+ * @rx_bytes: receive bytes
+ * @tx_unicast: unicast packets transmitted
+ * @tx_mcastbcast: multicast/broadcast packets transmitted
+ * @tx_untagged: non-vlan packets transmitted
+ * @tx_vlan: vlan packets transmitted
+ * @tx_64_size: transmit packet length is 64 bytes
+ * @tx_65_127: transmit packet length is >=65 and < 127 bytes
+ * @tx_128_255: transmit packet length is >=128 and < 255 bytes
+ * @tx_256_511: transmit packet length is >=256 and < 511 bytes
+ * @tx_512_1023: transmit packet length is >=512 and < 1023 bytes
+ * @tx_1024_1518: transmit packet length is >=1024 and < 1518 bytes
+ * @tx_1519_max: transmit packet length >= 1519 bytes
+ * @rx_unicast: unicast packets received
+ * @rx_mcastbcast: multicast/broadcast packets received
+ * @rx_untagged: non-vlan packets received
+ * @rx_vlan: vlan packets received
+ * @rx_64_size: received packet length is 64 bytes
+ * @rx_65_127: received packet length is >=65 and < 127 bytes
+ * @rx_128_255: received packet length is >=128 and < 255 bytes
+ * @rx_256_511: received packet length is >=256 and < 511 bytes
+ * @rx_512_1023: received packet length is >=512 and < 1023 bytes
+ * @rx_1024_1518: received packet length is >=1024 and < 1518 bytes
+ * @rx_1519_max: received packet length >= 1519 bytes
+ *
+ * All the above are counters of corresponding conditions.
+ */
+struct hfi_veswport_summary_counters {
+	__be16  vp_instance;
+	__be16  vesw_id;
+	__be32  veswport_num;
+
+	__be64  tx_errors;
+	__be64  rx_errors;
+	__be64  tx_packets;
+	__be64  rx_packets;
+	__be64  tx_bytes;
+	__be64  rx_bytes;
+
+	__be64  tx_unicast;
+	__be64  tx_mcastbcast;
+
+	__be64  tx_untagged;
+	__be64  tx_vlan;
+
+	__be64  tx_64_size;
+	__be64  tx_65_127;
+	__be64  tx_128_255;
+	__be64  tx_256_511;
+	__be64  tx_512_1023;
+	__be64  tx_1024_1518;
+	__be64  tx_1519_max;
+
+	__be64  rx_unicast;
+	__be64  rx_mcastbcast;
+
+	__be64  rx_untagged;
+	__be64  rx_vlan;
+
+	__be64  rx_64_size;
+	__be64  rx_65_127;
+	__be64  rx_128_255;
+	__be64  rx_256_511;
+	__be64  rx_512_1023;
+	__be64  rx_1024_1518;
+	__be64  rx_1519_max;
+
+	__be64  reserved[16];
+} __packed;
+
+/**
+ * struct hfi_veswport_error_counters - error counters
+ * @vp_instance: vport instance on the HFI port
+ * @vesw_id: virtual ethernet switch id
+ * @veswport_num: virtual ethernet switch port number
+ * @tx_errors: transmit errors
+ * @rx_errors: receive errors
+ * @tx_smac_filt: smac filter errors
+ * @tx_dlid_zero: transmit packets with invalid dlid
+ * @tx_logic: other transmit errors
+ * @tx_drop_state: packet tansmission in non-forward port state
+ * @rx_bad_veswid: received packet with invalid vesw id
+ * @rx_runt: received ethernet packet with length < 64 bytes
+ * @rx_oversize: received ethernet packet with length > MTU size
+ * @rx_eth_down: received packets when interface is down
+ * @rx_drop_state: received packets in non-forwarding port state
+ * @rx_logic: other receive errors
+ *
+ * All the above are counters of corresponding erorr conditions.
+ */
+struct hfi_veswport_error_counters {
+	__be16  vp_instance;
+	__be16  vesw_id;
+	__be32  veswport_num;
+
+	__be64  tx_errors;
+	__be64  rx_errors;
+
+	__be64  rsvd0;
+	__be64  tx_smac_filt;
+	__be64  rsvd1;
+	__be64  rsvd2;
+	__be64  rsvd3;
+	__be64  tx_dlid_zero;
+	__be64  rsvd4;
+	__be64  tx_logic;
+	__be64  rsvd5;
+	__be64  tx_drop_state;
+
+	__be64  rx_bad_veswid;
+	__be64  rsvd6;
+	__be64  rx_runt;
+	__be64  rx_oversize;
+	__be64  rsvd7;
+	__be64  rx_eth_down;
+	__be64  rx_drop_state;
+	__be64  rx_logic;
+	__be64  rsvd8;
+
+	__be64  rsvd9[16];
+} __packed;
+
+/**
+ * struct hfi_veswport_trap - Trap message sent to EM by VNIC
+ * @fabric_id: 10 bit fabric id
+ * @veswid: 12 bit virtual ethernet switch id
+ * @veswportnum: logical port number on the Virtual switch
+ * @hfiportnum: physical port num (redundant on host)
+ * @veswportindex: switch port index on hfi port 0 based
+ * @opcode: operation
+ * @reserved: 32 bit for alignment
+ *
+ * The VNIC will send trap messages to the Ethernet manager to
+ * inform it about changes to the VNIC config, behaviour etc.
+ * This is the format of the trap payload.
+ */
+struct hfi_veswport_trap {
+	__be16  fabric_id;
+	__be16  veswid;
+	__be32  veswportnum;
+	__be16  hfiportnum;
+	u8      veswportindex;
+	u8      opcode;
+	__be32  reserved;
+} __packed;
+
+/**
+ * struct hfi_vnic_iface_macs_entry - single entry in the mac list
+ * @mac_addr: MAC address
+ */
+struct hfi_vnic_iface_mac_entry {
+	u8 mac_addr[ETH_ALEN];
+};
+
+/**
+ * struct hfi_veswport_iface_macs - Msg to set globally administered MAC
+ * @start_idx: position of first entry (0 based)
+ * @num_macs_in_msg: number of MACs in this message
+ * @tot_macs_in_lst: The total number of MACs the agent has
+ * @gen_count: gen_count to indicate change
+ * @entry: The mac list entry
+ *
+ * Same attribute IDS and attribute modifiers as in locally administered
+ * addresses used to set globally administered addresses
+ */
+struct hfi_veswport_iface_macs {
+	__be16 start_idx;
+	__be16 num_macs_in_msg;
+	__be16 tot_macs_in_lst;
+	__be16 gen_count;
+	struct hfi_vnic_iface_mac_entry entry[0];
+} __packed;
+
+/**
+ * struct hfi_vnic_vema_mad - Generic VEMA MAD
+ * @mad_hdr: Generic MAD header
+ * @rmpp_hdr: RMPP header for vendor specific MADs
+ * @oui: Unique org identifier
+ * @data: MAD data
+ */
+struct hfi_vnic_vema_mad {
+	struct ib_mad_hdr  mad_hdr;
+	struct ib_rmpp_hdr rmpp_hdr;
+	u8                 reserved;
+	u8                 oui[3];
+	u8                 data[HFI_VNIC_EMA_DATA];
+};
+
+/**
+ * struct hfi_vnic_notice_attr - Generic Notice MAD
+ * @gen_type: Generic/Specific bit and type of notice
+ * @oui_1: Vendor ID byte 1
+ * @oui_2: Vendor ID byte 2
+ * @oui_3: Vendor ID byte 3
+ * @trap_num: Trap number
+ * @toggle_count: Notice toggle bit and count value
+ * @issuer_lid: Trap issuer's lid
+ * @issuer_gid: Issuer GID (only if Report method)
+ * @raw_data: Trap message body
+ */
+struct hfi_vnic_notice_attr {
+	u8     gen_type;
+	u8     oui_1;
+	u8     oui_2;
+	u8     oui_3;
+	__be16 trap_num;
+	__be16 toggle_count;
+	__be32 issuer_lid;
+	__be32 reserved;
+	u8     issuer_gid[16];
+	u8     raw_data[64];
+} __packed;
+
+/**
+ * struct hfi_vnic_vema_mad_trap - Generic VEMA MAD Trap
+ * @mad_hdr: Generic MAD header
+ * @rmpp_hdr: RMPP header for vendor specific MADs
+ * @oui: Unique org identifier
+ * @notice: Notice structure
+ */
+struct hfi_vnic_vema_mad_trap {
+	struct ib_mad_hdr            mad_hdr;
+	struct ib_rmpp_hdr           rmpp_hdr;
+	u8                           reserved;
+	u8                           oui[3];
+	struct hfi_vnic_notice_attr  notice;
+};
+
 #endif /* _HFI_VNIC_ENCAP_H */
diff --git a/drivers/infiniband/sw/intel/vnic/hfi_vnic/hfi_vnic_internal.h b/drivers/infiniband/sw/intel/vnic/hfi_vnic/hfi_vnic_internal.h
index 8a5e0c1..4dbb117 100644
--- a/drivers/infiniband/sw/intel/vnic/hfi_vnic/hfi_vnic_internal.h
+++ b/drivers/infiniband/sw/intel/vnic/hfi_vnic/hfi_vnic_internal.h
@@ -95,13 +95,15 @@ enum hfi_vnic_flags_t {
 
 /**
  * struct __hfi_vesw_info - HFI vnic virtual switch info
+ *
+ * Same as hfi_vesw_info without bitwise attribute.
  */
 struct __hfi_vesw_info {
 	u16  fabric_id;
 	u16  vesw_id;
 
 	u8   rsvd0[6];
-	u16  def_fw_id_mask;
+	u16  def_port_mask;
 
 	u8   rsvd1[2];
 	u16  pkey;
@@ -118,6 +120,8 @@ struct __hfi_vesw_info {
 
 /**
  * struct __hfi_per_veswport_info - HFI vnic per port info
+ *
+ * Same as hfi_per_veswport_info without bitwise attribute.
  */
 struct __hfi_per_veswport_info {
 	u32  port_num;
@@ -156,6 +160,8 @@ struct __hfi_per_veswport_info {
 
 /**
  * struct __hfi_veswport_info - HFI vnic port info
+ *
+ * Same as hfi_veswport_info without bitwise attribute.
  */
 struct __hfi_veswport_info {
 	struct __hfi_vesw_info            vesw;
@@ -163,6 +169,21 @@ struct __hfi_veswport_info {
 };
 
 /**
+ * struct __hfi_veswport_trap - HFI vnic trap info
+ *
+ * Same as hfi_veswport_trap without bitwise attribute.
+ */
+struct __hfi_veswport_trap {
+	u16	fabric_id;
+	u16	veswid;
+	u32	veswportnum;
+	u16	hfiportnum;
+	u8	veswportindex;
+	u8	opcode;
+	u32	reserved;
+} __packed;
+
+/**
  * struct hfi_vnic_rx_queue - HFI VNIC receive queue
  * @idx: queue index
  * @adapter: netdev adapter
@@ -210,6 +231,18 @@ struct hfi_vnic_adapter {
 #define v_notice(format, arg...) \
 	netdev_notice(adapter->netdev, format, ## arg)
 
+/* The maximum allowed entries in the mac table */
+#define HFI_VNIC_MAC_TBL_MAX_ENTRIES  2048
+/* Limit of smac entries in mac table */
+#define HFI_VNIC_MAX_SMAC_LIMIT       256
+
+/* The last octet of the MAC address is used as the key to the hash table */
+#define HFI_VNIC_MAC_HASH_IDX         5
+
+/* The VNIC MAC hash table is of size 2^8 */
+#define HFI_VNIC_MAC_TBL_HASH_BITS    8
+#define HFI_VNIC_MAC_TBL_SIZE  BIT(HFI_VNIC_MAC_TBL_HASH_BITS)
+
 extern char hfi_vnic_driver_name[];
 extern const char hfi_vnic_driver_version[];
 
-- 
1.8.3.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
