From: jchapman@katalix.com
Subject: Re: Re: [PATCH] e1000 poll behavior
Date: Wed, 15 Dec 2004 04:01:57 -0600
Message-ID: <1103104917.41c00b9533464@www.katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: gandalf@wlug.westbo.se, robert.olsson@data.slu.se
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Is there any advantage in exiting NAPI polled state as soon as
possible with the work_done < work_to_do test? Why not stay in
polled mode until no rx or tx work is done, i.e. only exit polled
state if work_done is zero? When the system is congested, it is common
for work_done < work_to_do to be true, which keeps interrupts enabled
and just makes the situation worse.

When working on e100 a while ago, I found better and more consistent
pps numbers by staying in polled mode until the interface went idle.
See current e100 code. Unfortunately I don't have e1000 hardware to
test if the same is true for e1000.

/james

Robert Olsson writes:

> Martin Josefsson writes:
>
>  > What about the case where tx_cleaned is true but (work_done < >
>  > work_to_do) is true. Then the statement is false and we continue,
>  > later we return (work_done >= work_to_do) which equals 0 (not
>  > seen in patch).  We are not allowed to return 0 when still on
>  > poll_list. That will sort of continue polling in a degraded way
>  > (no increase in quota) but will screw up device refcounting
>  > badly.
>  >
>  > That final return must be changed into "return 1;"
>
>  Ohoh thanks yes...
>
> --- drivers/net/e1000/e1000_main.c.orig	2004-12-09 17:49:56.000000000 +0100
> +++ drivers/net/e1000/e1000_main.c	2004-12-10 20:13:57.000000000 +0100
> @@ -2179,15 +2179,15 @@
>  	*budget -= work_done;
>  	netdev->quota -= work_done;
>
> -	/* if no Rx and Tx cleanup work was done, exit the polling mode */
> -	if(!tx_cleaned || (work_done < work_to_do) ||
> +	/* if no Tx and not enough Rx work done, exit the polling mode */
> +	if((!tx_cleaned && (work_done < work_to_do)) ||
>  				!netif_running(netdev)) {
>  		netif_rx_complete(netdev);
>  		e1000_irq_enable(adapter);
>  		return 0;
>  	}
>
> -	return (work_done >= work_to_do);
> +	return 1;
>  }
>
>  #endif
