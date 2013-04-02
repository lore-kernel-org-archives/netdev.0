From: Alan Ott <alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org>
Subject: [PATCH 3/6] mac802154: Use netif flow control
Date: Tue,  2 Apr 2013 14:47:58 -0400
Message-ID: <1364928481-1813-4-git-send-email-alan@signal11.us>
References: <1364928481-1813-1-git-send-email-alan@signal11.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Alan Ott <alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: Alexander Smirnov <alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1364928481-1813-1-git-send-email-alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

Use netif_stop_queue() and netif_wake_queue() to control the flow of
packets to mac802154 devices.  Since many IEEE 802.15.4 devices have no
output buffer, and since the mac802154 xmit() function is designed to
block, netif_stop_queue() is called after each packet.

Signed-off-by: Alan Ott <alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org>
---
 net/mac802154/tx.c | 16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/net/mac802154/tx.c b/net/mac802154/tx.c
index a248246..fe3e02c 100644
--- a/net/mac802154/tx.c
+++ b/net/mac802154/tx.c
@@ -25,6 +25,7 @@
 #include <linux/if_arp.h>
 #include <linux/crc-ccitt.h>
 
+#include <net/ieee802154_netdev.h>
 #include <net/mac802154.h>
 #include <net/wpan-phy.h>
 
@@ -45,6 +46,7 @@ static void mac802154_xmit_worker(struct work_struct *work)
 {
 	struct xmit_work *xw = container_of(work, struct xmit_work, work);
 	u8 xmit_attempts = 0;
+	struct mac802154_sub_if_data *sdata;
 	int res;
 
 	mutex_lock(&xw->priv->phy->pib_lock);
@@ -71,6 +73,12 @@ static void mac802154_xmit_worker(struct work_struct *work)
 out:
 	mutex_unlock(&xw->priv->phy->pib_lock);
 
+	/* Restart the netif queue on each sub_if_data object. */
+	rcu_read_lock();
+	list_for_each_entry_rcu(sdata, &xw->priv->slaves, list) {
+		netif_wake_queue(sdata->dev);
+	}
+	rcu_read_unlock();
 
 	dev_kfree_skb(xw->skb);
 
@@ -81,6 +89,7 @@ netdev_tx_t mac802154_tx(struct mac802154_priv *priv, struct sk_buff *skb,
 			 u8 page, u8 chan)
 {
 	struct xmit_work *work;
+	struct mac802154_sub_if_data *sdata;
 
 	if (!(priv->phy->channels_supported[page] & (1 << chan))) {
 		WARN_ON(1);
@@ -108,6 +117,13 @@ netdev_tx_t mac802154_tx(struct mac802154_priv *priv, struct sk_buff *skb,
 		return NETDEV_TX_BUSY;
 	}
 
+	/* Stop the netif queue on each sub_if_data object. */
+	rcu_read_lock();
+	list_for_each_entry_rcu(sdata, &priv->slaves, list) {
+		netif_stop_queue(sdata->dev);
+	}
+	rcu_read_unlock();
+
 	INIT_WORK(&work->work, mac802154_xmit_worker);
 	work->skb = skb;
 	work->priv = priv;
-- 
1.7.11.2


------------------------------------------------------------------------------
Minimize network downtime and maximize team effectiveness.
Reduce network management and security costs.Learn how to hire 
the most talented Cisco Certified professionals. Visit the 
Employer Resources Portal
http://www.cisco.com/web/learning/employer_resources/index.html
