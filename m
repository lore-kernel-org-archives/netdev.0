From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 3/9 Rev3] [sched] Modify qdisc_run to support batching
Date: Wed, 08 Aug 2007 16:05:17 +0200
Message-ID: <46B9CD9D.4020506@trash.net>
References: <20070808093114.15396.22797.sendpatchset@localhost.localdomain> <20070808093145.15396.91711.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, davem@davemloft.net,
	shemminger@linux-foundation.org, sri@us.ibm.com, jagana@us.ibm.com,
	Robert.Olsson@data.slu.se, peter.p.waskiewicz.jr@intel.com,
	herbert@gondor.apana.org.au, gaagaan@gmail.com,
	kumarkr@linux.ibm.com, rdreier@cisco.com, rick.jones2@hp.com,
	mcarlson@broadcom.com, jeff@garzik.org,
	general@lists.openfabrics.org, mchan@broadcom.com, tgraf@suug.ch,
	hadi@cyberus.ca, netdev@vger.kernel.org, xma@us.ibm.com
To: Krishna Kumar <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59698 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752099AbXHHOGc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Aug 2007 10:06:32 -0400
In-Reply-To: <20070808093145.15396.91711.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Krishna Kumar wrote:
> + * Algorithm to get skb(s) is:
> + *	- Non batching drivers, or if the batch list is empty and there is
> + *	  1 skb in the queue - dequeue skb and put it in *skbp to tell the
> + *	  caller to use the single xmit API.
> + *	- Batching drivers where the batch list already contains atleast one
> + *	  skb, or if there are multiple skbs in the queue: keep dequeue'ing
> + *	  skb's upto a limit and set *skbp to NULL to tell the caller to use
> + *	  the multiple xmit API.
> + *
> + * Returns:
> + *	1 - atleast one skb is to be sent out, *skbp contains skb or NULL
> + *	    (in case >1 skbs present in blist for batching)
> + *	0 - no skbs to be sent.
> + */
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


I think you missed my previous reply to this in the flood of
responses (or I missed your reply), so I'm copying it below:

The entire idea of a single queue after qdiscs that is refilled
independantly of transmissions times etc. make be worry a bit.
By changing the timing you're effectively changing the qdiscs
behaviour, at least in some cases. SFQ is a good example, but I
believe it affects most work-conserving qdiscs. Think of this
situation:

100 packets of flow 1 arrive
50 packets of flow 1 are sent
100 packets for flow 2 arrive
remaining packets are sent

On the wire you'll first see 50 packets of flow 1, than 100 packets
alternate of flow 1 and 2, then 50 packets flow 2.

With your additional queue all packets of flow 1 are pulled out of
the qdisc immediately and put in the fifo. When the 100 packets of
the second flow arrive they will also get pulled out immediately
and are put in the fifo behind the remaining 50 packets of flow 1.
So what you get on the wire is:

100 packets of flow 1
100 packets of flow 1

So SFQ is without any effect. This is not completely avoidable of
course, but you can and should limit the damage by only pulling
out as much packets as the driver can take and have the driver
stop the queue afterwards.

