From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH v4 net-next] net: Implement fast csum_partial for x86_64
Date: Fri, 26 Feb 2016 12:29:10 -0800
Message-ID: <CA+55aFzf9enVibvBzbu_wqU4OSm_QYivmJf3vmyH1BxvCLxJog@mail.gmail.com>
References: <1456516995-3471163-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, Peter Anvin <hpa@zytor.com>,
	"the arch/x86 maintainers" <x86@kernel.org>,
	kernel-team <kernel-team@fb.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f193.google.com ([209.85.213.193]:36049 "EHLO
	mail-ig0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754879AbcBZU3L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2016 15:29:11 -0500
Received: by mail-ig0-f193.google.com with SMTP id xg9so4593474igb.3
        for <netdev@vger.kernel.org>; Fri, 26 Feb 2016 12:29:10 -0800 (PST)
In-Reply-To: <1456516995-3471163-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Looks ok to me.

I am left wondering if the code should just do that

    add32_with_carry3(sum, result >> 32, result);

in the caller instead - right now pretty much every return point in
do_csum() effectively does that,  with the exception of

 - the 0-length case, which is presumably not really an issue in real
life and could as well just return 0

 - the 8-byte case that does two 32-bit loads instead, but could just
do a single 8-byte load and return it (and then the generic version in
the caller would do a shift).

That would simplifiy the code a bit - it wouldn't need to pass in
"sum" to do_csum at all, and we'd have just a single case of that
special 3-input carry add..

But I'm certainly ok with it as-is. I'm not sure how performance
critical the whole csum routine is, but at least now it doesn't
introduce a lot of new complex asm.

And this version might be reasonable to make generic, so that non-x86
architectures could use the same approach. That's what we ended up
doing for the dcache word-at-a-time code too in the end.

                Linus
