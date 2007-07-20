From: Patrick McHardy <kaber@trash.net>
Subject: [ofa-general] Re: [PATCH 05/10] sch_generic.c changes.
Date: Fri, 20 Jul 2007 20:16:36 +0200
Message-ID: <46A0FC04.1000006@trash.net>
References: <20070720063149.26341.84076.sendpatchset@localhost.localdomain>
	<20070720063249.26341.125.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, Robert.Olsson@data.slu.se,
	peter.p.waskiewicz.jr@intel.com, herbert@gondor.apana.org.au,
	gaagaan@gmail.com, kumarkr@linux.ibm.com, rdreier@cisco.com,
	mcarlson@broadcom.com, netdev@vger.kernel.org, jagana@us.ibm.com,
	general@lists.openfabrics.org, mchan@broadcom.com, tgraf@suug.ch,
	jeff@garzik.org, hadi@cyberus.ca, davem@davemloft.net, sri@us.ibm.com
To: Krishna Kumar <krkumar2@in.ibm.com>
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20070720063249.26341.125.sendpatchset@localhost.localdomain>
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
> +static inline int get_skb(struct net_device *dev, struct Qdisc *q,
> +			  struct sk_buff_head *blist,
> +			  struct sk_buff **skbp)
> +{
> +	if (likely(!blist) || (!skb_queue_len(blist) && qdisc_qlen(q) <= 1)) {
> +		return likely((*skbp = dev_dequeue_skb(dev, q)) != NULL);
> +	} else {
> +		int max = dev->tx_queue_len - skb_queue_len(blist);


I'm assuming the driver will simply leave excess packets in the
blist for the next run. The check for tx_queue_len is wrong though,
its only a default which can be overriden and some qdiscs don't
care for it at all.

> +		struct sk_buff *skb;
> +
> +		while (max > 0 && (skb = dev_dequeue_skb(dev, q)) != NULL)
> +			max -= dev_add_skb_to_blist(skb, dev);
> +
> +		*skbp = NULL;
> +		return 1;	/* we have atleast one skb in blist */
> +	}
> +}



> -void __qdisc_run(struct net_device *dev)
> +void __qdisc_run(struct net_device *dev, struct sk_buff_head *blist)


And the patches should really be restructured so this change is
in the same patch changing the header and the caller, for example.

>  {
>  	do {
> -		if (!qdisc_restart(dev))
> +		if (!qdisc_restart(dev, blist))
>  			break;
>  	} while (!netif_queue_stopped(dev));
>  
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
