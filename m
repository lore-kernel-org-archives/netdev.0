From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Inconsistend lock state in inet_frag_find
Date: Fri, 30 May 2008 19:10:46 +0200
Message-ID: <20080530171046.GA2420@ami.dom.local>
References: <20080529120248.GA9702@alice> <20080530105334.GA7378@ff.dom.local> <20080530131845.GA5167@alice>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: Eric Sesterhenn <snakebyte@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.189]:5127 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750909AbYE3RLq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 May 2008 13:11:46 -0400
Received: by nf-out-0910.google.com with SMTP id d3so50318nfc.21
        for <netdev@vger.kernel.org>; Fri, 30 May 2008 10:11:45 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080530131845.GA5167@alice>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 30, 2008 at 03:18:45PM +0200, Eric Sesterhenn wrote:
...
> with the patch applied i get the following lockdep warning:
> 
> [   63.531438] =================================
> [   63.531520] [ INFO: inconsistent lock state ]
> [   63.531520] 2.6.26-rc4 #7
> [   63.531520] ---------------------------------
> [   63.531520] inconsistent {softirq-on-W} -> {in-softirq-W} usage.
> [   63.531520] tcpsic6/3864 [HC0[0]:SC1[1]:HE1:SE0] takes:
> [   63.531520]  (&q->lock#2){-+..}, at: [<c07175b0>]
> ipv6_frag_rcv+0xd0/0xbd0
> [   63.531520] {softirq-on-W} state was registered at:
> [   63.531520]   [<c0143bba>] __lock_acquire+0x3aa/0x1080
> [   63.531520]   [<c0144906>] lock_acquire+0x76/0xa0
> [   63.531520]   [<c07a8f0b>] _spin_lock+0x2b/0x40
> [   63.531520]   [<c0727636>] nf_ct_frag6_gather+0x3f6/0x910
...

I hope it's not a Pandora's Box: looks like there are still a few of
these locks around, which could make more such reports, but since I
don't know this code, I'd prefer not to go ahead of lockdep...

Thanks,
Jarek P.

(Take 2: please revert the previous patch before applying.)
---

 net/ipv6/netfilter/nf_conntrack_reasm.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index 2dccad4..e65e26e 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -209,7 +209,9 @@ fq_find(__be32 id, struct in6_addr *src, struct in6_addr *dst)
 	arg.dst = dst;
 	hash = ip6qhashfn(id, src, dst);
 
+	local_bh_disable();
 	q = inet_frag_find(&nf_init_frags, &nf_frags, &arg, hash);
+	local_bh_enable();
 	if (q == NULL)
 		goto oom;
 
@@ -638,10 +640,10 @@ struct sk_buff *nf_ct_frag6_gather(struct sk_buff *skb)
 		goto ret_orig;
 	}
 
-	spin_lock(&fq->q.lock);
+	spin_lock_bh(&fq->q.lock);
 
 	if (nf_ct_frag6_queue(fq, clone, fhdr, nhoff) < 0) {
-		spin_unlock(&fq->q.lock);
+		spin_unlock_bh(&fq->q.lock);
 		pr_debug("Can't insert skb to queue\n");
 		fq_put(fq);
 		goto ret_orig;
@@ -653,7 +655,7 @@ struct sk_buff *nf_ct_frag6_gather(struct sk_buff *skb)
 		if (ret_skb == NULL)
 			pr_debug("Can't reassemble fragmented packets\n");
 	}
-	spin_unlock(&fq->q.lock);
+	spin_unlock_bh(&fq->q.lock);
 
 	fq_put(fq);
 	return ret_skb;
