From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3 net-next] net: diag: support SOCK_DESTROY for UDP
 sockets
Date: Tue, 23 Aug 2016 08:55:10 -0700
Message-ID: <1471967710.14381.23.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1471964547-18098-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Lorenzo Colitti <lorenzo@google.com>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:33901 "EHLO
        mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753830AbcHWPzM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2016 11:55:12 -0400
Received: by mail-pa0-f66.google.com with SMTP id hh10so10165624pac.1
        for <netdev@vger.kernel.org>; Tue, 23 Aug 2016 08:55:12 -0700 (PDT)
In-Reply-To: <1471964547-18098-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-08-23 at 08:02 -0700, David Ahern wrote:
> This implements SOCK_DESTROY for UDP sockets similar to what was done
> for TCP with commit c1e64e298b8ca ("net: diag: Support destroying TCP
> sockets.") A process with a UDP socket targeted for destroy is awakened
> and recvmsg fails with ECONNABORTED.
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> ---
> v3
> - add missing sock_diag_check_cookie check after socket lookup per
>   Eric'c comment
> 
> v2
> - changed socket lookup to __udp{4,6}_lib_lookup
> 
>  include/net/udp.h   |  1 +
>  net/ipv4/udp.c      | 17 +++++++++++++++
>  net/ipv4/udp_diag.c | 60 +++++++++++++++++++++++++++++++++++++++++++++++++++++
>  net/ipv6/udp.c      |  1 +
>  4 files changed, 79 insertions(+)
> 
> diff --git a/include/net/udp.h b/include/net/udp.h
> index 8894d7144189..ea53a87d880f 100644
> --- a/include/net/udp.h
> +++ b/include/net/udp.h
> @@ -251,6 +251,7 @@ int udp_get_port(struct sock *sk, unsigned short snum,
>  		 int (*saddr_cmp)(const struct sock *,
>  				  const struct sock *));
>  void udp_err(struct sk_buff *, u32);
> +int udp_abort(struct sock *sk, int err);
>  int udp_sendmsg(struct sock *sk, struct msghdr *msg, size_t len);
>  int udp_push_pending_frames(struct sock *sk);
>  void udp_flush_pending_frames(struct sock *sk);
> diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
> index 8f5f7f6026f7..044058835ea8 100644
> --- a/net/ipv4/udp.c
> +++ b/net/ipv4/udp.c
> @@ -2193,6 +2193,22 @@ unsigned int udp_poll(struct file *file, struct socket *sock, poll_table *wait)
>  }
>  EXPORT_SYMBOL(udp_poll);
>  
> +int udp_abort(struct sock *sk, int err)
> +{
> +	lock_sock(sk);
> +
> +	sk->sk_err = err;
> +	sk->sk_error_report(sk);
> +	udp_disconnect(sk, 0);
> +
> +	release_sock(sk);
> +
> +	sock_put(sk);
> +
> +	return 0;
> +}
> +EXPORT_SYMBOL_GPL(udp_abort);
> +
>  struct proto udp_prot = {
>  	.name		   = "UDP",
>  	.owner		   = THIS_MODULE,
> @@ -2224,6 +2240,7 @@ struct proto udp_prot = {
>  	.compat_getsockopt = compat_udp_getsockopt,
>  #endif
>  	.clear_sk	   = sk_prot_clear_portaddr_nulls,
> +	.diag_destroy	   = udp_abort,
>  };
>  EXPORT_SYMBOL(udp_prot);
>  
> diff --git a/net/ipv4/udp_diag.c b/net/ipv4/udp_diag.c
> index 3d5ccf4b1412..63896dd766f3 100644
> --- a/net/ipv4/udp_diag.c
> +++ b/net/ipv4/udp_diag.c
> @@ -165,12 +165,69 @@ static void udp_diag_get_info(struct sock *sk, struct inet_diag_msg *r,
>  	r->idiag_wqueue = sk_wmem_alloc_get(sk);
>  }
>  
> +#ifdef CONFIG_INET_DIAG_DESTROY
> +static int __udp_diag_destroy(struct sk_buff *in_skb,
> +			      const struct inet_diag_req_v2 *req,
> +			      struct udp_table *tbl)
> +{
> +	struct net *net = sock_net(in_skb->sk);
> +	struct sock *sk;
> +
> +	rcu_read_lock();
> +
> +	if (req->sdiag_family == AF_INET)
> +		sk = __udp4_lib_lookup(net,
> +				req->id.idiag_dst[0], req->id.idiag_dport,
> +				req->id.idiag_src[0], req->id.idiag_sport,
> +				req->id.idiag_if, tbl, NULL);
> +#if IS_ENABLED(CONFIG_IPV6)
> +	else if (req->sdiag_family == AF_INET6)
> +		sk = __udp6_lib_lookup(net,
> +				(struct in6_addr *)req->id.idiag_dst,
> +				req->id.idiag_dport,
> +				(struct in6_addr *)req->id.idiag_src,
> +				req->id.idiag_sport,
> +				req->id.idiag_if, tbl, NULL);
> +#endif
> +	if (sk && !atomic_inc_not_zero(&sk->sk_refcnt))
> +		sk = NULL;
> +
> +	rcu_read_unlock();
> +
> +	if (!sk)
> +		return -ENOENT;
> +
> +	if (sock_diag_check_cookie(sk, req->id.idiag_cookie)) {
> +		sock_put(sk);
> +		return -ENOENT;
> +	}
> +
> +	return sock_diag_destroy(sk, ECONNABORTED);
> +}
> +
> +static int udp_diag_destroy(struct sk_buff *in_skb,
> +			    const struct inet_diag_req_v2 *req)
> +{
> +	return __udp_diag_destroy(in_skb, req, &udp_table);
> +}
> +
> +static int udplite_diag_destroy(struct sk_buff *in_skb,
> +				const struct inet_diag_req_v2 *req)
> +{
> +	return __udp_diag_destroy(in_skb, req, &udplite_table);
> +}
> +
> +#endif
> +
>  static const struct inet_diag_handler udp_diag_handler = {
>  	.dump		 = udp_diag_dump,
>  	.dump_one	 = udp_diag_dump_one,
>  	.idiag_get_info  = udp_diag_get_info,
>  	.idiag_type	 = IPPROTO_UDP,
>  	.idiag_info_size = 0,
> +#ifdef CONFIG_INET_DIAG_DESTROY
> +	.destroy	 = udp_diag_destroy,
> +#endif
>  };
>  
>  static void udplite_diag_dump(struct sk_buff *skb, struct netlink_callback *cb,
> @@ -192,6 +249,9 @@ static const struct inet_diag_handler udplite_diag_handler = {
>  	.idiag_get_info  = udp_diag_get_info,
>  	.idiag_type	 = IPPROTO_UDPLITE,
>  	.idiag_info_size = 0,
> +#ifdef CONFIG_INET_DIAG_DESTROY
> +	.destroy	 = udplite_diag_destroy,
> +#endif
>  };
>  
>  static int __init udp_diag_init(void)
> diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
> index 81e2f98b958d..16512cf06e73 100644
> --- a/net/ipv6/udp.c
> +++ b/net/ipv6/udp.c
> @@ -1467,6 +1467,7 @@ struct proto udpv6_prot = {
>  	.compat_getsockopt = compat_udpv6_getsockopt,
>  #endif
>  	.clear_sk	   = udp_v6_clear_sk,
> +	.diag_destroy      = udp_abort,
>  };
>  
>  static struct inet_protosw udpv6_protosw = {
