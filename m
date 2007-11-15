From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH 2/2][INET] Move the reqsk_queue_yank_listen_sk from header
Date: Wed, 14 Nov 2007 16:12:30 -0800
Message-ID: <20071115001226.GJ2368@verge.net.au>
References: <473B3A3A.70207@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from koto.vergenet.net ([210.128.90.7]:37067 "EHLO koto.vergenet.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752697AbXKOAMi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Nov 2007 19:12:38 -0500
Content-Disposition: inline
In-Reply-To: <473B3A3A.70207@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 14, 2007 at 09:11:06PM +0300, Pavel Emelyanov wrote:
> This function is used in the net/core/request_sock.c only.
> No need in keeping it in the header file.

I feel like I am missing something here, but 
doesn't __reqsk_queue_destroy() in include/net/request_sock.h use
reqsk_queue_yank_listen_sk()?

static inline void __reqsk_queue_destroy(struct request_sock_queue
*queue)
{
        kfree(reqsk_queue_yank_listen_sk(queue));
}

> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
> 
> ---
> 
> diff --git a/include/net/request_sock.h b/include/net/request_sock.h
> index 0a954ee..e80b53f 100644
> --- a/include/net/request_sock.h
> +++ b/include/net/request_sock.h
> @@ -123,19 +123,6 @@ struct request_sock_queue {
>  
>  extern int reqsk_queue_alloc(struct request_sock_queue *queue,
>  			     unsigned int nr_table_entries);
> -
> -static inline struct listen_sock *reqsk_queue_yank_listen_sk(struct request_sock_queue *queue)
> -{
> -	struct listen_sock *lopt;
> -
> -	write_lock_bh(&queue->syn_wait_lock);
> -	lopt = queue->listen_opt;
> -	queue->listen_opt = NULL;
> -	write_unlock_bh(&queue->syn_wait_lock);
> -
> -	return lopt;
> -}
> -
>  extern void __reqsk_queue_destroy(struct request_sock_queue *queue);
>  extern void reqsk_queue_destroy(struct request_sock_queue *queue);
>  
> diff --git a/net/core/request_sock.c b/net/core/request_sock.c
> index 12a15f5..16b2ef0 100644
> --- a/net/core/request_sock.c
> +++ b/net/core/request_sock.c
> @@ -71,6 +71,19 @@ int reqsk_queue_alloc(struct request_sock_queue *queue,
>  
>  EXPORT_SYMBOL(reqsk_queue_alloc);
>  
> +static struct listen_sock *reqsk_queue_yank_listen_sk(
> +		struct request_sock_queue *queue)
> +{
> +	struct listen_sock *lopt;
> +
> +	write_lock_bh(&queue->syn_wait_lock);
> +	lopt = queue->listen_opt;
> +	queue->listen_opt = NULL;
> +	write_unlock_bh(&queue->syn_wait_lock);
> +
> +	return lopt;
> +}
> +
>  void __reqsk_queue_destroy(struct request_sock_queue *queue)
>  {
>  	struct listen_sock *lopt = reqsk_queue_yank_listen_sk(queue);
> -- 
> 1.5.3.4
> 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Horms, California Edition

