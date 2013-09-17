From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net] xfrm: Guard IPsec anti replay window against replay
 bitmap
Date: Tue, 17 Sep 2013 08:56:47 +0200
Message-ID: <20130917065647.GO7660@secunet.com>
References: <1379399165-8955-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:51882 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751420Ab3IQG4t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Sep 2013 02:56:49 -0400
Content-Disposition: inline
In-Reply-To: <1379399165-8955-1-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 17, 2013 at 02:26:05PM +0800, Fan Du wrote:
> 
> diff --git a/net/key/af_key.c b/net/key/af_key.c
> index 9d58537..911ef03 100644
> --- a/net/key/af_key.c
> +++ b/net/key/af_key.c
> @@ -1098,7 +1098,8 @@ static struct xfrm_state * pfkey_msg2xfrm_state(struct net *net,
>  
>  	x->id.proto = proto;
>  	x->id.spi = sa->sadb_sa_spi;
> -	x->props.replay_window = sa->sadb_sa_replay;
> +	x->props.replay_window = min_t(unsigned int, sa->sadb_sa_replay,
> +					(sizeof(x->replay.bitmap) * 8));
>  	if (sa->sadb_sa_flags & SADB_SAFLAGS_NOECN)
>  		x->props.flags |= XFRM_STATE_NOECN;
>  	if (sa->sadb_sa_flags & SADB_SAFLAGS_DECAP_DSCP)
> diff --git a/net/xfrm/xfrm_replay.c b/net/xfrm/xfrm_replay.c
> index 8dafe6d3..eeca388 100644
> --- a/net/xfrm/xfrm_replay.c
> +++ b/net/xfrm/xfrm_replay.c
> @@ -129,8 +129,7 @@ static int xfrm_replay_check(struct xfrm_state *x,
>  		return 0;
>  
>  	diff = x->replay.seq - seq;
> -	if (diff >= min_t(unsigned int, x->props.replay_window,
> -			  sizeof(x->replay.bitmap) * 8)) {
> +	if (diff >= x->props.replay_window) {

So x->props.replay_window will be valid if the state was added with the
pfkey interface, but what if the netlink interface was used? You should
also update the netlink part to always hold a valid replay window.
