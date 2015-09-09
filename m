From: Tycho Andersen <tycho.andersen@canonical.com>
Subject: Re: [PATCH 3/6] ebpf: add a way to dump an eBPF program
Date: Wed, 9 Sep 2015 16:34:22 -0600
Message-ID: <20150909223422.GE26679@smitten>
References: <1441382664-17437-1-git-send-email-tycho.andersen@canonical.com>
 <1441382664-17437-4-git-send-email-tycho.andersen@canonical.com>
 <CAGXu5jJ5+EFDRpgJC6U8Y4nvPEh2fivi-TZRNC-4qP9Gi7B7pA@mail.gmail.com>
 <20150904204554.GO26679@smitten>
 <CALCETrW5fS5d73ASJvhUuK=Yret7hcWD-B9NhZ3EsnCaw0MWFQ@mail.gmail.com>
 <20150904222855.GT26679@smitten>
 <CALCETrUY7B381DrzfDSvmDyZ98KAdWMHvpbJffJ0_ApjzH-Kbw@mail.gmail.com>
 <20150905002727.GA3890@hopstrocity>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kees Cook <keescook@chromium.org>,
	Alexei Starovoitov <ast@kernel.org>,
	Will Drewry <wad@chromium.org>,
	Oleg Nesterov <oleg@redhat.com>,
	Pavel Emelyanov <xemul@parallels.com>,
	"Serge E. Hallyn" <serge.hallyn@ubuntu.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	LKML <linux-kernel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Cyrill Gorcunov <gorcunov@parallels.com>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f176.google.com ([209.85.223.176]:33585 "EHLO
	mail-io0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751829AbbIIWeZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2015 18:34:25 -0400
Received: by iofh134 with SMTP id h134so40122852iof.0
        for <netdev@vger.kernel.org>; Wed, 09 Sep 2015 15:34:24 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20150905002727.GA3890@hopstrocity>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 04, 2015 at 06:27:27PM -0600, Tycho Andersen wrote:
> On Fri, Sep 04, 2015 at 04:08:53PM -0700, Andy Lutomirski wrote:
> > On Fri, Sep 4, 2015 at 3:28 PM, Tycho Andersen
> > <tycho.andersen@canonical.com> wrote:
> > > On Fri, Sep 04, 2015 at 02:48:03PM -0700, Andy Lutomirski wrote:
> > >> On Fri, Sep 4, 2015 at 1:45 PM, Tycho Andersen
> > >> <tycho.andersen@canonical.com> wrote:
> > >> > On Fri, Sep 04, 2015 at 01:17:30PM -0700, Kees Cook wrote:
> > >> >> On Fri, Sep 4, 2015 at 9:04 AM, Tycho Andersen
> > >> >> <tycho.andersen@canonical.com> wrote:
> > >> >> > This commit adds a way to dump eBPF programs. The initial implementation
> > >> >> > doesn't support maps, and therefore only allows dumping seccomp ebpf
> > >> >> > programs which themselves don't currently support maps.
> > >> >> >
> > >> >> > We export the GPL bit as well as a unique ID for the program so that
> > >> >>
> > >> >> This unique ID appears to be the heap address for the prog. That's a
> > >> >> huge leak, and should not be done. We don't want to introduce new
> > >> >> kernel address leaks while we're trying to fix the remaining ones.
> > >> >> Shouldn't the "unique ID" be the fd itself? I imagine KCMP_FILE
> > >> >> could be used, for example.
> > >> >
> > >> > No; we acquire the fd per process, so if a task installs a filter and
> > >> > then forks N times, we'll grab N (+1) copies of the filter from N (+1)
> > >> > different file descriptors. Ideally, we'd have some way to figure out
> > >> > that these were all the same. Some sort of prog_id is one way,
> > >> > although there may be others.
> > >>
> > >> I disagree a bit.  I think we want the actual hierarchy to be a
> > >> well-defined thing, because I have plans to make the hierarchy
> > >> actually do something.  That means that we'll need to have a more
> > >> exact way to dump the hierarchy than "these two filters are identical"
> > >> or "these two filters are not identical".
> > >
> > > Can you elaborate on what this would look like? I think with the
> > > "these two filters are the same" primitive (the same in the sense that
> > > they were inherited during a fork, not just that
> > > memcmp(filter1->insns, filter2->insns) == 0) you can infer the entire
> > > hierarchy, however clunky it may be to do so.
> > >
> > > Another issue is that KCMP_FILE won't work in this case, as it
> > > effectively compares the struct file *, which will be different since
> > > we need to call anon_inode_getfd() for each call of
> > > ptrace(PTRACE_SECCOMP_GET_FILTER_FD). We could add a KCMP_BPF (or just
> > > a KCMP_FILE_PRIVATE_DATA, since that's effectively what it would be).
> > > Does that make sense? [added Cyrill]
> > >
> > 
> > I don't really know what it would look like.  I think we want a way to
> > compare struct seccomp_filter pointers.

Here's a thought,

The set I'm currently proposing effectively separates the ref-counting
of the struct seccomp_filter from the struct bpf_prog (by necessity,
since we're referring to filters from fds). What if we went a little
futher, and made a copy of each seccomp_filter on fork(), keeping it
pointed at the same bpf_prog but adding some metadata about how it was
inherited (tsk->seccomp.filter->inheritence_count++ perhaps). This
would still require this change:

> diff --git a/kernel/seccomp.c b/kernel/seccomp.c
> index 9c6bea6..efc3f36 100644
> --- a/kernel/seccomp.c
> +++ b/kernel/seccomp.c
> @@ -239,7 +239,7 @@ static int is_ancestor(struct seccomp_filter *parent,
>  	if (parent == NULL)
>  		return 1;
>  	for (; child; child = child->prev)
> -		if (child == parent)
> +		if (child->prog == parent->prog)
>  			return 1;
>  	return 0;
>  }

to get the ancestry right on restore, but the change would make more
sense given that the seccomp_filter pointers were in fact unique at
this point.

To access it, we can change the current set to instead of iterating on
bpf_prog, to iterate on seccomp_filter, and add a few seccomp
commands, so the whole sequence looks like this:

seccomp_fd = ptrace(PTRACE_SECCOMP_GET_FILTER_FD, pid);
if (seccomp(SECCOMP_MODE_FILTER_EBPF, SECCOMP_EBPF_INHERITANCE, fd) > 0) {
        /* mark this as inherited from parent */
} else {
        bpf_fd = seccomp(SECCOMP_MODE_FILTER_EBPF, SECCOMP_EBPF_GET_FD, seccomp_fd);
        bpf(BPF_PROG_DUMP, &attr, sizeof(attr));
        /* save things as normal */
}

Then we need some way to restore this inheritance_count; the only
thing I can think of right now is to let people specify it when they
add the filter via SECCOMP_EBPF_ADD_FD, but that doesn't seem ideal
since these are potentially unprivileged users (root in their user
ns). However, it's not clear to me how one would abuse it given that
is_ancestor actually checks the bpf_prog pointers.

Tycho
