From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PROBLEM] WARNING: at kernel/exit.c:910 do_exit
Date: Sun, 21 Nov 2010 11:11:34 -0800
Message-ID: <AANLkTi=fdtLhdV8OOXLAJPPtdPvMWyo8e3ARbk8gagvc@mail.gmail.com>
References: <AANLkTi=ej5guZ2R72=fqe5mciwjVeY5LkDL3Qx1W0GvA@mail.gmail.com>
 <AANLkTikRJ3QBRJ_VsoMG4Q+HMs=a9C8XkJ31dtdKrfpO@mail.gmail.com> <20101121185116.GA2280@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Pekka Enberg <penberg@kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Oleg Nesterov <oleg@redhat.com>, Jens Axboe <jaxboe@fusionio.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101121185116.GA2280@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Nov 21, 2010 at 10:51 AM, Oleg Nesterov <oleg@redhat.com> wrote:
>
> Yes, but still I am puzzled a bit. Where ->fs_excl != 0 comes from?
> Not that I really understand what it means, but nothing in this path
> can do lock_super(), I think. This means it was already nonzero or
> the bug caused the memory corruption.

I would guess that by the time you do three recursive oopses, you've
probably used up all the kernel stack and you've stomped on the
thread_info itself. At that point, thread->tsk might be totally
random. So it's possible that "current->fs_excl" is nonzero simply
because "current" is a random pointer at this point.

Or it might be memory corruption, and the same thing that caused the
original oops.

I dunno.

I do wonder if we should just flag a thread as "busy oopsing" before
we call "do_exit(), so that _if_ we do a recursive oops we

 (a) don't print it out (except just a one-liner to say "recursively
oopsed in %pS" or something)
 (b) don't try to clean up with do_exit (because that's likely just
going to oops again or run out of stack etc)

That might have left us with a more visible original oops. Maybe the
register contents at that point could have given us any ideas (ie
things like the slab poisoning memory patterns or whatever).

> Btw, why it is atomic_t ?

That whole thing is insane. Afaik, there is one single user (apart
from the WARN_ON), and that's some stupid block scheduler crap for IO
priority boosting.

The block layer people have been way too eager to add random ugly
crud. And no, I don't see why the atomic_t would make any sense. It's
thread-local.

                 Linus
