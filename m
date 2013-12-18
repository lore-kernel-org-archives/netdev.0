From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCHv2 ipsec-next] xfrm: Namespacify xfrm_policy_sk_bundles
Date: Tue, 17 Dec 2013 20:50:11 -0800
Message-ID: <1387342211.19078.295.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1387337658-28951-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, davem@davemloft.net,
	netdev@vger.kernel.org
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:35536 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751267Ab3LREuO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Dec 2013 23:50:14 -0500
Received: by mail-pd0-f181.google.com with SMTP id p10so7638075pdj.26
        for <netdev@vger.kernel.org>; Tue, 17 Dec 2013 20:50:13 -0800 (PST)
In-Reply-To: <1387337658-28951-1-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-12-18 at 11:34 +0800, Fan Du wrote:
> xfrm_policy_sk_bundles, protected by net->xfrm.xfrm_policy_sk_bundle_lock
> should be put into netns xfrm structure, otherwise xfrm_policy_sk_bundles
> can be corrupted from different net namespace.
> 
> Moreover current xfrm_policy_sk_bundle_lock used in below two scenarios:
> 
> 1. xfrm_lookup(Process context)  vs  __xfrm_garbage_collect(softirq context)
> 2. xfrm_lookup(Process context)  vs  __xfrm_garbage_collect(Process context
>                                                 when SPD change or dev down) 
> 
> we can use xchg to avoid the spinlock, at the same time cover above scenarios,
> inspired by discussion in: http://marc.info/?l=linux-netdev&m=138713363113003&w=2
> 
> Signed-off-by: Fan Du <fan.du@windriver.com>
> ---
> v2:
>   Fix incorrect commit log.
> 
> ---
>  include/net/netns/xfrm.h |    2 +-
>  net/xfrm/xfrm_policy.c   |   17 +++--------------
>  2 files changed, 4 insertions(+), 15 deletions(-)
> 
> diff --git a/include/net/netns/xfrm.h b/include/net/netns/xfrm.h
> index 1006a26..4a30b1b 100644
> --- a/include/net/netns/xfrm.h
> +++ b/include/net/netns/xfrm.h
> @@ -58,9 +58,9 @@ struct netns_xfrm {
>  	struct dst_ops		xfrm6_dst_ops;
>  #endif
>  	spinlock_t xfrm_state_lock;
> -	spinlock_t xfrm_policy_sk_bundle_lock;
>  	rwlock_t xfrm_policy_lock;
>  	struct mutex xfrm_cfg_mutex;
> +	struct dst_entry *xfrm_policy_sk_bundles;
>  };
>  
>  #endif
> diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
> index a7487f3..26d79c0 100644
> --- a/net/xfrm/xfrm_policy.c
> +++ b/net/xfrm/xfrm_policy.c
> @@ -39,8 +39,6 @@
>  #define XFRM_QUEUE_TMO_MAX ((unsigned)(60*HZ))
>  #define XFRM_MAX_QUEUE_LEN	100
>  
> -static struct dst_entry *xfrm_policy_sk_bundles;
> -
>  static DEFINE_SPINLOCK(xfrm_policy_afinfo_lock);
>  static struct xfrm_policy_afinfo __rcu *xfrm_policy_afinfo[NPROTO]
>  						__read_mostly;
> @@ -2108,12 +2106,8 @@ struct dst_entry *xfrm_lookup(struct net *net, struct dst_entry *dst_orig,
>  			}
>  
>  			dst_hold(&xdst->u.dst);
> -
> -			spin_lock_bh(&net->xfrm.xfrm_policy_sk_bundle_lock);
> -			xdst->u.dst.next = xfrm_policy_sk_bundles;
> -			xfrm_policy_sk_bundles = &xdst->u.dst;
> -			spin_unlock_bh(&net->xfrm.xfrm_policy_sk_bundle_lock);
> -
> +			xdst->u.dst.next = xchg(&net->xfrm.xfrm_policy_sk_bundles,
> +						&xdst->u.dst);

This is not safe.

Take a look at include/linux/llist.h if you really want to avoid the
spinlock.
