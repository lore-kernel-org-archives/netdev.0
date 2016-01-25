From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: net/sctp: out-of-bounds access in sctp_add_bind_addr
Date: Mon, 25 Jan 2016 12:29:02 -0500
Message-ID: <20160125172902.GD29690@hmsreliant.think-freely.org>
References: <20160125160534.GC29690@hmsreliant.think-freely.org>
 <f5e86af253fac52b6f78448e9aaf68742a1ec7c5.1453738452.git.marcelo.leitner@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dvyukov@google.com, Vlad Yasevich <vyasevich@gmail.com>,
	netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	linux-kernel@vger.kernel.org, davem@davemloft.net,
	syzkaller@googlegroups.com, kcc@google.com, glider@google.com,
	sasha.levin@oracle.com, edumazet@google.com
To: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <f5e86af253fac52b6f78448e9aaf68742a1ec7c5.1453738452.git.marcelo.leitner@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 25, 2016 at 02:16:00PM -0200, Marcelo Ricardo Leitner wrote:
> Something like this. Builds, but UNTESTED.
> Uses union sizeof where possible but when reading from a buffer that is
> not aligned to it, like that user supplied one. Then relies on
> af->sockaddr_len
> 
> --8<--
> 
> ---
>  include/net/sctp/structs.h |  2 +-
>  net/sctp/bind_addr.c       | 14 ++++++++------
>  net/sctp/protocol.c        |  1 +
>  net/sctp/sm_make_chunk.c   |  2 +-
>  net/sctp/socket.c          |  5 +++--
>  5 files changed, 14 insertions(+), 10 deletions(-)
> 
> diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
> index 20e72129be1ce0063eeafcbaadcee1f37e0c614c..97ba8a8c466f5c50bdc87ec578792e56553baa91 100644
> --- a/include/net/sctp/structs.h
> +++ b/include/net/sctp/structs.h
> @@ -1099,7 +1099,7 @@ int sctp_bind_addr_dup(struct sctp_bind_addr *dest,
>  			const struct sctp_bind_addr *src,
>  			gfp_t gfp);
>  int sctp_add_bind_addr(struct sctp_bind_addr *, union sctp_addr *,
> -		       __u8 addr_state, gfp_t gfp);
> +		       int new_size, __u8 addr_state, gfp_t gfp);
>  int sctp_del_bind_addr(struct sctp_bind_addr *, union sctp_addr *);
>  int sctp_bind_addr_match(struct sctp_bind_addr *, const union sctp_addr *,
>  			 struct sctp_sock *);
> diff --git a/net/sctp/bind_addr.c b/net/sctp/bind_addr.c
> index 871cdf9567e6bc9c13cb1077dc6866a67e6e4367..80129d10a0af9c33e7348b79d010b9e5e948e584 100644
> --- a/net/sctp/bind_addr.c
> +++ b/net/sctp/bind_addr.c
> @@ -111,7 +111,8 @@ int sctp_bind_addr_dup(struct sctp_bind_addr *dest,
>  	dest->port = src->port;
>  
>  	list_for_each_entry(addr, &src->address_list, list) {
> -		error = sctp_add_bind_addr(dest, &addr->a, 1, gfp);
> +		error = sctp_add_bind_addr(dest, &addr->a, sizeof(addr->a),
> +					   1, gfp);
>  		if (error < 0)
>  			break;
>  	}
> @@ -150,7 +151,7 @@ void sctp_bind_addr_free(struct sctp_bind_addr *bp)
>  
>  /* Add an address to the bind address list in the SCTP_bind_addr structure. */
>  int sctp_add_bind_addr(struct sctp_bind_addr *bp, union sctp_addr *new,
> -		       __u8 addr_state, gfp_t gfp)
> +		       int new_size, __u8 addr_state, gfp_t gfp)
>  {
>  	struct sctp_sockaddr_entry *addr;
>  
> @@ -159,7 +160,7 @@ int sctp_add_bind_addr(struct sctp_bind_addr *bp, union sctp_addr *new,
>  	if (!addr)
>  		return -ENOMEM;
>  
> -	memcpy(&addr->a, new, sizeof(*new));
> +	memcpy(&addr->a, new, min_t(size_t, sizeof(*new), new_size));
>  
>  	/* Fix up the port if it has not yet been set.
>  	 * Both v4 and v6 have the port at the same offset.
> @@ -291,7 +292,8 @@ int sctp_raw_to_bind_addrs(struct sctp_bind_addr *bp, __u8 *raw_addr_list,
>  		}
>  
>  		af->from_addr_param(&addr, rawaddr, htons(port), 0);
> -		retval = sctp_add_bind_addr(bp, &addr, SCTP_ADDR_SRC, gfp);
> +		retval = sctp_add_bind_addr(bp, &addr, sizeof(addr),
> +					    SCTP_ADDR_SRC, gfp);
>  		if (retval) {
>  			/* Can't finish building the list, clean up. */
>  			sctp_bind_addr_clean(bp);
> @@ -453,8 +455,8 @@ static int sctp_copy_one_addr(struct net *net, struct sctp_bind_addr *dest,
>  		    (((AF_INET6 == addr->sa.sa_family) &&
>  		      (flags & SCTP_ADDR6_ALLOWED) &&
>  		      (flags & SCTP_ADDR6_PEERSUPP))))
> -			error = sctp_add_bind_addr(dest, addr, SCTP_ADDR_SRC,
> -						    gfp);
> +			error = sctp_add_bind_addr(dest, addr, sizeof(addr),
> +						   SCTP_ADDR_SRC, gfp);
>  	}
>  
>  	return error;
> diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
> index ab0d538a74ed593571cfaef02cd1bb7ce872abe6..2fb609008311f51344704d82f21b4de9f08253da 100644
> --- a/net/sctp/protocol.c
> +++ b/net/sctp/protocol.c
> @@ -214,6 +214,7 @@ int sctp_copy_local_addr_list(struct net *net, struct sctp_bind_addr *bp,
>  			      (copy_flags & SCTP_ADDR6_ALLOWED) &&
>  			      (copy_flags & SCTP_ADDR6_PEERSUPP)))) {
>  				error = sctp_add_bind_addr(bp, &addr->a,
> +						    sizeof(addr->a),
>  						    SCTP_ADDR_SRC, GFP_ATOMIC);
>  				if (error)
>  					goto end_copy;
> diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
> index 5d6a03fad3789a12290f5f14c5a7efa69c98f41a..1b91e9760fe514db6d89457e1d5da9e02800745e 100644
> --- a/net/sctp/sm_make_chunk.c
> +++ b/net/sctp/sm_make_chunk.c
> @@ -1830,7 +1830,7 @@ no_hmac:
>  	/* Also, add the destination address. */
>  	if (list_empty(&retval->base.bind_addr.address_list)) {
>  		sctp_add_bind_addr(&retval->base.bind_addr, &chunk->dest,
> -				SCTP_ADDR_SRC, GFP_ATOMIC);
> +				   sizeof(chunk->dest), SCTP_ADDR_SRC, GFP_ATOMIC);
>  	}
>  
>  	retval->next_tsn = retval->c.initial_tsn;
> diff --git a/net/sctp/socket.c b/net/sctp/socket.c
> index 9bb80ec4c08ff06f6e629078c5a926c3def3ce23..3765f1fd06aac253ec5ee8e8bd18fffefda64d62 100644
> --- a/net/sctp/socket.c
> +++ b/net/sctp/socket.c
> @@ -386,7 +386,8 @@ static int sctp_do_bind(struct sock *sk, union sctp_addr *addr, int len)
>  	/* Add the address to the bind address list.
>  	 * Use GFP_ATOMIC since BHs will be disabled.
>  	 */
> -	ret = sctp_add_bind_addr(bp, addr, SCTP_ADDR_SRC, GFP_ATOMIC);
> +	ret = sctp_add_bind_addr(bp, addr, af->sockaddr_len,
> +				 SCTP_ADDR_SRC, GFP_ATOMIC);
>  
>  	/* Copy back into socket for getsockname() use. */
>  	if (!ret) {
> @@ -576,7 +577,7 @@ static int sctp_send_asconf_add_ip(struct sock		*sk,
>  			addr = addr_buf;
>  			af = sctp_get_af_specific(addr->v4.sin_family);
>  			memcpy(&saveaddr, addr, af->sockaddr_len);
> -			retval = sctp_add_bind_addr(bp, &saveaddr,
> +			retval = sctp_add_bind_addr(bp, &saveaddr, sizeof(saveaddr),
>  						    SCTP_ADDR_NEW, GFP_ATOMIC);
>  			addr_buf += af->sockaddr_len;
>  		}
> -- 
> 2.5.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
Agreed, that looks correct
Neil
