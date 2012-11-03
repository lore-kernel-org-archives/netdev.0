From: Pavel Emelyanov <xemul@parallels.com>
Subject: Re: [RFC] net: netlink -- Allow netlink_dump to return error code
 if protocol handler is missed
Date: Sat, 03 Nov 2012 20:17:50 +0400
Message-ID: <509543AE.1020902@parallels.com>
References: <20121102173550.GH10877@moon>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: NETDEV <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Cyrill Gorcunov <gorcunov@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:12567 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752564Ab2KCQR6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 3 Nov 2012 12:17:58 -0400
In-Reply-To: <20121102173550.GH10877@moon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/02/2012 09:35 PM, Cyrill Gorcunov wrote:
> We've observed that in case if UDP diag module is not
> supported in kernel the netlink returns NLMSG_DONE without
> notifying a caller that handler is missed.
> 
> This patch makes netlink_dump to return error code instead.
> 
> So as example it become possible to detect such situation
> and handle it gracefully on userspace level.
> 
> Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>
> CC: David Miller <davem@davemloft.net>
> CC: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Pavel Emelyanov <xemul@parallels.com>
> ---
>  net/ipv4/inet_diag.c     |    5 ++++-
>  net/netlink/af_netlink.c |    4 ++++
>  2 files changed, 8 insertions(+), 1 deletion(-)
> 
> Index: linux-2.6.git/net/ipv4/inet_diag.c
> ===================================================================
> --- linux-2.6.git.orig/net/ipv4/inet_diag.c
> +++ linux-2.6.git/net/ipv4/inet_diag.c
> @@ -895,13 +895,16 @@ static int __inet_diag_dump(struct sk_bu
>  		struct inet_diag_req_v2 *r, struct nlattr *bc)
>  {
>  	const struct inet_diag_handler *handler;
> +	int err = 0;
>  
>  	handler = inet_diag_lock_handler(r->sdiag_protocol);
>  	if (!IS_ERR(handler))
>  		handler->dump(skb, cb, r, bc);
> +	else
> +		err = PTR_ERR(handler);
>  	inet_diag_unlock_handler(handler);
>  
> -	return skb->len;
> +	return err ? : skb->len;
>  }
>  
>  static int inet_diag_dump(struct sk_buff *skb, struct netlink_callback *cb)
> Index: linux-2.6.git/net/netlink/af_netlink.c
> ===================================================================
> --- linux-2.6.git.orig/net/netlink/af_netlink.c
> +++ linux-2.6.git/net/netlink/af_netlink.c
> @@ -1740,6 +1740,10 @@ static int netlink_dump(struct sock *sk)
>  		else
>  			__netlink_sendskb(sk, skb);
>  		return 0;
> +	} else if (len < 0) {
> +		err = len;
> +		nlk->cb = NULL;
> +		goto errout_skb;

When family-level handler is absent and sock_diag returns error this error
gets propagated back to user without this fix. Why do we need it in case
we return error from protocol-level handler?

>  	}
>  
>  	nlh = nlmsg_put_answer(skb, cb, NLMSG_DONE, sizeof(len), NLM_F_MULTI);
> .
> 
