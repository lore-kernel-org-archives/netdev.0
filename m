From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v2] isdn: Use ktime_t instead of 'struct timeval'
Date: Wed, 20 May 2015 15:56:28 +0200
Message-ID: <6378639.MgDWU7ZGDD@wuerfel>
References: <20150519073306.GA28427@tinar>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Karsten Keil <isdn@linux-pingi.de>, netdev@vger.kernel.org
To: Tina Ruchandani <ruchandani.tina@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.187]:58617 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752560AbbETN4b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2015 09:56:31 -0400
In-Reply-To: <20150519073306.GA28427@tinar>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 19 May 2015 13:03:06 Tina Ruchandani wrote:
> 'struct timeval' uses 32-bit representation for seconds which will
> overflow in year 2038 and beyond. mISDN/clock.c needs to compute and
> store elapsed time in intervals of 125 microseconds. This patch replaces
> the usage of 'struct timeval' with 64-bit ktime_t which is y2038 safe.
> The patch also replaces do_gettimeofday() (wall-clock time) with 
> ktime_get() (monotonic time) since we only care about elapsed time here.
> 
> Signed-off-by: Tina Ruchandani <ruchandani.tina@gmail.com>
> Suggested-by: Arnd Bergmnann <arnd@arndb.de>

Looks mostly ok now, just one detail left:

> +		delta = ktime_us_delta(tv_now, iclock_tv) / 125;

This line is something I suggested, but I have now realized that it's
still wrong, because you introduce a 64-by-32-bit division here
that will fail to link on most 32-bit architectures.

Using a cast to 32-bit value would solve that, like

      delta = ((u32)ktime_us_delta(tv_now, iclock_tv)) / 125;

as that would replace the 64-bit division with a 32-bit division.
This is fine as long as the delta is never more than 71 minutes,
otherwise you have to use

	delta = ktime_divns(ktime_sub(tv_now, iclock_tv), (NS_PER_SEC / 8000));

which is also potentially more efficient.


	Arnd
