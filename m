From: Tom Herbert <therbert@google.com>
Subject: [PATCH 3/5] tun: tun.c calls skb_get_sw_rxhash
Date: Wed, 20 Nov 2013 12:27:30 -0800 (PST)
Message-ID: <alpine.DEB.2.02.1311201220180.19396@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, edumazet@google.com, hkchu@google.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f201.google.com ([209.85.223.201]:53560 "EHLO
	mail-ie0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754989Ab3KTU1c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Nov 2013 15:27:32 -0500
Received: by mail-ie0-f201.google.com with SMTP id at1so533879iec.2
        for <netdev@vger.kernel.org>; Wed, 20 Nov 2013 12:27:31 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In tun.c, skb_get_rxhash is called on the transmit path with the
expectation that this matches the hash value returned by the same flow
in the receive path.  If the hardware is providing the rxhash values,
the computation on the transmit path will not match that of the
received path for the flow, so the flow lookups will always fail
on the receive side and the queue selection optimization is unused.

The patch changes the calls to skb_get_sw_rxhash to ensure that the
stack's rxhash calculation is always used for flow matching.  This
should always generate the same hash for a flow in both transmit and
receive paths.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 drivers/net/tun.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 7cb105c..c3e20c4 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -358,7 +358,7 @@ static u16 tun_select_queue(struct net_device *dev, struct sk_buff *skb)
 	rcu_read_lock();
 	numqueues = ACCESS_ONCE(tun->numqueues);
 
-	txq = skb_get_rxhash(skb);
+	txq = skb_get_sw_rxhash(skb);
 	if (txq) {
 		e = tun_flow_find(&tun->flows[tun_hashfn(txq)], txq);
 		if (e)
@@ -1138,7 +1138,7 @@ static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
 	skb_reset_network_header(skb);
 	skb_probe_transport_header(skb, 0);
 
-	rxhash = skb_get_rxhash(skb);
+	rxhash = skb_get_sw_rxhash(skb);
 	netif_rx_ni(skb);
 
 	tun->dev->stats.rx_packets++;
-- 
1.8.4.1
