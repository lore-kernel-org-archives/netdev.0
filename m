From: Yeshaswi M R Gowda <yeshaswi@chelsio.com>
Subject: [PATCH 2/3] chcr: Support for Chelsio's Crypto Hardware
Date: Mon, 11 Jul 2016 11:28:07 -0700
Message-ID: <1468261688-24525-3-git-send-email-yeshaswi@chelsio.com>
References: <1468261688-24525-1-git-send-email-yeshaswi@chelsio.com>
Cc: Yeshaswi M R Gowda <yeshaswi@chelsio.com>
To: hariprasad@chelsio.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, herbert@gondor.apana.org.au,
	davem@davemloft.net, linux-crypto@vger.kernel.org,
	jlulla@chelsio.com, atul.gupta@chelsio.com, harsh@chelsio.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1468261688-24525-1-git-send-email-yeshaswi@chelsio.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The Chelsio's Crypto Hardware can perform the following operations:
SHA1, SHA224, SHA256, SHA384 and SHA512, HMAC(SHA1), HMAC(SHA224),
HMAC(SHA256), HMAC(SHA384), HAMC(SHA512), AES-128-CBC, AES-192-CBC,
AES-256-CBC, AES-128-XTS, AES-256-XTS

This patch implements the driver for above mentioned features. This
driver is an Upper Layer Driver which is attached to Chelsio's LLD
(cxgb4) and uses the queue allocated by the LLD for sending the crypto
requests to the Hardware and receiving the responses from it.

The crypto operations can be performed by Chelsio's hardware from the
userspace applications and/or from within the kernel space using the
kernel's crypto API.

The above mentioned crypto features have been tested using kernel's
tests mentioned in testmgr.h. They also have been tested from user
space using libkcapi and Openssl.

Signed-off-by: Yeshaswi M R Gowda <yeshaswi@chelsio.com>
---
 drivers/crypto/chelsio/Kconfig       |   19 +
 drivers/crypto/chelsio/Makefile      |    4 +
 drivers/crypto/chelsio/chcr_algo.c   | 1531 ++++++++++++++++++++++++++++++++++
 drivers/crypto/chelsio/chcr_algo.h   |  502 +++++++++++
 drivers/crypto/chelsio/chcr_core.c   |  273 ++++++
 drivers/crypto/chelsio/chcr_core.h   |   85 ++
 drivers/crypto/chelsio/chcr_crypto.h |  255 ++++++
 7 files changed, 2669 insertions(+)
 create mode 100644 drivers/crypto/chelsio/Kconfig
 create mode 100644 drivers/crypto/chelsio/Makefile
 create mode 100644 drivers/crypto/chelsio/chcr_algo.c
 create mode 100644 drivers/crypto/chelsio/chcr_algo.h
 create mode 100644 drivers/crypto/chelsio/chcr_core.c
 create mode 100644 drivers/crypto/chelsio/chcr_core.h
 create mode 100644 drivers/crypto/chelsio/chcr_crypto.h

diff --git a/drivers/crypto/chelsio/Kconfig b/drivers/crypto/chelsio/Kconfig
new file mode 100644
index 0000000..5684a55
--- /dev/null
+++ b/drivers/crypto/chelsio/Kconfig
@@ -0,0 +1,19 @@
+config CRYPTO_DEV_CHELSIO
+	tristate "Chelsio Crypto Co-processor Driver"
+	select CHELSIO_T4
+	select CRYPTO_SHA1
+	select CRYPTO_SHA256
+	select CRYPTO_SHA512
+	---help---
+	  The Chelsio Crypto Co-processor driver for T6 adapters.
+
+	  For general information about Chelsio and our products, visit
+	  our website at <http://www.chelsio.com>.
+
+	  For customer support, please visit our customer support page at
+	  <http://www.chelsio.com/support.html>.
+
+	  Please send feedback to <linux-bugs@chelsio.com>.
+
+	  To compile this driver as a module, choose M here: the module
+	  will be called chcr.
diff --git a/drivers/crypto/chelsio/Makefile b/drivers/crypto/chelsio/Makefile
new file mode 100644
index 0000000..7e4fda5
--- /dev/null
+++ b/drivers/crypto/chelsio/Makefile
@@ -0,0 +1,4 @@
+ ccflags-y := -Idrivers/net/ethernet/chelsio/cxgb4
+
+ obj-$(CONFIG_CRYPTO_DEV_CHELSIO) += chcr.o
+ chcr-objs :=  chcr_core.o chcr_algo.o
\ No newline at end of file
diff --git a/drivers/crypto/chelsio/chcr_algo.c b/drivers/crypto/chelsio/chcr_algo.c
new file mode 100644
index 0000000..b070486
--- /dev/null
+++ b/drivers/crypto/chelsio/chcr_algo.c
@@ -0,0 +1,1531 @@
+/*
+ * This file is part of the Chelsio T6 Crypto driver for Linux.
+ *
+ * Copyright (c) 2003-2016 Chelsio Communications, Inc. All rights reserved.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * OpenIB.org BSD license below:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and/or other materials
+ *        provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ *
+ * Written and Maintained by:
+ *	Manoj Malviya (manojmalviya@chelsio.com)
+ *	Atul Gupta (atul.gupta@chelsio.com)
+ *	Jitendra Lulla (jlulla@chelsio.com)
+ *	Yeshaswi M R Gowda (yeshaswi@chelsio.com)
+ *	Harsh Jain (harsh@chelsio.com)
+ */
+
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/crypto.h>
+#include <linux/cryptohash.h>
+#include <linux/skbuff.h>
+#include <linux/rtnetlink.h>
+#include <linux/highmem.h>
+#include <linux/scatterlist.h>
+
+#include <crypto/aes.h>
+#include <crypto/algapi.h>
+#include <crypto/hash.h>
+#include <crypto/sha.h>
+#include <crypto/authenc.h>
+#include <crypto/internal/aead.h>
+#include <crypto/internal/hash.h>
+#include <crypto/aead.h>
+#include <crypto/scatterwalk.h>
+
+#include "t4fw_api.h"
+#include "t4_msg.h"
+#include "chcr_core.h"
+#include "chcr_algo.h"
+#include "chcr_crypto.h"
+
+static inline struct aead_ctx *AEAD_CTX(struct chcr_context *ctx)
+{
+	return ctx->crypto_ctx->aeadctx;
+}
+
+static inline struct ablk_ctx *ABLK_CTX(struct chcr_context *ctx)
+{
+	return ctx->crypto_ctx->ablkctx;
+}
+
+static inline struct hmac_ctx *HMAC_CTX(struct chcr_context *ctx)
+{
+	return ctx->crypto_ctx->hmacctx;
+}
+
+static inline struct uld_ctx *ULD_CTX(struct chcr_context *ctx)
+{
+	return ctx->dev->u_ctx;
+}
+
+static inline int is_ofld_imm(const struct sk_buff *skb)
+{
+	return skb->len <= MAX_IMM_OFLD_TX_DATA_WR_LEN;
+}
+
+/*
+ *	sgl_len - calculates the size of an SGL of the given capacity
+ *	@n: the number of SGL entries
+ *	Calculates the number of flits needed for a scatter/gather list that
+ *	can hold the given number of entries.
+ */
+static inline unsigned int sgl_len(unsigned int n)
+{
+	n--;
+	return (3 * n) / 2 + (n & 1) + 2;
+}
+
+/*
+ *	chcr_handle_resp - Unmap the DMA buffers associated with the request
+ *	@req: crypto request
+ */
+int chcr_handle_resp(struct crypto_async_request *req, unsigned char *input,
+		     int error_status)
+{
+	struct crypto_tfm *tfm = req->tfm;
+	struct chcr_context *ctx = crypto_tfm_ctx(tfm);
+	struct uld_ctx *u_ctx = ULD_CTX(ctx);
+	struct chcr_req_ctx ctx_req;
+	struct cpl_fw6_pld *fw6_pld;
+	unsigned int digestsize, updated_digestsize;
+
+	switch (tfm->__crt_alg->cra_flags & CRYPTO_ALG_TYPE_MASK) {
+	case CRYPTO_ALG_TYPE_AEAD:
+		ctx_req.req.aead_req = (struct aead_request *)req;
+		ctx_req.ctx.aead_ctx =
+			aead_request_ctx((struct aead_request *)req);
+		dma_unmap_sg(&u_ctx->lldi.pdev->dev, ctx_req.req.aead_req->dst,
+			     AEAD_CTX(ctx)->dst_nents, DMA_FROM_DEVICE);
+		if (ctx_req.ctx.aead_ctx->skb) {
+			kfree_skb(ctx_req.ctx.aead_ctx->skb);
+			ctx_req.ctx.aead_ctx->skb = NULL;
+		}
+		break;
+
+	case CRYPTO_ALG_TYPE_BLKCIPHER:
+		ctx_req.req.ablk_req = (struct ablkcipher_request *)req;
+		ctx_req.ctx.ablk_ctx =
+			ablkcipher_request_ctx(ctx_req.req.ablk_req);
+		if (error_status)
+			goto dma_unmap_blkcipher;
+		fw6_pld = (struct cpl_fw6_pld *)input;
+		memcpy(ctx_req.req.ablk_req->info, &fw6_pld->data[2],
+		       AES_BLOCK_SIZE);
+dma_unmap_blkcipher:
+		dma_unmap_sg(&u_ctx->lldi.pdev->dev, ctx_req.req.ablk_req->dst,
+			     ABLK_CTX(ctx)->dst_nents, DMA_FROM_DEVICE);
+		if (ctx_req.ctx.ablk_ctx->skb) {
+			kfree_skb(ctx_req.ctx.ablk_ctx->skb);
+			ctx_req.ctx.ablk_ctx->skb = NULL;
+		}
+		break;
+
+	case CRYPTO_ALG_TYPE_AHASH:
+		ctx_req.req.ahash_req = (struct ahash_request *)req;
+		ctx_req.ctx.ahash_ctx =
+			ahash_request_ctx(ctx_req.req.ahash_req);
+		digestsize =
+			crypto_ahash_digestsize(crypto_ahash_reqtfm(
+							ctx_req.req.ahash_req));
+		updated_digestsize = digestsize;
+		if (digestsize == SHA224_DIGEST_SIZE)
+			updated_digestsize = SHA256_DIGEST_SIZE;
+		else if (digestsize == SHA384_DIGEST_SIZE)
+			updated_digestsize = SHA512_DIGEST_SIZE;
+		if (ctx_req.ctx.ahash_ctx->skb)
+			ctx_req.ctx.ahash_ctx->skb = NULL;
+		if (ctx_req.ctx.ahash_ctx->result == 1) {
+			ctx_req.ctx.ahash_ctx->result = 0;
+			memcpy(ctx_req.req.ahash_req->result, input +
+			       sizeof(struct cpl_fw6_pld),
+			       digestsize);
+		} else {
+			memcpy(ctx_req.ctx.ahash_ctx->partial_hash, input +
+			       sizeof(struct cpl_fw6_pld),
+			       updated_digestsize);
+		}
+		kfree(ctx_req.ctx.ahash_ctx->dummy_payload_ptr);
+		ctx_req.ctx.ahash_ctx->dummy_payload_ptr = NULL;
+		break;
+	}
+	return 0;
+}
+
+/*
+ *	calc_tx_flits_ofld - calculate # of flits for an offload packet
+ *	@skb: the packet
+ *	Returns the number of flits needed for the given offload packet.
+ *	These packets are already fully constructed and no additional headers
+ *	will be added.
+ */
+static inline unsigned int calc_tx_flits_ofld(const struct sk_buff *skb)
+{
+	unsigned int flits, cnt;
+
+	if (is_ofld_imm(skb))
+		return DIV_ROUND_UP(skb->len, 8);
+
+	flits = skb_transport_offset(skb) / 8;   /* headers */
+	cnt = skb_shinfo(skb)->nr_frags;
+	if (skb_tail_pointer(skb) != skb_transport_header(skb))
+		cnt++;
+	return flits + sgl_len(cnt);
+}
+
+static struct shash_desc *chcr_alloc_shash(unsigned int ds)
+{
+	struct crypto_shash *base_hash = NULL;
+	struct shash_desc *desc;
+
+	switch (ds) {
+	case SHA1_DIGEST_SIZE:
+		base_hash = crypto_alloc_shash("sha1-generic", 0, 0);
+		break;
+	case SHA224_DIGEST_SIZE:
+		base_hash = crypto_alloc_shash("sha224-generic", 0, 0);
+		break;
+	case SHA256_DIGEST_SIZE:
+		base_hash = crypto_alloc_shash("sha256-generic", 0, 0);
+		break;
+	case SHA384_DIGEST_SIZE:
+		base_hash = crypto_alloc_shash("sha384-generic", 0, 0);
+		break;
+	case SHA512_DIGEST_SIZE:
+		base_hash = crypto_alloc_shash("sha512-generic", 0, 0);
+		break;
+	}
+	if (IS_ERR(base_hash)) {
+		pr_err("Can not allocate sha-generic algo.\n");
+		return (void *)base_hash;
+	}
+
+	desc = kmalloc(sizeof(*desc) + crypto_shash_descsize(base_hash),
+		       GFP_KERNEL);
+	if (!desc)
+		return ERR_PTR(-ENOMEM);
+	desc->tfm = base_hash;
+	desc->flags = crypto_shash_get_flags(base_hash);
+	return desc;
+}
+
+static int chcr_compute_partial_hash(struct shash_desc *desc,
+				     char *iopad, char *result_hash,
+				     int digest_size)
+{
+	struct sha1_state sha1_st;
+	struct sha256_state sha256_st;
+	struct sha512_state sha512_st;
+	int error;
+
+	if (digest_size == SHA1_DIGEST_SIZE) {
+		error = crypto_shash_init(desc) ?:
+			crypto_shash_update(desc, iopad, SHA1_BLOCK_SIZE) ?:
+			crypto_shash_export(desc, (void *)&sha1_st);
+		memcpy(result_hash, sha1_st.state, SHA1_DIGEST_SIZE);
+	} else if (digest_size == SHA224_DIGEST_SIZE) {
+		error = crypto_shash_init(desc) ?:
+			crypto_shash_update(desc, iopad, SHA256_BLOCK_SIZE) ?:
+			crypto_shash_export(desc, (void *)&sha256_st);
+		memcpy(result_hash, sha256_st.state, SHA256_DIGEST_SIZE);
+
+	} else if (digest_size == SHA256_DIGEST_SIZE) {
+		error = crypto_shash_init(desc) ?:
+			crypto_shash_update(desc, iopad, SHA256_BLOCK_SIZE) ?:
+			crypto_shash_export(desc, (void *)&sha256_st);
+		memcpy(result_hash, sha256_st.state, SHA256_DIGEST_SIZE);
+
+	} else if (digest_size == SHA384_DIGEST_SIZE) {
+		error = crypto_shash_init(desc) ?:
+			crypto_shash_update(desc, iopad, SHA512_BLOCK_SIZE) ?:
+			crypto_shash_export(desc, (void *)&sha512_st);
+		memcpy(result_hash, sha512_st.state, SHA512_DIGEST_SIZE);
+
+	} else if (digest_size == SHA512_DIGEST_SIZE) {
+		error = crypto_shash_init(desc) ?:
+			crypto_shash_update(desc, iopad, SHA512_BLOCK_SIZE) ?:
+			crypto_shash_export(desc, (void *)&sha512_st);
+		memcpy(result_hash, sha512_st.state, SHA512_DIGEST_SIZE);
+	} else {
+		error = -EINVAL;
+		pr_err("Unknown digest size %d\n", digest_size);
+	}
+	return error;
+}
+
+static void chcr_change_order(char *buf, int ds)
+{
+	int i;
+
+	if (ds == SHA512_DIGEST_SIZE) {
+		for (i = 0; i < (ds / sizeof(u64)); i++)
+			*((__be64 *)buf + i) =
+				cpu_to_be64(*((u64 *)buf + i));
+	} else {
+		for (i = 0; i < (ds / sizeof(u32)); i++)
+			*((__be32 *)buf + i) =
+				cpu_to_be32(*((u32 *)buf + i));
+	}
+}
+
+static inline int is_hmac(struct crypto_tfm *tfm)
+{
+	struct crypto_alg *alg = tfm->__crt_alg;
+	struct chcr_alg_template *chcr_crypto_alg =
+		container_of(__crypto_ahash_alg(alg), struct chcr_alg_template,
+			     alg.hash);
+	if ((chcr_crypto_alg->type & CRYPTO_ALG_SUB_TYPE_MASK) ==
+	    CRYPTO_ALG_SUB_TYPE_HASH_HMAC)
+		return 1;
+	return 0;
+}
+
+static inline unsigned int ch_nents(struct scatterlist *sg,
+				    unsigned int *total_size)
+{
+	unsigned int nents;
+
+	for (nents = 0, *total_size = 0; sg; sg = sg_next(sg)) {
+		nents++;
+		*total_size += sg->length;
+	}
+	return nents;
+}
+
+static void write_phys_cpl(struct cpl_rx_phys_dsgl *phys_cpl,
+			   struct scatterlist *sg,
+			   struct phys_sge_parm *sg_param)
+{
+	struct phys_sge_pairs *to;
+	unsigned int out_buf_size = sg_param->obsize;
+	unsigned int nents = sg_param->nents, i, j, tot_len = 0;
+
+	phys_cpl->op_to_tid = htonl(V_CPL_RX_PHYS_DSGL_OPCODE(CPL_RX_PHYS_DSGL)
+				    | V_CPL_RX_PHYS_DSGL_ISRDMA(0));
+	phys_cpl->pcirlxorder_to_noofsgentr =
+		htonl(V_CPL_RX_PHYS_DSGL_PCIRLXORDER(0) |
+		      V_CPL_RX_PHYS_DSGL_PCINOSNOOP(0) |
+		      V_CPL_RX_PHYS_DSGL_PCITPHNTENB(0) |
+		      V_CPL_RX_PHYS_DSGL_PCITPHNT(0) |
+		      V_CPL_RX_PHYS_DSGL_DCAID(0) |
+		      V_CPL_RX_PHYS_DSGL_NOOFSGENTR(nents));
+	phys_cpl->rss_hdr_int.opcode = CPL_RX_PHYS_ADDR;
+	phys_cpl->rss_hdr_int.qid = htons(sg_param->qid);
+	phys_cpl->rss_hdr_int.hash_val = 0;
+	to = (struct phys_sge_pairs *)((unsigned char *)phys_cpl +
+				       sizeof(struct cpl_rx_phys_dsgl));
+
+	for (i = 0; nents; to++) {
+		for (j = i; (nents && (j < (8 + i))); j++, nents--) {
+			to->len[j] = htons(sg->length);
+			to->addr[j] = cpu_to_be64(sg_dma_address(sg));
+			if (out_buf_size) {
+				if (tot_len + sg_dma_len(sg) >= out_buf_size) {
+					to->len[j] = htons(out_buf_size -
+							   tot_len);
+					return;
+				}
+				tot_len += sg_dma_len(sg);
+			}
+			sg = sg_next(sg);
+		}
+	}
+}
+
+static inline unsigned
+int map_writesg_phys_cpl(struct device *dev, struct cpl_rx_phys_dsgl *phys_cpl,
+			 struct scatterlist *sg, struct phys_sge_parm *sg_param)
+{
+	if (!sg || !sg_param->nents)
+		return 0;
+
+	sg_param->nents = dma_map_sg(dev, sg, sg_param->nents, DMA_FROM_DEVICE);
+	if (sg_param->nents == 0) {
+		pr_err("CHCR : DMA mapping failed\n");
+		return -EINVAL;
+	}
+	write_phys_cpl(phys_cpl, sg, sg_param);
+	return 0;
+}
+
+static inline int get_cryptoalg_subtype(struct crypto_tfm *tfm)
+{
+	struct crypto_alg *alg = tfm->__crt_alg;
+	struct chcr_alg_template *chcr_crypto_alg =
+		container_of(alg, struct chcr_alg_template, alg.crypto);
+
+	return chcr_crypto_alg->type & CRYPTO_ALG_SUB_TYPE_MASK;
+}
+
+static inline int
+write_sg_data_page_desc(struct sk_buff *skb, unsigned int *frags,
+			struct scatterlist *sg, unsigned int count)
+{
+	struct page *spage;
+	unsigned int page_len;
+
+	skb->len += count;
+	skb->data_len += count;
+	skb->truesize += count;
+	while (count > 0) {
+		if (sg && !sg->length)
+			break;
+		spage = sg_page(sg);
+		get_page(spage);
+		page_len = min(sg->length, count);
+		skb_fill_page_desc(skb, *frags, spage, sg->offset, page_len);
+		(*frags)++;
+		count -= page_len;
+		sg = sg_next(sg);
+	}
+	return 0;
+}
+
+static int generate_copy_rrkey(struct ablk_ctx *ablkctx,
+			       struct _key_ctx *key_ctx)
+{
+	if (ablkctx->ciph_mode == CHCR_SCMD_CIPHER_MODE_AES_CBC) {
+		get_aes_decrypt_key(key_ctx->key, ablkctx->key,
+				    ablkctx->enckey_len << 3);
+		memset(key_ctx->key + ablkctx->enckey_len, 0,
+		       CHCR_AES_MAX_KEY_LEN - ablkctx->enckey_len);
+	} else {
+		memcpy(key_ctx->key,
+		       ablkctx->key + (ablkctx->enckey_len >> 1),
+		       ablkctx->enckey_len >> 1);
+		get_aes_decrypt_key(key_ctx->key + (ablkctx->enckey_len >> 1),
+				    ablkctx->key, ablkctx->enckey_len << 2);
+	}
+	return 0;
+}
+
+static inline void create_wreq(struct chcr_context *ctx,
+			       struct fw_crypto_lookaside_wr *wreq,
+			       void *req, struct sk_buff *skb,
+			       int kctx_len, int hash_sz,
+			       unsigned int phys_dsgl)
+{
+	struct uld_ctx *u_ctx = ULD_CTX(ctx);
+	struct ulp_txpkt *ulptx = (struct ulp_txpkt *)(wreq + 1);
+	struct ulptx_idata *sc_imm = (struct ulptx_idata *)(ulptx + 1);
+	int iv_loc = IV_DSGL;
+	int qid = u_ctx->lldi.rxq_ids[ctx->tx_channel_id];
+	unsigned int immdatalen = 0, nr_frags = 0;
+
+	if (is_ofld_imm(skb)) {
+		immdatalen = skb->data_len;
+		iv_loc = IV_IMMEDIATE;
+	} else {
+		nr_frags = skb_shinfo(skb)->nr_frags;
+	}
+
+	wreq->op_to_cctx_size = FILL_WR_OP_CCTX_SIZE(immdatalen,
+						     (kctx_len >> 4));
+	wreq->pld_size_hash_size =
+		htonl(V_FW_CRYPTO_LOOKASIDE_WR_PLD_SIZE(sgl_lengths[nr_frags]) |
+		      V_FW_CRYPTO_LOOKASIDE_WR_HASH_SIZE(hash_sz));
+	wreq->len16_pkd = htonl(V_FW_CRYPTO_LOOKASIDE_WR_LEN16(DIV_ROUND_UP(
+				    (calc_tx_flits_ofld(skb) * 8), 16)));
+	wreq->cookie = cpu_to_be64((u64)req);
+	wreq->rx_chid_to_rx_q_id =
+		FILL_WR_RX_Q_ID(ctx->dev->tx_channel_id, qid,
+				(hash_sz) ? IV_NOP : iv_loc);
+
+	ulptx->cmd_dest = FILL_ULPTX_CMD_DEST(ctx->dev->tx_channel_id);
+	ulptx->len = htonl((DIV_ROUND_UP((calc_tx_flits_ofld(skb) * 8),
+					 16) - ((sizeof(*wreq)) >> 4)));
+
+	sc_imm->cmd_more = FILL_CMD_MORE(immdatalen);
+	sc_imm->len = cpu_to_be32(sizeof(struct cpl_tx_sec_pdu) + kctx_len +
+				  ((hash_sz) ? DUMMY_BYTES :
+				  (sizeof(struct cpl_rx_phys_dsgl) +
+				   phys_dsgl)) + immdatalen);
+}
+
+/**
+ *	create_cipher_wr - form the WR for cipher operations
+ *	@req: cipher req.
+ *	@ctx: crypto driver context of the request.
+ *	@qid: ingress qid where response of this WR should be received.
+ *	@op_type:	encryption or decryption
+ */
+static struct sk_buff
+*create_cipher_wr(struct crypto_async_request *req_base,
+		  struct chcr_context *ctx, unsigned short qid,
+		  unsigned short op_type)
+{
+	struct ablkcipher_request *req = (struct ablkcipher_request *)req_base;
+	struct crypto_ablkcipher *tfm = crypto_ablkcipher_reqtfm(req);
+	struct uld_ctx *u_ctx = ULD_CTX(ctx);
+	struct ablk_ctx *ablkctx = ABLK_CTX(ctx);
+	struct sk_buff *skb = NULL;
+	struct _key_ctx *key_ctx;
+	struct fw_crypto_lookaside_wr *wreq;
+	struct cpl_tx_sec_pdu *sec_cpl;
+	struct cpl_rx_phys_dsgl *phys_cpl;
+	struct chcr_blkcipher_req_ctx *req_ctx = ablkcipher_request_ctx(req);
+	struct phys_sge_parm sg_param;
+	unsigned int frags = 0, transhdr_len, phys_dsgl, dst_bufsize = 0;
+	unsigned int ivsize = crypto_ablkcipher_ivsize(tfm), kctx_len;
+
+	if (!req->info)
+		return ERR_PTR(-EINVAL);
+	ablkctx->dst_nents = ch_nents(req->dst, &dst_bufsize);
+	ablkctx->enc = op_type;
+
+	if ((ablkctx->enckey_len == 0) || (ivsize > AES_BLOCK_SIZE) ||
+	    (req->nbytes <= 0) || (req->nbytes % AES_BLOCK_SIZE))
+		return ERR_PTR(-EINVAL);
+
+	phys_dsgl = get_space_for_phys_dsgl(ablkctx->dst_nents);
+
+	kctx_len = sizeof(*key_ctx) +
+		(DIV_ROUND_UP(ablkctx->enckey_len, 16) * 16);
+	transhdr_len = CIPHER_TRANSHDR_SIZE(kctx_len, phys_dsgl);
+	skb = alloc_skb((transhdr_len + sizeof(struct sge_opaque_hdr)),
+			GFP_ATOMIC);
+	if (!skb)
+		return ERR_PTR(-ENOMEM);
+	skb_reserve(skb, sizeof(struct sge_opaque_hdr));
+	wreq = (struct fw_crypto_lookaside_wr *)__skb_put(skb, transhdr_len);
+
+	sec_cpl = (struct cpl_tx_sec_pdu *)((u8 *)wreq + SEC_CPL_OFFSET);
+	sec_cpl->op_ivinsrtofst =
+		FILL_SEC_CPL_OP_IVINSR(ctx->dev->tx_channel_id, 2, 1, 1);
+
+	sec_cpl->pldlen = htonl(ivsize + req->nbytes);
+	sec_cpl->aadstart_cipherstop_hi = FILL_SEC_CPL_CIPHERSTOP_HI(0, 0,
+								ivsize + 1, 0);
+
+	sec_cpl->cipherstop_lo_authinsert =  FILL_SEC_CPL_AUTHINSERT(0, 0,
+								     0, 0);
+	sec_cpl->seqno_numivs = FILL_SEC_CPL_SCMD0_SEQNO(op_type, 0,
+							 ablkctx->ciph_mode,
+							 0, 0, ivsize >> 1, 1);
+	sec_cpl->ivgen_hdrlen = FILL_SEC_CPL_IVGEN_HDRLEN(0, 0, 0,
+							  0, 1, phys_dsgl);
+
+	key_ctx = (struct _key_ctx *)((u8 *)sec_cpl + sizeof(*sec_cpl));
+	key_ctx->ctx_hdr = ablkctx->key_ctx_hdr;
+	if ((op_type == CHCR_DECRYPT_OP) &&
+	    (!(get_cryptoalg_subtype(crypto_ablkcipher_tfm(tfm)) ==
+	       CRYPTO_ALG_SUB_TYPE_CTR))) {
+		if (generate_copy_rrkey(ablkctx, key_ctx))
+			goto map_fail1;
+	} else {
+		if ((ablkctx->ciph_mode == CHCR_SCMD_CIPHER_MODE_AES_CBC) ||
+		    (ablkctx->ciph_mode == CHCR_SCMD_CIPHER_MODE_AES_CTR)) {
+			memcpy(key_ctx->key, ablkctx->key, ablkctx->enckey_len);
+		} else {
+			memcpy(key_ctx->key, ablkctx->key +
+			       (ablkctx->enckey_len >> 1),
+			       ablkctx->enckey_len >> 1);
+			memcpy(key_ctx->key +
+			       (ablkctx->enckey_len >> 1),
+			       ablkctx->key,
+			       ablkctx->enckey_len >> 1);
+		}
+	}
+	phys_cpl = (struct cpl_rx_phys_dsgl *)((u8 *)key_ctx + kctx_len);
+
+	memcpy(ablkctx->iv, req->info, ivsize);
+	sg_init_table(&ablkctx->iv_sg, 1);
+	sg_set_buf(&ablkctx->iv_sg, ablkctx->iv, ivsize);
+	sg_param.nents = ablkctx->dst_nents;
+	sg_param.obsize = dst_bufsize;
+	sg_param.qid = qid;
+	sg_param.align = 1;
+	if (map_writesg_phys_cpl(&u_ctx->lldi.pdev->dev, phys_cpl, req->dst,
+				 &sg_param))
+		goto map_fail1;
+
+	skb_set_transport_header(skb, transhdr_len);
+	write_sg_data_page_desc(skb, &frags, &ablkctx->iv_sg, ivsize);
+	write_sg_data_page_desc(skb, &frags, req->src, req->nbytes);
+	create_wreq(ctx, wreq, req, skb, kctx_len, 0, phys_dsgl);
+	req_ctx->skb = skb;
+	skb_get(skb);
+	return skb;
+map_fail1:
+	kfree_skb(skb);
+	return ERR_PTR(-ENOMEM);
+}
+
+static int chcr_aes_cbc_setkey(struct crypto_ablkcipher *tfm, const u8 *key,
+			       unsigned int keylen)
+{
+	struct chcr_context *ctx = crypto_ablkcipher_ctx(tfm);
+	struct ablk_ctx *ablkctx = ABLK_CTX(ctx);
+	struct ablkcipher_alg *alg = crypto_ablkcipher_alg(tfm);
+	unsigned int ck_size, context_size;
+	u16 alignment = 0;
+
+	if ((keylen < alg->min_keysize) || (keylen > alg->max_keysize))
+		goto badkey_err;
+
+	memcpy(ablkctx->key, key, keylen);
+	ablkctx->enckey_len = keylen;
+	if (keylen == AES_KEYSIZE_128) {
+		ck_size = CHCR_KEYCTX_CIPHER_KEY_SIZE_128;
+	} else if (keylen == AES_KEYSIZE_192) {
+		alignment = 8;
+		ck_size = CHCR_KEYCTX_CIPHER_KEY_SIZE_192;
+	} else if (keylen == AES_KEYSIZE_256) {
+		ck_size = CHCR_KEYCTX_CIPHER_KEY_SIZE_256;
+	} else {
+		goto badkey_err;
+	}
+
+	context_size = (KEY_CONTEXT_HDR_SALT_AND_PAD +
+			keylen + alignment) >> 4;
+
+	ablkctx->key_ctx_hdr = FILL_KEY_CTX_HDR(ck_size, CHCR_KEYCTX_NO_KEY,
+						0, 0, context_size);
+	if (get_cryptoalg_subtype(crypto_ablkcipher_tfm(tfm)) ==
+	    CRYPTO_ALG_SUB_TYPE_CTR)
+		ablkctx->ciph_mode =  CHCR_SCMD_CIPHER_MODE_AES_CTR;
+	else
+		ablkctx->ciph_mode = CHCR_SCMD_CIPHER_MODE_AES_CBC;
+	return 0;
+badkey_err:
+	crypto_ablkcipher_set_flags(tfm, CRYPTO_TFM_RES_BAD_KEY_LEN);
+	ablkctx->enckey_len = 0;
+	return -EINVAL;
+}
+
+static int chcr_aes_encrypt(struct ablkcipher_request *req)
+{
+	struct crypto_ablkcipher *tfm = crypto_ablkcipher_reqtfm(req);
+	struct chcr_context *ctx = crypto_ablkcipher_ctx(tfm);
+	struct crypto_async_request *req_base = &req->base;
+	struct uld_ctx *u_ctx = ULD_CTX(ctx);
+	struct sk_buff *skb;
+
+	if (cxgb4_is_crypto_q_full(u_ctx->lldi.ports[0], ctx->tx_channel_id))
+		return -EBUSY;
+
+	skb = create_cipher_wr(req_base, ctx,
+			       u_ctx->lldi.rxq_ids[ctx->tx_channel_id],
+			       CHCR_ENCRYPT_OP);
+	if (IS_ERR(skb)) {
+		pr_err("chcr : %s : Failed to form WR. No memory\n", __func__);
+		return  PTR_ERR(skb);
+	}
+	skb->dev = u_ctx->lldi.ports[0];
+	set_wr_txq(skb, CPL_PRIORITY_DATA, ctx->tx_channel_id);
+	chcr_send_wr(skb);
+	return -EINPROGRESS;
+}
+
+static int chcr_aes_decrypt(struct ablkcipher_request *req)
+{
+	struct crypto_ablkcipher *tfm = crypto_ablkcipher_reqtfm(req);
+	struct chcr_context *ctx = crypto_ablkcipher_ctx(tfm);
+	struct crypto_async_request *req_base = &req->base;
+	struct uld_ctx *u_ctx = ULD_CTX(ctx);
+	struct sk_buff *skb;
+
+	if (cxgb4_is_crypto_q_full(u_ctx->lldi.ports[0], ctx->tx_channel_id))
+		return -EBUSY;
+
+	skb = create_cipher_wr(req_base, ctx, u_ctx->lldi.rxq_ids[0],
+			       CHCR_DECRYPT_OP);
+	if (IS_ERR(skb)) {
+		pr_err("chcr : %s : Failed to form WR. No memory\n", __func__);
+		return PTR_ERR(skb);
+	}
+	skb->dev = u_ctx->lldi.ports[0];
+	set_wr_txq(skb, CPL_PRIORITY_DATA, ctx->tx_channel_id);
+	chcr_send_wr(skb);
+	return -EINPROGRESS;
+}
+
+static int chcr_device_init(struct chcr_context *ctx)
+{
+	struct uld_ctx *u_ctx;
+	unsigned int id;
+	int err = 0, rxq_perchan, rxq_idx;
+
+	id = smp_processor_id();
+	if (!ctx->dev) {
+		err = assign_chcr_device(&ctx->dev);
+		if (err) {
+			pr_err("chcr device assignment fails\n");
+			goto out;
+		}
+		u_ctx = ULD_CTX(ctx);
+		rxq_perchan = u_ctx->lldi.nrxq / u_ctx->lldi.nchan;
+		ctx->dev->tx_channel_id = 0;
+		rxq_idx = ctx->dev->tx_channel_id * rxq_perchan;
+		rxq_idx += id % rxq_perchan;
+		spin_lock(&ctx->dev->lock_chcr_dev);
+		ctx->tx_channel_id = rxq_idx;
+		spin_unlock(&ctx->dev->lock_chcr_dev);
+	}
+out:
+	return err;
+}
+
+static int chcr_cra_init(struct crypto_tfm *tfm)
+{
+	tfm->crt_ablkcipher.reqsize =  sizeof(struct chcr_blkcipher_req_ctx);
+	return chcr_device_init(crypto_tfm_ctx(tfm));
+}
+
+static int get_alg_config(struct algo_param *params,
+			  unsigned int auth_size)
+{
+	switch (auth_size) {
+	case SHA1_DIGEST_SIZE:
+		params->mk_size = CHCR_KEYCTX_MAC_KEY_SIZE_160;
+		params->auth_mode = CHCR_SCMD_AUTH_MODE_SHA1;
+		params->result_size = SHA1_DIGEST_SIZE;
+		break;
+	case SHA224_DIGEST_SIZE:
+		params->mk_size = CHCR_KEYCTX_MAC_KEY_SIZE_256;
+		params->auth_mode = CHCR_SCMD_AUTH_MODE_SHA224;
+		params->result_size = SHA256_DIGEST_SIZE;
+		break;
+	case SHA256_DIGEST_SIZE:
+		params->mk_size = CHCR_KEYCTX_MAC_KEY_SIZE_256;
+		params->auth_mode = CHCR_SCMD_AUTH_MODE_SHA256;
+		params->result_size = SHA256_DIGEST_SIZE;
+		break;
+	case SHA384_DIGEST_SIZE:
+		params->mk_size = CHCR_KEYCTX_MAC_KEY_SIZE_512;
+		params->auth_mode = CHCR_SCMD_AUTH_MODE_SHA512_384;
+		params->result_size = SHA512_DIGEST_SIZE;
+		break;
+	case SHA512_DIGEST_SIZE:
+		params->mk_size = CHCR_KEYCTX_MAC_KEY_SIZE_512;
+		params->auth_mode = CHCR_SCMD_AUTH_MODE_SHA512_512;
+		params->result_size = SHA512_DIGEST_SIZE;
+		break;
+	default:
+		pr_err("chcr : ERROR, unsupported digest size\n");
+		return -EINVAL;
+	}
+	return 0;
+}
+
+static inline int
+write_buffer_data_page_desc(struct chcr_ahash_req_ctx *req_ctx,
+			    struct sk_buff *skb, unsigned int *frags, char *bfr,
+			    u8 bfr_len)
+{
+	void *page_ptr = NULL;
+
+	skb->len += bfr_len;
+	skb->data_len += bfr_len;
+	skb->truesize += bfr_len;
+	page_ptr = kmalloc(CHCR_HASH_MAX_BLOCK_SIZE_128, GFP_ATOMIC | GFP_DMA);
+	if (!page_ptr)
+		return -ENOMEM;
+	get_page(virt_to_page(page_ptr));
+	req_ctx->dummy_payload_ptr = page_ptr;
+	memcpy(page_ptr, bfr, bfr_len);
+	skb_fill_page_desc(skb, *frags, virt_to_page(page_ptr),
+			   offset_in_page(page_ptr), bfr_len);
+	(*frags)++;
+	return 0;
+}
+
+/**
+ *	create_final_hash_wr - Create hash work request
+ *	@req - Cipher req base
+ */
+static struct sk_buff *create_final_hash_wr(struct ahash_request *req,
+					    struct hash_wr_param *param)
+{
+	struct chcr_ahash_req_ctx *req_ctx = ahash_request_ctx(req);
+	struct crypto_ahash *tfm = crypto_ahash_reqtfm(req);
+	struct chcr_context *ctx = crypto_tfm_ctx(crypto_ahash_tfm(tfm));
+	struct hmac_ctx *hmacctx = HMAC_CTX(ctx);
+	struct sk_buff *skb = NULL;
+	struct _key_ctx *key_ctx;
+	struct fw_crypto_lookaside_wr *wreq;
+	struct cpl_tx_sec_pdu *sec_cpl;
+	unsigned int frags = 0, transhdr_len, iopad_alignment = 0;
+	unsigned int digestsize = crypto_ahash_digestsize(tfm);
+	unsigned int kctx_len = sizeof(*key_ctx);
+	u8 hash_size_in_response = 0;
+
+	iopad_alignment = KEYCTX_ALIGN_PAD(digestsize);
+	kctx_len += param->alg_prm.result_size + iopad_alignment;
+	if (param->opad_needed)
+		kctx_len += param->alg_prm.result_size + iopad_alignment;
+
+	if (req_ctx->result)
+		hash_size_in_response = digestsize;
+	else
+		hash_size_in_response = param->alg_prm.result_size;
+	transhdr_len = HASH_TRANSHDR_SIZE(kctx_len);
+	skb = alloc_skb((transhdr_len + sizeof(struct sge_opaque_hdr)),
+			GFP_ATOMIC);
+	if (!skb)
+		return skb;
+
+	skb_reserve(skb, sizeof(struct sge_opaque_hdr));
+	wreq = (struct fw_crypto_lookaside_wr *)__skb_put(skb, transhdr_len);
+	memset(wreq, 0, transhdr_len);
+
+	sec_cpl = (struct cpl_tx_sec_pdu *)((u8 *)wreq + SEC_CPL_OFFSET);
+	sec_cpl->op_ivinsrtofst =
+		FILL_SEC_CPL_OP_IVINSR(ctx->dev->tx_channel_id, 2, 0, 0);
+	sec_cpl->pldlen = htonl(param->bfr_len + param->sg_len);
+
+	sec_cpl->aadstart_cipherstop_hi =
+		FILL_SEC_CPL_CIPHERSTOP_HI(0, 0, 0, 0);
+	sec_cpl->cipherstop_lo_authinsert =
+		FILL_SEC_CPL_AUTHINSERT(0, 1, 0, 0);
+	sec_cpl->seqno_numivs =
+		FILL_SEC_CPL_SCMD0_SEQNO(0, 0, 0, param->alg_prm.auth_mode,
+					 param->opad_needed, 0, 0);
+
+	sec_cpl->ivgen_hdrlen =
+		FILL_SEC_CPL_IVGEN_HDRLEN(param->last, param->more, 0, 1, 0, 0);
+
+	key_ctx = (struct _key_ctx *)((u8 *)sec_cpl + sizeof(*sec_cpl));
+	memcpy(key_ctx->key, req_ctx->partial_hash, param->alg_prm.result_size);
+
+	if (param->opad_needed)
+		memcpy(key_ctx->key + ((param->alg_prm.result_size <= 32) ? 32 :
+				       CHCR_HASH_MAX_DIGEST_SIZE),
+		       hmacctx->opad, param->alg_prm.result_size);
+
+	key_ctx->ctx_hdr = FILL_KEY_CTX_HDR(CHCR_KEYCTX_NO_KEY,
+					    param->alg_prm.mk_size, 0,
+					    param->opad_needed,
+					    (kctx_len >> 4));
+	sec_cpl->scmd1 = cpu_to_be64((u64)param->scmd1);
+
+	skb_set_transport_header(skb, transhdr_len);
+	if (param->bfr_len != 0)
+		write_buffer_data_page_desc(req_ctx, skb, &frags, req_ctx->bfr,
+					    param->bfr_len);
+	if (param->sg_len != 0)
+		write_sg_data_page_desc(skb, &frags, req->src, param->sg_len);
+
+	create_wreq(ctx, wreq, req, skb, kctx_len, hash_size_in_response,
+		    0);
+	req_ctx->skb = skb;
+	skb_get(skb);
+	return skb;
+}
+
+static int chcr_ahash_update(struct ahash_request *req)
+{
+	struct chcr_ahash_req_ctx *req_ctx = ahash_request_ctx(req);
+	struct crypto_ahash *rtfm = crypto_ahash_reqtfm(req);
+	struct chcr_context *ctx = crypto_tfm_ctx(crypto_ahash_tfm(rtfm));
+	struct uld_ctx *u_ctx = NULL;
+	struct sk_buff *skb;
+	u8 remainder = 0, bs;
+	unsigned int nbytes = req->nbytes;
+	struct hash_wr_param params;
+
+	bs = crypto_tfm_alg_blocksize(crypto_ahash_tfm(rtfm));
+
+	u_ctx = ULD_CTX(ctx);
+	if (cxgb4_is_crypto_q_full(u_ctx->lldi.ports[0], ctx->tx_channel_id))
+		return -EBUSY;
+
+	if (nbytes + req_ctx->bfr_len >= bs) {
+		remainder = (nbytes + req_ctx->bfr_len) % bs;
+		nbytes = nbytes + req_ctx->bfr_len - remainder;
+	} else {
+		sg_pcopy_to_buffer(req->src, sg_nents(req->src), req_ctx->bfr +
+				   req_ctx->bfr_len, nbytes, 0);
+		req_ctx->bfr_len += nbytes;
+		return 0;
+	}
+
+	params.opad_needed = 0;
+	params.more = 1;
+	params.last = 0;
+	params.sg_len = nbytes - req_ctx->bfr_len;
+	params.bfr_len = req_ctx->bfr_len;
+	params.scmd1 = 0;
+	get_alg_config(&params.alg_prm, crypto_ahash_digestsize(rtfm));
+	req_ctx->result = 0;
+	req_ctx->data_len += params.sg_len + params.bfr_len;
+	skb = create_final_hash_wr(req, &params);
+	if (!skb)
+		return -ENOMEM;
+
+	req_ctx->bfr_len = remainder;
+	if (remainder)
+		sg_pcopy_to_buffer(req->src, sg_nents(req->src),
+				   req_ctx->bfr, remainder, req->nbytes -
+				   remainder);
+	skb->dev = u_ctx->lldi.ports[0];
+	set_wr_txq(skb, CPL_PRIORITY_DATA, ctx->tx_channel_id);
+	chcr_send_wr(skb);
+
+	return -EINPROGRESS;
+}
+
+static void create_last_hash_block(char *bfr_ptr, unsigned int bs, u64 scmd1)
+{
+	memset(bfr_ptr, 0, bs);
+	*bfr_ptr = 0x80;
+	if (bs == 64)
+		*(__be64 *)(bfr_ptr + 56) = cpu_to_be64(scmd1  << 3);
+	else
+		*(__be64 *)(bfr_ptr + 120) =  cpu_to_be64(scmd1  << 3);
+}
+
+static int chcr_ahash_final(struct ahash_request *req)
+{
+	struct chcr_ahash_req_ctx *req_ctx = ahash_request_ctx(req);
+	struct crypto_ahash *rtfm = crypto_ahash_reqtfm(req);
+	struct chcr_context *ctx = crypto_tfm_ctx(crypto_ahash_tfm(rtfm));
+	struct hash_wr_param params;
+	struct sk_buff *skb;
+	struct uld_ctx *u_ctx = NULL;
+	u8 bs = crypto_tfm_alg_blocksize(crypto_ahash_tfm(rtfm));
+
+	u_ctx = ULD_CTX(ctx);
+	if (is_hmac(crypto_ahash_tfm(rtfm)))
+		params.opad_needed = 1;
+	else
+		params.opad_needed = 0;
+	params.sg_len = 0;
+	get_alg_config(&params.alg_prm, crypto_ahash_digestsize(rtfm));
+	req_ctx->result = 1;
+	params.bfr_len = req_ctx->bfr_len;
+	req_ctx->data_len += params.bfr_len + params.sg_len;
+	if (req_ctx->bfr && (req_ctx->bfr_len == 0)) {
+		create_last_hash_block(req_ctx->bfr, bs, req_ctx->data_len);
+		params.last = 0;
+		params.more = 1;
+		params.scmd1 = 0;
+		params.bfr_len = bs;
+
+	} else {
+		params.scmd1 = req_ctx->data_len;
+		params.last = 1;
+		params.more = 0;
+	}
+	skb = create_final_hash_wr(req, &params);
+	skb->dev = u_ctx->lldi.ports[0];
+	set_wr_txq(skb, CPL_PRIORITY_DATA, ctx->tx_channel_id);
+	chcr_send_wr(skb);
+	return -EINPROGRESS;
+}
+
+static int chcr_ahash_finup(struct ahash_request *req)
+{
+	struct chcr_ahash_req_ctx *req_ctx = ahash_request_ctx(req);
+	struct crypto_ahash *rtfm = crypto_ahash_reqtfm(req);
+	struct chcr_context *ctx = crypto_tfm_ctx(crypto_ahash_tfm(rtfm));
+	struct uld_ctx *u_ctx = NULL;
+	struct sk_buff *skb;
+	struct hash_wr_param params;
+	u8  bs;
+
+	bs = crypto_tfm_alg_blocksize(crypto_ahash_tfm(rtfm));
+	u_ctx = ULD_CTX(ctx);
+
+	if (cxgb4_is_crypto_q_full(u_ctx->lldi.ports[0], ctx->tx_channel_id))
+		return -EBUSY;
+
+	if (is_hmac(crypto_ahash_tfm(rtfm)))
+		params.opad_needed = 1;
+	else
+		params.opad_needed = 0;
+
+	params.sg_len = req->nbytes;
+	params.bfr_len = req_ctx->bfr_len;
+	get_alg_config(&params.alg_prm, crypto_ahash_digestsize(rtfm));
+	req_ctx->data_len += params.bfr_len + params.sg_len;
+	req_ctx->result = 1;
+	if (req_ctx->bfr && (req_ctx->bfr_len + req->nbytes) == 0) {
+		create_last_hash_block(req_ctx->bfr, bs, req_ctx->data_len);
+		params.last = 0;
+		params.more = 1;
+		params.scmd1 = 0;
+		params.bfr_len = bs;
+	} else {
+		params.scmd1 = req_ctx->data_len;
+		params.last = 1;
+		params.more = 0;
+	}
+
+	skb = create_final_hash_wr(req, &params);
+	if (!skb)
+		return -ENOMEM;
+	skb->dev = u_ctx->lldi.ports[0];
+	set_wr_txq(skb, CPL_PRIORITY_DATA, ctx->tx_channel_id);
+	chcr_send_wr(skb);
+
+	return -EINPROGRESS;
+}
+
+static int chcr_ahash_digest(struct ahash_request *req)
+{
+	struct chcr_ahash_req_ctx *req_ctx = ahash_request_ctx(req);
+	struct crypto_ahash *rtfm = crypto_ahash_reqtfm(req);
+	struct chcr_context *ctx = crypto_tfm_ctx(crypto_ahash_tfm(rtfm));
+	struct uld_ctx *u_ctx = NULL;
+	struct sk_buff *skb;
+	struct hash_wr_param params;
+	u8  bs;
+
+	rtfm->init(req);
+	bs = crypto_tfm_alg_blocksize(crypto_ahash_tfm(rtfm));
+
+	u_ctx = ULD_CTX(ctx);
+	if (cxgb4_is_crypto_q_full(u_ctx->lldi.ports[0], ctx->tx_channel_id))
+		return -EBUSY;
+
+	if (is_hmac(crypto_ahash_tfm(rtfm)))
+		params.opad_needed = 1;
+	else
+		params.opad_needed = 0;
+
+	params.last = 0;
+	params.more = 0;
+	params.sg_len = req->nbytes;
+	params.bfr_len = 0;
+	params.scmd1 = 0;
+	get_alg_config(&params.alg_prm, crypto_ahash_digestsize(rtfm));
+	req_ctx->result = 1;
+	req_ctx->data_len += params.bfr_len + params.sg_len;
+
+	if (req_ctx->bfr && req->nbytes == 0) {
+		create_last_hash_block(req_ctx->bfr, bs, 0);
+		params.more = 1;
+		params.bfr_len = bs;
+	}
+
+	skb = create_final_hash_wr(req, &params);
+	if (!skb)
+		return -ENOMEM;
+
+	skb->dev = u_ctx->lldi.ports[0];
+	set_wr_txq(skb, CPL_PRIORITY_DATA, ctx->tx_channel_id);
+	chcr_send_wr(skb);
+	return -EINPROGRESS;
+}
+
+static int chcr_ahash_export(struct ahash_request *areq, void *out)
+{
+	struct chcr_ahash_req_ctx *req_ctx = ahash_request_ctx(areq);
+	struct chcr_ahash_req_ctx *state = out;
+
+	state->bfr_len = req_ctx->bfr_len;
+	state->data_len = req_ctx->data_len;
+	memcpy(state->bfr, req_ctx->bfr, CHCR_HASH_MAX_BLOCK_SIZE_128);
+	memcpy(state->partial_hash, req_ctx->partial_hash,
+	       CHCR_HASH_MAX_DIGEST_SIZE);
+	return 0;
+}
+
+static int chcr_ahash_import(struct ahash_request *areq, const void *in)
+{
+	struct chcr_ahash_req_ctx *req_ctx = ahash_request_ctx(areq);
+	struct chcr_ahash_req_ctx *state = (struct chcr_ahash_req_ctx *)in;
+
+	req_ctx->bfr_len = state->bfr_len;
+	req_ctx->data_len = state->data_len;
+	req_ctx->dummy_payload_ptr = NULL;
+	memcpy(req_ctx->bfr, state->bfr, CHCR_HASH_MAX_BLOCK_SIZE_128);
+	memcpy(req_ctx->partial_hash, state->partial_hash,
+	       CHCR_HASH_MAX_DIGEST_SIZE);
+	return 0;
+}
+
+static int chcr_ahash_setkey(struct crypto_ahash *tfm, const u8 *key,
+			     unsigned int keylen)
+{
+	struct chcr_context *ctx = crypto_tfm_ctx(crypto_ahash_tfm(tfm));
+	struct hmac_ctx *hmacctx = HMAC_CTX(ctx);
+	unsigned int digestsize = crypto_ahash_digestsize(tfm);
+	unsigned int bs = crypto_tfm_alg_blocksize(crypto_ahash_tfm(tfm));
+	unsigned int i, err = 0, updated_digestsize;
+
+	/*
+	 * use the key to calculate the ipad and opad. ipad will sent with the
+	 * first request's data. opad will be sent with the final hash result
+	 * ipad in hmacctx->ipad and opad in hmacctx->opad location
+	 */
+	if (!hmacctx->desc)
+		return -EINVAL;
+	if (keylen > bs) {
+		err = crypto_shash_digest(hmacctx->desc, key, keylen,
+					  hmacctx->ipad);
+		if (err)
+			goto out;
+		keylen = digestsize;
+	} else {
+		memcpy(hmacctx->ipad, key, keylen);
+	}
+	memset(hmacctx->ipad + keylen, 0, bs - keylen);
+	memcpy(hmacctx->opad, hmacctx->ipad, bs);
+
+	for (i = 0; i < bs / sizeof(int); i++) {
+		*((unsigned int *)(&hmacctx->ipad) + i) ^= IPAD_DATA;
+		*((unsigned int *)(&hmacctx->opad) + i) ^= OPAD_DATA;
+	}
+
+	updated_digestsize = digestsize;
+	if (digestsize == SHA224_DIGEST_SIZE)
+		updated_digestsize = SHA256_DIGEST_SIZE;
+	else if (digestsize == SHA384_DIGEST_SIZE)
+		updated_digestsize = SHA512_DIGEST_SIZE;
+	err = chcr_compute_partial_hash(hmacctx->desc, hmacctx->ipad,
+					hmacctx->ipad, digestsize);
+	if (err)
+		goto out;
+	chcr_change_order(hmacctx->ipad, updated_digestsize);
+
+	err = chcr_compute_partial_hash(hmacctx->desc, hmacctx->opad,
+					hmacctx->opad, digestsize);
+	if (err)
+		goto out;
+	chcr_change_order(hmacctx->opad, updated_digestsize);
+out:
+	return err;
+}
+
+static int chcr_aes_xts_setkey(struct crypto_ablkcipher *tfm, const u8 *key,
+			       unsigned int key_len)
+{
+	struct chcr_context *ctx = crypto_ablkcipher_ctx(tfm);
+	struct ablk_ctx *ablkctx = ABLK_CTX(ctx);
+	int status = 0;
+	unsigned short context_size = 0;
+
+	if ((key_len == (AES_KEYSIZE_128 << 1)) ||
+	    (key_len == (AES_KEYSIZE_256 << 1))) {
+		memcpy(ablkctx->key, key, key_len);
+		ablkctx->enckey_len = key_len;
+		context_size = (KEY_CONTEXT_HDR_SALT_AND_PAD + key_len) >> 4;
+		ablkctx->key_ctx_hdr =
+			FILL_KEY_CTX_HDR((key_len == AES_KEYSIZE_256) ?
+					 CHCR_KEYCTX_CIPHER_KEY_SIZE_128 :
+					 CHCR_KEYCTX_CIPHER_KEY_SIZE_256,
+					 CHCR_KEYCTX_NO_KEY, 1,
+					 0, context_size);
+		ablkctx->ciph_mode = CHCR_SCMD_CIPHER_MODE_AES_XTS;
+	} else {
+		crypto_tfm_set_flags((struct crypto_tfm *)tfm,
+				     CRYPTO_TFM_RES_BAD_KEY_LEN);
+		ablkctx->enckey_len = 0;
+		status = -EINVAL;
+	}
+	return status;
+}
+
+static int chcr_sha_init(struct ahash_request *areq)
+{
+	struct chcr_ahash_req_ctx *req_ctx = ahash_request_ctx(areq);
+	struct crypto_ahash *tfm = crypto_ahash_reqtfm(areq);
+	int digestsize =  crypto_ahash_digestsize(tfm);
+
+	req_ctx->data_len = 0;
+	req_ctx->dummy_payload_ptr = NULL;
+	req_ctx->bfr_len = 0;
+	req_ctx->skb = NULL;
+	req_ctx->result = 0;
+	copy_hash_init_values(req_ctx->partial_hash, digestsize);
+	return 0;
+}
+
+static int chcr_sha_cra_init(struct crypto_tfm *tfm)
+{
+	crypto_ahash_set_reqsize(__crypto_ahash_cast(tfm),
+				 sizeof(struct chcr_ahash_req_ctx));
+	return chcr_device_init(crypto_tfm_ctx(tfm));
+}
+
+static int chcr_hmac_init(struct ahash_request *areq)
+{
+	struct chcr_ahash_req_ctx *req_ctx = ahash_request_ctx(areq);
+	struct crypto_ahash *rtfm = crypto_ahash_reqtfm(areq);
+	struct chcr_context *ctx = crypto_tfm_ctx(crypto_ahash_tfm(rtfm));
+	struct hmac_ctx *hmacctx = HMAC_CTX(ctx);
+	unsigned int digestsize = crypto_ahash_digestsize(rtfm);
+	unsigned int bs = crypto_tfm_alg_blocksize(crypto_ahash_tfm(rtfm));
+
+	chcr_sha_init(areq);
+	req_ctx->data_len = bs;
+	if (is_hmac(crypto_ahash_tfm(rtfm))) {
+		if (digestsize == SHA224_DIGEST_SIZE)
+			memcpy(req_ctx->partial_hash, hmacctx->ipad,
+			       SHA256_DIGEST_SIZE);
+		else if (digestsize == SHA384_DIGEST_SIZE)
+			memcpy(req_ctx->partial_hash, hmacctx->ipad,
+			       SHA512_DIGEST_SIZE);
+		else
+			memcpy(req_ctx->partial_hash, hmacctx->ipad,
+			       digestsize);
+	}
+	return 0;
+}
+
+static int chcr_hmac_cra_init(struct crypto_tfm *tfm)
+{
+	struct chcr_context *ctx = crypto_tfm_ctx(tfm);
+	struct hmac_ctx *hmacctx = HMAC_CTX(ctx);
+	unsigned int digestsize =
+		crypto_ahash_digestsize(__crypto_ahash_cast(tfm));
+
+	crypto_ahash_set_reqsize(__crypto_ahash_cast(tfm),
+				 sizeof(struct chcr_ahash_req_ctx));
+	hmacctx->desc = chcr_alloc_shash(digestsize);
+	if (IS_ERR(hmacctx->desc))
+		return PTR_ERR(hmacctx->desc);
+	return chcr_device_init(crypto_tfm_ctx(tfm));
+}
+
+static void chcr_free_shash(struct shash_desc *desc)
+{
+	crypto_free_shash(desc->tfm);
+	kfree(desc);
+}
+
+static void chcr_hmac_cra_exit(struct crypto_tfm *tfm)
+{
+	struct chcr_context *ctx = crypto_tfm_ctx(tfm);
+	struct hmac_ctx *hmacctx = HMAC_CTX(ctx);
+
+	if (hmacctx->desc) {
+		chcr_free_shash(hmacctx->desc);
+		hmacctx->desc = NULL;
+	}
+}
+
+static struct chcr_alg_template driver_algs[] = {
+	/* AES-CBC */
+	{
+		.type = CRYPTO_ALG_TYPE_ABLKCIPHER,
+		.is_registered = 0,
+		.alg.crypto = {
+			.cra_name		= "cbc(aes)",
+			.cra_driver_name	= "cbc(aes-chcr)",
+			.cra_priority		= CHCR_CRA_PRIORITY,
+			.cra_flags		= CRYPTO_ALG_TYPE_BLKCIPHER |
+				CRYPTO_ALG_ASYNC,
+			.cra_blocksize		= AES_BLOCK_SIZE,
+			.cra_ctxsize		= sizeof(struct chcr_context)
+				+ sizeof(struct ablk_ctx),
+			.cra_alignmask		= 0,
+			.cra_type		= &crypto_ablkcipher_type,
+			.cra_module		= THIS_MODULE,
+			.cra_init		= chcr_cra_init,
+			.cra_exit		= NULL,
+			.cra_u.ablkcipher	= {
+				.min_keysize	= AES_MIN_KEY_SIZE,
+				.max_keysize	= AES_MAX_KEY_SIZE,
+				.ivsize		= AES_BLOCK_SIZE,
+				.setkey			= chcr_aes_cbc_setkey,
+				.encrypt		= chcr_aes_encrypt,
+				.decrypt		= chcr_aes_decrypt,
+			}
+		}
+	},
+	{
+		.type = CRYPTO_ALG_TYPE_ABLKCIPHER,
+		.is_registered = 0,
+		.alg.crypto =   {
+			.cra_name		= "xts(aes)",
+			.cra_driver_name	= "xts(aes-chcr)",
+			.cra_priority		= CHCR_CRA_PRIORITY,
+			.cra_flags		= CRYPTO_ALG_TYPE_BLKCIPHER |
+				CRYPTO_ALG_ASYNC,
+			.cra_blocksize		= AES_BLOCK_SIZE,
+			.cra_ctxsize		= sizeof(struct chcr_context) +
+				sizeof(struct ablk_ctx),
+			.cra_alignmask		= 0,
+			.cra_type		= &crypto_ablkcipher_type,
+			.cra_module		= THIS_MODULE,
+			.cra_init		= chcr_cra_init,
+			.cra_exit		= NULL,
+			.cra_u = {
+				.ablkcipher = {
+					.min_keysize	= 2 * AES_MIN_KEY_SIZE,
+					.max_keysize	= 2 * AES_MAX_KEY_SIZE,
+					.ivsize		= AES_BLOCK_SIZE,
+					.setkey		= chcr_aes_xts_setkey,
+					.encrypt	= chcr_aes_encrypt,
+					.decrypt	= chcr_aes_decrypt,
+				}
+			}
+		}
+	},
+	/* SHA */
+	{
+		.type = CRYPTO_ALG_TYPE_AHASH,
+		.is_registered = 0,
+		.alg.hash = {
+			.halg.digestsize = SHA1_DIGEST_SIZE,
+			.halg.base = {
+				.cra_name = "sha1",
+				.cra_driver_name = "sha1-chcr",
+				.cra_blocksize = SHA1_BLOCK_SIZE,
+			}
+		}
+	},
+	{
+		.type = CRYPTO_ALG_TYPE_AHASH,
+		.is_registered = 0,
+		.alg.hash = {
+			.halg.digestsize = SHA256_DIGEST_SIZE,
+			.halg.base = {
+				.cra_name = "sha256",
+				.cra_driver_name = "sha256-chcr",
+				.cra_blocksize = SHA256_BLOCK_SIZE,
+			}
+		}
+	},
+	{
+		.type = CRYPTO_ALG_TYPE_AHASH,
+		.is_registered = 0,
+		.alg.hash = {
+			.halg.digestsize = SHA224_DIGEST_SIZE,
+			.halg.base = {
+				.cra_name = "sha224",
+				.cra_driver_name = "sha224-chcr",
+				.cra_blocksize = SHA224_BLOCK_SIZE,
+			}
+		}
+	},
+	{
+		.type = CRYPTO_ALG_TYPE_AHASH,
+		.is_registered = 0,
+		.alg.hash = {
+			.halg.digestsize = SHA384_DIGEST_SIZE,
+			.halg.base = {
+				.cra_name = "sha384",
+				.cra_driver_name = "sha384-chcr",
+				.cra_blocksize = SHA384_BLOCK_SIZE,
+			}
+		}
+	},
+	{
+		.type = CRYPTO_ALG_TYPE_AHASH,
+		.is_registered = 0,
+		.alg.hash = {
+			.halg.digestsize = SHA512_DIGEST_SIZE,
+			.halg.base = {
+				.cra_name = "sha512",
+				.cra_driver_name = "sha512-chcr",
+				.cra_blocksize = SHA512_BLOCK_SIZE,
+			}
+		}
+	},
+	/* HMAC */
+	{
+		.type = CRYPTO_ALG_TYPE_HMAC,
+		.is_registered = 0,
+		.alg.hash = {
+			.halg.digestsize = SHA1_DIGEST_SIZE,
+			.halg.base = {
+				.cra_name = "hmac(sha1)",
+				.cra_driver_name = "hmac(sha1-chcr)",
+				.cra_blocksize = SHA1_BLOCK_SIZE,
+			}
+		}
+	},
+	{
+		.type = CRYPTO_ALG_TYPE_HMAC,
+		.is_registered = 0,
+		.alg.hash = {
+			.halg.digestsize = SHA224_DIGEST_SIZE,
+			.halg.base = {
+				.cra_name = "hmac(sha224)",
+				.cra_driver_name = "hmac(sha224-chcr)",
+				.cra_blocksize = SHA224_BLOCK_SIZE,
+			}
+		}
+	},
+	{
+		.type = CRYPTO_ALG_TYPE_HMAC,
+		.is_registered = 0,
+		.alg.hash = {
+			.halg.digestsize = SHA256_DIGEST_SIZE,
+			.halg.base = {
+				.cra_name = "hmac(sha256)",
+				.cra_driver_name = "hmac(sha256-chcr)",
+				.cra_blocksize = SHA256_BLOCK_SIZE,
+			}
+		}
+	},
+	{
+		.type = CRYPTO_ALG_TYPE_HMAC,
+		.is_registered = 0,
+		.alg.hash = {
+			.halg.digestsize = SHA384_DIGEST_SIZE,
+			.halg.base = {
+				.cra_name = "hmac(sha384)",
+				.cra_driver_name = "hmac(sha384-chcr)",
+				.cra_blocksize = SHA384_BLOCK_SIZE,
+			}
+		}
+	},
+	{
+		.type = CRYPTO_ALG_TYPE_HMAC,
+		.is_registered = 0,
+		.alg.hash = {
+			.halg.digestsize = SHA512_DIGEST_SIZE,
+			.halg.base = {
+				.cra_name = "hmac(sha512)",
+				.cra_driver_name = "hmac(sha512-chcr)",
+				.cra_blocksize = SHA512_BLOCK_SIZE,
+			}
+		}
+	},
+};
+
+/*
+ *	chcr_unregister_alg - Deregister crypto algorithms with
+ *	kernel framework.
+ */
+static int chcr_unregister_alg(void)
+{
+	int i;
+
+	for (i = 0; i < ARRAY_SIZE(driver_algs); i++) {
+		switch (driver_algs[i].type & CRYPTO_ALG_TYPE_MASK) {
+		case CRYPTO_ALG_TYPE_ABLKCIPHER:
+			if (driver_algs[i].is_registered)
+				crypto_unregister_alg(
+						&driver_algs[i].alg.crypto);
+			break;
+		case CRYPTO_ALG_TYPE_AHASH:
+			if (driver_algs[i].is_registered)
+				crypto_unregister_ahash(
+						&driver_algs[i].alg.hash);
+			break;
+		}
+		driver_algs[i].is_registered = 0;
+	}
+	return 0;
+}
+
+/*
+ *	chcr_register_alg - Register crypto algorithms with kernel framework.
+ */
+static int chcr_register_alg(void)
+{
+	struct crypto_alg ai;
+	int err = 0, i;
+	char *name = NULL;
+
+	for (i = 0; i < ARRAY_SIZE(driver_algs); i++) {
+		if (driver_algs[i].is_registered)
+			continue;
+		switch (driver_algs[i].type & CRYPTO_ALG_TYPE_MASK) {
+		case CRYPTO_ALG_TYPE_ABLKCIPHER:
+			err = crypto_register_alg(&driver_algs[i].alg.crypto);
+			name = driver_algs[i].alg.crypto.cra_driver_name;
+			break;
+		case CRYPTO_ALG_TYPE_AHASH:
+			driver_algs[i].alg.hash.update = chcr_ahash_update;
+			driver_algs[i].alg.hash.final = chcr_ahash_final;
+			driver_algs[i].alg.hash.finup = chcr_ahash_finup;
+			driver_algs[i].alg.hash.digest = chcr_ahash_digest;
+			driver_algs[i].alg.hash.export = chcr_ahash_export;
+			driver_algs[i].alg.hash.import = chcr_ahash_import;
+			driver_algs[i].alg.hash.halg.statesize =
+				sizeof(struct chcr_ahash_req_ctx);
+			driver_algs[i].alg.hash.halg.base.cra_priority =
+				CHCR_CRA_PRIORITY;
+			driver_algs[i].alg.hash.halg.base.cra_module =
+				THIS_MODULE;
+			driver_algs[i].alg.hash.halg.base.cra_flags =
+				CRYPTO_ALG_TYPE_AHASH | CRYPTO_ALG_ASYNC;
+			driver_algs[i].alg.hash.halg.base.cra_alignmask = 0;
+			driver_algs[i].alg.hash.halg.base.cra_exit = NULL;
+			driver_algs[i].alg.hash.halg.base.cra_type =
+				&crypto_ahash_type;
+
+			if (driver_algs[i].type == CRYPTO_ALG_TYPE_HMAC) {
+				driver_algs[i].alg.hash.halg.base.cra_init =
+				driver_algs[i].alg.hash.halg.base.cra_init =
+					chcr_hmac_cra_init;
+				driver_algs[i].alg.hash.halg.base.cra_exit =
+					chcr_hmac_cra_exit;
+
+				driver_algs[i].alg.hash.init = chcr_hmac_init;
+
+				driver_algs[i].alg.hash.setkey =
+					chcr_ahash_setkey;
+				driver_algs[i].alg.hash.halg.base.cra_ctxsize =
+					sizeof(struct chcr_context) +
+					sizeof(struct hmac_ctx);
+			} else {
+				driver_algs[i].alg.hash.halg.base.cra_init =
+					chcr_sha_cra_init;
+				driver_algs[i].alg.hash.init = chcr_sha_init;
+
+				driver_algs[i].alg.hash.halg.base.cra_ctxsize =
+					sizeof(struct chcr_context);
+			}
+			err = crypto_register_ahash(&driver_algs[i].alg.hash);
+			ai = driver_algs[i].alg.hash.halg.base;
+			name = ai.cra_driver_name;
+			break;
+		}
+		if (err) {
+			pr_err("chcr : %s : Algorithm registration failed\n",
+			       name);
+			goto register_err;
+		} else {
+			driver_algs[i].is_registered = 1;
+		}
+	}
+	return 0;
+
+register_err:
+	chcr_unregister_alg();
+	return err;
+}
+
+/*
+ *	start_crypto - Register the crypto algorithms.
+ *	This should called once when the first device comesup. After this
+ *	kernel will start calling driver APIs for crypto operations.
+ */
+int start_crypto(void)
+{
+	return chcr_register_alg();
+}
+
+/*
+ *	stop_crypto - Deregister all the crypto algorithms with kernel.
+ *	This should be called once when the last device goes down. After this
+ *	kernel will not call the driver API for crypto operations.
+ */
+int stop_crypto(void)
+{
+	chcr_unregister_alg();
+	return 0;
+}
diff --git a/drivers/crypto/chelsio/chcr_algo.h b/drivers/crypto/chelsio/chcr_algo.h
new file mode 100644
index 0000000..34ded07
--- /dev/null
+++ b/drivers/crypto/chelsio/chcr_algo.h
@@ -0,0 +1,502 @@
+/*
+ * This file is part of the Chelsio T6 Crypto driver for Linux.
+ *
+ * Copyright (c) 2003-2016 Chelsio Communications, Inc. All rights reserved.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * OpenIB.org BSD license below:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and/or other materials
+ *        provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ *
+ */
+
+#ifndef __CHCR_ALGO_H__
+#define __CHCR_ALGO_H__
+
+/* Crypto key context */
+#define S_KEY_CONTEXT_CTX_LEN           24
+#define M_KEY_CONTEXT_CTX_LEN           0xff
+#define V_KEY_CONTEXT_CTX_LEN(x)        ((x) << S_KEY_CONTEXT_CTX_LEN)
+#define G_KEY_CONTEXT_CTX_LEN(x) \
+	(((x) >> S_KEY_CONTEXT_CTX_LEN) & M_KEY_CONTEXT_CTX_LEN)
+
+#define S_KEY_CONTEXT_DUAL_CK      12
+#define M_KEY_CONTEXT_DUAL_CK      0x1
+#define V_KEY_CONTEXT_DUAL_CK(x)   ((x) << S_KEY_CONTEXT_DUAL_CK)
+#define G_KEY_CONTEXT_DUAL_CK(x)   \
+(((x) >> S_KEY_CONTEXT_DUAL_CK) & M_KEY_CONTEXT_DUAL_CK)
+#define F_KEY_CONTEXT_DUAL_CK      V_KEY_CONTEXT_DUAL_CK(1U)
+
+#define S_KEY_CONTEXT_SALT_PRESENT      10
+#define M_KEY_CONTEXT_SALT_PRESENT      0x1
+#define V_KEY_CONTEXT_SALT_PRESENT(x)   ((x) << S_KEY_CONTEXT_SALT_PRESENT)
+#define G_KEY_CONTEXT_SALT_PRESENT(x)   \
+	(((x) >> S_KEY_CONTEXT_SALT_PRESENT) & \
+	 M_KEY_CONTEXT_SALT_PRESENT)
+#define F_KEY_CONTEXT_SALT_PRESENT      V_KEY_CONTEXT_SALT_PRESENT(1U)
+
+#define S_KEY_CONTEXT_VALID     0
+#define M_KEY_CONTEXT_VALID     0x1
+#define V_KEY_CONTEXT_VALID(x)  ((x) << S_KEY_CONTEXT_VALID)
+#define G_KEY_CONTEXT_VALID(x)  \
+	(((x) >> S_KEY_CONTEXT_VALID) & \
+	 M_KEY_CONTEXT_VALID)
+#define F_KEY_CONTEXT_VALID     V_KEY_CONTEXT_VALID(1U)
+
+#define S_KEY_CONTEXT_CK_SIZE           6
+#define M_KEY_CONTEXT_CK_SIZE           0xf
+#define V_KEY_CONTEXT_CK_SIZE(x)        ((x) << S_KEY_CONTEXT_CK_SIZE)
+#define G_KEY_CONTEXT_CK_SIZE(x)        \
+	(((x) >> S_KEY_CONTEXT_CK_SIZE) & M_KEY_CONTEXT_CK_SIZE)
+
+#define S_KEY_CONTEXT_MK_SIZE           2
+#define M_KEY_CONTEXT_MK_SIZE           0xf
+#define V_KEY_CONTEXT_MK_SIZE(x)        ((x) << S_KEY_CONTEXT_MK_SIZE)
+#define G_KEY_CONTEXT_MK_SIZE(x)        \
+	(((x) >> S_KEY_CONTEXT_MK_SIZE) & M_KEY_CONTEXT_MK_SIZE)
+
+#define S_KEY_CONTEXT_OPAD_PRESENT      11
+#define M_KEY_CONTEXT_OPAD_PRESENT      0x1
+#define V_KEY_CONTEXT_OPAD_PRESENT(x)   ((x) << S_KEY_CONTEXT_OPAD_PRESENT)
+#define G_KEY_CONTEXT_OPAD_PRESENT(x)   \
+	(((x) >> S_KEY_CONTEXT_OPAD_PRESENT) & \
+	 M_KEY_CONTEXT_OPAD_PRESENT)
+#define F_KEY_CONTEXT_OPAD_PRESENT      V_KEY_CONTEXT_OPAD_PRESENT(1U)
+
+#define CHCR_HASH_MAX_DIGEST_SIZE 64
+#define CHCR_MAX_SHA_DIGEST_SIZE 64
+
+#define IPSEC_TRUNCATED_ICV_SIZE 12
+#define TLS_TRUNCATED_HMAC_SIZE 10
+#define CBCMAC_DIGEST_SIZE 16
+#define MAX_HASH_NAME 20
+
+#define SHA1_INIT_STATE_5X4B    5
+#define SHA256_INIT_STATE_8X4B  8
+#define SHA512_INIT_STATE_8X8B  8
+#define SHA1_INIT_STATE         SHA1_INIT_STATE_5X4B
+#define SHA224_INIT_STATE       SHA256_INIT_STATE_8X4B
+#define SHA256_INIT_STATE       SHA256_INIT_STATE_8X4B
+#define SHA384_INIT_STATE       SHA512_INIT_STATE_8X8B
+#define SHA512_INIT_STATE       SHA512_INIT_STATE_8X8B
+
+#define DUMMY_BYTES 16
+
+#define IPAD_DATA 0x36363636
+#define OPAD_DATA 0x5c5c5c5c
+
+#define TRANSHDR_SIZE(alignedkctx_len)\
+	(sizeof(struct ulptx_idata) +\
+	 sizeof(struct ulp_txpkt) +\
+	 sizeof(struct fw_crypto_lookaside_wr) +\
+	 sizeof(struct cpl_tx_sec_pdu) +\
+	 (alignedkctx_len))
+#define CIPHER_TRANSHDR_SIZE(alignedkctx_len, sge_pairs) \
+	(TRANSHDR_SIZE(alignedkctx_len) + sge_pairs +\
+	 sizeof(struct cpl_rx_phys_dsgl))
+#define HASH_TRANSHDR_SIZE(alignedkctx_len)\
+	(TRANSHDR_SIZE(alignedkctx_len) + DUMMY_BYTES)
+
+#define SEC_CPL_OFFSET (sizeof(struct fw_crypto_lookaside_wr) + \
+			sizeof(struct ulp_txpkt) + \
+			sizeof(struct ulptx_idata))
+
+#define FILL_SEC_CPL_OP_IVINSR(id, len, hldr, ofst)      \
+	htonl( \
+	       V_CPL_TX_SEC_PDU_OPCODE(CPL_TX_SEC_PDU) | \
+	       V_CPL_TX_SEC_PDU_RXCHID((id)) | \
+	       V_CPL_TX_SEC_PDU_ACKFOLLOWS(0) | \
+	       V_CPL_TX_SEC_PDU_ULPTXLPBK(1) | \
+	       V_CPL_TX_SEC_PDU_CPLLEN((len)) | \
+	       V_CPL_TX_SEC_PDU_PLACEHOLDER((hldr)) | \
+	       V_CPL_TX_SEC_PDU_IVINSRTOFST((ofst)))
+
+#define  FILL_SEC_CPL_CIPHERSTOP_HI(a_start, a_stop, c_start, c_stop_hi) \
+	htonl( \
+	       V_CPL_TX_SEC_PDU_AADSTART((a_start)) | \
+	       V_CPL_TX_SEC_PDU_AADSTOP((a_stop)) | \
+	       V_CPL_TX_SEC_PDU_CIPHERSTART((c_start)) | \
+	       V_CPL_TX_SEC_PDU_CIPHERSTOP_HI((c_stop_hi)))
+
+#define  FILL_SEC_CPL_AUTHINSERT(c_stop_lo, a_start, a_stop, a_inst) \
+	htonl( \
+	       V_CPL_TX_SEC_PDU_CIPHERSTOP_LO((c_stop_lo)) | \
+		V_CPL_TX_SEC_PDU_AUTHSTART((a_start)) | \
+		V_CPL_TX_SEC_PDU_AUTHSTOP((a_stop)) | \
+		V_CPL_TX_SEC_PDU_AUTHINSERT((a_inst)))
+
+#define  FILL_SEC_CPL_SCMD0_SEQNO(ctrl, seq, cmode, amode, opad, size, nivs)  \
+		htonl( \
+		V_SCMD_SEQ_NO_CTRL(0) | \
+		V_SCMD_STATUS_PRESENT(0) | \
+		V_SCMD_PROTO_VERSION(CHCR_SCMD_PROTO_VERSION_GENERIC) | \
+		V_SCMD_ENC_DEC_CTRL((ctrl)) | \
+		V_SCMD_CIPH_AUTH_SEQ_CTRL((seq)) | \
+		V_SCMD_CIPH_MODE((cmode)) | \
+		V_SCMD_AUTH_MODE((amode)) | \
+		V_SCMD_HMAC_CTRL((opad)) | \
+		V_SCMD_IV_SIZE((size)) | \
+		V_SCMD_NUM_IVS((nivs)))
+
+#define FILL_SEC_CPL_IVGEN_HDRLEN(last, more, ctx_in, mac, ivdrop, len) htonl( \
+		V_SCMD_ENB_DBGID(0) | \
+		V_SCMD_IV_GEN_CTRL(0) | \
+		V_SCMD_LAST_FRAG((last)) | \
+		V_SCMD_MORE_FRAGS((more)) | \
+		V_SCMD_TLS_COMPPDU(0) | \
+		V_SCMD_KEY_CTX_INLINE((ctx_in)) | \
+		V_SCMD_TLS_FRAG_ENABLE(0) | \
+		V_SCMD_MAC_ONLY((mac)) |  \
+		V_SCMD_AADIVDROP((ivdrop)) | \
+		V_SCMD_HDR_LEN((len)))
+
+#define  FILL_KEY_CTX_HDR(ck_size, mk_size, d_ck, opad, ctx_len) \
+		htonl(V_KEY_CONTEXT_VALID(1) | \
+		      V_KEY_CONTEXT_CK_SIZE((ck_size)) | \
+		      V_KEY_CONTEXT_MK_SIZE(mk_size) | \
+		      V_KEY_CONTEXT_DUAL_CK((d_ck)) | \
+		      V_KEY_CONTEXT_OPAD_PRESENT((opad)) | \
+		      V_KEY_CONTEXT_SALT_PRESENT(1) | \
+		      V_KEY_CONTEXT_CTX_LEN((ctx_len)))
+
+#define FILL_WR_OP_CCTX_SIZE(len, ctx_len) \
+		htonl( \
+			V_FW_CRYPTO_LOOKASIDE_WR_OPCODE( \
+			FW_CRYPTO_LOOKASIDE_WR) | \
+			V_FW_CRYPTO_LOOKASIDE_WR_COMPL(0) | \
+			V_FW_CRYPTO_LOOKASIDE_WR_IMM_LEN((len)) | \
+			V_FW_CRYPTO_LOOKASIDE_WR_CCTX_LOC(1) | \
+			V_FW_CRYPTO_LOOKASIDE_WR_CCTX_SIZE((ctx_len)))
+
+#define FILL_WR_RX_Q_ID(cid, qid, wr_iv) \
+		htonl( \
+			V_FW_CRYPTO_LOOKASIDE_WR_RX_CHID((cid)) | \
+			V_FW_CRYPTO_LOOKASIDE_WR_RX_Q_ID((qid)) | \
+			V_FW_CRYPTO_LOOKASIDE_WR_LCB(0) | \
+			V_FW_CRYPTO_LOOKASIDE_WR_IV((wr_iv)))
+
+#define FILL_ULPTX_CMD_DEST(cid) \
+	htonl(V_ULPTX_CMD(ULP_TX_PKT) | \
+	      V_ULP_TXPKT_DEST(0) | \
+	      V_ULP_TXPKT_DATAMODIFY(0) | \
+	      V_ULP_TXPKT_CHANNELID((cid)) | \
+	      V_ULP_TXPKT_RO(1) | \
+	      V_ULP_TXPKT_FID(0))
+
+#define KEYCTX_ALIGN_PAD(bs) ({unsigned int _bs = (bs);\
+			      _bs == SHA1_DIGEST_SIZE ? 12 : 0; })
+
+#define FILL_PLD_SIZE_HASH_SIZE(payload_sgl_len, sgl_lengths, total_frags) \
+	htonl(V_FW_CRYPTO_LOOKASIDE_WR_PLD_SIZE(payload_sgl_len ? \
+						sgl_lengths[total_frags] : 0) |\
+	      V_FW_CRYPTO_LOOKASIDE_WR_HASH_SIZE(0))
+
+#define FILL_LEN_PKD(calc_tx_flits_ofld, skb) \
+	htonl(V_FW_CRYPTO_LOOKASIDE_WR_LEN16(DIV_ROUND_UP((\
+					   calc_tx_flits_ofld(skb) * 8), 16)))
+
+#define FILL_CMD_MORE(immdatalen) htonl(V_ULPTX_CMD(ULP_TX_SC_IMM) |\
+					V_ULP_TX_SC_MORE((immdatalen) ? 0 : 1))
+
+#define MAX_NK 8
+
+struct algo_param {
+	unsigned int auth_mode;
+	unsigned int mk_size;
+	unsigned int result_size;
+};
+
+struct hash_wr_param {
+	unsigned int opad_needed;
+	unsigned int more;
+	unsigned int last;
+	struct algo_param alg_prm;
+	unsigned int sg_len;
+	unsigned int bfr_len;
+	u64 scmd1;
+};
+
+enum {
+	AES_KEYLENGTH_128BIT = 128,
+	AES_KEYLENGTH_192BIT = 192,
+	AES_KEYLENGTH_256BIT = 256
+};
+
+enum {
+	KEYLENGTH_3BYTES = 3,
+	KEYLENGTH_4BYTES = 4,
+	KEYLENGTH_6BYTES = 6,
+	KEYLENGTH_8BYTES = 8
+};
+
+enum {
+	NUMBER_OF_ROUNDS_10 = 10,
+	NUMBER_OF_ROUNDS_12 = 12,
+	NUMBER_OF_ROUNDS_14 = 14,
+};
+
+/*
+ * CCM defines values of 4, 6, 8, 10, 12, 14, and 16 octets,
+ * where they indicate the size of the integrity check value (ICV)
+ */
+enum {
+	AES_CCM_ICV_4   = 4,
+	AES_CCM_ICV_6   = 6,
+	AES_CCM_ICV_8   = 8,
+	AES_CCM_ICV_10  = 10,
+	AES_CCM_ICV_12  = 12,
+	AES_CCM_ICV_14  = 14,
+	AES_CCM_ICV_16 = 16
+};
+
+struct hash_op_params {
+	unsigned char mk_size;
+	unsigned char pad_align;
+	unsigned char auth_mode;
+	char hash_name[MAX_HASH_NAME];
+	unsigned short block_size;
+	unsigned short word_size;
+	unsigned short ipad_size;
+};
+
+struct phys_sge_pairs {
+	__be16 len[8];
+	__be64 addr[8];
+};
+
+struct phys_sge_parm {
+	unsigned int nents;
+	unsigned int obsize;
+	unsigned short qid;
+	unsigned char align;
+};
+
+struct crypto_result {
+	struct completion completion;
+	int err;
+};
+
+static const u32 sha1_init[SHA1_DIGEST_SIZE / 4] = {
+		SHA1_H0, SHA1_H1, SHA1_H2, SHA1_H3, SHA1_H4,
+};
+
+static const u32 sha224_init[SHA256_DIGEST_SIZE / 4] = {
+		SHA224_H0, SHA224_H1, SHA224_H2, SHA224_H3,
+		SHA224_H4, SHA224_H5, SHA224_H6, SHA224_H7,
+};
+
+static const u32 sha256_init[SHA256_DIGEST_SIZE / 4] = {
+		SHA256_H0, SHA256_H1, SHA256_H2, SHA256_H3,
+		SHA256_H4, SHA256_H5, SHA256_H6, SHA256_H7,
+};
+
+static const u64 sha384_init[SHA512_DIGEST_SIZE / 8] = {
+		SHA384_H0, SHA384_H1, SHA384_H2, SHA384_H3,
+		SHA384_H4, SHA384_H5, SHA384_H6, SHA384_H7,
+};
+
+static const u64 sha512_init[SHA512_DIGEST_SIZE / 8] = {
+		SHA512_H0, SHA512_H1, SHA512_H2, SHA512_H3,
+		SHA512_H4, SHA512_H5, SHA512_H6, SHA512_H7,
+};
+
+static inline void copy_hash_init_values(char *key, int digestsize)
+{
+	u8 i;
+	__be32 *dkey = (__be32 *)key;
+	u64 *ldkey = (u64 *)key;
+	__be64 *sha384 = (__be64 *)sha384_init;
+	__be64 *sha512 = (__be64 *)sha512_init;
+
+	switch (digestsize) {
+	case SHA1_DIGEST_SIZE:
+		for (i = 0; i < SHA1_INIT_STATE; i++)
+			dkey[i] = cpu_to_be32(sha1_init[i]);
+		break;
+	case SHA224_DIGEST_SIZE:
+		for (i = 0; i < SHA224_INIT_STATE; i++)
+			dkey[i] = cpu_to_be32(sha224_init[i]);
+		break;
+	case SHA256_DIGEST_SIZE:
+		for (i = 0; i < SHA256_INIT_STATE; i++)
+			dkey[i] = cpu_to_be32(sha256_init[i]);
+		break;
+	case SHA384_DIGEST_SIZE:
+		for (i = 0; i < SHA384_INIT_STATE; i++)
+			ldkey[i] = be64_to_cpu(sha384[i]);
+		break;
+	case SHA512_DIGEST_SIZE:
+		for (i = 0; i < SHA512_INIT_STATE; i++)
+			ldkey[i] = be64_to_cpu(sha512[i]);
+		break;
+	}
+}
+
+static const u8 sgl_lengths[20] = {
+	0, 1, 2, 3, 4, 4, 5, 6, 7, 7, 8, 9, 10, 10, 11, 12, 13, 13, 14, 15
+};
+
+/* Number of len fields(8) * size of one addr field */
+#define PHYSDSGL_MAX_LEN_SIZE 16
+
+static inline u16 get_space_for_phys_dsgl(unsigned int sgl_entr)
+{
+	/* len field size + addr field size */
+	return ((sgl_entr >> 3) + ((sgl_entr % 8) ?
+				   1 : 0)) * PHYSDSGL_MAX_LEN_SIZE +
+		(sgl_entr << 3) + ((sgl_entr % 2 ? 1 : 0) << 3);
+}
+
+/* The AES s-transform matrix (s-box). */
+static const u8 aes_sbox[256] = {
+	99,  124, 119, 123, 242, 107, 111, 197, 48,  1,   103, 43,  254, 215,
+	171, 118, 202, 130, 201, 125, 250, 89,  71,  240, 173, 212, 162, 175,
+	156, 164, 114, 192, 183, 253, 147, 38,  54,  63,  247, 204, 52,  165,
+	229, 241, 113, 216, 49,  21, 4,   199, 35,  195, 24,  150, 5, 154, 7,
+	18,  128, 226, 235, 39,  178, 117, 9,   131, 44,  26,  27,  110, 90,
+	160, 82,  59,  214, 179, 41,  227, 47,  132, 83,  209, 0,   237, 32,
+	252, 177, 91,  106, 203, 190, 57,  74,  76,  88,  207, 208, 239, 170,
+	251, 67,  77,  51,  133, 69,  249, 2,   127, 80,  60,  159, 168, 81,
+	163, 64,  143, 146, 157, 56,  245, 188, 182, 218, 33,  16,  255, 243,
+	210, 205, 12,  19,  236, 95,  151, 68,  23,  196, 167, 126, 61,  100,
+	93,  25,  115, 96,  129, 79,  220, 34,  42,  144, 136, 70,  238, 184,
+	20,  222, 94,  11,  219, 224, 50,  58,  10,  73,  6,   36,  92,  194,
+	211, 172, 98,  145, 149, 228, 121, 231, 200, 55,  109, 141, 213, 78,
+	169, 108, 86,  244, 234, 101, 122, 174, 8, 186, 120, 37,  46,  28, 166,
+	180, 198, 232, 221, 116, 31,  75,  189, 139, 138, 112, 62,  181, 102,
+	72,  3,   246, 14,  97,  53,  87,  185, 134, 193, 29,  158, 225, 248,
+	152, 17,  105, 217, 142, 148, 155, 30,  135, 233, 206, 85,  40,  223,
+	140, 161, 137, 13,  191, 230, 66,  104, 65,  153, 45,  15,  176, 84,
+	187, 22
+};
+
+static u32 aes_ks_subword(const u32 w)
+{
+	u8 bytes[4];
+
+	*(u32 *)(&bytes[0]) = w;
+	bytes[0] = aes_sbox[bytes[0]];
+	bytes[1] = aes_sbox[bytes[1]];
+	bytes[2] = aes_sbox[bytes[2]];
+	bytes[3] = aes_sbox[bytes[3]];
+	return *(u32 *)(&bytes[0]);
+}
+
+static u32 round_constant[11] = {
+	0x01000000, 0x02000000, 0x04000000, 0x08000000,
+	0x10000000, 0x20000000, 0x40000000, 0x80000000,
+	0x1B000000, 0x36000000, 0x6C000000
+};
+
+/* dec_key - OUTPUT - Reverse round key
+ * key - INPUT - key
+ * keylength - INPUT - length of the key in number of bits
+ */
+static inline void get_aes_decrypt_key(unsigned char *dec_key,
+				       const unsigned char *key,
+				       unsigned int keylength)
+{
+	u32 temp;
+	__be32 val;
+	u32 w_ring[MAX_NK];
+	u8  w_last_ix;
+	int i, j, k = 0, flag = 0, start = 1, t1 = 0;
+	u8  nr, nk;
+
+	switch (keylength) {
+	case AES_KEYLENGTH_128BIT:
+		nk = KEYLENGTH_4BYTES;
+		nr = NUMBER_OF_ROUNDS_10;
+		start = 4;
+		break;
+
+	case AES_KEYLENGTH_192BIT:
+		nk = KEYLENGTH_6BYTES;
+		nr = NUMBER_OF_ROUNDS_12;
+		start = 2;
+		break;
+	case AES_KEYLENGTH_256BIT:
+		nk = KEYLENGTH_8BYTES;
+		nr = NUMBER_OF_ROUNDS_14;
+		start = 0;
+		break;
+	default:
+		return;
+	}
+
+	j = keylength >> KEYLENGTH_3BYTES;
+
+	/*
+	 * Need to do host byte order correction here since key is byte
+	 * oriented and the kx algorithm is word (u32) oriented.
+	 */
+	for (i = 0; i < nk; i += 1)
+		w_ring[i] = be32_to_cpu(*((__be32 *)&key[4 * i]));
+
+	i = (int)nk;
+	w_last_ix = i - 1;
+
+	while (i < (4 * (nr + 2))) {
+		temp = w_ring[w_last_ix];
+		if (!(i % nk)) {
+			temp = (temp << 8) | (temp >> 24);
+			temp = aes_ks_subword(temp);
+			temp ^= round_constant[i / nk - 1];
+		} else if ((nk > 6) && ((i % nk) == 4)) {
+			temp = aes_ks_subword(temp);
+		}
+		w_last_ix = (w_last_ix + 1) % nk;
+		temp ^= w_ring[w_last_ix];
+		w_ring[w_last_ix] = temp;
+		/* We need the round keys for round Nr+1 and Nr+2 (round key
+		 * Nr+2 is the round key beyond the last one used when
+		 * encrypting).  Rounds are numbered starting from 0, Nr=10
+		 * implies 11 rounds are used in encryption/decryption.
+		 */
+		if (i >= (4 * (nr - 1))) {
+			if (t1 >= start) {
+				if (j >= 0)
+					j -= 4;
+				if ((j < 0) && !flag) {
+					k = (keylength >> KEYLENGTH_3BYTES) - 4;
+					flag = 1;
+				}
+				if (k && flag)
+					k += 4;
+				if (j < 0)
+					j = 0;
+				val = cpu_to_be32(temp);
+				memcpy(dec_key + j + k,  (void *)&val,
+				       sizeof(u32));
+			} else {
+				t1++;
+			}
+		}
+		++i;
+	}
+}
+
+#endif /* __CHCR_ALGO_H__ */
diff --git a/drivers/crypto/chelsio/chcr_core.c b/drivers/crypto/chelsio/chcr_core.c
new file mode 100644
index 0000000..80c5dba
--- /dev/null
+++ b/drivers/crypto/chelsio/chcr_core.c
@@ -0,0 +1,273 @@
+/*
+ * This file is part of the Chelsio T6 Crypto driver for Linux.
+ *
+ * Copyright (c) 2003-2016 Chelsio Communications, Inc. All rights reserved.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * OpenIB.org BSD license below:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and/or other materials
+ *        provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ *
+ * Written and Maintained by:
+ *	Manoj Malviya (manojmalviya@chelsio.com)
+ *	Atul Gupta (atul.gupta@chelsio.com)
+ *	Jitendra Lulla (jlulla@chelsio.com)
+ *	Yeshaswi M R Gowda (yeshaswi@chelsio.com)
+ *	Harsh Jain (harsh@chelsio.com)
+ */
+
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/skbuff.h>
+
+#include <crypto/aes.h>
+#include <crypto/hash.h>
+
+#include "t4_msg.h"
+#include "chcr_core.h"
+
+static LIST_HEAD(uld_ctx_list);
+static DEFINE_MUTEX(dev_mutex);
+static atomic_t dev_count;
+
+typedef int (*chcr_handler_func)(struct chcr_dev *dev, unsigned char *input);
+static int cpl_fw6_pld_handler(struct chcr_dev *dev, unsigned char *input);
+static int chcr_uld_state_change(void *handle, enum cxgb4_state	state);
+static void *chcr_uld_add(const struct cxgb4_lld_info *lld);
+static int chcr_uld_control(void *handle, enum cxgb4_control control, ...);
+
+static chcr_handler_func work_handlers[NUM_CPL_CMDS] = {
+	[CPL_FW6_PLD] = cpl_fw6_pld_handler,
+};
+
+static const struct cxgb4_uld_info chcr_uld_info = {
+	.name = DRV_MODULE_NAME,
+	.add = chcr_uld_add,
+	.rx_handler = chcr_uld_rx_handler,
+	.state_change = chcr_uld_state_change,
+	.control = chcr_uld_control,
+};
+
+int assign_chcr_device(struct chcr_dev **dev)
+{
+	struct uld_ctx *u_ctx;
+
+	/*
+	 * Which device to use if multiple devices are available TODO
+	 * May be select the device based on round robin. One session
+	 * must go to the same device to maintain the ordering.
+	 */
+	mutex_lock(&dev_mutex); /* TODO ? */
+	u_ctx = list_first_entry(&uld_ctx_list, struct uld_ctx, entry);
+	if (!u_ctx) {
+		mutex_unlock(&dev_mutex);
+		goto err;
+	}
+
+	*dev = u_ctx->dev;
+	mutex_unlock(&dev_mutex);
+	return 0;
+err:
+	return -ENXIO;
+}
+
+static int chcr_dev_add(struct uld_ctx *u_ctx)
+{
+	struct chcr_dev *dev;
+
+	dev = kzalloc(sizeof(*dev), GFP_KERNEL);
+	if (!dev)
+		goto err;
+
+	spin_lock_init(&dev->lock_chcr_dev);
+	u_ctx->dev = dev;
+	dev->u_ctx = u_ctx;
+	atomic_inc(&dev_count);
+	return 0;
+err:
+	pr_err("CHCR Cannot allocate crypto dev\n");
+	return -ENXIO;
+}
+
+static int chcr_dev_remove(struct uld_ctx *u_ctx)
+{
+	kfree(u_ctx->dev);
+	u_ctx->dev = NULL;
+	atomic_dec(&dev_count);
+	return 0;
+}
+
+static int cpl_fw6_pld_handler(struct chcr_dev *dev,
+			       unsigned char *input)
+{
+	struct crypto_async_request *req;
+	struct cpl_fw6_pld *fw6_pld;
+	u64 cookie;
+	u32 ack_err_status = 0;
+	int error_status = 0;
+
+	fw6_pld = (struct cpl_fw6_pld *)input;
+	cookie = be64_to_cpu(fw6_pld->data[1]);
+	req = (struct crypto_async_request *)cookie;
+
+	ack_err_status =
+		ntohl(*(__be32 *)((unsigned char *)&fw6_pld->data[0] + 4));
+	if (ack_err_status) {
+		if (CHK_MAC_ERR_BIT(ack_err_status) ||
+		    CHK_PAD_ERR_BIT(ack_err_status))
+			error_status = -EINVAL;
+	}
+	/* call completion callback with failure status */
+	if (req) {
+		if (!chcr_handle_resp(req, input, error_status))
+			req->complete(req, error_status);
+		else
+			return -EINVAL;
+	} else {
+		pr_err("Incorrect request address from the firmware\n");
+		return -EFAULT;
+	}
+	return 0;
+}
+
+int chcr_send_wr(struct sk_buff *skb)
+{
+	return cxgb4_crypto_send(skb->dev, skb);
+}
+
+static void *chcr_uld_add(const struct cxgb4_lld_info *lld)
+{
+	struct uld_ctx *u_ctx;
+	/* Create the device and add it in the device list */
+	u_ctx = kzalloc(sizeof(*u_ctx), GFP_KERNEL);
+	if (!u_ctx) {
+		u_ctx = ERR_PTR(-ENOMEM);
+		goto out;
+	}
+	if (!(lld->ulp_crypto & ULP_CRYPTO_LOOKASIDE)) {
+		u_ctx = ERR_PTR(-ENOMEM);
+		goto out;
+	}
+	u_ctx->lldi = *lld;
+	mutex_lock(&dev_mutex);
+	list_add_tail(&u_ctx->entry, &uld_ctx_list);
+	mutex_unlock(&dev_mutex);
+out:
+	return u_ctx;
+}
+
+int chcr_uld_rx_handler(void *handle, const __be64 *rsp,
+			const struct pkt_gl *pgl)
+{
+	struct uld_ctx *u_ctx = (struct uld_ctx *)handle;
+	struct chcr_dev *dev = u_ctx->dev;
+	const struct cpl_act_establish *rpl = (struct cpl_act_establish
+					       *)rsp;
+
+	if (rpl->ot.opcode != CPL_FW6_PLD) {
+		pr_err("Unsupported opcode\n");
+		return 0;
+	}
+
+	if (!pgl)
+		work_handlers[rpl->ot.opcode](dev, (unsigned char *)&rsp[1]);
+	else
+		work_handlers[rpl->ot.opcode](dev, pgl->va);
+	return 0;
+}
+
+static int chcr_uld_state_change(void *handle, enum cxgb4_state state)
+{
+	struct uld_ctx *u_ctx = handle;
+	int ret = 0;
+
+	switch (state) {
+	case CXGB4_STATE_UP:
+		if (!u_ctx->dev) {
+			ret = chcr_dev_add(u_ctx);
+			if (ret != 0)
+				return ret;
+		}
+		if (atomic_read(&dev_count) == 1)
+			ret = start_crypto();
+		break;
+
+	case CXGB4_STATE_DETACH:
+		if (u_ctx->dev) {
+			mutex_lock(&dev_mutex);
+			chcr_dev_remove(u_ctx);
+			mutex_unlock(&dev_mutex);
+		}
+		if (!atomic_read(&dev_count))
+			stop_crypto();
+		break;
+
+	case CXGB4_STATE_START_RECOVERY:
+	case CXGB4_STATE_DOWN:
+	default:
+		break;
+	}
+	return ret;
+}
+
+static int chcr_uld_control(void *handle, enum cxgb4_control control, ...)
+{
+	return 0;
+}
+
+static int __init chcr_crypto_init(void)
+{
+	if (cxgb4_register_uld(CXGB4_ULD_CRYPTO, &chcr_uld_info))
+		pr_err("ULD register fail: No chcr crypto support in cxgb4");
+
+	return 0;
+}
+
+static void __exit chcr_crypto_exit(void)
+{
+	struct uld_ctx *u_ctx, *tmp;
+
+	if (atomic_read(&dev_count))
+		stop_crypto();
+
+	/* Remove all devices from list */
+	mutex_lock(&dev_mutex);
+	list_for_each_entry_safe(u_ctx, tmp, &uld_ctx_list, entry) {
+		if (u_ctx->dev)
+			chcr_dev_remove(u_ctx);
+		kfree(u_ctx);
+	}
+	mutex_unlock(&dev_mutex);
+	cxgb4_unregister_uld(CXGB4_ULD_CRYPTO);
+}
+
+module_init(chcr_crypto_init);
+module_exit(chcr_crypto_exit);
+
+MODULE_DESCRIPTION("Crypto Co-processor for Chelsio Terminator cards.");
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Chelsio Communications");
+MODULE_VERSION(DRV_VERSION);
diff --git a/drivers/crypto/chelsio/chcr_core.h b/drivers/crypto/chelsio/chcr_core.h
new file mode 100644
index 0000000..35b7cf24
--- /dev/null
+++ b/drivers/crypto/chelsio/chcr_core.h
@@ -0,0 +1,85 @@
+/*
+ * This file is part of the Chelsio T6 Crypto driver for Linux.
+ *
+ * Copyright (c) 2003-2016 Chelsio Communications, Inc. All rights reserved.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * OpenIB.org BSD license below:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and/or other materials
+ *        provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ *
+ */
+
+#ifndef __CHCR_CORE_H__
+#define __CHCR_CORE_H__
+
+#include <crypto/algapi.h>
+#include "t4_hw.h"
+#include "cxgb4.h"
+#include "cxgb4_uld.h"
+
+#define DRV_MODULE_NAME "chcr"
+#define DRV_VERSION "1.0.0.0"
+
+#define MAX_PENDING_REQ_TO_HW 20
+#define CHCR_TEST_RESPONSE_TIMEOUT 1000
+
+#define PAD_ERROR_BIT		1
+#define CHK_PAD_ERR_BIT(x)	(((x) >> PAD_ERROR_BIT) & 1)
+
+#define MAC_ERROR_BIT		0
+#define CHK_MAC_ERR_BIT(x)	(((x) >> MAC_ERROR_BIT) & 1)
+
+struct uld_ctx;
+
+struct chcr_dev {
+	/* Request submited to h/w and waiting for response. */
+	spinlock_t lock_chcr_dev;
+	struct crypto_queue pending_queue;
+	struct uld_ctx *u_ctx;
+	unsigned char tx_channel_id;
+};
+
+struct uld_ctx {
+	struct list_head entry;
+	struct cxgb4_lld_info lldi;
+	struct chcr_dev *dev;
+};
+
+void *chcr_dequeue_request(struct crypto_queue *queue);
+int assign_chcr_device(struct chcr_dev **dev);
+int chcr_send_wr(struct sk_buff *skb);
+int start_crypto(void);
+int stop_crypto(void);
+int chcr_enqueue_request(struct crypto_queue *queue,
+			 struct crypto_async_request *req);
+void chcr_delete_request(struct crypto_queue *queue,
+			 struct crypto_async_request *req);
+int chcr_uld_rx_handler(void *handle, const __be64 *rsp,
+			const struct pkt_gl *pgl);
+int chcr_handle_resp(struct crypto_async_request *req, unsigned char *input,
+		     int err);
+#endif /* __CHCR_CORE_H__ */
diff --git a/drivers/crypto/chelsio/chcr_crypto.h b/drivers/crypto/chelsio/chcr_crypto.h
new file mode 100644
index 0000000..d673c11
--- /dev/null
+++ b/drivers/crypto/chelsio/chcr_crypto.h
@@ -0,0 +1,255 @@
+/*
+ * This file is part of the Chelsio T6 Crypto driver for Linux.
+ *
+ * Copyright (c) 2003-2016 Chelsio Communications, Inc. All rights reserved.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * OpenIB.org BSD license below:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and/or other materials
+ *        provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ *
+ */
+
+#ifndef __CHCR_CRYPTO_H__
+#define __CHCR_CRYPTO_H__
+
+#define GHASH_BLOCK_SIZE    16
+#define GHASH_DIGEST_SIZE   16
+
+#define CCM_B0_SIZE             16
+#define CCM_AAD_FIELD_SIZE      2
+#define T5_MAX_AAD_SIZE 512
+
+/* Define following if h/w is not dropping the AAD and IV data before
+ * giving the processed data
+ */
+#define CHCR_NO_DATA_DROP_IN_HW
+
+#define CHCR_CRA_PRIORITY 300
+
+#define CHCR_AES_MAX_KEY_LEN  (2 * (AES_MAX_KEY_SIZE)) /* consider xts */
+#define CHCR_MAX_CRYPTO_IV_LEN 16 /* AES IV len */
+
+#define CHCR_MAX_AUTHENC_AES_KEY_LEN 32 /* max aes key length*/
+#define CHCR_MAX_AUTHENC_SHA_KEY_LEN 128 /* max sha key length*/
+
+#define CHCR_GIVENCRYPT_OP 2
+/* CPL/SCMD parameters */
+
+#define CHCR_ENCRYPT_OP 0
+#define CHCR_DECRYPT_OP 1
+
+#define CHCR_SCMD_SEQ_NO_CTRL_32BIT     1
+#define CHCR_SCMD_SEQ_NO_CTRL_48BIT     2
+#define CHCR_SCMD_SEQ_NO_CTRL_64BIT     3
+
+#define CHCR_SCMD_PROTO_VERSION_GENERIC 4
+
+#define CHCR_SCMD_AUTH_CTRL_AUTH_CIPHER 0
+#define CHCR_SCMD_AUTH_CTRL_CIPHER_AUTH 1
+
+#define CHCR_SCMD_CIPHER_MODE_NOP               0
+#define CHCR_SCMD_CIPHER_MODE_AES_CBC           1
+#define CHCR_SCMD_CIPHER_MODE_AES_GCM           2
+#define CHCR_SCMD_CIPHER_MODE_AES_CTR           3
+#define CHCR_SCMD_CIPHER_MODE_GENERIC_AES       4
+#define CHCR_SCMD_CIPHER_MODE_IPSEC_ESP         5
+#define CHCR_SCMD_CIPHER_MODE_AES_XTS           6
+#define CHCR_SCMD_CIPHER_MODE_AES_CCM           7
+
+#define CHCR_SCMD_AUTH_MODE_NOP             0
+#define CHCR_SCMD_AUTH_MODE_SHA1            1
+#define CHCR_SCMD_AUTH_MODE_SHA224          2
+#define CHCR_SCMD_AUTH_MODE_SHA256          3
+#define CHCR_SCMD_AUTH_MODE_GHASH           4
+#define CHCR_SCMD_AUTH_MODE_SHA512_224      5
+#define CHCR_SCMD_AUTH_MODE_SHA512_256      6
+#define CHCR_SCMD_AUTH_MODE_SHA512_384      7
+#define CHCR_SCMD_AUTH_MODE_SHA512_512      8
+#define CHCR_SCMD_AUTH_MODE_CBCMAC          9
+#define CHCR_SCMD_AUTH_MODE_CMAC            10
+
+#define CHCR_SCMD_HMAC_CTRL_NOP             0
+#define CHCR_SCMD_HMAC_CTRL_NO_TRUNC        1
+#define CHCR_SCMD_HMAC_CTRL_TRUNC_RFC4366   2
+#define CHCR_SCMD_HMAC_CTRL_IPSEC_96BIT     3
+#define CHCR_SCMD_HMAC_CTRL_IPSEC_64BIT     4
+
+#define CHCR_SCMD_IVGEN_CTRL_HW             0
+#define CHCR_SCMD_IVGEN_CTRL_SW             1
+/* This are not really mac key size. They are intermediate values
+ * of sha engine and its size
+ */
+#define CHCR_KEYCTX_MAC_KEY_SIZE_128        0
+#define CHCR_KEYCTX_MAC_KEY_SIZE_160        1
+#define CHCR_KEYCTX_MAC_KEY_SIZE_192        2
+#define CHCR_KEYCTX_MAC_KEY_SIZE_256        3
+#define CHCR_KEYCTX_MAC_KEY_SIZE_512        4
+#define CHCR_KEYCTX_CIPHER_KEY_SIZE_128     0
+#define CHCR_KEYCTX_CIPHER_KEY_SIZE_192     1
+#define CHCR_KEYCTX_CIPHER_KEY_SIZE_256     2
+#define CHCR_KEYCTX_NO_KEY                  15
+
+#define CHCR_CPL_FW4_PLD_IV_OFFSET          (5 * 64) /* bytes. flt #5 and #6 */
+#define CHCR_CPL_FW4_PLD_HASH_RESULT_OFFSET (7 * 64) /* bytes. flt #7 */
+#define CHCR_CPL_FW4_PLD_DATA_SIZE          (4 * 64) /* bytes. flt #4 to #7 */
+
+#define KEY_CONTEXT_HDR_SALT_AND_PAD	    16
+#define flits_to_bytes(x)  (x * 8)
+
+#define IV_NOP                  0
+#define IV_IMMEDIATE            1
+#define IV_DSGL			2
+#define AEAD_H_SIZE             16
+
+#define CRYPTO_ALG_SUB_TYPE_MASK            0x0f000000
+#define CRYPTO_ALG_SUB_TYPE_HASH_HMAC       0x01000000
+#define CRYPTO_ALG_SUB_TYPE_AEAD_RFC4106    0x02000000
+#define CRYPTO_ALG_SUB_TYPE_AEAD_AUTHENC    0x03000000
+#define CRYPTO_ALG_SUB_TYPE_AEAD_CCM        0x04000000
+#define CRYPTO_ALG_SUB_TYPE_AEAD_RFC4309    0x05000000
+#define CRYPTO_ALG_SUB_TYPE_CTR             0x06000000
+
+#define CRYPTO_ALG_TYPE_HMAC (CRYPTO_ALG_TYPE_AHASH |\
+			      CRYPTO_ALG_SUB_TYPE_HASH_HMAC)
+
+#define MAX_SALT                4
+#define MAX_SCRATCH_PAD_SIZE    32
+#define MAX_AEAD_IV_LENGTH      20
+
+#define CHCR_HASH_MAX_BLOCK_SIZE_64  64
+#define CHCR_HASH_MAX_BLOCK_SIZE_128 128
+
+/* Aligned to 128 bit boundary */
+struct _key_ctx {
+	__be32 ctx_hdr;
+	u8 salt[MAX_SALT];
+	__be64 reserverd;
+	unsigned char key[0];
+};
+
+struct ablk_ctx {
+	u8 enc;
+	unsigned int processed_len;
+	__be32 key_ctx_hdr;
+	unsigned int enckey_len;
+	unsigned int dst_nents;
+	struct scatterlist iv_sg;
+	u8 key[CHCR_AES_MAX_KEY_LEN];
+	u8 iv[CHCR_MAX_CRYPTO_IV_LEN];
+	unsigned char ciph_mode;
+};
+
+struct aead_ctx {
+	__be32 key_ctx_hdr;
+	unsigned int enckey_len;
+	unsigned int authkey_len;
+	unsigned int dst_nents;
+	struct scatterlist iv_sg;
+	unsigned char auth_mode;
+	u8 salt[MAX_SALT];
+	u8 key[128];
+	u8 iv[CHCR_MAX_CRYPTO_IV_LEN];
+	u8 ghash_h[AEAD_H_SIZE]; /* used only in GCM(AES) algorithms */
+	u8 h_iopad[2 * CHCR_HASH_MAX_DIGEST_SIZE];
+	unsigned char *dec_rrkey;
+};
+
+struct hmac_ctx {
+	struct shash_desc *desc;
+	u8 ipad[CHCR_HASH_MAX_BLOCK_SIZE_128];
+	u8 opad[CHCR_HASH_MAX_BLOCK_SIZE_128];
+};
+
+struct __crypto_ctx {
+	struct hmac_ctx hmacctx[0];
+	struct ablk_ctx ablkctx[0];
+	struct aead_ctx aeadctx[0];
+};
+
+struct chcr_context {
+	struct chcr_dev *dev;
+	unsigned char tx_channel_id;
+	struct __crypto_ctx crypto_ctx[0];
+};
+
+struct chcr_ahash_req_ctx {
+	u32 result;
+	char bfr[CHCR_HASH_MAX_BLOCK_SIZE_128];
+	u8 bfr_len;
+	/* DMA the partial hash in it */
+	u8 partial_hash[CHCR_HASH_MAX_DIGEST_SIZE];
+	u64 data_len;  /* Data len till time */
+	void *dummy_payload_ptr;
+	/* SKB which is being sent to the hardware for processing */
+	struct sk_buff *skb;
+};
+
+struct chcr_aead_req_ctx {
+	unsigned char iv[MAX_AEAD_IV_LENGTH];
+	unsigned char scratch_pad[MAX_SCRATCH_PAD_SIZE];
+	struct sk_buff *skb;
+};
+
+struct chcr_blkcipher_req_ctx {
+	struct sk_buff *skb;
+};
+
+struct chcr_alg_template {
+	u32 type;
+	u32 is_registered;
+	union {
+		struct crypto_alg crypto;
+		struct ahash_alg hash;
+		struct aead_alg aead;
+	} alg;
+};
+
+struct chcr_req_ctx {
+	union {
+		struct ahash_request *ahash_req;
+		struct aead_request *aead_req;
+		struct ablkcipher_request *ablk_req;
+	} req;
+	union {
+		struct chcr_ahash_req_ctx *ahash_ctx;
+		struct chcr_aead_req_ctx *aead_ctx;
+		struct chcr_blkcipher_req_ctx *ablk_ctx;
+	} ctx;
+};
+
+struct sge_opaque_hdr {
+	void *dev;
+	dma_addr_t addr[MAX_SKB_FRAGS + 1];
+};
+
+typedef struct sk_buff *(*create_wr_t)(struct crypto_async_request *req,
+				       struct chcr_context *ctx,
+				       unsigned short qid,
+				       unsigned short op_type);
+
+#endif /* __CHCR_CRYPTO_H__ */
+
-- 
1.7.10.1
