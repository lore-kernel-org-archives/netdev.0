From: Edward Cree via iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
Subject: [PATCH v3 net-next 03/12] nfp: change bpf verifier
 hooks to match new verifier data structures
Date: Tue, 27 Jun 2017 13:57:34 +0100
Message-ID: <b8418d35-7d3f-1ee3-2bfa-cdf87e5b7c95@solarflare.com>
References: <adc11342-737f-4e06-bce3-f0a92b5594a5@solarflare.com>
Reply-To: Edward Cree <ecree-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: oss-drivers-wFxRvT7yatFl57MIdRCFDg@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Alexei Starovoitov <ast-b10kYP2dOMg@public.gmane.org>, Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
	Jakub Kicinski <jakub.kicinski-wFxRvT7yatFl57MIdRCFDg@public.gmane.org>
Return-path: <iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
In-Reply-To: <adc11342-737f-4e06-bce3-f0a92b5594a5-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
List-Unsubscribe: <https://lists.iovisor.org/mailman/options/iovisor-dev>,
	<mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.iovisor.org/pipermail/iovisor-dev/>
List-Post: <mailto:iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
List-Help: <mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=help>
List-Subscribe: <https://lists.iovisor.org/mailman/listinfo/iovisor-dev>,
	<mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=subscribe>
Sender: iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org
Errors-To: iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Edward Cree <ecree-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
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
