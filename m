From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] wireless: qtnfmac: Convert timers to use timer_setup()
Date: Mon, 16 Oct 2017 16:36:22 -0700
Message-ID: <20171016233622.GA101550@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Igor Mitsyanko <imitsyanko@quantenna.com>,
        Avinash Patil <avinashp@quantenna.com>,
        Sergey Matyukevich <smatyukevich@quantenna.com>,
        Kamlesh Rath <krath@quantenna.com>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In preparation for unconditionally passing the struct timer_list pointer to
all timer callbacks, switch to using the new timer_setup() and from_timer()
to pass the timer pointer explicitly.

Cc: Igor Mitsyanko <imitsyanko@quantenna.com>
Cc: Avinash Patil <avinashp@quantenna.com>
Cc: Sergey Matyukevich <smatyukevich@quantenna.com>
Cc: Kalle Valo <kvalo@codeaurora.org>
Cc: Kamlesh Rath <krath@quantenna.com>
Cc: linux-wireless@vger.kernel.org
Cc: netdev@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 drivers/net/wireless/quantenna/qtnfmac/cfg80211.c | 7 +++----
 drivers/net/wireless/quantenna/qtnfmac/core.c     | 2 +-
 2 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/net/wireless/quantenna/qtnfmac/cfg80211.c b/drivers/net/wireless/quantenna/qtnfmac/cfg80211.c
index 32bf72c0399f..ac1b9bd5ed90 100644
--- a/drivers/net/wireless/quantenna/qtnfmac/cfg80211.c
+++ b/drivers/net/wireless/quantenna/qtnfmac/cfg80211.c
@@ -581,9 +581,9 @@ qtnf_del_station(struct wiphy *wiphy, struct net_device *dev,
 	return ret;
 }
 
-static void qtnf_scan_timeout(unsigned long data)
+static void qtnf_scan_timeout(struct timer_list *t)
 {
-	struct qtnf_wmac *mac = (struct qtnf_wmac *)data;
+	struct qtnf_wmac *mac = from_timer(mac, t, scan_timeout);
 
 	pr_warn("mac%d scan timed out\n", mac->macid);
 	qtnf_scan_done(mac, true);
@@ -602,8 +602,7 @@ qtnf_scan(struct wiphy *wiphy, struct cfg80211_scan_request *request)
 		return -EFAULT;
 	}
 
-	mac->scan_timeout.data = (unsigned long)mac;
-	mac->scan_timeout.function = qtnf_scan_timeout;
+	mac->scan_timeout.function = (TIMER_FUNC_TYPE)qtnf_scan_timeout;
 	mod_timer(&mac->scan_timeout,
 		  jiffies + QTNF_SCAN_TIMEOUT_SEC * HZ);
 
diff --git a/drivers/net/wireless/quantenna/qtnfmac/core.c b/drivers/net/wireless/quantenna/qtnfmac/core.c
index 5e60180482d1..aa7f146278a7 100644
--- a/drivers/net/wireless/quantenna/qtnfmac/core.c
+++ b/drivers/net/wireless/quantenna/qtnfmac/core.c
@@ -289,7 +289,7 @@ static struct qtnf_wmac *qtnf_core_mac_alloc(struct qtnf_bus *bus,
 		mac->iflist[i].vifid = i;
 		qtnf_sta_list_init(&mac->iflist[i].sta_list);
 		mutex_init(&mac->mac_lock);
-		init_timer(&mac->scan_timeout);
+		setup_timer(&mac->scan_timeout, NULL, 0);
 	}
 
 	qtnf_mac_init_primary_intf(mac);
-- 
2.7.4


-- 
Kees Cook
Pixel Security
