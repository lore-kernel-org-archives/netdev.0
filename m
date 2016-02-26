From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH v4 net-next] net: Implement fast csum_partial for x86_64
Date: Fri, 26 Feb 2016 12:41:51 -0800
Message-ID: <CALx6S37wttHggeHWy7JnMrrpY6A98asgv0J25ZLVpyFYDPCWcw@mail.gmail.com>
References: <1456516995-3471163-1-git-send-email-tom@herbertland.com>
	<CA+55aFzf9enVibvBzbu_wqU4OSm_QYivmJf3vmyH1BxvCLxJog@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, Peter Anvin <hpa@zytor.com>,
	"the arch/x86 maintainers" <x86@kernel.org>,
	kernel-team <kernel-team@fb.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:38613 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754946AbcBZUlw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2016 15:41:52 -0500
Received: by mail-ig0-f182.google.com with SMTP id y8so43528989igp.1
        for <netdev@vger.kernel.org>; Fri, 26 Feb 2016 12:41:52 -0800 (PST)
In-Reply-To: <CA+55aFzf9enVibvBzbu_wqU4OSm_QYivmJf3vmyH1BxvCLxJog@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 26, 2016 at 12:29 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
> Looks ok to me.
>
> I am left wondering if the code should just do that
>
>     add32_with_carry3(sum, result >> 32, result);
>
> in the caller instead - right now pretty much every return point in
> do_csum() effectively does that,  with the exception of
>
>  - the 0-length case, which is presumably not really an issue in real
> life and could as well just return 0
>
>  - the 8-byte case that does two 32-bit loads instead, but could just
> do a single 8-byte load and return it (and then the generic version in
> the caller would do a shift).

Right, it is slightly faster for those two cases to return the result
directly. (csum over 8 bytes might be common with some encapsulation
protocols).

>
> That would simplifiy the code a bit - it wouldn't need to pass in
> "sum" to do_csum at all, and we'd have just a single case of that
> special 3-input carry add..
>
> But I'm certainly ok with it as-is. I'm not sure how performance
> critical the whole csum routine is, but at least now it doesn't
> introduce a lot of new complex asm.
>
Micro-performance optimizations may become more relevant as we
introduce more high performance network paths to the kernel. But the
short term reason for this is to dispel any remaining notion that NIC
HW support for CHECKSUM_UNNECESSARY is somehow better than
CHECKSUM_COMPLETE because pulling up checksums in the protocols is too
expensive.

Tom

> And this version might be reasonable to make generic, so that non-x86
> architectures could use the same approach. That's what we ended up
> doing for the dcache word-at-a-time code too in the end.
>
>                 Linus
