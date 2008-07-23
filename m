From: David Miller <davem@davemloft.net>
Subject: Warning is now gone...
Date: Wed, 23 Jul 2008 14:05:18 -0700 (PDT)
Message-ID: <20080723.140518.138273179.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42206
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754164AbYGWVFR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2008 17:05:17 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 2D8FDC8C2D5
	for <netdev@vger.kernel.org>; Wed, 23 Jul 2008 14:05:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


As discussed, here is the warning removal, which I have checked
into net-2.6

It really was putting the cart before the horse, because
one should provide a sane alternative before making something
illegal :-)

I'll try to come up with a usable netif_tx_{free,unfreeze}()
set of interfaces.

netdev: Remove warning from __netif_schedule().

It isn't helping anything and we aren't going to be able to change all
the drivers that do queue wakeups in strange situations.

Just letting a noop_qdisc get scheduled will work because when
qdisc_run() executes via net_tx_work() it will simply find no packets
pending when it makes the ->dequeue() call in qdisc_restart.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/core/dev.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 6bf217d..ccf97f9 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1341,9 +1341,6 @@ static void dev_queue_xmit_nit(struct sk_buff *skb, struct net_device *dev)
 
 void __netif_schedule(struct Qdisc *q)
 {
-	if (WARN_ON_ONCE(q == &noop_qdisc))
-		return;
-
 	if (!test_and_set_bit(__QDISC_STATE_SCHED, &q->state)) {
 		struct softnet_data *sd;
 		unsigned long flags;
-- 
1.6.0.rc0.14.g95f8

