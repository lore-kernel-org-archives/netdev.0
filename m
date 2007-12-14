From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 4/4] sky2: rtnl_lock out of loop will be faster
Date: Fri, 14 Dec 2007 16:17:32 -0500
Message-ID: <4762F2EC.2010201@pobox.com>
References: <475FA0C1.8000701@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	shemminger@linux-foundation.org, netdev@vger.kernel.org
To: Wang Chen <wangchen@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:55964 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751672AbXLNVRr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Dec 2007 16:17:47 -0500
In-Reply-To: <475FA0C1.8000701@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wang Chen wrote:
> [PATCH 4/4] [NETDEV] sky2: rtnl_lock out of loop will be faster
> 
> Before this patch, it gets and releases the lock at each
> iteration of the loop. Changing unregister_netdev to
> unregister_netdevice and locking outside of the loop will
> be faster for this approach.
> 
> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
> ---
>  sky2.c |    4 +++-
>  1 files changed, 3 insertions(+), 1 deletion(-)
> 
> --- linux-2.6.24.rc5.org/drivers/net/sky2.c	2007-12-12 10:19:43.000000000 +0800
> +++ linux-2.6.24.rc5/drivers/net/sky2.c	2007-12-12 15:23:37.000000000 +0800
> @@ -4270,8 +4270,10 @@ static void __devexit sky2_remove(struct
>  	del_timer_sync(&hw->watchdog_timer);
>  	cancel_work_sync(&hw->restart_work);
>  
> +	rtnl_lock();
>  	for (i = hw->ports-1; i >= 0; --i)
> -		unregister_netdev(hw->dev[i]);
> +		unregister_netdevice(hw->dev[i]);
> +	rtnl_unlock();

while true and correct, I don't see the remove path as needing this type 
of micro-optimization.

Removing and shutting down hardware is an operation that can take many 
seconds (an eternity, to a computer)... a very slow operation.

Thus, given that speed is not a priority here, I place more value on 
smaller, more compact, easily reviewable code -- the existing unpatched 
code in this case.

	Jeff





