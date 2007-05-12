From: Patrick McHardy <kaber@trash.net>
Subject: Re: take 3 [RFC] make qdisc_restart more readable
Date: Sat, 12 May 2007 19:02:29 +0200
Message-ID: <4645F325.3060607@trash.net>
References: <D5C1322C3E673F459512FB59E0DDC32902D42586@orsmsx414.amr.corp.intel.com>	 <1178911773.4126.26.camel@localhost> <1178972280.4061.7.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	Thomas Graf <tgraf@suug.ch>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:58379 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755767AbXELREG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 May 2007 13:04:06 -0400
In-Reply-To: <1178972280.4061.7.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index f671cd2..718d6fd 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -83,6 +83,9 @@ struct wireless_dev;
>  #define NETDEV_TX_OK 0		/* driver took care of packet */
>  #define NETDEV_TX_BUSY 1	/* driver tx path was busy*/
>  #define NETDEV_TX_LOCKED -1	/* driver tx lock was already taken */
> +#define NETDEV_TX_DROP -2	/* request caller to drop packet */

This shouldn't be a NETDEV_TX code since its only handled correctly
internally for handle_dev_cpu_collision().

> +#define NETDEV_TX_QUEUE -3	/* request caller to requeue packet */

How will this be used? The driver can simply stop the queue if
it doesn't want to receive more packets.

> +static inline int handle_dev_cpu_collision(struct net_device *dev)
> +{
> +	if (dev->xmit_lock_owner == smp_processor_id()) {

unlikely would make sense here.

> +static inline int
> +handle_dev_requeue(struct sk_buff *skb, struct net_device *dev, struct Qdisc *q)
> +{
> +
> +	if (unlikely(q == &noop_qdisc))
> +		kfree_skb(skb);

Why is this special-casing needed? __qdisc_run already checks for
noop_qdisc and noop has a proper requeue function.

> +	else if (skb->next)
> +		dev->gso_skb = skb;

The gso_skb cases could probably also be marked unlikely.

> +	else
> +		q->ops->requeue(skb, q);
> +	/* XXX: Could netif_schedule fail? Or is that fact we are
> +	 * requeueing imply the hardware path is closed
> +	 * and even if we fail, some interupt will wake us
> +	*/
> +	netif_schedule(dev);
> +	return 0;
> +}
> +
> +static inline struct sk_buff *
> +try_get_tx_pkt(struct net_device *dev, struct Qdisc *q)
> +{
> +	struct sk_buff *skb = dev->gso_skb;
> +
> +	if (skb)
> +		dev->gso_skb = NULL;
> +	else
> +		skb = q->dequeue(q);
> +
> +	return skb;
> +}
> +
> +static inline int
> +handle_tx_locked(struct sk_buff *skb, struct net_device *dev, struct Qdisc *q)

handle_.* sounds a bit like "I couldn't think of a better name" :)
How about dev_tx_locked()?

> +{
> +	int ret =  (dev);
> +
> +	if (ret == NETDEV_TX_DROP) {
> +		kfree_skb(skb);
> +		return qdisc_qlen(q);
> +	}
> +
> +	return handle_dev_requeue(skb, dev, q);
> +}

> +	if (unlikely (ret != NETDEV_TX_BUSY)) {
> +		/* XXX: Do we need a ratelimit? or put a
> +		 * BUG_ON((int) ret != NETDEV_TX_BUSY) ?
> +		 **/
> +		printk("BUG %s code %d qlen %d\n",dev->name, ret, q->q.qlen);

BUG_ON sounds a bit extreme, net_ratelimit() makes sense.
