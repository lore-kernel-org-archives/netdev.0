From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH net] sctp: add the missing sock_owned_by_user check in
 sctp_icmp_redirect
Date: Wed, 18 Oct 2017 11:56:45 -0200
Message-ID: <20171018135645.GF5357@localhost.localdomain>
References: <7f2a5122d93d4b72115027690e89c0a164097452.1508333869.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
        davem@davemloft.net, Eric Dumazet <edumazet@google.com>,
        Neil Horman <nhorman@tuxdriver.com>
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41280 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750775AbdJRN4u (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 18 Oct 2017 09:56:50 -0400
Content-Disposition: inline
In-Reply-To: <7f2a5122d93d4b72115027690e89c0a164097452.1508333869.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 18, 2017 at 09:37:49PM +0800, Xin Long wrote:
> Now sctp processes icmp redirect packet in sctp_icmp_redirect where
> it calls sctp_transport_dst_check in which tp->dst can be released.
> 
> The problem is before calling sctp_transport_dst_check, it doesn't
> check sock_owned_by_user, which means tp->dst could be freed while
> a process is accessing it with owning the socket.
> 
> An use-after-free issue could be triggered by this.
> 
> This patch is to fix it by checking sock_owned_by_user before calling
> sctp_transport_dst_check in sctp_icmp_redirect, so that it would not
> release tp->dst if users still hold sock lock.
> 
> Besides, the same issue fixed in commit 45caeaa5ac0b ("dccp/tcp: fix
> routing redirect race") on sctp also needs this check.
> 
> Fixes: 55be7a9c6074 ("ipv4: Add redirect support to all protocol icmp error handlers")
> Reported-by: Eric Dumazet <edumazet@google.com>

Nice catch, btw.

> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Acked-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Thanks

> ---
>  net/sctp/input.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/sctp/input.c b/net/sctp/input.c
> index 92a0714..34f10e7 100644
> --- a/net/sctp/input.c
> +++ b/net/sctp/input.c
> @@ -421,7 +421,7 @@ void sctp_icmp_redirect(struct sock *sk, struct sctp_transport *t,
>  {
>  	struct dst_entry *dst;
>  
> -	if (!t)
> +	if (sock_owned_by_user(sk) || !t)
>  		return;
>  	dst = sctp_transport_dst_check(t);
>  	if (dst)
> -- 
> 2.1.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
