From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net-next] xfrm: remove useless hash_resize_mutex locks
Date: Fri, 29 Aug 2014 08:11:51 +0200
Message-ID: <20140829061150.GE6390@secunet.com>
References: <1409132986-12224-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Christophe Gouault <christophe.gouault@6wind.com>
To: Ying Xue <ying.xue@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:45873 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750983AbaH2GL5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Aug 2014 02:11:57 -0400
Content-Disposition: inline
In-Reply-To: <1409132986-12224-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ccing Christophe Gouault as he currently reworks the policy
hashing.

On Wed, Aug 27, 2014 at 05:49:46PM +0800, Ying Xue wrote:
> In xfrm_policy.c, hash_resize_mutex is defined as a local variable
> and only used in xfrm_hash_resize() which is declared as a work
> handler of xfrm.policy_hash_work. But when the xfrm.policy_hash_work
> work is put in the global workqueue(system_wq) with schedule_work(),
> the work will be really inserted in the global workqueue if it was
> not already queued, otherwise, it is still left in the same position
> on the the global workqueue. This means the xfrm_hash_resize() work
> handler is only executed once at any time no matter how many times
> its work is scheduled, that is, xfrm_hash_resize() is not called
> concurrently at all, so hash_resize_mutex is redundant for us.
> 
> Additionally hash_resize_mutex defined in xfrm_state.c can be removed
> as the same reason.
> 
> Signed-off-by: Ying Xue <ying.xue@windriver.com>
> Acked-by: David S. Miller <davem@davemloft.net>
> ---
> Just resend the patch after RFC flag is removed from below
> version:
> http://patchwork.ozlabs.org/patch/369818/
> 
>  net/xfrm/xfrm_policy.c |    5 -----
>  net/xfrm/xfrm_state.c  |   13 +++----------
>  2 files changed, 3 insertions(+), 15 deletions(-)
> 
> diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
> index beeed60..b559a90 100644
> --- a/net/xfrm/xfrm_policy.c
> +++ b/net/xfrm/xfrm_policy.c
> @@ -510,14 +510,11 @@ void xfrm_spd_getinfo(struct net *net, struct xfrmk_spdinfo *si)
>  }
>  EXPORT_SYMBOL(xfrm_spd_getinfo);
>  
> -static DEFINE_MUTEX(hash_resize_mutex);
>  static void xfrm_hash_resize(struct work_struct *work)
>  {
>  	struct net *net = container_of(work, struct net, xfrm.policy_hash_work);
>  	int dir, total;
>  
> -	mutex_lock(&hash_resize_mutex);

One of Christophes patches will use this mutex in a worker of
another work queue, so this mutex is really needed if I apply
his patchset. See http://patchwork.ozlabs.org/patch/383486/

I tend to apply Christophes patchset after some further testing,
so we can't remove this mutex now.

>  
>  /* Generate new index... KAME seems to generate them ordered by cost
> diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
> index 0ab5413..de971b6 100644
> --- a/net/xfrm/xfrm_state.c
> +++ b/net/xfrm/xfrm_state.c
> @@ -97,8 +97,6 @@ static unsigned long xfrm_hash_new_size(unsigned int state_hmask)
>  	return ((state_hmask + 1) << 1) * sizeof(struct hlist_head);
>  }
>  
> -static DEFINE_MUTEX(hash_resize_mutex);
> -

This one is still redundant, so we can remove it if there
are no plans to do something similar to the xfrm_state
hashing soon. Christophe?
