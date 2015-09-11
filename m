From: Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
Subject: Re: [PATCH v2 3/5] ebpf: add a way to dump an eBPF program
Date: Fri, 11 Sep 2015 15:39:14 +0200
Message-ID: <55F2D982.8010406@iogearbox.net>
References: <1441930862-14347-1-git-send-email-tycho.andersen@canonical.com> <1441930862-14347-4-git-send-email-tycho.andersen@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Will Drewry <wad-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
	Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	"Serge E. Hallyn" <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Tycho Andersen <tycho.andersen-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	Alexei Starovoitov <ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1441930862-14347-4-git-send-email-tycho.andersen-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 09/11/2015 02:21 AM, Tycho Andersen wrote:
> This commit adds a way to dump eBPF programs. The initial implementation
> doesn't support maps, and therefore only allows dumping seccomp ebpf
> programs which themselves don't currently support maps.
>
> v2: don't export a prog_id for the filter
>
> Signed-off-by: Tycho Andersen <tycho.andersen-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
> CC: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
> CC: Will Drewry <wad-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
> CC: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> CC: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
> CC: Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
> CC: Serge E. Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
> CC: Alexei Starovoitov <ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> CC: Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
[...]
> diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
> index dc9b464..58ae9f4 100644
> --- a/kernel/bpf/syscall.c
> +++ b/kernel/bpf/syscall.c
> @@ -586,6 +586,44 @@ free_prog:
>   	return err;
>   }
>
> +static int bpf_prog_dump(union bpf_attr *attr, union bpf_attr __user *uattr)
> +{
> +	int ufd = attr->prog_fd;
> +	struct fd f = fdget(ufd);
> +	struct bpf_prog *prog;
> +	int ret = -EINVAL;
> +
> +	prog = get_prog(f);
> +	if (IS_ERR(prog))
> +		return PTR_ERR(prog);
> +
> +	/* For now, let's refuse to dump anything that isn't a seccomp program.
> +	 * Other program types have support for maps, which our current dump
> +	 * code doesn't support.
> +	 */
> +	if (prog->type != BPF_PROG_TYPE_SECCOMP)
> +		goto out;

Yep, also when you start adding helper calls (next to map objects) you'd
need to undo kernel pointers that the verifier sets here.
