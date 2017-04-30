From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Patch net-next v2] ipv4: get rid of ip_ra_lock
Date: Sun, 30 Apr 2017 09:42:33 -0700
Message-ID: <1493570553.31837.18.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1493399069-31743-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:34697 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1165802AbdD3Qmh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Apr 2017 12:42:37 -0400
Received: by mail-pf0-f193.google.com with SMTP id g23so24931530pfj.1
        for <netdev@vger.kernel.org>; Sun, 30 Apr 2017 09:42:37 -0700 (PDT)
In-Reply-To: <1493399069-31743-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-04-28 at 10:04 -0700, Cong Wang wrote:
> After commit 1215e51edad1 ("ipv4: fix a deadlock in ip_ra_control")
> we always take RTNL lock for ip_ra_control() which is the only place
> we update the list ip_ra_chain, so the ip_ra_lock is no longer needed.
> 
> As Eric points out, BH does not need to disable either, RCU readers
> don't care.
> 
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> ---
>  net/ipv4/ip_sockglue.c | 9 +--------
>  1 file changed, 1 insertion(+), 8 deletions(-)
> 
> diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
> index 1d46d05..4c25458 100644
> --- a/net/ipv4/ip_sockglue.c
> +++ b/net/ipv4/ip_sockglue.c
> @@ -330,7 +330,6 @@ int ip_cmsg_send(struct sock *sk, struct msghdr *msg, struct ipcm_cookie *ipc,
>     sent to multicast group to reach destination designated router.
>   */
>  struct ip_ra_chain __rcu *ip_ra_chain;
> -static DEFINE_SPINLOCK(ip_ra_lock);
>  
> 
>  static void ip_ra_destroy_rcu(struct rcu_head *head)
> @@ -352,21 +351,17 @@ int ip_ra_control(struct sock *sk, unsigned char on,
>  
>  	new_ra = on ? kmalloc(sizeof(*new_ra), GFP_KERNEL) : NULL;
>  
> -	spin_lock_bh(&ip_ra_lock);
>  	for (rap = &ip_ra_chain;
> -	     (ra = rcu_dereference_protected(*rap,
> -			lockdep_is_held(&ip_ra_lock))) != NULL;
> +	     (ra = rtnl_dereference(*rap)) != NULL;
>  	     rap = &ra->next) {
>  		if (ra->sk == sk) {
>  			if (on) {
> -				spin_unlock_bh(&ip_ra_lock);
>  				kfree(new_ra);
>  				return -EADDRINUSE;
>  			}
>  			/* dont let ip_call_ra_chain() use sk again */
>  			ra->sk = NULL;
>  			RCU_INIT_POINTER(*rap, ra->next);
> -			spin_unlock_bh(&ip_ra_lock);
>  
>  			if (ra->destructor)
>  				ra->destructor(sk);
> @@ -381,7 +376,6 @@ int ip_ra_control(struct sock *sk, unsigned char on,
>  		}
>  	}
>  	if (!new_ra) {
> -		spin_unlock_bh(&ip_ra_lock);
>  		return -ENOBUFS;
>  	}

Minor point : You could have removed the {}

Acked-by: Eric Dumazet <edumazet@google.com>

Thanks !
