From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [ofa-general] Re: [PATCH 03/10] dev.c changes.
Date: Fri, 20 Jul 2007 10:44:19 -0700
Message-ID: <1184953459.12431.21.camel@localhost.localdomain>
References: <20070720063149.26341.84076.sendpatchset@localhost.localdomain>
	<20070720063227.26341.91868.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, Robert.Olsson@data.slu.se,
	peter.p.waskiewicz.jr@intel.com, herbert@gondor.apana.org.au,
	gaagaan@gmail.com, kumarkr@linux.ibm.com, rdreier@cisco.com,
	mcarlson@broadcom.com, kaber@trash.net, jagana@us.ibm.com,
	general@lists.openfabrics.org, netdev@vger.kernel.org,
	tgraf@suug.ch, jeff@garzik.org, hadi@cyberus.ca,
	davem@davemloft.net, mchan@broadcom.com
To: Krishna Kumar <krkumar2@in.ibm.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20070720063227.26341.91868.sendpatchset@localhost.localdomain>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-07-20 at 12:02 +0530, Krishna Kumar wrote:
> Changes in dev.c to support batching : add dev_add_skb_to_blist,
> register_netdev recognizes batch aware drivers, and net_tx_action is
> the sole user of batching.
> 
> Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
> ---
>  dev.c |   77 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++---
>  1 files changed, 74 insertions(+), 3 deletions(-)
> 
> diff -ruNp org/net/core/dev.c new/net/core/dev.c
> --- org/net/core/dev.c	2007-07-20 07:49:28.000000000 +0530
> +++ new/net/core/dev.c	2007-07-20 08:31:35.000000000 +0530

<snip>

> @@ -1566,7 +1605,7 @@ gso:
>  			/* reset queue_mapping to zero */
>  			skb->queue_mapping = 0;
>  			rc = q->enqueue(skb, q);
> -			qdisc_run(dev);
> +			qdisc_run(dev, NULL);

OK. So you are passing a NULL blist here. However, i am
not sure why batching is not used in this situation.

Thanks
Sridhar

>  			spin_unlock(&dev->queue_lock);
> 
>  			rc = rc == NET_XMIT_BYPASS ? NET_XMIT_SUCCESS : rc;
> @@ -1763,7 +1802,11 @@ static void net_tx_action(struct softirq
>  			clear_bit(__LINK_STATE_SCHED, &dev->state);
> 
>  			if (spin_trylock(&dev->queue_lock)) {
> -				qdisc_run(dev);
> +				/*
> +				 * Try to send out all skbs if batching is
> +				 * enabled.
> +				 */
> +				qdisc_run(dev, dev->skb_blist);
>  				spin_unlock(&dev->queue_lock);
>  			} else {
>  				netif_schedule(dev);
> @@ -3397,6 +3440,28 @@ int register_netdevice(struct net_device
>  		}
>  	}
> 
> +	if (dev->features & NETIF_F_BATCH_SKBS) {
> +		if (!dev->hard_start_xmit_batch ||
> +		    dev->tx_queue_len < MIN_QUEUE_LEN_BATCH) {
> +			/*
> +			 * Batch TX requires API support in driver plus have
> +			 * a minimum sized queue.
> +			 */
> +			printk(KERN_ERR "%s: Dropping NETIF_F_BATCH_SKBS "
> +					"since no API support or queue len "
> +					"is smaller than %d.\n",
> +					dev->name, MIN_QUEUE_LEN_BATCH);
> +			dev->features &= ~NETIF_F_BATCH_SKBS;
> +		} else {
> +			dev->skb_blist = kmalloc(sizeof *dev->skb_blist,
> +						 GFP_KERNEL);
> +			if (dev->skb_blist) {
> +				skb_queue_head_init(dev->skb_blist);
> +				dev->tx_queue_len >>= 1;
> +			}
> +		}
> +	}
> +
>  	/*
>  	 *	nil rebuild_header routine,
>  	 *	that should be never called and used as just bug trap.
> @@ -3732,10 +3797,16 @@ void unregister_netdevice(struct net_dev
> 
>  	synchronize_net();
> 
> +	/* Deallocate batching structure */
> +	if (dev->skb_blist) {
> +		skb_queue_purge(dev->skb_blist);
> +		kfree(dev->skb_blist);
> +		dev->skb_blist = NULL;
> +	}
> +
>  	/* Shutdown queueing discipline. */
>  	dev_shutdown(dev);
> 
> -
>  	/* Notify protocols, that we are about to destroy
>  	   this device. They should clean all the things.
>  	*/
