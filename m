From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net] net: sched: shrink struct qdisc_skb_cb to 28 bytes
Date: Thu, 18 Sep 2014 11:07:35 -0700
Message-ID: <1411063655.4290.18.camel@joe-AO725>
References: <1402338773-5996-1-git-send-email-_govind@gmx.com>
	 <1402338773-5996-2-git-send-email-_govind@gmx.com>
	 <CAE9FiQW+Rv4o9Pc1J9hyqgW1WrhEANKEXH6zYQc2NQqeMbAcvA@mail.gmail.com>
	 <alpine.LNX.2.03.1406261159071.1438@ws.cisco>
	 <CAJZOPZJ7+n0t1LCqaa3JCBByRw=f_Tp6rk8vm0ZnCzmtKFKX_g@mail.gmail.com>
	 <1411052525.7106.269.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140918092628.566eae2b@urahara>
	 <1411057934.7106.275.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1411063227.7106.280.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Or Gerlitz <or.gerlitz@gmail.com>,
	Govindarajulu Varadarajan <_govind@gmx.com>,
	Yinghai Lu <yinghai@kernel.org>,
	David Miller <davem@davemloft.net>,
	NetDev <netdev@vger.kernel.org>, ssujith@cisco.com,
	gvaradar@cisco.com, "Christian Benvenuti (benve)" <benve@cisco.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0134.hostedemail.com ([216.40.44.134]:52559 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932117AbaIRSHj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Sep 2014 14:07:39 -0400
In-Reply-To: <1411063227.7106.280.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-09-18 at 11:00 -0700, Eric Dumazet wrote:
> On Thu, 2014-09-18 at 09:32 -0700, Eric Dumazet wrote:
> > On Thu, 2014-09-18 at 09:26 -0700, Stephen Hemminger wrote:
[]
> > Or, do you have an idea ?
> 
> Seems straightforward ...
> 
> Or can you carry this fix for me ?
> 
> Thanks
> 
> [PATCH] ipoib: validate struct ipoib_cb size
> 
> To catch future errors sooner.
[]
> diff --git a/drivers/infiniband/ulp/ipoib/ipoib.h b/drivers/infiniband/ulp/ipoib/ipoib.h
[]
> +static inline struct ipoib_cb *ipoib_skb_cb(const struct sk_buff *skb)
> +{
> +	BUILD_BUG_ON(sizeof(skb->cb) < sizeof(struct ipoib_cb));
> +	return (struct ipoib_cb *)skb->cb;
> +}

It seems better not to use const for the struct sk_buff * here.

Neither of the uses take a const struct sk_buff *

> diff --git a/drivers/infiniband/ulp/ipoib/ipoib_main.c b/drivers/infiniband/ulp/ipoib/ipoib_main.c

> @@ -716,7 +716,7 @@ static int ipoib_start_xmit(struct sk_buff *skb, struct net_device *dev)
>  {
>  	struct ipoib_dev_priv *priv = netdev_priv(dev);
>  	struct ipoib_neigh *neigh;
> -	struct ipoib_cb *cb = (struct ipoib_cb *) skb->cb;
> +	struct ipoib_cb *cb = ipoib_skb_cb(skb);
>  	struct ipoib_header *header;
>  	unsigned long flags;
>  
> @@ -813,7 +813,7 @@ static int ipoib_hard_header(struct sk_buff *skb,
>  			     const void *daddr, const void *saddr, unsigned len)
>  {
>  	struct ipoib_header *header;
> -	struct ipoib_cb *cb = (struct ipoib_cb *) skb->cb;
> +	struct ipoib_cb *cb = ipoib_skb_cb(skb);
>  
>  	header = (struct ipoib_header *) skb_push(skb, sizeof *header);
