From: Rasmus Villemoes <linux-qQsb+v5E8BnlAoU/VqSP6n9LOBIZ5rWg@public.gmane.org>
Subject: [RFC 5/7] wlcore: avoid fragile snprintf use
Date: Tue,  8 Mar 2016 21:40:52 +0100
Message-ID: <1457469654-17059-6-git-send-email-linux@rasmusvillemoes.dk>
References: <CAGXu5jJ-NApCpANjfz+bAEfwZJ8xizkM-jDHVhOPCzhxV-aqdA@mail.gmail.com>
 <1457469654-17059-1-git-send-email-linux@rasmusvillemoes.dk>
Cc: Rasmus Villemoes <linux-qQsb+v5E8BnlAoU/VqSP6n9LOBIZ5rWg@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1457469654-17059-1-git-send-email-linux-qQsb+v5E8BnlAoU/VqSP6n9LOBIZ5rWg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Appending to a buffer like this is not guaranteed to work (passing
overlapping src and dst buffers to snprintf is undefined
behaviour). The standard and safe idiom is to keep track of the
current string length.

Signed-off-by: Rasmus Villemoes <linux-qQsb+v5E8BnlAoU/VqSP6n9LOBIZ5rWg@public.gmane.org>
---
 drivers/net/wireless/ti/wlcore/boot.c | 12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/drivers/net/wireless/ti/wlcore/boot.c b/drivers/net/wireless/ti/wlcore/boot.c
index 19b7ec7b69c2..401d75c02bf4 100644
--- a/drivers/net/wireless/ti/wlcore/boot.c
+++ b/drivers/net/wireless/ti/wlcore/boot.c
@@ -86,7 +86,7 @@ static int wlcore_validate_fw_ver(struct wl1271 *wl)
 	unsigned int *min_ver = (wl->fw_type == WL12XX_FW_TYPE_MULTI) ?
 		wl->min_mr_fw_ver : wl->min_sr_fw_ver;
 	char min_fw_str[32] = "";
-	int i;
+	int i, len;
 
 	/* the chip must be exactly equal */
 	if ((min_ver[FW_VER_CHIP] != WLCORE_FW_VER_IGNORE) &&
@@ -119,13 +119,15 @@ static int wlcore_validate_fw_ver(struct wl1271 *wl)
 	return 0;
 
 fail:
+	len = 0;
 	for (i = 0; i < NUM_FW_VER; i++)
 		if (min_ver[i] == WLCORE_FW_VER_IGNORE)
-			snprintf(min_fw_str, sizeof(min_fw_str),
-				  "%s*.", min_fw_str);
+			len += scnprintf(min_fw_str + len,
+					 sizeof(min_fw_str) - len, "*.");
 		else
-			snprintf(min_fw_str, sizeof(min_fw_str),
-				  "%s%u.", min_fw_str, min_ver[i]);
+			len += scnprintf(min_fw_str + len,
+					 sizeof(min_fw_str) - len,
+					 "%u.", min_ver[i]);
 
 	wl1271_error("Your WiFi FW version (%u.%u.%u.%u.%u) is invalid.\n"
 		     "Please use at least FW %s\n"
-- 
2.1.4

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
