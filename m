From: Hiroaki SHIMODA <shimoda.hiroaki@gmail.com>
Subject: Re: [PATCH] ip: ip_options_compile() resilient to NULL skb route
Date: Thu, 14 Apr 2011 13:15:52 +0900
Message-ID: <20110414131552.1822142f.shimoda.hiroaki@gmail.com>
References: <4DA522B2.90200@scotdoyle.com>
	<4DA5BCF7.9020606@scotdoyle.com>
	<1302708487.3725.0.camel@edumazet-laptop>
	<20110413.144812.116375845.davem@davemloft.net>
	<1302748276.3549.20.camel@edumazet-laptop>
	<20110413195424.1d2393c6@s6510>
	<1302750214.3549.34.camel@edumazet-laptop>
	<20110414123058.d4ffe7fb.shimoda.hiroaki@gmail.com>
	<1302752263.3549.41.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>, lkml@scotdoyle.com,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:44633 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751637Ab1DNEP5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2011 00:15:57 -0400
Received: by gxk21 with SMTP id 21so563511gxk.19
        for <netdev@vger.kernel.org>; Wed, 13 Apr 2011 21:15:56 -0700 (PDT)
In-Reply-To: <1302752263.3549.41.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 14 Apr 2011 05:37:43 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Indeed good catch, but should we return 0 or -EINVAL so that caller can
> drop packet ?
> 
> @@ -606,7 +606,7 @@ int ip_options_rcv_srr(struct sk_buff *skb)
>  	if (!opt->srr)
>  		return 0;
>  
> -	if (skb->pkt_type != PACKET_HOST)
> +	if (skb->pkt_type != PACKET_HOST || !rt)
>                 return -EINVAL;
>  	if (rt->rt_type == RTN_UNICAST) {
>  		if (!opt->is_strictroute)
> 

As your patch does we don't treat an skb without rt as error
on bridge/netfilter context.
So, I think returning 0 would be better off.
But thinking of ip_options_rcv_srr() is called from another context again
adding an extra check in br_parse_ip_options() is safer ?

diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index f3bc322..10ac127 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -263,7 +263,7 @@ static int br_parse_ip_options(struct sk_buff *skb)
 		if (in_dev && !IN_DEV_SOURCE_ROUTE(in_dev))
 			goto drop;
 
-		if (ip_options_rcv_srr(skb))
+		if (skb_rtable(skb) && ip_options_rcv_srr(skb))
 			goto drop;
 	}
 
Thanks.
