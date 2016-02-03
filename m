From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH net-next 1/4] drivers: net: xgene: Add support for Classifier engine
Date: Tue,  2 Feb 2016 23:55:13 -0800
Message-ID: <1454486116-23783-2-git-send-email-isubramanian@apm.com>
References: <1454486116-23783-1-git-send-email-isubramanian@apm.com>
Cc: devicetree@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	patches@apm.com, toanle@apm.com,
	Iyappan Subramanian <isubramanian@apm.com>,
	Khuong Dinh <kdinh@apm.com>, Tanmay Inamdar <tinamdar@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:36453 "EHLO
	mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755707AbcBCHzN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2016 02:55:13 -0500
Received: by mail-pf0-f179.google.com with SMTP id n128so9504929pfn.3
        for <netdev@vger.kernel.org>; Tue, 02 Feb 2016 23:55:13 -0800 (PST)
In-Reply-To: <1454486116-23783-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
Signed-off-by: Khuong Dinh <kdinh@apm.com>
Signed-off-by: Tanmay Inamdar <tinamdar@apm.com>
Tested-by: Toan Le <toanle@apm.com>
---
 drivers/net/ethernet/apm/xgene/Makefile          |   3 +-
 drivers/net/ethernet/apm/xgene/xgene_enet_cle.c  | 357 +++++++++++++++++++++++
 drivers/net/ethernet/apm/xgene/xgene_enet_cle.h  | 264 +++++++++++++++++
 drivers/net/ethernet/apm/xgene/xgene_enet_hw.h   |   1 +
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c |  29 +-
 drivers/net/ethernet/apm/xgene/xgene_enet_main.h |  14 +
 6 files changed, 659 insertions(+), 9 deletions(-)
 create mode 100644 drivers/net/ethernet/apm/xgene/xgene_enet_cle.c
 create mode 100644 drivers/net/ethernet/apm/xgene/xgene_enet_cle.h

diff --git a/drivers/net/ethernet/apm/xgene/Makefile b/drivers/net/ethernet/apm/xgene/Makefile
index 700b5ab..f46321f 100644
--- a/drivers/net/ethernet/apm/xgene/Makefile
+++ b/drivers/net/ethernet/apm/xgene/Makefile
@@ -3,5 +3,6 @@
 #
 
 xgene-enet-objs := xgene_enet_hw.o xgene_enet_sgmac.o xgene_enet_xgmac.o \
-		   xgene_enet_main.o xgene_enet_ring2.o xgene_enet_ethtool.o
+		   xgene_enet_main.o xgene_enet_ring2.o xgene_enet_ethtool.o \
+		   xgene_enet_cle.o
 obj-$(CONFIG_NET_XGENE) += xgene-enet.o
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_cle.c b/drivers/net/ethernet/apm/xgene/xgene_enet_cle.c
new file mode 100644
index 0000000..7eea982
--- /dev/null
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_cle.c
@@ -0,0 +1,357 @@
+/* Applied Micro X-Gene SoC Ethernet Classifier structures
+ *
+ * Copyright (c) 2016, Applied Micro Circuits Corporation
+ * Authors: Khuong Dinh <kdinh@apm.com>
+ *          Tanmay Inamdar <tinamdar@apm.com>
+ *          Iyappan Subramanian <isubramanian@apm.com>
+ *
+ * This program is free software; you can redistribute  it and/or modify it
+ * under  the terms of  the GNU General  Public License as published by the
+ * Free Software Foundation;  either version 2 of the  License, or (at your
+ * option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program.  If not, see <http://www.gnu.org/licenses/>.
+ */
+
+#include "xgene_enet_main.h"
+
+static void xgene_cle_dbptr_to_hw(struct xgene_enet_pdata *pdata,
+				  struct xgene_cle_dbptr *dbptr, u32 *buf)
+{
+	buf[4] = SET_VAL(CLE_FPSEL, dbptr->fpsel) |
+		 SET_VAL(CLE_DSTQIDL, dbptr->dstqid);
+
+	buf[5] = SET_VAL(CLE_DSTQIDH, (u32)dbptr->dstqid >> CLE_DSTQIDL_LEN) |
+		 SET_VAL(CLE_PRIORITY, dbptr->cle_priority);
+}
+
+static void xgene_cle_kn_to_hw(struct xgene_cle_ptree_kn *kn, u32 *buf)
+{
+	u32 i, j = 0;
+	u32 data;
+
+	buf[j++] = SET_VAL(CLE_TYPE, kn->node_type);
+	for (i = 0; i < kn->num_keys; i++) {
+		struct xgene_cle_ptree_key *key = &kn->key[i];
+
+		if (!(i % 2)) {
+			buf[j] = SET_VAL(CLE_KN_PRIO, key->priority) |
+				 SET_VAL(CLE_KN_RPTR, key->result_pointer);
+		} else {
+			data = SET_VAL(CLE_KN_PRIO, key->priority) |
+			       SET_VAL(CLE_KN_RPTR, key->result_pointer);
+			buf[j++] |= (data << 16);
+		}
+	}
+}
+
+static void xgene_cle_dn_to_hw(struct xgene_cle_ptree_ewdn *dn,
+			       u32 *buf, u32 jb)
+{
+	u32 i, j = 0;
+	u32 npp;
+	struct xgene_cle_ptree_branch *br;
+
+	buf[j++] = SET_VAL(CLE_DN_TYPE, dn->node_type) |
+		   SET_VAL(CLE_DN_LASTN, dn->last_node) |
+		   SET_VAL(CLE_DN_HLS, dn->hdr_len_store) |
+		   SET_VAL(CLE_DN_EXT, dn->hdr_extn) |
+		   SET_VAL(CLE_DN_BSTOR, dn->byte_store) |
+		   SET_VAL(CLE_DN_SBSTOR, dn->search_byte_store) |
+		   SET_VAL(CLE_DN_RPTR, dn->result_pointer);
+
+	for (i = 0; i < dn->num_branches; i++) {
+		br = &dn->branch[i];
+		npp = br->next_packet_pointer;
+
+		if ((br->jump_rel == JMP_ABS) && (npp < CLE_PKTRAM_SIZE))
+			npp += jb;
+
+		buf[j++] = SET_VAL(CLE_BR_VALID, br->valid) |
+			   SET_VAL(CLE_BR_NPPTR, npp) |
+			   SET_VAL(CLE_BR_JB, br->jump_bw) |
+			   SET_VAL(CLE_BR_JR, br->jump_rel) |
+			   SET_VAL(CLE_BR_OP, br->operation) |
+			   SET_VAL(CLE_BR_NNODE, br->next_node) |
+			   SET_VAL(CLE_BR_NBR, br->next_branch);
+
+		buf[j++] = SET_VAL(CLE_BR_DATA, br->data) |
+			   SET_VAL(CLE_BR_MASK, br->mask);
+	}
+}
+
+static int xgene_cle_poll_cmd_done(void __iomem *base,
+				   enum xgene_cle_cmd_type cmd)
+{
+	u32 status, loop = 10;
+	int ret = -EBUSY;
+
+	while (loop--) {
+		status = ioread32(base + INDCMD_STATUS);
+		if (status & cmd) {
+			ret = 0;
+			break;
+		}
+		usleep_range(1000, 2000);
+	}
+
+	return ret;
+}
+
+static int xgene_cle_dram_wr(struct xgene_enet_cle *cle, u32 *data, u8 nregs,
+			     u32 index, enum xgene_cle_dram_type type,
+			     enum xgene_cle_cmd_type cmd)
+{
+	void __iomem *base = cle->base;
+	enum xgene_cle_parser parser = cle->active_parser;
+	u32 i, j, ind_addr;
+	u8 port, nparsers;
+	int ret = 0;
+
+	/* PTREE_RAM onwards, DRAM regions are common for all parsers */
+	nparsers = (type >= PTREE_RAM) ? 1 : cle->parsers;
+
+	for (i = 0; i < nparsers; i++) {
+		port = i;
+		if ((type < PTREE_RAM) && (parser != PARSER_ALL))
+			port = parser;
+
+		ind_addr = XGENE_CLE_DRAM(type + (port * 4)) | index;
+		iowrite32(ind_addr, base + INDADDR);
+		for (j = 0; j < nregs; j++)
+			iowrite32(data[j], base + DATA_RAM0 + (j * 4));
+		iowrite32(cmd, base + INDCMD);
+
+		ret = xgene_cle_poll_cmd_done(base, cmd);
+		if (ret)
+			break;
+	}
+
+	return ret;
+}
+
+static void xgene_cle_enable_ptree(struct xgene_enet_pdata *pdata,
+				   struct xgene_enet_cle *cle)
+{
+	struct xgene_cle_ptree *ptree = &cle->ptree;
+	void __iomem *addr, *base = cle->base;
+	u32 offset = CLE_PORT_OFFSET;
+	u32 i;
+
+	/* 1G port has to advance 4 bytes and 10G has to advance 8 bytes */
+	ptree->start_pkt += cle->jump_bytes;
+	for (i = 0; i < cle->parsers; i++) {
+		if (cle->active_parser != PARSER_ALL)
+			addr = base + cle->active_parser * offset;
+		else
+			addr = base + (i * offset);
+
+		iowrite32(ptree->start_node & 0x3fff, addr + SNPTR0);
+		iowrite32(ptree->start_pkt & 0x1ff, addr + SPPTR0);
+	}
+}
+
+static int xgene_cle_setup_dbptr(struct xgene_enet_pdata *pdata,
+				 struct xgene_enet_cle *cle)
+{
+	struct xgene_cle_ptree *ptree = &cle->ptree;
+	struct xgene_cle_dbptr *dbptr = ptree->dbptr;
+	u32 buf[CLE_DRAM_REGS];
+	u32 i;
+	int ret;
+
+	memset(buf, 0, sizeof(buf));
+	for (i = 0; i < ptree->num_dbptr; i++) {
+		xgene_cle_dbptr_to_hw(pdata, &dbptr[i], buf);
+		ret = xgene_cle_dram_wr(cle, buf, 6, i + ptree->start_dbptr,
+					DB_RAM,	CLE_CMD_WR);
+		if (ret)
+			return ret;
+	}
+
+	return 0;
+}
+
+static int xgene_cle_setup_node(struct xgene_enet_pdata *pdata,
+				struct xgene_enet_cle *cle)
+{
+	struct xgene_cle_ptree *ptree = &cle->ptree;
+	struct xgene_cle_ptree_ewdn *dn = ptree->dn;
+	struct xgene_cle_ptree_kn *kn = ptree->kn;
+	u32 buf[CLE_DRAM_REGS];
+	int i, j, ret;
+
+	memset(buf, 0, sizeof(buf));
+	for (i = 0; i < ptree->num_dn; i++) {
+		xgene_cle_dn_to_hw(&dn[i], buf, cle->jump_bytes);
+		ret = xgene_cle_dram_wr(cle, buf, 17, i + ptree->start_node,
+					PTREE_RAM, CLE_CMD_WR);
+		if (ret)
+			return ret;
+	}
+
+	/* continue node index for key node */
+	memset(buf, 0, sizeof(buf));
+	for (j = i; j < (ptree->num_kn + ptree->num_dn); j++) {
+		xgene_cle_kn_to_hw(&kn[j - ptree->num_dn], buf);
+		ret = xgene_cle_dram_wr(cle, buf, 17, j + ptree->start_node,
+					PTREE_RAM, CLE_CMD_WR);
+		if (ret)
+			return ret;
+	}
+
+	return 0;
+}
+
+static int xgene_cle_setup_ptree(struct xgene_enet_pdata *pdata,
+				 struct xgene_enet_cle *cle)
+{
+	int ret;
+
+	ret = xgene_cle_setup_node(pdata, cle);
+	if (ret)
+		return ret;
+
+	ret = xgene_cle_setup_dbptr(pdata, cle);
+	if (ret)
+		return ret;
+
+	xgene_cle_enable_ptree(pdata, cle);
+
+	return 0;
+}
+
+static void xgene_cle_setup_def_dbptr(struct xgene_enet_pdata *pdata,
+				      struct xgene_enet_cle *enet_cle,
+				      struct xgene_cle_dbptr *dbptr,
+				      u32 index, u8 priority)
+{
+	void __iomem *base = enet_cle->base;
+	void __iomem *base_addr;
+	u32 buf[CLE_DRAM_REGS];
+	u32 def_cls, offset;
+	u32 i, j;
+
+	memset(buf, 0, sizeof(buf));
+	xgene_cle_dbptr_to_hw(pdata, dbptr, buf);
+
+	for (i = 0; i < enet_cle->parsers; i++) {
+		if (enet_cle->active_parser != PARSER_ALL) {
+			offset = enet_cle->active_parser *
+				CLE_PORT_OFFSET;
+		} else {
+			offset = i * CLE_PORT_OFFSET;
+		}
+
+		base_addr = base + DFCLSRESDB00 + offset;
+		for (j = 0; j < 6; j++)
+			iowrite32(buf[j], base_addr + (j * 4));
+
+		def_cls = ((priority & 0x7) << 10) | (index & 0x3ff);
+		iowrite32(def_cls, base + DFCLSRESDBPTR0 + offset);
+	}
+}
+
+static int xgene_enet_cle_init(struct xgene_enet_pdata *pdata)
+{
+	struct xgene_enet_cle *enet_cle = &pdata->cle;
+	struct xgene_cle_ptree *ptree = &enet_cle->ptree;
+	struct xgene_cle_dbptr dbptr[DB_MAX_PTRS];
+	struct xgene_cle_ptree_kn kn;
+	u32 def_qid, def_fpsel, pool_id;
+	struct xgene_cle_ptree_ewdn ptree_dn[] = {
+		{
+			/* PKT_TYPE_NODE */
+			.node_type = EWDN,
+			.last_node = 0,
+			.hdr_len_store = 0,
+			.hdr_extn = NO_BYTE,
+			.byte_store = NO_BYTE,
+			.search_byte_store = NO_BYTE,
+			.result_pointer = DB_RES_DROP,
+			.num_branches = 1,
+			.branch = {
+				{
+					/* Allow all packet type */
+					.valid = 0,
+					.next_packet_pointer = 0,
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
+			/* LAST NODE */
+			.node_type = EWDN,
+			.last_node = 1,
+			.hdr_len_store = 0,
+			.hdr_extn = NO_BYTE,
+			.byte_store = NO_BYTE,
+			.search_byte_store = NO_BYTE,
+			.result_pointer = DB_RES_DROP,
+			.num_branches = 1,
+			.branch = {
+				{
+					.valid = 0,
+					.next_packet_pointer = 0,
+					.jump_bw = JMP_FW,
+					.jump_rel = JMP_ABS,
+					.operation = EQT,
+					.next_node = MAX_NODES,
+					.next_branch = 0,
+					.data = 0,
+					.mask = 0xffff
+				}
+			}
+		}
+	};
+
+	ptree->start_pkt = 12; /* Ethertype */
+
+	def_qid = xgene_enet_dst_ring_num(pdata->rx_ring);
+	pool_id = pdata->rx_ring->buf_pool->id;
+	def_fpsel = xgene_enet_ring_bufnum(pool_id) - 0x20;
+
+	memset(dbptr, 0, sizeof(struct xgene_cle_dbptr) * DB_MAX_PTRS);
+	dbptr[DB_RES_ACCEPT].fpsel =  def_fpsel;
+	dbptr[DB_RES_ACCEPT].dstqid = def_qid;
+	dbptr[DB_RES_ACCEPT].cle_priority = 1;
+
+	dbptr[DB_RES_DEF].fpsel = def_fpsel;
+	dbptr[DB_RES_DEF].dstqid = def_qid;
+	dbptr[DB_RES_DEF].cle_priority = 7;
+	xgene_cle_setup_def_dbptr(pdata, enet_cle, &dbptr[DB_RES_DEF],
+				  DB_RES_ACCEPT, 7);
+
+	dbptr[DB_RES_DROP].drop = 1;
+
+	memset(&kn, 0, sizeof(kn));
+	kn.node_type = KN;
+	kn.num_keys = 1;
+	kn.key[0].priority = 0;
+	kn.key[0].result_pointer = DB_RES_ACCEPT;
+
+	ptree->dn = ptree_dn;
+	ptree->kn = &kn;
+	ptree->dbptr = dbptr;
+	ptree->num_dn = MAX_NODES;
+	ptree->num_kn = 1;
+	ptree->num_dbptr = DB_MAX_PTRS;
+
+	return xgene_cle_setup_ptree(pdata, enet_cle);
+}
+
+struct xgene_cle_ops xgene_cle3in_ops = {
+	.cle_init = xgene_enet_cle_init,
+};
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_cle.h b/drivers/net/ethernet/apm/xgene/xgene_enet_cle.h
new file mode 100644
index 0000000..9696a57
--- /dev/null
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_cle.h
@@ -0,0 +1,264 @@
+/* Applied Micro X-Gene SoC Ethernet Classifier structures
+ *
+ * Copyright (c) 2016, Applied Micro Circuits Corporation
+ * Authors: Khuong Dinh <kdinh@apm.com>
+ *          Tanmay Inamdar <tinamdar@apm.com>
+ *          Iyappan Subramanian <isubramanian@apm.com>
+ *
+ * This program is free software; you can redistribute  it and/or modify it
+ * under  the terms of  the GNU General  Public License as published by the
+ * Free Software Foundation;  either version 2 of the  License, or (at your
+ * option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program.  If not, see <http://www.gnu.org/licenses/>.
+ */
+
+#ifndef __XGENE_ENET_CLE_H__
+#define __XGENE_ENET_CLE_H__
+
+#include <linux/io.h>
+#include <linux/random.h>
+
+/* Register offsets */
+#define INDADDR			0x04
+#define INDCMD			0x08
+#define INDCMD_STATUS		0x0c
+#define DATA_RAM0		0x10
+#define SNPTR0			0x0100
+#define SPPTR0			0x0104
+#define DFCLSRESDBPTR0		0x0108
+#define DFCLSRESDB00		0x010c
+
+#define CLE_CMD_TO		10	/* ms */
+#define CLE_PKTRAM_SIZE		256	/* bytes */
+#define CLE_PORT_OFFSET		0x200
+#define CLE_DRAM_REGS		17
+
+#define CLE_DN_TYPE_LEN		2
+#define CLE_DN_TYPE_POS		0
+#define CLE_DN_LASTN_LEN	1
+#define CLE_DN_LASTN_POS	2
+#define CLE_DN_HLS_LEN		1
+#define CLE_DN_HLS_POS		3
+#define CLE_DN_EXT_LEN		2
+#define	CLE_DN_EXT_POS		4
+#define CLE_DN_BSTOR_LEN	2
+#define CLE_DN_BSTOR_POS	6
+#define CLE_DN_SBSTOR_LEN	2
+#define CLE_DN_SBSTOR_POS	8
+#define CLE_DN_RPTR_LEN		12
+#define CLE_DN_RPTR_POS		12
+
+#define CLE_BR_VALID_LEN	1
+#define CLE_BR_VALID_POS	0
+#define CLE_BR_NPPTR_LEN	9
+#define CLE_BR_NPPTR_POS	1
+#define CLE_BR_JB_LEN		1
+#define CLE_BR_JB_POS		10
+#define CLE_BR_JR_LEN		1
+#define CLE_BR_JR_POS		11
+#define CLE_BR_OP_LEN		3
+#define CLE_BR_OP_POS		12
+#define CLE_BR_NNODE_LEN	9
+#define CLE_BR_NNODE_POS	15
+#define CLE_BR_NBR_LEN		5
+#define CLE_BR_NBR_POS		24
+
+#define CLE_BR_DATA_LEN		16
+#define CLE_BR_DATA_POS		0
+#define CLE_BR_MASK_LEN		16
+#define CLE_BR_MASK_POS		16
+
+#define CLE_KN_PRIO_POS		0
+#define CLE_KN_PRIO_LEN		3
+#define CLE_KN_RPTR_POS		3
+#define CLE_KN_RPTR_LEN		10
+#define CLE_TYPE_POS		0
+#define CLE_TYPE_LEN		2
+
+#define CLE_DSTQIDL_POS		25
+#define CLE_DSTQIDL_LEN		7
+#define CLE_DSTQIDH_POS		0
+#define CLE_DSTQIDH_LEN		5
+#define CLE_FPSEL_POS		21
+#define CLE_FPSEL_LEN		4
+#define CLE_PRIORITY_POS	5
+#define CLE_PRIORITY_LEN	3
+
+/* Patricia tree node configuration */
+#define JMP_ABS			0
+#define JMP_REL			1
+#define JMP_FW			0
+#define JMP_BW			1
+#define SEARCH_STORE(b)		b
+#define BYTE_STORE(b)		b
+#define HDR_EXT(b)		b
+#define HLS(b)			b
+#define LN(b)			b
+#define VALID(b)		b
+#define NEXT_NODE(b)		b
+#define NEXT_BRANCH(b)		b
+#define KEY_INDEX(b)		b
+
+enum xgene_cle_ptree_nodes {
+	PKT_TYPE_NODE,
+	LAST_NODE,
+	MAX_NODES
+};
+
+enum xgene_cle_byte_store {
+	NO_BYTE,
+	FIRST_BYTE,
+	SECOND_BYTE,
+	BOTH_BYTES
+};
+
+/* Preclassification operation types */
+enum xgene_cle_node_type {
+	INV,
+	KN,
+	EWDN,
+	RES_NODE
+};
+
+/* Preclassification operation types */
+enum xgene_cle_op_type {
+	EQT,
+	NEQT,
+	LTEQT,
+	GTEQT,
+	AND,
+	NAND
+};
+
+enum xgene_cle_parser {
+	PARSER0,
+	PARSER1,
+	PARSER2,
+	PARSER_ALL
+};
+
+#define XGENE_CLE_DRAM(type)	(((type) & 0xf) << 28)
+enum xgene_cle_dram_type {
+	PKT_RAM,
+	PTREE_RAM = 0xc,
+	AVL_RAM,
+	DB_RAM
+};
+
+enum xgene_cle_cmd_type {
+	CLE_CMD_WR = 1,
+	CLE_CMD_RD = 2,
+	CLE_CMD_AVL_ADD = 8,
+	CLE_CMD_AVL_DEL = 16,
+	CLE_CMD_AVL_SRCH = 32
+};
+
+enum xgene_cle_ptree_dbptrs {
+	DB_RES_DROP,
+	DB_RES_DEF,
+	DB_RES_ACCEPT,
+	DB_MAX_PTRS
+};
+
+struct xgene_cle_ptree_branch {
+	bool valid;
+	u16 next_packet_pointer;
+	bool jump_bw;
+	bool jump_rel;
+	u8 operation;
+	u16 next_node;
+	u8 next_branch;
+	u16 data;
+	u16 mask;
+};
+
+struct xgene_cle_ptree_ewdn {
+	u8 node_type;
+	bool last_node;
+	bool hdr_len_store;
+	u8 hdr_extn;
+	u8 byte_store;
+	u8 search_byte_store;
+	u16 result_pointer;
+	u8 num_branches;
+	struct xgene_cle_ptree_branch branch[8];
+};
+
+struct xgene_cle_ptree_key {
+	u8 priority;
+	u16 result_pointer;
+};
+
+struct xgene_cle_ptree_kn {
+	u8 node_type;
+	u8 num_keys;
+	struct xgene_cle_ptree_key key[32];
+};
+
+struct xgene_cle_dbptr {
+	u8 split_boundary;
+	u8 mirror_nxtfpsel;
+	u8 mirror_fpsel;
+	u16 mirror_dstqid;
+	u8 drop;
+	u8 mirror;
+	u8 hdr_data_split;
+	u64 hopinfomsbs;
+	u8 DR;
+	u8 HR;
+	u64 hopinfomlsbs;
+	u16 h0enq_num;
+	u8 h0fpsel;
+	u8 nxtfpsel;
+	u8 fpsel;
+	u16 dstqid;
+	u8 cle_priority;
+	u8 cle_flowgroup;
+	u8 cle_perflow;
+	u8 cle_insert_timestamp;
+	u8 stash;
+	u8 in;
+	u8 perprioen;
+	u8 perflowgroupen;
+	u8 perflowen;
+	u8 selhash;
+	u8 selhdrext;
+	u8 mirror_nxtfpsel_msb;
+	u8 mirror_fpsel_msb;
+	u8 hfpsel_msb;
+	u8 nxtfpsel_msb;
+	u8 fpsel_msb;
+};
+
+struct xgene_cle_ptree {
+	struct xgene_cle_ptree_ewdn *dn;
+	struct xgene_cle_ptree_kn *kn;
+	struct xgene_cle_dbptr *dbptr;
+	u32 num_dn;
+	u32 num_kn;
+	u32 num_dbptr;
+	u32 start_node;
+	u32 start_pkt;
+	u32 start_dbptr;
+};
+
+struct xgene_enet_cle {
+	void __iomem *base;
+	struct xgene_cle_ptree ptree;
+	enum xgene_cle_parser active_parser;
+	u32 parsers;
+	u32 max_nodes;
+	u32 max_dbptrs;
+	u32 jump_bytes;
+};
+
+extern struct xgene_cle_ops xgene_cle3in_ops;
+
+#endif /* __XGENE_ENET_CLE_H__ */
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.h b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.h
index 8a90910..45725ec 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.h
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.h
@@ -101,6 +101,7 @@ enum xgene_enet_rm {
 #define MAC_OFFSET			0x30
 
 #define BLOCK_ETH_CSR_OFFSET		0x2000
+#define BLOCK_ETH_CLE_CSR_OFFSET	0x6000
 #define BLOCK_ETH_RING_IF_OFFSET	0x9000
 #define BLOCK_ETH_CLKRST_CSR_OFFSET	0xc000
 #define BLOCK_ETH_DIAG_CSR_OFFSET	0xD000
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
index 5eb9b20..2716d45 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
@@ -93,13 +93,6 @@ static int xgene_enet_refill_bufpool(struct xgene_enet_desc_ring *buf_pool,
 	return 0;
 }
 
-static u16 xgene_enet_dst_ring_num(struct xgene_enet_desc_ring *ring)
-{
-	struct xgene_enet_pdata *pdata = netdev_priv(ring->ndev);
-
-	return ((u16)pdata->rm << 10) | ring->num;
-}
-
 static u8 xgene_enet_hdr_len(const void *data)
 {
 	const struct ethhdr *eth = data;
@@ -1278,6 +1271,7 @@ static int xgene_enet_get_resources(struct xgene_enet_pdata *pdata)
 	else
 		base_addr = pdata->base_addr;
 	pdata->eth_csr_addr = base_addr + BLOCK_ETH_CSR_OFFSET;
+	pdata->cle.base = base_addr + BLOCK_ETH_CLE_CSR_OFFSET;
 	pdata->eth_ring_if_addr = base_addr + BLOCK_ETH_RING_IF_OFFSET;
 	pdata->eth_diag_csr_addr = base_addr + BLOCK_ETH_DIAG_CSR_OFFSET;
 	if (pdata->phy_mode == PHY_INTERFACE_MODE_RGMII ||
@@ -1300,6 +1294,7 @@ static int xgene_enet_init_hw(struct xgene_enet_pdata *pdata)
 {
 	struct net_device *ndev = pdata->ndev;
 	struct xgene_enet_desc_ring *buf_pool;
+	struct xgene_enet_cle *enet_cle = &pdata->cle;
 	u16 dst_ring_num;
 	int ret;
 
@@ -1323,7 +1318,24 @@ static int xgene_enet_init_hw(struct xgene_enet_pdata *pdata)
 	}
 
 	dst_ring_num = xgene_enet_dst_ring_num(pdata->rx_ring);
-	pdata->port_ops->cle_bypass(pdata, dst_ring_num, buf_pool->id);
+	if (pdata->phy_mode == PHY_INTERFACE_MODE_XGMII) {
+		/* Initialize and Enable  PreClassifier Tree */
+		enet_cle->max_nodes = 512;
+		enet_cle->max_dbptrs = 1024;
+		enet_cle->parsers = 3;
+		enet_cle->active_parser = PARSER_ALL;
+		enet_cle->ptree.start_node = 0;
+		enet_cle->ptree.start_dbptr = 0;
+		enet_cle->jump_bytes = 8;
+		ret = pdata->cle_ops->cle_init(pdata);
+		if (ret) {
+			netdev_err(ndev, "Preclass Tree init error\n");
+			return ret;
+		}
+	} else {
+		pdata->port_ops->cle_bypass(pdata, dst_ring_num, buf_pool->id);
+	}
+
 	pdata->mac_ops->init(pdata);
 
 	return ret;
@@ -1345,6 +1357,7 @@ static void xgene_enet_setup_ops(struct xgene_enet_pdata *pdata)
 	default:
 		pdata->mac_ops = &xgene_xgmac_ops;
 		pdata->port_ops = &xgene_xgport_ops;
+		pdata->cle_ops = &xgene_cle3in_ops;
 		pdata->rm = RM0;
 		break;
 	}
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.h b/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
index 248dfc4..05365c1 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
@@ -36,6 +36,7 @@
 #include <linux/if_vlan.h>
 #include <linux/phy.h>
 #include "xgene_enet_hw.h"
+#include "xgene_enet_cle.h"
 #include "xgene_enet_ring2.h"
 
 #define XGENE_DRV_VERSION	"v1.0"
@@ -145,6 +146,10 @@ struct xgene_ring_ops {
 	u32 (*len)(struct xgene_enet_desc_ring *);
 };
 
+struct xgene_cle_ops {
+	int (*cle_init)(struct xgene_enet_pdata *pdata);
+};
+
 /* ethernet private data */
 struct xgene_enet_pdata {
 	struct net_device *ndev;
@@ -174,10 +179,12 @@ struct xgene_enet_pdata {
 	void __iomem *ring_cmd_addr;
 	int phy_mode;
 	enum xgene_enet_rm rm;
+	struct xgene_enet_cle cle;
 	struct rtnl_link_stats64 stats;
 	const struct xgene_mac_ops *mac_ops;
 	const struct xgene_port_ops *port_ops;
 	struct xgene_ring_ops *ring_ops;
+	struct xgene_cle_ops *cle_ops;
 	struct delayed_work link_work;
 	u32 port_id;
 	u8 cpu_bufnum;
@@ -229,6 +236,13 @@ static inline struct device *ndev_to_dev(struct net_device *ndev)
 	return ndev->dev.parent;
 }
 
+static inline u16 xgene_enet_dst_ring_num(struct xgene_enet_desc_ring *ring)
+{
+	struct xgene_enet_pdata *pdata = netdev_priv(ring->ndev);
+
+	return ((u16)pdata->rm << 10) | ring->num;
+}
+
 void xgene_enet_set_ethtool_ops(struct net_device *netdev);
 
 #endif /* __XGENE_ENET_MAIN_H__ */
-- 
1.9.1
