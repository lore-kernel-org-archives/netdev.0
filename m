From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [RFC 11/12] nfp: bpf: move to new BPF program offload infrastructure
Date: Tue, 31 Oct 2017 18:52:16 -0700
Message-ID: <20171101015217.10666-12-jakub.kicinski@netronome.com>
References: <20171101015217.10666-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, alexei.starovoitov@gmail.com,
        daniel@iogearbox.net, bblanco@gmail.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:45293 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932940AbdKABxK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 21:53:10 -0400
Received: by mail-pg0-f66.google.com with SMTP id b192so805288pga.2
        for <netdev@vger.kernel.org>; Tue, 31 Oct 2017 18:53:09 -0700 (PDT)
In-Reply-To: <20171101015217.10666-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Following steps are taken in the driver to offload an XDP program:

XDP_SETUP_PROG:
 * prepare:
   - allocate program state;
   - run verifier (bpf_analyzer());
   - run translation;
 * load:
   - stop old program if needed;
   - load program;
   - enable BPF if not enabled;
 * clean up:
   - free program image.

With new infrastructure the flow will look like this:

BPF_OFFLOAD_VERIFIER_PREP:
  - allocate program state;
BPF_OFFLOAD_TRANSLATE:
   - run translation;
XDP_SETUP_PROG:
   - stop old program if needed;
   - load program;
   - enable BPF if not enabled;
BPF_OFFLOAD_DESTROY:
   - free program image.

Take advantage of the new infrastructure.  Allocation of driver
metadata has to be moved from jit.c to offload.c since it's now
done at a different stage.  Since there is no separate driver
private data for verification step, move temporary nfp_meta
pointer into nfp_prog.  We will now use user space context
offsets.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Quentin Monnet <quentin.monnet@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/bpf/jit.c       | 105 ++-----------
 drivers/net/ethernet/netronome/nfp/bpf/main.c      |   4 +
 drivers/net/ethernet/netronome/nfp/bpf/main.h      |  26 +--
 drivers/net/ethernet/netronome/nfp/bpf/offload.c   | 175 ++++++++++++++-------
 drivers/net/ethernet/netronome/nfp/bpf/verifier.c  |  43 +----
 drivers/net/ethernet/netronome/nfp/nfp_app.h       |  37 +++++
 .../net/ethernet/netronome/nfp/nfp_net_common.c    |   8 +
 7 files changed, 208 insertions(+), 190 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/bpf/jit.c b/drivers/net/ethernet/netronome/nfp/bpf/jit.c
index 64e21d05e8a1..361673d99eb3 100644
--- a/drivers/net/ethernet/netronome/nfp/bpf/jit.c
+++ b/drivers/net/ethernet/netronome/nfp/bpf/jit.c
@@ -77,17 +77,6 @@ nfp_meta_has_prev(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
 	return meta->l.prev != &nfp_prog->insns;
 }
 
-static void nfp_prog_free(struct nfp_prog *nfp_prog)
-{
-	struct nfp_insn_meta *meta, *tmp;
-
-	list_for_each_entry_safe(meta, tmp, &nfp_prog->insns, l) {
-		list_del(&meta->l);
-		kfree(meta);
-	}
-	kfree(nfp_prog);
-}
-
 static void nfp_prog_push(struct nfp_prog *nfp_prog, u64 insn)
 {
 	if (nfp_prog->__prog_alloc_len == nfp_prog->prog_len) {
@@ -1416,19 +1405,18 @@ static int mem_ldx_skb(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta,
 	swreg dst = reg_both(meta->insn.dst_reg * 2);
 
 	switch (meta->insn.off) {
-	case offsetof(struct sk_buff, len):
-		if (size != FIELD_SIZEOF(struct sk_buff, len))
+	case offsetof(struct __sk_buff, len):
+		if (size != FIELD_SIZEOF(struct __sk_buff, len))
 			return -EOPNOTSUPP;
 		wrp_mov(nfp_prog, dst, plen_reg(nfp_prog));
 		break;
-	case offsetof(struct sk_buff, data):
-		if (size != sizeof(void *))
+	case offsetof(struct __sk_buff, data):
+		if (size != FIELD_SIZEOF(struct __sk_buff, data))
 			return -EOPNOTSUPP;
 		wrp_mov(nfp_prog, dst, pptr_reg(nfp_prog));
 		break;
-	case offsetof(struct sk_buff, cb) +
-	     offsetof(struct bpf_skb_data_end, data_end):
-		if (size != sizeof(void *))
+	case offsetof(struct __sk_buff, data_end):
+		if (size != FIELD_SIZEOF(struct __sk_buff, data_end))
 			return -EOPNOTSUPP;
 		emit_alu(nfp_prog, dst,
 			 plen_reg(nfp_prog), ALU_OP_ADD, pptr_reg(nfp_prog));
@@ -1447,14 +1435,15 @@ static int mem_ldx_xdp(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta,
 {
 	swreg dst = reg_both(meta->insn.dst_reg * 2);
 
-	if (size != sizeof(void *))
-		return -EINVAL;
-
 	switch (meta->insn.off) {
-	case offsetof(struct xdp_buff, data):
+	case offsetof(struct xdp_md, data):
+		if (size != FIELD_SIZEOF(struct xdp_md, data))
+			return -EOPNOTSUPP;
 		wrp_mov(nfp_prog, dst, pptr_reg(nfp_prog));
 		break;
-	case offsetof(struct xdp_buff, data_end):
+	case offsetof(struct xdp_md, data_end):
+		if (size != FIELD_SIZEOF(struct xdp_md, data_end))
+			return -EOPNOTSUPP;
 		emit_alu(nfp_prog, dst,
 			 plen_reg(nfp_prog), ALU_OP_ADD, pptr_reg(nfp_prog));
 		break;
@@ -2103,28 +2092,6 @@ static int nfp_translate(struct nfp_prog *nfp_prog)
 	return nfp_fixup_branches(nfp_prog);
 }
 
-static int
-nfp_prog_prepare(struct nfp_prog *nfp_prog, const struct bpf_insn *prog,
-		 unsigned int cnt)
-{
-	unsigned int i;
-
-	for (i = 0; i < cnt; i++) {
-		struct nfp_insn_meta *meta;
-
-		meta = kzalloc(sizeof(*meta), GFP_KERNEL);
-		if (!meta)
-			return -ENOMEM;
-
-		meta->insn = prog[i];
-		meta->n = i;
-
-		list_add_tail(&meta->l, &nfp_prog->insns);
-	}
-
-	return 0;
-}
-
 /* --- Optimizations --- */
 static void nfp_bpf_opt_reg_init(struct nfp_prog *nfp_prog)
 {
@@ -2252,60 +2219,20 @@ static int nfp_bpf_ustore_calc(struct nfp_prog *nfp_prog, __le64 *ustore)
 	return 0;
 }
 
-/**
- * nfp_bpf_jit() - translate BPF code into NFP assembly
- * @filter:	kernel BPF filter struct
- * @prog_mem:	memory to store assembler instructions
- * @prog_start:	offset of the first instruction when loaded
- * @prog_done:	where to jump on exit
- * @prog_sz:	size of @prog_mem in instructions
- * @res:	achieved parameters of translation results
- */
-int
-nfp_bpf_jit(struct bpf_prog *filter, void *prog_mem,
-	    unsigned int prog_start, unsigned int prog_done,
-	    unsigned int prog_sz, struct nfp_bpf_result *res)
+int nfp_bpf_jit(struct nfp_prog *nfp_prog)
 {
-	struct nfp_prog *nfp_prog;
 	int ret;
 
-	nfp_prog = kzalloc(sizeof(*nfp_prog), GFP_KERNEL);
-	if (!nfp_prog)
-		return -ENOMEM;
-
-	INIT_LIST_HEAD(&nfp_prog->insns);
-	nfp_prog->type = filter->type;
-	nfp_prog->start_off = prog_start;
-	nfp_prog->tgt_done = prog_done;
-
-	ret = nfp_prog_prepare(nfp_prog, filter->insnsi, filter->len);
-	if (ret)
-		goto out;
-
-	ret = nfp_prog_verify(nfp_prog, filter);
-	if (ret)
-		goto out;
-
 	ret = nfp_bpf_optimize(nfp_prog);
 	if (ret)
-		goto out;
-
-	nfp_prog->prog = prog_mem;
-	nfp_prog->__prog_alloc_len = prog_sz;
+		return ret;
 
 	ret = nfp_translate(nfp_prog);
 	if (ret) {
 		pr_err("Translation failed with error %d (translated: %u)\n",
 		       ret, nfp_prog->n_translated);
-		ret = -EINVAL;
-		goto out;
+		return -EINVAL;
 	}
 
-	ret = nfp_bpf_ustore_calc(nfp_prog, (__force __le64 *)prog_mem);
-
-	res->n_instr = nfp_prog->prog_len;
-out:
-	nfp_prog_free(nfp_prog);
-
-	return ret;
+	return nfp_bpf_ustore_calc(nfp_prog, (__force __le64 *)nfp_prog->prog);
 }
diff --git a/drivers/net/ethernet/netronome/nfp/bpf/main.c b/drivers/net/ethernet/netronome/nfp/bpf/main.c
index 789cdde229d2..d7670fee725f 100644
--- a/drivers/net/ethernet/netronome/nfp/bpf/main.c
+++ b/drivers/net/ethernet/netronome/nfp/bpf/main.c
@@ -170,4 +170,8 @@ const struct nfp_app_type app_bpf = {
 	.setup_tc	= nfp_bpf_setup_tc,
 	.tc_busy	= nfp_bpf_tc_busy,
 	.xdp_offload	= nfp_bpf_xdp_offload,
+
+	.bpf_verifier_prep	= nfp_bpf_verifier_prep,
+	.bpf_translate		= nfp_bpf_translate,
+	.bpf_destroy		= nfp_bpf_destroy,
 };
diff --git a/drivers/net/ethernet/netronome/nfp/bpf/main.h b/drivers/net/ethernet/netronome/nfp/bpf/main.h
index a92391364450..bcbbbac56b28 100644
--- a/drivers/net/ethernet/netronome/nfp/bpf/main.h
+++ b/drivers/net/ethernet/netronome/nfp/bpf/main.h
@@ -41,7 +41,6 @@
 #include <linux/types.h>
 
 #include "../nfp_asm.h"
-#include "../nfp_net.h"
 
 /* For branch fixup logic use up-most byte of branch instruction as scratch
  * area.  Remember to clear this before sending instructions to HW!
@@ -79,6 +78,8 @@ enum pkt_vec {
 #define NFP_BPF_ABI_FLAGS	reg_imm(0)
 #define   NFP_BPF_ABI_FLAG_MARK	1
 
+struct nfp_app;
+struct nfp_net;
 struct nfp_prog;
 struct nfp_insn_meta;
 typedef int (*instr_cb_t)(struct nfp_prog *, struct nfp_insn_meta *);
@@ -140,6 +141,7 @@ static inline u8 mbpf_mode(const struct nfp_insn_meta *meta)
  * @prog: machine code
  * @prog_len: number of valid instructions in @prog array
  * @__prog_alloc_len: alloc size of @prog array
+ * @verifier_meta: temporary storage for verifier's insn meta
  * @type: BPF program type
  * @start_off: address of the first instruction in the memory
  * @tgt_out: jump target for normal exit
@@ -155,6 +157,8 @@ struct nfp_prog {
 	unsigned int prog_len;
 	unsigned int __prog_alloc_len;
 
+	struct nfp_insn_meta *verifier_meta;
+
 	enum bpf_prog_type type;
 
 	unsigned int start_off;
@@ -170,20 +174,18 @@ struct nfp_prog {
 	struct list_head insns;
 };
 
-struct nfp_bpf_result {
-	unsigned int n_instr;
-};
-
-int
-nfp_bpf_jit(struct bpf_prog *filter, void *prog,
-	    unsigned int prog_start, unsigned int prog_done,
-	    unsigned int prog_sz, struct nfp_bpf_result *res);
+int nfp_bpf_jit(struct nfp_prog *prog);
 
-int nfp_prog_verify(struct nfp_prog *nfp_prog, struct bpf_prog *prog);
-
-struct nfp_net;
+extern const struct bpf_ext_analyzer_ops nfp_bpf_analyzer_ops;
 
 int nfp_net_bpf_offload(struct nfp_net *nn, struct bpf_prog *prog,
 			bool old_prog);
 
+int nfp_bpf_verifier_prep(struct nfp_app *app, struct nfp_net *nn,
+			  struct netdev_bpf *bpf);
+int nfp_bpf_translate(struct nfp_app *app, struct nfp_net *nn,
+		      struct bpf_prog *prog);
+int nfp_bpf_destroy(struct nfp_app *app, struct nfp_net *nn,
+		    struct bpf_prog *prog);
+
 #endif
diff --git a/drivers/net/ethernet/netronome/nfp/bpf/offload.c b/drivers/net/ethernet/netronome/nfp/bpf/offload.c
index 29c96714dd76..4c3802d77a4c 100644
--- a/drivers/net/ethernet/netronome/nfp/bpf/offload.c
+++ b/drivers/net/ethernet/netronome/nfp/bpf/offload.c
@@ -51,19 +51,12 @@
 #include "../nfp_net_ctrl.h"
 #include "../nfp_net.h"
 
-static int
-nfp_net_bpf_offload_prepare(struct nfp_net *nn, struct bpf_prog *prog,
-			    struct nfp_bpf_result *res,
-			    void **code, dma_addr_t *dma_addr, u16 max_instr)
+static int nfp_net_bpf_load(struct nfp_net *nn, struct bpf_prog *prog)
 {
-	unsigned int code_sz = max_instr * sizeof(u64);
-	unsigned int stack_size;
-	u16 start_off, done_off;
+	struct nfp_prog *nfp_prog = prog->aux->offload->dev_priv;
 	unsigned int max_mtu;
-	int ret;
-
-	if (!IS_ENABLED(CONFIG_BPF_SYSCALL))
-		return -EOPNOTSUPP;
+	dma_addr_t dma_addr;
+	int err;
 
 	max_mtu = nn_readb(nn, NFP_NET_CFG_BPF_INL_MTU) * 64 - 32;
 	if (max_mtu < nn->dp.netdev->mtu) {
@@ -71,47 +64,24 @@ nfp_net_bpf_offload_prepare(struct nfp_net *nn, struct bpf_prog *prog,
 		return -EOPNOTSUPP;
 	}
 
-	start_off = nn_readw(nn, NFP_NET_CFG_BPF_START);
-	done_off = nn_readw(nn, NFP_NET_CFG_BPF_DONE);
-
-	stack_size = nn_readb(nn, NFP_NET_CFG_BPF_STACK_SZ) * 64;
-	if (prog->aux->stack_depth > stack_size) {
-		nn_info(nn, "stack too large: program %dB > FW stack %dB\n",
-			prog->aux->stack_depth, stack_size);
-		return -EOPNOTSUPP;
-	}
-
-	*code = dma_zalloc_coherent(nn->dp.dev, code_sz, dma_addr, GFP_KERNEL);
-	if (!*code)
+	dma_addr = dma_map_single(nn->dp.dev, nfp_prog->prog,
+				  nfp_prog->prog_len * sizeof(u64),
+				  DMA_TO_DEVICE);
+	if (dma_mapping_error(nn->dp.dev, dma_addr))
 		return -ENOMEM;
 
-	ret = nfp_bpf_jit(prog, *code, start_off, done_off, max_instr, res);
-	if (ret)
-		goto out;
-
-	return 0;
-
-out:
-	dma_free_coherent(nn->dp.dev, code_sz, *code, *dma_addr);
-	return ret;
-}
-
-static void
-nfp_net_bpf_load(struct nfp_net *nn, void *code, dma_addr_t dma_addr,
-		 unsigned int code_sz, unsigned int n_instr)
-{
-	u64 bpf_addr = dma_addr;
-	int err;
-
-	nn_writew(nn, NFP_NET_CFG_BPF_SIZE, n_instr);
-	nn_writeq(nn, NFP_NET_CFG_BPF_ADDR, bpf_addr);
+	nn_writew(nn, NFP_NET_CFG_BPF_SIZE, nfp_prog->prog_len);
+	nn_writeq(nn, NFP_NET_CFG_BPF_ADDR, dma_addr);
 
 	/* Load up the JITed code */
 	err = nfp_net_reconfig(nn, NFP_NET_CFG_UPDATE_BPF);
 	if (err)
 		nn_err(nn, "FW command error while loading BPF: %d\n", err);
 
-	dma_free_coherent(nn->dp.dev, code_sz, code, dma_addr);
+	dma_unmap_single(nn->dp.dev, dma_addr, nfp_prog->prog_len * sizeof(u64),
+			 DMA_TO_DEVICE);
+
+	return err;
 }
 
 static void nfp_net_bpf_start(struct nfp_net *nn)
@@ -140,12 +110,11 @@ static int nfp_net_bpf_stop(struct nfp_net *nn)
 int nfp_net_bpf_offload(struct nfp_net *nn, struct bpf_prog *prog,
 			bool old_prog)
 {
-	struct nfp_bpf_result res;
-	dma_addr_t dma_addr;
-	u16 max_instr;
-	void *code;
 	int err;
 
+	if (prog && !prog->aux->offload)
+		return -EINVAL;
+
 	if (prog && old_prog) {
 		u8 cap;
 
@@ -161,16 +130,114 @@ int nfp_net_bpf_offload(struct nfp_net *nn, struct bpf_prog *prog,
 	if (old_prog && !prog)
 		return nfp_net_bpf_stop(nn);
 
-	max_instr = nn_readw(nn, NFP_NET_CFG_BPF_MAX_LEN);
-
-	err = nfp_net_bpf_offload_prepare(nn, prog, &res, &code, &dma_addr,
-					  max_instr);
+	err = nfp_net_bpf_load(nn, prog);
 	if (err)
 		return err;
 
-	nfp_net_bpf_load(nn, code, dma_addr, max_instr * sizeof(u64),
-			 res.n_instr);
 	if (!old_prog)
 		nfp_net_bpf_start(nn);
+
+	return 0;
+}
+
+static int
+nfp_prog_prepare(struct nfp_prog *nfp_prog, const struct bpf_insn *prog,
+		 unsigned int cnt)
+{
+	unsigned int i;
+
+	for (i = 0; i < cnt; i++) {
+		struct nfp_insn_meta *meta;
+
+		meta = kzalloc(sizeof(*meta), GFP_KERNEL);
+		if (!meta)
+			return -ENOMEM;
+
+		meta->insn = prog[i];
+		meta->n = i;
+
+		list_add_tail(&meta->l, &nfp_prog->insns);
+	}
+
+	return 0;
+}
+
+static void nfp_prog_free(struct nfp_prog *nfp_prog)
+{
+	struct nfp_insn_meta *meta, *tmp;
+
+	list_for_each_entry_safe(meta, tmp, &nfp_prog->insns, l) {
+		list_del(&meta->l);
+		kfree(meta);
+	}
+	kfree(nfp_prog);
+}
+
+int nfp_bpf_verifier_prep(struct nfp_app *app, struct nfp_net *nn,
+			  struct netdev_bpf *bpf)
+{
+	struct bpf_prog *prog = bpf->verifier.prog;
+	struct nfp_prog *nfp_prog;
+	int ret;
+
+	nfp_prog = kzalloc(sizeof(*nfp_prog), GFP_KERNEL);
+	if (!nfp_prog)
+		return -ENOMEM;
+	prog->aux->offload->dev_priv = nfp_prog;
+
+	INIT_LIST_HEAD(&nfp_prog->insns);
+	nfp_prog->type = prog->type;
+
+	ret = nfp_prog_prepare(nfp_prog, prog->insnsi, prog->len);
+	if (ret)
+		goto err_free;
+
+	nfp_prog->verifier_meta = nfp_prog_first_meta(nfp_prog);
+	bpf->verifier.ops = &nfp_bpf_analyzer_ops;
+
+	return 0;
+
+err_free:
+	nfp_prog_free(nfp_prog);
+
+	return ret;
+}
+
+int nfp_bpf_translate(struct nfp_app *app, struct nfp_net *nn,
+		      struct bpf_prog *prog)
+{
+	struct nfp_prog *nfp_prog = prog->aux->offload->dev_priv;
+	unsigned int stack_size;
+	unsigned int max_instr;
+
+	stack_size = nn_readb(nn, NFP_NET_CFG_BPF_STACK_SZ) * 64;
+	if (prog->aux->stack_depth > stack_size) {
+		nn_info(nn, "stack too large: program %dB > FW stack %dB\n",
+			prog->aux->stack_depth, stack_size);
+		return -EOPNOTSUPP;
+	}
+
+	nfp_prog->stack_depth = prog->aux->stack_depth;
+	nfp_prog->start_off = nn_readw(nn, NFP_NET_CFG_BPF_START);
+	nfp_prog->tgt_done = nn_readw(nn, NFP_NET_CFG_BPF_DONE);
+
+	max_instr = nn_readw(nn, NFP_NET_CFG_BPF_MAX_LEN);
+	nfp_prog->__prog_alloc_len = max_instr * sizeof(u64);
+
+	nfp_prog->prog = kmalloc(nfp_prog->__prog_alloc_len, GFP_KERNEL);
+	if (!nfp_prog->prog)
+		return -ENOMEM;
+
+	return nfp_bpf_jit(nfp_prog);
+}
+
+int nfp_bpf_destroy(struct nfp_app *app, struct nfp_net *nn,
+		    struct bpf_prog *prog)
+{
+	struct nfp_prog *nfp_prog = prog->aux->offload->dev_priv;
+
+	kfree(nfp_prog->prog);
+	nfp_prog_free(nfp_prog);
+
 	return 0;
 }
diff --git a/drivers/net/ethernet/netronome/nfp/bpf/verifier.c b/drivers/net/ethernet/netronome/nfp/bpf/verifier.c
index da1b215587fe..0905711d4a79 100644
--- a/drivers/net/ethernet/netronome/nfp/bpf/verifier.c
+++ b/drivers/net/ethernet/netronome/nfp/bpf/verifier.c
@@ -40,12 +40,6 @@
 
 #include "main.h"
 
-/* Analyzer/verifier definitions */
-struct nfp_bpf_analyzer_priv {
-	struct nfp_prog *prog;
-	struct nfp_insn_meta *meta;
-};
-
 static struct nfp_insn_meta *
 nfp_bpf_goto_meta(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta,
 		  unsigned int insn_idx, unsigned int n_insns)
@@ -171,11 +165,11 @@ nfp_bpf_check_ptr(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta,
 static int
 nfp_verify_insn(struct bpf_verifier_env *env, int insn_idx, int prev_insn_idx)
 {
-	struct nfp_bpf_analyzer_priv *priv = env->analyzer_priv;
-	struct nfp_insn_meta *meta = priv->meta;
+	struct nfp_prog *nfp_prog = env->prog->aux->offload->dev_priv;
+	struct nfp_insn_meta *meta = nfp_prog->verifier_meta;
 
-	meta = nfp_bpf_goto_meta(priv->prog, meta, insn_idx, env->prog->len);
-	priv->meta = meta;
+	meta = nfp_bpf_goto_meta(nfp_prog, meta, insn_idx, env->prog->len);
+	nfp_prog->verifier_meta = meta;
 
 	if (meta->insn.src_reg >= MAX_BPF_REG ||
 	    meta->insn.dst_reg >= MAX_BPF_REG) {
@@ -184,39 +178,18 @@ nfp_verify_insn(struct bpf_verifier_env *env, int insn_idx, int prev_insn_idx)
 	}
 
 	if (meta->insn.code == (BPF_JMP | BPF_EXIT))
-		return nfp_bpf_check_exit(priv->prog, env);
+		return nfp_bpf_check_exit(nfp_prog, env);
 
 	if ((meta->insn.code & ~BPF_SIZE_MASK) == (BPF_LDX | BPF_MEM))
-		return nfp_bpf_check_ptr(priv->prog, meta, env,
+		return nfp_bpf_check_ptr(nfp_prog, meta, env,
 					 meta->insn.src_reg);
 	if ((meta->insn.code & ~BPF_SIZE_MASK) == (BPF_STX | BPF_MEM))
-		return nfp_bpf_check_ptr(priv->prog, meta, env,
+		return nfp_bpf_check_ptr(nfp_prog, meta, env,
 					 meta->insn.dst_reg);
 
 	return 0;
 }
 
-static const struct bpf_ext_analyzer_ops nfp_bpf_analyzer_ops = {
+const struct bpf_ext_analyzer_ops nfp_bpf_analyzer_ops = {
 	.insn_hook = nfp_verify_insn,
 };
-
-int nfp_prog_verify(struct nfp_prog *nfp_prog, struct bpf_prog *prog)
-{
-	struct nfp_bpf_analyzer_priv *priv;
-	int ret;
-
-	nfp_prog->stack_depth = prog->aux->stack_depth;
-
-	priv = kzalloc(sizeof(*priv), GFP_KERNEL);
-	if (!priv)
-		return -ENOMEM;
-
-	priv->prog = nfp_prog;
-	priv->meta = nfp_prog_first_meta(nfp_prog);
-
-	ret = bpf_analyzer(prog, &nfp_bpf_analyzer_ops, priv);
-
-	kfree(priv);
-
-	return ret;
-}
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_app.h b/drivers/net/ethernet/netronome/nfp/nfp_app.h
index 857bb33020ba..fadff666beb3 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_app.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_app.h
@@ -42,6 +42,7 @@
 
 struct bpf_prog;
 struct net_device;
+struct netdev_bof;
 struct pci_dev;
 struct sk_buff;
 struct sk_buff;
@@ -83,6 +84,9 @@ extern const struct nfp_app_type app_flower;
  * @setup_tc:	setup TC ndo
  * @tc_busy:	TC HW offload busy (rules loaded)
  * @xdp_offload:    offload an XDP program
+ * @bpf_verifier_prep:	verifier prep for dev-specific BPF programs
+ * @bpf_translate:	translate call for dev-specific BPF programs
+ * @bpf_destroy:	destroy for dev-specific BPF programs
  * @eswitch_mode_get:    get SR-IOV eswitch mode
  * @sriov_enable: app-specific sriov initialisation
  * @sriov_disable: app-specific sriov clean-up
@@ -118,6 +122,12 @@ struct nfp_app_type {
 	bool (*tc_busy)(struct nfp_app *app, struct nfp_net *nn);
 	int (*xdp_offload)(struct nfp_app *app, struct nfp_net *nn,
 			   struct bpf_prog *prog);
+	int (*bpf_verifier_prep)(struct nfp_app *app, struct nfp_net *nn,
+				 struct netdev_bpf *bpf);
+	int (*bpf_translate)(struct nfp_app *app, struct nfp_net *nn,
+			     struct bpf_prog *prog);
+	int (*bpf_destroy)(struct nfp_app *app, struct nfp_net *nn,
+			   struct bpf_prog *prog);
 
 	int (*sriov_enable)(struct nfp_app *app, int num_vfs);
 	void (*sriov_disable)(struct nfp_app *app);
@@ -271,6 +281,33 @@ static inline int nfp_app_xdp_offload(struct nfp_app *app, struct nfp_net *nn,
 	return app->type->xdp_offload(app, nn, prog);
 }
 
+static inline int
+nfp_app_bpf_verifier_prep(struct nfp_app *app, struct nfp_net *nn,
+			  struct netdev_bpf *bpf)
+{
+	if (!app || !app->type->bpf_verifier_prep)
+		return -EOPNOTSUPP;
+	return app->type->bpf_verifier_prep(app, nn, bpf);
+}
+
+static inline int
+nfp_app_bpf_translate(struct nfp_app *app, struct nfp_net *nn,
+		      struct bpf_prog *prog)
+{
+	if (!app || !app->type->bpf_translate)
+		return -EOPNOTSUPP;
+	return app->type->bpf_translate(app, nn, prog);
+}
+
+static inline int
+nfp_app_bpf_destroy(struct nfp_app *app, struct nfp_net *nn,
+		    struct bpf_prog *prog)
+{
+	if (!app || !app->type->bpf_destroy)
+		return -EOPNOTSUPP;
+	return app->type->bpf_destroy(app, nn, prog);
+}
+
 static inline bool nfp_app_ctrl_tx(struct nfp_app *app, struct sk_buff *skb)
 {
 	trace_devlink_hwmsg(priv_to_devlink(app->pf), false, 0,
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index f6c6ad4e8a59..232044b1b7aa 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -3393,6 +3393,14 @@ static int nfp_net_xdp(struct net_device *netdev, struct netdev_bpf *xdp)
 			xdp->prog_attached = XDP_ATTACHED_HW;
 		xdp->prog_id = nn->xdp_prog ? nn->xdp_prog->aux->id : 0;
 		return 0;
+	case BPF_OFFLOAD_VERIFIER_PREP:
+		return nfp_app_bpf_verifier_prep(nn->app, nn, xdp);
+	case BPF_OFFLOAD_TRANSLATE:
+		return nfp_app_bpf_translate(nn->app, nn,
+					     xdp->offload.prog);
+	case BPF_OFFLOAD_DESTROY:
+		return nfp_app_bpf_destroy(nn->app, nn,
+					   xdp->offload.prog);
 	default:
 		return -EINVAL;
 	}
-- 
2.14.1
