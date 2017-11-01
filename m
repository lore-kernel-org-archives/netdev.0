From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [RFC 07/12] nfp: bpf: drop support for cls_bpf with legacy actions
Date: Tue, 31 Oct 2017 18:52:12 -0700
Message-ID: <20171101015217.10666-8-jakub.kicinski@netronome.com>
References: <20171101015217.10666-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, alexei.starovoitov@gmail.com,
        daniel@iogearbox.net, bblanco@gmail.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:56589 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932930AbdKABxF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 21:53:05 -0400
Received: by mail-pg0-f68.google.com with SMTP id m18so780364pgd.13
        for <netdev@vger.kernel.org>; Tue, 31 Oct 2017 18:53:05 -0700 (PDT)
In-Reply-To: <20171101015217.10666-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Only support BPF_PROG_TYPE_SCHED_CLS programs in direct
action mode.  This simplifies preparing the offload since
there will now be only one mode of operation for that type
of program.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Quentin Monnet <quentin.monnet@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/bpf/jit.c      |  87 ++---------------
 drivers/net/ethernet/netronome/nfp/bpf/main.c     |  31 ++-----
 drivers/net/ethernet/netronome/nfp/bpf/main.h     |  30 +-----
 drivers/net/ethernet/netronome/nfp/bpf/offload.c  | 108 +---------------------
 drivers/net/ethernet/netronome/nfp/bpf/verifier.c |  11 +--
 5 files changed, 20 insertions(+), 247 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/bpf/jit.c b/drivers/net/ethernet/netronome/nfp/bpf/jit.c
index e7eeb7a07f81..35c5ca92d3ad 100644
--- a/drivers/net/ethernet/netronome/nfp/bpf/jit.c
+++ b/drivers/net/ethernet/netronome/nfp/bpf/jit.c
@@ -201,47 +201,6 @@ emit_br(struct nfp_prog *nfp_prog, enum br_mask mask, u16 addr, u8 defer)
 		  BR_CSS_NONE, addr, defer);
 }
 
-static void
-__emit_br_byte(struct nfp_prog *nfp_prog, u8 areg, u8 breg, bool imm8,
-	       u8 byte, bool equal, u16 addr, u8 defer, bool src_lmextn)
-{
-	u16 addr_lo, addr_hi;
-	u64 insn;
-
-	addr_lo = addr & (OP_BB_ADDR_LO >> __bf_shf(OP_BB_ADDR_LO));
-	addr_hi = addr != addr_lo;
-
-	insn = OP_BBYTE_BASE |
-		FIELD_PREP(OP_BB_A_SRC, areg) |
-		FIELD_PREP(OP_BB_BYTE, byte) |
-		FIELD_PREP(OP_BB_B_SRC, breg) |
-		FIELD_PREP(OP_BB_I8, imm8) |
-		FIELD_PREP(OP_BB_EQ, equal) |
-		FIELD_PREP(OP_BB_DEFBR, defer) |
-		FIELD_PREP(OP_BB_ADDR_LO, addr_lo) |
-		FIELD_PREP(OP_BB_ADDR_HI, addr_hi) |
-		FIELD_PREP(OP_BB_SRC_LMEXTN, src_lmextn);
-
-	nfp_prog_push(nfp_prog, insn);
-}
-
-static void
-emit_br_byte_neq(struct nfp_prog *nfp_prog,
-		 swreg src, u8 imm, u8 byte, u16 addr, u8 defer)
-{
-	struct nfp_insn_re_regs reg;
-	int err;
-
-	err = swreg_to_restricted(reg_none(), src, reg_imm(imm), &reg, true);
-	if (err) {
-		nfp_prog->error = err;
-		return;
-	}
-
-	__emit_br_byte(nfp_prog, reg.areg, reg.breg, reg.i8, byte, false, addr,
-		       defer, reg.src_lmextn);
-}
-
 static void
 __emit_immed(struct nfp_prog *nfp_prog, u16 areg, u16 breg, u16 imm_hi,
 	     enum immed_width width, bool invert,
@@ -1525,7 +1484,7 @@ mem_ldx(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta,
 	unsigned int size)
 {
 	if (meta->ptr.type == PTR_TO_CTX) {
-		if (nfp_prog->act == NN_ACT_XDP)
+		if (nfp_prog->type == BPF_PROG_TYPE_XDP)
 			return mem_ldx_xdp(nfp_prog, meta, size);
 		else
 			return mem_ldx_skb(nfp_prog, meta, size);
@@ -1998,34 +1957,6 @@ static void nfp_intro(struct nfp_prog *nfp_prog)
 		 plen_reg(nfp_prog), ALU_OP_AND, pv_len(nfp_prog));
 }
 
-static void nfp_outro_tc_legacy(struct nfp_prog *nfp_prog)
-{
-	const u8 act2code[] = {
-		[NN_ACT_TC_DROP]  = 0x22,
-		[NN_ACT_TC_REDIR] = 0x24
-	};
-	/* Target for aborts */
-	nfp_prog->tgt_abort = nfp_prog_current_offset(nfp_prog);
-	wrp_immed(nfp_prog, reg_both(0), 0);
-
-	/* Target for normal exits */
-	nfp_prog->tgt_out = nfp_prog_current_offset(nfp_prog);
-	/* Legacy TC mode:
-	 *   0        0x11 -> pass,  count as stat0
-	 *  -1  drop  0x22 -> drop,  count as stat1
-	 *     redir  0x24 -> redir, count as stat1
-	 *  ife mark  0x21 -> pass,  count as stat1
-	 *  ife + tx  0x24 -> redir, count as stat1
-	 */
-	emit_br_byte_neq(nfp_prog, reg_b(0), 0xff, 0, nfp_prog->tgt_done, 2);
-	wrp_mov(nfp_prog, reg_a(0), NFP_BPF_ABI_FLAGS);
-	emit_ld_field(nfp_prog, reg_a(0), 0xc, reg_imm(0x11), SHF_SC_L_SHF, 16);
-
-	emit_br(nfp_prog, BR_UNC, nfp_prog->tgt_done, 1);
-	emit_ld_field(nfp_prog, reg_a(0), 0xc, reg_imm(act2code[nfp_prog->act]),
-		      SHF_SC_L_SHF, 16);
-}
-
 static void nfp_outro_tc_da(struct nfp_prog *nfp_prog)
 {
 	/* TC direct-action mode:
@@ -2118,17 +2049,15 @@ static void nfp_outro_xdp(struct nfp_prog *nfp_prog)
 
 static void nfp_outro(struct nfp_prog *nfp_prog)
 {
-	switch (nfp_prog->act) {
-	case NN_ACT_DIRECT:
+	switch (nfp_prog->type) {
+	case BPF_PROG_TYPE_SCHED_CLS:
 		nfp_outro_tc_da(nfp_prog);
 		break;
-	case NN_ACT_TC_DROP:
-	case NN_ACT_TC_REDIR:
-		nfp_outro_tc_legacy(nfp_prog);
-		break;
-	case NN_ACT_XDP:
+	case BPF_PROG_TYPE_XDP:
 		nfp_outro_xdp(nfp_prog);
 		break;
+	default:
+		WARN_ON(1);
 	}
 }
 
@@ -2327,7 +2256,6 @@ static int nfp_bpf_ustore_calc(struct nfp_prog *nfp_prog, __le64 *ustore)
  * nfp_bpf_jit() - translate BPF code into NFP assembly
  * @filter:	kernel BPF filter struct
  * @prog_mem:	memory to store assembler instructions
- * @act:	action attached to this eBPF program
  * @prog_start:	offset of the first instruction when loaded
  * @prog_done:	where to jump on exit
  * @prog_sz:	size of @prog_mem in instructions
@@ -2335,7 +2263,6 @@ static int nfp_bpf_ustore_calc(struct nfp_prog *nfp_prog, __le64 *ustore)
  */
 int
 nfp_bpf_jit(struct bpf_prog *filter, void *prog_mem,
-	    enum nfp_bpf_action_type act,
 	    unsigned int prog_start, unsigned int prog_done,
 	    unsigned int prog_sz, struct nfp_bpf_result *res)
 {
@@ -2347,7 +2274,7 @@ nfp_bpf_jit(struct bpf_prog *filter, void *prog_mem,
 		return -ENOMEM;
 
 	INIT_LIST_HEAD(&nfp_prog->insns);
-	nfp_prog->act = act;
+	nfp_prog->type = filter->type;
 	nfp_prog->start_off = prog_start;
 	nfp_prog->tgt_done = prog_done;
 
diff --git a/drivers/net/ethernet/netronome/nfp/bpf/main.c b/drivers/net/ethernet/netronome/nfp/bpf/main.c
index 8e3e89cace8d..f6c0c3b517f1 100644
--- a/drivers/net/ethernet/netronome/nfp/bpf/main.c
+++ b/drivers/net/ethernet/netronome/nfp/bpf/main.c
@@ -85,34 +85,10 @@ static const char *nfp_bpf_extra_cap(struct nfp_app *app, struct nfp_net *nn)
 	return nfp_net_ebpf_capable(nn) ? "BPF" : "";
 }
 
-static int
-nfp_bpf_vnic_alloc(struct nfp_app *app, struct nfp_net *nn, unsigned int id)
-{
-	struct nfp_net_bpf_priv *priv;
-	int ret;
-
-	priv = kmalloc(sizeof(*priv), GFP_KERNEL);
-	if (!priv)
-		return -ENOMEM;
-
-	nn->app_priv = priv;
-	spin_lock_init(&priv->rx_filter_lock);
-	priv->nn = nn;
-	timer_setup(&priv->rx_filter_stats_timer,
-		    nfp_net_filter_stats_timer, 0);
-
-	ret = nfp_app_nic_vnic_alloc(app, nn, id);
-	if (ret)
-		kfree(priv);
-
-	return ret;
-}
-
 static void nfp_bpf_vnic_free(struct nfp_app *app, struct nfp_net *nn)
 {
 	if (nn->dp.bpf_offload_xdp)
 		nfp_bpf_xdp_offload(app, nn, NULL);
-	kfree(nn->app_priv);
 }
 
 static int nfp_bpf_setup_tc_block_cb(enum tc_setup_type type,
@@ -133,6 +109,11 @@ static int nfp_bpf_setup_tc_block_cb(enum tc_setup_type type,
 		if (nn->dp.bpf_offload_xdp)
 			return -EBUSY;
 
+		/* Only support TC direct action */
+		if (!cls_bpf->exts_integrated ||
+		    tcf_exts_has_actions(cls_bpf->exts))
+			return -EOPNOTSUPP;
+
 		return nfp_net_bpf_offload(nn, cls_bpf);
 	default:
 		return -EOPNOTSUPP;
@@ -184,7 +165,7 @@ const struct nfp_app_type app_bpf = {
 
 	.extra_cap	= nfp_bpf_extra_cap,
 
-	.vnic_alloc	= nfp_bpf_vnic_alloc,
+	.vnic_alloc	= nfp_app_nic_vnic_alloc,
 	.vnic_free	= nfp_bpf_vnic_free,
 
 	.setup_tc	= nfp_bpf_setup_tc,
diff --git a/drivers/net/ethernet/netronome/nfp/bpf/main.h b/drivers/net/ethernet/netronome/nfp/bpf/main.h
index bc604030ff6c..c5280de2ab14 100644
--- a/drivers/net/ethernet/netronome/nfp/bpf/main.h
+++ b/drivers/net/ethernet/netronome/nfp/bpf/main.h
@@ -65,13 +65,6 @@ enum pkt_vec {
 	PKT_VEC_PKT_PTR		= 2,
 };
 
-enum nfp_bpf_action_type {
-	NN_ACT_TC_DROP,
-	NN_ACT_TC_REDIR,
-	NN_ACT_DIRECT,
-	NN_ACT_XDP,
-};
-
 #define pv_len(np)	reg_lm(1, PKT_VEC_PKT_LEN)
 #define pv_ctm_ptr(np)	reg_lm(1, PKT_VEC_PKT_PTR)
 
@@ -147,7 +140,7 @@ static inline u8 mbpf_mode(const struct nfp_insn_meta *meta)
  * @prog: machine code
  * @prog_len: number of valid instructions in @prog array
  * @__prog_alloc_len: alloc size of @prog array
- * @act: BPF program/action type (TC DA, TC with action, XDP etc.)
+ * @type: BPF program type
  * @num_regs: number of registers used by this program
  * @regs_per_thread: number of basic registers allocated per thread
  * @start_off: address of the first instruction in the memory
@@ -164,7 +157,7 @@ struct nfp_prog {
 	unsigned int prog_len;
 	unsigned int __prog_alloc_len;
 
-	enum nfp_bpf_action_type act;
+	enum bpf_prog_type type;
 
 	unsigned int num_regs;
 	unsigned int regs_per_thread;
@@ -188,7 +181,7 @@ struct nfp_bpf_result {
 };
 
 int
-nfp_bpf_jit(struct bpf_prog *filter, void *prog, enum nfp_bpf_action_type act,
+nfp_bpf_jit(struct bpf_prog *filter, void *prog,
 	    unsigned int prog_start, unsigned int prog_done,
 	    unsigned int prog_sz, struct nfp_bpf_result *res);
 
@@ -197,23 +190,6 @@ int nfp_prog_verify(struct nfp_prog *nfp_prog, struct bpf_prog *prog);
 struct nfp_net;
 struct tc_cls_bpf_offload;
 
-/**
- * struct nfp_net_bpf_priv - per-vNIC BPF private data
- * @rx_filter:		Filter offload statistics - dropped packets/bytes
- * @rx_filter_prev:	Filter offload statistics - values from previous update
- * @rx_filter_change:	Jiffies when statistics last changed
- * @rx_filter_stats_timer:  Timer for polling filter offload statistics
- * @rx_filter_lock:	Lock protecting timer state changes (teardown)
- */
-struct nfp_net_bpf_priv {
-	struct nfp_stat_pair rx_filter, rx_filter_prev;
-	unsigned long rx_filter_change;
-	struct timer_list rx_filter_stats_timer;
-	struct nfp_net *nn;
-	spinlock_t rx_filter_lock;
-};
-
 int nfp_net_bpf_offload(struct nfp_net *nn, struct tc_cls_bpf_offload *cls_bpf);
-void nfp_net_filter_stats_timer(struct timer_list *t);
 
 #endif
diff --git a/drivers/net/ethernet/netronome/nfp/bpf/offload.c b/drivers/net/ethernet/netronome/nfp/bpf/offload.c
index 63c8f7847054..5035803e5395 100644
--- a/drivers/net/ethernet/netronome/nfp/bpf/offload.c
+++ b/drivers/net/ethernet/netronome/nfp/bpf/offload.c
@@ -51,92 +51,6 @@
 #include "../nfp_net_ctrl.h"
 #include "../nfp_net.h"
 
-void nfp_net_filter_stats_timer(struct timer_list *t)
-{
-	struct nfp_net_bpf_priv *priv = from_timer(priv, t,
-						   rx_filter_stats_timer);
-	struct nfp_net *nn = priv->nn;
-	struct nfp_stat_pair latest;
-
-	spin_lock_bh(&priv->rx_filter_lock);
-
-	if (nn->dp.ctrl & NFP_NET_CFG_CTRL_BPF)
-		mod_timer(&priv->rx_filter_stats_timer,
-			  jiffies + NFP_NET_STAT_POLL_IVL);
-
-	spin_unlock_bh(&priv->rx_filter_lock);
-
-	latest.pkts = nn_readq(nn, NFP_NET_CFG_STATS_APP1_FRAMES);
-	latest.bytes = nn_readq(nn, NFP_NET_CFG_STATS_APP1_BYTES);
-
-	if (latest.pkts != priv->rx_filter.pkts)
-		priv->rx_filter_change = jiffies;
-
-	priv->rx_filter = latest;
-}
-
-static void nfp_net_bpf_stats_reset(struct nfp_net *nn)
-{
-	struct nfp_net_bpf_priv *priv = nn->app_priv;
-
-	priv->rx_filter.pkts = nn_readq(nn, NFP_NET_CFG_STATS_APP1_FRAMES);
-	priv->rx_filter.bytes = nn_readq(nn, NFP_NET_CFG_STATS_APP1_BYTES);
-	priv->rx_filter_prev = priv->rx_filter;
-	priv->rx_filter_change = jiffies;
-}
-
-static int
-nfp_net_bpf_stats_update(struct nfp_net *nn, struct tc_cls_bpf_offload *cls_bpf)
-{
-	struct nfp_net_bpf_priv *priv = nn->app_priv;
-	u64 bytes, pkts;
-
-	pkts = priv->rx_filter.pkts - priv->rx_filter_prev.pkts;
-	bytes = priv->rx_filter.bytes - priv->rx_filter_prev.bytes;
-	bytes -= pkts * ETH_HLEN;
-
-	priv->rx_filter_prev = priv->rx_filter;
-
-	tcf_exts_stats_update(cls_bpf->exts,
-			      bytes, pkts, priv->rx_filter_change);
-
-	return 0;
-}
-
-static int
-nfp_net_bpf_get_act(struct nfp_net *nn, struct tc_cls_bpf_offload *cls_bpf)
-{
-	const struct tc_action *a;
-	LIST_HEAD(actions);
-
-	if (!cls_bpf->exts)
-		return NN_ACT_XDP;
-
-	/* TC direct action */
-	if (cls_bpf->exts_integrated) {
-		if (!tcf_exts_has_actions(cls_bpf->exts))
-			return NN_ACT_DIRECT;
-
-		return -EOPNOTSUPP;
-	}
-
-	/* TC legacy mode */
-	if (!tcf_exts_has_one_action(cls_bpf->exts))
-		return -EOPNOTSUPP;
-
-	tcf_exts_to_list(cls_bpf->exts, &actions);
-	list_for_each_entry(a, &actions, list) {
-		if (is_tcf_gact_shot(a))
-			return NN_ACT_TC_DROP;
-
-		if (is_tcf_mirred_egress_redirect(a) &&
-		    tcf_mirred_ifindex(a) == nn->dp.netdev->ifindex)
-			return NN_ACT_TC_REDIR;
-	}
-
-	return -EOPNOTSUPP;
-}
-
 static int
 nfp_net_bpf_offload_prepare(struct nfp_net *nn,
 			    struct tc_cls_bpf_offload *cls_bpf,
@@ -144,7 +58,6 @@ nfp_net_bpf_offload_prepare(struct nfp_net *nn,
 			    void **code, dma_addr_t *dma_addr, u16 max_instr)
 {
 	unsigned int code_sz = max_instr * sizeof(u64);
-	enum nfp_bpf_action_type act;
 	unsigned int stack_size;
 	u16 start_off, done_off;
 	unsigned int max_mtu;
@@ -153,11 +66,6 @@ nfp_net_bpf_offload_prepare(struct nfp_net *nn,
 	if (!IS_ENABLED(CONFIG_BPF_SYSCALL))
 		return -EOPNOTSUPP;
 
-	ret = nfp_net_bpf_get_act(nn, cls_bpf);
-	if (ret < 0)
-		return ret;
-	act = ret;
-
 	max_mtu = nn_readb(nn, NFP_NET_CFG_BPF_INL_MTU) * 64 - 32;
 	if (max_mtu < nn->dp.netdev->mtu) {
 		nn_info(nn, "BPF offload not supported with MTU larger than HW packet split boundary\n");
@@ -178,7 +86,7 @@ nfp_net_bpf_offload_prepare(struct nfp_net *nn,
 	if (!*code)
 		return -ENOMEM;
 
-	ret = nfp_bpf_jit(cls_bpf->prog, *code, act, start_off, done_off,
+	ret = nfp_bpf_jit(cls_bpf->prog, *code, start_off, done_off,
 			  max_instr, res);
 	if (ret)
 		goto out;
@@ -196,7 +104,6 @@ nfp_net_bpf_load_and_start(struct nfp_net *nn, u32 tc_flags,
 			   unsigned int code_sz, unsigned int n_instr,
 			   bool dense_mode)
 {
-	struct nfp_net_bpf_priv *priv = nn->app_priv;
 	u64 bpf_addr = dma_addr;
 	int err;
 
@@ -221,25 +128,15 @@ nfp_net_bpf_load_and_start(struct nfp_net *nn, u32 tc_flags,
 		nn_err(nn, "FW command error while enabling BPF: %d\n", err);
 
 	dma_free_coherent(nn->dp.dev, code_sz, code, dma_addr);
-
-	nfp_net_bpf_stats_reset(nn);
-	mod_timer(&priv->rx_filter_stats_timer,
-		  jiffies + NFP_NET_STAT_POLL_IVL);
 }
 
 static int nfp_net_bpf_stop(struct nfp_net *nn)
 {
-	struct nfp_net_bpf_priv *priv = nn->app_priv;
-
 	if (!(nn->dp.ctrl & NFP_NET_CFG_CTRL_BPF))
 		return 0;
 
-	spin_lock_bh(&priv->rx_filter_lock);
 	nn->dp.ctrl &= ~NFP_NET_CFG_CTRL_BPF;
-	spin_unlock_bh(&priv->rx_filter_lock);
 	nn_writel(nn, NFP_NET_CFG_CTRL, nn->dp.ctrl);
-
-	del_timer_sync(&priv->rx_filter_stats_timer);
 	nn->dp.bpf_offload_skip_sw = 0;
 
 	return nfp_net_reconfig(nn, NFP_NET_CFG_UPDATE_GEN);
@@ -295,9 +192,6 @@ int nfp_net_bpf_offload(struct nfp_net *nn, struct tc_cls_bpf_offload *cls_bpf)
 	case TC_CLSBPF_DESTROY:
 		return nfp_net_bpf_stop(nn);
 
-	case TC_CLSBPF_STATS:
-		return nfp_net_bpf_stats_update(nn, cls_bpf);
-
 	default:
 		return -EOPNOTSUPP;
 	}
diff --git a/drivers/net/ethernet/netronome/nfp/bpf/verifier.c b/drivers/net/ethernet/netronome/nfp/bpf/verifier.c
index 3d3dcac1c942..da1b215587fe 100644
--- a/drivers/net/ethernet/netronome/nfp/bpf/verifier.c
+++ b/drivers/net/ethernet/netronome/nfp/bpf/verifier.c
@@ -81,7 +81,7 @@ nfp_bpf_check_exit(struct nfp_prog *nfp_prog,
 	const struct bpf_reg_state *reg0 = &env->cur_state.regs[0];
 	u64 imm;
 
-	if (nfp_prog->act == NN_ACT_XDP)
+	if (nfp_prog->type == BPF_PROG_TYPE_XDP)
 		return 0;
 
 	if (!(reg0->type == SCALAR_VALUE && tnum_is_const(reg0->var_off))) {
@@ -94,13 +94,8 @@ nfp_bpf_check_exit(struct nfp_prog *nfp_prog,
 	}
 
 	imm = reg0->var_off.value;
-	if (nfp_prog->act != NN_ACT_DIRECT && imm != 0 && (imm & ~0U) != ~0U) {
-		pr_info("unsupported exit state: %d, imm: %llx\n",
-			reg0->type, imm);
-		return -EINVAL;
-	}
-
-	if (nfp_prog->act == NN_ACT_DIRECT && imm <= TC_ACT_REDIRECT &&
+	if (nfp_prog->type == BPF_PROG_TYPE_SCHED_CLS &&
+	    imm <= TC_ACT_REDIRECT &&
 	    imm != TC_ACT_SHOT && imm != TC_ACT_STOLEN &&
 	    imm != TC_ACT_QUEUED) {
 		pr_info("unsupported exit state: %d, imm: %llx\n",
-- 
2.14.1
