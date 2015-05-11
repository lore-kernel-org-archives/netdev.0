From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] isdn: Use ktime_t instead of 'struct timeval'
Date: Mon, 11 May 2015 17:31:39 +0200
Message-ID: <3634168.ue6qDafuIU@wuerfel>
References: <20150511023257.GA2612@tinar>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Karsten Keil <isdn@linux-pingi.de>, netdev@vger.kernel.org,
	y2038@lists.linaro.org
To: Tina Ruchandani <ruchandani.tina@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.131]:64231 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753819AbbEKPbo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 May 2015 11:31:44 -0400
In-Reply-To: <20150511023257.GA2612@tinar>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 11 May 2015 08:02:57 Tina Ruchandani wrote:

> -			do_gettimeofday(&tv_now);
> -		elapsed_sec = tv_now.tv_sec - iclock_tv.tv_sec;
> -		elapsed_8000th = (tv_now.tv_usec / 125)
> -			- (iclock_tv.tv_usec / 125);
> -		if (elapsed_8000th < 0) {
> -			elapsed_sec -= 1;
> -			elapsed_8000th += 8000;
> -		}
> +			tv_now = ktime_get();

A minor coding style comment here: If you have a multi-line
block after if() using curly braces, then you should also use
that for the else path, even if that is just one line.

However, if both sides do not need curly braces, leave them
out entirely.

> +		delta = ktime_to_us(ktime_sub(tv_now, iclock_tv));

We have a ktime_us_delta() function now that would simplify this
slightly.

> +		delta = delta / 125;

This looks like a possible bug: delta is a 16-bit number, so it will
be truncated to 65536 microseconds when assigning the result of
ktime_us_delta() or ktime_to_us(), and then you divide by 125, so
it will now be a number that is smaller than 524, and if the elapsed
time is more than 65536 microseconds, you can an incorrect result.

You can avoid that by using a 32-bit temporary, or doing it
implicitly as

	delta = ktime_us_delta(tv_now, iclock_tv) / 125;

Another option would be to calculate the right number from the
nanoseconds:

	delta = ktime_divns(ktime_sub(tv_now, iclock_tv), (NS_PER_SEC / 8000));

	Arnd
