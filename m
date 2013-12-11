From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH RFC] mlx4_en: Add PTP hardware clock
Date: Wed, 11 Dec 2013 19:54:39 +0100
Message-ID: <20131211185438.GC4371@netboy>
References: <1386786265-6322-1-git-send-email-shawn.bohrer@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>, netdev@vger.kernel.org,
	tomk@rgmadvisors.com, Shawn Bohrer <sbohrer@rgmadvisors.com>
To: Shawn Bohrer <shawn.bohrer@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f172.google.com ([209.85.215.172]:59421 "EHLO
	mail-ea0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750922Ab3LKSy6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Dec 2013 13:54:58 -0500
Received: by mail-ea0-f172.google.com with SMTP id q10so2912731ead.31
        for <netdev@vger.kernel.org>; Wed, 11 Dec 2013 10:54:54 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1386786265-6322-1-git-send-email-shawn.bohrer@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 11, 2013 at 12:24:25PM -0600, Shawn Bohrer wrote:
> From: Shawn Bohrer <sbohrer@rgmadvisors.com>
> 
> This adds a PHC to the mlx4_en driver.  This is largely based off of the
> e1000e driver (drivers/net/ethernet/intel/e1000e/ptp.c) which seemed
> very similar.  One thing I am unsure about is that in the e1000e driver
> they protect the timecounter code with a spinlock because the hardware
> reports the time in two 32bit registers.  The Mellanox code looks
> similar however the existing timecounter code in the mlx4_en driver
> wasn't protected with a lock so I left the lock out here as well.

Before, there were only three call sites,

grep -nH -e timecounter_ *
en_clock.c:108:	nsec = timecounter_cyc2time(&mdev->clock, timestamp);
en_clock.c:131:	timecounter_init(&mdev->clock, &mdev->cycles,
en_clock.c:148:		timecounter_read(&mdev->clock);

and so perhaps the locking was unnecessary (but maybe not).
In any case, the code that you added definitely needs locks.

> Additionally here the mlx4_en_phc_adjfreq() method simply returns
> -EOPNOTSUPP because I don't have the relevant hardware documentation on
> how to do this.  I'm hoping one of the Mellanox developers can either
> provide this documentation or provide a patch to implement that
> function.

Since the code already uses timecounter_read to convert clock ticks
into nanoseconds, why not simply adjust the 'mult' as other drivers
do?

[ If the clock is easily adjustable in hardware, then, by all means,
  do it that way. ]
 
> This is minimally tested at this point but Documentation/ptp/testptp
> appears to work on a Mellanox ConnectX-3 card.

Once you have the adjustment in place, then you can try it with
linuxptp.

Thanks,
Richard
