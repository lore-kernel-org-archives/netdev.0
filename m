From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 2/4] bpf: provide helper that indicates eBPF was migrated
Date: Thu, 30 Jul 2015 12:42:47 +0200
Message-ID: <11e0f83fcc330f6f7bd0d427dc4c81b2a699b498.1438250937.git.daniel@iogearbox.net>
References: <cover.1438250937.git.daniel@iogearbox.net>
Cc: ast@plumgrid.com, holzheu@linux.vnet.ibm.com,
	netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:52554 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754819AbbG3Kmx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2015 06:42:53 -0400
In-Reply-To: <cover.1438250937.git.daniel@iogearbox.net>
In-Reply-To: <cover.1438250937.git.daniel@iogearbox.net>
References: <cover.1438250937.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

During recent discussions we had with Michael, we found that it would
be useful to have an indicator that tells the JIT that an eBPF program
had been migrated from classic instructions into eBPF instructions, as
only in that case A and X need to be cleared in the prologue. Such eBPF
programs do not set a particular type, but all have BPF_PROG_TYPE_UNSPEC.
Thus, introduce a small helper for cde66c2d88da ("s390/bpf: Only clear
A and X for converted BPF programs") and possibly others in future.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Cc: Michael Holzheu <holzheu@linux.vnet.ibm.com>
---
 arch/s390/net/bpf_jit_comp.c |  2 +-
 include/linux/filter.h       | 10 ++++++++++
 2 files changed, 11 insertions(+), 1 deletion(-)

diff --git a/arch/s390/net/bpf_jit_comp.c b/arch/s390/net/bpf_jit_comp.c
index bbbac6d..9f4bbc0 100644
--- a/arch/s390/net/bpf_jit_comp.c
+++ b/arch/s390/net/bpf_jit_comp.c
@@ -1245,7 +1245,7 @@ static int bpf_jit_prog(struct bpf_jit *jit, struct bpf_prog *fp)
 	jit->lit = jit->lit_start;
 	jit->prg = 0;
 
-	bpf_jit_prologue(jit, fp->type == BPF_PROG_TYPE_UNSPEC);
+	bpf_jit_prologue(jit, bpf_prog_was_classic(fp));
 	for (i = 0; i < fp->len; i += insn_count) {
 		insn_count = bpf_jit_insn(jit, fp, i);
 		if (insn_count < 0)
diff --git a/include/linux/filter.h b/include/linux/filter.h
index 69d0055..6b02549 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -354,6 +354,16 @@ static inline unsigned int bpf_prog_size(unsigned int proglen)
 		   offsetof(struct bpf_prog, insns[proglen]));
 }
 
+static inline bool bpf_prog_was_classic(const struct bpf_prog *prog)
+{
+	/* When classic BPF programs have been loaded and the arch
+	 * does not have a classic BPF JIT (anymore), they have been
+	 * converted via bpf_migrate_filter() to eBPF and thus always
+	 * have an unspec program type.
+	 */
+	return prog->type == BPF_PROG_TYPE_UNSPEC;
+}
+
 #define bpf_classic_proglen(fprog) (fprog->len * sizeof(fprog->filter[0]))
 
 #ifdef CONFIG_DEBUG_SET_MODULE_RONX
-- 
1.9.3
