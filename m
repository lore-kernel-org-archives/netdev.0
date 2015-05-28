From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] neigh: Add missing rcu_assign_pointer
Date: Thu, 28 May 2015 03:13:48 -0700
Message-ID: <1432808028.24345.5.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1432801700-29300-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ying Xue <ying.xue@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:36268 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751548AbbE1KNv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2015 06:13:51 -0400
Received: by igbpi8 with SMTP id pi8so107600408igb.1
        for <netdev@vger.kernel.org>; Thu, 28 May 2015 03:13:50 -0700 (PDT)
In-Reply-To: <1432801700-29300-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-05-28 at 16:28 +0800, Ying Xue wrote:
> Commit e4c4e448cf55 ("neigh: Convert garbage collection from softirq
> to workqueue") misses to use rcu_assign_pointer() macro to assign a
> RCU-protected pointer.
> 
> Signed-off-by: Ying Xue <ying.xue@windriver.com>
> ---
>  net/core/neighbour.c |    3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/net/core/neighbour.c b/net/core/neighbour.c
> index 3a74df7..aaad3a5 100644
> --- a/net/core/neighbour.c
> +++ b/net/core/neighbour.c
> @@ -783,7 +783,8 @@ static void neigh_periodic_work(struct work_struct *work)
>  			if (atomic_read(&n->refcnt) == 1 &&
>  			    (state == NUD_FAILED ||
>  			     time_after(jiffies, n->used + NEIGH_VAR(n->parms, GC_STALETIME)))) {
> -				*np = n->next;
> +				rcu_assign_pointer(*np, rcu_dereference_protected(n->next,
> +								lockdep_is_held(&tbl->lock)));
>  				n->dead = 1;
>  				write_unlock(&n->lock);
>  				neigh_cleanup_and_release(n);


This patch is not needed.

You really should read Documentation/RCU , because it looks like you are
quite confused.

When we remove an element from a RCU protected list, all the objects in
the chain are already ready to be caught by rcu readers.

Therefore, no additional memory barrier is needed before doing *np =
n->next;

Please do not add spurious memory barriers. Like atomic operations, we
want all of them being required and possibly documented.
