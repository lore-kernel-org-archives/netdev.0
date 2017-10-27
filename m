From: Atul Gupta <atul.gupta@chelsio.com>
Subject: [PATCH net-next 2/2] chcr: Add support for Inline IPSec
Date: Fri, 27 Oct 2017 22:38:18 +0530
Message-ID: <1509124098-12234-2-git-send-email-atul.gupta@chelsio.com>
References: <1509124098-12234-1-git-send-email-atul.gupta@chelsio.com>
Cc: Harsh Jain <harsh@chelsio.com>,
        Ganesh Goudar <ganeshgr@chelsio.com>
To: netdev@vger.kernel.org, davem@davemloft.net,
        steffen.klassert@secunet.com, herbert@gondor.apana.org.au,
        linux-crypto@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:45845 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751978AbdJ0RJS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 13:09:18 -0400
In-Reply-To: <1509124098-12234-1-git-send-email-atul.gupta@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

register xfrmdev_ops callbacks, Send IPsec tunneled data
to HW for inline processing.
The driver use hardware crypto accelerator to encrypt and
generate ICV for the transmitted packet in Inline mode.

Signed-off-by: Atul Gupta <atul.gupta@chelsio.com>
Signed-off-by: Harsh Jain <harsh@chelsio.com>
Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>
---
 drivers/crypto/chelsio/Makefile      |   2 +-
 drivers/crypto/chelsio/chcr_algo.c   |  45 ++-
 drivers/crypto/chelsio/chcr_algo.h   |  17 -
 drivers/crypto/chelsio/chcr_core.c   |   8 +
 drivers/crypto/chelsio/chcr_core.h   |  39 +++
 drivers/crypto/chelsio/chcr_crypto.h |  17 +-
 drivers/crypto/chelsio/chcr_ipsec.c  | 659 +++++++++++++++++++++++++++++++++++
 7 files changed, 740 insertions(+), 47 deletions(-)
 create mode 100644 drivers/crypto/chelsio/chcr_ipsec.c

diff --git a/drivers/crypto/chelsio/Makefile b/drivers/crypto/chelsio/Makefile
index bebdf06..9056420 100644
--- a/drivers/crypto/chelsio/Makefile
+++ b/drivers/crypto/chelsio/Makefile
@@ -1,4 +1,4 @@
 ccflags-y := -Idrivers/net/ethernet/chelsio/cxgb4
 
 obj-$(CONFIG_CRYPTO_DEV_CHELSIO) += chcr.o
-chcr-objs :=  chcr_core.o chcr_algo.o
+chcr-objs :=  chcr_core.o chcr_algo.o chcr_ipsec.o
diff --git a/drivers/crypto/chelsio/chcr_algo.c b/drivers/crypto/chelsio/chcr_algo.c
index 0e81607..060f747 100644
--- a/drivers/crypto/chelsio/chcr_algo.c
+++ b/drivers/crypto/chelsio/chcr_algo.c
@@ -70,6 +70,29 @@
 #include "chcr_algo.h"
 #include "chcr_crypto.h"
 
+unsigned int sgl_ent_len[] = {0, 0, 16, 24, 40,
+			      48, 64, 72, 88,
+			      96, 112, 120, 136,
+			      144, 160, 168, 184, 192};
+
+unsigned int dsgl_ent_len[] = {0, 32, 32, 48, 48, 64, 64, 80, 80,
+			       112, 112, 128, 128, 144, 144, 160, 160,
+			       192, 192, 208, 208, 224, 224, 240, 240,
+			       272, 272, 288, 288, 304, 304, 320, 320};
+
+static u32 round_constant[11] = {
+	0x01000000, 0x02000000, 0x04000000, 0x08000000,
+	0x10000000, 0x20000000, 0x40000000, 0x80000000,
+	0x1B000000, 0x36000000, 0x6C000000
+};
+
+static int is_newsg(struct scatterlist *sgl, unsigned int *newents);
+static struct scatterlist *alloc_new_sg(struct scatterlist *sgl,
+					unsigned int nents);
+static inline void free_new_sg(struct scatterlist *sgl);
+static int chcr_handle_cipher_resp(struct ablkcipher_request *req,
+				   unsigned char *input, int err);
+
 static inline  struct chcr_aead_ctx *AEAD_CTX(struct chcr_context *ctx)
 {
 	return ctx->crypto_ctx->aeadctx;
@@ -105,18 +128,6 @@ static inline int is_ofld_imm(const struct sk_buff *skb)
 	return (skb->len <= CRYPTO_MAX_IMM_TX_PKT_LEN);
 }
 
-/*
- *	sgl_len - calculates the size of an SGL of the given capacity
- *	@n: the number of SGL entries
- *	Calculates the number of flits needed for a scatter/gather list that
- *	can hold the given number of entries.
- */
-static inline unsigned int sgl_len(unsigned int n)
-{
-	n--;
-	return (3 * n) / 2 + (n & 1) + 2;
-}
-
 static void chcr_verify_tag(struct aead_request *req, u8 *input, int *err)
 {
 	u8 temp[SHA512_DIGEST_SIZE];
@@ -432,7 +443,7 @@ static inline int map_writesg_phys_cpl(struct device *dev,
 	return 0;
 }
 
-static inline int get_aead_subtype(struct crypto_aead *aead)
+inline int get_aead_subtype(struct crypto_aead *aead)
 {
 	struct aead_alg *alg = crypto_aead_alg(aead);
 	struct chcr_alg_template *chcr_crypto_alg =
@@ -3134,10 +3145,10 @@ static int chcr_aead_decrypt(struct aead_request *req)
 	}
 }
 
-static int chcr_aead_op(struct aead_request *req,
-			  unsigned short op_type,
-			  int size,
-			  create_wr_t create_wr_fn)
+int chcr_aead_op(struct aead_request *req,
+		 unsigned short op_type,
+		 int size,
+		 create_wr_t create_wr_fn)
 {
 	struct crypto_aead *tfm = crypto_aead_reqtfm(req);
 	struct chcr_context *ctx = crypto_aead_ctx(tfm);
diff --git a/drivers/crypto/chelsio/chcr_algo.h b/drivers/crypto/chelsio/chcr_algo.h
index 583008d..a5f5b19 100644
--- a/drivers/crypto/chelsio/chcr_algo.h
+++ b/drivers/crypto/chelsio/chcr_algo.h
@@ -217,7 +217,6 @@
 					ULP_TX_SC_MORE_V((immdatalen) ? 0 : 1))
 
 #define MAX_NK 8
-#define CRYPTO_MAX_IMM_TX_PKT_LEN 256
 #define MAX_WR_SIZE			512
 #define ROUND_16(bytes)		((bytes) & 0xFFFFFFF0)
 #define MAX_DSGL_ENT			32
@@ -230,16 +229,6 @@
 #define SPACE_LEFT(len) \
 	((MAX_WR_SIZE - WR_MIN_LEN - (len)))
 
-unsigned int sgl_ent_len[] = {0, 0, 16, 24, 40,
-				48, 64, 72, 88,
-				96, 112, 120, 136,
-				144, 160, 168, 184,
-				192};
-unsigned int dsgl_ent_len[] = {0, 32, 32, 48, 48, 64, 64, 80, 80,
-				112, 112, 128, 128, 144, 144, 160, 160,
-				192, 192, 208, 208, 224, 224, 240, 240,
-				272, 272, 288, 288, 304, 304, 320, 320};
-
 struct algo_param {
 	unsigned int auth_mode;
 	unsigned int mk_size;
@@ -431,10 +420,4 @@ static inline u32 aes_ks_subword(const u32 w)
 	return *(u32 *)(&bytes[0]);
 }
 
-static u32 round_constant[11] = {
-	0x01000000, 0x02000000, 0x04000000, 0x08000000,
-	0x10000000, 0x20000000, 0x40000000, 0x80000000,
-	0x1B000000, 0x36000000, 0x6C000000
-};
-
 #endif /* __CHCR_ALGO_H__ */
diff --git a/drivers/crypto/chelsio/chcr_core.c b/drivers/crypto/chelsio/chcr_core.c
index b6dd9cb..65634e1 100644
--- a/drivers/crypto/chelsio/chcr_core.c
+++ b/drivers/crypto/chelsio/chcr_core.c
@@ -48,6 +48,7 @@
 	.add = chcr_uld_add,
 	.state_change = chcr_uld_state_change,
 	.rx_handler = chcr_uld_rx_handler,
+	.tx_handler = chcr_uld_tx_handler,
 };
 
 struct uld_ctx *assign_chcr_device(void)
@@ -164,6 +165,8 @@ static void *chcr_uld_add(const struct cxgb4_lld_info *lld)
 		goto out;
 	}
 	u_ctx->lldi = *lld;
+	if (lld->crypto & ULP_CRYPTO_IPSEC_INLINE)
+		chcr_add_xfrmops(lld);
 out:
 	return u_ctx;
 }
@@ -187,6 +190,11 @@ int chcr_uld_rx_handler(void *handle, const __be64 *rsp,
 	return 0;
 }
 
+int chcr_uld_tx_handler(struct sk_buff *skb, struct net_device *dev)
+{
+	return chcr_ipsec_xmit(skb, dev);
+}
+
 static int chcr_uld_state_change(void *handle, enum cxgb4_state state)
 {
 	struct uld_ctx *u_ctx = handle;
diff --git a/drivers/crypto/chelsio/chcr_core.h b/drivers/crypto/chelsio/chcr_core.h
index c9a19b2..d081fe0 100644
--- a/drivers/crypto/chelsio/chcr_core.h
+++ b/drivers/crypto/chelsio/chcr_core.h
@@ -39,6 +39,7 @@
 #include <crypto/algapi.h>
 #include "t4_hw.h"
 #include "cxgb4.h"
+#include "t4_msg.h"
 #include "cxgb4_uld.h"
 
 #define DRV_MODULE_NAME "chcr"
@@ -46,6 +47,7 @@
 
 #define MAX_PENDING_REQ_TO_HW 20
 #define CHCR_TEST_RESPONSE_TIMEOUT 1000
+#define CRYPTO_MAX_IMM_TX_PKT_LEN 256
 
 #define PAD_ERROR_BIT		1
 #define CHK_PAD_ERR_BIT(x)	(((x) >> PAD_ERROR_BIT) & 1)
@@ -76,6 +78,28 @@ struct chcr_wr {
 	struct _key_ctx key_ctx;
 };
 
+struct chcr_ipsec_req {
+	struct ulp_txpkt ulptx;
+	struct ulptx_idata sc_imm;
+	struct cpl_tx_sec_pdu sec_cpl;
+	struct _key_ctx key_ctx;
+};
+
+struct chcr_ipsec_wr {
+	struct fw_ulptx_wr wreq;
+	struct chcr_ipsec_req req;
+};
+
+struct ipsec_sa_entry {
+	int hmac_ctrl;
+	unsigned int enckey_len;
+	unsigned int kctx_len;
+	unsigned int authsize;
+	__be32 key_ctx_hdr;
+	char salt[MAX_SALT];
+	char key[2 * AES_MAX_KEY_SIZE];
+};
+
 struct chcr_dev {
 	spinlock_t lock_chcr_dev;
 	struct uld_ctx *u_ctx;
@@ -89,12 +113,27 @@ struct uld_ctx {
 	struct chcr_dev *dev;
 };
 
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
 struct uld_ctx * assign_chcr_device(void);
 int chcr_send_wr(struct sk_buff *skb);
 int start_crypto(void);
 int stop_crypto(void);
 int chcr_uld_rx_handler(void *handle, const __be64 *rsp,
 			const struct pkt_gl *pgl);
+int chcr_uld_tx_handler(struct sk_buff *skb, struct net_device *dev);
 int chcr_handle_resp(struct crypto_async_request *req, unsigned char *input,
 		     int err);
+int chcr_ipsec_xmit(struct sk_buff *skb, struct net_device *dev);
+void chcr_add_xfrmops(const struct cxgb4_lld_info *lld);
 #endif /* __CHCR_CORE_H__ */
diff --git a/drivers/crypto/chelsio/chcr_crypto.h b/drivers/crypto/chelsio/chcr_crypto.h
index 30af1ee..f435b75 100644
--- a/drivers/crypto/chelsio/chcr_crypto.h
+++ b/drivers/crypto/chelsio/chcr_crypto.h
@@ -284,16 +284,9 @@ struct sge_opaque_hdr {
 				       unsigned short qid,
 				       int size,
 				       unsigned short op_type);
-
-static int chcr_aead_op(struct aead_request *req_base,
-			  unsigned short op_type,
-			  int size,
-			  create_wr_t create_wr_fn);
-static inline int get_aead_subtype(struct crypto_aead *aead);
-static int is_newsg(struct scatterlist *sgl, unsigned int *newents);
-static struct scatterlist *alloc_new_sg(struct scatterlist *sgl,
-					unsigned int nents);
-static inline void free_new_sg(struct scatterlist *sgl);
-static int chcr_handle_cipher_resp(struct ablkcipher_request *req,
-				   unsigned char *input, int err);
+int chcr_aead_op(struct aead_request *req_base,
+		 unsigned short op_type,
+		 int size,
+		 create_wr_t create_wr_fn);
+inline int get_aead_subtype(struct crypto_aead *aead);
 #endif /* __CHCR_CRYPTO_H__ */
diff --git a/drivers/crypto/chelsio/chcr_ipsec.c b/drivers/crypto/chelsio/chcr_ipsec.c
new file mode 100644
index 0000000..4b5df88
--- /dev/null
+++ b/drivers/crypto/chelsio/chcr_ipsec.c
@@ -0,0 +1,659 @@
+/*
+ * This file is part of the Chelsio T6 Crypto driver for Linux.
+ *
+ * Copyright (c) 2003-2017 Chelsio Communications, Inc. All rights reserved.
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
+ *	Atul Gupta (atul.gupta@chelsio.com)
+ */
+
+#define pr_fmt(fmt) "chcr:" fmt
+
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/crypto.h>
+#include <linux/cryptohash.h>
+#include <linux/skbuff.h>
+#include <linux/rtnetlink.h>
+#include <linux/highmem.h>
+#include <linux/if_vlan.h>
+#include <linux/ip.h>
+#include <linux/netdevice.h>
+#include <net/esp.h>
+#include <net/xfrm.h>
+#include <crypto/aes.h>
+#include <crypto/algapi.h>
+#include <crypto/hash.h>
+#include <crypto/sha.h>
+#include <crypto/authenc.h>
+#include <crypto/internal/aead.h>
+#include <crypto/null.h>
+#include <crypto/internal/skcipher.h>
+#include <crypto/aead.h>
+#include <crypto/scatterwalk.h>
+#include <crypto/internal/hash.h>
+
+#include "chcr_core.h"
+#include "chcr_algo.h"
+#include "chcr_crypto.h"
+
+/*
+ * Max Tx descriptor space we allow for an Ethernet packet to be inlined
+ * into a WR.
+ */
+#define MAX_IMM_TX_PKT_LEN 256
+#define GCM_ESP_IV_SIZE     8
+
+static int chcr_xfrm_add_state(struct xfrm_state *x);
+static void chcr_xfrm_del_state(struct xfrm_state *x);
+static void chcr_xfrm_free_state(struct xfrm_state *x);
+static bool chcr_ipsec_offload_ok(struct sk_buff *skb, struct xfrm_state *x);
+
+static const struct xfrmdev_ops chcr_xfrmdev_ops = {
+	.xdo_dev_state_add      = chcr_xfrm_add_state,
+	.xdo_dev_state_delete   = chcr_xfrm_del_state,
+	.xdo_dev_state_free     = chcr_xfrm_free_state,
+	.xdo_dev_offload_ok     = chcr_ipsec_offload_ok,
+};
+
+/* Add offload xfrms to Chelsio Interface */
+void chcr_add_xfrmops(const struct cxgb4_lld_info *lld)
+{
+	struct net_device *netdev = NULL;
+	int i;
+
+	for (i = 0; i < lld->nports; i++) {
+		netdev = lld->ports[i];
+		if (!netdev)
+			continue;
+		netdev->xfrmdev_ops = &chcr_xfrmdev_ops;
+		netdev->hw_enc_features |= NETIF_F_HW_ESP;
+		netdev->features |= NETIF_F_HW_ESP;
+		rtnl_lock();
+		netdev_change_features(netdev);
+		rtnl_unlock();
+	}
+}
+
+static inline int chcr_ipsec_setauthsize(struct xfrm_state *x,
+					 struct ipsec_sa_entry *sa_entry)
+{
+	int hmac_ctrl;
+	int authsize = x->aead->alg_icv_len / 8;
+
+	sa_entry->authsize = authsize;
+
+	switch (authsize) {
+	case ICV_8:
+		hmac_ctrl = CHCR_SCMD_HMAC_CTRL_DIV2;
+		break;
+	case ICV_12:
+		hmac_ctrl = CHCR_SCMD_HMAC_CTRL_IPSEC_96BIT;
+		break;
+	case ICV_16:
+		hmac_ctrl = CHCR_SCMD_HMAC_CTRL_NO_TRUNC;
+		break;
+	default:
+		return -EINVAL;
+	}
+	return hmac_ctrl;
+}
+
+static inline int chcr_ipsec_setkey(struct xfrm_state *x,
+				    struct ipsec_sa_entry *sa_entry)
+{
+	struct crypto_cipher *cipher;
+	int keylen = (x->aead->alg_key_len + 7) / 8;
+	unsigned char *key = x->aead->alg_key;
+	int ck_size, key_ctx_size = 0;
+	unsigned char ghash_h[AEAD_H_SIZE];
+	int ret = 0;
+
+	if (keylen > 3) {
+		keylen -= 4;  /* nonce/salt is present in the last 4 bytes */
+		memcpy(sa_entry->salt, key + keylen, 4);
+	}
+
+	if (keylen == AES_KEYSIZE_128) {
+		ck_size = CHCR_KEYCTX_CIPHER_KEY_SIZE_128;
+	} else if (keylen == AES_KEYSIZE_192) {
+		ck_size = CHCR_KEYCTX_CIPHER_KEY_SIZE_192;
+	} else if (keylen == AES_KEYSIZE_256) {
+		ck_size = CHCR_KEYCTX_CIPHER_KEY_SIZE_256;
+	} else {
+		pr_err("GCM: Invalid key length %d\n", keylen);
+		ret = -EINVAL;
+		goto out;
+	}
+
+	memcpy(sa_entry->key, key, keylen);
+	sa_entry->enckey_len = keylen;
+	key_ctx_size = sizeof(struct _key_ctx) +
+			      ((DIV_ROUND_UP(keylen, 16)) << 4) +
+			      AEAD_H_SIZE;
+
+	sa_entry->key_ctx_hdr = FILL_KEY_CTX_HDR(ck_size,
+						 CHCR_KEYCTX_MAC_KEY_SIZE_128,
+						 0, 0,
+						 key_ctx_size >> 4);
+
+	/* Calculate the H = CIPH(K, 0 repeated 16 times).
+	 * It will go in key context
+	 */
+	cipher = crypto_alloc_cipher("aes-generic", 0, 0);
+	if (IS_ERR(cipher)) {
+		sa_entry->enckey_len = 0;
+		ret = -ENOMEM;
+		goto out;
+	}
+
+	ret = crypto_cipher_setkey(cipher, key, keylen);
+	if (ret) {
+		sa_entry->enckey_len = 0;
+		goto out1;
+	}
+	memset(ghash_h, 0, AEAD_H_SIZE);
+	crypto_cipher_encrypt_one(cipher, ghash_h, ghash_h);
+	memcpy(sa_entry->key + (DIV_ROUND_UP(sa_entry->enckey_len, 16) *
+	       16), ghash_h, AEAD_H_SIZE);
+	sa_entry->kctx_len = ((DIV_ROUND_UP(sa_entry->enckey_len, 16)) << 4) +
+			      AEAD_H_SIZE;
+out1:
+	crypto_free_cipher(cipher);
+out:
+	return ret;
+}
+
+/*
+ * chcr_xfrm_add_state
+ * returns 0 on success, negative error if failed to send message to FPGA
+ * positive error if FPGA returned a bad response
+ */
+static int chcr_xfrm_add_state(struct xfrm_state *x)
+{
+	struct net_device *netdev = x->xso.dev;
+	struct port_info *pi  = netdev_priv(netdev);
+	struct ipsec_sa_entry *sa_entry;
+	struct adapter *adap;
+	int res = 0;
+
+	adap = pi->adapter;
+
+	if (x->props.aalgo != SADB_AALG_NONE) {
+		pr_debug("CHCR: Cannot offload authenticated xfrm states\n");
+		return -EINVAL;
+	}
+	if (x->props.calgo != SADB_X_CALG_NONE) {
+		pr_debug("CHCR: Cannot offload compressed xfrm states\n");
+		return -EINVAL;
+	}
+	if (x->props.flags & XFRM_STATE_ESN) {
+		pr_debug("CHCR: Cannot offload ESN xfrm states\n");
+		return -EINVAL;
+	}
+	if (x->props.family != AF_INET &&
+	    x->props.family != AF_INET6) {
+		pr_debug("CHCR: Only IPv4/6 xfrm state offloaded\n");
+		return -EINVAL;
+	}
+	if (x->props.mode != XFRM_MODE_TRANSPORT &&
+	    x->props.mode != XFRM_MODE_TUNNEL) {
+		pr_debug("CHCR: Only transport and tunnel xfrm offload\n");
+		return -EINVAL;
+	}
+	if (x->id.proto != IPPROTO_ESP) {
+		pr_debug("CHCR: Only ESP xfrm state offloaded\n");
+		return -EINVAL;
+	}
+	if (x->encap) {
+		pr_debug("CHCR: Encapsulated xfrm state not offloaded\n");
+		return -EINVAL;
+	}
+	if (!x->aead) {
+		pr_debug("CHCR: Cannot offload xfrm states without aead\n");
+		return -EINVAL;
+	}
+	if (x->aead->alg_icv_len != 128 &&
+	    x->aead->alg_icv_len != 96) {
+		pr_debug("CHCR: Cannot offload xfrm states with AEAD ICV length other than 96b & 128b\n");
+	return -EINVAL;
+	}
+	if ((x->aead->alg_key_len != 128 + 32) &&
+	    (x->aead->alg_key_len != 256 + 32)) {
+		pr_debug("CHCR: Cannot offload xfrm states with AEAD key length other than 128/256 bit\n");
+		return -EINVAL;
+	}
+	if (x->tfcpad) {
+		pr_debug("CHCR: Cannot offload xfrm states with tfc padding\n");
+		return -EINVAL;
+	}
+	if (!x->geniv) {
+		pr_debug("CHCR: Cannot offload xfrm states without geniv\n");
+		return -EINVAL;
+	}
+	if (strcmp(x->geniv, "seqiv")) {
+		pr_debug("CHCR: Cannot offload xfrm states with geniv other than seqiv\n");
+		return -EINVAL;
+	}
+
+	sa_entry = kzalloc(sizeof(*sa_entry), GFP_KERNEL);
+	if (!sa_entry) {
+		res = -ENOMEM;
+		goto out;
+	}
+
+	sa_entry->hmac_ctrl = chcr_ipsec_setauthsize(x, sa_entry);
+	chcr_ipsec_setkey(x, sa_entry);
+	x->xso.offload_handle = (unsigned long)sa_entry;
+	try_module_get(THIS_MODULE);
+out:
+	return res;
+}
+
+static void chcr_xfrm_del_state(struct xfrm_state *x)
+{
+	/* do nothing */
+	if (!x->xso.offload_handle)
+		return;
+}
+
+static void chcr_xfrm_free_state(struct xfrm_state *x)
+{
+	struct ipsec_sa_entry *sa_entry;
+
+	if (!x->xso.offload_handle)
+		return;
+
+	sa_entry = (struct ipsec_sa_entry *)x->xso.offload_handle;
+	kfree(sa_entry);
+	module_put(THIS_MODULE);
+}
+
+static bool chcr_ipsec_offload_ok(struct sk_buff *skb, struct xfrm_state *x)
+{
+	/* Offload with IP options is not supported yet */
+	if (ip_hdr(skb)->ihl > 5)
+		return false;
+
+	return true;
+}
+
+static inline int is_eth_imm(const struct sk_buff *skb, unsigned int kctx_len)
+{
+	int hdrlen = sizeof(struct chcr_ipsec_req) + kctx_len;
+
+	hdrlen += sizeof(struct cpl_tx_pkt);
+	if (skb->len <= MAX_IMM_TX_PKT_LEN - hdrlen)
+		return hdrlen;
+	return 0;
+}
+
+static inline unsigned int calc_tx_sec_flits(const struct sk_buff *skb,
+					     unsigned int kctx_len)
+{
+	unsigned int flits;
+	int hdrlen = is_eth_imm(skb, kctx_len);
+
+	/* If the skb is small enough, we can pump it out as a work request
+	 * with only immediate data.  In that case we just have to have the
+	 * TX Packet header plus the skb data in the Work Request.
+	 */
+
+	if (hdrlen)
+		return DIV_ROUND_UP(skb->len + hdrlen, sizeof(__be64));
+
+	flits = sgl_len(skb_shinfo(skb)->nr_frags + 1);
+
+	/* Otherwise, we're going to have to construct a Scatter gather list
+	 * of the skb body and fragments.  We also include the flits necessary
+	 * for the TX Packet Work Request and CPL.  We always have a firmware
+	 * Write Header (incorporated as part of the cpl_tx_pkt_lso and
+	 * cpl_tx_pkt structures), followed by either a TX Packet Write CPL
+	 * message or, if we're doing a Large Send Offload, an LSO CPL message
+	 * with an embedded TX Packet Write CPL message.
+	 */
+	flits += (sizeof(struct fw_ulptx_wr) +
+		  sizeof(struct chcr_ipsec_req) +
+		  kctx_len +
+		  sizeof(struct cpl_tx_pkt_core)) / sizeof(__be64);
+	return flits;
+}
+
+inline void *copy_cpltx_pktxt(struct sk_buff *skb,
+				struct net_device *dev,
+				void *pos)
+{
+	struct adapter *adap;
+	struct port_info *pi;
+	struct sge_eth_txq *q;
+	struct cpl_tx_pkt_core *cpl;
+	u64 cntrl;
+	u32 ctrl0, qidx;
+
+	pi = netdev_priv(dev);
+	adap = pi->adapter;
+	qidx = skb->queue_mapping;
+	q = &adap->sge.ethtxq[qidx + pi->first_qset];
+
+	cpl = (struct cpl_tx_pkt_core *)pos;
+
+	if (skb->ip_summed == CHECKSUM_PARTIAL)
+		cntrl = TXPKT_L4CSUM_DIS_F | TXPKT_IPCSUM_DIS_F;
+	ctrl0 = TXPKT_OPCODE_V(CPL_TX_PKT_XT) | TXPKT_INTF_V(pi->tx_chan) |
+			       TXPKT_PF_V(adap->pf);
+	if (skb_vlan_tag_present(skb)) {
+		q->vlan_ins++;
+		cntrl |= TXPKT_VLAN_VLD_F | TXPKT_VLAN_V(skb_vlan_tag_get(skb));
+	}
+
+	cpl->ctrl0 = htonl(ctrl0);
+	cpl->pack = htons(0);
+	cpl->len = htons(skb->len);
+	cpl->ctrl1 = cpu_to_be64(cntrl);
+
+	pos += sizeof(struct cpl_tx_pkt_core);
+	return pos;
+}
+
+inline void *copy_key_cpltx_pktxt(struct sk_buff *skb,
+				struct net_device *dev,
+				void *pos,
+				struct ipsec_sa_entry *sa_entry)
+{
+	struct adapter *adap;
+	struct port_info *pi;
+	struct sge_eth_txq *q;
+	unsigned int len, qidx;
+	struct _key_ctx *key_ctx;
+	int left, eoq, key_len;
+
+	pi = netdev_priv(dev);
+	adap = pi->adapter;
+	qidx = skb->queue_mapping;
+	q = &adap->sge.ethtxq[qidx + pi->first_qset];
+	len = sa_entry->enckey_len + sizeof(struct cpl_tx_pkt_core);
+	key_len = sa_entry->kctx_len;
+
+	/* end of queue, reset pos to start of queue */
+	eoq = (void *)q->q.stat - pos;
+	left = eoq;
+	if (!eoq) {
+		pos = q->q.desc;
+		left = 64 * q->q.size;
+	}
+
+	/* Copy the Key context header */
+	key_ctx = (struct _key_ctx *)pos;
+	key_ctx->ctx_hdr = sa_entry->key_ctx_hdr;
+	memcpy(key_ctx->salt, sa_entry->salt, MAX_SALT);
+	pos += sizeof(struct _key_ctx);
+	left -= sizeof(struct _key_ctx);
+
+	if (likely(len <= left)) {
+		memcpy(key_ctx->key, sa_entry->key, key_len);
+		pos += key_len;
+	} else {
+		if (key_len <= left) {
+			memcpy(pos, sa_entry->key, key_len);
+			pos += key_len;
+		} else {
+			memcpy(pos, sa_entry->key, left);
+			memcpy(q->q.desc, sa_entry->key + left,
+			       key_len - left);
+			pos = q->q.desc + (key_len - left);
+		}
+	}
+	/* Copy CPL TX PKT XT */
+	pos = copy_cpltx_pktxt(skb, dev, pos);
+
+	return pos;
+}
+
+inline void *chcr_crypto_wreq(struct sk_buff *skb,
+			       struct net_device *dev,
+			       void *pos,
+			       int credits,
+			       struct ipsec_sa_entry *sa_entry)
+{
+	struct port_info *pi = netdev_priv(dev);
+	struct adapter *adap = pi->adapter;
+	unsigned int immdatalen = 0;
+	unsigned int ivsize = GCM_ESP_IV_SIZE;
+	struct chcr_ipsec_wr *wr;
+	unsigned int flits;
+	u32 wr_mid;
+	int qidx = skb_get_queue_mapping(skb);
+	struct sge_eth_txq *q = &adap->sge.ethtxq[qidx + pi->first_qset];
+	unsigned int kctx_len = sa_entry->kctx_len;
+	int qid = q->q.cntxt_id;
+
+	atomic_inc(&adap->chcr_stats.ipsec_cnt);
+
+	flits = calc_tx_sec_flits(skb, kctx_len);
+
+	if (is_eth_imm(skb, kctx_len))
+		immdatalen = skb->len;
+
+	/* WR Header */
+	wr = (struct chcr_ipsec_wr *)pos;
+	wr->wreq.op_to_compl = htonl(FW_WR_OP_V(FW_ULPTX_WR));
+	wr_mid = FW_CRYPTO_LOOKASIDE_WR_LEN16_V(DIV_ROUND_UP(flits, 2));
+
+	if (unlikely(credits < ETHTXQ_STOP_THRES)) {
+		netif_tx_stop_queue(q->txq);
+		q->q.stops++;
+		wr_mid |= FW_WR_EQUEQ_F | FW_WR_EQUIQ_F;
+	}
+	wr->wreq.flowid_len16 = htonl(wr_mid);
+
+	/* ULPTX */
+	wr->req.ulptx.cmd_dest = FILL_ULPTX_CMD_DEST(pi->port_id, qid);
+	wr->req.ulptx.len = htonl(DIV_ROUND_UP(flits, 2)  - 1);
+
+	/* Sub-command */
+	wr->req.sc_imm.cmd_more = FILL_CMD_MORE(immdatalen);
+	wr->req.sc_imm.len = cpu_to_be32(sizeof(struct cpl_tx_sec_pdu) +
+					 sizeof(wr->req.key_ctx) +
+					 kctx_len +
+					 sizeof(struct cpl_tx_pkt_core) +
+					 immdatalen);
+
+	/* CPL_SEC_PDU */
+	wr->req.sec_cpl.op_ivinsrtofst = htonl(
+				CPL_TX_SEC_PDU_OPCODE_V(CPL_TX_SEC_PDU) |
+				CPL_TX_SEC_PDU_CPLLEN_V(2) |
+				CPL_TX_SEC_PDU_PLACEHOLDER_V(1) |
+				CPL_TX_SEC_PDU_IVINSRTOFST_V(
+				(skb_transport_offset(skb) +
+				sizeof(struct ip_esp_hdr) + 1)));
+
+	wr->req.sec_cpl.pldlen = htonl(skb->len);
+
+	wr->req.sec_cpl.aadstart_cipherstop_hi = FILL_SEC_CPL_CIPHERSTOP_HI(
+				(skb_transport_offset(skb) + 1),
+				(skb_transport_offset(skb) +
+				 sizeof(struct ip_esp_hdr)),
+				(skb_transport_offset(skb) +
+				 sizeof(struct ip_esp_hdr) +
+				 GCM_ESP_IV_SIZE + 1), 0);
+
+	wr->req.sec_cpl.cipherstop_lo_authinsert =
+		FILL_SEC_CPL_AUTHINSERT(0, skb_transport_offset(skb) +
+					   sizeof(struct ip_esp_hdr) +
+					   GCM_ESP_IV_SIZE + 1,
+					   sa_entry->authsize,
+					   sa_entry->authsize);
+	wr->req.sec_cpl.seqno_numivs =
+		FILL_SEC_CPL_SCMD0_SEQNO(CHCR_ENCRYPT_OP, 1,
+					 CHCR_SCMD_CIPHER_MODE_AES_GCM,
+					 CHCR_SCMD_AUTH_MODE_GHASH,
+					 sa_entry->hmac_ctrl,
+					 ivsize >> 1);
+	wr->req.sec_cpl.ivgen_hdrlen =  FILL_SEC_CPL_IVGEN_HDRLEN(0, 0, 1,
+								  0, 0, 0);
+
+	pos += sizeof(struct fw_ulptx_wr) +
+	       sizeof(struct ulp_txpkt) +
+	       sizeof(struct ulptx_idata) +
+	       sizeof(struct cpl_tx_sec_pdu);
+
+	pos = copy_key_cpltx_pktxt(skb, dev, pos, sa_entry);
+
+	return pos;
+}
+
+/**
+ *      flits_to_desc - returns the num of Tx descriptors for the given flits
+ *      @n: the number of flits
+ *
+ *      Returns the number of Tx descriptors needed for the supplied number
+ *      of flits.
+ */
+static inline unsigned int flits_to_desc(unsigned int n)
+{
+	WARN_ON(n > SGE_MAX_WR_LEN / 8);
+	return DIV_ROUND_UP(n, 8);
+}
+
+static inline unsigned int txq_avail(const struct sge_txq *q)
+{
+	return q->size - 1 - q->in_use;
+}
+
+static void eth_txq_stop(struct sge_eth_txq *q)
+{
+	netif_tx_stop_queue(q->txq);
+	q->q.stops++;
+}
+
+static inline void txq_advance(struct sge_txq *q, unsigned int n)
+{
+	q->in_use += n;
+	q->pidx += n;
+	if (q->pidx >= q->size)
+		q->pidx -= q->size;
+}
+
+/*
+ *      chcr_ipsec_xmit called from ULD Tx handler
+ */
+int chcr_ipsec_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct xfrm_state *x = xfrm_input_state(skb);
+	struct ipsec_sa_entry *sa_entry;
+	u64 *pos, *end, *before, cntrl, *sgl;
+	int qidx, left, credits;
+	unsigned int flits = 0, ndesc, kctx_len;
+	struct adapter *adap;
+	struct sge_eth_txq *q;
+	struct port_info *pi;
+	dma_addr_t addr[MAX_SKB_FRAGS + 1];
+	bool immediate = false;
+
+	if (!x->xso.offload_handle)
+		return NETDEV_TX_BUSY;
+
+	sa_entry = (struct ipsec_sa_entry *)x->xso.offload_handle;
+	kctx_len = sa_entry->kctx_len;
+
+	if (skb->sp->len != 1) {
+out_free:       dev_kfree_skb_any(skb);
+		return NETDEV_TX_OK;
+	}
+
+	pi = netdev_priv(dev);
+	adap = pi->adapter;
+	qidx = skb->queue_mapping;
+	q = &adap->sge.ethtxq[qidx + pi->first_qset];
+
+	cxgb4_reclaim_completed_tx(adap, &q->q, true);
+	cntrl = TXPKT_L4CSUM_DIS_F | TXPKT_IPCSUM_DIS_F;
+
+	flits = calc_tx_sec_flits(skb, sa_entry->kctx_len);
+	ndesc = flits_to_desc(flits);
+	credits = txq_avail(&q->q) - ndesc;
+
+	if (unlikely(credits < 0)) {
+		eth_txq_stop(q);
+		dev_err(adap->pdev_dev,
+			"%s: Tx ring %u full while queue awake! cred:%d %d %d flits:%d\n",
+			dev->name, qidx, credits, ndesc, txq_avail(&q->q),
+			flits);
+		return NETDEV_TX_BUSY;
+	}
+
+	if (is_eth_imm(skb, kctx_len))
+		immediate = true;
+
+	if (!immediate &&
+	    unlikely(cxgb4_map_skb(adap->pdev_dev, skb, addr) < 0)) {
+		q->mapping_err++;
+		goto out_free;
+	}
+
+	pos = (u64 *)&q->q.desc[q->q.pidx];
+	before = (u64 *)pos;
+	end = (u64 *)pos + flits;
+	/* Setup IPSec CPL */
+	pos = (void *)chcr_crypto_wreq(skb, dev, (void *)pos,
+				       credits, sa_entry);
+	if (before > (u64 *)pos) {
+		left = (u8 *)end - (u8 *)q->q.stat;
+		end = (void *)q->q.desc + left;
+	}
+	if (pos == (u64 *)q->q.stat) {
+		left = (u8 *)end - (u8 *)q->q.stat;
+		end = (void *)q->q.desc + left;
+		pos = (void *)q->q.desc;
+	}
+
+	sgl = (void *)pos;
+	if (immediate) {
+		cxgb4_inline_tx_skb(skb, &q->q, sgl);
+		dev_consume_skb_any(skb);
+	} else {
+		int last_desc;
+
+		cxgb4_write_sgl(skb, &q->q, (void *)sgl, end,
+				0, addr);
+		skb_orphan(skb);
+
+		last_desc = q->q.pidx + ndesc - 1;
+		if (last_desc >= q->q.size)
+			last_desc -= q->q.size;
+		q->q.sdesc[last_desc].skb = skb;
+		q->q.sdesc[last_desc].sgl = (struct ulptx_sgl *)sgl;
+	}
+	txq_advance(&q->q, ndesc);
+
+	cxgb4_ring_tx_db(adap, &q->q, ndesc);
+	return NETDEV_TX_OK;
+}
-- 
1.8.3.1
