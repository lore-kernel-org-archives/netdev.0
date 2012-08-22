From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] x86_64: Define 128-bit memory-mapped I/O operations
Date: Wed, 22 Aug 2012 14:38:19 -0700 (PDT)
Message-ID: <20120822.143819.1261952354301786625.davem@davemloft.net>
References: <20120821.211427.1832042852041589162.davem@davemloft.net>
	<20120822.141433.730254311852927123.davem@davemloft.net>
	<CA+55aFxxSFMiohu80BZCObA0APPe08h1-7eAZ_BLoAZDWqqv0Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hpa@zytor.com, bhutchings@solarflare.com, tglx@linutronix.de,
	mingo@redhat.com, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com, x86@kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58361 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753630Ab2HVViU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2012 17:38:20 -0400
In-Reply-To: <CA+55aFxxSFMiohu80BZCObA0APPe08h1-7eAZ_BLoAZDWqqv0Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 22 Aug 2012 14:28:50 -0700

> On Wed, Aug 22, 2012 at 2:14 PM, David Miller <davem@davemloft.net> wrote:
>>
>> BTW, just to clarify, I'm not saying that we should save the FPU on
>> every trap where we find the FPU enabled or anything stupid like that.
>>
>> Definitely keep the kern_fpu_begin()/kern_fpu_end() type markers
>> around FPU usage, but allow some kind of nesting facility.
> 
> So nesting shouldn't be horrible, but the thing that really screws
> with people like the crypto use is not nesting, but the fact that
> sometimes you can't save at all, and the whole "kernel_fpu_possible()"
> or whatever we call the checking function.
> 
> IOW, in [soft]irq context, to avoid races with the irq happening as
> the process is going to do something with the FPU state, we don't
> allow saving and changing state, because that would mean that the
> normal FP state paths would have to be irq-safe, and they aren't.
> 
> And once you have to have that fpu possible check, if it happens to
> also disallow nested use, I doubt that's going to really affect
> anybody. The code has to take the case of "I'm not allowed to change
> FPU state" case into account regardless.

I don't think you really have to do anything special to handle
interrupts properly.

Let's assume that we use some variable length save area at the end of
thread_info to do this nested saving.

When you are asked for FPU usage, you first figure out how much you're
going to save.

Then you advance the allocation pointer in the thread_info, and save
into the space you allocated.

If an interrupt wants to use the FPU, that should be fine as well.
Whether the interrupt FPU save does it's save after you did, or
before, it should work out fine.

I suppose you might have some issues in determining whether we need to
do the full fxsave stuff or not.  There could be a state bit for that,
or similar.

Another idea, instead of doing this in thread_info, is to do it on the
local stack.  That way if we're in an interrupt, we'll use that
interrupt type's kernel stack.

You might be able to get away with always doing the full FPU
save/restore in that situation.
