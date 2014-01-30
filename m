From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] net/ipv4: Use proper RCU APIs for writer-side in
 udp_offload.c
Date: Thu, 30 Jan 2014 06:39:51 -0800
Message-ID: <1391092791.28432.78.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1391079118-23922-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, edumazet@google.com,
	Shlomo Pongratz <shlomop@mellanox.com>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:61052 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751816AbaA3Ojy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jan 2014 09:39:54 -0500
Received: by mail-ie0-f169.google.com with SMTP id to1so3413909ieb.28
        for <netdev@vger.kernel.org>; Thu, 30 Jan 2014 06:39:53 -0800 (PST)
In-Reply-To: <1391079118-23922-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-01-30 at 12:51 +0200, Or Gerlitz wrote:
> From: Shlomo Pongratz <shlomop@mellanox.com>
> 
> RCU writer side should use rcu_dereference_protected() and not
> rcu_dereference(), fix that. This also removes the "suspicious RCU usage"
> warning seen when running with CONFIG_PROVE_RCU.
> 
> Fixes: b582ef0 ('net: Add GRO support for UDP encapsulating protocols')
> Reported-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
> Signed-off-by: Shlomo Pongratz <shlomop@mellanox.com>
> ---
>  net/ipv4/udp_offload.c |   14 +++++++++-----
>  1 files changed, 9 insertions(+), 5 deletions(-)
> 
> diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
> index 2ffea6f..1bf21d4 100644
> --- a/net/ipv4/udp_offload.c
> +++ b/net/ipv4/udp_offload.c
> @@ -109,7 +109,8 @@ int udp_add_offload(struct udp_offload *uo)
>  	new_offload->offload = uo;
>  
>  	spin_lock(&udp_offload_lock);
> -	rcu_assign_pointer(new_offload->next, rcu_dereference(*head));
> +	rcu_assign_pointer(new_offload->next,
> +			   rcu_dereference_protected(*head, lockdep_is_held(&udp_offload_lock)));

Technically speaking, this first rcu_assign_pointer() is not needed,
because we write into a field of a structure which is only visible by
us.

The _following_ rcu_assign_pointer() is enough to make sure the whole
structure is consistent before being inserted in the global list.

So it should be enough and correct to simply use

	new_offload->next = udp_offload_base;
	rcu_assing_pointer(udp_offload_base, new_offload);

(and get rid of *head pointer btw)

>  	rcu_assign_pointer(*head, new_offload);
>  	spin_unlock(&udp_offload_lock);
>  
> @@ -130,12 +131,15 @@ void udp_del_offload(struct udp_offload *uo)
>  
>  	spin_lock(&udp_offload_lock);
>  
> -	uo_priv = rcu_dereference(*head);
> +	uo_priv = rcu_dereference_protected(*head,
> +					    lockdep_is_held(&udp_offload_lock));
>  	for (; uo_priv != NULL;
> -		uo_priv = rcu_dereference(*head)) {
> -
> +	     uo_priv = rcu_dereference_protected(*head,
> +						 lockdep_is_held(&udp_offload_lock))) {
>  		if (uo_priv->offload == uo) {
> -			rcu_assign_pointer(*head, rcu_dereference(uo_priv->next));
> +			rcu_assign_pointer(*head,
> +					   rcu_dereference_protected(uo_priv->next,
> +								     lockdep_is_held(&udp_offload_lock)));
>  			goto unlock;
>  		}
>  		head = &uo_priv->next;

You also could define and use a macro to get better indentation.

#define u_deref_protected(X) rcu_dereference_protected(X, lockdep_is_held(&udp_offload_lock))

(This is what we did for nl_deref_protected() for example)
