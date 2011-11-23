From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3 05/10] bql: Byte queue limits
Date: Wed, 23 Nov 2011 17:00:19 +0100
Message-ID: <1322064019.17693.53.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <alpine.DEB.2.00.1111222140410.15246@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:39887 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751230Ab1KWQAX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2011 11:00:23 -0500
Received: by qyd20 with SMTP id 20so512089qyd.19
        for <netdev@vger.kernel.org>; Wed, 23 Nov 2011 08:00:22 -0800 (PST)
In-Reply-To: <alpine.DEB.2.00.1111222140410.15246@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 22 novembre 2011 =C3=A0 21:52 -0800, Tom Herbert a =C3=A9crit =
:
> Networking stack support for byte queue limits, uses dynamic queue
> limits library.  Byte queue limits are maintained per transmit queue,
> and a dql structure has been added to netdev_queue structure for this
> purpose.
>=20
> Configuration of bql is in the tx-<n> sysfs directory for the queue
> under the byte_queue_limits directory.  Configuration includes:
> limit_min, bql minimum limit
> limit_max, bql maximum limit
> hold_time, bql slack hold time
>=20
> Also under the directory are:
> limit, current byte limit
> inflight, current number of bytes on the queue
>=20
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---
>  include/linux/netdevice.h |   28 ++++++++
>  net/Kconfig               |   13 ++++
>  net/core/dev.c            |    3 +
>  net/core/net-sysfs.c      |  150 +++++++++++++++++++++++++++++++++++=
+++++++---
>  4 files changed, 186 insertions(+), 8 deletions(-)
>=20
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 8b3eb8a..e17ece6 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -43,6 +43,7 @@
>  #include <linux/rculist.h>
>  #include <linux/dmaengine.h>
>  #include <linux/workqueue.h>
> +#include <linux/dynamic_queue_limits.h>
> =20
>  #include <linux/ethtool.h>
>  #include <net/net_namespace.h>
> @@ -557,6 +558,9 @@ struct netdev_queue {
>  	 * please use this field instead of dev->trans_start
>  	 */
>  	unsigned long		trans_start;
> +#ifdef CONFIG_BQL
> +	struct dql		dql;
> +#endif
>  } ____cacheline_aligned_in_smp;
> =20
>  static inline int netdev_queue_numa_node_read(const struct netdev_qu=
eue *q)
> @@ -1927,6 +1931,15 @@ static inline int netif_xmit_frozen_or_stopped=
(const struct netdev_queue *dev_qu
>  static inline void netdev_tx_sent_queue(struct netdev_queue *dev_que=
ue,
>  					unsigned int pkts, unsigned int bytes)
>  {
> +#ifdef CONFIG_BQL
> +	dql_queued(&dev_queue->dql, bytes);
> +	if (unlikely(dql_avail(&dev_queue->dql) < 0)) {
> +		set_bit(__QUEUE_STATE_STACK_XOFF, &dev_queue->state);
> +		if (unlikely(dql_avail(&dev_queue->dql) >=3D 0))
> +			clear_bit(__QUEUE_STATE_STACK_XOFF,
> +			    &dev_queue->state);
> +	}
> +#endif
>  }
> =20
>  static inline void netdev_sent_queue(struct net_device *dev,
> @@ -1938,6 +1951,18 @@ static inline void netdev_sent_queue(struct ne=
t_device *dev,
>  static inline void netdev_tx_completed_queue(struct netdev_queue *de=
v_queue,
>  					     unsigned pkts, unsigned bytes)
>  {
> +#ifdef CONFIG_BQL
> +	if (likely(bytes)) {
> +		dql_completed(&dev_queue->dql, bytes);
> +		if (unlikely(test_bit(__QUEUE_STATE_STACK_XOFF,
> +		    &dev_queue->state) &&
> +		    dql_avail(&dev_queue->dql) >=3D 0)) {

Maybe we can use some trick to avoid many wakeups ?

I feel that an other cpu might discover queue state is now XON and can
start xmit, without the extra __netif_schedule_queue() cost for this cp=
u
(softirq...). In a stress situation, cpu handling NIC interrupts can be
hogged...

The idea would be to clear STACK_XOFF bit, and if bytes are still in
flight (anotehr completion should come later), not call
netif_schedule_queue()

> +			if (test_and_clear_bit(__QUEUE_STATE_STACK_XOFF,
> +			     &dev_queue->state))
> +				netif_schedule_queue(dev_queue);
> +		}
> +	}
> +#endif
>  }
> =20
>  static=20
