From: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
Subject: [PATCH v2 net-next 2/2] mac802154: don't deliver packets to devices that are down
Date: Tue, 10 Jun 2014 18:11:11 +0200
Message-ID: <1402416671-30305-3-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
References: <1402416671-30305-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Cc: linux-zigbee-devel@lists.sourceforge.net, davem@davemloft.net,
	Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw1.uni-kl.de ([131.246.120.220]:50758 "EHLO
	mailgw1.uni-kl.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752336AbaFJQLt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jun 2014 12:11:49 -0400
Received: from itwm2.itwm.fhg.de (itwm2.itwm.fhg.de [131.246.191.3])
	by mailgw1.uni-kl.de (8.14.4/8.14.4/Debian-7) with ESMTP id s5AGBSVD021121
	(version=TLSv1/SSLv3 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 10 Jun 2014 18:11:30 +0200
In-Reply-To: <1402416671-30305-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Only one WPAN devices can be active at any given time, so only deliver
packets to that one interface that is actually up. Multiple monitors may
be up at any given time, but we don't have to deliver to monitors that
are down either.

Signed-off-by: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
---
 net/mac802154/monitor.c |    3 ++-
 net/mac802154/rx.c      |    9 ++++++---
 net/mac802154/wpan.c    |   13 ++++++++-----
 3 files changed, 16 insertions(+), 9 deletions(-)

diff --git a/net/mac802154/monitor.c b/net/mac802154/monitor.c
index 434a26f..a68230e 100644
--- a/net/mac802154/monitor.c
+++ b/net/mac802154/monitor.c
@@ -70,7 +70,8 @@ void mac802154_monitors_rx(struct mac802154_priv *priv, struct sk_buff *skb)
 
 	rcu_read_lock();
 	list_for_each_entry_rcu(sdata, &priv->slaves, list) {
-		if (sdata->type != IEEE802154_DEV_MONITOR)
+		if (sdata->type != IEEE802154_DEV_MONITOR ||
+		    !netif_running(sdata->dev))
 			continue;
 
 		skb2 = skb_clone(skb, GFP_ATOMIC);
diff --git a/net/mac802154/rx.c b/net/mac802154/rx.c
index 0597b96..46440b9 100644
--- a/net/mac802154/rx.c
+++ b/net/mac802154/rx.c
@@ -64,19 +64,22 @@ mac802154_subif_rx(struct ieee802154_dev *hw, struct sk_buff *skb, u8 lqi)
 
 		if (skb->len < 2) {
 			pr_debug("got invalid frame\n");
-			goto out;
+			goto fail;
 		}
 		crc = crc_ccitt(0, skb->data, skb->len);
 		if (crc) {
 			pr_debug("CRC mismatch\n");
-			goto out;
+			goto fail;
 		}
 		skb_trim(skb, skb->len - 2); /* CRC */
 	}
 
 	mac802154_monitors_rx(priv, skb);
 	mac802154_wpans_rx(priv, skb);
-out:
+
+	return;
+
+fail:
 	dev_kfree_skb(skb);
 }
 
diff --git a/net/mac802154/wpan.c b/net/mac802154/wpan.c
index c8cfd54..3c3069f 100644
--- a/net/mac802154/wpan.c
+++ b/net/mac802154/wpan.c
@@ -567,7 +567,6 @@ static int mac802154_parse_frame_start(struct sk_buff *skb,
 void mac802154_wpans_rx(struct mac802154_priv *priv, struct sk_buff *skb)
 {
 	int ret;
-	struct sk_buff *sskb;
 	struct mac802154_sub_if_data *sdata;
 	struct ieee802154_hdr hdr;
 
@@ -579,12 +578,16 @@ void mac802154_wpans_rx(struct mac802154_priv *priv, struct sk_buff *skb)
 
 	rcu_read_lock();
 	list_for_each_entry_rcu(sdata, &priv->slaves, list) {
-		if (sdata->type != IEEE802154_DEV_WPAN)
+		if (sdata->type != IEEE802154_DEV_WPAN ||
+		    !netif_running(sdata->dev))
 			continue;
 
-		sskb = skb_clone(skb, GFP_ATOMIC);
-		if (sskb)
-			mac802154_subif_frame(sdata, sskb, &hdr);
+		mac802154_subif_frame(sdata, skb, &hdr);
+		skb = NULL;
+		break;
 	}
 	rcu_read_unlock();
+
+	if (skb)
+		kfree_skb(skb);
 }
-- 
1.7.9.5
