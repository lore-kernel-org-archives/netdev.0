From: Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v2 3/5] ebpf: add a way to dump an eBPF program
Date: Thu, 10 Sep 2015 19:29:42 -0700
Message-ID: <20150911022940.GA4903@Alexeis-MacBook-Pro-2.local>
References: <1441930862-14347-1-git-send-email-tycho.andersen@canonical.com>
 <1441930862-14347-4-git-send-email-tycho.andersen@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	Alexei Starovoitov <ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Will Drewry <wad-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
	Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	"Serge E. Hallyn" <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>,
	Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Tycho Andersen <tycho.andersen-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1441930862-14347-4-git-send-email-tycho.andersen-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 10, 2015 at 06:21:00PM -0600, Tycho Andersen wrote:
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
> +
> +	ret = -EFAULT;
> +	if (put_user(prog->len, &uattr->dump_insn_cnt))
> +		goto out;
> +
> +	if (put_user((u8) prog->gpl_compatible, &uattr->gpl_compatible))
> +		goto out;
> +
> +	if (attr->dump_insns) {
> +		u32 len = prog->len * sizeof(struct bpf_insn);
> +
> +		if (copy_to_user(u64_to_ptr(attr->dump_insns),
> +				 prog->insns, len) != 0)
> +			goto out;
> +	}
> +
> +	ret = 0;
> +out:
> +	return ret;

fdput() is missing in all error paths.
