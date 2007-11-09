From: "Arnaldo Carvalho de Melo" <acme@redhat.com>
Subject: Re: [PATCH][PACKET] Use existing sock refcnt debugging
	infrastructure
Date: Fri, 9 Nov 2007 12:37:42 -0200
Message-ID: <20071109143742.GC12019@ghostprotocols.net>
References: <4734631D.6080807@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Arnaldo Carvalho de Melo <acme@redhat.com>,
	Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:50584 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758595AbXKIOh4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Nov 2007 09:37:56 -0500
Content-Disposition: inline
In-Reply-To: <4734631D.6080807@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Em Fri, Nov 09, 2007 at 04:39:41PM +0300, Pavel Emelyanov escreveu:
> The packet_socks_nr variable is used purely for debugging
> the number of sockets.
> 
> As Arnaldo pointed out, there's already an infrastructure
> for this purposes, so switch to using it.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>
 
> ---
> 
> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
> index 4cb2dfb..36331a5 100644
> --- a/net/packet/af_packet.c
> +++ b/net/packet/af_packet.c
> @@ -139,9 +139,6 @@ dev->hard_header == NULL (ll header is added by device, we cannot control it)
>  static HLIST_HEAD(packet_sklist);
>  static DEFINE_RWLOCK(packet_sklist_lock);
>  
> -static atomic_t packet_socks_nr;
> -
> -
>  /* Private packet socket structures. */
>  
>  struct packet_mclist
> @@ -236,10 +233,7 @@ static void packet_sock_destruct(struct sock *sk)
>  		return;
>  	}
>  
> -	atomic_dec(&packet_socks_nr);
> -#ifdef PACKET_REFCNT_DEBUG
> -	printk(KERN_DEBUG "PACKET socket %p is free, %d are alive\n", sk, atomic_read(&packet_socks_nr));
> -#endif
> +	sk_refcnt_debug_dec(sk);
>  }
>  
>  
> @@ -849,6 +843,7 @@ static int packet_release(struct socket *sock)
>  	/* Purge queues */
>  
>  	skb_queue_purge(&sk->sk_receive_queue);
> +	sk_refcnt_debug_release(sk);
>  
>  	sock_put(sk);
>  	return 0;
> @@ -1010,7 +1005,7 @@ static int packet_create(struct net *net, struct socket *sock, int protocol)
>  	po->num = proto;
>  
>  	sk->sk_destruct = packet_sock_destruct;
> -	atomic_inc(&packet_socks_nr);
> +	sk_refcnt_debug_inc(sk);
>  
>  	/*
>  	 *	Attach a protocol block
> -- 
> 1.5.3.4
> 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
