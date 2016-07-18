From: Amir Levy <amir.jer.levy@intel.com>
Subject: [PATCH v4 2/7] thunderbolt: Updating the register definitions
Date: Mon, 18 Jul 2016 13:00:35 +0300
Message-ID: <1468836040-28043-3-git-send-email-amir.jer.levy@intel.com>
References: <1468836040-28043-1-git-send-email-amir.jer.levy@intel.com>
Cc: linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, thunderbolt-linux@intel.com,
	mika.westerberg@intel.com, tomas.winkler@intel.com,
	Amir Levy <amir.jer.levy@intel.com>
To: andreas.noever@gmail.com, gregkh@linuxfoundation.org,
	bhelgaas@google.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1468836040-28043-1-git-send-email-amir.jer.levy@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adding more Thunderbolt(TM) register definitions
and some helper macros.

Signed-off-by: Amir Levy <amir.jer.levy@intel.com>
---
 drivers/thunderbolt/nhi_regs.h | 109 +++++++++++++++++++++++++++++++++++++++++
 1 file changed, 109 insertions(+)

diff --git a/drivers/thunderbolt/nhi_regs.h b/drivers/thunderbolt/nhi_regs.h
index 75cf069..b8e961f 100644
--- a/drivers/thunderbolt/nhi_regs.h
+++ b/drivers/thunderbolt/nhi_regs.h
@@ -9,6 +9,11 @@
 
 #include <linux/types.h>
 
+#define NHI_MMIO_BAR 0
+
+#define TBT_RING_MIN_NUM_BUFFERS	2
+#define TBT_RING_MAX_FRAME_SIZE		(4 * 1024)
+
 enum ring_flags {
 	RING_FLAG_ISOCH_ENABLE = 1 << 27, /* TX only? */
 	RING_FLAG_E2E_FLOW_CONTROL = 1 << 28,
@@ -39,6 +44,33 @@ struct ring_desc {
 	u32 time; /* write zero */
 } __packed;
 
+/**
+ * struct tbt_buf_desc - TX/RX ring buffer descriptor.
+ * This is same as struct ring_desc, but without the use of bitfields and
+ * with explicit endianity.
+ */
+struct tbt_buf_desc {
+	__le64 phys;
+	__le32 attributes;
+	__le32 time;
+};
+
+#define DESC_ATTR_LEN_SHIFT		0
+#define DESC_ATTR_LEN_MASK		GENMASK(11, DESC_ATTR_LEN_SHIFT)
+#define DESC_ATTR_EOF_SHIFT		12
+#define DESC_ATTR_EOF_MASK		GENMASK(15, DESC_ATTR_EOF_SHIFT)
+#define DESC_ATTR_SOF_SHIFT		16
+#define DESC_ATTR_SOF_MASK		GENMASK(19, DESC_ATTR_SOF_SHIFT)
+#define DESC_ATTR_TX_ISOCH_DMA_EN	BIT(20)	/* TX */
+#define DESC_ATTR_RX_CRC_ERR		BIT(20)	/* RX after use */
+#define DESC_ATTR_DESC_DONE		BIT(21)
+#define DESC_ATTR_REQ_STS		BIT(22)	/* TX and RX before use */
+#define DESC_ATTR_RX_BUF_OVRN_ERR	BIT(22)	/* RX after use */
+#define DESC_ATTR_INT_EN		BIT(23)
+#define DESC_ATTR_OFFSET_SHIFT		24
+#define DESC_ATTR_OFFSET_MASK		GENMASK(31, DESC_ATTR_OFFSET_SHIFT)
+
+
 /* NHI registers in bar 0 */
 
 /*
@@ -60,6 +92,30 @@ struct ring_desc {
  */
 #define REG_RX_RING_BASE	0x08000
 
+#define REG_RING_STEP			16
+#define REG_RING_PHYS_LO_OFFSET		0
+#define REG_RING_PHYS_HI_OFFSET		4
+#define REG_RING_CONS_PROD_OFFSET	8	/* cons - RO, prod - RW */
+#define REG_RING_CONS_SHIFT		0
+#define REG_RING_CONS_MASK		GENMASK(15, REG_RING_CONS_SHIFT)
+#define REG_RING_PROD_SHIFT		16
+#define REG_RING_PROD_MASK		GENMASK(31, REG_RING_PROD_SHIFT)
+#define REG_RING_SIZE_OFFSET		12
+#define REG_RING_SIZE_SHIFT		0
+#define REG_RING_SIZE_MASK		GENMASK(15, REG_RING_SIZE_SHIFT)
+#define REG_RING_BUF_SIZE_SHIFT		16
+#define REG_RING_BUF_SIZE_MASK		GENMASK(27, REG_RING_BUF_SIZE_SHIFT)
+
+#define TBT_RING_CONS_PROD_REG(iobase, ringbase, ringnumber) \
+			      ((iobase) + (ringbase) + \
+			      ((ringnumber) * REG_RING_STEP) + \
+			      REG_RING_CONS_PROD_OFFSET)
+
+#define TBT_REG_RING_PROD_EXTRACT(val) (((val) & REG_RING_PROD_MASK) >> \
+				       REG_RING_PROD_SHIFT)
+
+#define TBT_REG_RING_CONS_EXTRACT(val) (((val) & REG_RING_CONS_MASK) >> \
+				       REG_RING_CONS_SHIFT)
 /*
  * 32 bytes per entry, one entry for every hop (REG_HOP_COUNT)
  * 00: enum_ring_flags
@@ -77,6 +133,19 @@ struct ring_desc {
  * ..: unknown
  */
 #define REG_RX_OPTIONS_BASE	0x29800
+#define REG_RX_OPTS_TX_E2E_HOP_ID_SHIFT	12
+#define REG_RX_OPTS_TX_E2E_HOP_ID_MASK	\
+				GENMASK(22, REG_RX_OPTS_TX_E2E_HOP_ID_SHIFT)
+#define REG_RX_OPTS_MASK_OFFSET		4
+#define REG_RX_OPTS_MASK_EOF_SHIFT	0
+#define REG_RX_OPTS_MASK_EOF_MASK	GENMASK(15, REG_RX_OPTS_MASK_EOF_SHIFT)
+#define REG_RX_OPTS_MASK_SOF_SHIFT	16
+#define REG_RX_OPTS_MASK_SOF_MASK	GENMASK(31, REG_RX_OPTS_MASK_SOF_SHIFT)
+
+#define REG_OPTS_STEP			32
+#define REG_OPTS_E2E_EN			BIT(28)
+#define REG_OPTS_RAW			BIT(30)
+#define REG_OPTS_VALID			BIT(31)
 
 /*
  * three bitfields: tx, rx, rx overflow
@@ -86,6 +155,7 @@ struct ring_desc {
  */
 #define REG_RING_NOTIFY_BASE	0x37800
 #define RING_NOTIFY_REG_COUNT(nhi) ((31 + 3 * nhi->hop_count) / 32)
+#define REG_RING_NOTIFY_STEP	4
 
 /*
  * two bitfields: rx, tx
@@ -94,8 +164,47 @@ struct ring_desc {
  */
 #define REG_RING_INTERRUPT_BASE	0x38200
 #define RING_INTERRUPT_REG_COUNT(nhi) ((31 + 2 * nhi->hop_count) / 32)
+#define REG_RING_INT_TX_PROCESSED(ring_num)		BIT(ring_num)
+#define REG_RING_INT_RX_PROCESSED(ring_num, num_paths)	BIT((ring_num) + \
+							    (num_paths))
+#define RING_INT_DISABLE(base, val) iowrite32( \
+			ioread32((base) + REG_RING_INTERRUPT_BASE) & ~(val), \
+			(base) + REG_RING_INTERRUPT_BASE)
+#define RING_INT_ENABLE(base, val) iowrite32( \
+			ioread32((base) + REG_RING_INTERRUPT_BASE) | (val), \
+			(base) + REG_RING_INTERRUPT_BASE)
+#define RING_INT_DISABLE_TX(base, ring_num) \
+	RING_INT_DISABLE(base, REG_RING_INT_TX_PROCESSED(ring_num))
+#define RING_INT_DISABLE_RX(base, ring_num, num_paths) \
+	RING_INT_DISABLE(base, REG_RING_INT_RX_PROCESSED(ring_num, num_paths))
+#define RING_INT_ENABLE_TX(base, ring_num) \
+	RING_INT_ENABLE(base, REG_RING_INT_TX_PROCESSED(ring_num))
+#define RING_INT_ENABLE_RX(base, ring_num, num_paths) \
+	RING_INT_ENABLE(base, REG_RING_INT_RX_PROCESSED(ring_num, num_paths))
+#define RING_INT_DISABLE_TX_RX(base, ring_num, num_paths) \
+	RING_INT_DISABLE(base, REG_RING_INT_TX_PROCESSED(ring_num) | \
+			       REG_RING_INT_RX_PROCESSED(ring_num, num_paths))
+
+#define REG_RING_INTERRUPT_STEP	4
+
+#define REG_INT_THROTTLING_RATE	0x38c00
+#define REG_INT_THROTTLING_RATE_STEP	4
+#define NUM_INT_VECTORS			16
+
+#define REG_INT_VEC_ALLOC_BASE	0x38c40
+#define REG_INT_VEC_ALLOC_STEP		4
+#define REG_INT_VEC_ALLOC_FIELD_BITS	4
+#define REG_INT_VEC_ALLOC_FIELD_MASK	(BIT(REG_INT_VEC_ALLOC_FIELD_BITS) - 1)
+#define REG_INT_VEC_ALLOC_PER_REG	((BITS_PER_BYTE * sizeof(u32)) / \
+					 REG_INT_VEC_ALLOC_FIELD_BITS)
 
 /* The last 11 bits contain the number of hops supported by the NHI port. */
 #define REG_HOP_COUNT		0x39640
+#define REG_HOP_COUNT_TOTAL_PATHS_MASK	GENMASK(10, 0)
+
+#define REG_HOST_INTERFACE_RST	0x39858
+
+#define REG_DMA_MISC		0x39864
+#define REG_DMA_MISC_INT_AUTO_CLEAR	BIT(2)
 
 #endif
-- 
2.7.4
