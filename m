From: Andy Lutomirski <luto@kernel.org>
Subject: [RFC PATCH 4.10 3/6] bpf: Use SHA256 instead of SHA1 for bpf digests
Date: Fri, 23 Dec 2016 18:22:29 -0800
Message-ID: <bbfd69226fd74391045bafc695bba9a46cacca85.1482545792.git.luto@kernel.org>
References: <cover.1482545792.git.luto@kernel.org>
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
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <cover.1482545792.git.luto@kernel.org>
In-Reply-To: <cover.1482545792.git.luto@kernel.org>
References: <cover.1482545792.git.luto@kernel.org>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

BPF digests are intended to be used to avoid reloading programs that
are already loaded.  For use cases (CRIU?) where untrusted programs
are involved, intentional hash collisions could cause the wrong BPF
program to execute.  Additionally, if BPF digests are ever used
in-kernel to skip verification, a hash collision could give privilege
escalation directly.

SHA1 is no longer considered adequately collision-resistant (see, for
example, all the major browsers dropping support for SHA1
certificates).  Use SHA256 instead.

I moved the digest field to keep all of the bpf program metadata in
the same cache line.

Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: Alexei Starovoitov <ast@kernel.org>
Signed-off-by: Andy Lutomirski <luto@kernel.org>
---
 include/linux/filter.h | 11 +++--------
 init/Kconfig           |  1 +
 kernel/bpf/core.c      | 41 +++++++----------------------------------
 3 files changed, 11 insertions(+), 42 deletions(-)

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
index 223b734abccd..5a4e2d99cc38 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -1634,6 +1634,7 @@ config BPF_SYSCALL
 	bool "Enable bpf() system call"
 	select ANON_INODES
 	select BPF
+	select CRYPTO_SHA256_LIB
 	default n
 	help
 	  Enable the bpf() system call that allows to manipulate eBPF
diff --git a/kernel/bpf/core.c b/kernel/bpf/core.c
index 1eb4f1303756..911993863799 100644
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
+	sha256_init(&sha);
 
 	/* We need to take out the map fd for the digest calculation
 	 * since they are unstable from user space side.
@@ -188,30 +184,7 @@ int bpf_prog_calc_digest(struct bpf_prog *fp)
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
+	sha256_finup(&sha, raw, psize, fp->digest);
 	vfree(raw);
 	return 0;
 }
-- 
2.9.3
