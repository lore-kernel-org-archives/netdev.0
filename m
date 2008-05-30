From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH][NETFILTER]: fix inconsistent lock state in
	nf_ct_frag6_gather()
Date: Fri, 30 May 2008 23:53:14 +0200
Message-ID: <20080530215314.GA2485@ami.dom.local>
References: <20080529120248.GA9702@alice> <20080530105334.GA7378@ff.dom.local> <20080530211315.GA16064@alice>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Sesterhenn <snakebyte@gmx.de>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.169]:7011 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753075AbYE3Vx7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 May 2008 17:53:59 -0400
Received: by ug-out-1314.google.com with SMTP id h2so20077ugf.16
        for <netdev@vger.kernel.org>; Fri, 30 May 2008 14:53:58 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080530211315.GA16064@alice>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 30, 2008 at 11:13:15PM +0200, Eric Sesterhenn wrote:
...
> This one does the trick, i let tcp6sic run a bit longer and didnt
> see any more lockdep warnings. 
> 
> Thanks, Eric


David & Patrick,

It looks like this patch could be applied.

Thanks,
Jarek P.

-------------------------->

[NETFILTER]: fix inconsistent lock state in nf_ct_frag6_gather()

[   63.531438] =================================
[   63.531520] [ INFO: inconsistent lock state ]
[   63.531520] 2.6.26-rc4 #7
[   63.531520] ---------------------------------
[   63.531520] inconsistent {softirq-on-W} -> {in-softirq-W} usage.
[   63.531520] tcpsic6/3864 [HC0[0]:SC1[1]:HE1:SE0] takes:
[   63.531520]  (&q->lock#2){-+..}, at: [<c07175b0>] ipv6_frag_rcv+0xd0/0xbd0
[   63.531520] {softirq-on-W} state was registered at:
[   63.531520]   [<c0143bba>] __lock_acquire+0x3aa/0x1080
[   63.531520]   [<c0144906>] lock_acquire+0x76/0xa0
[   63.531520]   [<c07a8f0b>] _spin_lock+0x2b/0x40
[   63.531520]   [<c0727636>] nf_ct_frag6_gather+0x3f6/0x910
 ...

According to this and another similar lockdep report inet_fragment
locks are taken from nf_ct_frag6_gather() with softirqs enabled, but
these locks are mainly used in softirq context, so disabling BHs is
necessary.


Reported-and-tested-by: Eric Sesterhenn <snakebyte@gmx.de>
Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

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
