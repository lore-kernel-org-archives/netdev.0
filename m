From: Kees Cook <keescook@chromium.org>
Subject: Re: [PATCH v2 net-next 1/3] bpf: enable non-root eBPF programs
Date: Thu, 8 Oct 2015 10:45:29 -0700
Message-ID: <CAGXu5jLKO2AnpxeAaJArpicO-feBLN7njTPrXk+Z9RiAG23KwA@mail.gmail.com>
References: <1444281803-24274-1-git-send-email-ast@plumgrid.com>
	<1444281803-24274-2-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Andy Lutomirski <luto@amacapital.net>,
	Ingo Molnar <mingo@kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Eric Dumazet <edumazet@google.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Linux API <linux-api@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f181.google.com ([209.85.223.181]:35247 "EHLO
	mail-io0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933101AbbJHRpa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2015 13:45:30 -0400
Received: by ioiz6 with SMTP id z6so66092225ioi.2
        for <netdev@vger.kernel.org>; Thu, 08 Oct 2015 10:45:29 -0700 (PDT)
In-Reply-To: <1444281803-24274-2-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 7, 2015 at 10:23 PM, Alexei Starovoitov <ast@plumgrid.com> wrote:
> In order to let unprivileged users load and execute eBPF programs
> teach verifier to prevent pointer leaks.
> Verifier will prevent
> - any arithmetic on pointers
>   (except R10+Imm which is used to compute stack addresses)
> - comparison of pointers
>   (except if (map_value_ptr == 0) ... )
> - passing pointers to helper functions
> - indirectly passing pointers in stack to helper functions
> - returning pointer from bpf program
> - storing pointers into ctx or maps
>
> Spill/fill of pointers into stack is allowed, but mangling
> of pointers stored in the stack or reading them byte by byte is not.
>
> Within bpf programs the pointers do exist, since programs need to
> be able to access maps, pass skb pointer to LD_ABS insns, etc
> but programs cannot pass such pointer values to the outside
> or obfuscate them.
>
> Only allow BPF_PROG_TYPE_SOCKET_FILTER unprivileged programs,
> so that socket filters (tcpdump), af_packet (quic acceleration)
> and future kcm can use it.
> tracing and tc cls/act program types still require root permissions,
> since tracing actually needs to be able to see all kernel pointers
> and tc is for root only.
>
> For example, the following unprivileged socket filter program is allowed:
> int bpf_prog1(struct __sk_buff *skb)
> {
>   u32 index = load_byte(skb, ETH_HLEN + offsetof(struct iphdr, protocol));
>   u64 *value = bpf_map_lookup_elem(&my_map, &index);
>
>   if (value)
>         *value += skb->len;
>   return 0;
> }
>
> but the following program is not:
> int bpf_prog1(struct __sk_buff *skb)
> {
>   u32 index = load_byte(skb, ETH_HLEN + offsetof(struct iphdr, protocol));
>   u64 *value = bpf_map_lookup_elem(&my_map, &index);
>
>   if (value)
>         *value += (u64) skb;
>   return 0;
> }
> since it would leak the kernel address into the map.
>
> Unprivileged socket filter bpf programs have access to the
> following helper functions:
> - map lookup/update/delete (but they cannot store kernel pointers into them)
> - get_random (it's already exposed to unprivileged user space)
> - get_smp_processor_id
> - tail_call into another socket filter program
> - ktime_get_ns
>
> The feature is controlled by sysctl kernel.unprivileged_bpf_disabled.
> This toggle defaults to off (0), but can be set true (1).  Once true,
> bpf programs and maps cannot be accessed from unprivileged process,
> and the toggle cannot be set back to false.
>
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>

Reviewed-by: Kees Cook <keescook@chromium.org>

Thanks for making this safer! :)

-Kees

> ---
> v1->v2:
> - sysctl_unprivileged_bpf_disabled
> - drop bpf_trace_printk
> - split tests into separate patch to ease review
> ---
>  include/linux/bpf.h   |    2 +
>  kernel/bpf/syscall.c  |   11 ++---
>  kernel/bpf/verifier.c |  106 ++++++++++++++++++++++++++++++++++++++++++++-----
>  kernel/sysctl.c       |   13 ++++++
>  net/core/filter.c     |    3 +-
>  5 files changed, 120 insertions(+), 15 deletions(-)
>
> diff --git a/include/linux/bpf.h b/include/linux/bpf.h
> index 19b8a2081f88..e472b06df138 100644
> --- a/include/linux/bpf.h
> +++ b/include/linux/bpf.h
> @@ -167,6 +167,8 @@ void bpf_prog_put_rcu(struct bpf_prog *prog);
>  struct bpf_map *bpf_map_get(struct fd f);
>  void bpf_map_put(struct bpf_map *map);
>
> +extern int sysctl_unprivileged_bpf_disabled;
> +
>  /* verify correctness of eBPF program */
>  int bpf_check(struct bpf_prog **fp, union bpf_attr *attr);
>  #else
> diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
> index 5f35f420c12f..9f824b0f0f5f 100644
> --- a/kernel/bpf/syscall.c
> +++ b/kernel/bpf/syscall.c
> @@ -18,6 +18,8 @@
>  #include <linux/filter.h>
>  #include <linux/version.h>
>
> +int sysctl_unprivileged_bpf_disabled __read_mostly;
> +
>  static LIST_HEAD(bpf_map_types);
>
>  static struct bpf_map *find_and_alloc_map(union bpf_attr *attr)
> @@ -542,6 +544,9 @@ static int bpf_prog_load(union bpf_attr *attr)
>             attr->kern_version != LINUX_VERSION_CODE)
>                 return -EINVAL;
>
> +       if (type != BPF_PROG_TYPE_SOCKET_FILTER && !capable(CAP_SYS_ADMIN))
> +               return -EPERM;
> +
>         /* plain bpf_prog allocation */
>         prog = bpf_prog_alloc(bpf_prog_size(attr->insn_cnt), GFP_USER);
>         if (!prog)
> @@ -597,11 +602,7 @@ SYSCALL_DEFINE3(bpf, int, cmd, union bpf_attr __user *, uattr, unsigned int, siz
>         union bpf_attr attr = {};
>         int err;
>
> -       /* the syscall is limited to root temporarily. This restriction will be
> -        * lifted when security audit is clean. Note that eBPF+tracing must have
> -        * this restriction, since it may pass kernel data to user space
> -        */
> -       if (!capable(CAP_SYS_ADMIN))
> +       if (!capable(CAP_SYS_ADMIN) && sysctl_unprivileged_bpf_disabled)
>                 return -EPERM;
>
>         if (!access_ok(VERIFY_READ, uattr, 1))
> diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
> index f8da034c2258..1d6b97be79e1 100644
> --- a/kernel/bpf/verifier.c
> +++ b/kernel/bpf/verifier.c
> @@ -199,6 +199,7 @@ struct verifier_env {
>         struct verifier_state_list **explored_states; /* search pruning optimization */
>         struct bpf_map *used_maps[MAX_USED_MAPS]; /* array of map's used by eBPF program */
>         u32 used_map_cnt;               /* number of used maps */
> +       bool allow_ptr_leaks;
>  };
>
>  /* verbose verifier prints what it's seeing
> @@ -538,6 +539,21 @@ static int bpf_size_to_bytes(int bpf_size)
>                 return -EINVAL;
>  }
>
> +static bool is_spillable_regtype(enum bpf_reg_type type)
> +{
> +       switch (type) {
> +       case PTR_TO_MAP_VALUE:
> +       case PTR_TO_MAP_VALUE_OR_NULL:
> +       case PTR_TO_STACK:
> +       case PTR_TO_CTX:
> +       case FRAME_PTR:
> +       case CONST_PTR_TO_MAP:
> +               return true;
> +       default:
> +               return false;
> +       }
> +}
> +
>  /* check_stack_read/write functions track spill/fill of registers,
>   * stack boundary and alignment are checked in check_mem_access()
>   */
> @@ -550,9 +566,7 @@ static int check_stack_write(struct verifier_state *state, int off, int size,
>          */
>
>         if (value_regno >= 0 &&
> -           (state->regs[value_regno].type == PTR_TO_MAP_VALUE ||
> -            state->regs[value_regno].type == PTR_TO_STACK ||
> -            state->regs[value_regno].type == PTR_TO_CTX)) {
> +           is_spillable_regtype(state->regs[value_regno].type)) {
>
>                 /* register containing pointer is being spilled into stack */
>                 if (size != BPF_REG_SIZE) {
> @@ -643,6 +657,20 @@ static int check_ctx_access(struct verifier_env *env, int off, int size,
>         return -EACCES;
>  }
>
> +static bool is_pointer_value(struct verifier_env *env, int regno)
> +{
> +       if (env->allow_ptr_leaks)
> +               return false;
> +
> +       switch (env->cur_state.regs[regno].type) {
> +       case UNKNOWN_VALUE:
> +       case CONST_IMM:
> +               return false;
> +       default:
> +               return true;
> +       }
> +}
> +
>  /* check whether memory at (regno + off) is accessible for t = (read | write)
>   * if t==write, value_regno is a register which value is stored into memory
>   * if t==read, value_regno is a register which will receive the value from memory
> @@ -669,11 +697,21 @@ static int check_mem_access(struct verifier_env *env, u32 regno, int off,
>         }
>
>         if (state->regs[regno].type == PTR_TO_MAP_VALUE) {
> +               if (t == BPF_WRITE && value_regno >= 0 &&
> +                   is_pointer_value(env, value_regno)) {
> +                       verbose("R%d leaks addr into map\n", value_regno);
> +                       return -EACCES;
> +               }
>                 err = check_map_access(env, regno, off, size);
>                 if (!err && t == BPF_READ && value_regno >= 0)
>                         mark_reg_unknown_value(state->regs, value_regno);
>
>         } else if (state->regs[regno].type == PTR_TO_CTX) {
> +               if (t == BPF_WRITE && value_regno >= 0 &&
> +                   is_pointer_value(env, value_regno)) {
> +                       verbose("R%d leaks addr into ctx\n", value_regno);
> +                       return -EACCES;
> +               }
>                 err = check_ctx_access(env, off, size, t);
>                 if (!err && t == BPF_READ && value_regno >= 0)
>                         mark_reg_unknown_value(state->regs, value_regno);
> @@ -684,10 +722,17 @@ static int check_mem_access(struct verifier_env *env, u32 regno, int off,
>                         verbose("invalid stack off=%d size=%d\n", off, size);
>                         return -EACCES;
>                 }
> -               if (t == BPF_WRITE)
> +               if (t == BPF_WRITE) {
> +                       if (!env->allow_ptr_leaks &&
> +                           state->stack_slot_type[MAX_BPF_STACK + off] == STACK_SPILL &&
> +                           size != BPF_REG_SIZE) {
> +                               verbose("attempt to corrupt spilled pointer on stack\n");
> +                               return -EACCES;
> +                       }
>                         err = check_stack_write(state, off, size, value_regno);
> -               else
> +               } else {
>                         err = check_stack_read(state, off, size, value_regno);
> +               }
>         } else {
>                 verbose("R%d invalid mem access '%s'\n",
>                         regno, reg_type_str[state->regs[regno].type]);
> @@ -775,8 +820,13 @@ static int check_func_arg(struct verifier_env *env, u32 regno,
>                 return -EACCES;
>         }
>
> -       if (arg_type == ARG_ANYTHING)
> +       if (arg_type == ARG_ANYTHING) {
> +               if (is_pointer_value(env, regno)) {
> +                       verbose("R%d leaks addr into helper function\n", regno);
> +                       return -EACCES;
> +               }
>                 return 0;
> +       }
>
>         if (arg_type == ARG_PTR_TO_STACK || arg_type == ARG_PTR_TO_MAP_KEY ||
>             arg_type == ARG_PTR_TO_MAP_VALUE) {
> @@ -950,8 +1000,9 @@ static int check_call(struct verifier_env *env, int func_id)
>  }
>
>  /* check validity of 32-bit and 64-bit arithmetic operations */
> -static int check_alu_op(struct reg_state *regs, struct bpf_insn *insn)
> +static int check_alu_op(struct verifier_env *env, struct bpf_insn *insn)
>  {
> +       struct reg_state *regs = env->cur_state.regs;
>         u8 opcode = BPF_OP(insn->code);
>         int err;
>
> @@ -976,6 +1027,12 @@ static int check_alu_op(struct reg_state *regs, struct bpf_insn *insn)
>                 if (err)
>                         return err;
>
> +               if (is_pointer_value(env, insn->dst_reg)) {
> +                       verbose("R%d pointer arithmetic prohibited\n",
> +                               insn->dst_reg);
> +                       return -EACCES;
> +               }
> +
>                 /* check dest operand */
>                 err = check_reg_arg(regs, insn->dst_reg, DST_OP);
>                 if (err)
> @@ -1012,6 +1069,11 @@ static int check_alu_op(struct reg_state *regs, struct bpf_insn *insn)
>                                  */
>                                 regs[insn->dst_reg] = regs[insn->src_reg];
>                         } else {
> +                               if (is_pointer_value(env, insn->src_reg)) {
> +                                       verbose("R%d partial copy of pointer\n",
> +                                               insn->src_reg);
> +                                       return -EACCES;
> +                               }
>                                 regs[insn->dst_reg].type = UNKNOWN_VALUE;
>                                 regs[insn->dst_reg].map_ptr = NULL;
>                         }
> @@ -1061,8 +1123,18 @@ static int check_alu_op(struct reg_state *regs, struct bpf_insn *insn)
>                 /* pattern match 'bpf_add Rx, imm' instruction */
>                 if (opcode == BPF_ADD && BPF_CLASS(insn->code) == BPF_ALU64 &&
>                     regs[insn->dst_reg].type == FRAME_PTR &&
> -                   BPF_SRC(insn->code) == BPF_K)
> +                   BPF_SRC(insn->code) == BPF_K) {
>                         stack_relative = true;
> +               } else if (is_pointer_value(env, insn->dst_reg)) {
> +                       verbose("R%d pointer arithmetic prohibited\n",
> +                               insn->dst_reg);
> +                       return -EACCES;
> +               } else if (BPF_SRC(insn->code) == BPF_X &&
> +                          is_pointer_value(env, insn->src_reg)) {
> +                       verbose("R%d pointer arithmetic prohibited\n",
> +                               insn->src_reg);
> +                       return -EACCES;
> +               }
>
>                 /* check dest operand */
>                 err = check_reg_arg(regs, insn->dst_reg, DST_OP);
> @@ -1101,6 +1173,12 @@ static int check_cond_jmp_op(struct verifier_env *env,
>                 err = check_reg_arg(regs, insn->src_reg, SRC_OP);
>                 if (err)
>                         return err;
> +
> +               if (is_pointer_value(env, insn->src_reg)) {
> +                       verbose("R%d pointer comparison prohibited\n",
> +                               insn->src_reg);
> +                       return -EACCES;
> +               }
>         } else {
>                 if (insn->src_reg != BPF_REG_0) {
>                         verbose("BPF_JMP uses reserved fields\n");
> @@ -1155,6 +1233,9 @@ static int check_cond_jmp_op(struct verifier_env *env,
>                         regs[insn->dst_reg].type = CONST_IMM;
>                         regs[insn->dst_reg].imm = 0;
>                 }
> +       } else if (is_pointer_value(env, insn->dst_reg)) {
> +               verbose("R%d pointer comparison prohibited\n", insn->dst_reg);
> +               return -EACCES;
>         } else if (BPF_SRC(insn->code) == BPF_K &&
>                    (opcode == BPF_JEQ || opcode == BPF_JNE)) {
>
> @@ -1658,7 +1739,7 @@ static int do_check(struct verifier_env *env)
>                 }
>
>                 if (class == BPF_ALU || class == BPF_ALU64) {
> -                       err = check_alu_op(regs, insn);
> +                       err = check_alu_op(env, insn);
>                         if (err)
>                                 return err;
>
> @@ -1816,6 +1897,11 @@ static int do_check(struct verifier_env *env)
>                                 if (err)
>                                         return err;
>
> +                               if (is_pointer_value(env, BPF_REG_0)) {
> +                                       verbose("R0 leaks addr as return value\n");
> +                                       return -EACCES;
> +                               }
> +
>  process_bpf_exit:
>                                 insn_idx = pop_stack(env, &prev_insn_idx);
>                                 if (insn_idx < 0) {
> @@ -2144,6 +2230,8 @@ int bpf_check(struct bpf_prog **prog, union bpf_attr *attr)
>         if (ret < 0)
>                 goto skip_full_check;
>
> +       env->allow_ptr_leaks = capable(CAP_SYS_ADMIN);
> +
>         ret = do_check(env);
>
>  skip_full_check:
> diff --git a/kernel/sysctl.c b/kernel/sysctl.c
> index e69201d8094e..96c856b04081 100644
> --- a/kernel/sysctl.c
> +++ b/kernel/sysctl.c
> @@ -64,6 +64,7 @@
>  #include <linux/binfmts.h>
>  #include <linux/sched/sysctl.h>
>  #include <linux/kexec.h>
> +#include <linux/bpf.h>
>
>  #include <asm/uaccess.h>
>  #include <asm/processor.h>
> @@ -1139,6 +1140,18 @@ static struct ctl_table kern_table[] = {
>                 .proc_handler   = timer_migration_handler,
>         },
>  #endif
> +#ifdef CONFIG_BPF_SYSCALL
> +       {
> +               .procname       = "unprivileged_bpf_disabled",
> +               .data           = &sysctl_unprivileged_bpf_disabled,
> +               .maxlen         = sizeof(sysctl_unprivileged_bpf_disabled),
> +               .mode           = 0644,
> +               /* only handle a transition from default "0" to "1" */
> +               .proc_handler   = proc_dointvec_minmax,
> +               .extra1         = &one,
> +               .extra2         = &one,
> +       },
> +#endif
>         { }
>  };
>
> diff --git a/net/core/filter.c b/net/core/filter.c
> index cbaa23c3fb30..8fb3acbbe4cb 100644
> --- a/net/core/filter.c
> +++ b/net/core/filter.c
> @@ -1644,7 +1644,8 @@ sk_filter_func_proto(enum bpf_func_id func_id)
>         case BPF_FUNC_ktime_get_ns:
>                 return &bpf_ktime_get_ns_proto;
>         case BPF_FUNC_trace_printk:
> -               return bpf_get_trace_printk_proto();
> +               if (capable(CAP_SYS_ADMIN))
> +                       return bpf_get_trace_printk_proto();
>         default:
>                 return NULL;
>         }
> --
> 1.7.9.5
>



-- 
Kees Cook
Chrome OS Security
