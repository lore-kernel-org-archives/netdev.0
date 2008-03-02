From: James Chapman <jchapman@katalix.com>
Subject: Re: [PATCH][PPPOL2TP] add missing sock_put() in	pppol2tp_tunnel_closeall()
Date: Sun, 02 Mar 2008 20:32:41 +0000
Message-ID: <47CB0EE9.9060707@katalix.com>
References: <20080225215837.GA3281@ami.dom.local> <47C402A2.8040401@katalix.com> <20080227114837.GA5795@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s36.avahost.net ([74.53.95.194]:38030 "EHLO s36.avahost.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754111AbYCBUcp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 2 Mar 2008 15:32:45 -0500
In-Reply-To: <20080227114837.GA5795@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> 
> Subject: [PPPOL2TP] add missing sock_put() in pppol2tp_tunnel_closeall()
> 
> Every skb removed from session->reorder_q needs sock_put().
> 
> 
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

Acked-by: James Chapman <jchapman@katalix.com>

>  drivers/net/pppol2tp.c |    7 ++++++-
>  1 files changed, 6 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/pppol2tp.c b/drivers/net/pppol2tp.c
> index e0b072d..ee9e2a7 100644
> --- a/drivers/net/pppol2tp.c
> +++ b/drivers/net/pppol2tp.c
> @@ -1110,6 +1110,8 @@ static void pppol2tp_tunnel_closeall(struct pppol2tp_tunnel *tunnel)
>  	for (hash = 0; hash < PPPOL2TP_HASH_SIZE; hash++) {
>  again:
>  		hlist_for_each_safe(walk, tmp, &tunnel->session_hlist[hash]) {
> +			struct sk_buff *skb;
> +
>  			session = hlist_entry(walk, struct pppol2tp_session, hlist);
>  
>  			sk = session->sock;
> @@ -1138,7 +1140,10 @@ again:
>  			/* Purge any queued data */
>  			skb_queue_purge(&sk->sk_receive_queue);
>  			skb_queue_purge(&sk->sk_write_queue);
> -			skb_queue_purge(&session->reorder_q);
> +			while ((skb = skb_dequeue(&session->reorder_q))) {
> +				kfree_skb(skb);
> +				sock_put(sk);
> +			}
>  
>  			release_sock(sk);
>  			sock_put(sk);


-- 
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

