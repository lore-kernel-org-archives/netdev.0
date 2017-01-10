From: Andy Lutomirski <luto@kernel.org>
Subject: [PATCH v2 4/8] bpf: Use SHA256 instead of SHA1 for bpf digests
Date: Tue, 10 Jan 2017 15:24:42 -0800
Message-ID: <d6560ca273fe76969a7d9b31c5465ef614835f5d.1484090585.git.luto@kernel.org>
References: <cover.1484090585.git.luto@kernel.org>
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Eric Dumazet <edumazet@google.com>,
        Eric Biggers <ebiggers3@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        "David S. Miller" <davem@davemloft.net>,
        Andy Lutomirski <luto@kernel.org>,
        Alexei Starovoitov <ast@kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>,
        Netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Linux Crypto Mailing List <linux-crypto@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1484090585.git.luto@kernel.org>
In-Reply-To: <cover.1484090585.git.luto@kernel.org>
References: <cover.1484090585.git.luto@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

SHA1 is considered obsolete.  It is no longer considered to be
collision resistant and, in general, it should not be used for new
applications.  Change the new-in-4.10 BPF digest to SHA-256.  This
means that potential future applications of the digest that need
collision resistance will be able to use the BPF digest.  Applications
that just want a short identifier for a BPF program are welcome to
truncate the digest.

This is also a cleanup IMO -- the new sha256_*_direct() API is much
nicer than the old SHA1 library helpers.  It will also enable
incremental hashing so the BPF code can avoid calling vmalloc().

I moved the digest field to keep all of the bpf program metadata in
the same cache line.

Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: Alexei Starovoitov <ast@kernel.org>
Signed-off-by: Andy Lutomirski <luto@kernel.org>
---
 include/linux/filter.h | 11 +++--------
 init/Kconfig           |  1 +
 kernel/bpf/core.c      | 42 ++++++++----------------------------------
 3 files changed, 12 insertions(+), 42 deletions(-)

diff --git a/include/linux/filter.h b/include/linux/filter.h
index 702314253797..23df2574e30c 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -14,7 +14,8 @@
 #include <linux/workqueue.h>
 #include <linux/sched.h>
 #include <linux/capability.h>
-#include <linux/cryptohash.h>
+
+#include <crypto/sha.h>
 
 #include <net/sch_generic.h>
 
@@ -408,11 +409,11 @@ struct bpf_prog {
 	kmemcheck_bitfield_end(meta);
 	enum bpf_prog_type	type;		/* Type of BPF program */
 	u32			len;		/* Number of filter blocks */
-	u32			digest[SHA_DIGEST_WORDS]; /* Program digest */
 	struct bpf_prog_aux	*aux;		/* Auxiliary fields */
 	struct sock_fprog_kern	*orig_prog;	/* Original BPF program */
 	unsigned int		(*bpf_func)(const void *ctx,
 					    const struct bpf_insn *insn);
+	u8			digest[SHA256_DIGEST_SIZE]; /* Program digest */
 	/* Instructions for interpreter */
 	union {
 		struct sock_filter	insns[0];
@@ -519,12 +520,6 @@ static inline u32 bpf_prog_insn_size(const struct bpf_prog *prog)
 	return prog->len * sizeof(struct bpf_insn);
 }
 
-static inline u32 bpf_prog_digest_scratch_size(const struct bpf_prog *prog)
-{
-	return round_up(bpf_prog_insn_size(prog) +
-			sizeof(__be64) + 1, SHA_MESSAGE_BYTES);
-}
-
 static inline unsigned int bpf_prog_size(unsigned int proglen)
 {
 	return max(sizeof(struct bpf_prog),
diff --git a/init/Kconfig b/init/Kconfig
index 223b734abccd..f1ea6d023f8c 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -1389,6 +1389,7 @@ config HAVE_PCSPKR_PLATFORM
 # interpreter that classic socket filters depend on
 config BPF
 	bool
+	select CRYPTO_SHA256_DIRECT
 
 menuconfig EXPERT
 	bool "Configure standard kernel features (expert users)"
diff --git a/kernel/bpf/core.c b/kernel/bpf/core.c
index 1eb4f1303756..668b92f6ab58 100644
--- a/kernel/bpf/core.c
+++ b/kernel/bpf/core.c
@@ -148,22 +148,18 @@ void __bpf_prog_free(struct bpf_prog *fp)
 
 int bpf_prog_calc_digest(struct bpf_prog *fp)
 {
-	const u32 bits_offset = SHA_MESSAGE_BYTES - sizeof(__be64);
-	u32 raw_size = bpf_prog_digest_scratch_size(fp);
-	u32 ws[SHA_WORKSPACE_WORDS];
-	u32 i, bsize, psize, blocks;
+	struct sha256_state sha;
+	u32 i, psize;
 	struct bpf_insn *dst;
 	bool was_ld_map;
-	u8 *raw, *todo;
-	__be32 *result;
-	__be64 *bits;
+	u8 *raw;
 
-	raw = vmalloc(raw_size);
+	psize = bpf_prog_insn_size(fp);
+	raw = vmalloc(psize);
 	if (!raw)
 		return -ENOMEM;
 
-	sha_init(fp->digest);
-	memset(ws, 0, sizeof(ws));
+	sha256_init_direct(&sha);
 
 	/* We need to take out the map fd for the digest calculation
 	 * since they are unstable from user space side.
@@ -188,30 +184,8 @@ int bpf_prog_calc_digest(struct bpf_prog *fp)
 		}
 	}
 
-	psize = bpf_prog_insn_size(fp);
-	memset(&raw[psize], 0, raw_size - psize);
-	raw[psize++] = 0x80;
-
-	bsize  = round_up(psize, SHA_MESSAGE_BYTES);
-	blocks = bsize / SHA_MESSAGE_BYTES;
-	todo   = raw;
-	if (bsize - psize >= sizeof(__be64)) {
-		bits = (__be64 *)(todo + bsize - sizeof(__be64));
-	} else {
-		bits = (__be64 *)(todo + bsize + bits_offset);
-		blocks++;
-	}
-	*bits = cpu_to_be64((psize - 1) << 3);
-
-	while (blocks--) {
-		sha_transform(fp->digest, todo, ws);
-		todo += SHA_MESSAGE_BYTES;
-	}
-
-	result = (__force __be32 *)fp->digest;
-	for (i = 0; i < SHA_DIGEST_WORDS; i++)
-		result[i] = cpu_to_be32(fp->digest[i]);
-
+	sha256_update_direct(&sha, raw, psize);
+	sha256_final_direct(&sha, fp->digest);
 	vfree(raw);
 	return 0;
 }
-- 
2.9.3
