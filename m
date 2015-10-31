From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect
 for sockets in accept(3)
Date: Sat, 31 Oct 2015 20:29:29 +0000
Message-ID: <20151031202929.GN22011@ZenIV.linux.org.uk>
References: <20151029041611.GF22011@ZenIV.linux.org.uk>
 <1446122119.7476.138.camel@edumazet-glaptop2.roam.corp.google.com>
 <CA+55aFx_BQG4FzSuyL2KAz=c+R0cPv0ZpjboT_=yKjZNGmTUEg@mail.gmail.com>
 <20151030210215.GI22011@ZenIV.linux.org.uk>
 <CA+55aFyoA5sXQvFDavNa7cGkRevunmtPe8F8-_tZ9-826qfkgw@mail.gmail.com>
 <CA+55aFy9fPmbSCJoQiCkjkaiU2HTM6p=o-pJgiV7asyVWBjAEg@mail.gmail.com>
 <20151030223317.GK22011@ZenIV.linux.org.uk>
 <CA+55aFwfFb=LXU77AbiPDHgWcpBwTBoJB4EMCZgTgX32cxMYWw@mail.gmail.com>
 <20151031193449.GM22011@ZenIV.linux.org.uk>
 <CA+55aFxeiVx4wMhWALfU3KYCqhsnr8T8M-dEZc3aAyzobWeRGQ@mail.gmail.com>
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
In-Reply-To: <CA+55aFxeiVx4wMhWALfU3KYCqhsnr8T8M-dEZc3aAyzobWeRGQ@mail.gmail.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Oct 31, 2015 at 12:54:50PM -0700, Linus Torvalds wrote:
> On Sat, Oct 31, 2015 at 12:34 PM, Al Viro <viro@zeniv.linux.org.uk> wrote:
> >
> > ... and here's the current variant of mine.
> 
> Ugh. I really liked how simple mine ended up being. Yours is definitely not.

Note that it's not the final variant - just something that should be
testable.  There are all kinds of things that still need cleaning/simplifying
in there - e.g. scan() is definitely more complex than needed (if nothing
else, the "small bitmap" case is simply find_next_zero_bit(), and the
rest all have size equal to full cacheline; moreover, I'd overdone the
"... and check if there are other zero bits left" thing - its callers
used to use that a lot, and with the execption of two of them it was
absolutely worthless.  So it ended up more generic than necessary and
I'm going to trim that crap down.

It's still going to end up more complex than yours, obviously, but not as
badly as it is now.  I'm not sure if the speedup will be worth the
extra complexity, thus asking for testing...  On _some_ loads it is
considerably faster (at least by factor of 5), but whether those loads
resemble anything that occurs on real systems...

BTW, considerable amount of unpleasantness is due to ragged-right-end kind
of problems - take /proc/sys/fs/nr-open to something other than a power of
two and a whole lot of fun issues start happening.  I went for "if there
are secondary bitmaps at all, pad all bitmaps to a multiple of cacheline",
which at least somewhat mitigates that mess; hell knows, there might be
a clever way to sidestep it entirely...
