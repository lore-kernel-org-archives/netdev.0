From: Jean Tourrilhes <jt@hpl.hp.com>
Subject: Re: dBm cutoff at -1dBm is too low
Date: Fri, 5 May 2006 10:28:18 -0700
Message-ID: <20060505172818.GA7543@bougret.hpl.hp.com>
References: <1146760665.5294.65.camel@dv>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel9.hp.com ([156.153.255.214]:60078 "EHLO atlrel9.hp.com")
	by vger.kernel.org with ESMTP id S1751629AbWEER2W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 May 2006 13:28:22 -0400
To: Pavel Roskin <proski@gnu.org>
Content-Disposition: inline
In-Reply-To: <1146760665.5294.65.camel@dv>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 04, 2006 at 12:37:45PM -0400, Pavel Roskin wrote:
> Hello, Jean!
> 
> I'm converting Orinoco to the dBm reporting, and it turns out that the
> best signal iwconfig will report is -1dBm (0.8mW).  This would happen if
> qual->level has its highest value of 255.  Please see this code from
> wireless_tools.29.pre10:
> 
> len = snprintf(buffer, buflen, "Signal level%c%d dBm  ",
>                qual->updated & IW_QUAL_LEVEL_UPDATED ? '=' : ':',
>                qual->level - 0x100);

	Yes, that's correct.
	Note that the main limitation is that before I introduced the
explicit IW_QUAL_DBM in WE-19, the way to know if the value was
relative or dBm was to use the 'sign' of it, i.e. value above 0 were
non-dBm. The test is a few line before this snipset :

---------------------------------------------------------
      /* Check if the statistics are in dBm or relative */
      if((qual->updated & IW_QUAL_DBM)
	 || (qual->level > range->max_qual.level))
	{
---------------------------------------------------------

	There are still quite a few drivers which have not been
converted to use IW_QUAL_DBM, so I don't want to drop the backward
compatibility yet.

> With most cards transmitting at 100mW and some going as high as 500mW,
> it's not unreasonable to expect that the received signal may exceed 1mW
> for closely located receivers with good antennas.  I have seen HostAP
> reporting as much as 3mW through the proc filesystem!

	My rationale was two fold.
	First, such high values are quite unlikely, because cards need
to be very close, which does not happen that often. Power is limited
by spec and power consumption, so unlikely to go higher than
this. Also, I'm surprised that the card receiver does not saturate
with such high receive power, but I would question the accuracy of the
measurement.
	Second, the measurement is useful mostly in marginal
conditions. When signal is great, you don't really care, when signal
is low, you want to tweak your system to improve reception.

> Wouldn't it be better to put the cutoff at a higher value?  The simplest
> approach would be to treat qual->level and qual->noise as signed char,
> which would put the cutoff and 127dBm.  500 gigawatts should be enough
> for everyone :-)

	FCC says Tx 1W @ 2.4 GHz, ETSI says Tx 100mW @ 2.4 Gz. Yeah,
you could use directional antennas. So, realistically, we only need to
extend to +30dBm.
	On the other hand, I expect that with MIMO and UWB we would
start to receive signal weaker than what we currently do, and you
don't want to cutoff the bottom of the range (is -128dBm enough ?).
	I tried to use 'signed' in the struct a long while ago, and
for some reason it broke left and right, I don't remember the
details. So, whatever we do, it would not be straightforward.

> Regards,
> Pavel Roskin

	Have fun...

	Jean
