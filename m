From: Alan Ott <alan@signal11.us>
Subject: [PATCH v2 1/4] mac802154: Do not try to resend failed packets
Date: Wed,  3 Apr 2013 10:00:55 -0400
Message-ID: <1364997658-16498-2-git-send-email-alan@signal11.us>
References: <1364928481-1813-1-git-send-email-alan@signal11.us>
 <1364997658-16498-1-git-send-email-alan@signal11.us>
Cc: linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Alan Ott <alan@signal11.us>
To: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>,
	Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:58747 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758194Ab3DCOBI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Apr 2013 10:01:08 -0400
In-Reply-To: <1364997658-16498-1-git-send-email-alan@signal11.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When ops->xmit() fails, drop the packet. Devices which support hardware
ack and retry (which include all devices currently supported by mainline),
will automatically retry sending the packet (in the hardware) up to 3
times, per the 802.15.4 spec.  There is no need, and it is incorrect to
try to do it in mac802154.

Signed-off-by: Alan Ott <alan@signal11.us>
---
 net/mac802154/mac802154.h |  2 --
 net/mac802154/tx.c        | 12 ++----------
 2 files changed, 2 insertions(+), 12 deletions(-)

diff --git a/net/mac802154/mac802154.h b/net/mac802154/mac802154.h
index 21fa386..5c9e021 100644
--- a/net/mac802154/mac802154.h
+++ b/net/mac802154/mac802154.h
@@ -88,8 +88,6 @@ struct mac802154_sub_if_data {
 
 #define mac802154_to_priv(_hw)	container_of(_hw, struct mac802154_priv, hw)
 
-#define MAC802154_MAX_XMIT_ATTEMPTS	3
-
 #define MAC802154_CHAN_NONE		(~(u8)0) /* No channel is assigned */
 
 extern struct ieee802154_reduced_mlme_ops mac802154_mlme_reduced;
diff --git a/net/mac802154/tx.c b/net/mac802154/tx.c
index 4e09d07..7264874 100644
--- a/net/mac802154/tx.c
+++ b/net/mac802154/tx.c
@@ -39,7 +39,6 @@ struct xmit_work {
 	struct mac802154_priv *priv;
 	u8 chan;
 	u8 page;
-	u8 xmit_attempts;
 };
 
 static void mac802154_xmit_worker(struct work_struct *work)
@@ -60,18 +59,12 @@ static void mac802154_xmit_worker(struct work_struct *work)
 	}
 
 	res = xw->priv->ops->xmit(&xw->priv->hw, xw->skb);
+	if (res)
+		pr_debug("transmission failed\n");
 
 out:
 	mutex_unlock(&xw->priv->phy->pib_lock);
 
-	if (res) {
-		if (xw->xmit_attempts++ < MAC802154_MAX_XMIT_ATTEMPTS) {
-			queue_work(xw->priv->dev_workqueue, &xw->work);
-			return;
-		} else
-			pr_debug("transmission failed for %d times",
-				 MAC802154_MAX_XMIT_ATTEMPTS);
-	}
 
 	dev_kfree_skb(xw->skb);
 
@@ -114,7 +107,6 @@ netdev_tx_t mac802154_tx(struct mac802154_priv *priv, struct sk_buff *skb,
 	work->priv = priv;
 	work->page = page;
 	work->chan = chan;
-	work->xmit_attempts = 0;
 
 	queue_work(priv->dev_workqueue, &work->work);
 
-- 
1.7.11.2
