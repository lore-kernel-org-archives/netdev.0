From: Tycho Andersen <tycho.andersen@canonical.com>
Subject: Re: [PATCH 3/6] ebpf: add a way to dump an eBPF program
Date: Fri, 4 Sep 2015 18:27:27 -0600
Message-ID: <20150905002727.GA3890@hopstrocity>
References: <1441382664-17437-1-git-send-email-tycho.andersen@canonical.com>
 <1441382664-17437-4-git-send-email-tycho.andersen@canonical.com>
 <CAGXu5jJ5+EFDRpgJC6U8Y4nvPEh2fivi-TZRNC-4qP9Gi7B7pA@mail.gmail.com>
 <20150904204554.GO26679@smitten>
 <CALCETrW5fS5d73ASJvhUuK=Yret7hcWD-B9NhZ3EsnCaw0MWFQ@mail.gmail.com>
 <20150904222855.GT26679@smitten>
 <CALCETrUY7B381DrzfDSvmDyZ98KAdWMHvpbJffJ0_ApjzH-Kbw@mail.gmail.com>
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
Received: from mail-io0-f174.google.com ([209.85.223.174]:34241 "EHLO
	mail-io0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934691AbbIEA1a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Sep 2015 20:27:30 -0400
Received: by iofb144 with SMTP id b144so41165151iof.1
        for <netdev@vger.kernel.org>; Fri, 04 Sep 2015 17:27:29 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CALCETrUY7B381DrzfDSvmDyZ98KAdWMHvpbJffJ0_ApjzH-Kbw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 04, 2015 at 04:08:53PM -0700, Andy Lutomirski wrote:
> On Fri, Sep 4, 2015 at 3:28 PM, Tycho Andersen
> <tycho.andersen@canonical.com> wrote:
> > On Fri, Sep 04, 2015 at 02:48:03PM -0700, Andy Lutomirski wrote:
> >> On Fri, Sep 4, 2015 at 1:45 PM, Tycho Andersen
> >> <tycho.andersen@canonical.com> wrote:
> >> > On Fri, Sep 04, 2015 at 01:17:30PM -0700, Kees Cook wrote:
> >> >> On Fri, Sep 4, 2015 at 9:04 AM, Tycho Andersen
> >> >> <tycho.andersen@canonical.com> wrote:
> >> >> > This commit adds a way to dump eBPF programs. The initial implementation
> >> >> > doesn't support maps, and therefore only allows dumping seccomp ebpf
> >> >> > programs which themselves don't currently support maps.
> >> >> >
> >> >> > We export the GPL bit as well as a unique ID for the program so that
> >> >>
> >> >> This unique ID appears to be the heap address for the prog. That's a
> >> >> huge leak, and should not be done. We don't want to introduce new
> >> >> kernel address leaks while we're trying to fix the remaining ones.
> >> >> Shouldn't the "unique ID" be the fd itself? I imagine KCMP_FILE
> >> >> could be used, for example.
> >> >
> >> > No; we acquire the fd per process, so if a task installs a filter and
> >> > then forks N times, we'll grab N (+1) copies of the filter from N (+1)
> >> > different file descriptors. Ideally, we'd have some way to figure out
> >> > that these were all the same. Some sort of prog_id is one way,
> >> > although there may be others.
> >>
> >> I disagree a bit.  I think we want the actual hierarchy to be a
> >> well-defined thing, because I have plans to make the hierarchy
> >> actually do something.  That means that we'll need to have a more
> >> exact way to dump the hierarchy than "these two filters are identical"
> >> or "these two filters are not identical".
> >
> > Can you elaborate on what this would look like? I think with the
> > "these two filters are the same" primitive (the same in the sense that
> > they were inherited during a fork, not just that
> > memcmp(filter1->insns, filter2->insns) == 0) you can infer the entire
> > hierarchy, however clunky it may be to do so.
> >
> > Another issue is that KCMP_FILE won't work in this case, as it
> > effectively compares the struct file *, which will be different since
> > we need to call anon_inode_getfd() for each call of
> > ptrace(PTRACE_SECCOMP_GET_FILTER_FD). We could add a KCMP_BPF (or just
> > a KCMP_FILE_PRIVATE_DATA, since that's effectively what it would be).
> > Does that make sense? [added Cyrill]
> >
> 
> I don't really know what it would look like.  I think we want a way to
> compare struct seccomp_filter pointers.

Not to complicate things further, but this brings up another
interesting issue. Right now, we require PT_SUSPEND_SECCOMP in order
to restore seccomp and do things afterwards (otherwise the seccomp
filters might kill whatever things the restore process is doing). If
we want the struct seccomp_filter pointers to be identical on restore,
that means we need to restore when we are real root, because bpf()
requires that we be real root. This means that we essentially need to
ptrace the entire restore, which we don't want to do.

In order to work around this, I was thinking we could change the
ancestry check slightly:

diff --git a/kernel/seccomp.c b/kernel/seccomp.c
index 9c6bea6..efc3f36 100644
--- a/kernel/seccomp.c
+++ b/kernel/seccomp.c
@@ -239,7 +239,7 @@ static int is_ancestor(struct seccomp_filter *parent,
 	if (parent == NULL)
 		return 1;
 	for (; child; child = child->prev)
-		if (child == parent)
+		if (child->prog == parent->prog)
 			return 1;
 	return 0;
 }

so that we can do bpf() when we're real root, and just restore seccomp
at the very end. This would mean that the struct bpf_prog pointers are
shared, but the struct seccomp_filter pointers aren't.

Even assuming we have some sort of way to identify shared ancestry, we
still need something like the above in order to be able to restore it.
This sort of sucks; it would be ideal to to share struct
seccomp_filter *s too. We could do something like
seccomp(COPY_FROM_PARENT) or something, but given the struggles Kees
told me he had with getting SECCOMP_FILTER_FLAG_TSYNC right, I suspect
that won't fly.

> FWIW, I *hate* kcmp.  It might be worth trying to come up with a less
> awful way to do this.  For example, what if we could generate a kcmpfd
> such that each kcmpfd contains (internally) a random symmetric key?
> We could have a function that would return kernel pointers encrypted
> by that key.

We could do what Kees is proposing for struct bpf_prog and just keep a
globally unique id on struct seccomp_filter, and allow asking for that
via some seccomp(GET_ID, fd) over the same fd we're using to dump the
bpf prog. That doesn't solve our restore problem, though.

Tycho

> Of course, then we need to make sure that no one ever tries to keep a
> kcmpfd around long enough that CRIU needs to checkpoint it, because
> that's impossible.
> 
> Grr.
> 
> --Andy
