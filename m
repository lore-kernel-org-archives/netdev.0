From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [PATCH] net: Validate frames going through the direct_xmit path
Date: Tue, 02 Sep 2014 18:55:48 -0400
Message-ID: <20140902225548.885.79277.stgit@ahduyck-bv4.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:19316 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752046AbaIBXCw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Sep 2014 19:02:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In commit 50cbe9ab5f8d92d2d4a327b56e96559d8f63a1fa "net: Validate xmit SKBs
right when we pull them out of the qdisc" the validation code was moved out
of dev_hard_start_xmit and into dequeue_skb.  However this overlooked the
fact that we do not always enqueue the skb onto a qdisc.

As a result I was seeing issues trying to connect to a vhost_net interface
after this patch was applied.  To resolve the issue I have added a call to
validate_xmit_skb in sched_direct_xmit and this seems to have resolved the
issue by restoring the validation to this xmit path.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 net/sched/sch_generic.c |    9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index a8bf9f9..203ee65 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -128,8 +128,13 @@ int sch_direct_xmit(struct sk_buff *skb, struct Qdisc *q,
 	spin_unlock(root_lock);
 
 	HARD_TX_LOCK(dev, txq, smp_processor_id());
-	if (!netif_xmit_frozen_or_stopped(txq))
-		skb = dev_hard_start_xmit(skb, dev, txq, &ret);
+	if (!netif_xmit_frozen_or_stopped(txq)) {
+		skb = validate_xmit_skb(skb, dev);
+		if (!skb)
+			ret = NETDEV_TX_OK;
+		else
+			skb = dev_hard_start_xmit(skb, dev, txq, &ret);
+	}
 
 	HARD_TX_UNLOCK(dev, txq);
 
