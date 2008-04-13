From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH] lne390 and Jensen Alphas
Date: Sun, 13 Apr 2008 23:11:44 +0100
Message-ID: <20080413221144.GR9785@ZenIV.linux.org.uk>
References: <209D18A1-2B61-47F8-B1DC-067C1E676B9D@ccac.rwth-aachen.de> <200803291932.30204.florian.fainelli@telecomint.eu> <20080413210646.GA8178@heisenberg.ccac.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <florian.fainelli@telecomint.eu>,
	netdev@vger.kernel.org
To: Carsten Jacobi <carsten@ccac.rwth-aachen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:33256 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752960AbYDMWLq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Apr 2008 18:11:46 -0400
Content-Disposition: inline
In-Reply-To: <20080413210646.GA8178@heisenberg.ccac.rwth-aachen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 13, 2008 at 11:06:46PM +0200, Carsten Jacobi wrote:
> +	/* The mylex lne390 adapter requires 32bit access (see above) for every
> +	 * operation to the shared mem buffer. Since the block buffer is hardly
> +	 * aligned to a 32bit boundary memcpy_toio() will use 16bit
> +	 * operations to access the buffer ... we must use something else here. */
> +
> +	const void *from = buf;
> +	count -= 4;
> +	do {
> +		__raw_writel(*(const u16 *)from | (*(const u16 *)(from+2))<<16,
> +		(unsigned long) shmem);

The last argument of __raw_writel() is void __iomem *, not unsigned long.
WTF is that cast doing that?  Besides, it looks like misspelled
		const __le32 *from = buf;
		...
		__raw_writel(get_unaligned(from), shmem);

> +		(unsigned long) shmem += 4;

Write in C, please.  This isn't - you might as well write something like
	shmem * 2 -= 4;
since result of cast is not an l-value.

Finally, how much of that actually depends on Jensen and how much is
actually "oh, on x86 we use rep movsl in memcpy_toio(), so it ends up
with 32bit accesses"?
