From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH]IP: Send  an ICMP "Fragment Reassembly Timeout" message
 when enabling connection track
Date: Thu, 21 Jan 2010 13:13:38 +0100
Message-ID: <4B5844F2.30104@trash.net>
References: <4B57AC35.8070902@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	eric.dumazet@gmail.com, david@blue-labs.org, jorge@dti2.net,
	opurdila@ixiacom.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	netfilter-devel@vger.kernel.org
To: Shan Wei <shanwei@cn.fujitsu.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4B57AC35.8070902@cn.fujitsu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Shan Wei wrote:
> No matter whether connection track is enabled, an end host should send 
> an ICMPv4 "Fragment Reassembly Timeout" message when defrag timeout. 
> The reasons are following two points:  
> 
> 1. RFC 792 says:
>    >>>> >> > >   If a host reassembling a fragmented datagram cannot complete the
>    >>>> >> > >   reassembly due to missing fragments within its time limit it
>    >>>> >> > >   discards the datagram, and it may send a time exceeded message.
>    >>>> >> > > 
>    >>>> >> > >   If fragment zero is not available then no time exceeded need be
>    >>>> >> > >   sent at all.
>    >>>> >> > > 
>    >>>> >> > > Read more: http://www.faqs.org/rfcs/rfc792.html#ixzz0aOXRD7Wp
> 
> 2. Patrick McHardy also agrees with this opinion. :-) 
>    About the discussion of this opinion, refer to http://patchwork.ozlabs.org/patch/41649
> 
> The patch fixed the problem like this:
> When enabling connection track, fragments are received at PRE_ROUTING HOOK.
> If they are failed to reassemble, ip_expire() will be called. 
> Before sending an ICMP "Fragment Reassembly Timeout" message, 
> the patch searches router table to get the destination entry only for host type.
> 
> The patch has been tested on both host type and route type.

Looks good. One comment below:

> @@ -205,13 +207,38 @@ static void ip_expire(unsigned long arg)
>  	if ((qp->q.last_in & INET_FRAG_FIRST_IN) && qp->q.fragments != NULL) {
>  		struct sk_buff *head = qp->q.fragments;
>  
> -		/* Send an ICMP "Fragment Reassembly Timeout" message. */
>  		rcu_read_lock();
>  		head->dev = dev_get_by_index_rcu(net, qp->iif);
> -		if (head->dev)
> -			icmp_send(head, ICMP_TIME_EXCEEDED, ICMP_EXC_FRAGTIME, 0);
> -		rcu_read_unlock();
> +		if (!head->dev)
> +			goto out_rcu_unlock;
> +
> +		/*
> +		 * Only search router table for the head fragment,
> +		 * when defraging timeout at PRE_ROUTING HOOK.
> +		 */
> +		if (qp->user == IP_DEFRAG_CONNTRACK_IN && !skb_dst(head)) {
> +			const struct iphdr *iph = ip_hdr(head);
> +			int err = ip_route_input(head, iph->daddr, iph->saddr,
> +						 iph->tos, head->dev);
> +			if (unlikely(err))
> +				goto out_rcu_unlock;
> +
> +			/*
> +			 * Only an end host needs to send an ICMP
> +			 * "Fragment Reassembly Timeout" message, per RFC792.
> +			 */
> +			if (skb_rtable(head)->rt_type != RTN_LOCAL) {
> +				skb_dst_drop(head);

Is manually dropping the dst entry necessary here? It will get released
by the fragment destructor anyways if I'm not mistaken.

> +				goto out_rcu_unlock;
> +			}
> +		}
> +
> +		/* Send an ICMP "Fragment Reassembly Timeout" message. */
> +		icmp_send(head, ICMP_TIME_EXCEEDED, ICMP_EXC_FRAGTIME, 0);
>  	}
> +
> +out_rcu_unlock:
> +	rcu_read_unlock();
>  out:
>  	spin_unlock(&qp->q.lock);
>  	ipq_put(qp);
