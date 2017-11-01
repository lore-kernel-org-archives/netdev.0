From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [RFC 10/12] nfp: bpf: remove the register renumbering leftovers
Date: Tue, 31 Oct 2017 18:52:15 -0700
Message-ID: <20171101015217.10666-11-jakub.kicinski@netronome.com>
References: <20171101015217.10666-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, alexei.starovoitov@gmail.com,
        daniel@iogearbox.net, bblanco@gmail.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:43885 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932937AbdKABxI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 21:53:08 -0400
Received: by mail-pg0-f67.google.com with SMTP id s75so811169pgs.0
        for <netdev@vger.kernel.org>; Tue, 31 Oct 2017 18:53:08 -0700 (PDT)
In-Reply-To: <20171101015217.10666-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The register renumbering was removed and will not be coming back
in its old, naive form, given that it would be fundamentally
incompatible with calling functions.  Remove the leftovers.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Quentin Monnet <quentin.monnet@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/bpf/jit.c     | 4 ----
 drivers/net/ethernet/netronome/nfp/bpf/main.h    | 6 ------
 drivers/net/ethernet/netronome/nfp/bpf/offload.c | 7 ++-----
 3 files changed, 2 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/bpf/jit.c b/drivers/net/ethernet/netronome/nfp/bpf/jit.c
index 35c5ca92d3ad..64e21d05e8a1 100644
--- a/drivers/net/ethernet/netronome/nfp/bpf/jit.c
+++ b/drivers/net/ethernet/netronome/nfp/bpf/jit.c
@@ -2290,9 +2290,6 @@ nfp_bpf_jit(struct bpf_prog *filter, void *prog_mem,
 	if (ret)
 		goto out;
 
-	nfp_prog->num_regs = MAX_BPF_REG;
-	nfp_prog->regs_per_thread = 32;
-
 	nfp_prog->prog = prog_mem;
 	nfp_prog->__prog_alloc_len = prog_sz;
 
@@ -2307,7 +2304,6 @@ nfp_bpf_jit(struct bpf_prog *filter, void *prog_mem,
 	ret = nfp_bpf_ustore_calc(nfp_prog, (__force __le64 *)prog_mem);
 
 	res->n_instr = nfp_prog->prog_len;
-	res->dense_mode = false;
 out:
 	nfp_prog_free(nfp_prog);
 
diff --git a/drivers/net/ethernet/netronome/nfp/bpf/main.h b/drivers/net/ethernet/netronome/nfp/bpf/main.h
index 165c49b81c22..a92391364450 100644
--- a/drivers/net/ethernet/netronome/nfp/bpf/main.h
+++ b/drivers/net/ethernet/netronome/nfp/bpf/main.h
@@ -141,8 +141,6 @@ static inline u8 mbpf_mode(const struct nfp_insn_meta *meta)
  * @prog_len: number of valid instructions in @prog array
  * @__prog_alloc_len: alloc size of @prog array
  * @type: BPF program type
- * @num_regs: number of registers used by this program
- * @regs_per_thread: number of basic registers allocated per thread
  * @start_off: address of the first instruction in the memory
  * @tgt_out: jump target for normal exit
  * @tgt_abort: jump target for abort (e.g. access outside of packet buffer)
@@ -159,9 +157,6 @@ struct nfp_prog {
 
 	enum bpf_prog_type type;
 
-	unsigned int num_regs;
-	unsigned int regs_per_thread;
-
 	unsigned int start_off;
 	unsigned int tgt_out;
 	unsigned int tgt_abort;
@@ -177,7 +172,6 @@ struct nfp_prog {
 
 struct nfp_bpf_result {
 	unsigned int n_instr;
-	bool dense_mode;
 };
 
 int
diff --git a/drivers/net/ethernet/netronome/nfp/bpf/offload.c b/drivers/net/ethernet/netronome/nfp/bpf/offload.c
index cf000314410b..29c96714dd76 100644
--- a/drivers/net/ethernet/netronome/nfp/bpf/offload.c
+++ b/drivers/net/ethernet/netronome/nfp/bpf/offload.c
@@ -98,14 +98,11 @@ nfp_net_bpf_offload_prepare(struct nfp_net *nn, struct bpf_prog *prog,
 
 static void
 nfp_net_bpf_load(struct nfp_net *nn, void *code, dma_addr_t dma_addr,
-		 unsigned int code_sz, unsigned int n_instr, bool dense_mode)
+		 unsigned int code_sz, unsigned int n_instr)
 {
 	u64 bpf_addr = dma_addr;
 	int err;
 
-	if (dense_mode)
-		bpf_addr |= NFP_NET_CFG_BPF_CFG_8CTX;
-
 	nn_writew(nn, NFP_NET_CFG_BPF_SIZE, n_instr);
 	nn_writeq(nn, NFP_NET_CFG_BPF_ADDR, bpf_addr);
 
@@ -172,7 +169,7 @@ int nfp_net_bpf_offload(struct nfp_net *nn, struct bpf_prog *prog,
 		return err;
 
 	nfp_net_bpf_load(nn, code, dma_addr, max_instr * sizeof(u64),
-			 res.n_instr, res.dense_mode);
+			 res.n_instr);
 	if (!old_prog)
 		nfp_net_bpf_start(nn);
 	return 0;
-- 
2.14.1
