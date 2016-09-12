From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCHv2 net] sctp: hold the transport before using it in
 sctp_hash_cmp
Date: Mon, 12 Sep 2016 15:45:04 -0300
Message-ID: <20160912184504.GA17689@localhost.localdomain>
References: <8e671aa0baca387f230bf8f6fc5ecbbb091866f6.1473520283.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
        davem@davemloft.net, Vlad Yasevich <vyasevich@gmail.com>,
        daniel@iogearbox.net
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57316 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751254AbcILSpI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 12 Sep 2016 14:45:08 -0400
Content-Disposition: inline
In-Reply-To: <8e671aa0baca387f230bf8f6fc5ecbbb091866f6.1473520283.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Sep 10, 2016 at 11:11:23PM +0800, Xin Long wrote:
> Since commit 4f0087812648 ("sctp: apply rhashtable api to send/recv
> path"), sctp uses transport rhashtable with .obj_cmpfn sctp_hash_cmp,
> in which it compares the members of the transport with the rhashtable
> args to check if it's the right transport.
> 
> But sctp uses the transport without holding it in sctp_hash_cmp, it can
> cause a use-after-free panic. As after it gets transport from hashtable,
> another CPU may close the sk and free the asoc. In sctp_association_free,
> it frees all the transports, meanwhile, the assoc's refcnt may be reduced
> to 0, assoc can be destroyed by sctp_association_destroy.
> 
> So after that, transport->assoc is actually an unavailable memory address
> in sctp_hash_cmp. Although sctp_hash_cmp is under rcu_read_lock, it still
> can not avoid this, as assoc is not freed by RCU.
> 
> This patch is to hold the transport before checking it's members with
> sctp_transport_hold, in which it checks the refcnt first, holds it if
> it's not 0.
> 
> Fixes: 4f0087812648 ("sctp: apply rhashtable api to send/recv path")
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Note that we cannot defer the free of the asoc too because that cause
issues with port re-use (issue already hit and fixed in the past), as
the port would be still in use during the RCU grace period.

Acked-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

> ---
>  net/sctp/input.c | 27 +++++++++++++++++----------
>  1 file changed, 17 insertions(+), 10 deletions(-)
> 
> diff --git a/net/sctp/input.c b/net/sctp/input.c
> index 69444d3..1555fb8 100644
> --- a/net/sctp/input.c
> +++ b/net/sctp/input.c
> @@ -796,27 +796,34 @@ struct sctp_hash_cmp_arg {
>  static inline int sctp_hash_cmp(struct rhashtable_compare_arg *arg,
>  				const void *ptr)
>  {
> +	struct sctp_transport *t = (struct sctp_transport *)ptr;
>  	const struct sctp_hash_cmp_arg *x = arg->key;
> -	const struct sctp_transport *t = ptr;
> -	struct sctp_association *asoc = t->asoc;
> -	const struct net *net = x->net;
> +	struct sctp_association *asoc;
> +	int err = 1;
>  
>  	if (!sctp_cmp_addr_exact(&t->ipaddr, x->paddr))
> -		return 1;
> -	if (!net_eq(sock_net(asoc->base.sk), net))
> -		return 1;
> +		return err;
> +	if (!sctp_transport_hold(t))
> +		return err;
> +
> +	asoc = t->asoc;
> +	if (!net_eq(sock_net(asoc->base.sk), x->net))
> +		goto out;
>  	if (x->ep) {
>  		if (x->ep != asoc->ep)
> -			return 1;
> +			goto out;
>  	} else {
>  		if (x->laddr->v4.sin_port != htons(asoc->base.bind_addr.port))
> -			return 1;
> +			goto out;
>  		if (!sctp_bind_addr_match(&asoc->base.bind_addr,
>  					  x->laddr, sctp_sk(asoc->base.sk)))
> -			return 1;
> +			goto out;
>  	}
>  
> -	return 0;
> +	err = 0;
> +out:
> +	sctp_transport_put(t);
> +	return err;
>  }
>  
>  static inline u32 sctp_hash_obj(const void *data, u32 len, u32 seed)
> -- 
> 2.1.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
