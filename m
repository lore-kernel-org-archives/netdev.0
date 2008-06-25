From: Or Gerlitz <ogerlitz@voltaire.com>
Subject: Re: [ofa-general] [PATCH] net/inet_lro: remove setting skb->ip_summed
 when not LRO-able
Date: Wed, 25 Jun 2008 12:26:12 +0300
Message-ID: <48620F34.6090901@voltaire.com>
References: <1214318386.23583.37.camel@mtls03>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eli Cohen <eli@dev.mellanox.co.il>, netdev@vger.kernel.org,
	Roland Dreier <rdreier@cisco.com>,
	Vladimir Sokolovsky <vlad@mellanox.co.il>,
	OpenFabrics General <general@lists.openfabrics.org>
To: Jan-Bernd Themann <THEMANN@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fwil.voltaire.com ([193.47.165.2]:59942 "EHLO exil.voltaire.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752459AbYFYJ0R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Jun 2008 05:26:17 -0400
In-Reply-To: <1214318386.23583.37.camel@mtls03>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eli Cohen wrote:
> When an SKB cannot be chained to a session, the current code attempts to "restore" its ip_summed field from lro_mgr->ip_summed. However, lro_mgr->ip_summed does not hold the original value; in fact, we'd better not touch skb->ip_summed since it is not modified by the code in the path leading to a failure to chain it.
>
> --- a/net/ipv4/inet_lro.c
> +++ b/net/ipv4/inet_lro.c
> @@ -383,8 +383,7 @@ static int __lro_proc_skb(struct net_lro_mgr *lro_mgr, struct sk_buff *skb,
>  out2: /* send aggregated SKBs to stack */
>  	lro_flush(lro_mgr, lro_desc);
>  
> -out:  /* Original SKB has to be posted to stack */
> -	skb->ip_summed = lro_mgr->ip_summed;
> +out:
>  	return 1;
>  }
Jan-Bernd,

I understand from your response that lro_mgr->ip_summed is not needed, 
so I guess it should removed from all other places that (eg its 
definition and usage in inet_lro.[ch] and under drivers/net.

Second, if lro_mgr->aggr_ip_summed is indeed needed, I tend to think it 
need to be derived per received packet from skb->ip_summed, since the 
kernel allows for drivers ti have different checksum offload 
capabilities which for some drivers might be impossible to be encoded in 
one global value (lro_mgr->aggr_ip_summed), what's your thinking here?

Third, consider a case where the receiver gets some very small data 
chunks (eg file/block target that has to serve lots of IOPS for some 
clients but also large IOs for other clients), that is some senders set 
TCP_NODELAY, etc. Now, looking in the code _lro_proc_skb() (below) and 
doing reading some reads at the archives, my understanding is that its 
very possible that a large set of small packets would be gathered and 
sent up to the stack only by the consumer calling lro_flush_all in the 
end of its NAPI poll loop. Am I correct?

Or

> static int __lro_proc_skb(struct net_lro_mgr *lro_mgr, struct sk_buff *skb,
> 			  struct vlan_group *vgrp, u16 vlan_tag, void *priv)
> {
> 	struct net_lro_desc *lro_desc;
> 	struct iphdr *iph;
> 	struct tcphdr *tcph;
> 	u64 flags;
> 	int vlan_hdr_len = 0;
>
> 	if (!lro_mgr->get_skb_header
> 	    || lro_mgr->get_skb_header(skb, (void *)&iph, (void *)&tcph,
> 				       &flags, priv))
> 		goto out;
>
> 	if (!(flags & LRO_IPV4) || !(flags & LRO_TCP))
> 		goto out;
>
> 	lro_desc = lro_get_desc(lro_mgr, lro_mgr->lro_arr, iph, tcph);
> 	if (!lro_desc)
> 		goto out;
>
> 	if ((skb->protocol == htons(ETH_P_8021Q))
> 	    && !(lro_mgr->features & LRO_F_EXTRACT_VLAN_ID))
> 		vlan_hdr_len = VLAN_HLEN;
>
> 	if (!lro_desc->active) { /* start new lro session */
> 		if (lro_tcp_ip_check(iph, tcph, skb->len - vlan_hdr_len, NULL))
> 			goto out;
>
> 		skb->ip_summed = lro_mgr->ip_summed_aggr;
> 		lro_init_desc(lro_desc, skb, iph, tcph, vlan_tag, vgrp);
> 		LRO_INC_STATS(lro_mgr, aggregated);
> 		return 0;
> 	}
>
> 	if (lro_desc->tcp_next_seq != ntohl(tcph->seq))
> 		goto out2;
>
> 	if (lro_tcp_ip_check(iph, tcph, skb->len, lro_desc))
> 		goto out2;
>
> 	lro_add_packet(lro_desc, skb, iph, tcph);
> 	LRO_INC_STATS(lro_mgr, aggregated);
>
> 	if ((lro_desc->pkt_aggr_cnt >= lro_mgr->max_aggr) ||
> 	    lro_desc->parent->len > (0xFFFF - lro_mgr->dev->mtu))
> 		lro_flush(lro_mgr, lro_desc);
>
> 	return 0;
>
> out2: /* send aggregated SKBs to stack */
> 	lro_flush(lro_mgr, lro_desc);
>
> out:  /* Original SKB has to be posted to stack */
> 	skb->ip_summed = lro_mgr->ip_summed;
> 	return 1;
> }

 

