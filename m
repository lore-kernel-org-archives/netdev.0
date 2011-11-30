From: Alexander Smirnov <alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 07/12] [IEEE802154] ieee802154: define
	simplified mlme interface
Date: Wed, 30 Nov 2011 17:25:26 +0300
Message-ID: <1322663126-3987-1-git-send-email-alex.bluesman.smirnov@gmail.com>
References: <20111130141827.GA3739@avtobot.cybertron>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <20111130141827.GA3739-AUGNqIMGY+bGcXpsla5Oef8+0UxHXcjY@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

Define light-weight mlme interface.

Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 include/net/ieee802154_netdev.h |   11 +++++++++++
 net/ieee802154/nl-mac.c         |    2 +-
 2 files changed, 12 insertions(+), 1 deletions(-)

diff --git a/include/net/ieee802154_netdev.h b/include/net/ieee802154_netdev.h
index 12a7ee4..5264b00 100644
--- a/include/net/ieee802154_netdev.h
+++ b/include/net/ieee802154_netdev.h
@@ -83,7 +83,12 @@ struct wpan_phy;
  * get_phy should increment the reference counting on returned phy.
  * Use wpan_wpy_put to put that reference.
  */
+struct simple_mlme_ops {
+	struct wpan_phy *(*get_phy)(const struct net_device *dev);
+};
 struct ieee802154_mlme_ops {
+	struct simple_mlme_ops wpan_ops;
+
 	int (*assoc_req)(struct net_device *dev,
 			struct ieee802154_addr *addr,
 			u8 channel, u8 page, u8 cap);
@@ -112,6 +117,12 @@ struct ieee802154_mlme_ops {
 	u8 (*get_bsn)(const struct net_device *dev);
 };
 
+static inline struct simple_mlme_ops *simple_mlme_ops(
+		const struct net_device *dev)
+{
+	return dev->ml_priv;
+}
+
 static inline struct ieee802154_mlme_ops *ieee802154_mlme_ops(
 		const struct net_device *dev)
 {
diff --git a/net/ieee802154/nl-mac.c b/net/ieee802154/nl-mac.c
index adaf462..1d23aa6 100644
--- a/net/ieee802154/nl-mac.c
+++ b/net/ieee802154/nl-mac.c
@@ -263,7 +263,7 @@ static int ieee802154_nl_fill_iface(struct sk_buff *msg, u32 pid,
 	if (!hdr)
 		goto out;
 
-	phy = ieee802154_mlme_ops(dev)->get_phy(dev);
+	phy = simple_mlme_ops(dev)->get_phy(dev);
 	BUG_ON(!phy);
 
 	NLA_PUT_STRING(msg, IEEE802154_ATTR_DEV_NAME, dev->name);
-- 
1.7.2.3


------------------------------------------------------------------------------
All the data continuously generated in your IT infrastructure 
contains a definitive record of customers, application performance, 
security threats, fraudulent activity, and more. Splunk takes this 
data and makes sense of it. IT sense. And common sense.
http://p.sf.net/sfu/splunk-novd2d
