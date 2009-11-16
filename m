From: Eli Cohen <eli-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
Subject: [PATCHv6 07/10] ib_core: RDMAoE UD packet packing support
Date: Mon, 16 Nov 2009 17:53:54 +0200
Message-ID: <20091116155354.GH2463@mtls03>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux RDMA list <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, ewg <ewg-ZwoEplunGu1OwGhvXhtEPSCwEArCW2h5@public.gmane.org>
To: Roland Dreier <rdreier-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Add support functions to aid in packing RDMAoE packets.

Signed-off-by: Eli Cohen <eli-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
---
 drivers/infiniband/core/ud_header.c |  111 +++++++++++++++++++++++++++++++++++
 include/rdma/ib_pack.h              |   26 ++++++++
 2 files changed, 137 insertions(+), 0 deletions(-)

diff --git a/drivers/infiniband/core/ud_header.c b/drivers/infiniband/core/ud_header.c
index 8ec7876..d04b6f2 100644
--- a/drivers/infiniband/core/ud_header.c
+++ b/drivers/infiniband/core/ud_header.c
@@ -80,6 +80,29 @@ static const struct ib_field lrh_table[]  = {
 	  .size_bits    = 16 }
 };
 
+static const struct ib_field eth_table[]  = {
+	{ STRUCT_FIELD(eth, dmac_h),
+	  .offset_words = 0,
+	  .offset_bits  = 0,
+	  .size_bits    = 32 },
+	{ STRUCT_FIELD(eth, dmac_l),
+	  .offset_words = 1,
+	  .offset_bits  = 0,
+	  .size_bits    = 16 },
+	{ STRUCT_FIELD(eth, smac_h),
+	  .offset_words = 1,
+	  .offset_bits  = 16,
+	  .size_bits    = 16 },
+	{ STRUCT_FIELD(eth, smac_l),
+	  .offset_words = 2,
+	  .offset_bits  = 0,
+	  .size_bits    = 32 },
+	{ STRUCT_FIELD(eth, type),
+	  .offset_words = 3,
+	  .offset_bits  = 0,
+	  .size_bits    = 16 }
+};
+
 static const struct ib_field grh_table[]  = {
 	{ STRUCT_FIELD(grh, ip_version),
 	  .offset_words = 0,
@@ -241,6 +264,53 @@ void ib_ud_header_init(int     		    payload_bytes,
 EXPORT_SYMBOL(ib_ud_header_init);
 
 /**
+ * ib_rdmaoe_ud_header_init - Initialize UD header structure
+ * @payload_bytes:Length of packet payload
+ * @grh_present:GRH flag (if non-zero, GRH will be included)
+ * @header:Structure to initialize
+ *
+ * ib_rdmaoe_ud_header_init() initializes the grh.ip_version, grh.payload_length,
+ * grh.next_header, bth.opcode, bth.pad_count and
+ * bth.transport_header_version fields of a &struct eth_ud_header given
+ * the payload length and whether a GRH will be included.
+ */
+void ib_rdmaoe_ud_header_init(int     		    payload_bytes,
+			   int    		    grh_present,
+			   struct eth_ud_header    *header)
+{
+	int header_len;
+
+	memset(header, 0, sizeof *header);
+
+	header_len =
+		sizeof header->eth  +
+		IB_BTH_BYTES  +
+		IB_DETH_BYTES;
+	if (grh_present)
+		header_len += IB_GRH_BYTES;
+
+	header->grh_present          = grh_present;
+	if (grh_present) {
+		header->grh.ip_version      = 6;
+		header->grh.payload_length  =
+			cpu_to_be16((IB_BTH_BYTES     +
+				     IB_DETH_BYTES    +
+				     payload_bytes    +
+				     4                + /* ICRC     */
+				     3) & ~3);          /* round up */
+		header->grh.next_header     = 0x1b;
+	}
+
+	if (header->immediate_present)
+		header->bth.opcode           = IB_OPCODE_UD_SEND_ONLY_WITH_IMMEDIATE;
+	else
+		header->bth.opcode           = IB_OPCODE_UD_SEND_ONLY;
+	header->bth.pad_count                = (4 - payload_bytes) & 3;
+	header->bth.transport_header_version = 0;
+}
+EXPORT_SYMBOL(ib_rdmaoe_ud_header_init);
+
+/**
  * ib_ud_header_pack - Pack UD header struct into wire format
  * @header:UD header struct
  * @buf:Buffer to pack into
@@ -281,6 +351,47 @@ int ib_ud_header_pack(struct ib_ud_header *header,
 EXPORT_SYMBOL(ib_ud_header_pack);
 
 /**
+ * rdmaoe_ud_header_pack - Pack UD header struct into eth wire format
+ * @header:UD header struct
+ * @buf:Buffer to pack into
+ *
+ * ib_ud_header_pack() packs the UD header structure @header into wire
+ * format in the buffer @buf.
+ */
+int rdmaoe_ud_header_pack(struct eth_ud_header *header,
+		       void                 *buf)
+{
+	int len = 0;
+
+	ib_pack(eth_table, ARRAY_SIZE(eth_table),
+		&header->eth, buf);
+	len += IB_ETH_BYTES;
+
+	if (header->grh_present) {
+		ib_pack(grh_table, ARRAY_SIZE(grh_table),
+			&header->grh, buf + len);
+		len += IB_GRH_BYTES;
+	}
+
+	ib_pack(bth_table, ARRAY_SIZE(bth_table),
+		&header->bth, buf + len);
+	len += IB_BTH_BYTES;
+
+	ib_pack(deth_table, ARRAY_SIZE(deth_table),
+		&header->deth, buf + len);
+	len += IB_DETH_BYTES;
+
+	if (header->immediate_present) {
+		memcpy(buf + len, &header->immediate_data,
+		       sizeof header->immediate_data);
+		len += sizeof header->immediate_data;
+	}
+
+	return len;
+}
+EXPORT_SYMBOL(rdmaoe_ud_header_pack);
+
+/**
  * ib_ud_header_unpack - Unpack UD header struct from wire format
  * @header:UD header struct
  * @buf:Buffer to pack into
diff --git a/include/rdma/ib_pack.h b/include/rdma/ib_pack.h
index d7fc45c..bf199eb 100644
--- a/include/rdma/ib_pack.h
+++ b/include/rdma/ib_pack.h
@@ -37,6 +37,7 @@
 
 enum {
 	IB_LRH_BYTES  = 8,
+	IB_ETH_BYTES  = 14,
 	IB_GRH_BYTES  = 40,
 	IB_BTH_BYTES  = 12,
 	IB_DETH_BYTES = 8
@@ -210,6 +211,14 @@ struct ib_unpacked_deth {
 	__be32       source_qpn;
 };
 
+struct ib_unpacked_eth {
+	u8	dmac_h[4];
+	u8	dmac_l[2];
+	u8	smac_h[2];
+	u8	smac_l[4];
+	__be16	type;
+};
+
 struct ib_ud_header {
 	struct ib_unpacked_lrh  lrh;
 	int                     grh_present;
@@ -220,6 +229,16 @@ struct ib_ud_header {
 	__be32         		immediate_data;
 };
 
+struct eth_ud_header {
+	struct ib_unpacked_eth  eth;
+	int                     grh_present;
+	struct ib_unpacked_grh  grh;
+	struct ib_unpacked_bth  bth;
+	struct ib_unpacked_deth deth;
+	int            		immediate_present;
+	__be32         		immediate_data;
+};
+
 void ib_pack(const struct ib_field        *desc,
 	     int                           desc_len,
 	     void                         *structure,
@@ -234,10 +253,17 @@ void ib_ud_header_init(int     		   payload_bytes,
 		       int    		   grh_present,
 		       struct ib_ud_header *header);
 
+void ib_rdmaoe_ud_header_init(int     		   payload_bytes,
+			   int    		   grh_present,
+			   struct eth_ud_header   *header);
+
 int ib_ud_header_pack(struct ib_ud_header *header,
 		      void                *buf);
 
 int ib_ud_header_unpack(void                *buf,
 			struct ib_ud_header *header);
 
+int rdmaoe_ud_header_pack(struct eth_ud_header *header,
+		       void                 *buf);
+
 #endif /* IB_PACK_H */
-- 
1.6.5.2

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
