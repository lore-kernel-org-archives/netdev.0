From: Kees Cook <keescook@chromium.org>
Subject: Re: [PATCH 1/6] ebpf: add a seccomp program type
Date: Fri, 4 Sep 2015 13:34:12 -0700
Message-ID: <CAGXu5j+9YvL6XzX=x8krZbdJXFpe-3FuMu=hAZX9Ew=hYyuK7Q@mail.gmail.com>
References: <1441382664-17437-1-git-send-email-tycho.andersen@canonical.com>
	<1441382664-17437-2-git-send-email-tycho.andersen@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexei Starovoitov <ast@kernel.org>,
	Will Drewry <wad@chromium.org>,
	Oleg Nesterov <oleg@redhat.com>,
	Andy Lutomirski <luto@amacapital.net>,
	Pavel Emelyanov <xemul@parallels.com>,
	"Serge E. Hallyn" <serge.hallyn@ubuntu.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	LKML <linux-kernel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>
To: Tycho Andersen <tycho.andersen@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1441382664-17437-2-git-send-email-tycho.andersen@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 4, 2015 at 9:04 AM, Tycho Andersen
<tycho.andersen@canonical.com> wrote:
> seccomp uses eBPF as its underlying storage and execution format, and eBPF
> has features that seccomp would like to make use of in the future. This
> patch adds a formal seccomp type to the eBPF verifier.
>
> The current implementation of the seccomp eBPF type is very limited, and
> doesn't support some interesting features (notably, maps) of eBPF. However,
> the primary motivation for this patchset is to enable checkpoint/restore
> for seccomp filters later in the series, to this limited feature set is ok
> for now.
>
> Signed-off-by: Tycho Andersen <tycho.andersen@canonical.com>
> CC: Kees Cook <keescook@chromium.org>
> CC: Will Drewry <wad@chromium.org>
> CC: Oleg Nesterov <oleg@redhat.com>
> CC: Andy Lutomirski <luto@amacapital.net>
> CC: Pavel Emelyanov <xemul@parallels.com>
> CC: Serge E. Hallyn <serge.hallyn@ubuntu.com>
> CC: Alexei Starovoitov <ast@kernel.org>
> CC: Daniel Borkmann <daniel@iogearbox.net>
> ---
>  include/uapi/linux/bpf.h |  1 +
>  net/core/filter.c        | 95 ++++++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 96 insertions(+)
>
> diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
> index 29ef6f9..79b825a 100644
> --- a/include/uapi/linux/bpf.h
> +++ b/include/uapi/linux/bpf.h
> @@ -122,6 +122,7 @@ enum bpf_prog_type {
>         BPF_PROG_TYPE_KPROBE,
>         BPF_PROG_TYPE_SCHED_CLS,
>         BPF_PROG_TYPE_SCHED_ACT,
> +       BPF_PROG_TYPE_SECCOMP,
>  };
>
>  #define BPF_PSEUDO_MAP_FD      1
> diff --git a/net/core/filter.c b/net/core/filter.c
> index be3098f..ed339fa 100644
> --- a/net/core/filter.c
> +++ b/net/core/filter.c
> @@ -1466,6 +1466,39 @@ tc_cls_act_func_proto(enum bpf_func_id func_id)
>         }
>  }
>
> +static const struct bpf_func_proto *
> +seccomp_func_proto(enum bpf_func_id func_id)
> +{
> +       /* Right now seccomp eBPF loading doesn't support maps; seccomp filters
> +        * are considered to be read-only after they're installed, so map fds
> +        * probably need to be invalidated when a seccomp filter with maps is
> +        * installed.
> +        *
> +        * The rest of these might be reasonable to call from seccomp, so we
> +        * export them.
> +        */
> +       switch (func_id) {
> +       case BPF_FUNC_ktime_get_ns:
> +               return &bpf_ktime_get_ns_proto;
> +       case BPF_FUNC_trace_printk:
> +               return bpf_get_trace_printk_proto();
> +       case BPF_FUNC_get_prandom_u32:
> +               return &bpf_get_prandom_u32_proto;
> +       case BPF_FUNC_get_smp_processor_id:
> +               return &bpf_get_smp_processor_id_proto;
> +       case BPF_FUNC_tail_call:
> +               return &bpf_tail_call_proto;
> +       case BPF_FUNC_get_current_pid_tgid:
> +               return &bpf_get_current_pid_tgid_proto;
> +       case BPF_FUNC_get_current_uid_gid:
> +               return &bpf_get_current_uid_gid_proto;
> +       case BPF_FUNC_get_current_comm:
> +               return &bpf_get_current_comm_proto;
> +       default:
> +               return NULL;
> +       }
> +}

While this list is probably fine, I don't want to mix the addition of
eBPF functions to the seccomp ABI with the CRIU changes. No function
calls are currently possible and it should stay that way.

I was expecting to see a validator, similar to the existing BPF
validator that is called when creating seccomp filters currently. Can
we add a similar validator for new BPF_PROG_TYPE_SECCOMP?

-Kees

> +
>  static bool __is_valid_access(int off, int size, enum bpf_access_type type)
>  {
>         /* check bounds */
> @@ -1516,6 +1549,17 @@ static bool tc_cls_act_is_valid_access(int off, int size,
>         return __is_valid_access(off, size, type);
>  }
>
> +static bool seccomp_is_valid_access(int off, int size,
> +                                   enum bpf_access_type type)
> +{
> +       if (type == BPF_WRITE)
> +               return false;
> +
> +       if (off < 0 || off >= sizeof(struct seccomp_data) || off & 3)
> +               return false;
> +
> +       return true;
> +}
>  static u32 bpf_net_convert_ctx_access(enum bpf_access_type type, int dst_reg,
>                                       int src_reg, int ctx_off,
>                                       struct bpf_insn *insn_buf)
> @@ -1630,6 +1674,45 @@ static u32 bpf_net_convert_ctx_access(enum bpf_access_type type, int dst_reg,
>         return insn - insn_buf;
>  }
>
> +static u32 seccomp_convert_ctx_access(enum bpf_access_type type, int dst_reg,
> +                                     int src_reg, int ctx_off,
> +                                     struct bpf_insn *insn_buf)
> +{
> +       struct bpf_insn *insn = insn_buf;
> +
> +       switch (ctx_off) {
> +       case offsetof(struct seccomp_data, nr):
> +               BUILD_BUG_ON(FIELD_SIZEOF(struct seccomp_data, nr) != 4);
> +
> +               *insn++ = BPF_LDX_MEM(BPF_W, dst_reg, src_reg, ctx_off);
> +               break;
> +
> +       case offsetof(struct seccomp_data, arch):
> +               BUILD_BUG_ON(FIELD_SIZEOF(struct seccomp_data, arch) != 4);
> +
> +               *insn++ = BPF_LDX_MEM(BPF_W, dst_reg, src_reg, ctx_off);
> +               break;
> +
> +       case offsetof(struct seccomp_data, instruction_pointer):
> +               BUILD_BUG_ON(FIELD_SIZEOF(struct seccomp_data,
> +                                         instruction_pointer) != 8);
> +
> +               *insn++ = BPF_LDX_MEM(BPF_DW, dst_reg, src_reg, ctx_off);
> +               break;
> +
> +       default:
> +               if (ctx_off & 7 ||
> +                   ctx_off < offsetof(struct seccomp_data, args))
> +                       return -EINVAL;
> +
> +               BUILD_BUG_ON(FIELD_SIZEOF(struct seccomp_data, args[0]) != 8);
> +
> +               *insn++ = BPF_LDX_MEM(BPF_DW, dst_reg, src_reg, ctx_off);
> +       }
> +
> +       return insn - insn_buf;
> +}
> +
>  static const struct bpf_verifier_ops sk_filter_ops = {
>         .get_func_proto = sk_filter_func_proto,
>         .is_valid_access = sk_filter_is_valid_access,
> @@ -1642,6 +1725,12 @@ static const struct bpf_verifier_ops tc_cls_act_ops = {
>         .convert_ctx_access = bpf_net_convert_ctx_access,
>  };
>
> +static const struct bpf_verifier_ops seccomp_ops = {
> +       .get_func_proto = seccomp_func_proto,
> +       .is_valid_access = seccomp_is_valid_access,
> +       .convert_ctx_access = seccomp_convert_ctx_access,
> +};
> +
>  static struct bpf_prog_type_list sk_filter_type __read_mostly = {
>         .ops = &sk_filter_ops,
>         .type = BPF_PROG_TYPE_SOCKET_FILTER,
> @@ -1657,11 +1746,17 @@ static struct bpf_prog_type_list sched_act_type __read_mostly = {
>         .type = BPF_PROG_TYPE_SCHED_ACT,
>  };
>
> +static struct bpf_prog_type_list seccomp_type __read_mostly = {
> +       .ops = &seccomp_ops,
> +       .type = BPF_PROG_TYPE_SECCOMP,
> +};
> +
>  static int __init register_sk_filter_ops(void)
>  {
>         bpf_register_prog_type(&sk_filter_type);
>         bpf_register_prog_type(&sched_cls_type);
>         bpf_register_prog_type(&sched_act_type);
> +       bpf_register_prog_type(&seccomp_type);
>
>         return 0;
>  }
> --
> 2.1.4
>



-- 
Kees Cook
Chrome OS Security
