From: Phoebe Buckheister <phoebe.buckheister-mPn0NPGs4xGatNDF+KUbs4QuADTiUCJX@public.gmane.org>
Subject: [PATCH net-next 01/11] ieee802154: add types
	for link-layer security
Date: Fri, 16 May 2014 17:46:35 +0200
Message-ID: <1400255205-9031-2-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
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

The added structures match 802.15.4-2011 link-layer security PIBs as
closely as is reasonable. Some lists required by the standard were
modeled as bitmaps (frame_types and command_frame_ids in *llsec_key,
802.15.4-2011 7.5/Table 61), since using lists for those seems a bit
excessive and not particularly useful. The DeviceDescriptorHandleList
was inverted and is here a per-device list, since operations on this
list are likely to have both a key and a device at hand, and per-device
lists of keys are shorter than per-key lists of devices.

Signed-off-by: Phoebe Buckheister <phoebe.buckheister-mPn0NPGs4xGatNDF+KUbs4QuADTiUCJX@public.gmane.org>
---
 include/net/ieee802154_netdev.h |   95 +++++++++++++++++++++++++++++++++++++++
 1 file changed, 95 insertions(+)

diff --git a/include/net/ieee802154_netdev.h b/include/net/ieee802154_netdev.h
index bc9a747..6f8f9c2 100644
--- a/include/net/ieee802154_netdev.h
+++ b/include/net/ieee802154_netdev.h
@@ -242,6 +242,88 @@ static inline struct ieee802154_mac_cb *mac_cb_init(struct sk_buff *skb)
 	return mac_cb(skb);
 }
 
+#define IEEE802154_LLSEC_KEY_SIZE 16
+
+struct ieee802154_llsec_key_id {
+	u8 mode;
+	u8 id;
+	union {
+		struct ieee802154_addr device_addr;
+		__le32 short_source;
+		__le64 extended_source;
+	};
+};
+
+struct ieee802154_llsec_key {
+	u8 frame_types;
+	u32 cmd_frame_ids;
+	u8 key[IEEE802154_LLSEC_KEY_SIZE];
+};
+
+struct ieee802154_llsec_key_entry {
+	struct list_head list;
+
+	struct ieee802154_llsec_key_id id;
+	struct ieee802154_llsec_key *key;
+};
+
+struct ieee802154_llsec_device_key {
+	struct list_head list;
+
+	struct ieee802154_llsec_key_id key_id;
+	u32 frame_counter;
+};
+
+enum {
+	IEEE802154_LLSEC_DEVKEY_IGNORE,
+	IEEE802154_LLSEC_DEVKEY_RESTRICT,
+
+	__IEEE802154_LLSEC_DEVKEY_MAX,
+};
+
+struct ieee802154_llsec_device {
+	struct list_head list;
+
+	__le16 pan_id;
+	__le16 short_addr;
+	__le64 hwaddr;
+	u32 frame_counter;
+	bool seclevel_exempt;
+
+	u8 key_mode;
+	struct list_head keys;
+};
+
+struct ieee802154_llsec_seclevel {
+	struct list_head list;
+
+	u8 frame_type;
+	u8 cmd_frame_id;
+	bool device_override;
+	u32 sec_levels;
+};
+
+struct ieee802154_llsec_params {
+	bool enabled;
+
+	__be32 frame_counter;
+	u8 out_level;
+	struct ieee802154_llsec_key_id out_key;
+
+	__le64 default_key_source;
+
+	__le16 pan_id;
+	__le64 hwaddr;
+	__le64 coord_hwaddr;
+	__le16 coord_shortaddr;
+};
+
+struct ieee802154_llsec_table {
+	struct list_head keys;
+	struct list_head devices;
+	struct list_head security_levels;
+};
+
 #define IEEE802154_MAC_SCAN_ED		0
 #define IEEE802154_MAC_SCAN_ACTIVE	1
 #define IEEE802154_MAC_SCAN_PASSIVE	2
@@ -260,6 +342,19 @@ struct ieee802154_mac_params {
 };
 
 struct wpan_phy;
+
+enum {
+	IEEE802154_LLSEC_PARAM_ENABLED = 1 << 0,
+	IEEE802154_LLSEC_PARAM_FRAME_COUNTER = 1 << 1,
+	IEEE802154_LLSEC_PARAM_OUT_LEVEL = 1 << 2,
+	IEEE802154_LLSEC_PARAM_OUT_KEY = 1 << 3,
+	IEEE802154_LLSEC_PARAM_KEY_SOURCE = 1 << 4,
+	IEEE802154_LLSEC_PARAM_PAN_ID = 1 << 5,
+	IEEE802154_LLSEC_PARAM_HWADDR = 1 << 6,
+	IEEE802154_LLSEC_PARAM_COORD_HWADDR = 1 << 7,
+	IEEE802154_LLSEC_PARAM_COORD_SHORTADDR = 1 << 8,
+};
+
 /*
  * This should be located at net_device->ml_priv
  *
-- 
1.7.9.5


------------------------------------------------------------------------------
"Accelerate Dev Cycles with Automated Cross-Browser Testing - For FREE
Instantly run your Selenium tests across 300+ browser/OS combos.
Get unparalleled scalability from the best Selenium testing platform available
Simple to use. Nothing to install. Get started now for free."
http://p.sf.net/sfu/SauceLabs
