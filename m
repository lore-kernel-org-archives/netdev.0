From: Pavel Roskin <proski@gnu.org>
Subject: Re: dBm cutoff at -1dBm is too low
Date: Sat, 06 May 2006 23:32:12 -0400
Message-ID: <1146972732.24434.89.camel@dv>
References: <1146760665.5294.65.camel@dv>
	 <20060505172818.GA7543@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fencepost.gnu.org ([199.232.76.164]:40352 "EHLO
	fencepost.gnu.org") by vger.kernel.org with ESMTP id S1750944AbWEGDcP
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 6 May 2006 23:32:15 -0400
Received: from proski by fencepost.gnu.org with local (Exim 4.34)
	id 1Fca0E-0008QD-W8
	for netdev@vger.kernel.org; Sat, 06 May 2006 23:32:15 -0400
To: jt@hpl.hp.com
In-Reply-To: <20060505172818.GA7543@bougret.hpl.hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-05-05 at 10:28 -0700, Jean Tourrilhes wrote:
> 	Note that the main limitation is that before I introduced the
> explicit IW_QUAL_DBM in WE-19, the way to know if the value was
> relative or dBm was to use the 'sign' of it, i.e. value above 0 were
> non-dBm. The test is a few line before this snipset :
> 
> ---------------------------------------------------------
>       /* Check if the statistics are in dBm or relative */
>       if((qual->updated & IW_QUAL_DBM)
> 	 || (qual->level > range->max_qual.level))
> 	{
> ---------------------------------------------------------
> 
> 	There are still quite a few drivers which have not been
> converted to use IW_QUAL_DBM, so I don't want to drop the backward
> compatibility yet.

But shouldn't you trust the drivers using IW_QUAL_DBM, whether the value
is positive or negative?

> 	Second, the measurement is useful mostly in marginal
> conditions. When signal is great, you don't really care, when signal
> is low, you want to tweak your system to improve reception.

The problem is the driver has to take care of it.  It cannot just take
the dBm value from the card and pass it to userspace.  It has to limit
the value at -1.  Otherwise iwconfig would show -256dBm or something
like that.  I can imagine that some GUI can decide that the connection
has become very bad, and that would confuse the user.

> > Wouldn't it be better to put the cutoff at a higher value?  The simplest
> > approach would be to treat qual->level and qual->noise as signed char,
> > which would put the cutoff and 127dBm.  500 gigawatts should be enough
> > for everyone :-)
> 
> 	FCC says Tx 1W @ 2.4 GHz, ETSI says Tx 100mW @ 2.4 Gz. Yeah,
> you could use directional antennas. So, realistically, we only need to
> extend to +30dBm.
> 	On the other hand, I expect that with MIMO and UWB we would
> start to receive signal weaker than what we currently do, and you
> don't want to cutoff the bottom of the range (is -128dBm enough ?).
> 	I tried to use 'signed' in the struct a long while ago, and
> for some reason it broke left and right, I don't remember the
> details. So, whatever we do, it would not be straightforward.

I suggest -192dBm to 63dBm.  That's enough padding on both sides, so
that the drivers can just pass the firmware value without checking.

-- 
Regards,
Pavel Roskin

