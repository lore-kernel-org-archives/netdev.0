From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH net-next 2/4] drivers: net: xgene: Add support for RSS
Date: Tue,  2 Feb 2016 23:55:14 -0800
Message-ID: <1454486116-23783-3-git-send-email-isubramanian@apm.com>
References: <1454486116-23783-1-git-send-email-isubramanian@apm.com>
Cc: devicetree@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	patches@apm.com, toanle@apm.com,
	Iyappan Subramanian <isubramanian@apm.com>,
	Khuong Dinh <kdinh@apm.com>, Tanmay Inamdar <tinamdar@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:34278 "EHLO
	mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756213AbcBCHzP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2016 02:55:15 -0500
Received: by mail-pf0-f176.google.com with SMTP id o185so9628190pfb.1
        for <netdev@vger.kernel.org>; Tue, 02 Feb 2016 23:55:15 -0800 (PST)
In-Reply-To: <1454486116-23783-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
Signed-off-by: Khuong Dinh <kdinh@apm.com>
Signed-off-by: Tanmay Inamdar <tinamdar@apm.com>
Tested-by: Toan Le <toanle@apm.com>
---
 drivers/net/ethernet/apm/xgene/xgene_enet_cle.c | 386 +++++++++++++++++++++++-
 drivers/net/ethernet/apm/xgene/xgene_enet_cle.h |  52 ++++
 2 files changed, 433 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_cle.c b/drivers/net/ethernet/apm/xgene/xgene_enet_cle.c
index 7eea982..d51268f 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_cle.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_cle.c
@@ -21,6 +21,25 @@
 
 #include "xgene_enet_main.h"
 
+/* interfaces to convert structures to HW recognized bit formats */
+static void xgene_cle_sband_to_hw(u8 frag, enum xgene_cle_prot_version ver,
+				  enum xgene_cle_prot_type type, u32 len,
+				  u32 *reg)
+{
+	*reg =  XGENE_CLE_RSS_WR(SB_IPFRAG, frag) |
+		XGENE_CLE_RSS_WR(SB_IPPROT, type) |
+		XGENE_CLE_RSS_WR(SB_IPVER, ver) |
+		XGENE_CLE_RSS_WR(SB_HDRLEN, len);
+}
+
+static void xgene_cle_idt_to_hw(u32 dstqid, u32 fpsel,
+				u32 nfpsel, u32 *idt_reg)
+{
+	*idt_reg =  XGENE_CLE_RSS_WR(IDT_DSTQID, dstqid) |
+		    XGENE_CLE_RSS_WR(IDT_FPSEL, fpsel) |
+		    XGENE_CLE_RSS_WR(IDT_NFPSEL, nfpsel);
+}
+
 static void xgene_cle_dbptr_to_hw(struct xgene_enet_pdata *pdata,
 				  struct xgene_cle_dbptr *dbptr, u32 *buf)
 {
@@ -258,29 +277,372 @@ static void xgene_cle_setup_def_dbptr(struct xgene_enet_pdata *pdata,
 	}
 }
 
+static int xgene_cle_set_rss_sband(struct xgene_enet_cle *cle)
+{
+	u32 sband, reg = 0;
+	u32 idx = CLE_PKTRAM_SIZE / sizeof(u32);
+	u32 mac_hdr_len = 14;
+	u32 ipv4_ihl = 5;
+	u32 hdr_len;
+	int ret;
+
+	/* Sideband: IPV4/TCP packets */
+	hdr_len = (mac_hdr_len << 5) | ipv4_ihl;
+	xgene_cle_sband_to_hw(0, XGENE_CLE_IPV4, XGENE_CLE_TCP, hdr_len, &reg);
+	sband = reg;
+
+	/* Sideband: IPv4/UDP packets */
+	hdr_len = (mac_hdr_len << 5) | ipv4_ihl;
+	xgene_cle_sband_to_hw(1, XGENE_CLE_IPV4, XGENE_CLE_UDP, hdr_len, &reg);
+	sband |= (reg << 16);
+
+	ret = xgene_cle_dram_wr(cle, &sband, 1, idx, PKT_RAM, CLE_CMD_WR);
+	if (ret)
+		return ret;
+
+	/* Sideband: IPv4/RAW packets */
+	hdr_len = (mac_hdr_len << 5) | ipv4_ihl;
+	xgene_cle_sband_to_hw(0, XGENE_CLE_IPV4, XGENE_CLE_OTHER,
+			      hdr_len, &reg);
+	sband = reg;
+
+	/* Sideband: Ethernet II/RAW packets */
+	hdr_len = (mac_hdr_len << 5);
+	xgene_cle_sband_to_hw(0, XGENE_CLE_IPV4, XGENE_CLE_OTHER,
+			      hdr_len, &reg);
+	sband |= (reg << 16);
+
+	ret = xgene_cle_dram_wr(cle, &sband, 1, idx + 1, PKT_RAM, CLE_CMD_WR);
+	if (ret)
+		return ret;
+
+	return 0;
+}
+
+static int xgene_cle_set_rss_skeys(struct xgene_enet_cle *cle)
+{
+	int ret = 0;
+	u32 secret_key_ipv4[4];  /* 16 Bytes*/
+
+	get_random_bytes(secret_key_ipv4, 16);
+	ret = xgene_cle_dram_wr(cle, secret_key_ipv4, 4, 0,
+				RSS_IPV4_HASH_SKEY, CLE_CMD_WR);
+	return ret;
+}
+
+static int xgene_cle_set_rss_idt(struct xgene_enet_pdata *pdata)
+{
+	int i, ret = 0;
+	u32 fpsel, dstqid, nfpsel, idt_reg;
+	u16 pool_id;
+
+	for (i = 0; i < XGENE_CLE_IDT_ENTRIES; i++) {
+		pool_id = pdata->rx_ring->buf_pool->id;
+		fpsel = xgene_enet_ring_bufnum(pool_id) - 0x20;
+		dstqid = xgene_enet_dst_ring_num(pdata->rx_ring);
+		nfpsel = 0;
+		idt_reg = 0;
+
+		xgene_cle_idt_to_hw(dstqid, fpsel, nfpsel, &idt_reg);
+		ret = xgene_cle_dram_wr(&pdata->cle, &idt_reg, 1, i,
+					RSS_IDT, CLE_CMD_WR);
+		if (ret)
+			return ret;
+	}
+
+	ret = xgene_cle_set_rss_skeys(&pdata->cle);
+	if (ret)
+		return ret;
+
+	return 0;
+}
+
+static int xgene_cle_setup_rss(struct xgene_enet_pdata *pdata)
+{
+	struct xgene_enet_cle *cle = &pdata->cle;
+	void __iomem *base = cle->base;
+	u32 offset, val = 0;
+	int i, ret = 0;
+
+	offset = CLE_PORT_OFFSET;
+	for (i = 0; i < cle->parsers; i++) {
+		if (cle->active_parser != PARSER_ALL)
+			offset = cle->active_parser * CLE_PORT_OFFSET;
+		else
+			offset = i * CLE_PORT_OFFSET;
+
+		/* enable RSS */
+		val = (RSS_IPV4_12B << 1) | 0x1;
+		writel(val, base + RSS_CTRL0 + offset);
+	}
+
+	/* setup sideband data */
+	ret = xgene_cle_set_rss_sband(cle);
+	if (ret)
+		return ret;
+
+	/* setup indirection table */
+	ret = xgene_cle_set_rss_idt(pdata);
+	if (ret)
+		return ret;
+
+	return 0;
+}
+
 static int xgene_enet_cle_init(struct xgene_enet_pdata *pdata)
 {
 	struct xgene_enet_cle *enet_cle = &pdata->cle;
 	struct xgene_cle_ptree *ptree = &enet_cle->ptree;
 	struct xgene_cle_dbptr dbptr[DB_MAX_PTRS];
 	struct xgene_cle_ptree_kn kn;
+	struct xgene_cle_ptree_branch *br;
 	u32 def_qid, def_fpsel, pool_id;
+	int ret;
 	struct xgene_cle_ptree_ewdn ptree_dn[] = {
 		{
 			/* PKT_TYPE_NODE */
 			.node_type = EWDN,
 			.last_node = 0,
-			.hdr_len_store = 0,
+			.hdr_len_store = 1,
 			.hdr_extn = NO_BYTE,
 			.byte_store = NO_BYTE,
 			.search_byte_store = NO_BYTE,
 			.result_pointer = DB_RES_DROP,
-			.num_branches = 1,
+			.num_branches = 2,
 			.branch = {
 				{
-					/* Allow all packet type */
+					/* IPV4 */
 					.valid = 0,
-					.next_packet_pointer = 0,
+					.next_packet_pointer = 22,
+					.jump_bw = JMP_FW,
+					.jump_rel = JMP_ABS,
+					.operation = EQT,
+					.next_node = PKT_PROT_NODE,
+					.next_branch = 0,
+					.data = 0x8,
+					.mask = 0xffff
+				},
+				{
+					.valid = 0,
+					.next_packet_pointer = 262,
+					.jump_bw = JMP_FW,
+					.jump_rel = JMP_ABS,
+					.operation = EQT,
+					.next_node = LAST_NODE,
+					.next_branch = 0,
+					.data = 0x0,
+					.mask = 0xffff
+				}
+			},
+		},
+		{
+			/* PKT_PROT_NODE */
+			.node_type = EWDN,
+			.last_node = 0,
+			.hdr_len_store = 1,
+			.hdr_extn = NO_BYTE,
+			.byte_store = NO_BYTE,
+			.search_byte_store = NO_BYTE,
+			.result_pointer = DB_RES_DROP,
+			.num_branches = 3,
+			.branch = {
+				{
+					/* TCP */
+					.valid = 1,
+					.next_packet_pointer = 26,
+					.jump_bw = JMP_FW,
+					.jump_rel = JMP_ABS,
+					.operation = EQT,
+					.next_node = RSS_IPV4_TCP_NODE,
+					.next_branch = 0,
+					.data = 0x0600,
+					.mask = 0xffff
+				},
+				{
+					/* UDP */
+					.valid = 1,
+					.next_packet_pointer = 26,
+					.jump_bw = JMP_FW,
+					.jump_rel = JMP_ABS,
+					.operation = EQT,
+					.next_node = RSS_IPV4_UDP_NODE,
+					.next_branch = 0,
+					.data = 0x1100,
+					.mask = 0xffff
+				},
+				{
+					.valid = 0,
+					.next_packet_pointer = 260,
+					.jump_bw = JMP_FW,
+					.jump_rel = JMP_ABS,
+					.operation = EQT,
+					.next_node = LAST_NODE,
+					.next_branch = 0,
+					.data = 0x0,
+					.mask = 0xffff
+				}
+			}
+		},
+		{
+			/* RSS_IPV4_TCP_NODE */
+			.node_type = EWDN,
+			.last_node = 0,
+			.hdr_len_store = 1,
+			.hdr_extn = NO_BYTE,
+			.byte_store = NO_BYTE,
+			.search_byte_store = BOTH_BYTES,
+			.result_pointer = DB_RES_DROP,
+			.num_branches = 6,
+			.branch = {
+				{
+					/* SRC IPV4 B01 */
+					.valid = 0,
+					.next_packet_pointer = 28,
+					.jump_bw = JMP_FW,
+					.jump_rel = JMP_ABS,
+					.operation = EQT,
+					.next_node = RSS_IPV4_TCP_NODE,
+					.next_branch = 1,
+					.data = 0x0,
+					.mask = 0xffff
+				},
+				{
+					/* SRC IPV4 B23 */
+					.valid = 0,
+					.next_packet_pointer = 30,
+					.jump_bw = JMP_FW,
+					.jump_rel = JMP_ABS,
+					.operation = EQT,
+					.next_node = RSS_IPV4_TCP_NODE,
+					.next_branch = 2,
+					.data = 0x0,
+					.mask = 0xffff
+				},
+				{
+					/* DST IPV4 B01 */
+					.valid = 0,
+					.next_packet_pointer = 32,
+					.jump_bw = JMP_FW,
+					.jump_rel = JMP_ABS,
+					.operation = EQT,
+					.next_node = RSS_IPV4_TCP_NODE,
+					.next_branch = 3,
+					.data = 0x0,
+					.mask = 0xffff
+				},
+				{
+					/* DST IPV4 B23 */
+					.valid = 0,
+					.next_packet_pointer = 34,
+					.jump_bw = JMP_FW,
+					.jump_rel = JMP_ABS,
+					.operation = EQT,
+					.next_node = RSS_IPV4_TCP_NODE,
+					.next_branch = 4,
+					.data = 0x0,
+					.mask = 0xffff
+				},
+				{
+					/* TCP SRC Port */
+					.valid = 0,
+					.next_packet_pointer = 36,
+					.jump_bw = JMP_FW,
+					.jump_rel = JMP_ABS,
+					.operation = EQT,
+					.next_node = RSS_IPV4_TCP_NODE,
+					.next_branch = 5,
+					.data = 0x0,
+					.mask = 0xffff
+				},
+				{
+					/* TCP DST Port */
+					.valid = 0,
+					.next_packet_pointer = 256,
+					.jump_bw = JMP_FW,
+					.jump_rel = JMP_ABS,
+					.operation = EQT,
+					.next_node = LAST_NODE,
+					.next_branch = 0,
+					.data = 0x0,
+					.mask = 0xffff
+				}
+			}
+		},
+		{
+			/* RSS_IPV4_UDP_NODE */
+			.node_type = EWDN,
+			.last_node = 0,
+			.hdr_len_store = 1,
+			.hdr_extn = NO_BYTE,
+			.byte_store = NO_BYTE,
+			.search_byte_store = BOTH_BYTES,
+			.result_pointer = DB_RES_DROP,
+			.num_branches = 6,
+			.branch = {
+				{
+					/* SRC IPV4 B01 */
+					.valid = 0,
+					.next_packet_pointer = 28,
+					.jump_bw = JMP_FW,
+					.jump_rel = JMP_ABS,
+					.operation = EQT,
+					.next_node = RSS_IPV4_UDP_NODE,
+					.next_branch = 1,
+					.data = 0x0,
+					.mask = 0xffff
+				},
+				{
+					/* SRC IPV4 B23 */
+					.valid = 0,
+					.next_packet_pointer = 30,
+					.jump_bw = JMP_FW,
+					.jump_rel = JMP_ABS,
+					.operation = EQT,
+					.next_node = RSS_IPV4_UDP_NODE,
+					.next_branch = 2,
+					.data = 0x0,
+					.mask = 0xffff
+				},
+				{
+					/* DST IPV4 B01 */
+					.valid = 0,
+					.next_packet_pointer = 32,
+					.jump_bw = JMP_FW,
+					.jump_rel = JMP_ABS,
+					.operation = EQT,
+					.next_node = RSS_IPV4_UDP_NODE,
+					.next_branch = 3,
+					.data = 0x0,
+					.mask = 0xffff
+				},
+				{
+					/* DST IPV4 B23 */
+					.valid = 0,
+					.next_packet_pointer = 34,
+					.jump_bw = JMP_FW,
+					.jump_rel = JMP_ABS,
+					.operation = EQT,
+					.next_node = RSS_IPV4_UDP_NODE,
+					.next_branch = 4,
+					.data = 0x0,
+					.mask = 0xffff
+				},
+				{
+					/* TCP SRC Port */
+					.valid = 0,
+					.next_packet_pointer = 36,
+					.jump_bw = JMP_FW,
+					.jump_rel = JMP_ABS,
+					.operation = EQT,
+					.next_node = RSS_IPV4_UDP_NODE,
+					.next_branch = 5,
+					.data = 0x0,
+					.mask = 0xffff
+				},
+				{
+					/* TCP DST Port */
+					.valid = 0,
+					.next_packet_pointer = 256,
 					.jump_bw = JMP_FW,
 					.jump_rel = JMP_ABS,
 					.operation = EQT,
@@ -295,7 +657,7 @@ static int xgene_enet_cle_init(struct xgene_enet_pdata *pdata)
 			/* LAST NODE */
 			.node_type = EWDN,
 			.last_node = 1,
-			.hdr_len_store = 0,
+			.hdr_len_store = 1,
 			.hdr_extn = NO_BYTE,
 			.byte_store = NO_BYTE,
 			.search_byte_store = NO_BYTE,
@@ -318,6 +680,20 @@ static int xgene_enet_cle_init(struct xgene_enet_pdata *pdata)
 	};
 
 	ptree->start_pkt = 12; /* Ethertype */
+	if (pdata->phy_mode == PHY_INTERFACE_MODE_XGMII) {
+		ret = xgene_cle_setup_rss(pdata);
+		if (ret) {
+			netdev_err(pdata->ndev, "RSS initialization failed\n");
+			return ret;
+		}
+	} else {
+		br = &ptree_dn[PKT_PROT_NODE].branch[0];
+		br->valid = 0;
+		br->next_packet_pointer = 260;
+		br->next_node = NEXT_NODE(LAST_NODE);
+		br->data = 0x0000;
+		br->mask = 0xffff;
+	}
 
 	def_qid = xgene_enet_dst_ring_num(pdata->rx_ring);
 	pool_id = pdata->rx_ring->buf_pool->id;
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_cle.h b/drivers/net/ethernet/apm/xgene/xgene_enet_cle.h
index 9696a57..a12ac8c 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_cle.h
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_cle.h
@@ -34,6 +34,7 @@
 #define SPPTR0			0x0104
 #define DFCLSRESDBPTR0		0x0108
 #define DFCLSRESDB00		0x010c
+#define RSS_CTRL0		0x0000013c
 
 #define CLE_CMD_TO		10	/* ms */
 #define CLE_PKTRAM_SIZE		256	/* bytes */
@@ -108,6 +109,9 @@
 
 enum xgene_cle_ptree_nodes {
 	PKT_TYPE_NODE,
+	PKT_PROT_NODE,
+	RSS_IPV4_TCP_NODE,
+	RSS_IPV4_UDP_NODE,
 	LAST_NODE,
 	MAX_NODES
 };
@@ -147,6 +151,8 @@ enum xgene_cle_parser {
 #define XGENE_CLE_DRAM(type)	(((type) & 0xf) << 28)
 enum xgene_cle_dram_type {
 	PKT_RAM,
+	RSS_IDT,
+	RSS_IPV4_HASH_SKEY,
 	PTREE_RAM = 0xc,
 	AVL_RAM,
 	DB_RAM
@@ -160,6 +166,22 @@ enum xgene_cle_cmd_type {
 	CLE_CMD_AVL_SRCH = 32
 };
 
+enum xgene_cle_ipv4_rss_hashtype {
+	RSS_IPV4_8B,
+	RSS_IPV4_12B,
+};
+
+enum xgene_cle_prot_type {
+	XGENE_CLE_TCP,
+	XGENE_CLE_UDP,
+	XGENE_CLE_ESP,
+	XGENE_CLE_OTHER
+};
+
+enum xgene_cle_prot_version {
+	XGENE_CLE_IPV4,
+};
+
 enum xgene_cle_ptree_dbptrs {
 	DB_RES_DROP,
 	DB_RES_DEF,
@@ -167,6 +189,36 @@ enum xgene_cle_ptree_dbptrs {
 	DB_MAX_PTRS
 };
 
+/* RSS sideband signal info */
+#define XGENE_CLE_SB_IPFRAG_WIDTH	1
+#define XGENE_CLE_SB_IPFRAG_SHIFT	0
+#define XGENE_CLE_SB_IPPROT_WIDTH	2
+#define XGENE_CLE_SB_IPPROT_SHIFT	1
+#define XGENE_CLE_SB_IPVER_WIDTH	1
+#define XGENE_CLE_SB_IPVER_SHIFT	3
+#define XGENE_CLE_SB_HDRLEN_WIDTH	12
+#define XGENE_CLE_SB_HDRLEN_SHIFT	4
+
+/* RSS indirection table */
+#define XGENE_CLE_IDT_ENTRIES		128
+#define XGENE_CLE_IDT_DSTQID_WIDTH	12
+#define XGENE_CLE_IDT_DSTQID_SHIFT	0
+#define XGENE_CLE_IDT_FPSEL_WIDTH	4
+#define XGENE_CLE_IDT_FPSEL_SHIFT	12
+#define XGENE_CLE_IDT_NFPSEL_WIDTH	4
+#define XGENE_CLE_IDT_NFPSEL_SHIFT	16
+
+/* RSS access macros */
+#define XGENE_CLE_RSS_MASK(field)	(((2 << \
+					(XGENE_CLE_##field##_WIDTH - 1)) - 1) \
+					<< XGENE_CLE_##field##_SHIFT)
+#define XGENE_CLE_RSS_RD(field, word)	(((word) & \
+					XGENE_CLE_RSS_MASK(field)) >> \
+					XGENE_CLE_##field##_SHIFT)
+#define XGENE_CLE_RSS_WR(field, word)	(((word) << \
+					XGENE_CLE_##field##_SHIFT) & \
+					XGENE_CLE_RSS_MASK(field))
+
 struct xgene_cle_ptree_branch {
 	bool valid;
 	u16 next_packet_pointer;
-- 
1.9.1
