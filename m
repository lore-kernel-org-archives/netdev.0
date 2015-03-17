From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [RFC PATCH] xen-netback: making the bandwidth limiter runtime
 settable
Date: Tue, 17 Mar 2015 11:17:49 +0000
Message-ID: <20150317111749.GC27314@zion.uk.xensource.com>
References: <1426251065-24279-1-git-send-email-imrep.amz@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Ian Campbell <ian.campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>,
	<xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, "Palik, Imre" <imrep@amazon.de>,
	"Anthony Liguori" <aliguori@amazon.com>
To: Imre Palik <imrep.amz@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1426251065-24279-1-git-send-email-imrep.amz@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 13, 2015 at 01:51:05PM +0100, Imre Palik wrote:
> From: "Palik, Imre" <imrep@amazon.de>
> 
> With the current netback, the bandwidth limiter's parameters are only
> settable during vif setup time.  This patch register a watch on them, and
> thus makes them runtime changeable.
> 
> When the watch fires, the timer is reset.  The timer's mutex is used for
> fencing the change.
> 

I think this is a valid idea.  Just that this commit message is not
complete. It doesn't describe everything this patch does.

> Cc: Anthony Liguori <aliguori@amazon.com>
> Signed-off-by: Imre Palik <imrep@amazon.de>
> ---
[...]
>  	queue->rx_queue_max = XENVIF_RX_QUEUE_BYTES;
> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
> index cab9f52..bcc1880 100644
> --- a/drivers/net/xen-netback/netback.c
> +++ b/drivers/net/xen-netback/netback.c
> @@ -641,7 +641,7 @@ static void tx_add_credit(struct xenvif_queue *queue)
>  	queue->remaining_credit = min(max_credit, max_burst);
>  }
>  
> -static void tx_credit_callback(unsigned long data)
> +void xenvif_tx_credit_callback(unsigned long data)

Please keep this function static.

And say in the commit message you change tx_credit_callback to a better
name.

>  {
>  	struct xenvif_queue *queue = (struct xenvif_queue *)data;
>  	tx_add_credit(queue);
> @@ -1170,7 +1170,7 @@ static bool tx_credit_exceeded(struct xenvif_queue *queue, unsigned size)
>  		queue->credit_timeout.data     =
>  			(unsigned long)queue;
>  		queue->credit_timeout.function =
> -			tx_credit_callback;
> +			xenvif_tx_credit_callback;
>  		mod_timer(&queue->credit_timeout,
>  			  next_credit);
[...]
> @@ -594,13 +597,9 @@ static void xen_net_read_rate(struct xenbus_device *dev,
>  	unsigned long b, u;
>  	char *ratestr;
>  
> -	/* Default to unlimited bandwidth. */
> -	*bytes = ~0UL;
> -	*usec = 0;
> -
>  	ratestr = xenbus_read(XBT_NIL, dev->nodename, "rate", NULL);
>  	if (IS_ERR(ratestr))
> -		return;
> +		goto reset;
>  
>  	s = ratestr;
>  	b = simple_strtoul(s, &e, 10);
> @@ -612,15 +611,21 @@ static void xen_net_read_rate(struct xenbus_device *dev,
>  	if ((s == e) || (*e != '\0'))
>  		goto fail;
>  
> +	kfree(ratestr);
> +
>  	*bytes = b;
>  	*usec = u;
>  
> -	kfree(ratestr);
>  	return;
>  
> - fail:
> +fail:
>  	pr_warn("Failed to parse network rate limit. Traffic unlimited.\n");
>  	kfree(ratestr);
> +
> +reset:
> +	/* Default to unlimited bandwidth. */
> +	*bytes = ~0UL;
> +	*usec = 0;
>  }
>  

Any reason you modify this function? It is still doing the exact same
thing, right?

>  static int xen_net_read_mac(struct xenbus_device *dev, u8 mac[])
> @@ -645,6 +650,59 @@ static int xen_net_read_mac(struct xenbus_device *dev, u8 mac[])
>  	return 0;
>  }
>  
> +static void xen_net_rate_changed(struct xenbus_watch *watch,
> +				const char **vec, unsigned int len)
> +{
> +	struct xenvif *vif = container_of(watch, struct xenvif, credit_watch);
> +	struct xenbus_device *dev = xenvif_to_xenbus_device(vif);
> +	unsigned long   credit_bytes;
> +	unsigned long   credit_usec;
> +	unsigned int queue_index;
> +
> +	xen_net_read_rate(dev, &credit_bytes, &credit_usec);
> +	for (queue_index = 0; queue_index < vif->num_queues; queue_index++) {
> +		struct xenvif_queue *queue = &vif->queues[queue_index];
> +
> +		queue->credit_bytes = credit_bytes;
> +		queue->credit_usec = credit_usec;
> +		if (!mod_timer_pending(&queue->credit_timeout, jiffies) &&
> +			queue->remaining_credit > queue->credit_bytes) {
> +			queue->remaining_credit = queue->credit_bytes;
> +		}
> +	}
> +}
> +
> +static int xen_register_watchers(struct xenbus_device *dev, struct xenvif *vif)
> +{
> +	int err = 0;
> +	char *node;
> +	unsigned maxlen = strlen(dev->nodename) + sizeof("/rate");
> +
> +	node = kmalloc(maxlen, GFP_KERNEL);
> +	if (!node)
> +		return -ENOMEM;
> +	sprintf(node, "%s/rate", dev->nodename);

Please use snprintf. (Though I can see using sprintf is fine here but I
want the code to be a bit future proof.)

> +	vif->credit_watch.node = node;
> +	vif->credit_watch.callback = xen_net_rate_changed;
> +	err = register_xenbus_watch(&vif->credit_watch);
> +	if (err) {
> +		pr_err("Failed to set watcher %s\n", vif->credit_watch.node);
> +		kfree(node);
> +		vif->credit_watch.node = 0;
> +		vif->credit_watch.callback = 0;

Please use NULL here.

Wei.
