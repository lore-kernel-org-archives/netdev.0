From: Phoebe Buckheister <phoebe.buckheister-mPn0NPGs4xGatNDF+KUbs4QuADTiUCJX@public.gmane.org>
Subject: [PATCH net-next 2/2] mac802154: don't deliver
	packets to devices that are down
Date: Tue, 10 Jun 2014 17:08:42 +0200
Message-ID: <1402412922-14180-3-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
References: <1402412922-14180-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1402412922-14180-1-git-send-email-phoebe.buckheister-mPn0NPGs4xGatNDF+KUbs4QuADTiUCJX@public.gmane.org>
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
packets to that one interface that is actually up.

Signed-off-by: Phoebe Buckheister <phoebe.buckheister-mPn0NPGs4xGatNDF+KUbs4QuADTiUCJX@public.gmane.org>
---
 net/mac802154/wpan.c |   12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/net/mac802154/wpan.c b/net/mac802154/wpan.c
index c8cfd54..1ba648e 100644
--- a/net/mac802154/wpan.c
+++ b/net/mac802154/wpan.c
@@ -567,7 +567,6 @@ static int mac802154_parse_frame_start(struct sk_buff *skb,
 void mac802154_wpans_rx(struct mac802154_priv *priv, struct sk_buff *skb)
 {
 	int ret;
-	struct sk_buff *sskb;
 	struct mac802154_sub_if_data *sdata;
 	struct ieee802154_hdr hdr;
 
@@ -579,12 +578,15 @@ void mac802154_wpans_rx(struct mac802154_priv *priv, struct sk_buff *skb)
 
 	rcu_read_lock();
 	list_for_each_entry_rcu(sdata, &priv->slaves, list) {
-		if (sdata->type != IEEE802154_DEV_WPAN)
+		if (sdata->type != IEEE802154_DEV_WPAN ||
+		    !netif_running(sdata->dev))
 			continue;
 
-		sskb = skb_clone(skb, GFP_ATOMIC);
-		if (sskb)
-			mac802154_subif_frame(sdata, sskb, &hdr);
+		skb = skb_clone(skb, GFP_ATOMIC);
+		if (skb)
+			mac802154_subif_frame(sdata, skb, &hdr);
+
+		break;
 	}
 	rcu_read_unlock();
 }
-- 
1.7.9.5


------------------------------------------------------------------------------
HPCC Systems Open Source Big Data Platform from LexisNexis Risk Solutions
Find What Matters Most in Your Big Data with HPCC Systems
Open Source. Fast. Scalable. Simple. Ideal for Dirty Data.
Leverages Graph Analysis for Fast Processing & Easy Data Exploration
http://p.sf.net/sfu/hpccsystems
