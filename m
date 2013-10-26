From: =?UTF-8?q?Pali=20Roh=C3=A1r?= <pali.rohar@gmail.com>
Subject: [PATCH 05/16] wl1251: implement hardware ARP filtering
Date: Sat, 26 Oct 2013 22:34:04 +0200
Message-ID: <1382819655-30430-6-git-send-email-pali.rohar@gmail.com>
References: <1382819655-30430-1-git-send-email-pali.rohar@gmail.com>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, freemangordon@abv.bg,
	aaro.koskinen@iki.fi, pavel@ucw.cz, sre@ring0.de,
	joni.lapilainen@gmail.com, pali.rohar@gmail.com,
	David Gnedt <david.gnedt@davizone.at>
To: Luciano Coelho <luca@coelho.fi>,
	"John W. Linville" <linville@tuxdriver.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1382819655-30430-1-git-send-email-pali.rohar@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Gnedt <david.gnedt@davizone.at>

Update hardware ARP filter configuration on BSS_CHANGED_ARP_FILTER
notification from mac80211.
Ported from wl1271 driver.

Signed-off-by: David Gnedt <david.gnedt@davizone.at>
---
 drivers/net/wireless/ti/wl1251/acx.c  |   31 +++++++++++++++++++++++++++++++
 drivers/net/wireless/ti/wl1251/acx.h  |   15 +++++++++++++++
 drivers/net/wireless/ti/wl1251/main.c |   13 +++++++++++++
 3 files changed, 59 insertions(+)

diff --git a/drivers/net/wireless/ti/wl1251/acx.c b/drivers/net/wireless/ti/wl1251/acx.c
index cce50e2..9295090 100644
--- a/drivers/net/wireless/ti/wl1251/acx.c
+++ b/drivers/net/wireless/ti/wl1251/acx.c
@@ -1062,6 +1062,37 @@ out:
 	return ret;
 }
 
+int wl1251_acx_arp_ip_filter(struct wl1251 *wl, bool enable, __be32 address)
+{
+	struct wl1251_acx_arp_filter *acx;
+	int ret;
+
+	wl1251_debug(DEBUG_ACX, "acx arp ip filter, enable: %d", enable);
+
+	acx = kzalloc(sizeof(*acx), GFP_KERNEL);
+	if (!acx) {
+		ret = -ENOMEM;
+		goto out;
+	}
+
+	acx->version = ACX_IPV4_VERSION;
+	acx->enable = enable;
+
+	if (enable == true)
+		memcpy(acx->address, &address, ACX_IPV4_ADDR_SIZE);
+
+	ret = wl1251_cmd_configure(wl, ACX_ARP_IP_FILTER,
+				   acx, sizeof(*acx));
+	if (ret < 0) {
+		wl1251_warning("failed to set arp ip filter: %d", ret);
+		goto out;
+	}
+
+out:
+	kfree(acx);
+	return ret;
+}
+
 int wl1251_acx_ac_cfg(struct wl1251 *wl, u8 ac, u8 cw_min, u16 cw_max,
 		      u8 aifs, u16 txop)
 {
diff --git a/drivers/net/wireless/ti/wl1251/acx.h b/drivers/net/wireless/ti/wl1251/acx.h
index 99ea80e..4444cd0 100644
--- a/drivers/net/wireless/ti/wl1251/acx.h
+++ b/drivers/net/wireless/ti/wl1251/acx.h
@@ -1233,6 +1233,20 @@ struct wl1251_acx_bet_enable {
 	u8 padding[2];
 } __packed;
 
+#define ACX_IPV4_VERSION 4
+#define ACX_IPV6_VERSION 6
+#define ACX_IPV4_ADDR_SIZE 4
+struct wl1251_acx_arp_filter {
+	struct acx_header header;
+	u8 version;	/* The IP version: 4 - IPv4, 6 - IPv6.*/
+	u8 enable;	/* 1 - ARP filtering is enabled, 0 - disabled */
+	u8 padding[2];
+	u8 address[16];	/* The IP address used to filter ARP packets.
+			   ARP packets that do not match this address are
+			   dropped. When the IP Version is 4, the last 12
+			   bytes of the the address are ignored. */
+} __attribute__((packed));
+
 struct wl1251_acx_ac_cfg {
 	struct acx_header header;
 
@@ -1475,6 +1489,7 @@ int wl1251_acx_mem_cfg(struct wl1251 *wl);
 int wl1251_acx_wr_tbtt_and_dtim(struct wl1251 *wl, u16 tbtt, u8 dtim);
 int wl1251_acx_bet_enable(struct wl1251 *wl, enum wl1251_acx_bet_mode mode,
 			  u8 max_consecutive);
+int wl1251_acx_arp_ip_filter(struct wl1251 *wl, bool enable, __be32 address);
 int wl1251_acx_ac_cfg(struct wl1251 *wl, u8 ac, u8 cw_min, u16 cw_max,
 		      u8 aifs, u16 txop);
 int wl1251_acx_tid_cfg(struct wl1251 *wl, u8 queue,
diff --git a/drivers/net/wireless/ti/wl1251/main.c b/drivers/net/wireless/ti/wl1251/main.c
index 46a2494..9752745 100644
--- a/drivers/net/wireless/ti/wl1251/main.c
+++ b/drivers/net/wireless/ti/wl1251/main.c
@@ -1078,6 +1078,19 @@ static void wl1251_op_bss_info_changed(struct ieee80211_hw *hw,
 		}
 	}
 
+	if (changed & BSS_CHANGED_ARP_FILTER) {
+		__be32 addr = bss_conf->arp_addr_list[0];
+		WARN_ON(wl->bss_type != BSS_TYPE_STA_BSS);
+
+		if (bss_conf->arp_addr_cnt == 1 && bss_conf->assoc)
+			ret = wl1251_acx_arp_ip_filter(wl, true, addr);
+		else
+			ret = wl1251_acx_arp_ip_filter(wl, false, addr);
+
+		if (ret < 0)
+			goto out_sleep;
+	}
+
 	if (changed & BSS_CHANGED_BEACON) {
 		beacon = ieee80211_beacon_get(hw, vif);
 		if (!beacon)
-- 
1.7.10.4
