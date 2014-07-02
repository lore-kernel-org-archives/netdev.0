From: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH v2 net-next 04/13] at86rf230: remove
	is212 and add driver data
Date: Wed,  2 Jul 2014 17:10:01 +0200
Message-ID: <1404313810-30232-5-git-send-email-alex.aring@gmail.com>
References: <1404313810-30232-1-git-send-email-alex.aring@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1404313810-30232-1-git-send-email-alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch adds a new at86rf2xx_chip_data structure which holds device
specific attributes. Instead of runtime decisions "if (is212())" we set
callbacks/attributes while device detection.

Signed-off-by: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/net/ieee802154/at86rf230.c | 59 +++++++++++++++++++++++---------------
 1 file changed, 36 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ieee802154/at86rf230.c b/drivers/net/ieee802154/at86rf230.c
index 7d96cd4..694f5cf 100644
--- a/drivers/net/ieee802154/at86rf230.c
+++ b/drivers/net/ieee802154/at86rf230.c
@@ -38,12 +38,19 @@
 #include <net/mac802154.h>
 #include <net/wpan-phy.h>
 
+struct at86rf230_local;
+/* at86rf2xx chip depend data.
+ * All timings are in us.
+ */
+struct at86rf2xx_chip_data {
+	int rssi_base_val;
+
+	int (*set_channel)(struct at86rf230_local *, int, int);
+};
+
 struct at86rf230_local {
 	struct spi_device *spi;
 
-	u8 part;
-	u8 vers;
-
 	u8 buf[2];
 	struct mutex bmux;
 
@@ -56,16 +63,11 @@ struct at86rf230_local {
 	spinlock_t lock;
 	bool irq_busy;
 	bool is_tx;
-	bool tx_aret;
 
-	int rssi_base_val;
+	struct at86rf2xx_chip_data *data;
+	bool tx_aret;
 };
 
-static bool is_rf212(struct at86rf230_local *local)
-{
-	return local->part == 7;
-}
-
 #define	RG_TRX_STATUS	(0x01)
 #define	SR_TRX_STATUS		0x01, 0x1f, 0
 #define	SR_RESERVED_01_3	0x01, 0x20, 5
@@ -593,10 +595,8 @@ at86rf230_stop(struct ieee802154_dev *dev)
 }
 
 static int
-at86rf230_set_channel(struct at86rf230_local *lp, int page, int channel)
+at86rf23x_set_channel(struct at86rf230_local *lp, int page, int channel)
 {
-	lp->rssi_base_val = -91;
-
 	return at86rf230_write_subreg(lp, SR_CHANNEL, channel);
 }
 
@@ -614,10 +614,10 @@ at86rf212_set_channel(struct at86rf230_local *lp, int page, int channel)
 
 	if (page == 0) {
 		rc = at86rf230_write_subreg(lp, SR_BPSK_QPSK, 0);
-		lp->rssi_base_val = -100;
+		lp->data->rssi_base_val = -100;
 	} else {
 		rc = at86rf230_write_subreg(lp, SR_BPSK_QPSK, 1);
-		lp->rssi_base_val = -98;
+		lp->data->rssi_base_val = -98;
 	}
 	if (rc < 0)
 		return rc;
@@ -639,10 +639,7 @@ at86rf230_channel(struct ieee802154_dev *dev, int page, int channel)
 		return -EINVAL;
 	}
 
-	if (is_rf212(lp))
-		rc = at86rf212_set_channel(lp, page, channel);
-	else
-		rc = at86rf230_set_channel(lp, page, channel);
+	rc = lp->data->set_channel(lp, page, channel);
 	if (rc < 0)
 		return rc;
 
@@ -827,10 +824,10 @@ at86rf230_set_cca_ed_level(struct ieee802154_dev *dev, s32 level)
 	struct at86rf230_local *lp = dev->priv;
 	int desens_steps;
 
-	if (level < lp->rssi_base_val || level > 30)
+	if (level < lp->data->rssi_base_val || level > 30)
 		return -EINVAL;
 
-	desens_steps = (level - lp->rssi_base_val) * 100 / 207;
+	desens_steps = (level - lp->data->rssi_base_val) * 100 / 207;
 
 	return at86rf230_write_subreg(lp, SR_CCA_ED_THRES, desens_steps);
 }
@@ -889,6 +886,21 @@ static struct ieee802154_ops at86rf230_ops = {
 	.set_frame_retries = at86rf230_set_frame_retries,
 };
 
+static struct at86rf2xx_chip_data at86rf233_data = {
+	.rssi_base_val = -91,
+	.set_channel = at86rf23x_set_channel,
+};
+
+static struct at86rf2xx_chip_data at86rf231_data = {
+	.rssi_base_val = -91,
+	.set_channel = at86rf23x_set_channel,
+};
+
+static struct at86rf2xx_chip_data at86rf212_data = {
+	.rssi_base_val = -100,
+	.set_channel = at86rf212_set_channel,
+};
+
 static void at86rf230_irqwork(struct work_struct *work)
 {
 	struct at86rf230_local *lp =
@@ -1061,8 +1073,6 @@ at86rf230_detect_device(struct at86rf230_local *lp)
 		return -EINVAL;
 	}
 
-	lp->part = part;
-	lp->vers = version;
 	lp->dev->extra_tx_headroom = 0;
 	lp->dev->flags = IEEE802154_HW_OMIT_CKSUM | IEEE802154_HW_AACK |
 			 IEEE802154_HW_TXPOWER | IEEE802154_HW_CSMA;
@@ -1074,11 +1084,13 @@ at86rf230_detect_device(struct at86rf230_local *lp)
 		break;
 	case 3:
 		chip = "at86rf231";
+		lp->data = &at86rf231_data;
 		lp->dev->phy->channels_supported[0] = 0x7FFF800;
 		break;
 	case 7:
 		chip = "at86rf212";
 		if (version == 1) {
+			lp->data = &at86rf212_data;
 			lp->dev->flags |= IEEE802154_HW_LBT;
 			lp->dev->phy->channels_supported[0] = 0x00007FF;
 			lp->dev->phy->channels_supported[2] = 0x00007FF;
@@ -1088,6 +1100,7 @@ at86rf230_detect_device(struct at86rf230_local *lp)
 		break;
 	case 11:
 		chip = "at86rf233";
+		lp->data = &at86rf233_data;
 		lp->dev->phy->channels_supported[0] = 0x7FFF800;
 		break;
 	default:
-- 
2.0.1


------------------------------------------------------------------------------
Open source business process management suite built on Java and Eclipse
Turn processes into business applications with Bonita BPM Community Edition
Quickly connect people, data, and systems into organized workflows
Winner of BOSSIE, CODIE, OW2 and Gartner awards
http://p.sf.net/sfu/Bonitasoft
