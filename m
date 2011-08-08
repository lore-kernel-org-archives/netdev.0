From: Julia Lawall <julia@diku.dk>
Subject: [PATCH 9/9] drivers/net/wireless/wl1251: add missing kfree
Date: Mon,  8 Aug 2011 13:18:03 +0200
Message-ID: <1312802283-9107-9-git-send-email-julia@diku.dk>
Cc: kernel-janitors@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Luciano Coelho <coelho@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <julia@diku.dk>

In each case, the kfree already at the end of the function is also needed
in the error case.

A simplified version of the semantic match that finds this problem is as
follows: (http://coccinelle.lip6.fr/)

// <smpl>
@exists@
local idexpression x;
statement S,S1;
expression E;
identifier fl;
expression *ptr != NULL;
@@

x = \(kmalloc\|kzalloc\|kcalloc\)(...);
...
if (x == NULL) S
<... when != x
     when != if (...) { <+...kfree(x)...+> }
     when any
     when != true x == NULL
x->fl
...>
(
if (x == NULL) S1
|
if (...) { ... when != x
               when forall
(
 return \(0\|<+...x...+>\|ptr\);
|
* return ...;
)
}
)
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>

---
 drivers/net/wireless/wl1251/acx.c |    6 +-----
 drivers/net/wireless/wl1251/cmd.c |    2 +-
 2 files changed, 2 insertions(+), 6 deletions(-)

diff --git a/drivers/net/wireless/wl1251/acx.c b/drivers/net/wireless/wl1251/acx.c
index ef8370e..ad87a1a 100644
--- a/drivers/net/wireless/wl1251/acx.c
+++ b/drivers/net/wireless/wl1251/acx.c
@@ -140,8 +140,6 @@ int wl1251_acx_sleep_auth(struct wl1251 *wl, u8 sleep_auth)
 	auth->sleep_auth = sleep_auth;
 
 	ret = wl1251_cmd_configure(wl, ACX_SLEEP_AUTH, auth, sizeof(*auth));
-	if (ret < 0)
-		return ret;
 
 out:
 	kfree(auth);
@@ -681,10 +679,8 @@ int wl1251_acx_cca_threshold(struct wl1251 *wl)
 
 	ret = wl1251_cmd_configure(wl, ACX_CCA_THRESHOLD,
 				   detection, sizeof(*detection));
-	if (ret < 0) {
+	if (ret < 0)
 		wl1251_warning("failed to set cca threshold: %d", ret);
-		return ret;
-	}
 
 out:
 	kfree(detection);
diff --git a/drivers/net/wireless/wl1251/cmd.c b/drivers/net/wireless/wl1251/cmd.c
index 81f164b..d14d69d 100644
--- a/drivers/net/wireless/wl1251/cmd.c
+++ b/drivers/net/wireless/wl1251/cmd.c
@@ -241,7 +241,7 @@ int wl1251_cmd_data_path(struct wl1251 *wl, u8 channel, bool enable)
 	if (ret < 0) {
 		wl1251_error("tx %s cmd for channel %d failed",
 			     enable ? "start" : "stop", channel);
-		return ret;
+		goto out;
 	}
 
 	wl1251_debug(DEBUG_BOOT, "tx %s cmd channel %d",
