From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4] ipconfig: Inform user if carrier is not ready
Date: Wed, 19 Sep 2012 16:13:03 -0400 (EDT)
Message-ID: <20120919.161303.1543204155807997032.davem@davemloft.net>
References: <1347656179-17638-1-git-send-email-erwanaliasr1@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: erwanaliasr1@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57130 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751292Ab2ISUNF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2012 16:13:05 -0400
In-Reply-To: <1347656179-17638-1-git-send-email-erwanaliasr1@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Erwan Velu <erwanaliasr1@gmail.com>
Date: Fri, 14 Sep 2012 22:56:19 +0200

> While using the ip= option at the cmdline, the kernel can hold the boot
> process for 2 minutes (CONF_CARRIER_TIMEOUT) if the carrier is not
> present.
> 
> While waiting the carrier, user is not informed about this situation and
> so could think the kernel is frozen.
> 
> If we don't get the carrier after some seconds, let's display a message to
> inform the user about the remaining time before reaching the timeout.
> 
> Signed-off-by: Erwan Velu <erwanaliasr1@gmail.com>
> ---
>  net/ipv4/ipconfig.c |   13 +++++++++++++
>  1 file changed, 13 insertions(+)
> 
> diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
> index 67e8a6b..fb17bad 100644
> --- a/net/ipv4/ipconfig.c
> +++ b/net/ipv4/ipconfig.c
> @@ -90,6 +90,7 @@
>  /* Define the friendly delay before and after opening net devices */
>  #define CONF_POST_OPEN		10	/* After opening: 10 msecs */
>  #define CONF_CARRIER_TIMEOUT	120000	/* Wait for carrier timeout */
> +#define CONF_WARN_CARRIER_TIMEOUT 5000	/* Time before showing a warning message  */
>  
>  /* Define the timeout for waiting for a DHCP/BOOTP/RARP reply */
>  #define CONF_OPEN_RETRIES 	2	/* (Re)open devices twice */
> @@ -205,6 +206,7 @@ static int __init ic_open_devs(void)
>  	struct net_device *dev;
>  	unsigned short oflags;
>  	unsigned long start;
> +	unsigned int loops = 0;
>  
>  	last = &ic_first_dev;
>  	rtnl_lock();
> @@ -266,6 +268,17 @@ static int __init ic_open_devs(void)
>  			if (ic_is_init_dev(dev) && netif_carrier_ok(dev))
>  				goto have_carrier;
>  
> +		/* This loop is blocking the boot process until 
> +		 *  we get the carrier or reach the timeout.
> +		 *  We have to inform the user about the situation as 
> +		 *  it could look like a kernel freeze.
> +		 *  After CONF_WARN_CARRIER_TIMEOUT milliseconds,
> +		 *  we display the remaing time before reaching the timeout.
> +		 */

Please format this comment consistently.  On the first line you have one
leading space, and on all the subsequent lines you use two leading spaces.
This looks ugly, use one leading space on every. line

		/* This loop is blocking the boot process until 
		 * we get the carrier or reach the timeout.
		 * We have to inform the user about the situation as 
		 * it could look like a kernel freeze.
		 * After CONF_WARN_CARRIER_TIMEOUT milliseconds,
		 * we display the remaing time before reaching the timeout.
		 */

> +		if (++loops == CONF_WARN_CARRIER_TIMEOUT) {
> +			pr_info("IP-Config: Waiting up to %d seconds for carrier on interface\n", 
> +				(CONF_CARRIER_TIMEOUT - CONF_WARN_CARRIER_TIMEOUT)/ 1000);
> +		}

Missing space right before the "/" in the calculation and this line
non-trivially exceeds 80 columns.  Perhaps split it up like:

				((CONF_CARRIER_TIMEOUT -
				 CONF_WARN_CARRIER_TIMEOUT)
				 / 1000));
