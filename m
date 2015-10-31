From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect
 for sockets in accept(3)
Date: Fri, 30 Oct 2015 18:07:42 -0700
Message-ID: <1446253662.6254.59.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1446043677.7476.68.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20151028211347.GC22011@ZenIV.linux.org.uk>
	 <1446068668.7476.89.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20151028223330.GD22011@ZenIV.linux.org.uk>
	 <1446073709.7476.93.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20151029001532.GE22011@ZenIV.linux.org.uk>
	 <1446089381.7476.114.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20151029041611.GF22011@ZenIV.linux.org.uk>
	 <1446122119.7476.138.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+55aFx_BQG4FzSuyL2KAz=c+R0cPv0ZpjboT_=yKjZNGmTUEg@mail.gmail.com>
	 <20151030210215.GI22011@ZenIV.linux.org.uk>
	 <CA+55aFyoA5sXQvFDavNa7cGkRevunmtPe8F8-_tZ9-826qfkgw@mail.gmail.com>
	 <CA+55aFy9fPmbSCJoQiCkjkaiU2HTM6p=o-pJgiV7asyVWBjAEg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Al Viro <viro@zeniv.linux.org.uk>,
	David Miller <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Network Development <netdev@vger.kernel.org>,
	David Howells <dhowells@redhat.com>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <CA+55aFy9fPmbSCJoQiCkjkaiU2HTM6p=o-pJgiV7asyVWBjAEg@mail.gmail.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2015-10-30 at 14:50 -0700, Linus Torvalds wrote:
> On Fri, Oct 30, 2015 at 2:23 PM, Linus Torvalds
> <torvalds@linux-foundation.org> wrote:
> > On Fri, Oct 30, 2015 at 2:02 PM, Al Viro <viro@zeniv.linux.org.uk> wrote:
> >>
> >> Your variant has 1:64 ratio; obviously better than now, but we can actually
> >> do 1:bits-per-cacheline quite easily.
> >
> > Ok, but in that case you end up needing a counter for each cacheline
> > too (to count how many bits, in order to know when to say "cacheline
> > is entirely full").
> 
> So here's a largely untested version of my "one bit per word"
> approach. It seems to work, but looking at it, I'm unhappy with a few
> things:
> 
>  - using kmalloc() for the .full_fds_bits[] array is simple, but
> disgusting, since 99% of all programs just have a single word.
> 
>    I know I talked about just adding the allocation to the same one
> that allocates the bitmaps themselves, but I got lazy and didn't do
> it. Especially since that code seems to try fairly hard to make the
> allocations nice powers of two, according to the comments. That may
> actually matter from an allocation standpoint.
> 
>  - Maybe we could just use that "full_fds_bits_init" field for when a
> single word is sufficient, and avoid the kmalloc that way?

At least make sure the allocation uses a cache line, so that multiple
processes do not share same cache line for this possibly hot field

fdt->full_fds_bits = kzalloc(max_t(size_t,
				   L1_CACHE_BYTES,
				   BITBIT_SIZE(nr)),
			     GFP_KERNEL);

> 
> Anyway. This is a pretty simple patch, and I actually think that we
> could just get rid of the "next_fd" logic entirely with this. That
> would make this *patch* be more complicated, but it would make the
> resulting *code* be simpler.
> 
> Hmm? Want to play with this? Eric, what does this do to your test-case?

Excellent results so far Linus, 500 % increase, thanks a lot !

Tested using 16 threads, 8 on Socket0, 8 on Socket1 

Before patch :

# ulimit -n 12000000
# taskset ff0ff ./opensock -t 16 -n 10000000 -l 10   
count=10000000 (check/increase ulimit -n)
total = 636870

After patch :

taskset ff0ff ./opensock -t 16 -n 10000000 -l 10
count=10000000 (check/increase ulimit -n)
total = 3845134   (6 times better)

Your patch out-performs the O_FD_FASTALLOC one on this particular test
by ~ 9 % :

taskset ff0ff ./opensock -t 16 -n 10000000 -l 10 -f
count=10000000 (check/increase ulimit -n)
total = 3505252

If I raise to 48 threads, the FAST_ALLOC wins by 5 % (3752087 instead of
3546666).

Oh, and 48 threads without any patches : 383027

-> program runs one order of magnitude faster, congrats !


