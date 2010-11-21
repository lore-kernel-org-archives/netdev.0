From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PROBLEM] WARNING: at kernel/exit.c:910 do_exit
Date: Sun, 21 Nov 2010 19:51:16 +0100
Message-ID: <20101121185116.GA2280@redhat.com>
References: <AANLkTi=ej5guZ2R72=fqe5mciwjVeY5LkDL3Qx1W0GvA@mail.gmail.com> <AANLkTikRJ3QBRJ_VsoMG4Q+HMs=a9C8XkJ31dtdKrfpO@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Pekka Enberg <penberg@kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:16358 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752197Ab0KUS6a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 21 Nov 2010 13:58:30 -0500
Content-Disposition: inline
In-Reply-To: <AANLkTikRJ3QBRJ_VsoMG4Q+HMs=a9C8XkJ31dtdKrfpO@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/21, Linus Torvalds wrote:
>
> On Sun, Nov 21, 2010 at 7:35 AM, Pekka Enberg <penberg@kernel.org> wr=
ote:
> >
> > =A0 =A0 =A0 =A0WARN_ON(atomic_read(&tsk->fs_excl));
> >
> > in do_exit(). There was a prior oops in __pipe_free_info() called i=
n
> > sys_recvmsg() paths that unfortunately scrolled away.
>
> That WARN_ON() is almost certainly due to the previous oops.
>
> The previous oops may have scrolled away, but you can see the
> call-chain, since it's part of the later oops. Except the photo is
> hard to read ;)
>
> In fact, you can see that there has been _two_ oopses before that. Th=
e
> "free_pipe_info()" oops comes from the "do_exit()" path of the _first=
_
> oops.
>
> So the original oops seems to be around here:
>
>    (*probably* oopsed in __scm_destroy)
>    (the fd_install on the stack is likely from scm_detach_fds calling
> it before calling __scm_destroy - just a stale pointer remaining on
> the stack)
>    scm_detach_fds
>    unix_stream_recvmsg
>    sock_recvmsg
>    __sys_recvmsg
>    sys_recvmsg

Yes, but still I am puzzled a bit. Where ->fs_excl !=3D 0 comes from?
Not that I really understand what it means, but nothing in this path
can do lock_super(), I think. This means it was already nonzero or
the bug caused the memory corruption.

Btw, why it is atomic_t ?

> And who knows? It may be that the networking oops was due to some
> other earlier problem that isn't part of this particular callchain an=
d
> that has long since scrolled away.

Agreed, probably this is false alarm. The oopsing task can trigger
a lot of "wrong" warnings.

Oleg.

