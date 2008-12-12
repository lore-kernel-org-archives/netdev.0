From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH 3/8] net: Add Generic Receive Offload infrastructure
Date: Fri, 12 Dec 2008 22:51:30 +0300
Message-ID: <20081212195130.GB27281@ioremap.net>
References: <20081212053116.GA2927@gondor.apana.org.au> <E1LB0cx-0000r3-N2@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tservice.net.ru ([195.178.208.66]:45670 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751669AbYLLTvb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Dec 2008 14:51:31 -0500
Content-Disposition: inline
In-Reply-To: <E1LB0cx-0000r3-N2@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 12, 2008 at 04:31:51PM +1100, Herbert Xu (herbert@gondor.apana.org.au) wrote:
> +static int napi_gro_complete(struct sk_buff *skb)
> +{
> +	struct packet_type *ptype;
> +	__be16 type = skb->protocol;
> +	struct list_head *head = &ptype_base[ntohs(type) & PTYPE_HASH_MASK];
> +	int err = -ENOENT;
> +
> +	if (!skb_shinfo(skb)->frag_list)
> +		goto out;
> +
> +	rcu_read_lock();
> +	list_for_each_entry_rcu(ptype, head, list) {
> +		if (ptype->type != type || ptype->dev || !ptype->gro_complete)
> +			continue;
> +
> +		err = ptype->gro_complete(skb);
> +		break;
> +	}
> +	rcu_read_unlock();
> +
> +	if (err) {
> +		WARN_ON(&ptype->list == head);
> +		kfree_skb(skb);
> +		return NET_RX_SUCCESS;

Success after freeing skb on error? :)
Why not WARN_ON_ONCE()?

> +	}
> +
> +out:
> +	__skb_push(skb, -skb_network_offset(skb));
> +	return netif_receive_skb(skb);
> +}
> +
> +void napi_gro_flush(struct napi_struct *napi)
> +{
> +	struct sk_buff *skb, *next;
> +
> +	for (skb = napi->gro_list; skb; skb = next) {
> +		next = skb->next;
> +		skb->next = NULL;
> +		napi_gro_complete(skb);
> +	}
> +
> +	napi->gro_list = NULL;
> +}
> +EXPORT_SYMBOL(napi_gro_flush);
> +
> +int napi_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
> +{
> +	struct sk_buff **pp;
> +	struct packet_type *ptype;
> +	__be16 type = skb->protocol;
> +	struct list_head *head = &ptype_base[ntohs(type) & PTYPE_HASH_MASK];
> +	int count = 0;
> +	int mac_len;
> +
> +	if (!(skb->dev->features & NETIF_F_GRO))
> +		goto normal;
> +
> +	rcu_read_lock();
> +	list_for_each_entry_rcu(ptype, head, list) {
> +		struct sk_buff *p;
> +
> +		if (ptype->type != type || ptype->dev || !ptype->gro_receive)
> +			continue;
> +
> +		skb_reset_network_header(skb);
> +		mac_len = skb->network_header - skb->mac_header;
> +		skb->mac_len = mac_len;
> +		NAPI_GRO_CB(skb)->same_flow = 0;
> +		NAPI_GRO_CB(skb)->flush = 0;
> +
> +		for (p = napi->gro_list; p; p = p->next) {
> +			count++;
> +			NAPI_GRO_CB(p)->same_flow =
> +				p->mac_len == mac_len &&
> +				!memcmp(skb_mac_header(p), skb_mac_header(skb),
> +					mac_len);
> +			NAPI_GRO_CB(p)->flush = 0;
> +		}
> +
> +		pp = ptype->gro_receive(&napi->gro_list, skb);
> +		break;
> +	}
> +	rcu_read_unlock();
> +
> +	if (&ptype->list == head)
> +		goto normal;
> +
> +	if (pp) {
> +		struct sk_buff *nskb = *pp;
> +
> +		*pp = nskb->next;
> +		nskb->next = NULL;
> +		napi_gro_complete(nskb);
> +		count--;
> +	}
> +
> +	if (NAPI_GRO_CB(skb)->same_flow)
> +		goto ok;

Should this set ->count?

> +
> +	if (NAPI_GRO_CB(skb)->flush || count >= MAX_GRO_SKBS) {
> +		__skb_push(skb, -skb_network_offset(skb));
> +		goto normal;
> +	}
> +
> +	NAPI_GRO_CB(skb)->count = 1;

Maybe this should be set to 'count', not 1?

> +	skb->next = napi->gro_list;
> +	napi->gro_list = skb;
> +
> +ok:
> +	return NET_RX_SUCCESS;
> +
> +normal:
> +	return netif_receive_skb(skb);
> +}
> +EXPORT_SYMBOL(napi_gro_receive);

-- 
	Evgeniy Polyakov
