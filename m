From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH 1/5 net-next] inet: replace ->bind_conflict with
 ->rcv_saddr_equal
Date: Wed, 21 Dec 2016 16:06:54 +0100
Message-ID: <1482332814.2260.6.camel@stressinduktion.org>
References: <1482264424-15439-1-git-send-email-jbacik@fb.com>
         <1482264424-15439-2-git-send-email-jbacik@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Josef Bacik <jbacik@fb.com>, davem@davemloft.net,
        kraigatgoog@gmail.com, eric.dumazet@gmail.com, tom@herbertland.com,
        netdev@vger.kernel.org, kernel-team@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:46003 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S934293AbcLUPHB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2016 10:07:01 -0500
In-Reply-To: <1482264424-15439-2-git-send-email-jbacik@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-12-20 at 15:07 -0500, Josef Bacik wrote:
> The only difference between inet6_csk_bind_conflict and inet_csk_bind_conflict
> is how they check the rcv_saddr.  Since we want to be able to check the saddr in
> other places just drop the protocol specific ->bind_conflict and replace it with
> ->rcv_saddr_equal, then make inet_csk_bind_conflict the one true bind conflict
> function.
> 
> Signed-off-by: Josef Bacik <jbacik@fb.com>
> 



> ---
>  include/net/inet6_connection_sock.h |  5 -----
>  include/net/inet_connection_sock.h  |  9 +++------
>  net/dccp/ipv4.c                     |  3 ++-
>  net/dccp/ipv6.c                     |  2 +-
>  net/ipv4/inet_connection_sock.c     | 22 +++++++-------------
>  net/ipv4/tcp_ipv4.c                 |  3 ++-
>  net/ipv4/udp.c                      |  1 +
>  net/ipv6/inet6_connection_sock.c    | 40 -------------------------------------
>  net/ipv6/tcp_ipv6.c                 |  4 ++--
>  9 files changed, 18 insertions(+), 71 deletions(-)
> 
> diff --git a/include/net/inet6_connection_sock.h b/include/net/inet6_connection_sock.h
> index 3212b39..8ec87b6 100644
> --- a/include/net/inet6_connection_sock.h
> +++ b/include/net/inet6_connection_sock.h
> @@ -15,16 +15,11 @@
>  
>  #include <linux/types.h>
>  
> -struct inet_bind_bucket;
>  struct request_sock;
>  struct sk_buff;
>  struct sock;
>  struct sockaddr;
>  
> -int inet6_csk_bind_conflict(const struct sock *sk,
> -			    const struct inet_bind_bucket *tb, bool relax,
> -			    bool soreuseport_ok);
> -
>  struct dst_entry *inet6_csk_route_req(const struct sock *sk, struct flowi6 *fl6,
>  				      const struct request_sock *req, u8 proto);
>  
> diff --git a/include/net/inet_connection_sock.h b/include/net/inet_connection_sock.h
> index ec0479a..9cd43c5 100644
> --- a/include/net/inet_connection_sock.h
> +++ b/include/net/inet_connection_sock.h
> @@ -62,9 +62,9 @@ struct inet_connection_sock_af_ops {
>  				char __user *optval, int __user *optlen);
>  #endif
>  	void	    (*addr2sockaddr)(struct sock *sk, struct sockaddr *);
> -	int	    (*bind_conflict)(const struct sock *sk,
> -				     const struct inet_bind_bucket *tb,
> -				     bool relax, bool soreuseport_ok);
> +	int         (*rcv_saddr_equal)(const struct sock *sk1,
> +				       const struct sock *sk2,
> +				       bool match_wildcard);
>  	void	    (*mtu_reduced)(struct sock *sk);
>  };
>  
> 

The patch looks as a nice code cleanup already!

Have you looked if we can simply have one rcv_saddr_equal for both ipv4
and ipv6 that e.g. uses sk->sk_family instead of function pointers?
This could give us even more possibilities to remove some indirect
functions calls and thus might relieve some cycles?

Thanks,
Hannes
