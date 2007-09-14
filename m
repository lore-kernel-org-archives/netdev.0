From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: [ofa-general] Re: [PATCH 3/10 REV5] [sched] Modify qdisc_run to
	support batching
Date: Fri, 14 Sep 2007 16:15:19 +0400
Message-ID: <20070914121518.GB18517@2ka.mipt.ru>
References: <20070914090058.17589.80352.sendpatchset@K50wks273871wss.in.ibm.com>
	<20070914090156.17589.61701.sendpatchset@K50wks273871wss.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jagana@us.ibm.com, Robert.Olsson@data.slu.se, herbert@gondor.apana.org.au,
	gaagaan@gmail.com, kumarkr@linux.ibm.com, rdreier@cisco.com,
	peter.p.waskiewicz.jr@intel.com, hadi@cyberus.ca,
	netdev@vger.kernel.org, kaber@trash.net, randy.dunlap@oracle.com,
	jeff@garzik.org, general@lists.openfabrics.org,
	mchan@broadcom.com, tgraf@suug.ch, mcarlson@broadcom.com,
	sri@us.ibm.com, shemminger@linux-foundation.org, davem@davemloft.net
To: Krishna Kumar <krkumar2@in.ibm.com>
Return-path: <general-bounces@lists.openfabrics.org>
Content-Disposition: inline
In-Reply-To: <20070914090156.17589.61701.sendpatchset@K50wks273871wss.in.ibm.com>
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

On Fri, Sep 14, 2007 at 02:31:56PM +0530, Krishna Kumar (krkumar2@in.ibm.com) wrote:
> +int dev_add_skb_to_blist(struct sk_buff *skb, struct net_device *dev)
> +{
> +	if (!list_empty(&ptype_all))
> +		dev_queue_xmit_nit(skb, dev);
> +
> +	if (netif_needs_gso(dev, skb)) {
> +		if (unlikely(dev_gso_segment(skb))) {
> +			kfree_skb(skb);
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

Could it be list_move()-like function for skb lists?
I'm pretty sure if you change first and the last skbs and ke of the
queue in one shot, result will be the same.
Actually how many skbs are usually batched in your load?

> +			/* Reset destructor for kfree_skb to work */
> +			skb->destructor = DEV_GSO_CB(skb)->destructor;
> +			kfree_skb(skb);

Why do you free first skb in the chain?

> +			return count;
> +		}
> +	}
> +	__skb_queue_tail(dev->skb_blist, skb);
> +	return 1;
> +}

-- 
	Evgeniy Polyakov
