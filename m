From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 2/3] x86_64: Define 128-bit memory-mapped I/O operations
Date: Wed, 22 Aug 2012 07:06:28 -0700
Message-ID: <CA+55aFwrQu7L14T8-gc=QFNhHQnhoE9PZW3wXmjgt7RGH77xHA@mail.gmail.com>
References: <CA+55aFy=ohFoZ1yZGdj1DCcNXU9gsndgH9Qod4q8+s=sbGKUzQ@mail.gmail.com>
 <5034591E.3040908@zytor.com> <CA+55aFz39tCSO7sf7+czNEBcEx7q4=KbnAcKEoS-KBwr6D3Psg@mail.gmail.com>
 <20120821.220010.1158630981089834558.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: hpa@zytor.com, bhutchings@solarflare.com, tglx@linutronix.de,
	mingo@redhat.com, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com, x86@kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:42762 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753085Ab2HVOGt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2012 10:06:49 -0400
Received: by wicr5 with SMTP id r5so5755452wic.1
        for <netdev@vger.kernel.org>; Wed, 22 Aug 2012 07:06:48 -0700 (PDT)
In-Reply-To: <20120821.220010.1158630981089834558.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 21, 2012 at 10:00 PM, David Miller <davem@davemloft.net> wrote:
>
> All the x86 crypto code hits this case all the time, easiest example
> is doing a dm-crypt on a block device when an IPSEC packet arrives.
>
> The crypto code has all of this special code and layering that is
> there purely so it can fall back to the slow non-optimized version
> of the crypto operation when it hits this can't-nest-fpu-saving
> situation.

Right. And it needs to be there. The current interface is fine and correct.

We can maybe optimize the current model (as outlined earlier), but no,
there's no way in hell we're doing lazy saving of FPU state from
interrupts etc. So all the "check if I can use FPU state at all", and
the explicit kernel_fpu_begin/end() interfaces are absolutely the
right model.

I realize that the people who write that code think that *their* code
is the most important thing in the world, and everything else should
revolve around them, and we should make everything else slower just to
make them happy. But they are wrong.

Deal with it, or do not. You can do the crypto entirely in software. I
think the current model is absolutely the right one, exactly because
it *allows* you to use the FPU for crypto, but it doesn't force the
rest of the kernel to make sure the FPU is always available to you.

I think your complaining about the interface is entirely bogus, and
comes from not appreciating that other areas and uses have other
concerns.

What I would suggest is trying to do profiling, and seeing if the
"let's try to save only once, and restore only when returning to user
space" approach helps. But that's an *implementation* change, not an
interface change. The interface is doing the right thing, the
implementation is just not perhaps optimal.

                  Linus
