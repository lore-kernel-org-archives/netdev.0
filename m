From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH v3 net-next] net: Implement fast csum_partial for x86_64
Date: Thu, 4 Feb 2016 14:09:21 -0800
Message-ID: <CA+55aFwqq6n9OOTNOXMdWN4kJX9iJoP58fZ4KwTc51enxtkqgg@mail.gmail.com>
References: <1454527121-4007853-1-git-send-email-tom@herbertland.com>
	<20160204093021.GB1553@gmail.com>
	<CA+55aFxqs+mE=s4UkNQXJA8JjAKKb6vk1JO672jdEuWtsJ=hVg@mail.gmail.com>
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
Received: from mail-ig0-f195.google.com ([209.85.213.195]:35910 "EHLO
	mail-ig0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753116AbcBDWJW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Feb 2016 17:09:22 -0500
In-Reply-To: <CA+55aFxqs+mE=s4UkNQXJA8JjAKKb6vk1JO672jdEuWtsJ=hVg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 4, 2016 at 1:46 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
>         static const unsigned long mask[9] = {
>                 0x0000000000000000,
>                 0x000000000000ff00,
>                 0x000000000000ffff,
>                 0x00000000ff00ffff,
>                 0x00000000ffffffff,
>                 0x0000ff00ffffffff,
>                 0x0000ffffffffffff,
>                 0xff00ffffffffffff,
>                 0xffffffffffffffff };
>         unsigned long val = load_unaligned_zeropad(buf + (len & 1));
>         val &= mask[len];

Yeah, that was buggy. I knew it was likely buggy,  but that "buf +
(len & 1)" was just stupid.

The "+" should be "-", of course - the point is to shift up the value
by 8 bits for odd cases, and we need to load starting one byte early
for that. The idea is that we use the byte shifter in the load unit to
do some work for us.

And the bitmasks are the wrong way around for the odd cases - it's the
low byte that ends up being bogus for those cases.

So it should probably look something like

        static const unsigned long mask[9] = {
                0x0000000000000000,
                0x000000000000ff00,
                0x000000000000ffff,
                0x00000000ffffff00,
                0x00000000ffffffff,
                0x0000ffffffffff00,
                0x0000ffffffffffff,
                0xffffffffffffff00,
                0xffffffffffffffff };
        unsigned long val = load_unaligned_zeropad(buf - (len & 1));
        val &= mask[len];

and then it *might* work.

Still entirely and utterly untested, I just decided to look at it a
bit more and noticed my thinko.

                Linus
