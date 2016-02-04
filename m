From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH v3 net-next] net: Implement fast csum_partial for x86_64
Date: Thu, 4 Feb 2016 13:46:11 -0800
Message-ID: <CA+55aFxqs+mE=s4UkNQXJA8JjAKKb6vk1JO672jdEuWtsJ=hVg@mail.gmail.com>
References: <1454527121-4007853-1-git-send-email-tom@herbertland.com>
	<20160204093021.GB1553@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Tom Herbert <tom@herbertland.com>,
	David Miller <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, Peter Anvin <hpa@zytor.com>,
	"the arch/x86 maintainers" <x86@kernel.org>,
	kernel-team <kernel-team@fb.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>
To: Ingo Molnar <mingo@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:35727 "EHLO
	mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965728AbcBDVqM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Feb 2016 16:46:12 -0500
In-Reply-To: <20160204093021.GB1553@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I missed the original email (I don't have net-devel in my mailbox),
but based on Ingo's quoting have a more fundamental question:

Why wasn't that done with C code instead of asm with odd numerical targets?

It seems likely that the real issue is avoiding the short loops (that
will cause branch prediction problems) and use a lookup table instead.

But we can probably do better than that asm.

For example, for the actual "8 bytes or shorter" case, I think
something like this might just work fine:

  unsigned long csum_partial_8orless(const unsigned char *buf,
unsigned long len, unsigned long sum)
  {
        static const unsigned long mask[9] = {
                0x0000000000000000,
                0x000000000000ff00,
                0x000000000000ffff,
                0x00000000ff00ffff,
                0x00000000ffffffff,
                0x0000ff00ffffffff,
                0x0000ffffffffffff,
                0xff00ffffffffffff,
                0xffffffffffffffff };
        unsigned long val = load_unaligned_zeropad(buf + (len & 1));
        val &= mask[len];
        asm("addq %1,%0 ; adcq $0,%0":"=r" (sum):"r" (val), "0" (sum));
        return sum;
  }

NOTE! The above is 100% untested. But I _think_ it may handle the
odd-byte-case correctly, and it should result in just one 8-byte load
(the "load_unaligned_zeropad()" is just in case that ends up
overflowing and we have page-alloc-debug triggering a page fault at
the end). All without looping or any conditional branches that might
mispredict.

My point is that going to assembly results in pretty hard-to-read
code, but it's also fairly inflexible. If we stay with C, we can much
more easily play tricks. So for example, make the above an inline
function, and now you can do things like this:

  static inline unsigned long csum_partial_64bit(void *buf, unsigned
long len, unsigned long sum)
  {
        if (len <= 8)
                return csum_partial_8orless(buf, len, sum);

        /* We know it's larger than 8 bytes, so handle alignment */
        align = 7 & -(unsigned long)buf;
        sum = csum_partial_8orless(buf, align, sum);
        buf += align;

        /* We need to do the big-endian thing */
        sum = rotate_by8_if_odd(sum, align);

        /* main loop for big packets */
        .. do the unrolled inline asm thing that we already do ..

        sum = rotate_by8_if_odd(sum, align);

        /* Handle the last bytes */
        return csum_partial_8orless(buf, len, sum);
  }

  /* Fold the 64-bit sum we computed down to 32 bits __wsum */
  __wsum int csum_partial(void *buf, unsigned int len, __wsum partial)
  {
        unsigned long sum = csum_partial_64bit(ptr, len, partial);
        asm("addl %1,%0 ; adcl $0,%0":"=r" (sum):"r" (sum >> 32), "0" (sum));
        return sum;
 }

or something like that.

NOTE NOTE NOTE! I did a half-arsed attempt at getting the whole
"big-endian 16-bit add" thing right by doing the odd byte masking in
the end cases, and by rotating the sum by 8 bits around the
8-byte-unrolled-loop, but I didn't test the above. It's literally
written in my mail client. So I can almost guarantee that it is buggy,
but it is meant as an *example* of "why not do it this way" rather
than production code.

I think that writing it in C and trying to be intelligent about it
like the above would result in more maintainable code, and it is
possible that it would even be faster.

Yes, writing it in C *does* likely result in a few more cases of "adcq
$0" in order to finish up the carry calculations. The *only* advantage
of inline asm is how it allows you to keep the carry flag around. So
there is downside to the C model, and it might cause a cycle or two of
extra work, but the upside of C is that you can try to do clever
things without turning the code completely unreadable.

For example, doing the exception handling (that will never actually
trigger) for the "let's just do a 8-byte load" is just painful in
assembly. In C, we already have the helper function to do it.

Hmm? Would somebody be willing to take the likely very buggy code
above, and test it and make it work? I assume there's a test harness
for the whole csum thing somewhere.

                     Linus
