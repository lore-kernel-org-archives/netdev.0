From: Sander Eikelenboom <linux@eikelenboom.it>
Subject: Re: Netfilter: BUG: unable to handle kernel paging request, RIP:
 =?UTF-8?Q?physdev=5Fmt+=30xd=36/=30x=31=36=30?=
Date: Mon, 14 Sep 2015 09:50:26 +0200
Message-ID: <57e23f8e80b57dff72f6bc5b7e9b2d53@eikelenboom.it>
References: <1620a50057d1e8aadafe27c74ee42d93@eikelenboom.it>
 <20150913180620.GK24810@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter@vger.kernel.org,
	Pablo Neira Ayuso <pablo@netfilter.org>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vserver.eikelenboom.it ([84.200.39.61]:58410 "EHLO
	smtp.eikelenboom.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753155AbbINH6q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Sep 2015 03:58:46 -0400
In-Reply-To: <20150913180620.GK24810@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2015-09-13 20:06, Florian Westphal wrote:
> Sander Eikelenboom <linux@eikelenboom.it> wrote:
>> Using a linux-4.3-rc1 kernel i encountered the splat below:
> 
> Thanks for reporting this bug.
> 
>> [  290.200642] BUG: unable to handle kernel paging request at
>> 000000000484195d
>> [  290.211702] IP: [<ffffffff819bc3e6>] physdev_mt+0xd6/0x160
> [..]
> 
>> [  290.444088]  [<ffffffff81a4e6c0>] ipt_do_table+0x210/0x390
>> [  290.461951]  [<ffffffff81a510ae>] iptable_filter_hook+0x2e/0x70
>> [  290.470756]  [<ffffffff8199279c>] nf_iterate+0x4c/0x80
>> [  290.479587]  [<ffffffff81992834>] nf_hook_slow+0x64/0xc0
>> [  290.488341]  [<ffffffff81a06779>] ip_forward+0x369/0x3c0
>> [  290.496927]  [<ffffffff81a06380>] ? ip_frag_mem+0x40/0x40
>> [  290.505365]  [<ffffffff81a04961>] ip_rcv_finish+0x101/0x330
>> [  290.513480]  [<ffffffff81a05001>] ip_rcv+0x291/0x390
>> [  290.521562]  [<ffffffff81a04860>] ?
> 
> Aye, ip forwarding of bridged packets with call-iptables=1 is broken.
> 
> Please, could you try this patch?  It fixes this bug for me.

Hi Florian,

Works for me too, thx for the fix !

--
Sander


> diff --git a/net/bridge/br_netfilter_hooks.c 
> b/net/bridge/br_netfilter_hooks.c
> --- a/net/bridge/br_netfilter_hooks.c
> +++ b/net/bridge/br_netfilter_hooks.c
> @@ -355,6 +355,7 @@ static int br_nf_pre_routing_finish(struct sock
> *sk, struct sk_buff *skb)
>  	struct iphdr *iph = ip_hdr(skb);
>  	struct nf_bridge_info *nf_bridge = nf_bridge_info_get(skb);
>  	struct rtable *rt;
> +	bool daddr_changed;
>  	int err;
> 
>  	nf_bridge->frag_max_size = IPCB(skb)->frag_max_size;
> @@ -363,8 +364,15 @@ static int br_nf_pre_routing_finish(struct sock
> *sk, struct sk_buff *skb)
>  		skb->pkt_type = PACKET_OTHERHOST;
>  		nf_bridge->pkt_otherhost = false;
>  	}
> +
> +	/* set physoutdev to NULL, its set by the bridge forward hook but
> +	 * frame might be routed instead of bridged.
> +	 */
> +	daddr_changed = br_nf_ipv4_daddr_was_changed(skb, nf_bridge);
> +	nf_bridge->physoutdev = NULL;
>  	nf_bridge->in_prerouting = 0;
> -	if (br_nf_ipv4_daddr_was_changed(skb, nf_bridge)) {
> +
> +	if (daddr_changed) {
>  		if ((err = ip_route_input(skb, iph->daddr, iph->saddr, iph->tos, 
> dev))) {
>  			struct in_device *in_dev = __in_dev_get_rcu(dev);
> 
> diff --git a/net/bridge/br_netfilter_ipv6.c 
> b/net/bridge/br_netfilter_ipv6.c
> index 77383bf..772222b 100644
> --- a/net/bridge/br_netfilter_ipv6.c
> +++ b/net/bridge/br_netfilter_ipv6.c
> @@ -167,6 +167,7 @@ static int br_nf_pre_routing_finish_ipv6(struct
> sock *sk, struct sk_buff *skb)
>  	struct rtable *rt;
>  	struct net_device *dev = skb->dev;
>  	const struct nf_ipv6_ops *v6ops = nf_get_ipv6_ops();
> +	bool daddr_changed;
> 
>  	nf_bridge->frag_max_size = IP6CB(skb)->frag_max_size;
> 
> @@ -174,8 +175,12 @@ static int br_nf_pre_routing_finish_ipv6(struct
> sock *sk, struct sk_buff *skb)
>  		skb->pkt_type = PACKET_OTHERHOST;
>  		nf_bridge->pkt_otherhost = false;
>  	}
> +
> +	daddr_changed = br_nf_ipv6_daddr_was_changed(skb, nf_bridge);
> +	nf_bridge->physoutdev = NULL;
>  	nf_bridge->in_prerouting = 0;
> -	if (br_nf_ipv6_daddr_was_changed(skb, nf_bridge)) {
> +
> +	if (daddr_changed) {
>  		skb_dst_drop(skb);
>  		v6ops->route_input(skb);
