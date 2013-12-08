From: =?UTF-8?q?Pali=20Roh=C3=A1r?= <pali.rohar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH v2 04/16] wl1251: implement hardware ARP filtering
Date: Sun,  8 Dec 2013 10:25:02 +0100
Message-ID: <1386494714-21070-5-git-send-email-pali.rohar@gmail.com>
References: <1382819655-30430-1-git-send-email-pali.rohar@gmail.com>
 <1386494714-21070-1-git-send-email-pali.rohar@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, freemangordon-uiMcrn6V0Vs@public.gmane.org,
	aaro.koskinen-X3B1VOXEql0@public.gmane.org, pavel-+ZI9xUNit7I@public.gmane.org, sre-GFxCN5SEZAc@public.gmane.org,
	joni.lapilainen-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	Felipe Contreras <felipe.contreras-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	David Gnedt <david.gnedt-rFfgOQFw6VLk7+2FdBfRIA@public.gmane.org>,
	=?UTF-8?q?Pali=20Roh=C3=A1r?= <pali.rohar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Luciano Coelho <luca-XPOmlcxoEMv1KXRcyAk9cg@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1386494714-21070-1-git-send-email-pali.rohar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

=46rom: David Gnedt <david.gnedt-rFfgOQFw6VLk7+2FdBfRIA@public.gmane.org>

Update hardware ARP filter configuration on BSS_CHANGED_ARP_FILTER
notification from mac80211.
Ported from wl1271 driver.

Signed-off-by: David Gnedt <david.gnedt-rFfgOQFw6VLk7+2FdBfRIA@public.gmane.org>
Signed-off-by: Pali Roh=C3=A1r <pali.rohar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/net/wireless/ti/wl1251/acx.c  |   26 +++++++++++++++++++++++++=
+
 drivers/net/wireless/ti/wl1251/acx.h  |   15 +++++++++++++++
 drivers/net/wireless/ti/wl1251/main.c |   12 ++++++++++++
 3 files changed, 53 insertions(+)

diff --git a/drivers/net/wireless/ti/wl1251/acx.c b/drivers/net/wireles=
s/ti/wl1251/acx.c
index cce50e2..5f4a552 100644
--- a/drivers/net/wireless/ti/wl1251/acx.c
+++ b/drivers/net/wireless/ti/wl1251/acx.c
@@ -1062,6 +1062,32 @@ out:
 	return ret;
 }
=20
+int wl1251_acx_arp_ip_filter(struct wl1251 *wl, bool enable, __be32 ad=
dress)
+{
+	struct wl1251_acx_arp_filter *acx;
+	int ret;
+
+	wl1251_debug(DEBUG_ACX, "acx arp ip filter, enable: %d", enable);
+
+	acx =3D kzalloc(sizeof(*acx), GFP_KERNEL);
+	if (!acx)
+		return -ENOMEM;
+
+	acx->version =3D ACX_IPV4_VERSION;
+	acx->enable =3D enable;
+
+	if (enable)
+		memcpy(acx->address, &address, ACX_IPV4_ADDR_SIZE);
+
+	ret =3D wl1251_cmd_configure(wl, ACX_ARP_IP_FILTER,
+				   acx, sizeof(*acx));
+	if (ret < 0)
+		wl1251_warning("failed to set arp ip filter: %d", ret);
+
+	kfree(acx);
+	return ret;
+}
+
 int wl1251_acx_ac_cfg(struct wl1251 *wl, u8 ac, u8 cw_min, u16 cw_max,
 		      u8 aifs, u16 txop)
 {
diff --git a/drivers/net/wireless/ti/wl1251/acx.h b/drivers/net/wireles=
s/ti/wl1251/acx.h
index 99ea80e..4444cd0 100644
--- a/drivers/net/wireless/ti/wl1251/acx.h
+++ b/drivers/net/wireless/ti/wl1251/acx.h
@@ -1233,6 +1233,20 @@ struct wl1251_acx_bet_enable {
 	u8 padding[2];
 } __packed;
=20
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
=20
@@ -1475,6 +1489,7 @@ int wl1251_acx_mem_cfg(struct wl1251 *wl);
 int wl1251_acx_wr_tbtt_and_dtim(struct wl1251 *wl, u16 tbtt, u8 dtim);
 int wl1251_acx_bet_enable(struct wl1251 *wl, enum wl1251_acx_bet_mode =
mode,
 			  u8 max_consecutive);
+int wl1251_acx_arp_ip_filter(struct wl1251 *wl, bool enable, __be32 ad=
dress);
 int wl1251_acx_ac_cfg(struct wl1251 *wl, u8 ac, u8 cw_min, u16 cw_max,
 		      u8 aifs, u16 txop);
 int wl1251_acx_tid_cfg(struct wl1251 *wl, u8 queue,
diff --git a/drivers/net/wireless/ti/wl1251/main.c b/drivers/net/wirele=
ss/ti/wl1251/main.c
index 46a2494..0e27f1f 100644
--- a/drivers/net/wireless/ti/wl1251/main.c
+++ b/drivers/net/wireless/ti/wl1251/main.c
@@ -980,6 +980,7 @@ static void wl1251_op_bss_info_changed(struct ieee8=
0211_hw *hw,
 {
 	struct wl1251 *wl =3D hw->priv;
 	struct sk_buff *beacon, *skb;
+	bool enable;
 	int ret;
=20
 	wl1251_debug(DEBUG_MAC80211, "mac80211 bss info changed");
@@ -1078,6 +1079,17 @@ static void wl1251_op_bss_info_changed(struct ie=
ee80211_hw *hw,
 		}
 	}
=20
+	if (changed & BSS_CHANGED_ARP_FILTER) {
+		__be32 addr =3D bss_conf->arp_addr_list[0];
+		WARN_ON(wl->bss_type !=3D BSS_TYPE_STA_BSS);
+
+		enable =3D bss_conf->arp_addr_cnt =3D=3D 1 && bss_conf->assoc;
+		wl1251_acx_arp_ip_filter(wl, enable, addr);
+
+		if (ret < 0)
+			goto out_sleep;
+	}
+
 	if (changed & BSS_CHANGED_BEACON) {
 		beacon =3D ieee80211_beacon_get(hw, vif);
 		if (!beacon)
--=20
1.7.9.5

--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
