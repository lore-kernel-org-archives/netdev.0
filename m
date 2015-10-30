From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect for
 sockets in accept(3)
Date: Fri, 30 Oct 2015 10:18:12 -0700
Message-ID: <CA+55aFx_BQG4FzSuyL2KAz=c+R0cPv0ZpjboT_=yKjZNGmTUEg@mail.gmail.com>
References: <1445991236.7476.59.camel@edumazet-glaptop2.roam.corp.google.com>
	<20151028123543.GB22011@ZenIV.linux.org.uk>
	<1446038672.7476.65.camel@edumazet-glaptop2.roam.corp.google.com>
	<1446043677.7476.68.camel@edumazet-glaptop2.roam.corp.google.com>
	<20151028211347.GC22011@ZenIV.linux.org.uk>
	<1446068668.7476.89.camel@edumazet-glaptop2.roam.corp.google.com>
	<20151028223330.GD22011@ZenIV.linux.org.uk>
	<1446073709.7476.93.camel@edumazet-glaptop2.roam.corp.google.com>
	<20151029001532.GE22011@ZenIV.linux.org.uk>
	<1446089381.7476.114.camel@edumazet-glaptop2.roam.corp.google.com>
	<20151029041611.GF22011@ZenIV.linux.org.uk>
	<1446122119.7476.138.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Al Viro <viro@zeniv.linux.org.uk>,
	David Miller <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Network Development <netdev@vger.kernel.org>,
	David Howells <dhowells@redhat.com>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:35018 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751395AbbJ3RSN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2015 13:18:13 -0400
In-Reply-To: <1446122119.7476.138.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 29, 2015 at 5:35 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
> Well, I already tested the O_FD_FASTALLOC thing, and I can tell you
> find_next_zero_bit() is nowhere to be found in kernel profiles anymore.
> It also lowers time we hold the fd array spinlock while doing fd alloc.

I do wonder if we couldn't just speed up the bitmap allocator by an
order of magnitude. It would be nicer to be able to make existing
loads faster without any new "don't bother with POSIX semantics" flag.

We could, for example, extend the "open_fds" bitmap with a
"second-level" bitmap that has information on when the first level is
full. We traverse the open_fd's bitmap one word at a time anyway, we
could have a second-level bitmap that has one bit per word to say
whether that word is already full.

So you'd basically have:

 - open_fds: array with the real bitmap (exactly like we do now)
 - full_fds_bits: array of bits that shows which of the "unsigned
longs" in 'open_fs' are already full.

and then you can basically walk 4096 fd's at a time by just checking
one single word in the full_fds_bits[] array.

So in __alloc_fd(), instead of using find_next_zero_bit(), you'd use
"find_next_fd()", which woulf do something like

    #define NR_BITS_PER_BIT (64*sizeof(long)*sizeof(long))

    unsigned long find_next_fd(struct fdtable *fdt, unsigned long start)
    {
        while (start < fdt->max_fds) {
            unsigned long startbit = start / BITS_PER_LONG;
            unsigned long bitbit = startbit / BITS_PER_LONG;
            unsigned long bitmax = (bitbit+1) * BITS_PER_LONG * BITS_PER_LONG;

            if (bitmax > max_fds)
                bitmax = fdt->max_fds;

            // Are all the bits in all the bitbit arrays already set?
            if (!~fds->full_fds_bits[bitbit]) {
                start = bitmax;
                continue;
            }

            fd = find_next_zero_bit(fdt->open_fds, bitmax, start);
            if (fd < bitmax)
                return fd;
        }
        return fdt->max_fds;
    }

which really should cut down on the bit traversal by a factor of 64.

Of course, then you do have to maintain that bitmap-of-bits in
__set_open_fd() and __clear_open_fd(), but that should be pretty
trivial too:

 - __clear_open_fd() would become just

        __clear_bit(fd, fdt->open_fds);
        __clear_bit(fd / BITS_PER_LONG, fdt->full_fds_bits);

 - and __set_open_fd() would become

        __set_bit(fd, fdt->open_fds);
        fd /= BITS_PER_LONG;
        if (!~fdt->open_fds[fd])
            __set_bit(fd, fdt->full_fds_bits);

or something.

NOTE NOTE NOTE! The above is all very much written without any testing
in the email client, so while I tried to make it look like "real
code", consider the above just pseudo-code.

The advantage of the above is that it should just work for existing
binaries. It may not be quite as optimal as just introducing a new
"don't care about POSIX" feature, but quite frankly, if it cuts down
the bad case of "find_next_zero_bit()" by a factror of 64 (and then
adds a *small* expense factor on top of that), I suspect it should be
"good enough" even for your nasty case.

What do you think? Willing to try the above approach (with any
inevitable bug-fixes) and see how it compares?

Obviously in addition to any fixes to my pseudo-code above you'd need
to add the allocations for the new "full_fds_bits" etc, but I think it
should be easy to make the full_fds_bit allocation be *part* of the
"open_fds" allocation, so you wouldn't need a new allocation in
alloc_fdtable(). We already do that whole "use a single allocation" to
combine open_fds with close_on_exec into one single allocation.

                    Linus
