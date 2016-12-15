From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH net] sctp: sctp_epaddr_lookup_transport should be
 protected by rcu_read_lock
Date: Thu, 15 Dec 2016 14:43:23 -0200
Message-ID: <20161215164323.GB4731@localhost.localdomain>
References: <eb70a1f54c102c728a5572f1aa2842940fc3f5a5.1481814055.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
        davem@davemloft.net, Neil Horman <nhorman@tuxdriver.com>,
        Dmitry Vyukov <dvyukov@google.com>
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39180 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755649AbcLOQn0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 15 Dec 2016 11:43:26 -0500
Content-Disposition: inline
In-Reply-To: <eb70a1f54c102c728a5572f1aa2842940fc3f5a5.1481814055.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 15, 2016 at 11:00:55PM +0800, Xin Long wrote:
> Since commit 7fda702f9315 ("sctp: use new rhlist interface on sctp transport
> rhashtable"), sctp has changed to use rhlist_lookup to look up transport, but
> rhlist_lookup doesn't call rcu_read_lock inside, unlike rhashtable_lookup_fast.
> 
> It is called in sctp_epaddr_lookup_transport and sctp_addrs_lookup_transport.
> sctp_addrs_lookup_transport is always in the protection of rcu_read_lock(),
> as __sctp_lookup_association is called in rx path or sctp_lookup_association
> which are in the protection of rcu_read_lock() already.
> 
> But sctp_epaddr_lookup_transport is called by sctp_endpoint_lookup_assoc, it
> doesn't call rcu_read_lock, which may cause "suspicious rcu_dereference_check
> usage' in __rhashtable_lookup.
> 
> This patch is to fix it by adding rcu_read_lock in sctp_endpoint_lookup_assoc
> before calling sctp_epaddr_lookup_transport.
> 
> Fixes: 7fda702f9315 ("sctp: use new rhlist interface on sctp transport rhashtable")
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Acked-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>

> ---
>  net/sctp/endpointola.c | 5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git a/net/sctp/endpointola.c b/net/sctp/endpointola.c
> index 1f03065..410ddc1 100644
> --- a/net/sctp/endpointola.c
> +++ b/net/sctp/endpointola.c
> @@ -331,7 +331,9 @@ struct sctp_association *sctp_endpoint_lookup_assoc(
>  	 * on this endpoint.
>  	 */
>  	if (!ep->base.bind_addr.port)
> -		goto out;
> +		return NULL;
> +
> +	rcu_read_lock();
>  	t = sctp_epaddr_lookup_transport(ep, paddr);
>  	if (!t)
>  		goto out;
> @@ -339,6 +341,7 @@ struct sctp_association *sctp_endpoint_lookup_assoc(
>  	*transport = t;
>  	asoc = t->asoc;
>  out:
> +	rcu_read_unlock();
>  	return asoc;
>  }
>  
> -- 
> 2.1.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
