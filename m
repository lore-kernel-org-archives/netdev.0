From: "Du, Fan" <fan.du@intel.com>
Subject: RE: [RFC net-next] xfrm: refactory to avoid state tasklet
 scheduling errors
Date: Tue, 14 Jul 2015 07:53:11 +0000
Message-ID: <5A90DA2E42F8AE43BC4A093BF0678848E797EE@SHSMSX104.ccr.corp.intel.com>
References: <1436254997-2942-1-git-send-email-giuseppe.cantavenera@azcom.it>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexander Sverdlin <alexander.sverdlin@nokia.com>,
	Matija Glavinic Pecotic <matija.glavinic-pecotic.ext@nokia.com>,
	"Giuseppe Cantavenera" <giuseppe.cantavenera.ext@nokia.com>,
	Nicholas Faustini <nicholas.faustini.ext@nokia.com>,
	"Du, Fan" <fan.du@intel.com>
To: Giuseppe Cantavenera <giuseppe.cantavenera@azcom.it>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:31967 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751663AbbGNHzP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jul 2015 03:55:15 -0400
In-Reply-To: <1436254997-2942-1-git-send-email-giuseppe.cantavenera@azcom.it>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



>-----Original Message-----
>From: Giuseppe Cantavenera [mailto:giuseppe.cantavenera@azcom.it]
>Sent: Tuesday, July 7, 2015 3:43 PM
>To: netdev@vger.kernel.org
>Cc: Giuseppe Cantavenera; Steffen Klassert; David S. Miller; Du, Fan; Alexander
>Sverdlin; Matija Glavinic Pecotic; Giuseppe Cantavenera; Nicholas Faustini
>Subject: [RFC net-next] xfrm: refactory to avoid state tasklet scheduling errors
>
>The SA state is managed by a tasklet scheduled relying on the wall clock.
>Previous changes have already tried to address bugs
>when the system time is changed but some error conditions still exist,
>because the logic is still coupled with the wall time.
>
>If the time is changed in between the SA is created and the tasklet timer
>is started for the first time, the SA scheduling will be broken:
>either the SA will expire and never be recreated, or it will expire at
>an unexpected time.  The reason is that x->curlft.add_time will not be valid
>when the "next" variable is computed for the very first time
>in xfrm_timer_handler().
>
>Fix this behaviour by avoiding to rely on the system time.
>Stick to relative time intervals and realise a total decoupling
>from the wall time.
>
>Based on another patch written and published by
>Fan Du (fan.du@intel.com) in 2013 but never merged:
>part of the code preserved, some rewritten and improved.
>Changes to the logic accounting for the use_time expiration.
>Here we allow both add_time and use_time expirations to be set.
>
>Cc: Steffen Klassert <steffen.klassert@secunet.com>
>Cc: David S. Miller <davem@davemloft.net>
>Cc: Fan Du <fan.du@intel.com>
>Cc: Alexander Sverdlin <alexander.sverdlin@nokia.com>
>Cc: Matija Glavinic Pecotic <matija.glavinic-pecotic.ext@nokia.com>
>Signed-off-by: Giuseppe Cantavenera <giuseppe.cantavenera.ext@nokia.com>
>Signed-off-by: Nicholas Faustini <nicholas.faustini.ext@nokia.com>
>---
>
>Hello,
>
>we also meet the same bug Fan Du did a while ago.
>Two solutions were proposed in the past:
>either forcibly mark as expired all of the keys every time the clock is set,
>or replace the existing timers with relative ones.
>
>The former would introduce unexpected behaviour
>(the keys would keep expiring when they shouldn't) and does not address the
>real problem: THE COUPLING between the SA scheduling and the wall timer.
>Actually it introduces even more of that.
>
>The latter is robust, extremly lightweight and maintanable, and preserves the
>expected behaviour, that's why we preferred it.
>
>Any feedback or any other idea is greatly appreciated.

Thanks for keep working this issue as I did 2 years ago.

Objection against the original approach from the maintainers is that it complicates
the logic to the degree which involving extra maintenance effort, that is the effort
it's not worthwhile against the trouble it might introduce in the future.

Another approach you can try is using monotonic boot time(counting in suspend time also)
to mark the life time of SA, then the timer handler logic will be quite easier and smaller
than now, sure it will be robust naturally. The cost is that SA lifetime displaying by setkey
and SA migration has to be taken care of as SA life time is boot time now, not the wall time.


>Thanks,
>Regards,
>Giuseppe
