From: Patrick McHardy <kaber@trash.net>
Subject: [ofa-general] Re: [PATCH 03/10] dev.c changes.
Date: Fri, 20 Jul 2007 12:04:30 +0200
Message-ID: <46A088AE.1090702@trash.net>
References: <20070720063149.26341.84076.sendpatchset@localhost.localdomain>
	<20070720063227.26341.91868.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, Robert.Olsson@data.slu.se,
	peter.p.waskiewicz.jr@intel.com, herbert@gondor.apana.org.au,
	gaagaan@gmail.com, kumarkr@linux.ibm.com, rdreier@cisco.com,
	mcarlson@broadcom.com, jagana@us.ibm.com,
	general@lists.openfabrics.org, netdev@vger.kernel.org,
	tgraf@suug.ch, jeff@garzik.org, hadi@cyberus.ca,
	davem@davemloft.net, mchan@broadcom.com, sri@us.ibm.com
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

Krishna Kumar wrote:
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


The queue length can be changed through multiple interfaces, if that
really is important you need to catch these cases too.

> +		} else {
> +			dev->skb_blist = kmalloc(sizeof *dev->skb_blist,
> +						 GFP_KERNEL);


Why not simply put the head in struct net_device? It seems to me that
this could also be used for gso_skb.

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

Queue purging should be done in dev_deactivate.
