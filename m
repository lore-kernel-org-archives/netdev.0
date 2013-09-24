From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] vxlan: Use RCU apis to access sk_user_data.
Date: Mon, 23 Sep 2013 22:51:16 -0700
Message-ID: <1380001876.3165.44.camel@edumazet-glaptop>
References: <1380000501-13969-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jesse Gross <jesse@nicira.com>
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f42.google.com ([209.85.213.42]:52952 "EHLO
	mail-yh0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750713Ab3IXFvT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Sep 2013 01:51:19 -0400
Received: by mail-yh0-f42.google.com with SMTP id z12so1824316yhz.15
        for <netdev@vger.kernel.org>; Mon, 23 Sep 2013 22:51:18 -0700 (PDT)
In-Reply-To: <1380000501-13969-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-09-23 at 22:28 -0700, Pravin B Shelar wrote:
> Use of RCU api makes vxlan code easier to understand.  It also
> fixes bug due to missing ACCESS_ONCE() on sk_user_data dereference.
> In rare case without ACCESS_ONCE() compiler might omit vs on
> sk_user_data dereference.
> Compiler can use vs as alias for sk->sk_user_data, resulting in
> multiple sk_user_data dereference in rcu read context which
> could change.
> 
> CC: Jesse Gross <jesse@nicira.com>
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
> ---
>  drivers/net/vxlan.c |    9 +++------
>  include/net/sock.h  |    2 ++
>  2 files changed, 5 insertions(+), 6 deletions(-)
> 
> diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
> index d1292fe..3519a71 100644
> --- a/drivers/net/vxlan.c
> +++ b/drivers/net/vxlan.c
> @@ -952,8 +952,7 @@ void vxlan_sock_release(struct vxlan_sock *vs)
>  
>  	spin_lock(&vn->sock_lock);
>  	hlist_del_rcu(&vs->hlist);
> -	smp_wmb();
> -	vs->sock->sk->sk_user_data = NULL;
> +	rcu_assign_pointer(sk_user_data_rcu(vs->sock->sk), NULL);

RCU_INIT_POINTER(sk_user_data_rcu(vs->sock->sk), NULL)
