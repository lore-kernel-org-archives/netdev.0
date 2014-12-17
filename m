From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net 2/2] geneve: Fix races between socket add and release.
Date: Wed, 17 Dec 2014 16:54:54 +0000
Message-ID: <20141217165454.GE28766@casper.infradead.org>
References: <1418783132-99230-1-git-send-email-jesse@nicira.com>
 <1418783132-99230-2-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Andy Zhou <azhou@nicira.com>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:56270 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750951AbaLQQyz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2014 11:54:55 -0500
Content-Disposition: inline
In-Reply-To: <1418783132-99230-2-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/16/14 at 06:25pm, Jesse Gross wrote:
> Currently, searching for a socket to add a reference to is not
> synchronized with deletion of sockets. This can result in use
> after free if there is another operation that is removing a
> socket at the same time. Solving this requires both holding the
> appropriate lock and checking the refcount to ensure that it
> has not already hit zero.
> 
> Inspired by a related (but not exactly the same) issue in the
> VXLAN driver.
> 
> Fixes: 0b5e8b8e ("net: Add Geneve tunneling protocol driver")
> CC: Andy Zhou <azhou@nicira.com>
> Signed-off-by: Jesse Gross <jesse@nicira.com>
> ---
>  net/ipv4/geneve.c | 13 +++++++------
>  1 file changed, 7 insertions(+), 6 deletions(-)
> 
> diff --git a/net/ipv4/geneve.c b/net/ipv4/geneve.c
> index 5a47188..95e47c9 100644
> --- a/net/ipv4/geneve.c
> +++ b/net/ipv4/geneve.c
> @@ -296,6 +296,7 @@ struct geneve_sock *geneve_sock_add(struct net *net, __be16 port,
>  				    geneve_rcv_t *rcv, void *data,
>  				    bool no_share, bool ipv6)
>  {
> +	struct geneve_net *gn = net_generic(net, geneve_net_id);
>  	struct geneve_sock *gs;
>  
>  	gs = geneve_socket_create(net, port, rcv, data, ipv6);
> @@ -305,15 +306,15 @@ struct geneve_sock *geneve_sock_add(struct net *net, __be16 port,
>  	if (no_share)	/* Return error if sharing is not allowed. */
>  		return ERR_PTR(-EINVAL);
>  
> +	spin_lock(&gn->sock_lock);
>  	gs = geneve_find_sock(net, port);

Perhaps remove the _rcu of the iterator in the geneve_find_sock?
Also, the kfree_rcu() seems no longer needed as all read accesses
are protected by the spinlock.

> -	if (gs) {
> -		if (gs->rcv == rcv)
> -			atomic_inc(&gs->refcnt);
> -		else
> +	if (gs && ((gs->rcv != rcv) ||
> +		   !atomic_add_unless(&gs->refcnt, 1, 0)))
>  			gs = ERR_PTR(-EBUSY);

Since you are taking gn->sock_lock in geneve_sock_release()
anyway, all accesses to refcnt could eventually be converted
to non-atomic ops.
