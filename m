From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RFC net-next 3/3] net/core/sock.c: sk_clone_lock()
 should only do get_net() if the parent is not a kernel socket
Date: Thu, 30 Jul 2015 15:06:47 +0200
Message-ID: <1438261607.20182.130.camel@edumazet-glaptop2.roam.corp.google.com>
References: <cover.1438245718.git.sowmini.varadhan@oracle.com>
	 <15334c31275787177fb1d12927604ee87d3938d4.1438245718.git.sowmini.varadhan@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, cwang@twopensource.com,
	ajaykumar.hotchandani@oracle.com,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:36054 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751391AbbG3NGv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2015 09:06:51 -0400
Received: by wicgb10 with SMTP id gb10so243270791wic.1
        for <netdev@vger.kernel.org>; Thu, 30 Jul 2015 06:06:50 -0700 (PDT)
In-Reply-To: <15334c31275787177fb1d12927604ee87d3938d4.1438245718.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-07-30 at 04:55 -0400, Sowmini Varadhan wrote:
> The newsk returned by sk_clone_lock should hold a get_net()
> reference if, and only if, the parent is not a kernel socket
> (making this similar to sk_alloc()).
> 
> E.g,. for the SYN_RECV call path, tcp_v4_syn_recv_sock->..inet_csk_clone_lock
> sets up the syn_recv newsk from sk_clone_lock. When the parent (listen)
> socket is a kernel socket (defined in sk_alloc() as having
> sk_net_refcnt == 0), then the newsk should also have a 0 sk_net_refcnt
> and should not hold a get_net() reference.
> 
> Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
> ---
>  net/core/sock.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
> 
> diff --git a/net/core/sock.c b/net/core/sock.c
> index 08f16db..371d1b7 100644
> --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -1497,7 +1497,8 @@ struct sock *sk_clone_lock(const struct sock *sk, const gfp_t priority)
>  		sock_copy(newsk, sk);
>  
>  		/* SANITY */
> -		get_net(sock_net(newsk));
> +		if (likely(newsk->sk_net_refcnt))
> +			get_net(sock_net(newsk));
>  		sk_node_init(&newsk->sk_node);
>  		sock_lock_init(newsk);
>  		bh_lock_sock(newsk);

CC Eric Biederman 

It looks this should be submitted for 'net' tree, not 'net-next'

Fixes: 26abe14379f8 ("net: Modify sk_alloc to not reference count the netns of kernel sockets.")

Acked-by: Eric Dumazet <edumazet@google.com>
