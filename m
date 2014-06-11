From: Phoebe Buckheister <phoebe.buckheister-mPn0NPGs4xGatNDF+KUbs4QuADTiUCJX@public.gmane.org>
Subject: [PATCH v3 net-next 2/2] mac802154: don't
	deliver packets to devices that are down
Date: Wed, 11 Jun 2014 12:03:07 +0200
Message-ID: <1402480987-492-3-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
References: <1402480987-492-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1402480987-492-1-git-send-email-phoebe.buckheister-mPn0NPGs4xGatNDF+KUbs4QuADTiUCJX@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

Only one WPAN devices can be active at any given time, so only deliver
packets to that one interface that is actually up. Multiple monitors may
be up at any given time, but we don't have to deliver to monitors that
are down either.

Signed-off-by: Phoebe Buckheister <phoebe.buckheister-mPn0NPGs4xGatNDF+KUbs4QuADTiUCJX@public.gmane.org>
---
 net/mac802154/monitor.c |    3 ++-
 net/mac802154/rx.c      |   11 +++++++----
 net/mac802154/wpan.c    |   13 ++++++++-----
 3 files changed, 17 insertions(+), 10 deletions(-)

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
index 0597b96..7f820a1 100644
--- a/net/mac802154/rx.c
+++ b/net/mac802154/rx.c
@@ -64,20 +64,23 @@ mac802154_subif_rx(struct ieee802154_dev *hw, struct sk_buff *skb, u8 lqi)
 
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
-	dev_kfree_skb(skb);
+
+	return;
+
+fail:
+	kfree_skb(skb);
 }
 
 static void mac802154_rx_worker(struct work_struct *work)
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


------------------------------------------------------------------------------
HPCC Systems Open Source Big Data Platform from LexisNexis Risk Solutions
Find What Matters Most in Your Big Data with HPCC Systems
Open Source. Fast. Scalable. Simple. Ideal for Dirty Data.
Leverages Graph Analysis for Fast Processing & Easy Data Exploration
http://p.sf.net/sfu/hpccsystems
