From: Tycho Andersen <tycho.andersen-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: [PATCH v2 4/5] seccomp: add a way to access filters via bpf fds
Date: Fri, 11 Sep 2015 08:29:42 -0600
Message-ID: <20150911142942.GF27574@smitten>
References: <1441930862-14347-1-git-send-email-tycho.andersen@canonical.com>
 <1441930862-14347-5-git-send-email-tycho.andersen@canonical.com>
 <55F2BF5A.8010006@iogearbox.net>
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
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <55F2BF5A.8010006-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 11, 2015 at 01:47:38PM +0200, Daniel Borkmann wrote:
> On 09/11/2015 02:21 AM, Tycho Andersen wrote:
> >This patch adds a way for a process that is "real root" to access the
> >seccomp filters of another process. The process first does a
> >PTRACE_SECCOMP_GET_FILTER_FD to get an fd with that process' seccomp filter
> >attached, and then iterates on this with PTRACE_SECCOMP_NEXT_FILTER using
> >bpf(BPF_PROG_DUMP) to dump the actual program at each step.
> >
> >Signed-off-by: Tycho Andersen <tycho.andersen-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
> >CC: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
> >CC: Will Drewry <wad-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
> >CC: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> >CC: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
> >CC: Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
> >CC: Serge E. Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
> >CC: Alexei Starovoitov <ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> >CC: Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
> [...]
> >diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
> >index 58ae9f4..ac3ed1c 100644
> >--- a/kernel/bpf/syscall.c
> >+++ b/kernel/bpf/syscall.c
> >@@ -506,6 +506,30 @@ struct bpf_prog *bpf_prog_get(u32 ufd)
> >  }
> >  EXPORT_SYMBOL_GPL(bpf_prog_get);
> >
> >+int bpf_prog_set(u32 ufd, struct bpf_prog *new)
> >+{
> >+	struct fd f;
> >+	struct bpf_prog *prog;
> >+
> >+	f = fdget(ufd);
> >+
> >+	prog = get_prog(f);
> >+	if (!IS_ERR(prog) && prog)
> >+		bpf_prog_put(prog);
> >+
> >+	atomic_inc(&new->aux->refcnt);
> >+	f.file->private_data = new;
> >+	fdput(f);
> >+	return 0;
> 
> So in case get_prog() fails, and for example f.file is infact NULL,
> you assign the bpf prog then to ERR_PTR(-EBADF)'s private_data? :(

Thanks, I will fix for the next version.

> >+}
> >+EXPORT_SYMBOL_GPL(bpf_prog_set);
> >+
> >+int bpf_new_fd(struct bpf_prog *prog, int flags)
> >+{
> >+	return anon_inode_getfd("bpf-prog", &bpf_prog_fops, prog, flags);
> >+}
> >+EXPORT_SYMBOL_GPL(bpf_new_fd);
> 
> Any reason why these two need to be exported for modules? Which
> modules are using them?
> 
> I think modules should probably not mess with this.

No reason, I suppose. I was just exporting because bpf_prog_get is;
I'll drop it for the next version.

> If you already name it generic, it would also be good if bpf_new_fd()
> is used in case of maps that call anon_inode_getfd(), too.

I needed to call bpf_new_fd from kernel/seccomp.c, which it seems
shouldn't be able to reference bpf_prog_fops, which is why I added the
little "proxy". If we change the api to something like,

bpf_new_fd("bpf-map", &bpf_map_fops, map);
bpf_new_fd("bpf-prog", &bpf_prog_fops, prog);

I'd need access to bpf_prog_fops again. What about changing the name
to bpf_new_prog_fd?

Tycho
