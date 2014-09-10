From: Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v11 net-next 04/12] bpf: expand BPF syscall with program
 load/unload
Date: Wed, 10 Sep 2014 10:04:58 +0200
Message-ID: <5410062A.4090003@redhat.com>
References: <1410325808-3657-1-git-send-email-ast@plumgrid.com> <1410325808-3657-5-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Linus Torvalds <torvalds-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
	Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>,
	Hannes Frederic Sowa <hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>,
	Chema Gonzalez <chema-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>,
	Pablo Neira Ayuso <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>,
	"H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>,
	Andrew Morton <akpm-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1410325808-3657-5-git-send-email-ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 09/10/2014 07:10 AM, Alexei Starovoitov wrote:
> eBPF programs are similar to kernel modules. They are loaded by the user
> process and automatically unloaded when process exits. Each eBPF program is
> a safe run-to-completion set of instructions. eBPF verifier statically
> determines that the program terminates and is safe to execute.
>
> The following syscall wrapper can be used to load the program:
> int bpf_prog_load(enum bpf_prog_type prog_type,
>                    const struct bpf_insn *insns, int insn_cnt,
>                    const char *license)
> {
>      union bpf_attr attr = {
>          .prog_type = prog_type,
>          .insns = insns,
>          .insn_cnt = insn_cnt,
>          .license = license,
>      };
>
>      return bpf(BPF_PROG_LOAD, &attr, sizeof(attr));
> }
> where 'insns' is an array of eBPF instructions and 'license' is a string
> that must be GPL compatible to call helper functions marked gpl_only
>
> Upon succesful load the syscall returns prog_fd.
> Use close(prog_fd) to unload the program.
>
> User space tests and examples follow in the later patches
>
> Signed-off-by: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
...
> diff --git a/include/linux/filter.h b/include/linux/filter.h
> index 4b59edead908..9727616693e5 100644
> --- a/include/linux/filter.h
> +++ b/include/linux/filter.h
> @@ -15,6 +15,7 @@
>   struct sk_buff;
>   struct sock;
>   struct seccomp_data;
> +struct bpf_prog_info;
>
>   /* ArgX, context and stack frame pointer register positions. Note,
>    * Arg1, Arg2, Arg3, etc are used as argument mappings of function
> @@ -302,8 +303,12 @@ struct bpf_work_struct {
>   struct bpf_prog {
>   	u16			pages;		/* Number of allocated pages */
>   	bool			jited;		/* Is our filter JIT'ed? */
> +	bool			has_info;	/* whether 'info' is valid */
>   	u32			len;		/* Number of filter blocks */
> -	struct sock_fprog_kern	*orig_prog;	/* Original BPF program */
> +	union {
> +		struct sock_fprog_kern	*orig_prog;	/* Original BPF program */
> +		struct bpf_prog_info	*info;
> +	};

All members of this bpf_prog_info should go into bpf_work_struct,
as I have intended this to be a ancillary structure here. Since
we already allocate this anyway, you can reduce complexity by doing
the additional allocation plus remove the has_info member.

>   	struct bpf_work_struct	*work;		/* Deferred free work struct */
>   	unsigned int		(*bpf_func)(const struct sk_buff *skb,
>   					    const struct bpf_insn *filter);
> diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
> index 3a03fdf4db0e..1d0411965576 100644
> --- a/include/uapi/linux/bpf.h
> +++ b/include/uapi/linux/bpf.h
> @@ -99,12 +99,23 @@ enum bpf_cmd {
...
> +/* called by sockets/tracing/seccomp before attaching program to an event
> + * pairs with bpf_prog_put()
> + */

But seccomp already does refcounting on each BPF filter. Or, is the
intention to remove this from seccomp?

> +struct bpf_prog *bpf_prog_get(u32 ufd)
> +{
> +	struct fd f = fdget(ufd);
> +	struct bpf_prog *prog;
> +
> +	prog = get_prog(f);
> +
> +	if (IS_ERR(prog))
> +		return prog;
> +
> +	atomic_inc(&prog->info->refcnt);
> +	fdput(f);
> +	return prog;
> +}
...
> diff --git a/net/core/filter.c b/net/core/filter.c
> index dfc716ffa44b..d771e4f03745 100644
> --- a/net/core/filter.c
> +++ b/net/core/filter.c
> @@ -835,6 +835,7 @@ static void bpf_release_orig_filter(struct bpf_prog *fp)
>   {
>   	struct sock_fprog_kern *fprog = fp->orig_prog;
>
> +	BUG_ON(fp->has_info);

Why BUG_ON() (also in so many other places)?

>   	if (fprog) {
>   		kfree(fprog->filter);
>   		kfree(fprog);
> @@ -973,6 +974,7 @@ static struct bpf_prog *bpf_prepare_filter(struct bpf_prog *fp)
>
>   	fp->bpf_func = NULL;
>   	fp->jited = false;
> +	fp->has_info = false;
>
>   	err = bpf_check_classic(fp->insns, fp->len);
>   	if (err) {
>
