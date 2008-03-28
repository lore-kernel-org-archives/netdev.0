From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.24 BUG: soft lockup - CPU#X
Date: Thu, 27 Mar 2008 18:38:44 -0700 (PDT)
Message-ID: <20080327.183844.74572930.davem@davemloft.net>
References: <47EC399E.90804@sun.com>
	<20080327.173418.18777696.davem@davemloft.net>
	<20080328012234.GA20465@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Matheos.Worku@Sun.COM, jesse.brandeburg@intel.com,
	jarkao2@gmail.com, netdev@vger.kernel.org, hadi@cyberus.ca
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33986
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753484AbYC1Bio (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2008 21:38:44 -0400
In-Reply-To: <20080328012234.GA20465@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 28 Mar 2008 09:22:34 +0800

> @@ -187,6 +187,10 @@ void __qdisc_run(struct net_device *dev)
>  	do {
>  		if (!qdisc_restart(dev))
>  			break;
> +		if (need_resched()) {
> +			netif_schedule(dev);
> +			break;
> +		}
>  	} while (!netif_queue_stopped(dev));
>  
>  	clear_bit(__LINK_STATE_QDISC_RUNNING, &dev->state);

This runs from softirqs, the local thread's scheduling
state is updated from timers which also run from softirqs,
so this need_resched() test won't work.

Probably you'll need something similar to the ->poll()
NAPI breakout logic, which uses 2 jiffies as the breakout
point.  (it uses 2, because we could be very close to
transitioning to the next jiffie and thus don't want
to breakout prematurely in that case)
