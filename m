From: Vladislav Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH] SCTP: fix race between sctp_bind_addr_free() and sctp_bind_addr_conflict()
Date: Wed, 18 May 2011 08:33:19 -0400
Message-ID: <4DD3BC8F.9050802@hp.com>
References: <BANLkTikeWzuE-384uT6RhZR6Wn=DBK+CNQ@mail.gmail.com>	 <1305704885.2983.4.camel@edumazet-laptop>	 <BANLkTik75iqfgvWGKLJYu6E7mheOwOZX+A@mail.gmail.com> <1305707358.2983.14.camel@edumazet-laptop> <4DD38B30.9090601@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Jacek Luczak <difrost.kernel@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Wei Yongjun <yjwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:42328 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932738Ab1ERMdY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2011 08:33:24 -0400
In-Reply-To: <4DD38B30.9090601@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/18/2011 05:02 AM, Wei Yongjun wrote:
 
> fix the race between sctp_bind_addr_free() and sctp_bind_addr_conflict(), maybe you just
> need to remove the socket from the port hash before empty the bind address list.
> some thing like this, not test.
> 
> diff --git a/net/sctp/endpointola.c b/net/sctp/endpointola.c
> index c8cc24e..924d846 100644
> --- a/net/sctp/endpointola.c
> +++ b/net/sctp/endpointola.c
> @@ -268,12 +268,13 @@ static void sctp_endpoint_destroy(struct sctp_endpoint *ep)
>  
>  	/* Cleanup. */
>  	sctp_inq_free(&ep->base.inqueue);
> -	sctp_bind_addr_free(&ep->base.bind_addr);
>  
>  	/* Remove and free the port */
>  	if (sctp_sk(ep->base.sk)->bind_hash)
>  		sctp_put_port(ep->base.sk);
>  
> +	sctp_bind_addr_free(&ep->base.bind_addr);
> +
>  	/* Give up our hold on the sock. */
>  	if (ep->base.sk)
>  		sock_put(ep->base.sk);
> 
> 

I am not sure that this will guarantee avoidance of this crash, even though it is the right
thing to do in general.

We simply make the race condition much smaller and much harder to hit.  Potentially, one
cpu may be doing lookup of the socket while the other is doing the destroy.  If the lookup cpu
finds the socket just as this code removes the socket from the hash, we still have this potential
race condition.

I agree with Eric, rcu_read_lock() is not strictly necessary, as what we are really after is call_rcu()
based destruction.  We need to delay memory destruction for the rcu grace period.

Thinking a little more about how bind_addr_clean() is used, it would probably benefit from getting
converted to call_rcu().  That function is used as local clean-up in case of malloc failure; however,
that doesn't preclude a potential race.  The fact that we do not have this race simply points out that
we don't have any kind of parallel lookup that can hit it (and the code confirms it).  This doesn't
mean that we wouldn't have it in the future.

-vlad
