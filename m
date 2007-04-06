From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 3/4] Add mapped address type inline
Date: Fri, 06 Apr 2007 12:47:56 +0900 (JST)
Message-ID: <20070406.124756.32711377.yoshfuji@linux-ipv6.org>
References: <11758281864173-git-send-email-brian.haley@hp.com>
	<151538c13022864224f5ff440e1147f884abb492.1175794415.git.brian.haley@hp.com>
	<4615BCB5.2020609@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	lksctp-developers@lists.sourceforge.net
To: brian.haley@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:40424 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753225AbXDFDrD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Apr 2007 23:47:03 -0400
In-Reply-To: <4615BCB5.2020609@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <4615BCB5.2020609@hp.com> (at Thu, 05 Apr 2007 23:21:25 -0400), Brian Haley <brian.haley@hp.com> says:

> Add mapped address type inline to avoid calls to ipv6_addr_type().
> 
> Signed-off-by: Brian Haley <brian.haley@hp.com>
> ---
>   include/net/ipv6.h       |    6 ++++++
>   net/ipv6/ip6_flowlabel.c |    6 ++----
>   net/ipv6/ipv6_sockglue.c |    2 +-
>   net/ipv6/tcp_ipv6.c      |   13 +++++--------
>   net/ipv6/udp.c           |    2 +-
>   net/sctp/ipv6.c          |    4 ++--
>   6 files changed, 17 insertions(+), 16 deletions(-)
> 
> diff --git a/include/net/ipv6.h b/include/net/ipv6.h
> index a888b0e..f3e13db 100644
> --- a/include/net/ipv6.h
> +++ b/include/net/ipv6.h
> @@ -444,6 +444,12 @@ static inline int ipv6_addr_type_multicast(const struct in6_addr *a)
>   	return ((a->s6_addr32[0] & htonl(0xFF000000)) == htonl(0xFF000000));
>   }
> 
> +static inline int ipv6_addr_type_mapped(const struct in6_addr *a)
> +{
> +	return ((a->s6_addr32[0] | a->s6_addr32[1]) == 0 &&
> +		 a->s6_addr32[2] == htonl(0x0000ffff));
> +}
> +
>   /*
>    *	Prototypes exported by ipv6
>    */

I prefer ipv6_addr_v4mapped() to align with ipv6_addr_any()
(and IN6_IS_ADDR_V4MAPPED() macro in RFC3493).

> diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
> index 537978c..a47d23d 100644
> --- a/net/ipv6/tcp_ipv6.c
> +++ b/net/ipv6/tcp_ipv6.c
> @@ -132,7 +132,6 @@ static int tcp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
>   	struct in6_addr *saddr = NULL, *final_p = NULL, final;
>   	struct flowi fl;
>   	struct dst_entry *dst;
> -	int addr_type;
>   	int err;
> 
>   	if (addr_len < SIN6_LEN_RFC2133)
> @@ -163,12 +162,10 @@ static int tcp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
>   	if(ipv6_addr_any(&usin->sin6_addr))
>   		usin->sin6_addr.s6_addr[15] = 0x1;
> 
> -	addr_type = ipv6_addr_type(&usin->sin6_addr);
> -
> -	if(addr_type & IPV6_ADDR_MULTICAST)
> +	if (ipv6_addr_type_multicast(&usin->sin6_addr))
>   		return -ENETUNREACH;
> 
> -	if (addr_type&IPV6_ADDR_LINKLOCAL) {
> +	if (ipv6_addr_scope_linklocal(&usin->sin6_addr)) {
>   		if (addr_len >= sizeof(struct sockaddr_in6) &&
>   		    usin->sin6_scope_id) {
>   			/* If interface is set while binding, indices
> @@ -200,7 +197,7 @@ static int tcp_v6_connect(struct sock *sk, struct sockaddr *uaddr,
>   	 *	TCP over IPv4
>   	 */

different commit?

--yoshfuji
