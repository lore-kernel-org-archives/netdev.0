From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH net] sctp: sctp_transport_lookup_process should
 rcu_read_unlock when transport is null
Date: Thu, 15 Dec 2016 14:48:27 -0200
Message-ID: <20161215164827.GC4731@localhost.localdomain>
References: <3d4f0205d5b5c64d372dffb37602f48e4a173612.1481814352.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
        davem@davemloft.net, Neil Horman <nhorman@tuxdriver.com>
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50516 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1757837AbcLOQsa (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 15 Dec 2016 11:48:30 -0500
Content-Disposition: inline
In-Reply-To: <3d4f0205d5b5c64d372dffb37602f48e4a173612.1481814352.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 15, 2016 at 11:05:52PM +0800, Xin Long wrote:
> Prior to this patch, sctp_transport_lookup_process didn't rcu_read_unlock
> when it failed to find a transport by sctp_addrs_lookup_transport.
> 
> This patch is to fix it by moving up rcu_read_unlock right before checking
> transport and also to remove the out path.
> 
> Fixes: 1cceda784980 ("sctp: fix the issue sctp_diag uses lock_sock in rcu_read_lock")
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Acked-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

> ---
>  net/sctp/socket.c | 7 +++----
>  1 file changed, 3 insertions(+), 4 deletions(-)
> 
> diff --git a/net/sctp/socket.c b/net/sctp/socket.c
> index d5f4b4a..318c678 100644
> --- a/net/sctp/socket.c
> +++ b/net/sctp/socket.c
> @@ -4472,18 +4472,17 @@ int sctp_transport_lookup_process(int (*cb)(struct sctp_transport *, void *),
>  				  const union sctp_addr *paddr, void *p)
>  {
>  	struct sctp_transport *transport;
> -	int err = -ENOENT;
> +	int err;
>  
>  	rcu_read_lock();
>  	transport = sctp_addrs_lookup_transport(net, laddr, paddr);
> +	rcu_read_unlock();
>  	if (!transport)
> -		goto out;
> +		return -ENOENT;
>  
> -	rcu_read_unlock();
>  	err = cb(transport, p);
>  	sctp_transport_put(transport);
>  
> -out:
>  	return err;
>  }
>  EXPORT_SYMBOL_GPL(sctp_transport_lookup_process);
> -- 
> 2.1.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
