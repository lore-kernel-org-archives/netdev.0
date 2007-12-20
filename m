From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] sky2: Use deferrable timer for watchdog
Date: Thu, 20 Dec 2007 09:16:03 -0800
Message-ID: <20071220091603.0d69b045@deepthought>
References: <Pine.LNX.4.64.0712182008160.3616@mini.warudkars.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org
To: parag.warudkar@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:34405 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759966AbXLTRQc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2007 12:16:32 -0500
In-Reply-To: <Pine.LNX.4.64.0712182008160.3616@mini.warudkars.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 18 Dec 2007 20:13:28 -0500 (EST)
Parag Warudkar <parag.warudkar@gmail.com> wrote:

> 
> sky2 can use deferrable timer for watchdog - reduces wakeups from idle per 
> second.
> 
> Signed-off-by: Parag Warudkar <parag.warudkar@gmail.com>
> 
> --- linux-2.6/drivers/net/sky2.c	2007-12-07 10:04:39.000000000 -0500
> +++ linux-2.6-work/drivers/net/sky2.c	2007-12-18 20:07:58.000000000 -0500
> @@ -4230,7 +4230,10 @@
>   			sky2_show_addr(dev1);
>   	}
> 
> -	setup_timer(&hw->watchdog_timer, sky2_watchdog, (unsigned long) hw);
> +	hw->watchdog_timer.function = sky2_watchdog;
> +	hw->watchdog_timer.data = (unsigned long) hw;
> +	init_timer_deferrable(&hw->watchdog_timer);
> +
>   	INIT_WORK(&hw->restart_work, sky2_restart);
> 
>   	pci_set_drvdata(pdev, hw);

Does it really reduce the wakeup's or only change who gets charged by powertop?
The system is going to wakeup once a second anyway. Looks to me that if the
timer is using round_jiffies(), that setting deferrable just changes the accounting.

My interpretation of the api is:
   * round_jiffies()  - timer wants to wakeup but isn't precise about when so schedule
                        on next second when system will wake up anyway;
                        e.g why meetings are usually scheduled on the hour

   * deferrable       - timer doesn't have to really wakeup but wants to happen near
                        a particular time. e.g. "I'll meet you at the pub around 8pm"

Therefore doing deferrable is unnecessary for timers using round_jiffies unless system
is so good at doing timers that it is going to skip doing timer once per second.

-- 
Stephen Hemminger <stephen.hemminger@vyatta.com>
