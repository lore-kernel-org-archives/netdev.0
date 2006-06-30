From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH] improved statistics for bcm43xx-softmac
Date: Thu, 29 Jun 2006 22:07:58 -0500
Message-ID: <44A4958E.6040701@lwfinger.net>
References: <44A3524C.40704@lwfinger.net> <1151614610.15090.30.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Linville <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc12.worldnet.att.net ([204.127.131.116]:34793 "EHLO
	mtiwmhc12.worldnet.att.net") by vger.kernel.org with ESMTP
	id S964938AbWF3DID (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Jun 2006 23:08:03 -0400
To: Dan Williams <dcbw@redhat.com>
In-Reply-To: <1151614610.15090.30.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dan Williams wrote:

> To me, it looks like you're trying to use dBm rather than RSSI here.  In
> that case, you have to set range->max_qual.level to 0, because the upper
> bound of dBm is indeed 0.  If you are using negative values _anywhere_
> in your code for quality, you're almost certainly using dBm, not RSSI,
> or something is very wrong.
> Print out the value of 'average' from handle_irq_noise() both when close
> and far away from the AP.  It looks to me like the final calculations
> there come out in dBm given the fact that (a) average is negative, and
> (b) that average is in the range of acceptable dBm numbers.  So:
> 
> 1. set your stats->max_qual.level = 0
> 2. set bcm->stats.link_quality = average
> 3. Do link quality calculation on signal and noise; you can't just be
> linear here though, since a noise floor of -100 with a signal of -90 is
> in reality better than 10% signal; it's actually pretty OK.  Each -1 dBm
> step near the noise floor counts for more % than a -1 dBm increase near
> the best signal level.  You have to weight the bottom of the scale WRT
> percentage to get values that make sense.

Thanks for explaining how to get dBm into these fields. The comments in include/linux/wireless.h are 
confusing.

The quantity listed in stats.rssi has been processed into a dBm value in a routine called 
bcm43xx_rssi_postprocess, which I need to mention in the comments. The calculation is more black 
magic from the clean-room group's reverse engineering of the Mips driver. I changed the name of the 
constant from RSSI_MAX to RX_POWER_MAX, which I estimate to be -10 dBm (see below).

As I move away from the AP, I get the following results:

Dist.	"rssi"	"average"	Link Quality	Notes

.3 m	-14	-64		96/100		Nearly on top of AP
  2 m	-27	-62		83/100		Direct line of sight
15 m	-55	-65		55/100		Bounce down hallway and/or through wall
20 m	-66	-66		44/100		Like 15m point, but through plate glass window
						 - 35% packet loss with ping

The "Link Quality" above comes from 100 - "rssi" - RX_POWER_MAX, where RX_POWER_MAX is -10.

As "average" does not change, clearly the link quality cannot be derived from that value. It seems 
to me that the processed value in the stats.rssi field is not too bad an estimate of the qual.level 
(in dBm). The value from "average" is also not a good estimate of the noise, but it is the best I 
have at the moment. Clearly, the reported value of qual.qual (Link quality) needs to be adjusted

> ipw2200 for example reports -53 dBm near the AP, with noise floor of -83
> dBm in a fairly spectrum-crowded area.  That translates into what
> ipw2200 reports as a 75% signal, which seems a bit off, but gives you an
> idea.  You'll never get near 0 dBm, since there's already 10s of dBm
> loss when the signal has to cross any air at all.

I'm now getting a similar result with an 85% signal at 2 m. The main difference is that both signal 
and noise seem to be shifted up by about 20 dBm. As these are logarithmic quantities, S/N is 
preserved through this offset. My feeling is that these statistics have no absolute meaning, but are 
good as relative indicators. When the left-most bar in the Wireless Network Information applet in 
the KDE taskbar changes from green to yellow, I know that the signal is degraded.

Thanks for your comments. They made me dig a lot deeper into the numbers.

Larry

