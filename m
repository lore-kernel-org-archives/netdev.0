From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] netlink: add NETLINK_BROADCAST_REPORT_ERROR socket option
Date: Mon, 16 Feb 2009 12:13:52 +0100
Message-ID: <49994A70.5000502@trash.net>
References: <20090216105200.29072.99944.stgit@Decadence>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:53979 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751331AbZBPLN4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Feb 2009 06:13:56 -0500
In-Reply-To: <20090216105200.29072.99944.stgit@Decadence>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pablo Neira Ayuso wrote:
> diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
> index 6ee69c2..29dd4fb 100644
> --- a/net/netlink/af_netlink.c
> +++ b/net/netlink/af_netlink.c
> @@ -85,6 +85,7 @@ struct netlink_sock {
>  
>  #define NETLINK_KERNEL_SOCKET	0x1
>  #define NETLINK_RECV_PKTINFO	0x2
> +#define NETLINK_BROADCAST_SEND_REPORT_ERROR	0x4

The name seems to imply send twice (send/report).

>  static inline struct netlink_sock *nlk_sk(struct sock *sk)
>  {
> @@ -994,13 +995,15 @@ static inline int do_one_broadcast(struct sock *sk,
>  	if (p->skb2 == NULL) {
>  		netlink_overrun(sk);
>  		/* Clone failed. Notify ALL listeners. */
> -		p->failure = 1;
> +		if (nlk->flags & NETLINK_BROADCAST_SEND_REPORT_ERROR)
> +			p->failure = 1;

This doesn't make sense. *Other* sockets get skipped only iff
this socket had the error-report flag set? This should be done
in a consistent manner, which means either not set the failure
flag at all and retry for all sockets, or set it for any failed
socket delivery and determine the return value based on whether
one of the skipped sockets had the error-report flag set.

>  	} else if (sk_filter(sk, p->skb2)) {
>  		kfree_skb(p->skb2);
>  		p->skb2 = NULL;
>  	} else if ((val = netlink_broadcast_deliver(sk, p->skb2)) < 0) {
>  		netlink_overrun(sk);
> -		p->delivery_failure = 1;
> +		if (nlk->flags & NETLINK_BROADCAST_SEND_REPORT_ERROR)
> +			p->delivery_failure = 1;
>  	} else {
>  		p->congested |= val;
>  		p->delivered = 1;
