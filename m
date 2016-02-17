From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net 1/3] sctp: move rcu_read_lock from
 __sctp_lookup_association to sctp_lookup_association
Date: Wed, 17 Feb 2016 11:11:04 -0500
Message-ID: <20160217161104.GA17476@hmsreliant.think-freely.org>
References: <cover.1455517541.git.lucien.xin@gmail.com>
 <c805e4a1994f53947351e8d4dd79609fd206e807.1455517541.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Vlad Yasevich <vyasevich@gmail.com>, davem@davemloft.net
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:40786 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161077AbcBQQLS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2016 11:11:18 -0500
Content-Disposition: inline
In-Reply-To: <c805e4a1994f53947351e8d4dd79609fd206e807.1455517541.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 15, 2016 at 02:28:03PM +0800, Xin Long wrote:
> __sctp_lookup_association() is only invoked by sctp_v4_err() and
> sctp_rcv(), both which run on the rx BH, and it has been protected
> by rcu_read_lock [see ip_local_deliver_finish() / ipv6_rcv()].
> 
> So we can move it to sctp_lookup_association, only let
> sctp_lookup_association use rcu_read_lock.
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Not that it was right before if this is true, but if we're using rcu in a bottom
half path, shouldn't rcu_read_lock_bh be used instead here?

Neil

> ---
>  net/sctp/input.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/sctp/input.c b/net/sctp/input.c
> index 49d2cc7..21a2d6b 100644
> --- a/net/sctp/input.c
> +++ b/net/sctp/input.c
> @@ -937,7 +937,6 @@ static struct sctp_association *__sctp_lookup_association(
>  	struct sctp_transport *t;
>  	struct sctp_association *asoc = NULL;
>  
> -	rcu_read_lock();
>  	t = sctp_addrs_lookup_transport(net, local, peer);
>  	if (!t || !sctp_transport_hold(t))
>  		goto out;
> @@ -949,7 +948,6 @@ static struct sctp_association *__sctp_lookup_association(
>  	sctp_transport_put(t);
>  
>  out:
> -	rcu_read_unlock();
>  	return asoc;
>  }
>  
> @@ -962,7 +960,9 @@ struct sctp_association *sctp_lookup_association(struct net *net,
>  {
>  	struct sctp_association *asoc;
>  
> +	rcu_read_lock();
>  	asoc = __sctp_lookup_association(net, laddr, paddr, transportp);
> +	rcu_read_unlock();
>  
>  	return asoc;
>  }
> -- 
> 2.1.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
