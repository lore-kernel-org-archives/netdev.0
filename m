From: Masami Hiramatsu <masami.hiramatsu.pt-FCd8Q96Dh0JBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH v5 tip 1/7] bpf: make internal bpf API independent
 of CONFIG_BPF_SYSCALL ifdefs
Date: Mon, 02 Mar 2015 19:53:09 +0900
Message-ID: <54F44115.40505@hitachi.com>
References: <1425252465-27527-1-git-send-email-ast@plumgrid.com> <1425252465-27527-2-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>,
	Namhyung Kim <namhyung-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Arnaldo Carvalho de Melo <acme-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Jiri Olsa <jolsa-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
	Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1425252465-27527-2-git-send-email-ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

(2015/03/02 8:27), Alexei Starovoitov wrote:
> From: Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
> 
> Socket filter code and other subsystems with upcoming eBPF support should
> not need to deal with the fact that we have CONFIG_BPF_SYSCALL defined or
> not.
> 
> Having the bpf syscall as a config option is a nice thing and I'd expect
> it to stay that way for expert users (I presume one day the default setting
> of it might change, though), but code making use of it should not care if
> it's actually enabled or not.

Hmm, it seems that this still doesn't hide some APIs which is provided
only when CONFIG_BPF_SYSCALL. For example bpf_register_map_type etc.
I think all those APIs should be hidden in #ifdef or at least be commented
so that the user doesn't refer that without the kconfig.
(I don't think we need to provide dummy functions for those APIs,
 but it's better to clarify which API we can use with which kconfig)

Thank you,

> 
> Instead, hide this via header files and let the rest deal with it.
> 
> Signed-off-by: Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
> Signed-off-by: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
> ---
>  include/linux/bpf.h |   20 ++++++++++++++++----
>  1 file changed, 16 insertions(+), 4 deletions(-)
> 
> diff --git a/include/linux/bpf.h b/include/linux/bpf.h
> index bbfceb756452..c2e21113ecc0 100644
> --- a/include/linux/bpf.h
> +++ b/include/linux/bpf.h
> @@ -113,8 +113,6 @@ struct bpf_prog_type_list {
>  	enum bpf_prog_type type;
>  };
>  
> -void bpf_register_prog_type(struct bpf_prog_type_list *tl);
> -
>  struct bpf_prog;
>  
>  struct bpf_prog_aux {
> @@ -129,11 +127,25 @@ struct bpf_prog_aux {
>  };
>  
>  #ifdef CONFIG_BPF_SYSCALL
> +void bpf_register_prog_type(struct bpf_prog_type_list *tl);
> +
>  void bpf_prog_put(struct bpf_prog *prog);
> +struct bpf_prog *bpf_prog_get(u32 ufd);
>  #else
> -static inline void bpf_prog_put(struct bpf_prog *prog) {}
> +static inline void bpf_register_prog_type(struct bpf_prog_type_list *tl)
> +{
> +}
> +
> +static inline struct bpf_prog *bpf_prog_get(u32 ufd)
> +{
> +	return ERR_PTR(-EOPNOTSUPP);
> +}
> +
> +static inline void bpf_prog_put(struct bpf_prog *prog)
> +{
> +}
>  #endif
> -struct bpf_prog *bpf_prog_get(u32 ufd);
> +
>  /* verify correctness of eBPF program */
>  int bpf_check(struct bpf_prog *fp, union bpf_attr *attr);
>  
> 


-- 
Masami HIRAMATSU
Software Platform Research Dept. Linux Technology Research Center
Hitachi, Ltd., Yokohama Research Laboratory
E-mail: masami.hiramatsu.pt-FCd8Q96Dh0JBDgjK7y7TUQ@public.gmane.org
