From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCHv2 net 1/3] sctp: hold transport instead of assoc in
 sctp_diag
Date: Mon, 31 Oct 2016 18:14:18 -0200
Message-ID: <20161031201418.GC8514@localhost.localdomain>
References: <cover.1477916928.git.lucien.xin@gmail.com>
 <a58ed3a60643e38876a12ed9193e60f7b38cba4d.1477916928.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
        davem@davemloft.net, Vlad Yasevich <vyasevich@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52070 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S946289AbcJaUOV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 31 Oct 2016 16:14:21 -0400
Content-Disposition: inline
In-Reply-To: <a58ed3a60643e38876a12ed9193e60f7b38cba4d.1477916928.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 31, 2016 at 08:32:31PM +0800, Xin Long wrote:
> In sctp_transport_lookup_process(), Commit 1cceda784980 ("sctp: fix
> the issue sctp_diag uses lock_sock in rcu_read_lock") moved cb() out
> of rcu lock, but it put transport and hold assoc instead, and ignore
> that cb() still uses transport. It may cause a use-after-free issue.
> 
> This patch is to hold transport instead of assoc there.
> 
> Fixes: 1cceda784980 ("sctp: fix the issue sctp_diag uses lock_sock in rcu_read_lock")
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Acked-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

> ---
>  net/sctp/socket.c | 5 +----
>  1 file changed, 1 insertion(+), 4 deletions(-)
> 
> diff --git a/net/sctp/socket.c b/net/sctp/socket.c
> index 9fbb6fe..71b75f9 100644
> --- a/net/sctp/socket.c
> +++ b/net/sctp/socket.c
> @@ -4480,12 +4480,9 @@ int sctp_transport_lookup_process(int (*cb)(struct sctp_transport *, void *),
>  	if (!transport || !sctp_transport_hold(transport))
>  		goto out;
>  
> -	sctp_association_hold(transport->asoc);
> -	sctp_transport_put(transport);
> -
>  	rcu_read_unlock();
>  	err = cb(transport, p);
> -	sctp_association_put(transport->asoc);
> +	sctp_transport_put(transport);
>  
>  out:
>  	return err;
> -- 
> 2.1.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
