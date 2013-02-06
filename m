From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v6] netpoll: protect napi_poll and poll_controller
 during dev_[open|close]
Date: Wed, 06 Feb 2013 15:45:29 -0500 (EST)
Message-ID: <20130206.154529.1102937973870429106.davem@davemloft.net>
References: <1359578665-29248-1-git-send-email-nhorman@tuxdriver.com>
	<1360087543-16049-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ivecera@redhat.com,
	bhutchings@solarflare.com, romieu@fr.zoreil.com,
	eric.dumazet@gmail.com
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43490 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758141Ab3BFUpb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Feb 2013 15:45:31 -0500
In-Reply-To: <1360087543-16049-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Tue,  5 Feb 2013 13:05:43 -0500

> Ivan Vercera was recently backporting commit
> 9c13cb8bb477a83b9a3c9e5a5478a4e21294a760 to a RHEL kernel, and I noticed that,
> while this patch protects the tg3 driver from having its ndo_poll_controller
> routine called during device initalization, it does nothing for the driver
> during shutdown. I.e. it would be entirely possible to have the
> ndo_poll_controller method (or subsequently the ndo_poll) routine called for a
> driver in the netpoll path on CPU A while in parallel on CPU B, the ndo_close or
> ndo_open routine could be called.  Given that the two latter routines tend to
> initizlize and free many data structures that the former two rely on, the result
> can easily be data corruption or various other crashes.  Furthermore, it seems
> that this is potentially a problem with all net drivers that support netpoll,
> and so this should ideally be fixed in a common path.
> 
> As Ben H Pointed out to me, we can't preform dev_open/dev_close in atomic
> context, so I've come up with this solution.  We can use a mutex to sleep in
> open/close paths and just do a mutex_trylock in the napi poll path and abandon
> the poll attempt if we're locked, as we'll just retry the poll on the next send
> anyway.
> 
> I've tested this here by flooding netconsole with messages on a system whos nic
> driver I modfied to periodically return NETDEV_TX_BUSY, so that the netpoll tx
> workqueue would be forced to send frames and poll the device.  While this was
> going on I rapidly ifdown/up'ed the interface and watched for any problems.
> I've not found any.
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>

Applied to net-next, thanks Neil.
