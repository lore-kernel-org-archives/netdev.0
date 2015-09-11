From: Tycho Andersen <tycho.andersen-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: [PATCH v2 2/5] seccomp: make underlying bpf ref counted as well
Date: Fri, 11 Sep 2015 08:44:00 -0600
Message-ID: <20150911144400.GI27574@smitten>
References: <1441930862-14347-1-git-send-email-tycho.andersen@canonical.com>
 <1441930862-14347-3-git-send-email-tycho.andersen@canonical.com>
 <55F2D0EC.9090004@iogearbox.net>
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
In-Reply-To: <55F2D0EC.9090004-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 11, 2015 at 03:02:36PM +0200, Daniel Borkmann wrote:
> On 09/11/2015 02:20 AM, Tycho Andersen wrote:
> >In the next patch, we're going to add a way to access the underlying
> >filters via bpf fds. This means that we need to ref-count both the
> >struct seccomp_filter objects and the struct bpf_prog objects separately,
> >in case a process dies but a filter is still referred to by another
> >process.
> >
> >Additionally, we mark classic converted seccomp filters as seccomp eBPF
> >programs, since they are a subset of what is supported in seccomp eBPF.
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
> >---
> >  kernel/seccomp.c | 4 +++-
> >  1 file changed, 3 insertions(+), 1 deletion(-)
> >
> >diff --git a/kernel/seccomp.c b/kernel/seccomp.c
> >index 245df6b..afaeddf 100644
> >--- a/kernel/seccomp.c
> >+++ b/kernel/seccomp.c
> >@@ -378,6 +378,8 @@ static struct seccomp_filter *seccomp_prepare_filter(struct sock_fprog *fprog)
> >  	}
> >
> >  	atomic_set(&sfilter->usage, 1);
> >+	atomic_set(&sfilter->prog->aux->refcnt, 1);
> >+	sfilter->prog->type = BPF_PROG_TYPE_SECCOMP;
> 
> So, if you do this, then this breaks the assumption of eBPF JITs
> that, currently, all classic converted BPF programs always have a
> prog->type of BPF_PROG_TYPE_UNSPEC (see: bpf_prog_was_classic()).
> 
> Currently, JITs make use of this information to determine whether
> A and X mappings for such programs should or should not be cleared
> in the prologue (s390 currently).
> 
> In the seccomp_prepare_filter() stage, we're already past that, so
> it will not cause an issue, but we certainly would need to be very
> careful in future, if bpf_prog_was_classic() is then used at a later
> stage when we already have a generated bpf_prog somewhere, as then
> this assumption will break.

The only reason we need to do this is to allow BPF_DUMP_PROG to work,
since we were restricting it to only allow dumping of seccomp
programs, since those don't have maps. Instead, perhaps we could allow
dumping of BPF_PROG_TYPE_SECCOMP and BPF_PROG_TYPE_UNSPEC?

Tycho
