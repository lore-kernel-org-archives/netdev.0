From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: [PATCH] cw1200: fix bogus maybe-uninitialized warning
Date: Mon, 24 Oct 2016 17:41:49 +0200
Message-ID: <20161024154215.2863586-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
        Johannes Berg <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Solomon Peachy <pizza-pCgMCH4qpMRg9hUCZPvPmw@public.gmane.org>,
        Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On x86, the cw1200 driver produces a rather silly warning about the
possible use of the 'ret' variable without an initialization
presumably after being confused by the architecture specific definition
of WARN_ON:

drivers/net/wireless/st/cw1200/wsm.c: In function ‘wsm_handle_rx’:
drivers/net/wireless/st/cw1200/wsm.c:1457:9: error: ‘ret’ may be used uninitialized in this function [-Werror=maybe-uninitialized]

As the driver just checks the same variable twice here, we can simplify
it by removing the second condition, which makes it more readable and
avoids the warning.

Signed-off-by: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
---
 drivers/net/wireless/st/cw1200/wsm.c | 15 +++++++--------
 1 file changed, 7 insertions(+), 8 deletions(-)

diff --git a/drivers/net/wireless/st/cw1200/wsm.c b/drivers/net/wireless/st/cw1200/wsm.c
index 680d60eabc75..094e6637ade2 100644
--- a/drivers/net/wireless/st/cw1200/wsm.c
+++ b/drivers/net/wireless/st/cw1200/wsm.c
@@ -385,14 +385,13 @@ static int wsm_multi_tx_confirm(struct cw1200_common *priv,
 	if (WARN_ON(count <= 0))
 		return -EINVAL;
 
-	if (count > 1) {
-		/* We already released one buffer, now for the rest */
-		ret = wsm_release_tx_buffer(priv, count - 1);
-		if (ret < 0)
-			return ret;
-		else if (ret > 0)
-			cw1200_bh_wakeup(priv);
-	}
+	/* We already released one buffer, now for the rest */
+	ret = wsm_release_tx_buffer(priv, count - 1);
+	if (ret < 0)
+		return ret;
+
+	if (ret > 0)
+		cw1200_bh_wakeup(priv);
 
 	cw1200_debug_txed_multi(priv, count);
 	for (i = 0; i < count; ++i) {
-- 
2.9.0
