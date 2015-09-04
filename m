From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH 1/6] ebpf: add a seccomp program type
Date: Fri, 4 Sep 2015 14:50:39 -0700
Message-ID: <CALCETrVhmBS+uEjYwCE=CzkXL5C+mysj=Rq=jMD3LTqbZUDD-g@mail.gmail.com>
References: <1441382664-17437-1-git-send-email-tycho.andersen@canonical.com> <1441382664-17437-2-git-send-email-tycho.andersen@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Kees Cook <keescook@chromium.org>,
	Alexei Starovoitov <ast@kernel.org>,
	Will Drewry <wad@chromium.org>,
	Oleg Nesterov <oleg@redhat.com>,
	Pavel Emelyanov <xemul@parallels.com>,
	"Serge E. Hallyn" <serge.hallyn@ubuntu.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
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

I don't think we should expose prandom to unprivileged userspace.
This may be an attack vector.

Also, before we allow anything with side effects, we should think
carefully about whether seccomp filters with side effects (other than
through their return value) are okay.

--Andy
