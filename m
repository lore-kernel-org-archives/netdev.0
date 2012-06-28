From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: unlock busylock before servicing qdisc
Date: Thu, 28 Jun 2012 21:22:42 +0200
Message-ID: <1340911362.13187.183.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Tom Parkin <tparkin@katalix.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:58801 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751399Ab2F1TWq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jun 2012 15:22:46 -0400
Received: by wibhm11 with SMTP id hm11so396573wib.1
        for <netdev@vger.kernel.org>; Thu, 28 Jun 2012 12:22:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

commit 79640a4ca6 (net: add additional lock to qdisc to increase
throughput) added a LOCKDEP occurrence on bonding/l2tp or other stacked
devices, if several levels use a qdisc.

We should release the busylock before the call to sch_direct_xmit() or
else LOCKDEP complains we try to lock busylock again in the lower dev
qdisc handler.

This of course is a false lockdep positive, but this
patch is the simplest way to get rid of it.

Reported-by: Tom Parkin <tparkin@katalix.com>
Tested-by: Tom Parkin <tparkin@katalix.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>
---
 net/core/dev.c |   12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 6df2140..d265c67 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2412,13 +2412,13 @@ static inline int __dev_xmit_skb(struct sk_buff
*skb, struct Qdisc *q,
 
 		qdisc_bstats_update(q, skb);
 
-		if (sch_direct_xmit(skb, q, dev, txq, root_lock)) {
-			if (unlikely(contended)) {
-				spin_unlock(&q->busylock);
-				contended = false;
-			}
+		if (unlikely(contended)) {
+			spin_unlock(&q->busylock);
+			contended = false;
+		}
+		if (sch_direct_xmit(skb, q, dev, txq, root_lock))
 			__qdisc_run(q);
-		} else
+		else
 			qdisc_run_end(q);
 
 		rc = NET_XMIT_SUCCESS;
