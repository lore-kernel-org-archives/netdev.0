From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC PATCH v2 4/9] bql: Byte queue limits
Date: Tue, 16 Aug 2011 18:31:42 +0100
Message-ID: <1313515902.2725.33.camel@bwh-desktop>
References: <alpine.DEB.2.00.1108072144010.13721@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:40352 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751295Ab1HPRbq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Aug 2011 13:31:46 -0400
In-Reply-To: <alpine.DEB.2.00.1108072144010.13721@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2011-08-07 at 21:48 -0700, Tom Herbert wrote:
> Networking stack support for byte queue limits, uses dynamic queue
> limits library.  Byte queue limits are maintained per transmit queue,
> and a bql structure has been added to netdev_queue structure for this
> purpose.
> 
> Configuration of bql is in the tx-<n> sysfs directory for the queue
> under the byte_queue_limits directory.  Configuration includes:
> limit_min, bql minimum limit
> limit_max, bql maximum limit
> hold_time, bql slack hold time
> 
> Also under the directory are:
> limit, current byte limit
> inflight, current number of bytes on the queue
> 
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---
>  include/linux/netdevice.h |   16 +++
>  net/core/dev.c            |    1 +
>  net/core/net-sysfs.c      |  230 ++++++++++++++++++++++++++++++++++-----------
>  3 files changed, 192 insertions(+), 55 deletions(-)
> 
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 74e8862..d49265b 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
[...]
> @@ -1913,29 +1915,43 @@ static inline int netif_xmit_frozen_or_stopped(const struct netdev_queue *dev_qu
>  static inline void netdev_tx_sent_queue(struct netdev_queue *dev_queue,
>  					unsigned int pkts, unsigned int bytes)
>  {
> +	dql_queued(&dev_queue->dql, bytes);
> +	if (dql_avail(&dev_queue->dql) < 0)
> +		set_bit(__QUEUE_STATE_STACK_XOFF, &dev_queue->state);
>  }
[...]
>  static inline void netdev_tx_completed_queue(struct netdev_queue *dev_queue,
>  					     unsigned pkts, unsigned bytes)
>  {
> +	if (bytes) {
> +		dql_completed(&dev_queue->dql, bytes);
> +		if (dql_avail(&dev_queue->dql) >= 0 &&
> +		    test_and_clear_bit(__QUEUE_STATE_STACK_XOFF,
> +		     &dev_queue->state))
> +			netif_schedule_queue(dev_queue);
> +	}
>  }

There is generally no interlocking between initiation and completion
paths, and the dql library doesn't provide either interlocking or atomic
operations, so I'm pretty sure there is a race condition here where a
queue will not be woken.	

Also, the cache line containing the struct dql can ping-pong between
CPUs doing initiation and completion.  (I know we're aiming for these to
be the same, but we can't yet assume they will be.)

[...]
> diff --git a/net/core/dev.c b/net/core/dev.c
> index a7f8c38..bd5cd15 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -5395,6 +5395,7 @@ static void netdev_init_one_queue(struct net_device *dev,
>  	queue->xmit_lock_owner = -1;
>  	netdev_queue_numa_node_write(queue, NUMA_NO_NODE);
>  	queue->dev = dev;
> +	dql_init(&queue->dql, 1000);

I think you mean HZ, not 1000.

[...]
> +static ssize_t bql_show_inflight(struct netdev_queue *queue,
> +				 struct netdev_queue_attribute *attr,
> +				 char *buf)
> +{
> +	struct dql *dql = &queue->dql;
> +	int p = 0;
> +
> +	p = sprintf(buf, "%lu\n", dql->num_queued - dql->num_completed);
> +
> +	return p;
> +}
[...]

A certain amount of redundancy in the use of 'p' here...

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

