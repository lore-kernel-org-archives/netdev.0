From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PROBLEM] WARNING: at kernel/exit.c:910 do_exit
Date: Sun, 21 Nov 2010 09:42:57 -0800
Message-ID: <AANLkTikRJ3QBRJ_VsoMG4Q+HMs=a9C8XkJ31dtdKrfpO@mail.gmail.com>
References: <AANLkTi=ej5guZ2R72=fqe5mciwjVeY5LkDL3Qx1W0GvA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: oleg@redhat.com, LKML <linux-kernel@vger.kernel.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Pekka Enberg <penberg@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:56523 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754650Ab0KURoA convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 21 Nov 2010 12:44:00 -0500
In-Reply-To: <AANLkTi=ej5guZ2R72=fqe5mciwjVeY5LkDL3Qx1W0GvA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Nov 21, 2010 at 7:35 AM, Pekka Enberg <penberg@kernel.org> wrot=
e:
>
> The following warning triggered on me while I was browsing the web:
>
> =A0http://twitpic.com/38vxxg
>
> [ Click on the "Rotate photo" button for landscape version.=A0]
>
> It's
>
> =A0 =A0 =A0 =A0WARN_ON(atomic_read(&tsk->fs_excl));
>
> in do_exit(). There was a prior oops in __pipe_free_info() called in
> sys_recvmsg() paths that unfortunately scrolled away.

That WARN_ON() is almost certainly due to the previous oops.

The previous oops may have scrolled away, but you can see the
call-chain, since it's part of the later oops. Except the photo is
hard to read ;)

In fact, you can see that there has been _two_ oopses before that. The
"free_pipe_info()" oops comes from the "do_exit()" path of the _first_
oops.

So the original oops seems to be around here:

   (*probably* oopsed in __scm_destroy)
   (the fd_install on the stack is likely from scm_detach_fds calling
it before calling __scm_destroy - just a stale pointer remaining on
the stack)
   scm_detach_fds
   unix_stream_recvmsg
   sock_recvmsg
   __sys_recvmsg
   sys_recvmsg

which means that this is almost certainly in networking. Then, when
that oops caused us to die, do_exit() tried to clean up the state, and
_that_ caused us to oops again (now in free_pipe_info). That second
oops is the partial one you see. And then the _third_ oops is the one
you actually caught.

The free_pipe_info() oops in turn must be because we passed in an
invalid "inode" pointer. It's almost certainly the "inode->i_pipe"
dereference, so inode was NULL or something. I don't see why that
would happen, but with a previous oops it's not necessarily clear that
there _is_ a reason.

And who knows? It may be that the networking oops was due to some
other earlier problem that isn't part of this particular callchain and
that has long since scrolled away. I don't see any unix domain changes
since -rc1.

                   Linus
