From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH 2/2] random32: use msecs_to_jiffies for reseed timer
Date: Tue, 12 Nov 2013 15:35:12 -0800
Message-ID: <20131112153512.68520cca@samsung-9>
References: <1384296342-3348-1-git-send-email-dborkman@redhat.com>
	<1384296342-3348-2-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:43641 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756319Ab3KLXfU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Nov 2013 18:35:20 -0500
Received: by mail-pd0-f172.google.com with SMTP id w10so7608380pde.31
        for <netdev@vger.kernel.org>; Tue, 12 Nov 2013 15:35:19 -0800 (PST)
In-Reply-To: <1384296342-3348-2-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 12 Nov 2013 23:45:42 +0100
Daniel Borkmann <dborkman@redhat.com> wrote:

> Use msecs_to_jiffies, for these calculations as different HZ
> considerations are taken into account for conversion of the timer
> shot, and also it makes the code more readable.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---
>  lib/random32.c | 8 ++++++--
>  1 file changed, 6 insertions(+), 2 deletions(-)
> 
> diff --git a/lib/random32.c b/lib/random32.c
> index 4f9d5df..1e5b2df 100644
> --- a/lib/random32.c
> +++ b/lib/random32.c
> @@ -214,18 +214,22 @@ static DEFINE_TIMER(seed_timer, __prandom_timer, 0, 0);
>  static void __prandom_timer(unsigned long dontcare)
>  {
>  	u32 entropy;
> +	unsigned long expires;
>  
>  	get_random_bytes(&entropy, sizeof(entropy));
>  	prandom_seed(entropy);
> +
>  	/* reseed every ~60 seconds, in [40 .. 80) interval with slack */
> -	seed_timer.expires = jiffies + (40 * HZ + (prandom_u32() % (40 * HZ)));
> +	expires = 40 + (prandom_u32() % 40);
> +	seed_timer.expires = jiffies + msecs_to_jiffies(expires * MSEC_PER_SEC);
> +
>  	add_timer(&seed_timer);
>  }
>  
>  static void __init __prandom_start_seed_timer(void)
>  {
>  	set_timer_slack(&seed_timer, HZ);
> -	seed_timer.expires = jiffies + 40 * HZ;
> +	seed_timer.expires = jiffies + msecs_to_jiffies(40 * MSEC_PER_SEC);
>  	add_timer(&seed_timer);
>  }
>  

Some questions:
 1. What is the point of using msecs_to_jiffies? the older code already handled
    differing HZ?
 2. Why the magic 40-80 sec range? What about platforms with very low entropy
    you will end up draining it faster.
 3. I prefer using mod_timer rather than setting expires and call add_timer
 4. You should also use round_jiffies to save power by making the wakeup on a second
    boundary.
