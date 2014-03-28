From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 3/3] net: Warn when a skb is freed inappropriately in hard irq context.
Date: Thu, 27 Mar 2014 18:23:22 -0700
Message-ID: <87vbuzjeut.fsf_-_@x220.int.ebiederm.org>
References: <20140314.225923.61318448733570839.davem@davemloft.net>
	<87k3bwqgf7.fsf@xmission.com> <877g7wqg8e.fsf_-_@xmission.com>
	<20140317.154916.2276987764507311378.davem@davemloft.net>
	<87iorcgh5d.fsf_-_@xmission.com> <87fvmgf2c7.fsf_-_@xmission.com>
	<1395149407.22343.8.camel@deadeye.wl.decadent.org.uk>
	<87lhw7inzg.fsf@nemi.mork.no>
	<1395156229.9114.35.camel@edumazet-glaptop2.roam.corp.google.com>
	<2c96faab-4293-4e7f-b8e0-4997af745fbf@email.android.com>
	<063D6719AE5E284EB5DD2968C1650D6D0F6E02DB@AcuExch.aculab.com>
	<87mwgbkttv.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: =?utf-8?Q?'Bj=C3=B8rn?= Mork' <bjorn@mork.no>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Ben Hutchings <ben@decadent.org.uk>,
	"stephen\@networkplumber.org" <stephen@networkplumber.org>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	"xiyou.wangcong\@gmail.com" <xiyou.wangcong@gmail.com>,
	"mpm\@selenic.com" <mpm@selenic.com>,
	"satyam.sharma\@gmail.com" <satyam.sharma@gmail.com>,
	David Laight <David.Laight@ACULAB.COM>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:42110 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756819AbaC1BXd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2014 21:23:33 -0400
In-Reply-To: <87mwgbkttv.fsf_-_@x220.int.ebiederm.org> (Eric W. Biederman's
	message of "Thu, 27 Mar 2014 18:14:36 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Use skb_irq_freeable to warn on all cases where it is not safe to free a
skb in hard irq context.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/core/skbuff.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 3f14c638c2b1..aaee52840a7d 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -554,14 +554,14 @@ static void kfree_skbmem(struct sk_buff *skb)
 
 static void skb_release_head_state(struct sk_buff *skb)
 {
+	WARN_ON(in_irq() && !skb_irq_freeable(skb));
+
 	skb_dst_drop(skb);
 #ifdef CONFIG_XFRM
 	secpath_put(skb->sp);
 #endif
-	if (skb->destructor) {
-		WARN_ON(in_irq());
+	if (skb->destructor)
 		skb->destructor(skb);
-	}
 #if IS_ENABLED(CONFIG_NF_CONNTRACK)
 	nf_conntrack_put(skb->nfct);
 #endif
-- 
1.7.10.4
