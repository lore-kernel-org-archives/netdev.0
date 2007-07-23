From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: [ofa-general] Re: [PATCH 03/12 -Rev2] dev.c changes.
Date: Mon, 23 Jul 2007 14:44:28 +0400
Message-ID: <20070723104428.GC22877@2ka.mipt.ru>
References: <20070722090457.7787.4601.sendpatchset@K50wks273871wss.in.ibm.com>
	<20070722090525.7787.10432.sendpatchset@K50wks273871wss.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: jagana@us.ibm.com, Robert.Olsson@data.slu.se,
	peter.p.waskiewicz.jr@intel.com, herbert@gondor.apana.org.au,
	gaagaan@gmail.com, kumarkr@linux.ibm.com, rdreier@cisco.com,
	mcarlson@broadcom.com, kaber@trash.net, jeff@garzik.org,
	general@lists.openfabrics.org, netdev@vger.kernel.org,
	tgraf@suug.ch, hadi@cyberus.ca, davem@davemloft.net,
	mchan@broadcom.com, sri@us.ibm.com
To: Krishna Kumar <krkumar2@in.ibm.com>
Return-path: <general-bounces@lists.openfabrics.org>
Content-Disposition: inline
In-Reply-To: <20070722090525.7787.10432.sendpatchset@K50wks273871wss.in.ibm.com>
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

Hi Krishna.

On Sun, Jul 22, 2007 at 02:35:25PM +0530, Krishna Kumar (krkumar2@in.ibm.com) wrote:
> diff -ruNp org/net/core/dev.c rev2/net/core/dev.c
> --- org/net/core/dev.c	2007-07-20 07:49:28.000000000 +0530
> +++ rev2/net/core/dev.c	2007-07-21 23:08:33.000000000 +0530
> @@ -875,6 +875,48 @@ void netdev_state_change(struct net_devi
>  	}
>  }
>  
> +/*
> + * dev_change_tx_batching - Enable or disable batching for a driver that
> + * supports batching.
> + */
> +int dev_change_tx_batching(struct net_device *dev, unsigned long new_batch_skb)
> +{
> +	int ret;
> +
> +	if (!dev->hard_start_xmit_batch) {
> +		/* Driver doesn't support skb batching */
> +		ret = -ENOTSUPP;
> +		goto out;
> +	}
> +
> +	/* Handle invalid argument */
> +	if (new_batch_skb < 0) {
> +		ret = -EINVAL;
> +		goto out;
> +	}
> +
> +	ret = 0;
> +
> +	/* Check if new value is same as the current */
> +	if (!!(dev->features & NETIF_F_BATCH_ON) == !!new_batch_skb)
> +		goto out;

o_O

Scratched head for too long before understood what it means :)

> +	spin_lock(&dev->queue_lock);
> +	if (new_batch_skb) {
> +		dev->features |= NETIF_F_BATCH_ON;
> +		dev->tx_queue_len >>= 1;
> +	} else {
> +		if (!skb_queue_empty(&dev->skb_blist))
> +			skb_queue_purge(&dev->skb_blist);
> +		dev->features &= ~NETIF_F_BATCH_ON;
> +		dev->tx_queue_len <<= 1;
> +	}
> +	spin_unlock(&dev->queue_lock);

Hmm, should this also stop interrupts?

-- 
	Evgeniy Polyakov
