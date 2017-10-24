From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] drivers/wireless: rsi: Convert timers to use timer_setup()
Date: Tue, 24 Oct 2017 02:29:09 -0700
Message-ID: <20171024092909.GA47160@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Amitkumar Karwar <amit.karwar@redpinesignals.com>,
        Prameela Rani Garnepudi <prameela.j04cs@gmail.com>,
        Pavani Muthyala <pavani.muthyala@redpinesignals.com>,
        Karun Eagalapati <karun256@gmail.com>,
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

Cc: Kalle Valo <kvalo@codeaurora.org>
Cc: Amitkumar Karwar <amit.karwar@redpinesignals.com>
Cc: Prameela Rani Garnepudi <prameela.j04cs@gmail.com>
Cc: Pavani Muthyala <pavani.muthyala@redpinesignals.com>
Cc: Karun Eagalapati <karun256@gmail.com>
Cc: linux-wireless@vger.kernel.org
Cc: netdev@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 drivers/net/wireless/rsi/rsi_91x_hal.c      | 7 +++----
 drivers/net/wireless/rsi/rsi_91x_mac80211.c | 4 ++--
 drivers/net/wireless/rsi/rsi_91x_main.c     | 4 +---
 drivers/net/wireless/rsi/rsi_common.h       | 2 +-
 4 files changed, 7 insertions(+), 10 deletions(-)

diff --git a/drivers/net/wireless/rsi/rsi_91x_hal.c b/drivers/net/wireless/rsi/rsi_91x_hal.c
index 689527d7007a..1176de646942 100644
--- a/drivers/net/wireless/rsi/rsi_91x_hal.c
+++ b/drivers/net/wireless/rsi/rsi_91x_hal.c
@@ -418,9 +418,9 @@ int rsi_prepare_beacon(struct rsi_common *common, struct sk_buff *skb)
 	return 0;
 }
 
-static void bl_cmd_timeout(unsigned long priv)
+static void bl_cmd_timeout(struct timer_list *t)
 {
-	struct rsi_hw *adapter = (struct rsi_hw *)priv;
+	struct rsi_hw *adapter = from_timer(adapter, t, bl_cmd_timer);
 
 	adapter->blcmd_timer_expired = true;
 	del_timer(&adapter->bl_cmd_timer);
@@ -428,8 +428,7 @@ static void bl_cmd_timeout(unsigned long priv)
 
 static int bl_start_cmd_timer(struct rsi_hw *adapter, u32 timeout)
 {
-	setup_timer(&adapter->bl_cmd_timer, (void *)&bl_cmd_timeout,
-		    (unsigned long)adapter);
+	timer_setup(&adapter->bl_cmd_timer, bl_cmd_timeout, 0);
 	adapter->bl_cmd_timer.expires = (msecs_to_jiffies(timeout) + jiffies);
 
 	adapter->blcmd_timer_expired = false;
diff --git a/drivers/net/wireless/rsi/rsi_91x_mac80211.c b/drivers/net/wireless/rsi/rsi_91x_mac80211.c
index b1f5dbbde3cb..9427c9d7c9c7 100644
--- a/drivers/net/wireless/rsi/rsi_91x_mac80211.c
+++ b/drivers/net/wireless/rsi/rsi_91x_mac80211.c
@@ -1663,9 +1663,9 @@ static void rsi_resume_conn_channel(struct rsi_common *common)
 	}
 }
 
-void rsi_roc_timeout(unsigned long data)
+void rsi_roc_timeout(struct timer_list *t)
 {
-	struct rsi_common *common = (struct rsi_common *)data;
+	struct rsi_common *common = from_timer(common, t, roc_timer);
 
 	rsi_dbg(INFO_ZONE, "Remain on channel expired\n");
 
diff --git a/drivers/net/wireless/rsi/rsi_91x_main.c b/drivers/net/wireless/rsi/rsi_91x_main.c
index 71b8cfb8252e..2a1fbb7db6c4 100644
--- a/drivers/net/wireless/rsi/rsi_91x_main.c
+++ b/drivers/net/wireless/rsi/rsi_91x_main.c
@@ -262,9 +262,7 @@ struct rsi_hw *rsi_91x_init(void)
 
 	rsi_default_ps_params(adapter);
 	spin_lock_init(&adapter->ps_lock);
-	common->roc_timer.data = (unsigned long)common;
-	common->roc_timer.function = (void *)&rsi_roc_timeout;
-	init_timer(&common->roc_timer);
+	timer_setup(&common->roc_timer, rsi_roc_timeout, 0);
 	common->init_done = true;
 	return adapter;
 
diff --git a/drivers/net/wireless/rsi/rsi_common.h b/drivers/net/wireless/rsi/rsi_common.h
index 272e18d750ff..29acaea3636d 100644
--- a/drivers/net/wireless/rsi/rsi_common.h
+++ b/drivers/net/wireless/rsi/rsi_common.h
@@ -85,5 +85,5 @@ void rsi_91x_deinit(struct rsi_hw *adapter);
 int rsi_read_pkt(struct rsi_common *common, s32 rcv_pkt_len);
 struct rsi_sta *rsi_find_sta(struct rsi_common *common, u8 *mac_addr);
 struct ieee80211_vif *rsi_get_vif(struct rsi_hw *adapter, u8 *mac);
-void rsi_roc_timeout(unsigned long data);
+void rsi_roc_timeout(struct timer_list *t);
 #endif
-- 
2.7.4


-- 
Kees Cook
Pixel Security
