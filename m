From: Julia Lawall <julia@diku.dk>
Subject: [PATCH 2/9] drivers/net/wireless/wl12xx: add missing kfree
Date: Mon,  8 Aug 2011 13:17:56 +0200
Message-ID: <1312802283-9107-2-git-send-email-julia@diku.dk>
Cc: kernel-janitors@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Luciano Coelho <coelho@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <julia@diku.dk>

In each case, the freed data should be freed in the error handling code as
well.

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
 drivers/net/wireless/wl12xx/acx.c      |    6 +-----
 drivers/net/wireless/wl12xx/testmode.c |    5 ++++-
 2 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/drivers/net/wireless/wl12xx/testmode.c b/drivers/net/wireless/wl12xx/testmode.c
index 5d5e1ef..88add68 100644
--- a/drivers/net/wireless/wl12xx/testmode.c
+++ b/drivers/net/wireless/wl12xx/testmode.c
@@ -139,12 +139,15 @@ static int wl1271_tm_cmd_interrogate(struct wl1271 *wl, struct nlattr *tb[])
 
 	if (ret < 0) {
 		wl1271_warning("testmode cmd interrogate failed: %d", ret);
+		kfree(cmd);
 		return ret;
 	}
 
 	skb = cfg80211_testmode_alloc_reply_skb(wl->hw->wiphy, sizeof(*cmd));
-	if (!skb)
+	if (!skb) {
+		kfree(cmd);
 		return -ENOMEM;
+	}
 
 	NLA_PUT(skb, WL1271_TM_ATTR_DATA, sizeof(*cmd), cmd);
 
diff --git a/drivers/net/wireless/wl12xx/acx.c b/drivers/net/wireless/wl12xx/acx.c
index 7e33f1f..34f6ab5 100644
--- a/drivers/net/wireless/wl12xx/acx.c
+++ b/drivers/net/wireless/wl12xx/acx.c
@@ -77,8 +77,6 @@ int wl1271_acx_sleep_auth(struct wl1271 *wl, u8 sleep_auth)
 	auth->sleep_auth = sleep_auth;
 
 	ret = wl1271_cmd_configure(wl, ACX_SLEEP_AUTH, auth, sizeof(*auth));
-	if (ret < 0)
-		return ret;
 
 out:
 	kfree(auth);
@@ -624,10 +622,8 @@ int wl1271_acx_cca_threshold(struct wl1271 *wl)
 
 	ret = wl1271_cmd_configure(wl, ACX_CCA_THRESHOLD,
 				   detection, sizeof(*detection));
-	if (ret < 0) {
+	if (ret < 0)
 		wl1271_warning("failed to set cca threshold: %d", ret);
-		return ret;
-	}
 
 out:
 	kfree(detection);
