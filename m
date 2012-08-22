From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] x86_64: Define 128-bit memory-mapped I/O operations
Date: Wed, 22 Aug 2012 14:14:33 -0700 (PDT)
Message-ID: <20120822.141433.730254311852927123.davem@davemloft.net>
References: <CA+55aFy=ohFoZ1yZGdj1DCcNXU9gsndgH9Qod4q8+s=sbGKUzQ@mail.gmail.com>
	<5034591E.3040908@zytor.com>
	<20120821.211427.1832042852041589162.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, bhutchings@solarflare.com,
	tglx@linutronix.de, mingo@redhat.com, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com, x86@kernel.org
To: hpa@zytor.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58184 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753493Ab2HVVOg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2012 17:14:36 -0400
In-Reply-To: <20120821.211427.1832042852041589162.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Tue, 21 Aug 2012 21:14:27 -0700 (PDT)

> From: "H. Peter Anvin" <hpa@zytor.com>
> Date: Tue, 21 Aug 2012 20:59:26 -0700
> 
>> kernel_fpu_end() would still have to re-enable preemption (and
>> preemption would have to check the work flag), but that should be cheap.
>> 
>> We could allow the FPU in the kernel to have preemption, if we allocated
>> space for two xstates per thread instead of one.  That is, however, a
>> fair hunk of memory.
> 
> Once you have done the first FPU save for the sake of the kernel, you
> can minimize what you save for any deeper nesting because the kernel
> only cares about a very limited part of that FPU state not the whole
> 1K thing.
> 
> Those bits you can save by hand with a bunch of explicit stores of the
> XMM registers, or something like that.

BTW, just to clarify, I'm not saying that we should save the FPU on
every trap where we find the FPU enabled or anything stupid like that.

Definitely keep the kern_fpu_begin()/kern_fpu_end() type markers
around FPU usage, but allow some kind of nesting facility.

Here's one idea.  Anyone using the existing kern_fpu_*() markers get
the existing behavior.  Only one level of kernel FPU usage is allowed.

But a new interface allows specification of a state-save mask.  And it
is only users of this interface for which we allow nesting past the
first FPU user.

If this is the first kernel FPU user, we always do the full fxsave or
whatever to push out the full state.  For any level of kernel FPU
nesting we save only what is in the save-mask, by hand.
