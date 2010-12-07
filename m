From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net: call dev_queue_xmit_nit() after
 skb_dst_drop()
Date: Tue, 07 Dec 2010 08:19:19 +0100
Message-ID: <1291706359.2769.17.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:41120 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752705Ab0LGHTY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Dec 2010 02:19:24 -0500
Received: by wyb28 with SMTP id 28so12918307wyb.19
        for <netdev@vger.kernel.org>; Mon, 06 Dec 2010 23:19:22 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Avoid some atomic ops on dst refcount, calling dev_queue_xmit_nit()
after skb_dst_drop() in dev_hard_start_xmit().

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
Next patch will perform the sk_run_filter() in dev_queue_xmit_nit(),
before cloning skb and af_packet rcv() call.

 net/core/dev.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 55ff66f..59360ef 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2025,9 +2025,6 @@ int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
 	int rc = NETDEV_TX_OK;
 
 	if (likely(!skb->next)) {
-		if (!list_empty(&ptype_all))
-			dev_queue_xmit_nit(skb, dev);
-
 		/*
 		 * If device doesnt need skb->dst, release it right now while
 		 * its hot in this cpu cache
@@ -2037,6 +2034,9 @@ int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev,
 
 		skb_orphan_try(skb);
 
+		if (!list_empty(&ptype_all))
+			dev_queue_xmit_nit(skb, dev);
+
 		if (vlan_tx_tag_present(skb) &&
 		    !(dev->features & NETIF_F_HW_VLAN_TX)) {
 			skb = __vlan_put_tag(skb, vlan_tx_tag_get(skb));


