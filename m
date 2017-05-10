From: David Miller <davem@davemloft.net>
Subject: Re: bpf pointer alignment validation
Date: Wed, 10 May 2017 12:45:46 -0400 (EDT)
Message-ID: <20170510.124546.210650328192684036.davem@davemloft.net>
References: <59133716.7060800@iogearbox.net>
        <20170510.115720.1396306489898364855.davem@davemloft.net>
        <59133E1E.8060208@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, ast@fb.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41792 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752894AbdEJQpu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 10 May 2017 12:45:50 -0400
In-Reply-To: <59133E1E.8060208@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Wed, 10 May 2017 18:21:50 +0200

> On 05/10/2017 05:57 PM, David Miller wrote:
>> From: Daniel Borkmann <daniel@iogearbox.net>
>> Date: Wed, 10 May 2017 17:51:50 +0200
>>
>>> Would probably be good nevertheless to have this as a flag for
>>> program loads, which gets then passed through to the verifier to
>>> explicitly enable strict alignment checks.
>>>
>>> Might certainly aide developing & testing programs on archs with
>>> efficient unaligned access and later actually running them on archs
>>> that don't have it. (And at minimum, it also helps for checking
>>> the test suite against the verifier.)
>>
>> Ok, I can implement this flag.
>>
>> The only question is where to put it?  An unused bit in the program
>> type? :-)
> 
> See for example 7f677633379b ("bpf: introduce BPF_F_ALLOW_OVERRIDE
> flag"). We can add a flags field to the prog loading part of union
> bpf_attr; we would need to make sure to update
> BPF_PROG_LOAD_LAST_FIELD
> to the new member, and to reject unknown flags, of course. Then the
> syscall will handle compat with older binaries just fine by design,
> the main bpf syscall code and CHECK_ATTR() macros will ensure this
> (backward compat, and to a limited degree also forward compat).

Thanks to both of you for guidance on how to do this properly.

Here is what I have right now, once things look good enough I'll split
it all out into a proper patch series:

1) Add alignment tracking.
2) Add "log_level > 1" per-insn state dumping
3) Add BPF_F_STRICT_ALIGNMENT
4) Add bpf_verify_program() to library
5) Add test_align to selftests

====================
Subject: [PATCH] BPF alignment framework

---
 include/linux/bpf_verifier.h             |   3 +
 include/uapi/linux/bpf.h                 |   8 +
 kernel/bpf/syscall.c                     |   5 +-
 kernel/bpf/verifier.c                    | 132 ++++++++--
 tools/include/uapi/linux/bpf.h           |  11 +-
 tools/lib/bpf/bpf.c                      |  22 ++
 tools/lib/bpf/bpf.h                      |   4 +
 tools/testing/selftests/bpf/Makefile     |   4 +-
 tools/testing/selftests/bpf/test_align.c | 417 +++++++++++++++++++++++++++++++
 9 files changed, 581 insertions(+), 25 deletions(-)
 create mode 100644 tools/testing/selftests/bpf/test_align.c

diff --git a/include/linux/bpf_verifier.h b/include/linux/bpf_verifier.h
index 5efb4db..7c6a519 100644
--- a/include/linux/bpf_verifier.h
+++ b/include/linux/bpf_verifier.h
@@ -40,6 +40,9 @@ struct bpf_reg_state {
 	 */
 	s64 min_value;
 	u64 max_value;
+	u32 min_align;
+	u32 aux_off;
+	u32 aux_off_align;
 };
 
 enum bpf_stack_slot_type {
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 945a1f5..94dfa9d 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -132,6 +132,13 @@ enum bpf_attach_type {
  */
 #define BPF_F_ALLOW_OVERRIDE	(1U << 0)
 
+/* If BPF_F_STRICT_ALIGNMENT is used in BPF_PROG_LOAD command, the
+ * verifier will perform strict alignment checking as if the kernel
+ * has been built with CONFIG_EFFICIENT_UNALIGNED_ACCESS not set,
+ * and NET_IP_ALIGN defined to 2.
+ */
+#define BPF_F_STRICT_ALIGNMENT	(1U << 0)
+
 #define BPF_PSEUDO_MAP_FD	1
 
 /* flags for BPF_MAP_UPDATE_ELEM command */
@@ -177,6 +184,7 @@ union bpf_attr {
 		__u32		log_size;	/* size of user buffer */
 		__aligned_u64	log_buf;	/* user supplied buffer */
 		__u32		kern_version;	/* checked when prog_type=kprobe */
+		__u32		prog_flags;
 	};
 
 	struct { /* anonymous struct used by BPF_OBJ_* commands */
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 13642c7..027053a 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -784,7 +784,7 @@ struct bpf_prog *bpf_prog_get_type(u32 ufd, enum bpf_prog_type type)
 EXPORT_SYMBOL_GPL(bpf_prog_get_type);
 
 /* last field in 'union bpf_attr' used by this command */
-#define	BPF_PROG_LOAD_LAST_FIELD kern_version
+#define	BPF_PROG_LOAD_LAST_FIELD prog_flags
 
 static int bpf_prog_load(union bpf_attr *attr)
 {
@@ -797,6 +797,9 @@ static int bpf_prog_load(union bpf_attr *attr)
 	if (CHECK_ATTR(BPF_PROG_LOAD))
 		return -EINVAL;
 
+	if (attr->prog_flags & ~BPF_F_STRICT_ALIGNMENT)
+		return -EINVAL;
+
 	/* copy eBPF program license from user space */
 	if (strncpy_from_user(license, u64_to_user_ptr(attr->license),
 			      sizeof(license) - 1) < 0)
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index c2ff608..87ecb4d 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -241,6 +241,12 @@ static void print_verifier_state(struct bpf_verifier_state *state)
 		if (reg->max_value != BPF_REGISTER_MAX_RANGE)
 			verbose(",max_value=%llu",
 				(unsigned long long)reg->max_value);
+		if (reg->min_align)
+			verbose(",min_align=%u", reg->min_align);
+		if (reg->aux_off)
+			verbose(",aux_off=%u", reg->aux_off);
+		if (reg->aux_off_align)
+			verbose(",aux_off_align=%u", reg->aux_off_align);
 	}
 	for (i = 0; i < MAX_BPF_STACK; i += BPF_REG_SIZE) {
 		if (state->stack_slot_type[i] == STACK_SPILL)
@@ -455,6 +461,9 @@ static void init_reg_state(struct bpf_reg_state *regs)
 		regs[i].imm = 0;
 		regs[i].min_value = BPF_REGISTER_MIN_RANGE;
 		regs[i].max_value = BPF_REGISTER_MAX_RANGE;
+		regs[i].min_align = 0;
+		regs[i].aux_off = 0;
+		regs[i].aux_off_align = 0;
 	}
 
 	/* frame pointer */
@@ -483,11 +492,17 @@ static void reset_reg_range_values(struct bpf_reg_state *regs, u32 regno)
 	regs[regno].max_value = BPF_REGISTER_MAX_RANGE;
 }
 
+static void reset_reg_align(struct bpf_reg_state *regs, u32 regno)
+{
+	regs[regno].min_align = 0;
+}
+
 static void mark_reg_unknown_value_and_range(struct bpf_reg_state *regs,
 					     u32 regno)
 {
 	mark_reg_unknown_value(regs, regno);
 	reset_reg_range_values(regs, regno);
+	reset_reg_align(regs, regno);
 }
 
 enum reg_arg_type {
@@ -768,15 +783,29 @@ static bool is_pointer_value(struct bpf_verifier_env *env, int regno)
 }
 
 static int check_pkt_ptr_alignment(const struct bpf_reg_state *reg,
-				   int off, int size)
+				   int off, int size, bool strict)
 {
-	if (reg->id && size != 1) {
-		verbose("Unknown alignment. Only byte-sized access allowed in packet access.\n");
-		return -EACCES;
+	int reg_off;
+
+	/* Byte size accesses are always allowed. */
+	if (!strict || size == 1)
+		return 0;
+
+	reg_off = reg->off;
+	if (reg->id) {
+		if (reg->aux_off_align % size) {
+			verbose("Packet access is only %u byte aligned, %d byte access not allowed\n",
+				reg->aux_off_align, size);
+			return -EACCES;
+		}
+		reg_off += reg->aux_off;
 	}
 
-	/* skb->data is NET_IP_ALIGN-ed */
-	if ((NET_IP_ALIGN + reg->off + off) % size != 0) {
+	/* skb->data is NET_IP_ALIGN-ed, but for strict alignment checking
+	 * we force this to 2 which is universally what architectures use
+	 * when they don't set CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS.
+	 */
+	if (((strict ? 2 : NET_IP_ALIGN) + reg_off + off) % size != 0) {
 		verbose("misaligned packet access off %d+%d+%d size %d\n",
 			NET_IP_ALIGN, reg->off, off, size);
 		return -EACCES;
@@ -786,9 +815,9 @@ static int check_pkt_ptr_alignment(const struct bpf_reg_state *reg,
 }
 
 static int check_val_ptr_alignment(const struct bpf_reg_state *reg,
-				   int size)
+				   int size, bool strict)
 {
-	if (size != 1) {
+	if (strict && size != 1) {
 		verbose("Unknown alignment. Only byte-sized access allowed in value access.\n");
 		return -EACCES;
 	}
@@ -796,16 +825,21 @@ static int check_val_ptr_alignment(const struct bpf_reg_state *reg,
 	return 0;
 }
 
+static bool strict_alignment;
+
 static int check_ptr_alignment(const struct bpf_reg_state *reg,
 			       int off, int size)
 {
+	bool strict = strict_alignment;
+
+	if (!IS_ENABLED(CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS))
+		strict = true;
+
 	switch (reg->type) {
 	case PTR_TO_PACKET:
-		return IS_ENABLED(CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS) ? 0 :
-		       check_pkt_ptr_alignment(reg, off, size);
+		return check_pkt_ptr_alignment(reg, off, size, strict);
 	case PTR_TO_MAP_VALUE_ADJ:
-		return IS_ENABLED(CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS) ? 0 :
-		       check_val_ptr_alignment(reg, size);
+		return check_val_ptr_alignment(reg, size, strict);
 	default:
 		if (off % size != 0) {
 			verbose("misaligned access off %d size %d\n",
@@ -872,6 +906,8 @@ static int check_mem_access(struct bpf_verifier_env *env, u32 regno, int off,
 							 value_regno);
 			/* note that reg.[id|off|range] == 0 */
 			state->regs[value_regno].type = reg_type;
+			state->regs[value_regno].aux_off = 0;
+			state->regs[value_regno].aux_off_align = 0;
 		}
 
 	} else if (reg->type == FRAME_PTR || reg->type == PTR_TO_STACK) {
@@ -1444,6 +1480,8 @@ static int check_packet_ptr_add(struct bpf_verifier_env *env,
 		 */
 		dst_reg->off += imm;
 	} else {
+		bool had_id;
+
 		if (src_reg->type == PTR_TO_PACKET) {
 			/* R6=pkt(id=0,off=0,r=62) R7=imm22; r7 += r6 */
 			tmp_reg = *dst_reg;  /* save r7 state */
@@ -1477,14 +1515,23 @@ static int check_packet_ptr_add(struct bpf_verifier_env *env,
 				src_reg->imm);
 			return -EACCES;
 		}
+
+		had_id = (dst_reg->id != 0);
+
 		/* dst_reg stays as pkt_ptr type and since some positive
 		 * integer value was added to the pointer, increment its 'id'
 		 */
 		dst_reg->id = ++env->id_gen;
 
-		/* something was added to pkt_ptr, set range and off to zero */
+		/* something was added to pkt_ptr, set range to zero */
+		dst_reg->aux_off = dst_reg->off;
 		dst_reg->off = 0;
 		dst_reg->range = 0;
+		if (had_id)
+			dst_reg->aux_off_align = min(dst_reg->aux_off_align,
+						     src_reg->min_align);
+		else
+			dst_reg->aux_off_align = src_reg->min_align;
 	}
 	return 0;
 }
@@ -1658,6 +1705,13 @@ static void check_reg_overflow(struct bpf_reg_state *reg)
 		reg->min_value = BPF_REGISTER_MIN_RANGE;
 }
 
+static u32 calc_align(u32 imm)
+{
+	if (!imm)
+		return 1U << 31;
+	return imm - ((imm - 1) & imm);
+}
+
 static void adjust_reg_min_max_vals(struct bpf_verifier_env *env,
 				    struct bpf_insn *insn)
 {
@@ -1665,8 +1719,10 @@ static void adjust_reg_min_max_vals(struct bpf_verifier_env *env,
 	s64 min_val = BPF_REGISTER_MIN_RANGE;
 	u64 max_val = BPF_REGISTER_MAX_RANGE;
 	u8 opcode = BPF_OP(insn->code);
+	u32 dst_align, src_align;
 
 	dst_reg = &regs[insn->dst_reg];
+	src_align = 0;
 	if (BPF_SRC(insn->code) == BPF_X) {
 		check_reg_overflow(&regs[insn->src_reg]);
 		min_val = regs[insn->src_reg].min_value;
@@ -1682,18 +1738,25 @@ static void adjust_reg_min_max_vals(struct bpf_verifier_env *env,
 		    regs[insn->src_reg].type != UNKNOWN_VALUE) {
 			min_val = BPF_REGISTER_MIN_RANGE;
 			max_val = BPF_REGISTER_MAX_RANGE;
+			src_align = 0;
+		} else {
+			src_align = regs[insn->src_reg].min_align;
 		}
 	} else if (insn->imm < BPF_REGISTER_MAX_RANGE &&
 		   (s64)insn->imm > BPF_REGISTER_MIN_RANGE) {
 		min_val = max_val = insn->imm;
+		src_align = calc_align(insn->imm);
 	}
 
+	dst_align = dst_reg->min_align;
+
 	/* We don't know anything about what was done to this register, mark it
 	 * as unknown.
 	 */
 	if (min_val == BPF_REGISTER_MIN_RANGE &&
 	    max_val == BPF_REGISTER_MAX_RANGE) {
 		reset_reg_range_values(regs, insn->dst_reg);
+		reset_reg_align(regs, insn->dst_reg);
 		return;
 	}
 
@@ -1712,18 +1775,21 @@ static void adjust_reg_min_max_vals(struct bpf_verifier_env *env,
 			dst_reg->min_value += min_val;
 		if (dst_reg->max_value != BPF_REGISTER_MAX_RANGE)
 			dst_reg->max_value += max_val;
+		dst_reg->min_align = min(src_align, dst_align);
 		break;
 	case BPF_SUB:
 		if (dst_reg->min_value != BPF_REGISTER_MIN_RANGE)
 			dst_reg->min_value -= min_val;
 		if (dst_reg->max_value != BPF_REGISTER_MAX_RANGE)
 			dst_reg->max_value -= max_val;
+		dst_reg->min_align = min(src_align, dst_align);
 		break;
 	case BPF_MUL:
 		if (dst_reg->min_value != BPF_REGISTER_MIN_RANGE)
 			dst_reg->min_value *= min_val;
 		if (dst_reg->max_value != BPF_REGISTER_MAX_RANGE)
 			dst_reg->max_value *= max_val;
+		dst_reg->min_align = max(src_align, dst_align);
 		break;
 	case BPF_AND:
 		/* Disallow AND'ing of negative numbers, ain't nobody got time
@@ -1735,17 +1801,23 @@ static void adjust_reg_min_max_vals(struct bpf_verifier_env *env,
 		else
 			dst_reg->min_value = 0;
 		dst_reg->max_value = max_val;
+		dst_reg->min_align = max(src_align, dst_align);
 		break;
 	case BPF_LSH:
 		/* Gotta have special overflow logic here, if we're shifting
 		 * more than MAX_RANGE then just assume we have an invalid
 		 * range.
 		 */
-		if (min_val > ilog2(BPF_REGISTER_MAX_RANGE))
+		if (min_val > ilog2(BPF_REGISTER_MAX_RANGE)) {
 			dst_reg->min_value = BPF_REGISTER_MIN_RANGE;
-		else if (dst_reg->min_value != BPF_REGISTER_MIN_RANGE)
-			dst_reg->min_value <<= min_val;
-
+			dst_reg->min_align = 1;
+		} else {
+			if (dst_reg->min_value != BPF_REGISTER_MIN_RANGE)
+				dst_reg->min_value <<= min_val;
+			if (!dst_reg->min_align)
+				dst_reg->min_align = 1;
+			dst_reg->min_align <<= min_val;
+		}
 		if (max_val > ilog2(BPF_REGISTER_MAX_RANGE))
 			dst_reg->max_value = BPF_REGISTER_MAX_RANGE;
 		else if (dst_reg->max_value != BPF_REGISTER_MAX_RANGE)
@@ -1755,11 +1827,19 @@ static void adjust_reg_min_max_vals(struct bpf_verifier_env *env,
 		/* RSH by a negative number is undefined, and the BPF_RSH is an
 		 * unsigned shift, so make the appropriate casts.
 		 */
-		if (min_val < 0 || dst_reg->min_value < 0)
+		if (min_val < 0 || dst_reg->min_value < 0) {
 			dst_reg->min_value = BPF_REGISTER_MIN_RANGE;
-		else
+		} else {
 			dst_reg->min_value =
 				(u64)(dst_reg->min_value) >> min_val;
+		}
+		if (min_val < 0) {
+			dst_reg->min_align = 1;
+		} else {
+			dst_reg->min_align >>= (u64) min_val;
+			if (!dst_reg->min_align)
+				dst_reg->min_align = 1;
+		}
 		if (dst_reg->max_value != BPF_REGISTER_MAX_RANGE)
 			dst_reg->max_value >>= max_val;
 		break;
@@ -1861,6 +1941,7 @@ static int check_alu_op(struct bpf_verifier_env *env, struct bpf_insn *insn)
 			regs[insn->dst_reg].imm = insn->imm;
 			regs[insn->dst_reg].max_value = insn->imm;
 			regs[insn->dst_reg].min_value = insn->imm;
+			regs[insn->dst_reg].min_align = calc_align(insn->imm);
 		}
 
 	} else if (opcode > BPF_END) {
@@ -2845,8 +2926,12 @@ static int do_check(struct bpf_verifier_env *env)
 			goto process_bpf_exit;
 		}
 
-		if (log_level && do_print_state) {
-			verbose("\nfrom %d to %d:", prev_insn_idx, insn_idx);
+		if (log_level > 1 || (log_level && do_print_state)) {
+			if (log_level > 1)
+				verbose("%d:", insn_idx);
+			else
+				verbose("\nfrom %d to %d:",
+					prev_insn_idx, insn_idx);
 			print_verifier_state(&env->cur_state);
 			do_print_state = false;
 		}
@@ -3483,6 +3568,10 @@ int bpf_check(struct bpf_prog **prog, union bpf_attr *attr)
 	} else {
 		log_level = 0;
 	}
+	if (attr->prog_flags & BPF_F_STRICT_ALIGNMENT)
+		strict_alignment = true;
+	else
+		strict_alignment = false;
 
 	ret = replace_map_fd_with_map_ptr(env);
 	if (ret < 0)
@@ -3588,6 +3677,7 @@ int bpf_analyzer(struct bpf_prog *prog, const struct bpf_ext_analyzer_ops *ops,
 	mutex_lock(&bpf_verifier_lock);
 
 	log_level = 0;
+	strict_alignment = false;
 
 	env->explored_states = kcalloc(env->prog->len,
 				       sizeof(struct bpf_verifier_state_list *),
diff --git a/tools/include/uapi/linux/bpf.h b/tools/include/uapi/linux/bpf.h
index e553529..94dfa9d 100644
--- a/tools/include/uapi/linux/bpf.h
+++ b/tools/include/uapi/linux/bpf.h
@@ -132,6 +132,13 @@ enum bpf_attach_type {
  */
 #define BPF_F_ALLOW_OVERRIDE	(1U << 0)
 
+/* If BPF_F_STRICT_ALIGNMENT is used in BPF_PROG_LOAD command, the
+ * verifier will perform strict alignment checking as if the kernel
+ * has been built with CONFIG_EFFICIENT_UNALIGNED_ACCESS not set,
+ * and NET_IP_ALIGN defined to 2.
+ */
+#define BPF_F_STRICT_ALIGNMENT	(1U << 0)
+
 #define BPF_PSEUDO_MAP_FD	1
 
 /* flags for BPF_MAP_UPDATE_ELEM command */
@@ -177,6 +184,7 @@ union bpf_attr {
 		__u32		log_size;	/* size of user buffer */
 		__aligned_u64	log_buf;	/* user supplied buffer */
 		__u32		kern_version;	/* checked when prog_type=kprobe */
+		__u32		prog_flags;
 	};
 
 	struct { /* anonymous struct used by BPF_OBJ_* commands */
@@ -481,8 +489,7 @@ union bpf_attr {
  * u32 bpf_get_socket_uid(skb)
  *     Get the owner uid of the socket stored inside sk_buff.
  *     @skb: pointer to skb
- *     Return: uid of the socket owner on success or 0 if the socket pointer
- *     inside sk_buff is NULL
+ *     Return: uid of the socket owner on success or overflowuid if failed.
  */
 #define __BPF_FUNC_MAPPER(FN)		\
 	FN(unspec),			\
diff --git a/tools/lib/bpf/bpf.c b/tools/lib/bpf/bpf.c
index 4fe444b80..6e17898 100644
--- a/tools/lib/bpf/bpf.c
+++ b/tools/lib/bpf/bpf.c
@@ -117,6 +117,28 @@ int bpf_load_program(enum bpf_prog_type type, const struct bpf_insn *insns,
 	return sys_bpf(BPF_PROG_LOAD, &attr, sizeof(attr));
 }
 
+int bpf_verify_program(enum bpf_prog_type type, const struct bpf_insn *insns,
+		       size_t insns_cnt, int strict_alignment,
+		       const char *license, __u32 kern_version,
+		       char *log_buf, size_t log_buf_sz)
+{
+	union bpf_attr attr;
+
+	bzero(&attr, sizeof(attr));
+	attr.prog_type = type;
+	attr.insn_cnt = (__u32)insns_cnt;
+	attr.insns = ptr_to_u64(insns);
+	attr.license = ptr_to_u64(license);
+	attr.log_buf = ptr_to_u64(log_buf);
+	attr.log_size = log_buf_sz;
+	attr.log_level = 2;
+	log_buf[0] = 0;
+	attr.kern_version = kern_version;
+	attr.prog_flags = strict_alignment ? BPF_F_STRICT_ALIGNMENT : 0;
+
+	return sys_bpf(BPF_PROG_LOAD, &attr, sizeof(attr));
+}
+
 int bpf_map_update_elem(int fd, const void *key, const void *value,
 			__u64 flags)
 {
diff --git a/tools/lib/bpf/bpf.h b/tools/lib/bpf/bpf.h
index edb4dae..972bd83 100644
--- a/tools/lib/bpf/bpf.h
+++ b/tools/lib/bpf/bpf.h
@@ -35,6 +35,10 @@ int bpf_load_program(enum bpf_prog_type type, const struct bpf_insn *insns,
 		     size_t insns_cnt, const char *license,
 		     __u32 kern_version, char *log_buf,
 		     size_t log_buf_sz);
+int bpf_verify_program(enum bpf_prog_type type, const struct bpf_insn *insns,
+		       size_t insns_cnt, int strict_alignment,
+		       const char *license, __u32 kern_version,
+		       char *log_buf, size_t log_buf_sz);
 
 int bpf_map_update_elem(int fd, const void *key, const void *value,
 			__u64 flags);
diff --git a/tools/testing/selftests/bpf/Makefile b/tools/testing/selftests/bpf/Makefile
index 91edd05..1e1cde1 100644
--- a/tools/testing/selftests/bpf/Makefile
+++ b/tools/testing/selftests/bpf/Makefile
@@ -11,7 +11,8 @@ endif
 CFLAGS += -Wall -O2 -I$(APIDIR) -I$(LIBDIR) -I$(GENDIR) $(GENFLAGS) -I../../../include
 LDLIBS += -lcap -lelf
 
-TEST_GEN_PROGS = test_verifier test_tag test_maps test_lru_map test_lpm_map test_progs
+TEST_GEN_PROGS = test_verifier test_tag test_maps test_lru_map test_lpm_map test_progs \
+	test_align
 
 TEST_GEN_FILES = test_pkt_access.o test_xdp.o test_l4lb.o test_tcp_estats.o
 
diff --git a/tools/testing/selftests/bpf/test_align.c b/tools/testing/selftests/bpf/test_align.c
new file mode 100644
index 0000000..9dd9794
--- /dev/null
+++ b/tools/testing/selftests/bpf/test_align.c
@@ -0,0 +1,417 @@
+#include <asm/types.h>
+#include <linux/types.h>
+#include <stdint.h>
+#include <stdio.h>
+#include <stdlib.h>
+#include <unistd.h>
+#include <errno.h>
+#include <string.h>
+#include <stddef.h>
+#include <stdbool.h>
+
+#include <linux/unistd.h>
+#include <linux/filter.h>
+#include <linux/bpf_perf_event.h>
+#include <linux/bpf.h>
+
+#include <bpf/bpf.h>
+
+#include "../../../include/linux/filter.h"
+
+#ifndef ARRAY_SIZE
+# define ARRAY_SIZE(x) (sizeof(x) / sizeof((x)[0]))
+#endif
+
+#define MAX_INSNS	512
+#define MAX_MATCHES	16
+
+struct bpf_align_test {
+	const char *descr;
+	struct bpf_insn	insns[MAX_INSNS];
+	enum {
+		UNDEF,
+		ACCEPT,
+		REJECT
+	} result;
+	enum bpf_prog_type prog_type;
+	const char *matches[MAX_MATCHES];
+};
+
+static struct bpf_align_test tests[] = {
+	{
+		.descr = "mov",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_3, 2),
+			BPF_MOV64_IMM(BPF_REG_3, 4),
+			BPF_MOV64_IMM(BPF_REG_3, 8),
+			BPF_MOV64_IMM(BPF_REG_3, 16),
+			BPF_MOV64_IMM(BPF_REG_3, 32),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+		.matches = {
+			"1: R1=ctx R3=imm2,min_value=2,max_value=2,min_align=2 R10=fp",
+			"2: R1=ctx R3=imm4,min_value=4,max_value=4,min_align=4 R10=fp",
+			"3: R1=ctx R3=imm8,min_value=8,max_value=8,min_align=8 R10=fp",
+			"4: R1=ctx R3=imm16,min_value=16,max_value=16,min_align=16 R10=fp",
+			"5: R1=ctx R3=imm32,min_value=32,max_value=32,min_align=32 R10=fp",
+		},
+	},
+	{
+		.descr = "shift",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_3, 1),
+			BPF_ALU64_IMM(BPF_LSH, BPF_REG_3, 1),
+			BPF_ALU64_IMM(BPF_LSH, BPF_REG_3, 1),
+			BPF_ALU64_IMM(BPF_LSH, BPF_REG_3, 1),
+			BPF_ALU64_IMM(BPF_LSH, BPF_REG_3, 1),
+			BPF_ALU64_IMM(BPF_RSH, BPF_REG_3, 4),
+			BPF_MOV64_IMM(BPF_REG_4, 32),
+			BPF_ALU64_IMM(BPF_RSH, BPF_REG_4, 1),
+			BPF_ALU64_IMM(BPF_RSH, BPF_REG_4, 1),
+			BPF_ALU64_IMM(BPF_RSH, BPF_REG_4, 1),
+			BPF_ALU64_IMM(BPF_RSH, BPF_REG_4, 1),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+		.matches = {
+			"1: R1=ctx R3=imm1,min_value=1,max_value=1,min_align=1 R10=fp",
+			"2: R1=ctx R3=imm2,min_value=2,max_value=2,min_align=2 R10=fp",
+			"3: R1=ctx R3=imm4,min_value=4,max_value=4,min_align=4 R10=fp",
+			"4: R1=ctx R3=imm8,min_value=8,max_value=8,min_align=8 R10=fp",
+			"5: R1=ctx R3=imm16,min_value=16,max_value=16,min_align=16 R10=fp",
+			"6: R1=ctx R3=imm1,min_value=1,max_value=1,min_align=1 R10=fp",
+			"7: R1=ctx R3=imm1,min_value=1,max_value=1,min_align=1 R4=imm32,min_value=32,max_value=32,min_align=32 R10=fp",
+			"8: R1=ctx R3=imm1,min_value=1,max_value=1,min_align=1 R4=imm16,min_value=16,max_value=16,min_align=16 R10=fp",
+			"9: R1=ctx R3=imm1,min_value=1,max_value=1,min_align=1 R4=imm8,min_value=8,max_value=8,min_align=8 R10=fp",
+			"10: R1=ctx R3=imm1,min_value=1,max_value=1,min_align=1 R4=imm4,min_value=4,max_value=4,min_align=4 R10=fp",
+			"11: R1=ctx R3=imm1,min_value=1,max_value=1,min_align=1 R4=imm2,min_value=2,max_value=2,min_align=2 R10=fp",
+		},
+	},
+	{
+		.descr = "addsub",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_3, 4),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_3, 4),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_3, 2),
+			BPF_MOV64_IMM(BPF_REG_4, 8),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_4, 4),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_4, 2),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+		.matches = {
+			"1: R1=ctx R3=imm4,min_value=4,max_value=4,min_align=4 R10=fp",
+			"2: R1=ctx R3=imm8,min_value=8,max_value=8,min_align=4 R10=fp",
+			"3: R1=ctx R3=imm10,min_value=10,max_value=10,min_align=2 R10=fp",
+			"4: R1=ctx R3=imm10,min_value=10,max_value=10,min_align=2 R4=imm8,min_value=8,max_value=8,min_align=8 R10=fp",
+			"5: R1=ctx R3=imm10,min_value=10,max_value=10,min_align=2 R4=imm12,min_value=12,max_value=12,min_align=4 R10=fp",
+			"6: R1=ctx R3=imm10,min_value=10,max_value=10,min_align=2 R4=imm14,min_value=14,max_value=14,min_align=2 R10=fp",
+		},
+	},
+	{
+		.descr = "mul",
+		.insns = {
+			BPF_MOV64_IMM(BPF_REG_3, 7),
+			BPF_ALU64_IMM(BPF_MUL, BPF_REG_3, 1),
+			BPF_ALU64_IMM(BPF_MUL, BPF_REG_3, 2),
+			BPF_ALU64_IMM(BPF_MUL, BPF_REG_3, 4),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+		.matches = {
+			"1: R1=ctx R3=imm7,min_value=7,max_value=7,min_align=1 R10=fp",
+			"2: R1=ctx R3=imm7,min_value=7,max_value=7,min_align=1 R10=fp",
+			"3: R1=ctx R3=imm14,min_value=14,max_value=14,min_align=2 R10=fp",
+			"4: R1=ctx R3=imm56,min_value=56,max_value=56,min_align=4 R10=fp",
+		},
+	},
+
+#define PREP_PKT_POINTERS \
+	BPF_LDX_MEM(BPF_W, BPF_REG_2, BPF_REG_1, \
+		    offsetof(struct __sk_buff, data)), \
+	BPF_LDX_MEM(BPF_W, BPF_REG_3, BPF_REG_1, \
+		    offsetof(struct __sk_buff, data_end))
+
+#define LOAD_UNKNOWN(DST_REG) \
+	PREP_PKT_POINTERS, \
+	BPF_MOV64_REG(BPF_REG_0, BPF_REG_2), \
+	BPF_ALU64_IMM(BPF_ADD, BPF_REG_0, 8), \
+	BPF_JMP_REG(BPF_JGE, BPF_REG_3, BPF_REG_0, 1), \
+	BPF_EXIT_INSN(), \
+	BPF_LDX_MEM(BPF_B, DST_REG, BPF_REG_2, 0)
+
+	{
+		.descr = "unknown shift",
+		.insns = {
+			LOAD_UNKNOWN(BPF_REG_3),
+			BPF_ALU64_IMM(BPF_LSH, BPF_REG_3, 1),
+			BPF_ALU64_IMM(BPF_LSH, BPF_REG_3, 1),
+			BPF_ALU64_IMM(BPF_LSH, BPF_REG_3, 1),
+			BPF_ALU64_IMM(BPF_LSH, BPF_REG_3, 1),
+			LOAD_UNKNOWN(BPF_REG_4),
+			BPF_ALU64_IMM(BPF_LSH, BPF_REG_4, 5),
+			BPF_ALU64_IMM(BPF_RSH, BPF_REG_4, 1),
+			BPF_ALU64_IMM(BPF_RSH, BPF_REG_4, 1),
+			BPF_ALU64_IMM(BPF_RSH, BPF_REG_4, 1),
+			BPF_ALU64_IMM(BPF_RSH, BPF_REG_4, 1),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+		.matches = {
+			"7: R0=pkt(id=0,off=8,r=8) R1=ctx R2=pkt(id=0,off=0,r=8) R3=inv56 R10=fp",
+			"8: R0=pkt(id=0,off=8,r=8) R1=ctx R2=pkt(id=0,off=0,r=8) R3=inv55,min_align=2 R10=fp",
+			"9: R0=pkt(id=0,off=8,r=8) R1=ctx R2=pkt(id=0,off=0,r=8) R3=inv54,min_align=4 R10=fp",
+			"10: R0=pkt(id=0,off=8,r=8) R1=ctx R2=pkt(id=0,off=0,r=8) R3=inv53,min_align=8 R10=fp",
+			"11: R0=pkt(id=0,off=8,r=8) R1=ctx R2=pkt(id=0,off=0,r=8) R3=inv52,min_align=16 R10=fp",
+			"18: R0=pkt(id=0,off=8,r=8) R1=ctx R2=pkt(id=0,off=0,r=8) R3=pkt_end R4=inv56 R10=fp",
+			"19: R0=pkt(id=0,off=8,r=8) R1=ctx R2=pkt(id=0,off=0,r=8) R3=pkt_end R4=inv51,min_align=32 R10=fp",
+			"20: R0=pkt(id=0,off=8,r=8) R1=ctx R2=pkt(id=0,off=0,r=8) R3=pkt_end R4=inv52,min_align=16 R10=fp",
+			"21: R0=pkt(id=0,off=8,r=8) R1=ctx R2=pkt(id=0,off=0,r=8) R3=pkt_end R4=inv53,min_align=8 R10=fp",
+			"22: R0=pkt(id=0,off=8,r=8) R1=ctx R2=pkt(id=0,off=0,r=8) R3=pkt_end R4=inv54,min_align=4 R10=fp",
+			"23: R0=pkt(id=0,off=8,r=8) R1=ctx R2=pkt(id=0,off=0,r=8) R3=pkt_end R4=inv55,min_align=2 R10=fp",
+		},
+	},
+	{
+		.descr = "unknown mul",
+		.insns = {
+			LOAD_UNKNOWN(BPF_REG_3),
+			BPF_MOV64_REG(BPF_REG_4, BPF_REG_3),
+			BPF_ALU64_IMM(BPF_MUL, BPF_REG_4, 1),
+			BPF_MOV64_REG(BPF_REG_4, BPF_REG_3),
+			BPF_ALU64_IMM(BPF_MUL, BPF_REG_4, 2),
+			BPF_MOV64_REG(BPF_REG_4, BPF_REG_3),
+			BPF_ALU64_IMM(BPF_MUL, BPF_REG_4, 4),
+			BPF_MOV64_REG(BPF_REG_4, BPF_REG_3),
+			BPF_ALU64_IMM(BPF_MUL, BPF_REG_4, 8),
+			BPF_ALU64_IMM(BPF_MUL, BPF_REG_4, 2),
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+		.matches = {
+			"7: R0=pkt(id=0,off=8,r=8) R1=ctx R2=pkt(id=0,off=0,r=8) R3=inv56 R10=fp",
+			"8: R0=pkt(id=0,off=8,r=8) R1=ctx R2=pkt(id=0,off=0,r=8) R3=inv56 R4=inv56 R10=fp",
+			"9: R0=pkt(id=0,off=8,r=8) R1=ctx R2=pkt(id=0,off=0,r=8) R3=inv56 R4=inv55,min_align=1 R10=fp",
+			"10: R0=pkt(id=0,off=8,r=8) R1=ctx R2=pkt(id=0,off=0,r=8) R3=inv56 R4=inv56 R10=fp",
+			"11: R0=pkt(id=0,off=8,r=8) R1=ctx R2=pkt(id=0,off=0,r=8) R3=inv56 R4=inv54,min_align=2 R10=fp",
+			"12: R0=pkt(id=0,off=8,r=8) R1=ctx R2=pkt(id=0,off=0,r=8) R3=inv56 R4=inv56 R10=fp",
+			"13: R0=pkt(id=0,off=8,r=8) R1=ctx R2=pkt(id=0,off=0,r=8) R3=inv56 R4=inv53,min_align=4 R10=fp",
+			"14: R0=pkt(id=0,off=8,r=8) R1=ctx R2=pkt(id=0,off=0,r=8) R3=inv56 R4=inv56 R10=fp",
+			"15: R0=pkt(id=0,off=8,r=8) R1=ctx R2=pkt(id=0,off=0,r=8) R3=inv56 R4=inv52,min_align=8 R10=fp",
+			"16: R0=pkt(id=0,off=8,r=8) R1=ctx R2=pkt(id=0,off=0,r=8) R3=inv56 R4=inv50,min_align=8 R10=fp"
+		},
+	},
+	{
+		.descr = "packet const offset",
+		.insns = {
+			PREP_PKT_POINTERS,
+			BPF_MOV64_REG(BPF_REG_5, BPF_REG_2),
+
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+
+			/* Skip over ethernet header.  */
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_5, 14),
+			BPF_MOV64_REG(BPF_REG_4, BPF_REG_5),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_4, 4),
+			BPF_JMP_REG(BPF_JGE, BPF_REG_3, BPF_REG_4, 1),
+			BPF_EXIT_INSN(),
+
+			BPF_LDX_MEM(BPF_B, BPF_REG_4, BPF_REG_5, 0),
+			BPF_LDX_MEM(BPF_B, BPF_REG_4, BPF_REG_5, 1),
+			BPF_LDX_MEM(BPF_B, BPF_REG_4, BPF_REG_5, 2),
+			BPF_LDX_MEM(BPF_B, BPF_REG_4, BPF_REG_5, 3),
+			BPF_LDX_MEM(BPF_H, BPF_REG_4, BPF_REG_5, 0),
+			BPF_LDX_MEM(BPF_H, BPF_REG_4, BPF_REG_5, 2),
+			BPF_LDX_MEM(BPF_W, BPF_REG_4, BPF_REG_5, 0),
+
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+		.matches = {
+			"4: R0=imm0,min_value=0,max_value=0,min_align=2147483648 R1=ctx R2=pkt(id=0,off=0,r=0) R3=pkt_end R5=pkt(id=0,off=0,r=0) R10=fp",
+			"5: R0=imm0,min_value=0,max_value=0,min_align=2147483648 R1=ctx R2=pkt(id=0,off=0,r=0) R3=pkt_end R5=pkt(id=0,off=14,r=0) R10=fp",
+			"6: R0=imm0,min_value=0,max_value=0,min_align=2147483648 R1=ctx R2=pkt(id=0,off=0,r=0) R3=pkt_end R4=pkt(id=0,off=14,r=0) R5=pkt(id=0,off=14,r=0) R10=fp",
+			"10: R0=imm0,min_value=0,max_value=0,min_align=2147483648 R1=ctx R2=pkt(id=0,off=0,r=18) R3=pkt_end R4=inv56 R5=pkt(id=0,off=14,r=18) R10=fp",
+			"14: R0=imm0,min_value=0,max_value=0,min_align=2147483648 R1=ctx R2=pkt(id=0,off=0,r=18) R3=pkt_end R4=inv48 R5=pkt(id=0,off=14,r=18) R10=fp",
+			"15: R0=imm0,min_value=0,max_value=0,min_align=2147483648 R1=ctx R2=pkt(id=0,off=0,r=18) R3=pkt_end R4=inv48 R5=pkt(id=0,off=14,r=18) R10=fp",
+		},
+	},
+	{
+		.descr = "packet variable offset",
+		.insns = {
+			LOAD_UNKNOWN(BPF_REG_6),
+			BPF_ALU64_IMM(BPF_LSH, BPF_REG_6, 2),
+
+			/* First, add a constant to the R5 packet pointer,
+			 * then a variable with a known alignment.
+			 */
+			BPF_MOV64_REG(BPF_REG_5, BPF_REG_2),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_5, 14),
+			BPF_ALU64_REG(BPF_ADD, BPF_REG_5, BPF_REG_6),
+			BPF_MOV64_REG(BPF_REG_4, BPF_REG_5),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_4, 4),
+			BPF_JMP_REG(BPF_JGE, BPF_REG_3, BPF_REG_4, 1),
+			BPF_EXIT_INSN(),
+			BPF_LDX_MEM(BPF_W, BPF_REG_4, BPF_REG_5, 0),
+
+			/* Now, test in the other direction.  Adding first
+			 * the variable offset to R5, then the constant.
+			 */
+			BPF_MOV64_REG(BPF_REG_5, BPF_REG_2),
+			BPF_ALU64_REG(BPF_ADD, BPF_REG_5, BPF_REG_6),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_5, 14),
+			BPF_MOV64_REG(BPF_REG_4, BPF_REG_5),
+			BPF_ALU64_IMM(BPF_ADD, BPF_REG_4, 4),
+			BPF_JMP_REG(BPF_JGE, BPF_REG_3, BPF_REG_4, 1),
+			BPF_EXIT_INSN(),
+			BPF_LDX_MEM(BPF_W, BPF_REG_4, BPF_REG_5, 0),
+
+			BPF_MOV64_IMM(BPF_REG_0, 0),
+			BPF_EXIT_INSN(),
+		},
+		.prog_type = BPF_PROG_TYPE_SCHED_CLS,
+		.matches = {
+			/* Calculated offset in R6 has unknown value, but known
+			 * alignment of 4.
+			 */
+			"8: R0=pkt(id=0,off=8,r=8) R1=ctx R2=pkt(id=0,off=0,r=8) R3=pkt_end R6=inv54,min_align=4 R10=fp",
+
+			/* Offset is added to packet pointer R5, resulting in known
+			 * auxiliary alignment and offset.
+			 */
+			"11: R0=pkt(id=0,off=8,r=8) R1=ctx R2=pkt(id=0,off=0,r=8) R3=pkt_end R5=pkt(id=1,off=0,r=0),aux_off=14,aux_off_align=4 R6=inv54,min_align=4 R10=fp",
+
+			/* At the time the word size load is performed from R5,
+			 * it's total offset is NET_IP_ALIGN + reg->off (0) +
+			 * reg->aux_off (14) which is 16.  Then the variable
+			 * offset is considered using reg->aux_off_align which
+			 * is 4 and meets the load's requirements.
+			 */
+			"15: R0=pkt(id=0,off=8,r=8) R1=ctx R2=pkt(id=0,off=0,r=8) R3=pkt_end R4=pkt(id=1,off=4,r=4),aux_off=14,aux_off_align=4 R5=pkt(id=1,off=0,r=4),aux_off=14,aux_off_align=4 R6=inv54,min_align=4 R10=fp",
+
+
+			/* Variable offset is added to R5 packet pointer,
+			 * resulting in auxiliary alignment of 4.
+			 */
+			"18: R0=pkt(id=0,off=8,r=8) R1=ctx R2=pkt(id=0,off=0,r=8) R3=pkt_end R4=inv,aux_off=14,aux_off_align=4 R5=pkt(id=2,off=0,r=0),aux_off_align=4 R6=inv54,min_align=4 R10=fp",
+
+			/* Constant offset is added to R5, resulting in
+			 * reg->off of 14.
+			 */
+			"19: R0=pkt(id=0,off=8,r=8) R1=ctx R2=pkt(id=0,off=0,r=8) R3=pkt_end R4=inv,aux_off=14,aux_off_align=4 R5=pkt(id=2,off=14,r=0),aux_off_align=4 R6=inv54,min_align=4 R10=fp",
+
+			/* At the time the word size load is performed from R5,
+			 * it's total offset is NET_IP_ALIGN + reg->off (14) which
+			 * is 16.  Then the variable offset is considered using
+			 * reg->aux_off_align which is 4 and meets the load's
+			 * requirements.
+			 */
+			"23: R0=pkt(id=0,off=8,r=8) R1=ctx R2=pkt(id=0,off=0,r=8) R3=pkt_end R4=pkt(id=2,off=18,r=18),aux_off_align=4 R5=pkt(id=2,off=14,r=18),aux_off_align=4 R6=inv54,min_align=4 R10=fp",
+		},
+	},
+};
+
+static int probe_filter_length(const struct bpf_insn *fp)
+{
+	int len;
+
+	for (len = MAX_INSNS - 1; len > 0; --len)
+		if (fp[len].code != 0 || fp[len].imm != 0)
+			break;
+	return len + 1;
+}
+
+static char bpf_vlog[32768];
+
+static int do_test_single(struct bpf_align_test *test)
+{
+	struct bpf_insn *prog = test->insns;
+	int prog_type = test->prog_type;
+	int prog_len, i;
+	int fd_prog;
+	int ret;
+
+	prog_len = probe_filter_length(prog);
+	fd_prog = bpf_verify_program(prog_type ? : BPF_PROG_TYPE_SOCKET_FILTER,
+				     prog, prog_len, 1, "GPL", 0,
+				     bpf_vlog, sizeof(bpf_vlog));
+	if (fd_prog < 0) {
+		printf("Failed to load program.\n");
+		printf("%s", bpf_vlog);
+		ret = 1;
+	} else {
+		ret = 0;
+		for (i = 0; i < MAX_MATCHES; i++) {
+			const char *t, *m = test->matches[i];
+
+			if (!m)
+				break;
+			t = strstr(bpf_vlog, m);
+			if (!t) {
+				printf("Failed to find match: %s\n", m);
+				ret = 1;
+				printf("%s", bpf_vlog);
+				break;
+			}
+		}
+		/* printf("%s", bpf_vlog); */
+		close(fd_prog);
+	}
+	return ret;
+}
+
+static int do_test(unsigned int from, unsigned int to)
+{
+	int all_pass = 0;
+	int all_fail = 0;
+	unsigned int i;
+
+	for (i = from; i < to; i++) {
+		struct bpf_align_test *test = &tests[i];
+		int fail;
+
+		printf("Test %3d: %s ... ",
+		       i, test->descr);
+		fail = do_test_single(test);
+		if (fail) {
+			all_fail++;
+			printf("FAIL\n");
+		} else {
+			all_pass++;
+			printf("PASS\n");
+		}
+	}
+	printf("Results: %d pass %d fail\n",
+	       all_pass, all_fail);
+	return 0;
+}
+
+int main(int argc, char **argv)
+{
+	unsigned int from = 0, to = ARRAY_SIZE(tests);
+
+	if (argc == 3) {
+		unsigned int l = atoi(argv[argc - 2]);
+		unsigned int u = atoi(argv[argc - 1]);
+
+		if (l < to && u < to) {
+			from = l;
+			to   = u + 1;
+		}
+	} else if (argc == 2) {
+		unsigned int t = atoi(argv[argc - 1]);
+
+		if (t < to) {
+			from = t;
+			to   = t + 1;
+		}
+	}
+	return do_test(from, to);
+}
-- 
2.1.2.532.g19b5d50
