From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] x86_64: Define 128-bit memory-mapped I/O operations
Date: Tue, 21 Aug 2012 20:29:45 -0700 (PDT)
Message-ID: <20120821.202945.2278895156403194101.davem@davemloft.net>
References: <1345601051.2659.93.camel@bwh-desktop.uk.solarflarecom.com>
	<20120821.193446.1534561579811962053.davem@davemloft.net>
	<503450E2.2040504@zytor.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, tglx@linutronix.de, mingo@redhat.com,
	netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	x86@kernel.org, torvalds@linux-foundation.org
To: hpa@zytor.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48019 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751557Ab2HVD3r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Aug 2012 23:29:47 -0400
In-Reply-To: <503450E2.2040504@zytor.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "H. Peter Anvin" <hpa@zytor.com>
Date: Tue, 21 Aug 2012 20:24:18 -0700

> I'm all ears... tell me how sparc64 deals with this, maybe we can
> implement something similar.  At the same time, do keep in mind that on
> x86 this is not just a matter of the FPU state, but the entire "extended
> state" which can be very large.

Sparc's state is pretty huge too.  256 bytes worth of FPU registers,
plus a set of 64-bit control registers.

What we do is we have a FPU stack that grows up from the end of the
thread_info struct, towards the bottom of the kernel stack.

Slot 0 is always the user FPU state.

Slot 1 and further are kernel FPU state save areas.

We hold a counter which keep track of how far deeply saved we are
in the stack.

Not for the purpose of space saving, but for overhead reduction we
sometimes can get away with only saving away half of the FPU
registers.  The chip provides a pair of dirty bits, one for the lower
half of the FPU register file and one for the upper half.  We only
save the bits that are actually dirty.

Furthermore, when we have FPU using code in the kernel that only uses
the lower half of the registers, we only save away that part of the
state around the routine.
