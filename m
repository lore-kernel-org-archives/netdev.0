From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net] net: ipv6: Fix ping to link-local addresses.
Date: Mon, 8 Aug 2016 16:26:46 +0200
Message-ID: <7ff321ea-87f7-4a59-0e1e-52962d4e9be6@stressinduktion.org>
References: <1470642127-574-1-git-send-email-lorenzo@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: ek@google.com, davem@davemloft.net,
	hideaki.yoshifuji@miraclelinux.com
To: Lorenzo Colitti <lorenzo@google.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:43680 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751028AbcHHO0t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2016 10:26:49 -0400
In-Reply-To: <1470642127-574-1-git-send-email-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08.08.2016 09:42, Lorenzo Colitti wrote:
> ping_v6_sendmsg never sets flowi6_oif, so it is not possible to
> ping an IPv6 address on a different interface. Instead, it sets
> flowi6_iif, which is incorrect but harmless. Also, it returns an
> error if a passed-in scope ID doesn't match sk_bound_dev_if.
> 
> Get rid of the error, stop setting flowi6_iif, and support
> various ways of setting oif in the same priority order used by
> udpv6_sendmsg.
> 
> Tested: https://android-review.googlesource.com/#/c/254470/
> Signed-off-by: Lorenzo Colitti <lorenzo@google.com>
> ---
>  net/ipv6/ping.c | 29 +++++++++++++++--------------
>  1 file changed, 15 insertions(+), 14 deletions(-)
> 
> diff --git a/net/ipv6/ping.c b/net/ipv6/ping.c
> index fed40d1..eabf1ea 100644
> --- a/net/ipv6/ping.c
> +++ b/net/ipv6/ping.c
> @@ -55,7 +55,7 @@ static int ping_v6_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
>  	struct icmp6hdr user_icmph;
>  	int addr_type;
>  	struct in6_addr *daddr;
> -	int iif = 0;
> +	int oif = 0;
>  	struct flowi6 fl6;
>  	int err;
>  	struct dst_entry *dst;
> @@ -78,23 +78,28 @@ static int ping_v6_sendmsg(struct sock *sk, struct msghdr *msg, size_t len)
>  		if (u->sin6_family != AF_INET6) {
>  			return -EAFNOSUPPORT;
>  		}
> -		if (sk->sk_bound_dev_if &&
> -		    sk->sk_bound_dev_if != u->sin6_scope_id) {
> -			return -EINVAL;
> -		}

Hmm, sk->sk_bound_dev_if always has highest prio for the selection of
the output interface. Thus this code made sense to me.

Bye,
Hannes
