From: David Miller <davem@davemloft.net>
Subject: Re: net/3com/3c515: Fix timer handling, prevent leaks and crashes
Date: Fri, 16 Dec 2016 13:25:35 -0500 (EST)
Message-ID: <20161216.132535.904601621144551948.davem@davemloft.net>
References: <alpine.DEB.2.20.1612111826310.18281@nanos>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        tedheadster@gmail.com, luto@kernel.org
To: tglx@linutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53368 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932775AbcLPSZh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2016 13:25:37 -0500
In-Reply-To: <alpine.DEB.2.20.1612111826310.18281@nanos>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Gleixner <tglx@linutronix.de>
Date: Sun, 11 Dec 2016 18:31:22 +0100 (CET)

> The timer handling in this driver is broken in several ways:
> 
> - corkscrew_open() initializes and arms a timer before requesting the
>   device interrupt. If the request fails the timer stays armed.
> 
>   A second call to corkscrew_open will unconditionally reinitialize the
>   quued timer and arm it again. Also a immediate device removal will leave
>   the timer queued because close() is not called (open() failed) and
>   therefore nothing issues del_timer().
> 
>   The reinitialization corrupts the link chain in the timer wheel hash
>   bucket and causes a NULL pointer dereference when the timer wheel tries
>   to operate on that hash bucket. Immediate device removal lets the link
>   chain poke into freed and possibly reused memory.
> 
>   Solution: Arm the timer after the successful irq request.
> 
> - corkscrew_close() uses del_timer()
> 
>   On close the timer is disarmed with del_timer() which lets the following
>   code race against a concurrent timer expiry function.
> 
>   Solution: Use del_timer_sync() instead
> 
> - corkscrew_close() calls del_timer() unconditionally
> 
>   del_timer() is invoked even if the timer was never initialized. This
>   works by chance because the struct containing the timer is zeroed at
>   allocation time.
> 
>   Solution: Move the setup of the timer into corkscrew_setup().
> 
> Reported-by: Matthew Whitehead <tedheadster@gmail.com>
> Signed-off-by: Thomas Gleixner <tglx@linutronix.de>

Applied, thanks Thomas.
