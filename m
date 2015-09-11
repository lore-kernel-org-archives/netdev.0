From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Subject: Re: [PATCH v2 1/5] ebpf: add a seccomp program type
Date: Fri, 11 Sep 2015 14:09:45 +0200
Message-ID: <CAKgNAkhtb5=9QvkOqx+LeUmz2V-bzowyf-VepG3Oe2gW1BSGmw@mail.gmail.com>
References: <1441930862-14347-1-git-send-email-tycho.andersen@canonical.com> <1441930862-14347-2-git-send-email-tycho.andersen@canonical.com>
Reply-To: mtk.manpages@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Kees Cook <keescook@chromium.org>,
	Alexei Starovoitov <ast@kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Will Drewry <wad@chromium.org>,
	Oleg Nesterov <oleg@redhat.com>,
	Andy Lutomirski <luto@amacapital.net>,
	Pavel Emelyanov <xemul@parallels.com>,
	"Serge E. Hallyn" <serge.hallyn@ubuntu.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	lkml <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Linux API <linux-api@vger.kernel.org>
To: Tycho Andersen <tycho.andersen@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1441930862-14347-2-git-send-email-tycho.andersen@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11 September 2015 at 02:20, Tycho Andersen
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

Hi Tycho,

Seems like a man-pages patch is warranted here also?

Cheers,

Michael


> v2: * don't allow seccomp eBPF programs to call any functions
>     * get rid of superfluous seccomp_convert_ctx_access
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
>  net/core/filter.c        | 31 +++++++++++++++++++++++++++++++
>  2 files changed, 32 insertions(+)
>
> diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
> index 92a48e2..631cdee 100644
> --- a/include/uapi/linux/bpf.h
> +++ b/include/uapi/linux/bpf.h
> @@ -123,6 +123,7 @@ enum bpf_prog_type {
>         BPF_PROG_TYPE_KPROBE,
>         BPF_PROG_TYPE_SCHED_CLS,
>         BPF_PROG_TYPE_SCHED_ACT,
> +       BPF_PROG_TYPE_SECCOMP,
>  };
>
>  #define BPF_PSEUDO_MAP_FD      1
> diff --git a/net/core/filter.c b/net/core/filter.c
> index 13079f0..faaae67 100644
> --- a/net/core/filter.c
> +++ b/net/core/filter.c
> @@ -1612,6 +1612,15 @@ tc_cls_act_func_proto(enum bpf_func_id func_id)
>         }
>  }
>
> +static const struct bpf_func_proto *
> +seccomp_func_proto(enum bpf_func_id func_id)
> +{
> +       /* At some point in the future seccomp filters may grow support for
> +        * eBPF functions. For now, these are disabled.
> +        */
> +       return NULL;
> +}
> +
>  static bool __is_valid_access(int off, int size, enum bpf_access_type type)
>  {
>         /* check bounds */
> @@ -1662,6 +1671,17 @@ static bool tc_cls_act_is_valid_access(int off, int size,
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
> @@ -1795,6 +1815,11 @@ static const struct bpf_verifier_ops tc_cls_act_ops = {
>         .convert_ctx_access = bpf_net_convert_ctx_access,
>  };
>
> +static const struct bpf_verifier_ops seccomp_ops = {
> +       .get_func_proto = seccomp_func_proto,
> +       .is_valid_access = seccomp_is_valid_access,
> +};
> +
>  static struct bpf_prog_type_list sk_filter_type __read_mostly = {
>         .ops = &sk_filter_ops,
>         .type = BPF_PROG_TYPE_SOCKET_FILTER,
> @@ -1810,11 +1835,17 @@ static struct bpf_prog_type_list sched_act_type __read_mostly = {
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
> --
> To unsubscribe from this list: send the line "unsubscribe linux-api" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/
