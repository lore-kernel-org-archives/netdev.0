From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect
 for sockets in accept(3)
Date: Sat, 31 Oct 2015 21:51:16 +0000
Message-ID: <20151031215116.GO22011@ZenIV.linux.org.uk>
References: <CA+55aFx_BQG4FzSuyL2KAz=c+R0cPv0ZpjboT_=yKjZNGmTUEg@mail.gmail.com>
 <20151030210215.GI22011@ZenIV.linux.org.uk>
 <CA+55aFyoA5sXQvFDavNa7cGkRevunmtPe8F8-_tZ9-826qfkgw@mail.gmail.com>
 <CA+55aFy9fPmbSCJoQiCkjkaiU2HTM6p=o-pJgiV7asyVWBjAEg@mail.gmail.com>
 <20151030223317.GK22011@ZenIV.linux.org.uk>
 <CA+55aFwfFb=LXU77AbiPDHgWcpBwTBoJB4EMCZgTgX32cxMYWw@mail.gmail.com>
 <20151031193449.GM22011@ZenIV.linux.org.uk>
 <CA+55aFxeiVx4wMhWALfU3KYCqhsnr8T8M-dEZc3aAyzobWeRGQ@mail.gmail.com>
 <1446324359.6254.71.camel@edumazet-glaptop2.roam.corp.google.com>
 <CA+55aFz9wm7LssaaUzmo-NYNGW88gb_TkUFSJoFJrY+fvtt8+A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Network Development <netdev@vger.kernel.org>,
	David Howells <dhowells@redhat.com>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CA+55aFz9wm7LssaaUzmo-NYNGW88gb_TkUFSJoFJrY+fvtt8+A@mail.gmail.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Oct 31, 2015 at 02:23:31PM -0700, Linus Torvalds wrote:

> The other stuff we probably can't do all that much about. Unless we
> decide to go for some complicated lockless optimistic file descriptor
> allocation scheme with retry-on-failure instead of locks. Which I'm
> sure is possible, but I'm equally sure is painful.

The interesting part is dup2() - we'd have to do something like
	serialize against other dup2
	was_claimed = atomically set and test bit in bitmap
	if was_claimed
		tofree = fdt->fd[fd];
		if (!tofree)
			fail with EBUSY
	install into ->fd[...]
	end of critical area
in there; __alloc_fd() could be made retry-on-failure, but I don't see
how to cope with dup2 vs. dup2 without an explicit exclusion.
