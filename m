From: Neel Patel <neepatel@cisco.com>
Subject: [PATCH 1/4] drivers/net: enic: Adding support for Cisco Low Latency NIC
Date: Fri,  9 Aug 2013 11:38:52 -0700
Message-ID: <1376073535-17154-2-git-send-email-neepatel@cisco.com>
References: <1376073535-17154-1-git-send-email-neepatel@cisco.com>
Cc: Neel Patel <neepatel@cisco.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtv-iport-4.cisco.com ([173.36.130.15]:25682 "EHLO
	mtv-iport-4.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S968068Ab3HISi5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Aug 2013 14:38:57 -0400
In-Reply-To: <1376073535-17154-1-git-send-email-neepatel@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch,
	- Adds new firmware commands for the new Cisco Low Latency NIC
      (aka. USNIC).
    - Enables descriptor prefetch on the hardware. This feature
      reduces latency for small packet transmit.

Signed-off-by: Neel Patel <neepatel@cisco.com>
Signed-off-by: Nishank Trivedi <nistrive@cisco.com>
Signed-off-by: Christian Benvenuti <benve@cisco.com>
---
 drivers/net/ethernet/cisco/enic/enic.h        |   2 +-
 drivers/net/ethernet/cisco/enic/enic_res.h    |   9 +-
 drivers/net/ethernet/cisco/enic/vnic_dev.c    |   5 +
 drivers/net/ethernet/cisco/enic/vnic_dev.h    |   1 +
 drivers/net/ethernet/cisco/enic/vnic_devcmd.h | 176 +++++++++++++++++++++++++-
 drivers/net/ethernet/cisco/enic/vnic_rq.c     |   9 +-
 drivers/net/ethernet/cisco/enic/vnic_rq.h     |   5 +-
 drivers/net/ethernet/cisco/enic/vnic_wq.c     |   7 +-
 drivers/net/ethernet/cisco/enic/vnic_wq.h     |  86 ++++++++++++-
 9 files changed, 281 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/cisco/enic/enic.h b/drivers/net/ethernet/cisco/enic/enic.h
index 2e37c63..75e842d 100644
--- a/drivers/net/ethernet/cisco/enic/enic.h
+++ b/drivers/net/ethernet/cisco/enic/enic.h
@@ -33,7 +33,7 @@
 #define DRV_NAME		"enic"
 #define DRV_DESCRIPTION		"Cisco VIC Ethernet NIC Driver"
 #define DRV_VERSION		"2.1.1.39"
-#define DRV_COPYRIGHT		"Copyright 2008-2011 Cisco Systems, Inc"
+#define DRV_COPYRIGHT		"Copyright 2008-2013 Cisco Systems, Inc"
 
 #define ENIC_BARS_MAX		6
 
diff --git a/drivers/net/ethernet/cisco/enic/enic_res.h b/drivers/net/ethernet/cisco/enic/enic_res.h
index 25be273..69f60af 100644
--- a/drivers/net/ethernet/cisco/enic/enic_res.h
+++ b/drivers/net/ethernet/cisco/enic/enic_res.h
@@ -47,6 +47,9 @@ static inline void enic_queue_wq_desc_ex(struct vnic_wq *wq,
 	int offload_mode, int cq_entry, int sop, int eop, int loopback)
 {
 	struct wq_enet_desc *desc = vnic_wq_next_desc(wq);
+	u8 desc_skip_cnt = 1;
+	u8 compressed_send = 0;
+	u64 wrid = 0;
 
 	wq_enet_desc_enc(desc,
 		(u64)dma_addr | VNIC_PADDR_TARGET,
@@ -59,7 +62,8 @@ static inline void enic_queue_wq_desc_ex(struct vnic_wq *wq,
 		(u16)vlan_tag,
 		(u8)loopback);
 
-	vnic_wq_post(wq, os_buf, dma_addr, len, sop, eop);
+	vnic_wq_post(wq, os_buf, dma_addr, len, sop, eop, desc_skip_cnt,
+			(u8)cq_entry, compressed_send, wrid);
 }
 
 static inline void enic_queue_wq_desc_cont(struct vnic_wq *wq,
@@ -120,6 +124,7 @@ static inline void enic_queue_rq_desc(struct vnic_rq *rq,
 	dma_addr_t dma_addr, unsigned int len)
 {
 	struct rq_enet_desc *desc = vnic_rq_next_desc(rq);
+	u64 wrid = 0;
 	u8 type = os_buf_index ?
 		RQ_ENET_TYPE_NOT_SOP : RQ_ENET_TYPE_ONLY_SOP;
 
@@ -127,7 +132,7 @@ static inline void enic_queue_rq_desc(struct vnic_rq *rq,
 		(u64)dma_addr | VNIC_PADDR_TARGET,
 		type, (u16)len);
 
-	vnic_rq_post(rq, os_buf, os_buf_index, dma_addr, len);
+	vnic_rq_post(rq, os_buf, os_buf_index, dma_addr, len, wrid);
 }
 
 struct enic;
diff --git a/drivers/net/ethernet/cisco/enic/vnic_dev.c b/drivers/net/ethernet/cisco/enic/vnic_dev.c
index 97455c5..1b436b3 100644
--- a/drivers/net/ethernet/cisco/enic/vnic_dev.c
+++ b/drivers/net/ethernet/cisco/enic/vnic_dev.c
@@ -970,6 +970,11 @@ err_out:
 	return NULL;
 }
 
+struct pci_dev *vnic_dev_get_pdev(struct vnic_dev *vdev)
+{
+	return vdev->pdev;
+}
+
 int vnic_dev_init_prov2(struct vnic_dev *vdev, u8 *buf, u32 len)
 {
 	u64 a0, a1 = len;
diff --git a/drivers/net/ethernet/cisco/enic/vnic_dev.h b/drivers/net/ethernet/cisco/enic/vnic_dev.h
index f3d9b79..e670029 100644
--- a/drivers/net/ethernet/cisco/enic/vnic_dev.h
+++ b/drivers/net/ethernet/cisco/enic/vnic_dev.h
@@ -127,6 +127,7 @@ int vnic_dev_set_ig_vlan_rewrite_mode(struct vnic_dev *vdev,
 struct vnic_dev *vnic_dev_register(struct vnic_dev *vdev,
 	void *priv, struct pci_dev *pdev, struct vnic_dev_bar *bar,
 	unsigned int num_bars);
+struct pci_dev *vnic_dev_get_pdev(struct vnic_dev *vdev);
 int vnic_dev_init_prov2(struct vnic_dev *vdev, u8 *buf, u32 len);
 int vnic_dev_enable2(struct vnic_dev *vdev, int active);
 int vnic_dev_enable2_done(struct vnic_dev *vdev, int *status);
diff --git a/drivers/net/ethernet/cisco/enic/vnic_devcmd.h b/drivers/net/ethernet/cisco/enic/vnic_devcmd.h
index 23d5552..b9a0d78 100644
--- a/drivers/net/ethernet/cisco/enic/vnic_devcmd.h
+++ b/drivers/net/ethernet/cisco/enic/vnic_devcmd.h
@@ -281,11 +281,25 @@ enum vnic_devcmd_cmd {
 	 *              0 if no VIF-CONFIG-INFO TLV was ever received. */
 	CMD_CONFIG_INFO_GET     = _CMDC(_CMD_DIR_RW, _CMD_VTYPE_ALL, 44),
 
+	/* INT13 API: (u64)a0=paddr to vnic_int13_params struct
+	 *            (u32)a1=INT13_CMD_xxx
+	 */
+	CMD_INT13_ALL = _CMDC(_CMD_DIR_WRITE, _CMD_VTYPE_ALL, 45),
+
+	/* Set default vlan:
+	 * in: (u16)a0=new default vlan
+	 *     (u16)a1=zero for overriding vlan with param a0,
+	 *		       non-zero for resetting vlan to the default
+	 * out: (u16)a0=old default vlan
+	 */
+	CMD_SET_DEFAULT_VLAN = _CMDC(_CMD_DIR_RW, _CMD_VTYPE_ALL, 46),
+
 	/* init_prov_info2:
 	 * Variant of CMD_INIT_PROV_INFO, where it will not try to enable
 	 * the vnic until CMD_ENABLE2 is issued.
 	 *     (u64)a0=paddr of vnic_devcmd_provinfo
-	 *     (u32)a1=sizeof provision info */
+	 *     (u32)a1=sizeof provision info
+	 */
 	CMD_INIT_PROV_INFO2  = _CMDC(_CMD_DIR_WRITE, _CMD_VTYPE_ENET, 47),
 
 	/* enable2:
@@ -339,16 +353,57 @@ enum vnic_devcmd_cmd {
 	CMD_INTR_COAL_CONVERT = _CMDC(_CMD_DIR_READ, _CMD_VTYPE_ALL, 50),
 
 	/*
-	 * cmd_set_mac_addr
-	 *	set mac address
+	 * Set the predefined mac address as default
 	 * in:
 	 *   (u48)a0 = mac addr
-	 *
 	 */
 	CMD_SET_MAC_ADDR = _CMDC(_CMD_DIR_WRITE, _CMD_VTYPE_ENET, 55),
+
+	/* Update the provisioning info of the given VIF
+	 *     (u64)a0=paddr of vnic_devcmd_provinfo
+	 *     (u32)a1=sizeof provision info
+	 */
+	CMD_PROV_INFO_UPDATE = _CMDC(_CMD_DIR_WRITE, _CMD_VTYPE_ENET, 56),
+
+	/* Add a filter.
+	 * in: (u64) a0= filter address
+	 *     (u32) a1= size of filter
+	 * out: (u32) a0=filter identifier
+	 */
+	CMD_ADD_FILTER = _CMDC(_CMD_DIR_RW, _CMD_VTYPE_ENET, 58),
+
+	/* Delete a filter.
+	 * in: (u32) a0=filter identifier
+	 */
+	CMD_DEL_FILTER = _CMDC(_CMD_DIR_WRITE, _CMD_VTYPE_ENET, 59),
+
+	/* Enable a Queue Pair in User space NIC
+	 * in: (u32) a0=Queue Pair number
+	 *     (u32) a1= command
+	 */
+	CMD_QP_ENABLE = _CMDC(_CMD_DIR_WRITE, _CMD_VTYPE_ENET, 60),
+
+	/* Disable a Queue Pair in User space NIC
+	 * in: (u32) a0=Queue Pair number
+	 *     (u32) a1= command
+	 */
+	CMD_QP_DISABLE = _CMDC(_CMD_DIR_WRITE, _CMD_VTYPE_ENET, 61),
+
+	/* Stats dump Queue Pair in User space NIC
+	 * in: (u32) a0=Queue Pair number
+	 *     (u64) a1=host buffer addr for status dump
+	 *     (u32) a2=length of the buffer
+	 */
+	CMD_QP_STATS_DUMP = _CMDC(_CMD_DIR_WRITE, _CMD_VTYPE_ENET, 62),
+
+	/* Clear stats for Queue Pair in User space NIC
+	 * in: (u32) a0=Queue Pair number
+	 */
+	CMD_QP_STATS_CLEAR = _CMDC(_CMD_DIR_WRITE, _CMD_VTYPE_ENET, 63),
 };
 
 /* CMD_ENABLE2 flags */
+#define CMD_ENABLE2_STANDBY 0x0
 #define CMD_ENABLE2_ACTIVE  0x1
 
 /* flags for CMD_OPEN */
@@ -364,6 +419,9 @@ enum vnic_devcmd_cmd {
 #define CMD_PFILTER_PROMISCUOUS		0x08
 #define CMD_PFILTER_ALL_MULTICAST	0x10
 
+/* Commands for CMD_QP_ENABLE/CM_QP_DISABLE */
+#define CMD_QP_RQWQ                     0x0
+
 /* rewrite modes for CMD_IG_VLAN_REWRITE_MODE */
 #define IG_VLAN_REWRITE_MODE_DEFAULT_TRUNK              0
 #define IG_VLAN_REWRITE_MODE_UNTAG_DEFAULT_VLAN         1
@@ -390,6 +448,7 @@ enum vnic_devcmd_error {
 	ERR_EMAXRES = 10,
 	ERR_ENOTSUPPORTED = 11,
 	ERR_EINPROGRESS = 12,
+	ERR_MAX
 };
 
 /*
@@ -435,6 +494,115 @@ struct vnic_devcmd_provinfo {
 	u8 data[0];
 };
 
+/* These are used in flags field of different filters to denote
+ * valid fields used.
+ */
+#define FILTER_FIELD_VALID(fld) (1 << (fld - 1))
+
+#define FILTER_FIELDS_USNIC ( \
+			FILTER_FIELD_VALID(1) | \
+			FILTER_FIELD_VALID(2) | \
+			FILTER_FIELD_VALID(3) | \
+			FILTER_FIELD_VALID(4))
+
+#define FILTER_FIELDS_IPV4_5TUPLE ( \
+			FILTER_FIELD_VALID(1) | \
+			FILTER_FIELD_VALID(2) | \
+			FILTER_FIELD_VALID(3) | \
+			FILTER_FIELD_VALID(4) | \
+			FILTER_FIELD_VALID(5))
+
+#define FILTER_FIELDS_MAC_VLAN ( \
+			FILTER_FIELD_VALID(1) | \
+			FILTER_FIELD_VALID(2))
+
+#define FILTER_FIELD_USNIC_VLAN    FILTER_FIELD_VALID(1)
+#define FILTER_FIELD_USNIC_ETHTYPE FILTER_FIELD_VALID(2)
+#define FILTER_FIELD_USNIC_PROTO   FILTER_FIELD_VALID(3)
+#define FILTER_FIELD_USNIC_ID      FILTER_FIELD_VALID(4)
+
+struct filter_usnic_id {
+	u32 flags;
+	u16 vlan;
+	u16 ethtype;
+	u8 proto_version;
+	u32 usnic_id;
+} __packed;
+
+#define FILTER_FIELD_5TUP_PROTO  FILTER_FIELD_VALID(1)
+#define FILTER_FIELD_5TUP_SRC_AD FILTER_FIELD_VALID(2)
+#define FILTER_FIELD_5TUP_DST_AD FILTER_FIELD_VALID(3)
+#define FILTER_FIELD_5TUP_SRC_PT FILTER_FIELD_VALID(4)
+#define FILTER_FIELD_5TUP_DST_PT FILTER_FIELD_VALID(5)
+
+/* Enums for the protocol field. */
+enum protocol_e {
+	PROTO_UDP = 0,
+	PROTO_TCP = 1,
+};
+
+struct filter_ipv4_5tuple {
+	u32 flags;
+	u32 protocol;
+	u32 src_addr;
+	u32 dst_addr;
+	u16 src_port;
+	u16 dst_port;
+} __packed;
+
+#define FILTER_FIELD_VMQ_VLAN   FILTER_FIELD_VALID(1)
+#define FILTER_FIELD_VMQ_MAC    FILTER_FIELD_VALID(2)
+
+struct filter_mac_vlan {
+	u32 flags;
+	u16 vlan;
+	u8 mac_addr[6];
+} __packed;
+
+/* Specifies the filter_action type. */
+enum {
+	FILTER_ACTION_RQ_STEERING = 0,
+	FILTER_ACTION_MAX
+};
+
+struct filter_action {
+	u32 type;
+	union {
+		u32 rq_idx;
+	} u;
+} __packed;
+
+/* Specifies the filter type. */
+enum filter_type {
+	FILTER_USNIC_ID = 0,
+	FILTER_IPV4_5TUPLE = 1,
+	FILTER_MAC_VLAN = 2,
+	FILTER_MAX
+};
+
+struct filter {
+	u32 type;
+	union {
+		struct filter_usnic_id usnic;
+		struct filter_ipv4_5tuple ipv4;
+		struct filter_mac_vlan mac_vlan;
+	} u;
+} __packed;
+
+enum {
+	CLSF_TLV_FILTER = 0,
+	CLSF_TLV_ACTION = 1,
+};
+
+/* Maximum size of buffer to CMD_ADD_FILTER */
+#define FILTER_MAX_BUF_SIZE 100
+
+struct filter_tlv {
+	u_int32_t type;
+	u_int32_t length;
+	u_int32_t val[0];
+};
+
 /*
  * Writing cmd register causes STAT_BUSY to get set in status register.
  * When cmd completes, STAT_BUSY will be cleared.
diff --git a/drivers/net/ethernet/cisco/enic/vnic_rq.c b/drivers/net/ethernet/cisco/enic/vnic_rq.c
index 7e1488f..e003b48 100644
--- a/drivers/net/ethernet/cisco/enic/vnic_rq.c
+++ b/drivers/net/ethernet/cisco/enic/vnic_rq.c
@@ -30,16 +30,15 @@
 static int vnic_rq_alloc_bufs(struct vnic_rq *rq)
 {
 	struct vnic_rq_buf *buf;
-	struct vnic_dev *vdev;
 	unsigned int i, j, count = rq->ring.desc_count;
 	unsigned int blks = VNIC_RQ_BUF_BLKS_NEEDED(count);
 
-	vdev = rq->vdev;
-
 	for (i = 0; i < blks; i++) {
 		rq->bufs[i] = kzalloc(VNIC_RQ_BUF_BLK_SZ(count), GFP_ATOMIC);
-		if (!rq->bufs[i])
+		if (!rq->bufs[i]) {
+			pr_err("Failed to alloc rq_bufs\n");
 			return -ENOMEM;
+		}
 	}
 
 	for (i = 0; i < blks; i++) {
@@ -141,7 +140,7 @@ void vnic_rq_init(struct vnic_rq *rq, unsigned int cq_index,
 	unsigned int error_interrupt_enable,
 	unsigned int error_interrupt_offset)
 {
-	u32 fetch_index;
+	u32 fetch_index = 0;
 
 	/* Use current fetch_index as the ring starting point */
 	fetch_index = ioread32(&rq->ctrl->fetch_index);
diff --git a/drivers/net/ethernet/cisco/enic/vnic_rq.h b/drivers/net/ethernet/cisco/enic/vnic_rq.h
index 2056586..ee7bc95 100644
--- a/drivers/net/ethernet/cisco/enic/vnic_rq.h
+++ b/drivers/net/ethernet/cisco/enic/vnic_rq.h
@@ -72,6 +72,7 @@ struct vnic_rq_buf {
 	unsigned int len;
 	unsigned int index;
 	void *desc;
+	uint64_t wr_id;
 };
 
 struct vnic_rq {
@@ -110,7 +111,8 @@ static inline unsigned int vnic_rq_next_index(struct vnic_rq *rq)
 
 static inline void vnic_rq_post(struct vnic_rq *rq,
 	void *os_buf, unsigned int os_buf_index,
-	dma_addr_t dma_addr, unsigned int len)
+	dma_addr_t dma_addr, unsigned int len,
+	uint64_t wrid)
 {
 	struct vnic_rq_buf *buf = rq->to_use;
 
@@ -118,6 +120,7 @@ static inline void vnic_rq_post(struct vnic_rq *rq,
 	buf->os_buf_index = os_buf_index;
 	buf->dma_addr = dma_addr;
 	buf->len = len;
+	buf->wr_id = wrid;
 
 	buf = buf->next;
 	rq->to_use = buf;
diff --git a/drivers/net/ethernet/cisco/enic/vnic_wq.c b/drivers/net/ethernet/cisco/enic/vnic_wq.c
index 5e0d7a2..fff35d4 100644
--- a/drivers/net/ethernet/cisco/enic/vnic_wq.c
+++ b/drivers/net/ethernet/cisco/enic/vnic_wq.c
@@ -30,16 +30,15 @@
 static int vnic_wq_alloc_bufs(struct vnic_wq *wq)
 {
 	struct vnic_wq_buf *buf;
-	struct vnic_dev *vdev;
 	unsigned int i, j, count = wq->ring.desc_count;
 	unsigned int blks = VNIC_WQ_BUF_BLKS_NEEDED(count);
 
-	vdev = wq->vdev;
-
 	for (i = 0; i < blks; i++) {
 		wq->bufs[i] = kzalloc(VNIC_WQ_BUF_BLK_SZ(count), GFP_ATOMIC);
-		if (!wq->bufs[i])
+		if (!wq->bufs[i]) {
+			pr_err("Failed to alloc wq_bufs\n");
 			return -ENOMEM;
+		}
 	}
 
 	for (i = 0; i < blks; i++) {
diff --git a/drivers/net/ethernet/cisco/enic/vnic_wq.h b/drivers/net/ethernet/cisco/enic/vnic_wq.h
index 7dd937a..b655667 100644
--- a/drivers/net/ethernet/cisco/enic/vnic_wq.h
+++ b/drivers/net/ethernet/cisco/enic/vnic_wq.h
@@ -58,6 +58,10 @@ struct vnic_wq_buf {
 	unsigned int index;
 	int sop;
 	void *desc;
+	uint64_t wr_id; /* Cookie */
+	uint8_t cq_entry; /* Gets completion event from hw */
+	uint8_t desc_skip_cnt; /* Num descs to occupy */
+	uint8_t compressed_send; /* Both hdr and payload in one desc */
 };
 
 /* Break the vnic_wq_buf allocations into blocks of 32/64 entries */
@@ -100,16 +104,94 @@ static inline void *vnic_wq_next_desc(struct vnic_wq *wq)
 	return wq->to_use->desc;
 }
 
+#define PI_LOG2_CACHE_LINE_SIZE        5
+#define PI_INDEX_BITS            12
+#define PI_INDEX_MASK ((1U << PI_INDEX_BITS) - 1)
+#define PI_PREFETCH_LEN_MASK ((1U << PI_LOG2_CACHE_LINE_SIZE) - 1)
+#define PI_PREFETCH_LEN_OFF 16
+#define PI_PREFETCH_ADDR_BITS 43
+#define PI_PREFETCH_ADDR_MASK ((1ULL << PI_PREFETCH_ADDR_BITS) - 1)
+#define PI_PREFETCH_ADDR_OFF 21
+
+/* How many cache lines are touched by buffer (addr, len). */
+static inline unsigned int num_cache_lines_touched(dma_addr_t addr,
+	unsigned int len)
+{
+	const unsigned long mask = PI_PREFETCH_LEN_MASK;
+	const unsigned long laddr = (unsigned long)addr;
+	unsigned long lines, equiv_len;
+	/* A. If addr is aligned, our solution is just to round up len to the
+	 * next boundary.
+	 *
+	 *  e.g. addr = 0, len = 48
+	 * +--------------------+
+	 * |XXXXXXXXXXXXXXXXXXXX|    32-byte cacheline a
+	 * +--------------------+
+	 * |XXXXXXXXXX          |    cacheline b
+	 * +--------------------+
+	 *
+	 * B. If addr is not aligned, however, we may use an extra
+	 * cacheline.  e.g. addr = 12, len = 22
+	 *
+	 * +--------------------+
+	 * |       XXXXXXXXXXXXX|
+	 * +--------------------+
+	 * |XX                  |
+	 * +--------------------+
+	 *
+	 * Our solution is to make the problem equivalent to case A
+	 * above by adding the empty space in the first cacheline to the length:
+	 * unsigned long len;
+	 *
+	 * +--------------------+
+	 * |eeeeeeeXXXXXXXXXXXXX|    "e" is empty space, which we add to len
+	 * +--------------------+
+	 * |XX                  |
+	 * +--------------------+
+	 */
+	equiv_len = len + (laddr & mask);
+
+	/* Now we can just round up this len to the next 32-byte boundary. */
+	lines = (equiv_len + mask) & (~mask);
+
+	/* Scale bytes -> cachelines. */
+	return lines >> PI_LOG2_CACHE_LINE_SIZE;
+}
+
+static inline u64 vnic_cached_posted_index(dma_addr_t addr,
+	unsigned int len, unsigned int index)
+{
+	unsigned int num_cache_lines = num_cache_lines_touched(addr, len);
+	/* Wish we could avoid a branch here.  We could have separate
+	 * vnic_wq_post() and vinc_wq_post_inline(), the latter
+	 * only supporting < 1k (2^5 * 2^5) sends, I suppose.  This would
+	 * eliminate the if (eop) branch as well.
+	 */
+	if (num_cache_lines > PI_PREFETCH_LEN_MASK)
+		num_cache_lines = 0;
+	return (index & PI_INDEX_MASK) |
+		((num_cache_lines & PI_PREFETCH_LEN_MASK)
+		 << PI_PREFETCH_LEN_OFF) |
+			(((addr >> PI_LOG2_CACHE_LINE_SIZE) &
+			  PI_PREFETCH_ADDR_MASK) << PI_PREFETCH_ADDR_OFF);
+}
+
 static inline void vnic_wq_post(struct vnic_wq *wq,
 	void *os_buf, dma_addr_t dma_addr,
-	unsigned int len, int sop, int eop)
+	unsigned int len, int sop, int eop,
+	uint8_t desc_skip_cnt, uint8_t cq_entry,
+	uint8_t compressed_send, uint64_t wrid)
 {
 	struct vnic_wq_buf *buf = wq->to_use;
 
 	buf->sop = sop;
+	buf->cq_entry = cq_entry;
+	buf->compressed_send = compressed_send;
+	buf->desc_skip_cnt = desc_skip_cnt;
 	buf->os_buf = eop ? os_buf : NULL;
 	buf->dma_addr = dma_addr;
 	buf->len = len;
+	buf->wr_id = wrid;
 
 	buf = buf->next;
 	if (eop) {
@@ -123,7 +205,7 @@ static inline void vnic_wq_post(struct vnic_wq *wq,
 	}
 	wq->to_use = buf;
 
-	wq->ring.desc_avail--;
+	wq->ring.desc_avail -= desc_skip_cnt;
 }
 
 static inline void vnic_wq_service(struct vnic_wq *wq,
-- 
1.8.4-rc0
