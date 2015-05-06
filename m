From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH 2/2] pktgen: introduce xmit_mode 'rx_inject'
Date: Wed, 6 May 2015 10:44:42 +0200
Message-ID: <20150506104442.009312cf@redhat.com>
References: <20150505202730.8715.48527.stgit@ivy>
	<20150505202959.8715.51882.stgit@ivy>
	<5549A772.9060009@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
	Alexei Starovoitov <ast@plumgrid.com>, brouer@redhat.com
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56622 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753106AbbEFIor (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 May 2015 04:44:47 -0400
In-Reply-To: <5549A772.9060009@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 05 May 2015 22:32:34 -0700
Alexander Duyck <alexander.duyck@gmail.com> wrote:

> On 05/05/2015 01:30 PM, Jesper Dangaard Brouer wrote:
> 
> <snip>
> 
> > diff --git a/net/core/pktgen.c b/net/core/pktgen.c
> > index 43bb215..85195b2 100644
> > --- a/net/core/pktgen.c
> > +++ b/net/core/pktgen.c
> > @@ -210,6 +210,10 @@
> 
> <snip>
> 
> > @@ -3320,6 +3358,7 @@ static void pktgen_xmit(struct pktgen_dev *pkt_dev)
> >   	unsigned int burst = ACCESS_ONCE(pkt_dev->burst);
> >   	struct net_device *odev = pkt_dev->odev;
> >   	struct netdev_queue *txq;
> > +	struct sk_buff *skb;
> >   	int ret;
> >
> >   	/* If device is offline, then don't send */
> > @@ -3352,11 +3391,45 @@ static void pktgen_xmit(struct pktgen_dev *pkt_dev)
> >   		pkt_dev->last_pkt_size = pkt_dev->skb->len;
> >   		pkt_dev->allocated_skbs++;
> >   		pkt_dev->clone_count = 0;	/* reset counter */
> > +		if (pkt_dev->xmit_mode == M_RX_INJECT)
> > +			pkt_dev->skb->protocol = eth_type_trans(pkt_dev->skb,
> > +								pkt_dev->skb->dev);
> >   	}
> >
> 
> I was just wondering.  Since M_RX_INJECT is not compatible with 
> clone_skb couldn't the lines added above be moved down into the block 
> below so that you could avoid the additional conditional jump?

Sure, that is possible.  I'll let Alexei answer, as it is his code.
(And repost if he also thinks so...)


> >   	if (pkt_dev->delay && pkt_dev->last_ok)
> >   		spin(pkt_dev, pkt_dev->next_tx);
> >
> > +	if (pkt_dev->xmit_mode == M_RX_INJECT) {
> > +		skb = pkt_dev->skb;
> > +		atomic_add(burst, &skb->users);
> > +		local_bh_disable();
> > +		do {
> > +			ret = netif_receive_skb(skb);
> > +			if (ret == NET_RX_DROP)
> > +				pkt_dev->errors++;
> > +			pkt_dev->sofar++;
> > +			pkt_dev->seq_num++;
> > +			if (atomic_read(&skb->users) != burst) {
> > +				/* skb was queued by rps/rfs or taps,
> > +				 * so cannot reuse this skb
> > +				 */
> > +				atomic_sub(burst - 1, &skb->users);
> > +				/* get out of the loop and wait
> > +				 * until skb is consumed
> > +				 */
> > +				pkt_dev->last_ok = 1;
> > +				break;
> > +			}
> > +			/* skb was 'freed' by stack, so clean few
> > +			 * bits and reuse it
> > +			 */
> > +#ifdef CONFIG_NET_CLS_ACT
> > +			skb->tc_verd = 0; /* reset reclass/redir ttl */
> > +#endif
> > +		} while (--burst > 0);
> > +		goto out; /* Skips xmit_mode M_TX */
> > +	}
> > +
> >   	txq = skb_get_tx_queue(odev, pkt_dev->skb);
> >
> >   	local_bh_disable();
> > @@ -3404,6 +3477,7 @@ xmit_more:
> >   unlock:
> >   	HARD_TX_UNLOCK(odev, txq);
> >
> > +out:
> >   	local_bh_enable();
> >
> >   	/* If pkt_dev->count is zero, then run forever */
> >
> > --
> > To unsubscribe from this list: send the line "unsubscribe netdev" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >
> 



-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
