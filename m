From: Bandan Das <bsd@redhat.com>
Subject: Re: Revert 462fb2af9788a82a534f8184abfde31574e1cfa0 (bridge : Sanitize skb before it enters the IP stack)
Date: Thu, 22 May 2014 16:06:35 -0400
Message-ID: <jpg4n0hpohg.fsf@nelium.bos.redhat.com>
References: <536F8C0F.4090206@davidnewall.com>
	<5370CB47.4010400@davidnewall.com>
	<DUB123-W514EA0A4A29F520778F2FFED350@phx.gbl>
	<53715D67.8020803@davidnewall.com> <53736ACC.9010902@davidnewall.com>
	<537621AC.1060409@davidnewall.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Lukas Tribus <luky-37@hotmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Netdev <netdev@vger.kernel.org>, "fw\@strlen.de" <fw@strlen.de>
To: David Newall <davidn@davidnewall.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:63581 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751424AbaEVUGv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 May 2014 16:06:51 -0400
In-Reply-To: <537621AC.1060409@davidnewall.com> (David Newall's message of
	"Sat, 17 May 2014 00:03:16 +0930")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Newall <davidn@davidnewall.com> writes:

> We should revert commit 462fb2af9788a82a534f8184abfde31574e1cfa0
> (bridge : Sanitize skb before it enters the IP stack) because it
> corrupts IP packets with RR or TS options set, only partially updating
> the IP header and leaving an incorrect checksum.
>
> The argument for introducing the change is at lkml.org/lkml/2010/8/30/391:
>
> The bridge layer can overwrite the IPCB using the
> BR_INPUT_SKB_CB macro. In br_nf_dev_queue_xmit,
> if we recieve a packet greater in size than the bridge
> device MTU, we call ip_fragment which in turn will lead to
> icmp_send calling ip_options_echo if the DF flag is set.
> ip_options_echo will then incorrectly try to parse the IPCB as
> IP options resulting in a buffer overflow.
> This change refills the CB area back with IP
> options before ip_fragment calls icmp_send. If we fail parsing,
> we zero out the IPCB area to guarantee that the stack does
> not get corrupted.
>
> A bridge should not fragment packets; an *ethernet* bridge should not
> need to.  Fragmenting packets is the job of higher level protocol.

IIRC, older dhcp servers try to set a low enough mtu and that was
causing ip_fragment to bail.. I think I was seeing this with a 
KVM guest with a bridged interface set to fetch an ip from the host
network.

Are you sure this won't cause a regression ? I think this was the 
relevant change -
 static int br_nf_dev_queue_xmit(struct sk_buff *skb)
 {
+       int ret;
+
        if (skb->nfct != NULL && skb->protocol == htons(ETH_P_IP) &&
            skb->len + nf_bridge_mtu_reduction(skb) > skb->dev->mtu &&
            !skb_is_gso(skb)) {
-               /* BUG: Should really parse the IP options here. */
-               memset(IPCB(skb), 0, sizeof(struct inet_skb_parm));
-               return ip_fragment(skb, br_dev_queue_push_xmit);
+               if (br_parse_ip_options(skb))
+                       /* Drop invalid packet */
+                       return NF_DROP;
+               ret = ip_fragment(skb, br_dev_queue_push_xmit);

This call was the reason for the change, are you sure this isn't 
applicable anymore ?

        } else
-               return br_dev_queue_push_xmit(skb);
+               ret = br_dev_queue_push_xmit(skb);
+
+       return ret;
 }

> --- br_netfilter.c	2014-01-20 13:10:07.000000000 +1030
> +++ br_netfilter.c.prop	2014-05-16 23:07:57.975386905 +0930
> @@ -253,73 +253,6 @@
>  		skb->protocol = htons(ETH_P_PPP_SES);
>  }
>  -/* When handing a packet over to the IP layer
> - * check whether we have a skb that is in the
> - * expected format
> - */
> -
> -static int br_parse_ip_options(struct sk_buff *skb)
> -{
> -	struct ip_options *opt;
> -	const struct iphdr *iph;
> -	struct net_device *dev = skb->dev;
> -	u32 len;
> -
> -	if (!pskb_may_pull(skb, sizeof(struct iphdr)))
> -		goto inhdr_error;
> -
> -	iph = ip_hdr(skb);
> -	opt = &(IPCB(skb)->opt);
> -
> -	/* Basic sanity checks */
> -	if (iph->ihl < 5 || iph->version != 4)
> -		goto inhdr_error;
> -
> -	if (!pskb_may_pull(skb, iph->ihl*4))
> -		goto inhdr_error;
> -
> -	iph = ip_hdr(skb);
> -	if (unlikely(ip_fast_csum((u8 *)iph, iph->ihl)))
> -		goto inhdr_error;
> -
> -	len = ntohs(iph->tot_len);
> -	if (skb->len < len) {
> -		IP_INC_STATS_BH(dev_net(dev), IPSTATS_MIB_INTRUNCATEDPKTS);
> -		goto drop;
> -	} else if (len < (iph->ihl*4))
> -		goto inhdr_error;
> -
> -	if (pskb_trim_rcsum(skb, len)) {
> -		IP_INC_STATS_BH(dev_net(dev), IPSTATS_MIB_INDISCARDS);
> -		goto drop;
> -	}
> -
> -	memset(IPCB(skb), 0, sizeof(struct inet_skb_parm));
> -	if (iph->ihl == 5)
> -		return 0;
> -
> -	opt->optlen = iph->ihl*4 - sizeof(struct iphdr);
> -	if (ip_options_compile(dev_net(dev), opt, skb))
> -		goto inhdr_error;
> -
> -	/* Check correct handling of SRR option */
> -	if (unlikely(opt->srr)) {
> -		struct in_device *in_dev = __in_dev_get_rcu(dev);
> -		if (in_dev && !IN_DEV_SOURCE_ROUTE(in_dev))
> -			goto drop;
> -
> -		if (ip_options_rcv_srr(skb))
> -			goto drop;
> -	}
> -
> -	return 0;
> -
> -inhdr_error:
> -	IP_INC_STATS_BH(dev_net(dev), IPSTATS_MIB_INHDRERRORS);
> -drop:
> -	return -1;
> -}
> -
>  /* Fill in the header for fragmented IP packets handled by
>   * the IPv4 connection tracking code.
>   */
> @@ -679,6 +612,7 @@
>  {
>  	struct net_bridge_port *p;
>  	struct net_bridge *br;
> +	const struct iphdr *iph;
>  	__u32 len = nf_bridge_encap_header_len(skb);
>  	if (unlikely(!pskb_may_pull(skb, len)))
> @@ -704,9 +638,29 @@
>  		return NF_ACCEPT;
>  	nf_bridge_pull_encap_header_rcsum(skb);
> +
> +	if (!pskb_may_pull(skb, sizeof(struct iphdr)))
> +		goto inhdr_error;
>  -	if (br_parse_ip_options(skb))
> -		return NF_DROP;
> +	iph = ip_hdr(skb);
> +	if (iph->ihl < 5 || iph->version != 4)
> +		goto inhdr_error;
> +
> +	if (!pskb_may_pull(skb, 4 * iph->ihl))
> +		goto inhdr_error;
> +
> +	iph = ip_hdr(skb);
> +	if (ip_fast_csum((__u8 *) iph, iph->ihl) != 0)
> +		goto inhdr_error;
> +
> +	len = ntohs(iph->tot_len);
> +	if (skb->len < len || len < 4 * iph->ihl)
> +		goto inhdr_error;
> +
> +	pskb_trim_rcsum(skb, len);
> +
> +	/* BUG: Should really parse the IP options here. */
> +	memset(IPCB(skb), 0, sizeof(struct inet_skb_parm));
>  	nf_bridge_put(skb->nf_bridge);
>  	if (!nf_bridge_alloc(skb))
> @@ -720,6 +674,10 @@
>  		br_nf_pre_routing_finish);
>  	return NF_STOLEN;
> +
> +inhdr_error:
> +//      IP_INC_STATS_BH(IpInHdrErrors);
> +	return NF_DROP;
>  }
>  @@ -806,9 +764,6 @@
>  		nf_bridge->mask |= BRNF_PKT_TYPE;
>  	}
>  -	if (pf == NFPROTO_IPV4 && br_parse_ip_options(skb))
> -		return NF_DROP;
> -
>  	/* The physdev module checks on this */
>  	nf_bridge->mask |= BRNF_BRIDGED;
>  	nf_bridge->physoutdev = skb->dev;
> @@ -862,19 +817,14 @@
>  #if IS_ENABLED(CONFIG_NF_CONNTRACK_IPV4)
>  static int br_nf_dev_queue_xmit(struct sk_buff *skb)
>  {
> -	int ret;
> -
>  	if (skb->nfct != NULL && skb->protocol == htons(ETH_P_IP) &&
>  	    skb->len + nf_bridge_mtu_reduction(skb) > skb->dev->mtu &&
>  	    !skb_is_gso(skb)) {
> -		if (br_parse_ip_options(skb))
> -			/* Drop invalid packet */
> -			return NF_DROP;
> -		ret = ip_fragment(skb, br_dev_queue_push_xmit);
> +		/* BUG: Should really parse the IP options here. */
> +		memset(IPCB(skb), 0, sizeof(struct inet_skb_parm));
> +		return ip_fragment(skb, br_dev_queue_push_xmit);
>  	} else
> -		ret = br_dev_queue_push_xmit(skb);
> -
> -	return ret;
> +		return br_dev_queue_push_xmit(skb);
>  }
>  #else
>  static int br_nf_dev_queue_xmit(struct sk_buff *skb)
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
