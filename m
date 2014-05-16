From: Phoebe Buckheister <phoebe.buckheister-mPn0NPGs4xGatNDF+KUbs4QuADTiUCJX@public.gmane.org>
Subject: [PATCH net-next 09/11] mac802154: propagate
	device address changes to llsec
Date: Fri, 16 May 2014 17:46:43 +0200
Message-ID: <1400255205-9031-10-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
References: <1400255205-9031-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1400255205-9031-1-git-send-email-phoebe.buckheister-mPn0NPGs4xGatNDF+KUbs4QuADTiUCJX@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Phoebe Buckheister <phoebe.buckheister-mPn0NPGs4xGatNDF+KUbs4QuADTiUCJX@public.gmane.org>
---
 net/mac802154/mac_cmd.c |   24 +++++++++++++++++++++++-
 net/mac802154/wpan.c    |   26 ++++++++++++++++++++++++--
 2 files changed, 47 insertions(+), 3 deletions(-)

diff --git a/net/mac802154/mac_cmd.c b/net/mac802154/mac_cmd.c
index afb4e2c..bf80913 100644
--- a/net/mac802154/mac_cmd.c
+++ b/net/mac802154/mac_cmd.c
@@ -40,6 +40,9 @@ static int mac802154_mlme_start_req(struct net_device *dev,
 				    u8 pan_coord, u8 blx,
 				    u8 coord_realign)
 {
+	struct ieee802154_mlme_ops *ops = ieee802154_mlme_ops(dev);
+	int rc = 0;
+
 	BUG_ON(addr->mode != IEEE802154_ADDR_SHORT);
 
 	mac802154_dev_set_pan_id(dev, addr->pan_id);
@@ -47,12 +50,31 @@ static int mac802154_mlme_start_req(struct net_device *dev,
 	mac802154_dev_set_ieee_addr(dev);
 	mac802154_dev_set_page_channel(dev, page, channel);
 
+	if (ops->llsec) {
+		struct ieee802154_llsec_params params;
+		int changed = 0;
+
+		params.coord_shortaddr = addr->short_addr;
+		changed |= IEEE802154_LLSEC_PARAM_COORD_SHORTADDR;
+
+		params.pan_id = addr->pan_id;
+		changed |= IEEE802154_LLSEC_PARAM_PAN_ID;
+
+		params.hwaddr = ieee802154_devaddr_from_raw(dev->dev_addr);
+		changed |= IEEE802154_LLSEC_PARAM_HWADDR;
+
+		params.coord_hwaddr = params.hwaddr;
+		changed |= IEEE802154_LLSEC_PARAM_COORD_HWADDR;
+
+		rc = ops->llsec->set_params(dev, &params, changed);
+	}
+
 	/* FIXME: add validation for unused parameters to be sane
 	 * for SoftMAC
 	 */
 	ieee802154_nl_start_confirm(dev, IEEE802154_SUCCESS);
 
-	return 0;
+	return rc;
 }
 
 static struct wpan_phy *mac802154_get_phy(const struct net_device *dev)
diff --git a/net/mac802154/wpan.c b/net/mac802154/wpan.c
index 00729ca..23bc91c 100644
--- a/net/mac802154/wpan.c
+++ b/net/mac802154/wpan.c
@@ -35,6 +35,28 @@
 
 #include "mac802154.h"
 
+static int mac802154_wpan_update_llsec(struct net_device *dev)
+{
+	struct mac802154_sub_if_data *priv = netdev_priv(dev);
+	struct ieee802154_mlme_ops *ops = ieee802154_mlme_ops(dev);
+	int rc = 0;
+
+	if (ops->llsec) {
+		struct ieee802154_llsec_params params;
+		int changed = 0;
+
+		params.pan_id = priv->pan_id;
+		changed |= IEEE802154_LLSEC_PARAM_PAN_ID;
+
+		params.hwaddr = priv->extended_addr;
+		changed |= IEEE802154_LLSEC_PARAM_HWADDR;
+
+		rc = ops->llsec->set_params(dev, &params, changed);
+	}
+
+	return rc;
+}
+
 static int
 mac802154_wpan_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
@@ -81,7 +103,7 @@ mac802154_wpan_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 		priv->pan_id = cpu_to_le16(sa->addr.pan_id);
 		priv->short_addr = cpu_to_le16(sa->addr.short_addr);
 
-		err = 0;
+		err = mac802154_wpan_update_llsec(dev);
 		break;
 	}
 
@@ -99,7 +121,7 @@ static int mac802154_wpan_mac_addr(struct net_device *dev, void *p)
 	/* FIXME: validate addr */
 	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
 	mac802154_dev_set_ieee_addr(dev);
-	return 0;
+	return mac802154_wpan_update_llsec(dev);
 }
 
 int mac802154_set_mac_params(struct net_device *dev,
-- 
1.7.9.5


------------------------------------------------------------------------------
"Accelerate Dev Cycles with Automated Cross-Browser Testing - For FREE
Instantly run your Selenium tests across 300+ browser/OS combos.
Get unparalleled scalability from the best Selenium testing platform available
Simple to use. Nothing to install. Get started now for free."
http://p.sf.net/sfu/SauceLabs
