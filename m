From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: [PATCH 3/3] netfilter: xt_CT: remove a compile warning
Date: Tue, 3 Apr 2012 23:28:50 +0900
Message-ID: <201204032328.CDE78687.tQOHSLVFOFMJOF@I-love.SAKURA.ne.jp>
References: <201204032048.GFH51564.QSOVLMOOJHtFFF@I-love.SAKURA.ne.jp>
	<20120403120900.GB6010@1984>
	<201204032128.JEG78136.JStMOHQOVFFFLO@I-love.SAKURA.ne.jp>
	<20120403125755.GA15339@1984>
	<20120403130620.GA15385@1984>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www262.sakura.ne.jp ([202.181.97.72]:49904 "EHLO
	www262.sakura.ne.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753789Ab2DCO25 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Apr 2012 10:28:57 -0400
In-Reply-To: <20120403130620.GA15385@1984>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pablo Neira Ayuso wrote:
> A bit better patch, no need to hold rcu_read_lock again in
> xt_ct_tg_timeout_put (even if that doesn't harm).

Patch looks OK.

By the way,

665 static struct nf_conn *
666 __nf_conntrack_alloc(struct net *net, u16 zone,
667                      const struct nf_conntrack_tuple *orig,
668                      const struct nf_conntrack_tuple *repl,
669                      gfp_t gfp, u32 hash)
670 {
(...snipped...)
680         atomic_inc(&net->ct.count);
(...snipped...)
698         ct = kmem_cache_alloc(net->ct.nf_conntrack_cachep, gfp);
699         if (ct == NULL) {
700                 atomic_dec(&net->ct.count);
701                 return ERR_PTR(-ENOMEM);
702         }
(...snipped...)
720         if (zone) {
721                 struct nf_conntrack_zone *nf_ct_zone;
722 
723                 nf_ct_zone = nf_ct_ext_add(ct, NF_CT_EXT_ZONE, GFP_ATOMIC);
724                 if (!nf_ct_zone)
725                         goto out_free;
726                 nf_ct_zone->id = zone;
727         }
(...snipped...)
737 out_free:

I think we want to call atomic_dec() here.

738         kmem_cache_free(net->ct.nf_conntrack_cachep, ct);
739         return ERR_PTR(-ENOMEM);
740 #endif
741 }
