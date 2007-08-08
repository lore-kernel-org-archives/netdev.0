From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: [ofa-general] Re: [PATCH 2/9 Rev3] [core] Add skb_blist &
	hard_start_xmit_batch
Date: Wed, 8 Aug 2007 16:01:43 +0400
Message-ID: <20070808120142.GA26884@2ka.mipt.ru>
References: <20070808093114.15396.22797.sendpatchset@localhost.localdomain>
	<20070808093135.15396.29687.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jagana@us.ibm.com, Robert.Olsson@data.slu.se,
	peter.p.waskiewicz.jr@intel.com, herbert@gondor.apana.org.au,
	gaagaan@gmail.com, kumarkr@linux.ibm.com, rdreier@cisco.com,
	mcarlson@broadcom.com, kaber@trash.net, jeff@garzik.org,
	hadi@cyberus.ca, general@lists.openfabrics.org,
	mchan@broadcom.com, tgraf@suug.ch, netdev@vger.kernel.org,
	shemminger@linux-foundation.org, davem@davemloft.net, sri@us.ibm.com
To: Krishna Kumar <krkumar2@in.ibm.com>
Return-path: <general-bounces@lists.openfabrics.org>
Content-Disposition: inline
In-Reply-To: <20070808093135.15396.29687.sendpatchset@localhost.localdomain>
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

On Wed, Aug 08, 2007 at 03:01:35PM +0530, Krishna Kumar (krkumar2@in.ibm.com) wrote:
> +int dev_change_tx_batch_skb(struct net_device *dev, unsigned long new_batch_skb)
> +{
> +	int ret = 0;
> +	struct sk_buff_head *blist;
> +
> +	if (!dev->hard_start_xmit_batch) {
> +		/* Driver doesn't support batching skb API */
> +		ret = -ENOTSUPP;
> +		goto out;
> +	}
> +
> +	/* Handle invalid argument */
> +	if (new_batch_skb < 0) {
> +		ret = -EINVAL;
> +		goto out;
> +	}

It is unsigned, how can it be less than zero?

And actually you use it just like a binary flag (casted to/from u32 in
the code, btw), so why not using ethtool_value directly here?

> +	/* Check if new value is same as the current */
> +	if (!!dev->skb_blist == !!new_batch_skb)
> +		goto out;
> +
> +	if (new_batch_skb &&
> +	    (blist = kmalloc(sizeof *blist, GFP_KERNEL)) == NULL) {
> +		ret = -ENOMEM;
> +		goto out;
> +	}
> +
> +	spin_lock(&dev->queue_lock);
> +	if (new_batch_skb) {
> +		skb_queue_head_init(blist);
> +		dev->skb_blist = blist;
> +	} else
> +		free_batching(dev);
> +	spin_unlock(&dev->queue_lock);

This needs bh lock too, since blist is accessed by qdisc_restart.

> +int dev_add_skb_to_blist(struct sk_buff *skb, struct net_device *dev)
> +{
> +	if (!list_empty(&ptype_all))
> +		dev_queue_xmit_nit(skb, dev);
> +
> +	if (netif_needs_gso(dev, skb)) {
> +		if (unlikely(dev_gso_segment(skb))) {
> +			kfree(skb);
> +			return 0;
> +		}
> +
> +		if (skb->next) {
> +			int count = 0;
> +
> +			do {
> +				struct sk_buff *nskb = skb->next;
> +
> +				skb->next = nskb->next;
> +				__skb_queue_tail(dev->skb_blist, nskb);
> +				count++;
> +			} while (skb->next);

Is it possible to move list without iterating over each entry?


-- 
	Evgeniy Polyakov
