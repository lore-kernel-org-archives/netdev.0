From: Helmut Schaa <helmut.schaa@googlemail.com>
Subject: [PATCH] net: fix tx queue selection for bridged devices implementing select_queue
Date: Fri,  3 Sep 2010 14:39:56 +0200
Message-ID: <1283517596-2382-1-git-send-email-helmut.schaa@googlemail.com>
Cc: netdev@vger.kernel.org, Johannes Berg <johannes@sipsolutions.net>,
	Krishna Kumar <krkumar2@in.ibm.com>,
	Helmut Schaa <helmut.schaa@googlemail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:51856 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755301Ab0ICMk5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Sep 2010 08:40:57 -0400
Received: by fxm13 with SMTP id 13so1025069fxm.19
        for <netdev@vger.kernel.org>; Fri, 03 Sep 2010 05:40:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a net device is implementing the select_queue callback and is part of
a bridge, frames coming from the bridge already have a tx queue associated
to the socket (introduced in commit a4ee3ce3293dc931fab19beb472a8bde1295aebe,
"net: Use sk_tx_queue_mapping for connected sockets"). The call to
sk_tx_queue_get will then return the tx queue used by the bridge instead
of calling the select_queue callback.

In case of mac80211 this broke QoS which is implemented by using the
select_queue callback. Furthermore it introduced problems with rt2x00
because frames with the same TID and RA sometimes appeared on different
tx queues which the hw cannot handle correctly.

Fix this by always calling select_queue first if it is available and only
afterwards use the socket tx queue mapping.

Signed-off-by: Helmut Schaa <helmut.schaa@googlemail.com>
---

JFI this patch is based on wireless-testing.

 net/core/dev.c |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 3721fbb..b9b22a3 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2058,16 +2058,16 @@ static struct netdev_queue *dev_pick_tx(struct net_device *dev,
 					struct sk_buff *skb)
 {
 	int queue_index;
-	struct sock *sk = skb->sk;
+	const struct net_device_ops *ops = dev->netdev_ops;
 
-	queue_index = sk_tx_queue_get(sk);
-	if (queue_index < 0) {
-		const struct net_device_ops *ops = dev->netdev_ops;
+	if (ops->ndo_select_queue) {
+		queue_index = ops->ndo_select_queue(dev, skb);
+		queue_index = dev_cap_txqueue(dev, queue_index);
+	} else {
+		struct sock *sk = skb->sk;
+		queue_index = sk_tx_queue_get(sk);
+		if (queue_index < 0) {
 
-		if (ops->ndo_select_queue) {
-			queue_index = ops->ndo_select_queue(dev, skb);
-			queue_index = dev_cap_txqueue(dev, queue_index);
-		} else {
 			queue_index = 0;
 			if (dev->real_num_tx_queues > 1)
 				queue_index = skb_tx_hash(dev, skb);
-- 
1.7.1

