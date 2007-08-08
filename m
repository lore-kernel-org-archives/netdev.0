From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: [ofa-general] Re: [PATCH 3/9 Rev3] [sched] Modify qdisc_run to
	support batching
Date: Wed, 8 Aug 2007 16:14:02 +0400
Message-ID: <20070808121401.GB8478@2ka.mipt.ru>
References: <20070808093114.15396.22797.sendpatchset@localhost.localdomain>
	<20070808093145.15396.91711.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jagana@us.ibm.com, Robert.Olsson@data.slu.se, herbert@gondor.apana.org.au,
	gaagaan@gmail.com, kumarkr@linux.ibm.com, rdreier@cisco.com,
	peter.p.waskiewicz.jr@intel.com, mcarlson@broadcom.com,
	kaber@trash.net, jeff@garzik.org, hadi@cyberus.ca,
	general@lists.openfabrics.org, mchan@broadcom.com, tgraf@suug.ch,
	netdev@vger.kernel.org, shemminger@linux-foundation.org,
	davem@davemloft.net, sri@us.ibm.com
To: Krishna Kumar <krkumar2@in.ibm.com>
Return-path: <general-bounces@lists.openfabrics.org>
Content-Disposition: inline
In-Reply-To: <20070808093145.15396.91711.sendpatchset@localhost.localdomain>
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

On Wed, Aug 08, 2007 at 03:01:45PM +0530, Krishna Kumar (krkumar2@in.ibm.com) wrote:
> +static inline int get_skb(struct net_device *dev, struct Qdisc *q,
> +			  struct sk_buff_head *blist, struct sk_buff **skbp)
> +{
> +	if (likely(!blist || (!skb_queue_len(blist) && qdisc_qlen(q) <= 1))) {
> +		return likely((*skbp = dev_dequeue_skb(dev, q)) != NULL);
> +	} else {
> +		int max = dev->tx_queue_len - skb_queue_len(blist);
> +		struct sk_buff *skb;
> +
> +		while (max > 0 && (skb = dev_dequeue_skb(dev, q)) != NULL)
> +			max -= dev_add_skb_to_blist(skb, dev);
> +
> +		*skbp = NULL;
> +		return 1;	/* we have atleast one skb in blist */
> +	}
> +}

Same here - is it possible to get a list in one go instead of pulling
one-by-one, since it forces quite a few additional unneded lock
get/releases. What about dev_dequeue_number_skb(dev, q, num), which will 
grab the lock and move a list of skbs from one queue to provided head.

> @@ -158,7 +198,10 @@ static inline int qdisc_restart(struct n
>  	/* And release queue */
>  	spin_unlock(&dev->queue_lock);
>  
> -	ret = dev_hard_start_xmit(skb, dev);
> +	if (likely(skb))
> +		ret = dev_hard_start_xmit(skb, dev);
> +	else
> +		ret = dev->hard_start_xmit_batch(dev);

Perfectionism says that having array of two functions and calling one of
them via array_func_pointer[!!skb] will be much faster. Just a though.
It is actually much faster than if/else on x86 at least.

-- 
	Evgeniy Polyakov
