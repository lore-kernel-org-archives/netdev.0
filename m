From: Scot Doyle <lkml@scotdoyle.com>
Subject: Re: [PATCH v2] ip: ip_options_compile() resilient to NULL skb route
Date: Thu, 14 Apr 2011 17:02:48 -0500
Message-ID: <4DA76F08.5000302@scotdoyle.com>
References: <4DA522B2.90200@scotdoyle.com> <4DA5BCF7.9020606@scotdoyle.com>	 <1302708487.3725.0.camel@edumazet-laptop>	 <20110413.144812.116375845.davem@davemloft.net>	 <1302748276.3549.20.camel@edumazet-laptop> <20110413195424.1d2393c6@s6510>	 <1302750214.3549.34.camel@edumazet-laptop>	 <20110414123058.d4ffe7fb.shimoda.hiroaki@gmail.com> <1302796537.3248.22.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.scotdoyle.com ([74.207.249.244]:56620 "EHLO
	smtp.scotdoyle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751520Ab1DNWCu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2011 18:02:50 -0400
In-Reply-To: <1302796537.3248.22.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/14/2011 10:55 AM, Eric Dumazet wrote:
> Scot Doyle demonstrated ip_options_compile() could be called with an skb
> without an attached route, using a setup involving a bridge, netfilter,
> and forged IP packets.
>
> Let's make ip_options_compile() and ip_options_rcv_srr() a bit more
> robust, instead of changing bridge/netfilter code.
>
> With help from Hiroaki SHIMODA.
>
> Reported-by: Scot Doyle<lkml@scotdoyle.com>
> Signed-off-by: Eric Dumazet<eric.dumazet@gmail.com>
> Cc: Stephen Hemminger<shemminger@vyatta.com>
> Cc: Hiroaki SHIMODA<shimoda.hiroaki@gmail.com>
> ---
> v2: ip_options_rcv_srr() fix as well, from Hiroaki
>
>   net/ipv4/ip_options.c |    6 +++---
>   1 file changed, 3 insertions(+), 3 deletions(-)
>
> diff --git a/net/ipv4/ip_options.c b/net/ipv4/ip_options.c
> index 28a736f..2391b24 100644
> --- a/net/ipv4/ip_options.c
> +++ b/net/ipv4/ip_options.c
> @@ -329,7 +329,7 @@ int ip_options_compile(struct net *net,
>   					pp_ptr = optptr + 2;
>   					goto error;
>   				}
> -				if (skb) {
> +				if (rt) {
>   					memcpy(&optptr[optptr[2]-1],&rt->rt_spec_dst, 4);
>   					opt->is_changed = 1;
>   				}
> @@ -371,7 +371,7 @@ int ip_options_compile(struct net *net,
>   						goto error;
>   					}
>   					opt->ts = optptr - iph;
> -					if (skb) {
> +					if (rt)  {
>   						memcpy(&optptr[optptr[2]-1],&rt->rt_spec_dst, 4);
>   						timeptr = (__be32*)&optptr[optptr[2]+3];
>   					}
> @@ -603,7 +603,7 @@ int ip_options_rcv_srr(struct sk_buff *skb)
>   	unsigned long orefdst;
>   	int err;
>
> -	if (!opt->srr)
> +	if (!opt->srr || !rt)
>   		return 0;
>
>   	if (skb->pkt_type != PACKET_HOST)
The 2.6.39-rc3 kernel, plus this patch and the two patches previously 
accepted by David in this thread, didn't panic when tested with the IP 
Stack Checker tool hitting either the assigned bridge IP address or a 
guest virtual machine IP address sharing that bridge.
