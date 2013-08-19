From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [Patch net-next v3 8/9] sctp: use generic union inet_addr
Date: Mon, 19 Aug 2013 11:05:31 -0400
Message-ID: <5212343B.3090409@gmail.com>
References: <1376907278-26377-1-git-send-email-amwang@redhat.com> <1376907278-26377-9-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Neil Horman <nhorman@tuxdriver.com>, linux-sctp@vger.kernel.org
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gh0-f174.google.com ([209.85.160.174]:41703 "EHLO
	mail-gh0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750985Ab3HSPFf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Aug 2013 11:05:35 -0400
In-Reply-To: <1376907278-26377-9-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/19/2013 06:14 AM, Cong Wang wrote:
> From: Cong Wang <amwang@redhat.com>
>
> sctp has its own union sctp_addr which is nearly same
> with the generic union inet_addr, so just convert it
> to the generic one.
>
> Sorry for the big patch, it is not easy to split it. Most
> of the patch simply does s/union sctp_addr/union inet_addr/
> and some adjustments for the fields.
>
> The address family specific ops, ->cmp_addr(), ->is_any() etc.,
> are removed, since we have generic helpers, they are unnecessary.

You are not actually removing cmp_addr(), so that's invalid.
For the usage of ->is_any, see below.

> diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
> index 422db6c..8dfaa39 100644
> --- a/include/net/sctp/structs.h
> +++ b/include/net/sctp/structs.h
> @@ -1117,10 +1105,10 @@ union sctp_params sctp_bind_addrs_to_raw(const struct sctp_bind_addr *bp,
>   int sctp_raw_to_bind_addrs(struct sctp_bind_addr *bp, __u8 *raw, int len,
>   			   __u16 port, gfp_t gfp);
>
> -sctp_scope_t sctp_scope(const union sctp_addr *);
> -int sctp_in_scope(struct net *net, const union sctp_addr *addr, const sctp_scope_t scope);
> -int sctp_is_any(struct sock *sk, const union sctp_addr *addr);
> -int sctp_addr_is_valid(const union sctp_addr *addr);
> +sctp_scope_t sctp_scope(const union inet_addr *);
> +int sctp_in_scope(struct net *net, const union inet_addr *addr, const sctp_scope_t scope);
> +int sctp_is_any(struct sock *sk, const union inet_addr *addr);

You are keeping the prototype and remove the implementation of 
sctp_is_any later, but that's ok since I don't think the implementation
should be removed.  However, this points out that this should probably
be a separate patch (first do straight conversion to new data structure,
then fix up usage and delete unneeded functions).

> +int sctp_addr_is_valid(const union inet_addr *addr);
>   int sctp_is_ep_boundall(struct sock *sk);
>
>
> diff --git a/net/sctp/bind_addr.c b/net/sctp/bind_addr.c
> index 077bb07..03d8f85 100644
> --- a/net/sctp/bind_addr.c
> +++ b/net/sctp/bind_addr.c
> @@ -47,7 +47,7 @@
> @@ -436,13 +436,13 @@ union sctp_addr *sctp_find_unmatch_addr(struct sctp_bind_addr	*bp,
>
>   /* Copy out addresses from the global local address list. */
>   static int sctp_copy_one_addr(struct net *net, struct sctp_bind_addr *dest,
> -			      union sctp_addr *addr,
> +			      union inet_addr *addr,
>   			      sctp_scope_t scope, gfp_t gfp,
>   			      int flags)
>   {
>   	int error = 0;
>
> -	if (sctp_is_any(NULL, addr)) {
> +	if (inet_addr_any(addr)) {
>   		error = sctp_copy_local_addr_list(net, dest, scope, gfp, flags);
>   	} else if (sctp_in_scope(net, addr, scope)) {
>   		/* Now that the address is in scope, check to see if
> @@ -461,27 +461,8 @@ static int sctp_copy_one_addr(struct net *net, struct sctp_bind_addr *dest,
>   	return error;
>   }
>
> -/* Is this a wildcard address?  */
> -int sctp_is_any(struct sock *sk, const union sctp_addr *addr)
> -{
> -	unsigned short fam = 0;
> -	struct sctp_af *af;
> -
> -	/* Try to get the right address family */
> -	if (addr->sa.sa_family != AF_UNSPEC)
> -		fam = addr->sa.sa_family;
> -	else if (sk)
> -		fam = sk->sk_family;
> -
> -	af = sctp_get_af_specific(fam);
> -	if (!af)
> -		return 0;
> -
> -	return af->is_any(addr);
> -}
> -

I don't think you can remove this implentation.  It is would introduce
a lot of regressions for code that does:
	struct sockaddr_in sin;
	memset(&sin, 0, sizeof(sin));

	/* Do some setsockopt... with sin */

While I do agree that this is a bit sloppy (and I've made that argument 
to all the bug submitters), this type of bug has been reported for a 
long time and sctp_is_any() was finally changed to fix it once and for
all.  You are un-fixing it...

>   /* Is 'addr' valid for 'scope'?  */
> -int sctp_in_scope(struct net *net, const union sctp_addr *addr, sctp_scope_t scope)
> +int sctp_in_scope(struct net *net, const union inet_addr *addr, sctp_scope_t scope)
>   {
>   	sctp_scope_t addr_scope = sctp_scope(addr);
>
> @@ -530,7 +511,7 @@ int sctp_is_ep_boundall(struct sock *sk)
>   	if (sctp_list_single_entry(&bp->address_list)) {
>   		addr = list_entry(bp->address_list.next,
>   				  struct sctp_sockaddr_entry, list);
> -		if (sctp_is_any(sk, &addr->a))
> +		if (inet_addr_any(&addr->a))
>   			return 1;
>   	}
>   	return 0;
> diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
> index da613ce..2e1262b 100644
> --- a/net/sctp/ipv6.c
> +++ b/net/sctp/ipv6.c
>
>   /* Compare addresses exactly.
>    * v4-mapped-v6 is also in consideration.
>    */
> -static int sctp_v6_cmp_addr(const union sctp_addr *addr1,
> -			    const union sctp_addr *addr2)
> +static bool sctp_v6_cmp_addr(const union inet_addr *addr1,
> +			     const union inet_addr *addr2)
>   {
>   	if (addr1->sa.sa_family != addr2->sa.sa_family) {
>   		if (addr1->sa.sa_family == AF_INET &&
>   		    addr2->sa.sa_family == AF_INET6 &&
> -		    ipv6_addr_v4mapped(&addr2->v6.sin6_addr)) {
> -			if (addr2->v6.sin6_port == addr1->v4.sin_port &&
> -			    addr2->v6.sin6_addr.s6_addr32[3] ==
> -			    addr1->v4.sin_addr.s_addr)
> +		    ipv6_addr_v4mapped(&addr2->sin6.sin6_addr)) {
> +			if (addr2->sin6.sin6_port == addr1->sin.sin_port &&
> +			    addr2->sin6.sin6_addr.s6_addr32[3] ==
> +			    addr1->sin.sin_addr.s_addr)
>   				return 1;
>   		}
>   		if (addr2->sa.sa_family == AF_INET &&
>   		    addr1->sa.sa_family == AF_INET6 &&
> -		    ipv6_addr_v4mapped(&addr1->v6.sin6_addr)) {
> -			if (addr1->v6.sin6_port == addr2->v4.sin_port &&
> -			    addr1->v6.sin6_addr.s6_addr32[3] ==
> -			    addr2->v4.sin_addr.s_addr)
> +		    ipv6_addr_v4mapped(&addr1->sin6.sin6_addr)) {
> +			if (addr1->sin6.sin6_port == addr2->sin.sin_port &&
> +			    addr1->sin6.sin6_addr.s6_addr32[3] ==
> +			    addr2->sin.sin_addr.s_addr)
>   				return 1;
>   		}
>   		return 0;
>   	}
> -	if (!ipv6_addr_equal(&addr1->v6.sin6_addr, &addr2->v6.sin6_addr))
> -		return 0;
> -	/* If this is a linklocal address, compare the scope_id. */
> -	if (ipv6_addr_type(&addr1->v6.sin6_addr) & IPV6_ADDR_LINKLOCAL) {
> -		if (addr1->v6.sin6_scope_id && addr2->v6.sin6_scope_id &&
> -		    (addr1->v6.sin6_scope_id != addr2->v6.sin6_scope_id)) {
> -			return 0;
> -		}
> -	}
> -
> -	return 1;
> -}
>
> -/* Initialize addr struct to INADDR_ANY. */
> -static void sctp_v6_inaddr_any(union sctp_addr *addr, __be16 port)
> -{
> -	memset(addr, 0x00, sizeof(union sctp_addr));
> -	addr->v6.sin6_family = AF_INET6;
> -	addr->v6.sin6_port = port;
> -}
> -
> -/* Is this a wildcard address? */
> -static int sctp_v6_is_any(const union sctp_addr *addr)
> -{
> -	return ipv6_addr_any(&addr->v6.sin6_addr);
> +	return inet_addr_equal(addr1, addr2);

You've dropped the scope_id comparision which inet_addr_equal does not 
seem to do.   As far as I can see from this series,  inet_addr_equal()
just calls ipv6_addr_equal.


-vlad
