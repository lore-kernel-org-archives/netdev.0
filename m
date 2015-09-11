From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v2 4/5] seccomp: add a way to access filters via bpf fds
Date: Fri, 11 Sep 2015 13:47:38 +0200
Message-ID: <55F2BF5A.8010006@iogearbox.net>
References: <1441930862-14347-1-git-send-email-tycho.andersen@canonical.com> <1441930862-14347-5-git-send-email-tycho.andersen@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Will Drewry <wad@chromium.org>,
	Oleg Nesterov <oleg@redhat.com>,
	Andy Lutomirski <luto@amacapital.net>,
	Pavel Emelyanov <xemul@parallels.com>,
	"Serge E. Hallyn" <serge.hallyn@ubuntu.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-api@vger.kernel.org
To: Tycho Andersen <tycho.andersen@canonical.com>,
	Kees Cook <keescook@chromium.org>,
	Alexei Starovoitov <ast@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1441930862-14347-5-git-send-email-tycho.andersen@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/11/2015 02:21 AM, Tycho Andersen wrote:
> This patch adds a way for a process that is "real root" to access the
> seccomp filters of another process. The process first does a
> PTRACE_SECCOMP_GET_FILTER_FD to get an fd with that process' seccomp filter
> attached, and then iterates on this with PTRACE_SECCOMP_NEXT_FILTER using
> bpf(BPF_PROG_DUMP) to dump the actual program at each step.
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
[...]
> diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
> index 58ae9f4..ac3ed1c 100644
> --- a/kernel/bpf/syscall.c
> +++ b/kernel/bpf/syscall.c
> @@ -506,6 +506,30 @@ struct bpf_prog *bpf_prog_get(u32 ufd)
>   }
>   EXPORT_SYMBOL_GPL(bpf_prog_get);
>
> +int bpf_prog_set(u32 ufd, struct bpf_prog *new)
> +{
> +	struct fd f;
> +	struct bpf_prog *prog;
> +
> +	f = fdget(ufd);
> +
> +	prog = get_prog(f);
> +	if (!IS_ERR(prog) && prog)
> +		bpf_prog_put(prog);
> +
> +	atomic_inc(&new->aux->refcnt);
> +	f.file->private_data = new;
> +	fdput(f);
> +	return 0;

So in case get_prog() fails, and for example f.file is infact NULL,
you assign the bpf prog then to ERR_PTR(-EBADF)'s private_data? :(

> +}
> +EXPORT_SYMBOL_GPL(bpf_prog_set);
> +
> +int bpf_new_fd(struct bpf_prog *prog, int flags)
> +{
> +	return anon_inode_getfd("bpf-prog", &bpf_prog_fops, prog, flags);
> +}
> +EXPORT_SYMBOL_GPL(bpf_new_fd);

Any reason why these two need to be exported for modules? Which
modules are using them?

I think modules should probably not mess with this.

If you already name it generic, it would also be good if bpf_new_fd()
is used in case of maps that call anon_inode_getfd(), too.
