From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 3/9 v2] myri10ge: rework parity error check and cleanup
Date: Mon, 27 Jun 2011 19:17:15 -0700
Message-ID: <1309227435.3344.20.camel@Joe-Laptop>
References: <1309187108-12715-1-git-send-email-mason@myri.com>
	 <1309187108-12715-3-git-send-email-mason@myri.com>
	 <20110627205432.GA18978@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Andrew Gallatin <gallatin@myri.com>
To: Jon Mason <mason@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:3248 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755404Ab1F1CRS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Jun 2011 22:17:18 -0400
In-Reply-To: <20110627205432.GA18978@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-06-27 at 15:54 -0500, Jon Mason wrote:
> Clean up watchdog reset code:
>  - move code that checks for stuck slice to a common routine
>  - unless there is a confirmed h/w fault, verify that a stuck
>    slice is still stuck in the watchdog worker; if the slice is no
>    longer stuck, abort the reset.
>  - this removes an egregious 2000ms pause in the watchdog worker that
>    was a diagnostic aid (to look for spurious resets) the snuck into
>    production code.
> v2 includes corrections from Ben Hutchings and Joe Perches

Here's some more trivia:

> diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
[]
> @@ -3442,6 +3443,42 @@ static u32 myri10ge_read_reboot(struct myri10ge_priv *mgp)
>  	return reboot;
>  }
>  
> +static void
> +myri10ge_check_slice(struct myri10ge_slice_state *ss, int *reset_needed,
> +		     int *busy_slice_cnt, u32 rx_pause_cnt)
> +{
[]
> +		/* nic seems like it might be stuck.. */
> +		if (rx_pause_cnt != mgp->watchdog_pause) {
> +			if (net_ratelimit())
> +				netdev_warn(mgp->dev, "slice %d: TX paused, "
> +					    "check link partner\n", slice);

I think this would be better if the format weren't split.

				netdev_warn(mgp->dev, "slice %d: TX paused, check link partner\n",
					    slice);
or
				netdev_warn(mgp->dev,
					    "slice %d: TX paused, check link partner\n",
					    slice);
or if you really must split it because exceeding 80 columns
makes you itchy:
				netdev_warn(mgp->dev, "slice %d: "
					    "TX paused, check link partner\n",
					    slice);

> @@ -3465,8 +3504,7 @@ static void myri10ge_watchdog(struct work_struct *work)
>  		 * For now, just report it */
>  		reboot = myri10ge_read_reboot(mgp);
>  		netdev_err(mgp->dev, "NIC rebooted (0x%x),%s resetting\n",
> -			   reboot,
> -			   myri10ge_reset_recover ? "" : " not");
> +			   reboot, myri10ge_reset_recover ? " " : " not");

I think this was correct before you changed it.

Maybe:
			   reboot, myri10ge_reset_recover ? "" : " not");


