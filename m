From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect
 for sockets in accept(3)
Date: Fri, 30 Oct 2015 21:02:15 +0000
Message-ID: <20151030210215.GI22011@ZenIV.linux.org.uk>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Network Development <netdev@vger.kernel.org>,
	David Howells <dhowells@redhat.com>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:55712 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932814AbbJ3VCV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2015 17:02:21 -0400
Content-Disposition: inline
In-Reply-To: <CA+55aFx_BQG4FzSuyL2KAz=c+R0cPv0ZpjboT_=yKjZNGmTUEg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 30, 2015 at 10:18:12AM -0700, Linus Torvalds wrote:

> I do wonder if we couldn't just speed up the bitmap allocator by an
> order of magnitude. It would be nicer to be able to make existing
> loads faster without any new "don't bother with POSIX semantics" flag.
> 
> We could, for example, extend the "open_fds" bitmap with a
> "second-level" bitmap that has information on when the first level is
> full. We traverse the open_fd's bitmap one word at a time anyway, we
> could have a second-level bitmap that has one bit per word to say
> whether that word is already full.

Your variant has 1:64 ratio; obviously better than now, but we can actually
do 1:bits-per-cacheline quite easily.

I've been playing with a variant that has more than two bitmaps, and
AFAICS it
	a) does not increase the amount of cacheline pulled and
	b) keeps it well-bound even in the absolutely worst case
(128M-odd descriptors filled, followed by close(0);dup2(1,0); -
in that case it ends up accessing the 7 cachelines worth of
bitmaps; your variant will read through 4000-odd cachelines of
the summary bitmap alone; the mainline is even worse).

> The advantage of the above is that it should just work for existing
> binaries. It may not be quite as optimal as just introducing a new
> "don't care about POSIX" feature, but quite frankly, if it cuts down
> the bad case of "find_next_zero_bit()" by a factror of 64 (and then
> adds a *small* expense factor on top of that), I suspect it should be
> "good enough" even for your nasty case.
> 
> What do you think? Willing to try the above approach (with any
> inevitable bug-fixes) and see how it compares?
> 
> Obviously in addition to any fixes to my pseudo-code above you'd need
> to add the allocations for the new "full_fds_bits" etc, but I think it
> should be easy to make the full_fds_bit allocation be *part* of the
> "open_fds" allocation, so you wouldn't need a new allocation in
> alloc_fdtable(). We already do that whole "use a single allocation" to
> combine open_fds with close_on_exec into one single allocation.

I'll finish testing what I've got and post it; it costs 3 extra pointers
in the files_struct and a bit fatter bitmap allocation (less than 0.2%
extra).  All the arguments regarding the unmodified binaries apply, of
course, and so far it looks fairly compact...
