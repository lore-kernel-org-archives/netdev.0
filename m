From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [RFC 09/12] nfp: bpf: require seamless reload for program replace
Date: Tue, 31 Oct 2017 18:52:14 -0700
Message-ID: <20171101015217.10666-10-jakub.kicinski@netronome.com>
References: <20171101015217.10666-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, alexei.starovoitov@gmail.com,
        daniel@iogearbox.net, bblanco@gmail.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:55021 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932935AbdKABxH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 21:53:07 -0400
Received: by mail-pf0-f196.google.com with SMTP id n89so718754pfk.11
        for <netdev@vger.kernel.org>; Tue, 31 Oct 2017 18:53:07 -0700 (PDT)
In-Reply-To: <20171101015217.10666-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Firmware supports live replacement of programs for quite some
time now.  Remove the software-fallback related logic and
depend on it for program replace.  Seamless reload is required
anyway if maps are present.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Quentin Monnet <quentin.monnet@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/bpf/main.c    | 11 ++---
 drivers/net/ethernet/netronome/nfp/bpf/main.h    |  2 +-
 drivers/net/ethernet/netronome/nfp/bpf/offload.c | 61 +++++++++++-------------
 drivers/net/ethernet/netronome/nfp/nfp_net.h     |  2 -
 4 files changed, 33 insertions(+), 43 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/bpf/main.c b/drivers/net/ethernet/netronome/nfp/bpf/main.c
index c788def0c457..789cdde229d2 100644
--- a/drivers/net/ethernet/netronome/nfp/bpf/main.c
+++ b/drivers/net/ethernet/netronome/nfp/bpf/main.c
@@ -67,7 +67,7 @@ nfp_bpf_xdp_offload(struct nfp_app *app, struct nfp_net *nn,
 	if (prog && running && !nn->dp.bpf_offload_xdp)
 		return -EBUSY;
 
-	ret = nfp_net_bpf_offload(nn, prog, running, true);
+	ret = nfp_net_bpf_offload(nn, prog, running);
 	/* Stop offload if replace not possible */
 	if (ret && prog)
 		nfp_bpf_xdp_offload(app, nn, NULL);
@@ -92,7 +92,6 @@ static int nfp_bpf_setup_tc_block_cb(enum tc_setup_type type,
 {
 	struct tc_cls_bpf_offload *cls_bpf = type_data;
 	struct nfp_net *nn = cb_priv;
-	bool skip_sw;
 
 	if (type != TC_SETUP_CLSBPF ||
 	    !tc_can_offload(nn->dp.netdev) ||
@@ -108,15 +107,13 @@ static int nfp_bpf_setup_tc_block_cb(enum tc_setup_type type,
 	    tcf_exts_has_actions(cls_bpf->exts))
 		return -EOPNOTSUPP;
 
-	skip_sw = !!(cls_bpf->gen_flags & TCA_CLS_FLAGS_SKIP_SW);
-
 	switch (cls_bpf->command) {
 	case TC_CLSBPF_REPLACE:
-		return nfp_net_bpf_offload(nn, cls_bpf->prog, true, !skip_sw);
+		return nfp_net_bpf_offload(nn, cls_bpf->prog, true);
 	case TC_CLSBPF_ADD:
-		return nfp_net_bpf_offload(nn, cls_bpf->prog, false, !skip_sw);
+		return nfp_net_bpf_offload(nn, cls_bpf->prog, false);
 	case TC_CLSBPF_DESTROY:
-		return nfp_net_bpf_offload(nn, NULL, true, !skip_sw);
+		return nfp_net_bpf_offload(nn, NULL, true);
 	default:
 		return -EOPNOTSUPP;
 	}
diff --git a/drivers/net/ethernet/netronome/nfp/bpf/main.h b/drivers/net/ethernet/netronome/nfp/bpf/main.h
index 15ff341d35b1..165c49b81c22 100644
--- a/drivers/net/ethernet/netronome/nfp/bpf/main.h
+++ b/drivers/net/ethernet/netronome/nfp/bpf/main.h
@@ -190,6 +190,6 @@ int nfp_prog_verify(struct nfp_prog *nfp_prog, struct bpf_prog *prog);
 struct nfp_net;
 
 int nfp_net_bpf_offload(struct nfp_net *nn, struct bpf_prog *prog,
-			bool old_prog, bool sw_fallback);
+			bool old_prog);
 
 #endif
diff --git a/drivers/net/ethernet/netronome/nfp/bpf/offload.c b/drivers/net/ethernet/netronome/nfp/bpf/offload.c
index de689919c58f..cf000314410b 100644
--- a/drivers/net/ethernet/netronome/nfp/bpf/offload.c
+++ b/drivers/net/ethernet/netronome/nfp/bpf/offload.c
@@ -97,16 +97,12 @@ nfp_net_bpf_offload_prepare(struct nfp_net *nn, struct bpf_prog *prog,
 }
 
 static void
-nfp_net_bpf_load_and_start(struct nfp_net *nn, bool sw_fallback,
-			   void *code, dma_addr_t dma_addr,
-			   unsigned int code_sz, unsigned int n_instr,
-			   bool dense_mode)
+nfp_net_bpf_load(struct nfp_net *nn, void *code, dma_addr_t dma_addr,
+		 unsigned int code_sz, unsigned int n_instr, bool dense_mode)
 {
 	u64 bpf_addr = dma_addr;
 	int err;
 
-	nn->dp.bpf_offload_skip_sw = !sw_fallback;
-
 	if (dense_mode)
 		bpf_addr |= NFP_NET_CFG_BPF_CFG_8CTX;
 
@@ -118,14 +114,19 @@ nfp_net_bpf_load_and_start(struct nfp_net *nn, bool sw_fallback,
 	if (err)
 		nn_err(nn, "FW command error while loading BPF: %d\n", err);
 
+	dma_free_coherent(nn->dp.dev, code_sz, code, dma_addr);
+}
+
+static void nfp_net_bpf_start(struct nfp_net *nn)
+{
+	int err;
+
 	/* Enable passing packets through BPF function */
 	nn->dp.ctrl |= NFP_NET_CFG_CTRL_BPF;
 	nn_writel(nn, NFP_NET_CFG_CTRL, nn->dp.ctrl);
 	err = nfp_net_reconfig(nn, NFP_NET_CFG_UPDATE_GEN);
 	if (err)
 		nn_err(nn, "FW command error while enabling BPF: %d\n", err);
-
-	dma_free_coherent(nn->dp.dev, code_sz, code, dma_addr);
 }
 
 static int nfp_net_bpf_stop(struct nfp_net *nn)
@@ -135,13 +136,12 @@ static int nfp_net_bpf_stop(struct nfp_net *nn)
 
 	nn->dp.ctrl &= ~NFP_NET_CFG_CTRL_BPF;
 	nn_writel(nn, NFP_NET_CFG_CTRL, nn->dp.ctrl);
-	nn->dp.bpf_offload_skip_sw = 0;
 
 	return nfp_net_reconfig(nn, NFP_NET_CFG_UPDATE_GEN);
 }
 
 int nfp_net_bpf_offload(struct nfp_net *nn, struct bpf_prog *prog,
-			bool old_prog, bool sw_fallback)
+			bool old_prog)
 {
 	struct nfp_bpf_result res;
 	dma_addr_t dma_addr;
@@ -149,36 +149,31 @@ int nfp_net_bpf_offload(struct nfp_net *nn, struct bpf_prog *prog,
 	void *code;
 	int err;
 
-	/* There is nothing stopping us from implementing seamless
-	 * replace but the simple method of loading I adopted in
-	 * the firmware does not handle atomic replace (i.e. we have to
-	 * stop the BPF offload and re-enable it).  Leaking-in a few
-	 * frames which didn't have BPF applied in the hardware should
-	 * be fine if software fallback is available, though.
-	 */
-	if (prog && old_prog && nn->dp.bpf_offload_skip_sw)
-		return -EBUSY;
+	if (prog && old_prog) {
+		u8 cap;
+
+		cap = nn_readb(nn, NFP_NET_CFG_BPF_CAP);
+		if (!(cap & NFP_NET_BPF_CAP_RELO))
+			return -EBUSY;
+	}
 
 	/* Something else is loaded, different program type? */
 	if (!old_prog && nn->dp.ctrl & NFP_NET_CFG_CTRL_BPF)
 		return -EBUSY;
 
-	max_instr = nn_readw(nn, NFP_NET_CFG_BPF_MAX_LEN);
-	code = NULL;
+	if (old_prog && !prog)
+		return nfp_net_bpf_stop(nn);
 
-	if (prog) {
-		err = nfp_net_bpf_offload_prepare(nn, prog, &res, &code,
-						  &dma_addr, max_instr);
-		if (err)
-			return err;
-	}
+	max_instr = nn_readw(nn, NFP_NET_CFG_BPF_MAX_LEN);
 
-	if (old_prog)
-		nfp_net_bpf_stop(nn);
+	err = nfp_net_bpf_offload_prepare(nn, prog, &res, &code, &dma_addr,
+					  max_instr);
+	if (err)
+		return err;
 
-	if (prog)
-		nfp_net_bpf_load_and_start(nn, sw_fallback, code,
-					   dma_addr, max_instr * sizeof(u64),
-					   res.n_instr, res.dense_mode);
+	nfp_net_bpf_load(nn, code, dma_addr, max_instr * sizeof(u64),
+			 res.n_instr, res.dense_mode);
+	if (!old_prog)
+		nfp_net_bpf_start(nn);
 	return 0;
 }
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net.h b/drivers/net/ethernet/netronome/nfp/nfp_net.h
index 3d411f0d15b6..7f9857c276b1 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net.h
@@ -476,7 +476,6 @@ struct nfp_stat_pair {
  * @dev:		Backpointer to struct device
  * @netdev:		Backpointer to net_device structure
  * @is_vf:		Is the driver attached to a VF?
- * @bpf_offload_skip_sw:  Offloaded BPF program will not be rerun by cls_bpf
  * @bpf_offload_xdp:	Offloaded BPF program is XDP
  * @chained_metadata_format:  Firemware will use new metadata format
  * @rx_dma_dir:		Mapping direction for RX buffers
@@ -502,7 +501,6 @@ struct nfp_net_dp {
 	struct net_device *netdev;
 
 	u8 is_vf:1;
-	u8 bpf_offload_skip_sw:1;
 	u8 bpf_offload_xdp:1;
 	u8 chained_metadata_format:1;
 
-- 
2.14.1
