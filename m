From: Michal Soltys <soltys@ziu.info>
Subject: Re: HFSC classes going out of bounds, regression in recent kernels?
Date: Mon, 31 May 2010 19:53:42 +0200
Message-ID: <4C03F7A6.2090204@ziu.info>
References: <201004061822.21735.nuclearcat@nuclearcat.com> <4BBB5543.40607@trash.net> <201005200434.28433.nuclearcat@nuclearcat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	Jeff Garzik <jeff@garzik.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Denys Fedorysychenko <nuclearcat@nuclearcat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from drutsystem.com ([80.72.38.138]:3760 "EHLO drutsystem.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754478Ab0EaSPa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 May 2010 14:15:30 -0400
In-Reply-To: <201005200434.28433.nuclearcat@nuclearcat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10-05-20 03:34, Denys Fedorysychenko wrote:
> I am trying to track down HFSC bug.
> It seems, most probably it is related to PSCHED_SHIFT at the end, i am doing
> testing again. I will try to do complete clean build, maybe last time some .o
> was left or i forgot to do make clean.
> 
> SM_SHIFT in HFSC is calculated as 30 - PSCHED_SHIFT, and it is shifted too
> much (or not enough) with new changes (ISM_SHIFT seems wrong too). So it is
> most probably overflow or not enough resolution.
> I will try to change PSCHED_SHIFT back to confirm that, and at least i found
> way to reproduce bug.
> 
> Additionally in sch_hfsc.c i notice mentioned that PSCHED_SHIFT 10 is tick per
> 1024us, but i try to calculate their table (in source comments), it doesn't
> fit with my calculations based on 1024us/tick, but fits well with 1024
> nanosecond.
> 
> Is it was 1024ns per tick and now 64ns per tick? Or it is microseconds(us) ?
> --

In the old table (when PSCHED_SHIFT was 10) in the hfsc file, the requirements 
to keep 4 decimal digits were 20 and 18 for SM_ and ISM_ respectively. 
For the reference:

 *  bits/sec      100Kbps     1Mbps     10Mbps     100Mbps    1Gbps
 *  ------------+-------------------------------------------------------
 *  bytes/1.024us 12.8e-3    128e-3     1280e-3    12800e-3   128000e-3
 *  1.024us/byte  78.125     7.8125     0.78125    0.078125   0.0078125
 *
 * So, for PSCHED_SHIFT 10 we need: SM_SHIFT 20, ISM_SHIFT 18.


Considering the table - and if I didn't miss anything - they were swapped.

psticks/byte in its "corner" case (0.0078125) requires 1e6, which corrsponds to 
ISM_SHIFT == 20.

Similary, corner case for bytes/pstick (0.0128) requires 1e5, where 
SM_SHIFT == 17 would be sufficient.

The above assuming pstick is 1.024us

Currently, with PSCHED_SHIFT == 6 (so pstick is 64ns), the define macros 
actually hit the spot, giving following values:

bytes/pstick: SM_SHIFT  24 (0.0008 @ 100kbit)
psticks/byte: ISM_SHIFT 14 (0.125  @ 1gbit)

But in generic case - the macros will not yield appropriate results - e.g. 
for PSCHED_SHIFT == 10, SM_SHIFT would be 20 and ISM_SHIFT would be 18 (not 
enough for 4 decimal digits).

On a related subject - it would probably be desirable to consider smaller 
speeds than 100kbit, as adsl links with mere 128kbit upstream total are 
nothing out of ordinary. If we considered 10kbit as the reference value, we 
would need SM_SHIFT 27 to cover 0.00008 @ 10kbit. Not sure if 10gbit is 
desirable too - ISM_SHIFT would need 17 then. All assuming that 4 decimal 
digits is what we really need.

