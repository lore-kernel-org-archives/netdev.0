From: David Miller <davem@davemloft.net>
Subject: Re: pkt_sched: cls_u32: Fix locking in u32_delete()
Date: Sat, 11 Oct 2008 12:24:00 -0700 (PDT)
Message-ID: <20081011.122400.51934908.davem@davemloft.net>
References: <20081011111711.GA2808@ami.dom.local>
	<E1KofAk-0001uJ-0q@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org, m0sia@plotinka.ru,
	akpm@linux-foundation.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38709
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755146AbYJKTYY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Oct 2008 15:24:24 -0400
In-Reply-To: <E1KofAk-0001uJ-0q@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sat, 11 Oct 2008 22:10:22 +0800

> Jarek Poplawski <jarkao2@gmail.com> wrote:
> > pkt_sched: cls_u32: Fix locking in u32_delete()
> > 
> > While looking for a possible reason of bugzilla [Bug 11571]
> > "u32_classify Kernel Panic" reported by m0sia@plotinka.ru I found that
> > tcf_tree_lock() is missing in u32_delete() during u32_destroy_hnode()
> > call. Other paths calling this function use this lock. It haven't been
> > acknowledged this fixes the bug, but I think this patch is needed here
> > anyway.
> > 
> > Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
> > 
> > ---
> > 
> > net/sched/cls_u32.c |    2 ++
> > 1 files changed, 2 insertions(+), 0 deletions(-)
> > 
> > diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
> > index 246f906..9912ad5 100644
> > --- a/net/sched/cls_u32.c
> > +++ b/net/sched/cls_u32.c
> > @@ -433,7 +433,9 @@ static int u32_delete(struct tcf_proto *tp, unsigned long arg)
> > 
> >        if (ht->refcnt == 1) {
> >                ht->refcnt--;
> > +               tcf_tree_lock(tp);
> >                u32_destroy_hnode(tp, ht);
> > +               tcf_tree_unlock(tp);
> 
> Well if you were going to protect you'd need to lock before the
> reference count check.  However, this is actually unecessary
> because the reference count can only be increased the RTNL which
> we're already holding.
> 
> Also, if the reference count is 1, then there must be no live
> references in the system to the hash table so we can safely
> delete it.
> 
> So whatever the problem is this isn't it :)

Agreed, the synchronization is already what is necessary here.

As Herbert stated, the refcounts only change under RTNL and when we see
it hit 0 we can be sure we are the only reference to it.

Next, my understanding is that:

1) tc_h_common is a per sched tree object
2) we quiesced the whole sched tree, from the root, before
   getting to this code

Which means that the hash list deletion in u32_destroy_hnode() is
safe as well.

But hey, we could be missing something here, so I'd be happy to
hear that Jarek can still see some hole here :)  Because it is true
that we have seen some weird crashes still and u32 seems common
amongst those report.

