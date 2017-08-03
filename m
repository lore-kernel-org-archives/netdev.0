From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH v4 net-next 02/13] nfp: change bpf verifier hooks to match new
 verifier data structures
Date: Thu, 3 Aug 2017 17:11:34 +0100
Message-ID: <3d69276f-9f16-0c1a-4596-5c909abe08fc@solarflare.com>
References: <22441d84-0a11-5c00-2d2a-25e7dbafa6c2@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        iovisor-dev <iovisor-dev@lists.iovisor.org>
To: <davem@davemloft.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <22441d84-0a11-5c00-2d2a-25e7dbafa6c2@solarflare.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 drivers/net/ethernet/netronome/nfp/bpf/verifier.c | 24 +++++++++++++----------
 kernel/bpf/tnum.c                                 |  1 +
 2 files changed, 15 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/bpf/verifier.c b/drivers/net/ethernet/netronome/nfp/bpf/verifier.c
index d696ba4..5b783a9 100644
--- a/drivers/net/ethernet/netronome/nfp/bpf/verifier.c
+++ b/drivers/net/ethernet/netronome/nfp/bpf/verifier.c
@@ -79,28 +79,32 @@ nfp_bpf_check_exit(struct nfp_prog *nfp_prog,
 		   const struct bpf_verifier_env *env)
 {
 	const struct bpf_reg_state *reg0 = &env->cur_state.regs[0];
+	u64 imm;
 
 	if (nfp_prog->act == NN_ACT_XDP)
 		return 0;
 
-	if (reg0->type != CONST_IMM) {
-		pr_info("unsupported exit state: %d, imm: %llx\n",
-			reg0->type, reg0->imm);
+	if (!(reg0->type == SCALAR_VALUE && tnum_is_const(reg0->var_off))) {
+		char tn_buf[48];
+
+		tnum_strn(tn_buf, sizeof(tn_buf), reg0->var_off);
+		pr_info("unsupported exit state: %d, var_off: %s\n",
+			reg0->type, tn_buf);
 		return -EINVAL;
 	}
 
-	if (nfp_prog->act != NN_ACT_DIRECT &&
-	    reg0->imm != 0 && (reg0->imm & ~0U) != ~0U) {
+	imm = reg0->var_off.value;
+	if (nfp_prog->act != NN_ACT_DIRECT && imm != 0 && (imm & ~0U) != ~0U) {
 		pr_info("unsupported exit state: %d, imm: %llx\n",
-			reg0->type, reg0->imm);
+			reg0->type, imm);
 		return -EINVAL;
 	}
 
-	if (nfp_prog->act == NN_ACT_DIRECT && reg0->imm <= TC_ACT_REDIRECT &&
-	    reg0->imm != TC_ACT_SHOT && reg0->imm != TC_ACT_STOLEN &&
-	    reg0->imm != TC_ACT_QUEUED) {
+	if (nfp_prog->act == NN_ACT_DIRECT && imm <= TC_ACT_REDIRECT &&
+	    imm != TC_ACT_SHOT && imm != TC_ACT_STOLEN &&
+	    imm != TC_ACT_QUEUED) {
 		pr_info("unsupported exit state: %d, imm: %llx\n",
-			reg0->type, reg0->imm);
+			reg0->type, imm);
 		return -EINVAL;
 	}
 
diff --git a/kernel/bpf/tnum.c b/kernel/bpf/tnum.c
index 803bd0d..92eeeb1 100644
--- a/kernel/bpf/tnum.c
+++ b/kernel/bpf/tnum.c
@@ -141,6 +141,7 @@ int tnum_strn(char *str, size_t size, struct tnum a)
 {
 	return snprintf(str, size, "(%#llx; %#llx)", a.value, a.mask);
 }
+EXPORT_SYMBOL_GPL(tnum_strn);
 
 int tnum_sbin(char *str, size_t size, struct tnum a)
 {
