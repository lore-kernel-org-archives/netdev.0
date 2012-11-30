From: Alan Ott <alan@signal11.us>
Subject: [PATCH 1/2] mac802154: fix memory leaks
Date: Thu, 29 Nov 2012 23:25:10 -0500
Message-ID: <1354249511-8086-1-git-send-email-alan@signal11.us>
References: <504EA95C.9010003@signal11.us>
Cc: linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Alan Ott <alan@signal11.us>
To: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>,
	Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:45912 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753463Ab2K3EZL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2012 23:25:11 -0500
In-Reply-To: <504EA95C.9010003@signal11.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

kfree_skb() was not getting called in the case of some failures.
This was pointed out by Eric Dumazet.

Signed-off-by: Alan Ott <alan@signal11.us>
---
 net/mac802154/tx.c   | 5 ++++-
 net/mac802154/wpan.c | 4 +++-
 2 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/net/mac802154/tx.c b/net/mac802154/tx.c
index 1a4df39..db63914 100644
--- a/net/mac802154/tx.c
+++ b/net/mac802154/tx.c
@@ -85,6 +85,7 @@ netdev_tx_t mac802154_tx(struct mac802154_priv *priv, struct sk_buff *skb,
 
 	if (!(priv->phy->channels_supported[page] & (1 << chan))) {
 		WARN_ON(1);
+		kfree_skb(skb);
 		return NETDEV_TX_OK;
 	}
 
@@ -103,8 +104,10 @@ netdev_tx_t mac802154_tx(struct mac802154_priv *priv, struct sk_buff *skb,
 	}
 
 	work = kzalloc(sizeof(struct xmit_work), GFP_ATOMIC);
-	if (!work)
+	if (!work) {
+		kfree_skb(skb);
 		return NETDEV_TX_BUSY;
+	}
 
 	INIT_WORK(&work->work, mac802154_xmit_worker);
 	work->skb = skb;
diff --git a/net/mac802154/wpan.c b/net/mac802154/wpan.c
index f30f6d4..1191039 100644
--- a/net/mac802154/wpan.c
+++ b/net/mac802154/wpan.c
@@ -327,8 +327,10 @@ mac802154_wpan_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	if (chan == MAC802154_CHAN_NONE ||
 	    page >= WPAN_NUM_PAGES ||
-	    chan >= WPAN_NUM_CHANNELS)
+	    chan >= WPAN_NUM_CHANNELS) {
+		kfree_skb(skb);
 		return NETDEV_TX_OK;
+	}
 
 	skb->skb_iif = dev->ifindex;
 	dev->stats.tx_packets++;
-- 
1.7.11.2
