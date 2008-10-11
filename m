From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: pkt_sched: cls_u32: Fix locking in u32_delete()
Date: Sat, 11 Oct 2008 22:10:22 +0800
Message-ID: <E1KofAk-0001uJ-0q@gondolin.me.apana.org.au>
References: <20081011111711.GA2808@ami.dom.local>
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org, m0sia@plotinka.ru,
	akpm@linux-foundation.org
To: jarkao2@gmail.com (Jarek Poplawski)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:56275 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753061AbYJKOKa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Oct 2008 10:10:30 -0400
In-Reply-To: <20081011111711.GA2808@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski <jarkao2@gmail.com> wrote:
> pkt_sched: cls_u32: Fix locking in u32_delete()
> 
> While looking for a possible reason of bugzilla [Bug 11571]
> "u32_classify Kernel Panic" reported by m0sia@plotinka.ru I found that
> tcf_tree_lock() is missing in u32_delete() during u32_destroy_hnode()
> call. Other paths calling this function use this lock. It haven't been
> acknowledged this fixes the bug, but I think this patch is needed here
> anyway.
> 
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
> 
> ---
> 
> net/sched/cls_u32.c |    2 ++
> 1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
> index 246f906..9912ad5 100644
> --- a/net/sched/cls_u32.c
> +++ b/net/sched/cls_u32.c
> @@ -433,7 +433,9 @@ static int u32_delete(struct tcf_proto *tp, unsigned long arg)
> 
>        if (ht->refcnt == 1) {
>                ht->refcnt--;
> +               tcf_tree_lock(tp);
>                u32_destroy_hnode(tp, ht);
> +               tcf_tree_unlock(tp);

Well if you were going to protect you'd need to lock before the
reference count check.  However, this is actually unecessary
because the reference count can only be increased the RTNL which
we're already holding.

Also, if the reference count is 1, then there must be no live
references in the system to the hash table so we can safely
delete it.

So whatever the problem is this isn't it :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
