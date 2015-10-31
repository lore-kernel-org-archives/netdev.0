From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect for
 sockets in accept(3)
Date: Sat, 31 Oct 2015 14:23:31 -0700
Message-ID: <CA+55aFz9wm7LssaaUzmo-NYNGW88gb_TkUFSJoFJrY+fvtt8+A@mail.gmail.com>
References: <20151029001532.GE22011@ZenIV.linux.org.uk>
	<1446089381.7476.114.camel@edumazet-glaptop2.roam.corp.google.com>
	<20151029041611.GF22011@ZenIV.linux.org.uk>
	<1446122119.7476.138.camel@edumazet-glaptop2.roam.corp.google.com>
	<CA+55aFx_BQG4FzSuyL2KAz=c+R0cPv0ZpjboT_=yKjZNGmTUEg@mail.gmail.com>
	<20151030210215.GI22011@ZenIV.linux.org.uk>
	<CA+55aFyoA5sXQvFDavNa7cGkRevunmtPe8F8-_tZ9-826qfkgw@mail.gmail.com>
	<CA+55aFy9fPmbSCJoQiCkjkaiU2HTM6p=o-pJgiV7asyVWBjAEg@mail.gmail.com>
	<20151030223317.GK22011@ZenIV.linux.org.uk>
	<CA+55aFwfFb=LXU77AbiPDHgWcpBwTBoJB4EMCZgTgX32cxMYWw@mail.gmail.com>
	<20151031193449.GM22011@ZenIV.linux.org.uk>
	<CA+55aFxeiVx4wMhWALfU3KYCqhsnr8T8M-dEZc3aAyzobWeRGQ@mail.gmail.com>
	<1446324359.6254.71.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Al Viro <viro@zeniv.linux.org.uk>,
	David Miller <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Network Development <netdev@vger.kernel.org>,
	David Howells <dhowells@redhat.com>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <1446324359.6254.71.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Oct 31, 2015 at 1:45 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>     13.84%       opensock  [kernel.kallsyms]    [k] queued_spin_lock_slowpath
>                  |
>                  --- queued_spin_lock_slowpath
>                     |
>                     |--99.97%-- _raw_spin_lock
>                     |          |
>                     |          |--53.03%-- __close_fd
>                     |          |
>                     |          |--46.83%-- __alloc_fd

Interesting. "__close_fd" actually looks more expensive than
allocation. They presumably get called equally often, so it's probably
some cache effect.

__close_fd() doesn't do anything even remotely interesting as far as I
can tell, but it strikes me that we probably take a *lot* of cache
misses on the stupid "close-on-exec" flags, which are probably always
zero anyway.

Mind testing something really stupid, and making the __clear_bit() in
__clear_close_on_exec() conditiona, something like this:

     static inline void __clear_close_on_exec(int fd, struct fdtable *fdt)
     {
    -       __clear_bit(fd, fdt->close_on_exec);
    +       if (test_bit(fd, fdt->close_on_exec)
    +               __clear_bit(fd, fdt->close_on_exec);
     }

and see if it makes a difference.

This is the kind of thing that a single-threaded (or even
single-socket) test will never actually show, because it caches well
enough. But for two sockets, I could imagine the unnecessary dirtying
of cachelines and ping-pong being noticeable.

The other stuff we probably can't do all that much about. Unless we
decide to go for some complicated lockless optimistic file descriptor
allocation scheme with retry-on-failure instead of locks. Which I'm
sure is possible, but I'm equally sure is painful.

                    Linus
