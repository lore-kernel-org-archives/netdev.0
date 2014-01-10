From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net V2 2/2] net: core: explicitly select a txq before
 doing l2 forwarding
Date: Fri, 10 Jan 2014 09:27:00 -0500
Message-ID: <20140110142700.GA10111@neilslaptop.think-freely.org>
References: <1389260252-48591-1-git-send-email-jasowang@redhat.com>
 <1389260252-48591-2-git-send-email-jasowang@redhat.com>
 <20140109123144.GC16701@hmsreliant.think-freely.org>
 <52CF9B25.7020909@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, mst@redhat.com,
	John Fastabend <john.r.fastabend@intel.com>,
	e1000-devel@lists.sourceforge.net
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <52CF9B25.7020909@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jan 10, 2014 at 03:03:01PM +0800, Jason Wang wrote:
> On 01/09/2014 08:31 PM, Neil Horman wrote:
> > On Thu, Jan 09, 2014 at 05:37:32PM +0800, Jason Wang wrote:
> >> Currently, the tx queue were selected implicitly in ndo_dfwd_start_xmit(). The
> >> will cause several issues:
> >>
> >> - NETIF_F_LLTX were removed for macvlan, so txq lock were done for macvlan
> >>   instead of lower device which misses the necessary txq synchronization for
> >>   lower device such as txq stopping or frozen required by dev watchdog or
> >>   control path.
> >> - dev_hard_start_xmit() was called with NULL txq which bypasses the net device
> >>   watchdog.
> >> - dev_hard_start_xmit() does not check txq everywhere which will lead a crash
> >>   when tso is disabled for lower device.
> >>
> >> Fix this by explicitly introducing a new param for .ndo_select_queue() for just
> >> selecting queues in the case of l2 forwarding offload. And also introducing
> >> dfwd_direct_xmit() to do the queue selecting, txq holding and transmitting for
> >> l2 forwarding.
> >>
> >> With this fixes, NETIF_F_LLTX could be preserved for macvlan and there's no need
> >> to check txq against NULL in dev_hard_start_xmit(). Also there's no need to keep
> >> a dedicated ndo_dfwd_start_xmit().
> >>
> >> In the future, it was also required for macvtap l2 forwarding support since it
> >> provides a necessary synchronization method.
> >>
> >> Cc: John Fastabend <john.r.fastabend@intel.com>
> >> Cc: Neil Horman <nhorman@tuxdriver.com>
> >> Cc: e1000-devel@lists.sourceforge.net
> >> Signed-off-by: Jason Wang <jasowang@redhat.com>
> >>
> >> ---
> >> Changes from V1:
> >> - Adding a new parameter to ndo_select_queue instead of a new method to select
> >>   queue for l2 forwarding.
> >> - Remove the unnecessary ndo_dfwd_start_xmit() since txq was selected
> >>   explicitly.
> >> - Keep NETIF_F_LLTX when netdev feature is changed.
> >> - Shape the commit log
> > A few minor nits inline.
> >> <snip>
> >>  }
> >> diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
> >> index 5360f73..7eb4c82 100644
> >> --- a/drivers/net/macvlan.c
> >> +++ b/drivers/net/macvlan.c
> >> @@ -299,7 +299,7 @@ netdev_tx_t macvlan_start_xmit(struct sk_buff *skb,
> >>  
> >>  	if (vlan->fwd_priv) {
> >>  		skb->dev = vlan->lowerdev;
> >> -		ret = dev_hard_start_xmit(skb, skb->dev, NULL, vlan->fwd_priv);
> >> +		ret = dfwd_direct_xmit(skb, skb->dev, vlan->fwd_priv);
> >>  	} else {
> >>  		ret = macvlan_queue_xmit(skb, dev);
> >>  	}
> >> @@ -366,7 +366,6 @@ static int macvlan_open(struct net_device *dev)
> >>  		if (IS_ERR_OR_NULL(vlan->fwd_priv)) {
> >>  			vlan->fwd_priv = NULL;
> >>  		} else {
> >> -			dev->features &= ~NETIF_F_LLTX;
> >>  			return 0;
> >>  		}
> > After removing the features flag operation here, you don't need the braces
> > around the else statement either.
> 
> Ok.
> >> <snip>
> >> +int dfwd_direct_xmit(struct sk_buff *skb, struct net_device *dev,
> >> +		     void *accel_priv)
> >> +{
> >> +	struct netdev_queue *txq;
> >> +	int ret = NETDEV_TX_BUSY;
> >> +	int index;
> >> +
> >> +	BUG_ON(!dev->netdev_ops->ndo_select_queue);
> >> +	index =	dev->netdev_ops->ndo_select_queue(dev, skb, accel_priv);
> >> +
> >> +	local_bh_disable();
> >> +
> >> +	skb_set_queue_mapping(skb, index);
> >> +	txq = netdev_get_tx_queue(dev, index);
> >> +
> >> +	HARD_TX_LOCK(dev, txq, smp_processor_id());
> >> +	if (!netif_xmit_frozen_or_stopped(txq))
> >> +		ret = dev_hard_start_xmit(skb, dev, txq);
> >> +	HARD_TX_UNLOCK(dev, txq);
> >> +
> >> +	local_bh_enable();
> >> +	return ret;
> >> +}
> >> +EXPORT_SYMBOL_GPL(dfwd_direct_xmit);
> >> +
> > Now that we're using the common path to select a queue, can we just use
> > dev_queue_xmit here instead of creating our own transmit function?  The txq we
> > select from the ixgbe card will just have a pfifo_fast queue on it (if not a
> > noop queue), so dev_queue_xmit should just fall into the dev_hard_start_xmit
> > path, and save us this extra coding.
> >
> > Neil
> 
> Ture, and this will make no difference with the case without l2
> forwarding. To not trouble other parts too much, I will keep the current
> dev_queue_xmit() API and rename the current dev_queue_xmit() to
> __dev_queue_xmit() can make it can accept a accel_priv parameter. So
> dev_queue_xmit() will call this will NULL accel_priv and introduce a
> dev_queue_xmit_accel() that can accept a accel_priv parameter.
> 

Sounds perfect, thanks!
Neil

> Thanks
> >
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > Please read the FAQ at  http://www.tux.org/lkml/
> 
> 
