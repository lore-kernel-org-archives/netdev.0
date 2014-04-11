From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net] pktgen: be friendly to LLTX devices
Date: Fri, 11 Apr 2014 13:22:00 +0200
Message-ID: <1397215320-1838-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, Jesper Dangaard Brouer <brouer@redhat.com>,
	Eric Dumazet <edumazet@google.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33956 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754140AbaDKLWE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Apr 2014 07:22:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Similarly to commit 43279500deca ("packet: respect devices with
LLTX flag in direct xmit"), we can basically apply the very same
to pktgen. This will help testing against LLTX devices such as
dummy driver (or others), which only have a single netdevice txq
and would otherwise require locking their txq from pktgen side
while e.g. in dummy case, we would not need any locking. Fix this
by making use of HARD_TX_{UN,}LOCK API, so that NETIF_F_LLTX will
be respected.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Eric Dumazet <edumazet@google.com>
---
 net/core/pktgen.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index d068ec2..0304f98 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -3338,7 +3338,9 @@ static void pktgen_xmit(struct pktgen_dev *pkt_dev)
 	queue_map = skb_get_queue_mapping(pkt_dev->skb);
 	txq = netdev_get_tx_queue(odev, queue_map);
 
-	__netif_tx_lock_bh(txq);
+	local_bh_disable();
+
+	HARD_TX_LOCK(odev, txq, smp_processor_id());
 
 	if (unlikely(netif_xmit_frozen_or_drv_stopped(txq))) {
 		ret = NETDEV_TX_BUSY;
@@ -3374,7 +3376,9 @@ static void pktgen_xmit(struct pktgen_dev *pkt_dev)
 		pkt_dev->last_ok = 0;
 	}
 unlock:
-	__netif_tx_unlock_bh(txq);
+	HARD_TX_UNLOCK(odev, txq);
+
+	local_bh_enable();
 
 	/* If pkt_dev->count is zero, then run forever */
 	if ((pkt_dev->count != 0) && (pkt_dev->sofar >= pkt_dev->count)) {
-- 
1.7.11.7
