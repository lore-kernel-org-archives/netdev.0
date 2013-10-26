From: =?UTF-8?q?Pali=20Roh=C3=A1r?= <pali.rohar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 13/16] wl1251: enforce changed hw encryption support on monitor state change
Date: Sat, 26 Oct 2013 22:34:12 +0200
Message-ID: <1382819655-30430-14-git-send-email-pali.rohar@gmail.com>
References: <1382819655-30430-1-git-send-email-pali.rohar@gmail.com>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, freemangordon-uiMcrn6V0Vs@public.gmane.org,
	aaro.koskinen-X3B1VOXEql0@public.gmane.org, pavel-+ZI9xUNit7I@public.gmane.org, sre-GFxCN5SEZAc@public.gmane.org,
	joni.lapilainen-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, pali.rohar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	David Gnedt <david.gnedt-rFfgOQFw6VLk7+2FdBfRIA@public.gmane.org>
To: Luciano Coelho <luca-XPOmlcxoEMv1KXRcyAk9cg@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1382819655-30430-1-git-send-email-pali.rohar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: David Gnedt <david.gnedt-rFfgOQFw6VLk7+2FdBfRIA@public.gmane.org>

The firmware doesn't support per packet encryption selection, so disable hw
encryption support completly while a monitor interface is present to support
injection of packets (which shouldn't get encrypted by hw).
To enforce the changed hw encryption support force a disassociation on
non-monitor interfaces.
For disassociation a workaround using hw connection monitor is employed,
which temporary enables hw connection manager flag.

Signed-off-by: David Gnedt <david.gnedt-rFfgOQFw6VLk7+2FdBfRIA@public.gmane.org>
---
 drivers/net/wireless/ti/wl1251/main.c |   13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/drivers/net/wireless/ti/wl1251/main.c b/drivers/net/wireless/ti/wl1251/main.c
index 174f403..f054741 100644
--- a/drivers/net/wireless/ti/wl1251/main.c
+++ b/drivers/net/wireless/ti/wl1251/main.c
@@ -685,6 +685,16 @@ static int wl1251_op_config(struct ieee80211_hw *hw, u32 changed)
 		wl->power_level = conf->power_level;
 	}
 
+	/*
+	 * Tell stack that connection is lost because hw encryption isn't
+	 * supported in monitor mode.
+	 * XXX This requires temporary enabling the hw connection monitor flag
+	 */
+	if ((changed & IEEE80211_CONF_CHANGE_MONITOR) && wl->vif) {
+		wl->hw->flags |= IEEE80211_HW_CONNECTION_MONITOR;
+		ieee80211_connection_loss(wl->vif);
+	}
+
 out_sleep:
 	wl1251_ps_elp_sleep(wl);
 
@@ -1116,6 +1126,9 @@ static void wl1251_op_bss_info_changed(struct ieee80211_hw *hw,
 	}
 
 	if (changed & BSS_CHANGED_ASSOC) {
+		/* XXX Disable temporary enabled hw connection monitor flag */
+		wl->hw->flags &= ~IEEE80211_HW_CONNECTION_MONITOR;
+
 		if (bss_conf->assoc) {
 			wl->beacon_int = bss_conf->beacon_int;
 
-- 
1.7.10.4

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
