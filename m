From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH] qdisc: exit case fixes for skb list handling in
	qdisc layer
Date: Wed, 03 Sep 2014 12:12:50 +0200
Message-ID: <20140903101250.7668.91659.stgit@dragon>
References: <1409671557.3173.110.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Florian Westphal <fw@strlen.de>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Daniel Borkmann <dborkman@redhat.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36447 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932398AbaICKMv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Sep 2014 06:12:51 -0400
In-Reply-To: <1409671557.3173.110.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

More minor fixes to merge commit 53fda7f7f9e (Merge branch 'xmit_list')
that allows us to work with a list of SKBs.

Fixing exit cases in qdisc_reset() and qdisc_destroy(), where a
leftover requeued SKB (qdisc->gso_skb) can have the potential of
being a skb list, thus use kfree_skb_list().

This is a followup to commit 10770bc2d1 ("qdisc: adjustments for
API allowing skb list xmits").

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---

 net/sched/sch_generic.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 5b261e9..19696eb 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -621,7 +621,7 @@ void qdisc_reset(struct Qdisc *qdisc)
 		ops->reset(qdisc);
 
 	if (qdisc->gso_skb) {
-		kfree_skb(qdisc->gso_skb);
+		kfree_skb_list(qdisc->gso_skb);
 		qdisc->gso_skb = NULL;
 		qdisc->q.qlen = 0;
 	}
@@ -657,7 +657,7 @@ void qdisc_destroy(struct Qdisc *qdisc)
 	module_put(ops->owner);
 	dev_put(qdisc_dev(qdisc));
 
-	kfree_skb(qdisc->gso_skb);
+	kfree_skb_list(qdisc->gso_skb);
 	/*
 	 * gen_estimator est_timer() might access qdisc->q.lock,
 	 * wait a RCU grace period before freeing qdisc.
