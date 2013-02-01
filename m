From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] netpoll: protect napi_poll and poll_controller
 during dev_[open|close]
Date: Fri, 01 Feb 2013 09:14:07 -0800
Message-ID: <1359738847.30177.48.camel@edumazet-glaptop>
References: <1359578665-29248-1-git-send-email-nhorman@tuxdriver.com>
	 <1359738159-22597-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ivan Vecera <ivecera@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <bhutchings@solarflare.com>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f49.google.com ([209.85.160.49]:47239 "EHLO
	mail-pb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756673Ab3BAROL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Feb 2013 12:14:11 -0500
Received: by mail-pb0-f49.google.com with SMTP id xa12so2220349pbc.22
        for <netdev@vger.kernel.org>; Fri, 01 Feb 2013 09:14:10 -0800 (PST)
In-Reply-To: <1359738159-22597-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-02-01 at 12:02 -0500, Neil Horman wrote:
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
> context, so I've come up with this solution.  I've modified the npinfo->rx_flags
> to make use of bitops, so that we can atomically set/clear individual bits.
> We use one of these bits to provide mutual exclusion between the netpoll polling
> path and the dev_open/close paths.  I can't say Im a huge fan of returning
> -EBUSY in open/close, but I like it better than busy waiting while the poll path
> completes.
> 
> I've tested this here by flooding netconsole with messages on a system whos nic
> driver I modfied to periodically return NETDEV_TX_BUSY, so that the netpoll tx
> workqueue would be forced to send frames and poll the device.  While this was
> going on I rapidly ifdown/up'ed the interface and watched for any problems.
> I've not found any.
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> CC: Ivan Vecera <ivecera@redhat.com>
> CC: "David S. Miller" <davem@davemloft.net>
> CC: Ben Hutchings <bhutchings@solarflare.com>
> ---
>  include/linux/netpoll.h | 14 +++++++++----
>  net/core/dev.c          | 53 +++++++++++++++++++++++++++++++++++++++++++++++++
>  net/core/netpoll.c      | 23 ++++++++++++++-------
>  3 files changed, 79 insertions(+), 11 deletions(-)
> 
> diff --git a/include/linux/netpoll.h b/include/linux/netpoll.h
> index f54c3bb..09ef2e5 100644
> --- a/include/linux/netpoll.h
> +++ b/include/linux/netpoll.h
> @@ -35,10 +35,14 @@ struct netpoll {
>  	struct rcu_head rcu;
>  };
>  
> +#define NETPOLL_RX_ENABLED  1
> +#define NETPOLL_RX_DROP     2
> +#define NETPOLL_RX_ACTIVE   3
> +
>  struct netpoll_info {
>  	atomic_t refcnt;
>  
> -	int rx_flags;
> +	unsigned long flags;
>  	spinlock_t rx_lock;
>  	struct list_head rx_np; /* netpolls that registered an rx_hook */

You could avoid holes on 64bit arches using following order :

	atomic_t refcnt;
	spinlock_t rx_lock;
	unsigned long flags;
