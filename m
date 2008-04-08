From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] forcedeth: new backoff implementation
Date: Tue, 8 Apr 2008 01:14:25 -0700
Message-ID: <20080408011425.ff2dc98a.akpm@linux-foundation.org>
References: <47FA94CC.7070300@nvidia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>,
	Manfred Spraul <manfred@colorfullife.com>,
	nedev <netdev@vger.kernel.org>
To: Ayaz Abdulla <aabdulla@nvidia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:60836 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751791AbYDHIOh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Apr 2008 04:14:37 -0400
In-Reply-To: <47FA94CC.7070300@nvidia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 07 Apr 2008 17:40:28 -0400 Ayaz Abdulla <aabdulla@nvidia.com> wrote:

> This patch adds support for a new backoff algorithm for half duplex 
> supported in newer hardware. The old method is will be designated as 
> legacy mode.
> 
> Re-seeding random values for the backoff algorithms are performed when a 
> transmit has failed due to a maximum retry count (1 to 15, where max is 
> considered the wraparound case of 0).
> 
> ...
>
> +static void nv_legacybackoff_reseed(struct net_device *dev)
> +{
> +	u8 __iomem *base = get_hwbase(dev);
> +	u32 reg;
> +	u32 low;
> +	int tx_status = 0;
> +
> +	reg = readl(base + NvRegSlotTime) & ~NVREG_SLOTTIME_MASK;
> +	rdtscl(low);
> +	reg |= low & NVREG_SLOTTIME_MASK;
> +
> +	/* need to stop tx before change takes effect */
> +	tx_status = readl(base + NvRegTransmitterControl) & NVREG_XMITCTL_START;
> +	if (tx_status)
> +		nv_stop_tx(dev);
> +	nv_stop_rx(dev);
> +	writel(reg, base + NvRegSlotTime);
> +	if (tx_status)
> +		nv_start_tx(dev);
> +	nv_start_rx(dev);
> +}

Is there sufficient locking in place to prevent some other thread of
control coming in and trying to stop or start tx and/or rx while this
function is running?

> +static void nv_gear_backoff_reseed(struct net_device *dev)
> +{
> +	u8 __iomem *base = get_hwbase(dev);
> +	u32 miniseed1, miniseed2, miniseed2_reversed, miniseed3, miniseed3_reversed;
> +	u32 temp, seedset, combinedSeed;
> +	int i;
> +
> +	/* Setup seed for free running LFSR */
> +	/* We are going to read the time stamp counter 3 times and swizzle bits around to increase randomness */

I see this driver rigorously observes the 800-column-xterm convention.

> +	rdtscl(miniseed1);

err, no.  We don't have sufficient Kconfig dependencies in place to be able
to do this.  You just broke all non-x86.

Suitable fixes would be

a) add #ifdef CONFIG_X86 all over the place

b) use do_gettimeofday() (might be tricky if called from interrupt)

c) use cpu_clock().

> +	miniseed1 &= 0x0fff;
> +	if (miniseed1 == 0)
> +		miniseed1 = 0xabc;
> +
> +	rdtscl(miniseed2);
> +	miniseed2 &= 0x0fff;
> +	if (miniseed2 == 0)
> +		miniseed2 = 0xabc;
> +	miniseed2_reversed = ((miniseed2 & 0xF00) >> 8) | (miniseed2 & 0x0F0) | ((miniseed2 & 0x00F) << 8);
> +
> +	rdtscl(miniseed3);
> +	miniseed3 &= 0x0fff;
> +	if (miniseed3 == 0)
> +		miniseed3 = 0xabc;
> +	miniseed3_reversed = ((miniseed3 & 0xF00) >> 8) | (miniseed3 & 0x0F0) | ((miniseed3 & 0x00F) << 8);
> +
> +	combinedSeed = ((miniseed1 ^ miniseed2_reversed) << 12) | (miniseed2 ^ miniseed3_reversed);
> +
> +	/* Seeds can not be zero */
> +	if ((combinedSeed & NVREG_BKOFFCTRL_SEED_MASK) == 0)
> +		combinedSeed |= 0x08;
> +	if ((combinedSeed & (NVREG_BKOFFCTRL_SEED_MASK << NVREG_BKOFFCTRL_GEAR)) == 0)
> +		combinedSeed |= 0x8000;
> +
> +	/* Ensure seeds are not the same */
> +	if ((combinedSeed & NVREG_BKOFFCTRL_SEED_MASK) ==
> +	    (combinedSeed & (NVREG_BKOFFCTRL_SEED_MASK << NVREG_BKOFFCTRL_GEAR)))
> +		combinedSeed = 0x3FF3FF;
> +
> +	/* No need to disable tx here */
> +	temp = NVREG_BKOFFCTRL_DEFAULT | (0 << NVREG_BKOFFCTRL_SELECT);
> +	temp |= combinedSeed & NVREG_BKOFFCTRL_SEED_MASK;
> +	temp |= combinedSeed >> NVREG_BKOFFCTRL_GEAR;
> +	writel(temp,base + NvRegBackOffControl);
> +
> +    	/* Setup seeds for all gear LFSRs. */
> +	rdtscl(seedset);
> +	seedset = seedset % BACKOFF_SEEDSET_ROWS;
> +	for (i = 1; i <= BACKOFF_SEEDSET_LFSRS; i++)
> +	{
> +		temp = NVREG_BKOFFCTRL_DEFAULT | (i << NVREG_BKOFFCTRL_SELECT);
> +		temp |= gMainSeedSet[seedset][i-1] & 0x3ff;
> +		temp |= ((gGearSeedSet[seedset][i-1] & 0x3ff) << NVREG_BKOFFCTRL_GEAR);
> +		writel(temp, base + NvRegBackOffControl);
> +	}
> +}

Is lib/random32.c not useful here?  Perhaps after suitable modification?


