From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 3/3] netfilter: xt_CT: remove a compile warning
Date: Tue, 3 Apr 2012 16:52:10 +0200
Message-ID: <20120403145210.GA31196@1984>
References: <201204032048.GFH51564.QSOVLMOOJHtFFF@I-love.SAKURA.ne.jp>
 <20120403120900.GB6010@1984>
 <201204032128.JEG78136.JStMOHQOVFFFLO@I-love.SAKURA.ne.jp>
 <20120403125755.GA15339@1984>
 <20120403130620.GA15385@1984>
 <201204032328.CDE78687.tQOHSLVFOFMJOF@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="IrhDeMKUP4DT/M7F"
Cc: netdev@vger.kernel.org
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:51944 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753082Ab2DCOwP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Apr 2012 10:52:15 -0400
Content-Disposition: inline
In-Reply-To: <201204032328.CDE78687.tQOHSLVFOFMJOF@I-love.SAKURA.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--IrhDeMKUP4DT/M7F
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Apr 03, 2012 at 11:28:50PM +0900, Tetsuo Handa wrote:
> Pablo Neira Ayuso wrote:
> > A bit better patch, no need to hold rcu_read_lock again in
> > xt_ct_tg_timeout_put (even if that doesn't harm).
> 
> Patch looks OK.
> 
> By the way,
> 
> 665 static struct nf_conn *
> 666 __nf_conntrack_alloc(struct net *net, u16 zone,
> 667                      const struct nf_conntrack_tuple *orig,
> 668                      const struct nf_conntrack_tuple *repl,
> 669                      gfp_t gfp, u32 hash)
> 670 {
> (...snipped...)
> 680         atomic_inc(&net->ct.count);
> (...snipped...)
> 698         ct = kmem_cache_alloc(net->ct.nf_conntrack_cachep, gfp);
> 699         if (ct == NULL) {
> 700                 atomic_dec(&net->ct.count);
> 701                 return ERR_PTR(-ENOMEM);
> 702         }
> (...snipped...)
> 720         if (zone) {
> 721                 struct nf_conntrack_zone *nf_ct_zone;
> 722 
> 723                 nf_ct_zone = nf_ct_ext_add(ct, NF_CT_EXT_ZONE, GFP_ATOMIC);
> 724                 if (!nf_ct_zone)
> 725                         goto out_free;
> 726                 nf_ct_zone->id = zone;
> 727         }
> (...snipped...)
> 737 out_free:
> 
> I think we want to call atomic_dec() here.

Good catch :-).

Patch to address this issue follows.

--IrhDeMKUP4DT/M7F
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="0001-netfilter-nf_conntrack-fix-count-leak-in-error-path-.patch"

>From 0fca4d604c0898128014bc03ef965e0cf187a5e9 Mon Sep 17 00:00:00 2001
From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Tue, 3 Apr 2012 16:45:54 +0200
Subject: [PATCH] netfilter: nf_conntrack: fix count leak in error path of __nf_conntrack_alloc

We have to decrement the conntrack counter if we fail to access the
zone extension.

Reported-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_core.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index cbdb754..3cc4487 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -735,6 +735,7 @@ __nf_conntrack_alloc(struct net *net, u16 zone,
 
 #ifdef CONFIG_NF_CONNTRACK_ZONES
 out_free:
+	atomic_dec(&net->ct.count);
 	kmem_cache_free(net->ct.nf_conntrack_cachep, ct);
 	return ERR_PTR(-ENOMEM);
 #endif
-- 
1.7.2.5


--IrhDeMKUP4DT/M7F--
