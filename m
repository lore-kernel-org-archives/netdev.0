From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Patch net] ipv6: fix a potential deadlock in
 do_ipv6_setsockopt()
Date: Wed, 19 Oct 2016 16:38:49 -0700
Message-ID: <1476920329.5650.77.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1476901218-15635-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sploving1@gmail.com,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:33035 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754100AbcJSXiw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2016 19:38:52 -0400
Received: by mail-pf0-f196.google.com with SMTP id i85so3676828pfa.0
        for <netdev@vger.kernel.org>; Wed, 19 Oct 2016 16:38:52 -0700 (PDT)
In-Reply-To: <1476901218-15635-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-10-19 at 11:20 -0700, Cong Wang wrote:
> Baozeng reported this deadlock case:
> 
>        CPU0                    CPU1
>        ----                    ----
>   lock([  165.136033] sk_lock-AF_INET6);
>                                lock([  165.136033] rtnl_mutex);
>                                lock([  165.136033] sk_lock-AF_INET6);
>   lock([  165.136033] rtnl_mutex);
> 
> Similar to commit 87e9f0315952
> ("ipv4: fix a potential deadlock in mcast getsockopt() path")
> this is due to we still have a case, ipv6_sock_mc_close(),
> where we acquire sk_lock before rtnl_lock. Close this deadlock
> with the similar solution, that is always acquire rtnl lock first.
> 
> Fixes: baf606d9c9b1 ("ipv4,ipv6: grab rtnl before locking the socket")
> Reported-by: Baozeng Ding <sploving1@gmail.com>
> Tested-by: Baozeng Ding <sploving1@gmail.com>
> Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> ---
>  net/ipv6/af_inet6.c      | 2 ++
>  net/ipv6/ipv6_sockglue.c | 1 +
>  net/ipv6/mcast.c         | 4 ++--
>  3 files changed, 5 insertions(+), 2 deletions(-)
> 
> diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
> index 46ad699..b8c8d20 100644
> --- a/net/ipv6/af_inet6.c
> +++ b/net/ipv6/af_inet6.c
> @@ -414,7 +414,9 @@ int inet6_release(struct socket *sock)
>  		return -EINVAL;
>  
>  	/* Free mc lists */
> +	rtnl_lock();

Certainly not.

Some people want IPv6 being reasonably fast.

>  	ipv6_sock_mc_close(sk);
> +	rtnl_unlock();
>  
