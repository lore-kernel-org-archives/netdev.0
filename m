From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: [PATCH 2/3] x86_64: Define 128-bit memory-mapped I/O operations
Date: Tue, 21 Aug 2012 20:59:26 -0700
Message-ID: <5034591E.3040908@zytor.com>
References: <1345598601.2659.76.camel@bwh-desktop.uk.solarflarecom.com> <503437D4.8090706@zytor.com> <1345601051.2659.93.camel@bwh-desktop.uk.solarflarecom.com> <20120821.193446.1534561579811962053.davem@davemloft.net> <503450E2.2040504@zytor.com> <CA+55aFy=ohFoZ1yZGdj1DCcNXU9gsndgH9Qod4q8+s=sbGKUzQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, bhutchings@solarflare.com,
	tglx@linutronix.de, mingo@redhat.com, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com, x86@kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from terminus.zytor.com ([198.137.202.10]:37972 "EHLO mail.zytor.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753305Ab2HVD7n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Aug 2012 23:59:43 -0400
In-Reply-To: <CA+55aFy=ohFoZ1yZGdj1DCcNXU9gsndgH9Qod4q8+s=sbGKUzQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/21/2012 08:52 PM, Linus Torvalds wrote:
> 
> That said, we might *try* to make the kernel FPU use be cheaper. We
> could do something like:
> 
>  - if we need to restore FPU state for user mode, don't do it
> synchronously in kernel_fpu_end(), just set a work-flag, and do it
> just once before returning to user mode
> 
>  - that makes kernel_fpu_end() a no-op, and while we can't get rid of
> kernel_fpu_begin(), we could at least make it cheap to do many times
> consecutively (ie we'd have to check "who owns FPU state" and perhaps
> save it, but the save would have to be done only the first time).
> 

The zeroeth order thing we should do is to make it nest; there are cases
where we do multiple kernel_fpu_begin/_end in sequence for no good reason.

kernel_fpu_end() would still have to re-enable preemption (and
preemption would have to check the work flag), but that should be cheap.

We could allow the FPU in the kernel to have preemption, if we allocated
space for two xstates per thread instead of one.  That is, however, a
fair hunk of memory.

	-hpa
