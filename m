From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net 2/3] bpf, verifier: fix rejection of unaligned access checks for map_value_adj
Date: Fri, 31 Mar 2017 02:24:03 +0200
Message-ID: <57e1266ac8edacc48087923d624fff6d750e053e.1490918592.git.daniel@iogearbox.net>
References: <cover.1490918592.git.daniel@iogearbox.net>
Cc: netdev@vger.kernel.org, ast@fb.com, jbacik@fb.com, kafai@fb.com,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:46184 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933350AbdCaAYS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 30 Mar 2017 20:24:18 -0400
In-Reply-To: <cover.1490918592.git.daniel@iogearbox.net>
In-Reply-To: <cover.1490918592.git.daniel@iogearbox.net>
References: <cover.1490918592.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, the verifier doesn't reject unaligned access for map_value_adj
register types. Commit 484611357c19 ("bpf: allow access into map value
arrays") added logic to check_ptr_alignment() extending it from PTR_TO_PACKET
to also PTR_TO_MAP_VALUE_ADJ, but for PTR_TO_MAP_VALUE_ADJ no enforcement
is in place, because reg->id for PTR_TO_MAP_VALUE_ADJ reg types is never
non-zero, meaning, we can cause BPF_H/_W/_DW-based unaligned access for
architectures not supporting efficient unaligned access, and thus worst
case could raise exceptions on some archs that are unable to correct the
unaligned access or perform a different memory access to the actual
requested one and such.

i) Unaligned load with !CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS
   on r0 (map_value_adj):

   0: (bf) r2 = r10
   1: (07) r2 += -8
   2: (7a) *(u64 *)(r2 +0) = 0
   3: (18) r1 = 0x42533a00
   5: (85) call bpf_map_lookup_elem#1
   6: (15) if r0 == 0x0 goto pc+11
    R0=map_value(ks=8,vs=48,id=0),min_value=0,max_value=0 R10=fp
   7: (61) r1 = *(u32 *)(r0 +0)
   8: (35) if r1 >= 0xb goto pc+9
    R0=map_value(ks=8,vs=48,id=0),min_value=0,max_value=0 R1=inv,min_value=0,max_value=10 R10=fp
   9: (07) r0 += 3
  10: (79) r7 = *(u64 *)(r0 +0)
    R0=map_value_adj(ks=8,vs=48,id=0),min_value=3,max_value=3 R1=inv,min_value=0,max_value=10 R10=fp
  11: (79) r7 = *(u64 *)(r0 +2)
    R0=map_value_adj(ks=8,vs=48,id=0),min_value=3,max_value=3 R1=inv,min_value=0,max_value=10 R7=inv R10=fp
  [...]

ii) Unaligned store with !CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS
    on r0 (map_value_adj):

   0: (bf) r2 = r10
   1: (07) r2 += -8
   2: (7a) *(u64 *)(r2 +0) = 0
   3: (18) r1 = 0x4df16a00
   5: (85) call bpf_map_lookup_elem#1
   6: (15) if r0 == 0x0 goto pc+19
    R0=map_value(ks=8,vs=48,id=0),min_value=0,max_value=0 R10=fp
   7: (07) r0 += 3
   8: (7a) *(u64 *)(r0 +0) = 42
    R0=map_value_adj(ks=8,vs=48,id=0),min_value=3,max_value=3 R10=fp
   9: (7a) *(u64 *)(r0 +2) = 43
    R0=map_value_adj(ks=8,vs=48,id=0),min_value=3,max_value=3 R10=fp
  10: (7a) *(u64 *)(r0 -2) = 44
    R0=map_value_adj(ks=8,vs=48,id=0),min_value=3,max_value=3 R10=fp
  [...]

For the PTR_TO_PACKET type, reg->id is initially zero when skb->data
was fetched, it later receives a reg->id from env->id_gen generator
once another register with UNKNOWN_VALUE type was added to it via
check_packet_ptr_add(). The purpose of this reg->id is twofold: i) it
is used in find_good_pkt_pointers() for setting the allowed access
range for regs with PTR_TO_PACKET of same id once verifier matched
on data/data_end tests, and ii) for check_ptr_alignment() to determine
that when not having efficient unaligned access and register with
UNKNOWN_VALUE was added to PTR_TO_PACKET, that we're only allowed
to access the content bytewise due to unknown unalignment. reg->id
was never intended for PTR_TO_MAP_VALUE{,_ADJ} types and thus is
always zero, the only marking is in PTR_TO_MAP_VALUE_OR_NULL that
was added after 484611357c19 via 57a09bf0a416 ("bpf: Detect identical
PTR_TO_MAP_VALUE_OR_NULL registers"). Above tests will fail for
non-root environment due to prohibited pointer arithmetic.

The fix splits register-type specific checks into their own helper
instead of keeping them combined, so we don't run into a similar
issue in future once we extend check_ptr_alignment() further and
forget to add reg->type checks for some of the checks.

Fixes: 484611357c19 ("bpf: allow access into map value arrays")
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Reviewed-by: Josef Bacik <jbacik@fb.com>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 kernel/bpf/verifier.c | 58 +++++++++++++++++++++++++++++++++------------------
 1 file changed, 38 insertions(+), 20 deletions(-)

diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 86dedde..a834068 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -765,38 +765,56 @@ static bool is_pointer_value(struct bpf_verifier_env *env, int regno)
 	}
 }
 
-static int check_ptr_alignment(struct bpf_verifier_env *env,
-			       struct bpf_reg_state *reg, int off, int size)
+static int check_pkt_ptr_alignment(const struct bpf_reg_state *reg,
+				   int off, int size)
 {
-	if (reg->type != PTR_TO_PACKET && reg->type != PTR_TO_MAP_VALUE_ADJ) {
-		if (off % size != 0) {
-			verbose("misaligned access off %d size %d\n",
-				off, size);
-			return -EACCES;
-		} else {
-			return 0;
-		}
-	}
-
-	if (IS_ENABLED(CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS))
-		/* misaligned access to packet is ok on x86,arm,arm64 */
-		return 0;
-
 	if (reg->id && size != 1) {
-		verbose("Unknown packet alignment. Only byte-sized access allowed\n");
+		verbose("Unknown alignment. Only byte-sized access allowed in packet access.\n");
 		return -EACCES;
 	}
 
 	/* skb->data is NET_IP_ALIGN-ed */
-	if (reg->type == PTR_TO_PACKET &&
-	    (NET_IP_ALIGN + reg->off + off) % size != 0) {
+	if ((NET_IP_ALIGN + reg->off + off) % size != 0) {
 		verbose("misaligned packet access off %d+%d+%d size %d\n",
 			NET_IP_ALIGN, reg->off, off, size);
 		return -EACCES;
 	}
+
 	return 0;
 }
 
+static int check_val_ptr_alignment(const struct bpf_reg_state *reg,
+				   int size)
+{
+	if (size != 1) {
+		verbose("Unknown alignment. Only byte-sized access allowed in value access.\n");
+		return -EACCES;
+	}
+
+	return 0;
+}
+
+static int check_ptr_alignment(const struct bpf_reg_state *reg,
+			       int off, int size)
+{
+	switch (reg->type) {
+	case PTR_TO_PACKET:
+		return IS_ENABLED(CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS) ? 0 :
+		       check_pkt_ptr_alignment(reg, off, size);
+	case PTR_TO_MAP_VALUE_ADJ:
+		return IS_ENABLED(CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS) ? 0 :
+		       check_val_ptr_alignment(reg, size);
+	default:
+		if (off % size != 0) {
+			verbose("misaligned access off %d size %d\n",
+				off, size);
+			return -EACCES;
+		}
+
+		return 0;
+	}
+}
+
 /* check whether memory at (regno + off) is accessible for t = (read | write)
  * if t==write, value_regno is a register which value is stored into memory
  * if t==read, value_regno is a register which will receive the value from memory
@@ -818,7 +836,7 @@ static int check_mem_access(struct bpf_verifier_env *env, u32 regno, int off,
 	if (size < 0)
 		return size;
 
-	err = check_ptr_alignment(env, reg, off, size);
+	err = check_ptr_alignment(reg, off, size);
 	if (err)
 		return err;
 
-- 
1.9.3
