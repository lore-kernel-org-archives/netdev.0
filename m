From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH v3 net-next] net: Implement fast csum_partial for x86_64
Date: Thu, 4 Feb 2016 17:27:31 -0800
Message-ID: <CA+55aFwGt-ZCna4cEUXP2Qd39etMgJYu6MTyimP38GKV4aK_aA@mail.gmail.com>
References: <1454527121-4007853-1-git-send-email-tom@herbertland.com>
	<20160204093021.GB1553@gmail.com>
	<CA+55aFxqs+mE=s4UkNQXJA8JjAKKb6vk1JO672jdEuWtsJ=hVg@mail.gmail.com>
	<CA+55aFwqq6n9OOTNOXMdWN4kJX9iJoP58fZ4KwTc51enxtkqgg@mail.gmail.com>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+55aFwqq6n9OOTNOXMdWN4kJX9iJoP58fZ4KwTc51enxtkqgg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 4, 2016 at 2:09 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> The "+" should be "-", of course - the point is to shift up the value
> by 8 bits for odd cases, and we need to load starting one byte early
> for that. The idea is that we use the byte shifter in the load unit to
> do some work for us.

Ok, so I thought some more about this, and the fact is, we don't
actually want to do the byte shifting at all for the first case (the
"length < 8" case), since the address of that one hasn't been shifted.

it's only for the "we're going to align things to 8 bytes" case that
we would want to do it. But then we might as well use the
rotate_by8_if_odd() model, so I suspect the address games are just
entirely pointless.

So here is something that is actually tested (although admittedly not
well), and uses that fairly simple model.

NOTE! I did not do the unrolling of the "adcq" loop in the middle, but
that's a totally trivial thing now. So this isn't very optimized,
because it will do a *lot* of extra "adcq $0" to get rid of the carry
bit. But with that core loop unrolled, you'd get rid of most of them.

                  Linus

---
static unsigned long rotate_by8_if_odd(unsigned long sum, unsigned long aligned)
{
        asm("rorq %b1,%0"
                :"=r" (sum)
                :"c" ((aligned & 1) << 3), "0" (sum));
        return sum;
}

static unsigned long csum_partial_lt8(unsigned long val, int len,
unsigned long sum)
{
        unsigned long mask = (1ul << len*8)-1;
        val &= mask;
        return add64_with_carry(val, sum);
}

static unsigned long csum_partial_64(const void *buff, unsigned long
len, unsigned long sum)
{
        unsigned long align, val;

        // This is the only potentially unaligned access, and it can
        // also theoretically overflow into the next page
        val = load_unaligned_zeropad(buff);
        if (len < 8)
                return csum_partial_lt8(val, len, sum);

        align = 7 & -(unsigned long)buff;
        sum = csum_partial_lt8(val, align, sum);
        buff += align;
        len -= align;

        sum = rotate_by8_if_odd(sum, align);
        while (len >= 8) {
                val = *(unsigned long *) buff;
                sum = add64_with_carry(sum, val);
                buff += 8;
                len -= 8;
        }
        sum = csum_partial_lt8(*(unsigned long *)buff, len, sum);
        return rotate_by8_if_odd(sum, align);
}

__wsum csum_partial(const void *buff, unsigned long len, unsigned long sum)
{
        sum = csum_partial_64(buff, len, sum);
        return add32_with_carry(sum, sum >> 32);
}
