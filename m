From: Pablo Neira Ayuso <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>
Subject: Re: [PATCH v8 5/6] net: ipv4, ipv6: run cgroup eBPF egress programs
Date: Fri, 18 Nov 2016 13:37:32 +0100
Message-ID: <20161118123732.GA10400@salvia>
References: <1479407229-14861-1-git-send-email-daniel@zonque.org>
 <1479407229-14861-6-git-send-email-daniel@zonque.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: htejun-b10kYP2dOMg@public.gmane.org, daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org, ast-b10kYP2dOMg@public.gmane.org,
        davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, kafai-b10kYP2dOMg@public.gmane.org, fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org, harald-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Daniel Mack <daniel-cYrQPVfZoowdnm+yROfE0A@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1479407229-14861-6-git-send-email-daniel-cYrQPVfZoowdnm+yROfE0A@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 17, 2016 at 07:27:08PM +0100, Daniel Mack wrote:
[...]
> @@ -312,6 +314,12 @@ int ip_mc_output(struct net *net, struct sock *sk, struct sk_buff *skb)
>  	skb->dev = dev;
>  	skb->protocol = htons(ETH_P_IP);
>  
> +	ret = BPF_CGROUP_RUN_PROG_INET_EGRESS(sk, skb);
> +	if (ret) {
> +		kfree_skb(skb);
> +		return ret;
> +	}
> +
>  	/*
>  	 *	Multicasts are looped back for other local users
>  	 */
> @@ -364,12 +372,19 @@ int ip_mc_output(struct net *net, struct sock *sk, struct sk_buff *skb)
>  int ip_output(struct net *net, struct sock *sk, struct sk_buff *skb)
>  {
>  	struct net_device *dev = skb_dst(skb)->dev;
> +	int ret;
>  
>  	IP_UPD_PO_STATS(net, IPSTATS_MIB_OUT, skb->len);
>  
>  	skb->dev = dev;
>  	skb->protocol = htons(ETH_P_IP);
>  
> +	ret = BPF_CGROUP_RUN_PROG_INET_EGRESS(sk, skb);
> +	if (ret) {
> +		kfree_skb(skb);
> +		return ret;
> +	}
> +
>  	return NF_HOOK_COND(NFPROTO_IPV4, NF_INET_POST_ROUTING,
>  			    net, sk, skb, NULL, dev,
>  			    ip_finish_output,

Please, place this after the netfilter hook.

Since this new hook may mangle output packets, any mangling
potentially interfers and breaks conntrack.

Thank you.
