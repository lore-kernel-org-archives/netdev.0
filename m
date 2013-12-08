From: =?UTF-8?q?Pali=20Roh=C3=A1r?= <pali.rohar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH v2 05/16] wl1251: split RX and TX data path initialisation
Date: Sun,  8 Dec 2013 10:25:03 +0100
Message-ID: <1386494714-21070-6-git-send-email-pali.rohar@gmail.com>
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

Split up data path initialisation into RX and TX data path initialisati=
on
functions. This change is required for channel switching in monitor mod=
e.

Signed-off-by: David Gnedt <david.gnedt-rFfgOQFw6VLk7+2FdBfRIA@public.gmane.org>
Signed-off-by: Pali Roh=C3=A1r <pali.rohar-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/net/wireless/ti/wl1251/cmd.c  |   46 +++++++++++++++++++++++--=
--------
 drivers/net/wireless/ti/wl1251/cmd.h  |    3 ++-
 drivers/net/wireless/ti/wl1251/init.c |    9 +++++--
 3 files changed, 41 insertions(+), 17 deletions(-)

diff --git a/drivers/net/wireless/ti/wl1251/cmd.c b/drivers/net/wireles=
s/ti/wl1251/cmd.c
index 16b6479..381b3fe 100644
--- a/drivers/net/wireless/ti/wl1251/cmd.c
+++ b/drivers/net/wireless/ti/wl1251/cmd.c
@@ -204,11 +204,11 @@ out:
 	return ret;
 }
=20
-int wl1251_cmd_data_path(struct wl1251 *wl, u8 channel, bool enable)
+int wl1251_cmd_data_path_rx(struct wl1251 *wl, u8 channel, bool enable=
)
 {
 	struct cmd_enabledisable_path *cmd;
 	int ret;
-	u16 cmd_rx, cmd_tx;
+	u16 cmd_rx;
=20
 	wl1251_debug(DEBUG_CMD, "cmd data path");
=20
@@ -220,13 +220,10 @@ int wl1251_cmd_data_path(struct wl1251 *wl, u8 ch=
annel, bool enable)
=20
 	cmd->channel =3D channel;
=20
-	if (enable) {
+	if (enable)
 		cmd_rx =3D CMD_ENABLE_RX;
-		cmd_tx =3D CMD_ENABLE_TX;
-	} else {
+	else
 		cmd_rx =3D CMD_DISABLE_RX;
-		cmd_tx =3D CMD_DISABLE_TX;
-	}
=20
 	ret =3D wl1251_cmd_send(wl, cmd_rx, cmd, sizeof(*cmd));
 	if (ret < 0) {
@@ -238,17 +235,38 @@ int wl1251_cmd_data_path(struct wl1251 *wl, u8 ch=
annel, bool enable)
 	wl1251_debug(DEBUG_BOOT, "rx %s cmd channel %d",
 		     enable ? "start" : "stop", channel);
=20
+out:
+	kfree(cmd);
+	return ret;
+}
+
+int wl1251_cmd_data_path_tx(struct wl1251 *wl, u8 channel, bool enable=
)
+{
+	struct cmd_enabledisable_path *cmd;
+	int ret;
+	u16 cmd_tx;
+
+	wl1251_debug(DEBUG_CMD, "cmd data path");
+
+	cmd =3D kzalloc(sizeof(*cmd), GFP_KERNEL);
+	if (!cmd)
+		return -ENOMEM;
+
+	cmd->channel =3D channel;
+
+	if (enable)
+		cmd_tx =3D CMD_ENABLE_TX;
+	else
+		cmd_tx =3D CMD_DISABLE_TX;
+
 	ret =3D wl1251_cmd_send(wl, cmd_tx, cmd, sizeof(*cmd));
-	if (ret < 0) {
+	if (ret < 0)
 		wl1251_error("tx %s cmd for channel %d failed",
 			     enable ? "start" : "stop", channel);
-		goto out;
-	}
-
-	wl1251_debug(DEBUG_BOOT, "tx %s cmd channel %d",
-		     enable ? "start" : "stop", channel);
+	else
+		wl1251_debug(DEBUG_BOOT, "tx %s cmd channel %d",
+			     enable ? "start" : "stop", channel);
=20
-out:
 	kfree(cmd);
 	return ret;
 }
diff --git a/drivers/net/wireless/ti/wl1251/cmd.h b/drivers/net/wireles=
s/ti/wl1251/cmd.h
index 126f273..d824ff9 100644
--- a/drivers/net/wireless/ti/wl1251/cmd.h
+++ b/drivers/net/wireless/ti/wl1251/cmd.h
@@ -35,7 +35,8 @@ int wl1251_cmd_interrogate(struct wl1251 *wl, u16 id,=
 void *buf, size_t len);
 int wl1251_cmd_configure(struct wl1251 *wl, u16 id, void *buf, size_t =
len);
 int wl1251_cmd_vbm(struct wl1251 *wl, u8 identity,
 		   void *bitmap, u16 bitmap_len, u8 bitmap_control);
-int wl1251_cmd_data_path(struct wl1251 *wl, u8 channel, bool enable);
+int wl1251_cmd_data_path_rx(struct wl1251 *wl, u8 channel, bool enable=
);
+int wl1251_cmd_data_path_tx(struct wl1251 *wl, u8 channel, bool enable=
);
 int wl1251_cmd_join(struct wl1251 *wl, u8 bss_type, u8 channel,
 		    u16 beacon_interval, u8 dtim_interval);
 int wl1251_cmd_ps_mode(struct wl1251 *wl, u8 ps_mode);
diff --git a/drivers/net/wireless/ti/wl1251/init.c b/drivers/net/wirele=
ss/ti/wl1251/init.c
index a6ad223..424ce01 100644
--- a/drivers/net/wireless/ti/wl1251/init.c
+++ b/drivers/net/wireless/ti/wl1251/init.c
@@ -390,8 +390,13 @@ int wl1251_hw_init(struct wl1251 *wl)
 	if (ret < 0)
 		goto out_free_data_path;
=20
-	/* Enable data path */
-	ret =3D wl1251_cmd_data_path(wl, wl->channel, 1);
+	/* Enable rx data path */
+	ret =3D wl1251_cmd_data_path_rx(wl, wl->channel, 1);
+	if (ret < 0)
+		goto out_free_data_path;
+
+	/* Enable tx data path */
+	ret =3D wl1251_cmd_data_path_tx(wl, wl->channel, 1);
 	if (ret < 0)
 		goto out_free_data_path;
=20
--=20
1.7.9.5

--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
