From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [RFC 08/12] nfp: bpf: refactor offload logic
Date: Tue, 31 Oct 2017 18:52:13 -0700
Message-ID: <20171101015217.10666-9-jakub.kicinski@netronome.com>
References: <20171101015217.10666-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, alexei.starovoitov@gmail.com,
        daniel@iogearbox.net, bblanco@gmail.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:53913 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932932AbdKABxG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 21:53:06 -0400
Received: by mail-pg0-f67.google.com with SMTP id s2so786615pge.10
        for <netdev@vger.kernel.org>; Tue, 31 Oct 2017 18:53:06 -0700 (PDT)
In-Reply-To: <20171101015217.10666-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We currently create a fake cls_bpf offload object when we want
to offload XDP.  Simplify and clarify the code by moving the
TC/XDP specific logic out of common offload code.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Quentin Monnet <quentin.monnet@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/bpf/main.c    | 62 ++++++++++----------
 drivers/net/ethernet/netronome/nfp/bpf/main.h    |  4 +-
 drivers/net/ethernet/netronome/nfp/bpf/offload.c | 74 ++++++++++--------------
 3 files changed, 64 insertions(+), 76 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/bpf/main.c b/drivers/net/ethernet/netronome/nfp/bpf/main.c
index f6c0c3b517f1..c788def0c457 100644
--- a/drivers/net/ethernet/netronome/nfp/bpf/main.c
+++ b/drivers/net/ethernet/netronome/nfp/bpf/main.c
@@ -54,28 +54,24 @@ static int
 nfp_bpf_xdp_offload(struct nfp_app *app, struct nfp_net *nn,
 		    struct bpf_prog *prog)
 {
-	struct tc_cls_bpf_offload cmd = {
-		.prog = prog,
-	};
+	bool running;
 	int ret;
 
 	if (!nfp_net_ebpf_capable(nn))
 		return -EINVAL;
 
-	if (nn->dp.ctrl & NFP_NET_CFG_CTRL_BPF) {
-		if (!nn->dp.bpf_offload_xdp)
-			return prog ? -EBUSY : 0;
-		cmd.command = prog ? TC_CLSBPF_REPLACE : TC_CLSBPF_DESTROY;
-	} else {
-		if (!prog)
-			return 0;
-		cmd.command = TC_CLSBPF_ADD;
-	}
+	running = nn->dp.ctrl & NFP_NET_CFG_CTRL_BPF;
+
+	if (!prog && !(running && nn->dp.bpf_offload_xdp))
+		return 0;
+	if (prog && running && !nn->dp.bpf_offload_xdp)
+		return -EBUSY;
 
-	ret = nfp_net_bpf_offload(nn, &cmd);
+	ret = nfp_net_bpf_offload(nn, prog, running, true);
 	/* Stop offload if replace not possible */
-	if (ret && cmd.command == TC_CLSBPF_REPLACE)
+	if (ret && prog)
 		nfp_bpf_xdp_offload(app, nn, NULL);
+
 	nn->dp.bpf_offload_xdp = prog && !ret;
 	return ret;
 }
@@ -96,25 +92,31 @@ static int nfp_bpf_setup_tc_block_cb(enum tc_setup_type type,
 {
 	struct tc_cls_bpf_offload *cls_bpf = type_data;
 	struct nfp_net *nn = cb_priv;
+	bool skip_sw;
 
-	if (!tc_can_offload(nn->dp.netdev))
+	if (type != TC_SETUP_CLSBPF ||
+	    !tc_can_offload(nn->dp.netdev) ||
+	    !nfp_net_ebpf_capable(nn) ||
+	    cls_bpf->common.protocol != htons(ETH_P_ALL) ||
+	    cls_bpf->common.chain_index)
 		return -EOPNOTSUPP;
+	if (nn->dp.bpf_offload_xdp)
+		return -EBUSY;
 
-	switch (type) {
-	case TC_SETUP_CLSBPF:
-		if (!nfp_net_ebpf_capable(nn) ||
-		    cls_bpf->common.protocol != htons(ETH_P_ALL) ||
-		    cls_bpf->common.chain_index)
-			return -EOPNOTSUPP;
-		if (nn->dp.bpf_offload_xdp)
-			return -EBUSY;
-
-		/* Only support TC direct action */
-		if (!cls_bpf->exts_integrated ||
-		    tcf_exts_has_actions(cls_bpf->exts))
-			return -EOPNOTSUPP;
-
-		return nfp_net_bpf_offload(nn, cls_bpf);
+	/* Only support TC direct action */
+	if (!cls_bpf->exts_integrated ||
+	    tcf_exts_has_actions(cls_bpf->exts))
+		return -EOPNOTSUPP;
+
+	skip_sw = !!(cls_bpf->gen_flags & TCA_CLS_FLAGS_SKIP_SW);
+
+	switch (cls_bpf->command) {
+	case TC_CLSBPF_REPLACE:
+		return nfp_net_bpf_offload(nn, cls_bpf->prog, true, !skip_sw);
+	case TC_CLSBPF_ADD:
+		return nfp_net_bpf_offload(nn, cls_bpf->prog, false, !skip_sw);
+	case TC_CLSBPF_DESTROY:
+		return nfp_net_bpf_offload(nn, NULL, true, !skip_sw);
 	default:
 		return -EOPNOTSUPP;
 	}
diff --git a/drivers/net/ethernet/netronome/nfp/bpf/main.h b/drivers/net/ethernet/netronome/nfp/bpf/main.h
index c5280de2ab14..15ff341d35b1 100644
--- a/drivers/net/ethernet/netronome/nfp/bpf/main.h
+++ b/drivers/net/ethernet/netronome/nfp/bpf/main.h
@@ -188,8 +188,8 @@ nfp_bpf_jit(struct bpf_prog *filter, void *prog,
 int nfp_prog_verify(struct nfp_prog *nfp_prog, struct bpf_prog *prog);
 
 struct nfp_net;
-struct tc_cls_bpf_offload;
 
-int nfp_net_bpf_offload(struct nfp_net *nn, struct tc_cls_bpf_offload *cls_bpf);
+int nfp_net_bpf_offload(struct nfp_net *nn, struct bpf_prog *prog,
+			bool old_prog, bool sw_fallback);
 
 #endif
diff --git a/drivers/net/ethernet/netronome/nfp/bpf/offload.c b/drivers/net/ethernet/netronome/nfp/bpf/offload.c
index 5035803e5395..de689919c58f 100644
--- a/drivers/net/ethernet/netronome/nfp/bpf/offload.c
+++ b/drivers/net/ethernet/netronome/nfp/bpf/offload.c
@@ -52,8 +52,7 @@
 #include "../nfp_net.h"
 
 static int
-nfp_net_bpf_offload_prepare(struct nfp_net *nn,
-			    struct tc_cls_bpf_offload *cls_bpf,
+nfp_net_bpf_offload_prepare(struct nfp_net *nn, struct bpf_prog *prog,
 			    struct nfp_bpf_result *res,
 			    void **code, dma_addr_t *dma_addr, u16 max_instr)
 {
@@ -76,9 +75,9 @@ nfp_net_bpf_offload_prepare(struct nfp_net *nn,
 	done_off = nn_readw(nn, NFP_NET_CFG_BPF_DONE);
 
 	stack_size = nn_readb(nn, NFP_NET_CFG_BPF_STACK_SZ) * 64;
-	if (cls_bpf->prog->aux->stack_depth > stack_size) {
+	if (prog->aux->stack_depth > stack_size) {
 		nn_info(nn, "stack too large: program %dB > FW stack %dB\n",
-			cls_bpf->prog->aux->stack_depth, stack_size);
+			prog->aux->stack_depth, stack_size);
 		return -EOPNOTSUPP;
 	}
 
@@ -86,8 +85,7 @@ nfp_net_bpf_offload_prepare(struct nfp_net *nn,
 	if (!*code)
 		return -ENOMEM;
 
-	ret = nfp_bpf_jit(cls_bpf->prog, *code, start_off, done_off,
-			  max_instr, res);
+	ret = nfp_bpf_jit(prog, *code, start_off, done_off, max_instr, res);
 	if (ret)
 		goto out;
 
@@ -99,7 +97,7 @@ nfp_net_bpf_offload_prepare(struct nfp_net *nn,
 }
 
 static void
-nfp_net_bpf_load_and_start(struct nfp_net *nn, u32 tc_flags,
+nfp_net_bpf_load_and_start(struct nfp_net *nn, bool sw_fallback,
 			   void *code, dma_addr_t dma_addr,
 			   unsigned int code_sz, unsigned int n_instr,
 			   bool dense_mode)
@@ -107,7 +105,7 @@ nfp_net_bpf_load_and_start(struct nfp_net *nn, u32 tc_flags,
 	u64 bpf_addr = dma_addr;
 	int err;
 
-	nn->dp.bpf_offload_skip_sw = !!(tc_flags & TCA_CLS_FLAGS_SKIP_SW);
+	nn->dp.bpf_offload_skip_sw = !sw_fallback;
 
 	if (dense_mode)
 		bpf_addr |= NFP_NET_CFG_BPF_CFG_8CTX;
@@ -142,7 +140,8 @@ static int nfp_net_bpf_stop(struct nfp_net *nn)
 	return nfp_net_reconfig(nn, NFP_NET_CFG_UPDATE_GEN);
 }
 
-int nfp_net_bpf_offload(struct nfp_net *nn, struct tc_cls_bpf_offload *cls_bpf)
+int nfp_net_bpf_offload(struct nfp_net *nn, struct bpf_prog *prog,
+			bool old_prog, bool sw_fallback)
 {
 	struct nfp_bpf_result res;
 	dma_addr_t dma_addr;
@@ -150,49 +149,36 @@ int nfp_net_bpf_offload(struct nfp_net *nn, struct tc_cls_bpf_offload *cls_bpf)
 	void *code;
 	int err;
 
+	/* There is nothing stopping us from implementing seamless
+	 * replace but the simple method of loading I adopted in
+	 * the firmware does not handle atomic replace (i.e. we have to
+	 * stop the BPF offload and re-enable it).  Leaking-in a few
+	 * frames which didn't have BPF applied in the hardware should
+	 * be fine if software fallback is available, though.
+	 */
+	if (prog && old_prog && nn->dp.bpf_offload_skip_sw)
+		return -EBUSY;
+
+	/* Something else is loaded, different program type? */
+	if (!old_prog && nn->dp.ctrl & NFP_NET_CFG_CTRL_BPF)
+		return -EBUSY;
+
 	max_instr = nn_readw(nn, NFP_NET_CFG_BPF_MAX_LEN);
+	code = NULL;
 
-	switch (cls_bpf->command) {
-	case TC_CLSBPF_REPLACE:
-		/* There is nothing stopping us from implementing seamless
-		 * replace but the simple method of loading I adopted in
-		 * the firmware does not handle atomic replace (i.e. we have to
-		 * stop the BPF offload and re-enable it).  Leaking-in a few
-		 * frames which didn't have BPF applied in the hardware should
-		 * be fine if software fallback is available, though.
-		 */
-		if (nn->dp.bpf_offload_skip_sw)
-			return -EBUSY;
-
-		err = nfp_net_bpf_offload_prepare(nn, cls_bpf, &res, &code,
+	if (prog) {
+		err = nfp_net_bpf_offload_prepare(nn, prog, &res, &code,
 						  &dma_addr, max_instr);
 		if (err)
 			return err;
+	}
 
+	if (old_prog)
 		nfp_net_bpf_stop(nn);
-		nfp_net_bpf_load_and_start(nn, cls_bpf->gen_flags, code,
-					   dma_addr, max_instr * sizeof(u64),
-					   res.n_instr, res.dense_mode);
-		return 0;
-
-	case TC_CLSBPF_ADD:
-		if (nn->dp.ctrl & NFP_NET_CFG_CTRL_BPF)
-			return -EBUSY;
 
-		err = nfp_net_bpf_offload_prepare(nn, cls_bpf, &res, &code,
-						  &dma_addr, max_instr);
-		if (err)
-			return err;
-
-		nfp_net_bpf_load_and_start(nn, cls_bpf->gen_flags, code,
+	if (prog)
+		nfp_net_bpf_load_and_start(nn, sw_fallback, code,
 					   dma_addr, max_instr * sizeof(u64),
 					   res.n_instr, res.dense_mode);
-		return 0;
-
-	case TC_CLSBPF_DESTROY:
-		return nfp_net_bpf_stop(nn);
-
-	default:
-		return -EOPNOTSUPP;
-	}
+	return 0;
 }
-- 
2.14.1
