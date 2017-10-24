From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] drivers/wireless: marvell/mwifiex: Convert timers to use
 timer_setup()
Date: Tue, 24 Oct 2017 02:29:19 -0700
Message-ID: <20171024092919.GA47203@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Amitkumar Karwar <amitkarwar@gmail.com>,
        Nishant Sarmukadam <nishants@marvell.com>,
        Ganapathi Bhat <gbhat@marvell.com>,
        Xinming Hu <huxm@marvell.com>,
        Arvind Yadav <arvind.yadav.cs@gmail.com>,
        Ingo Molnar <mingo@kernel.org>,
        Johannes Berg <johannes.berg@intel.com>,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Zaborowski <andrew.zaborowski@intel.com>,
        libertas-dev@lists.infradead.org, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In preparation for unconditionally passing the struct timer_list pointer to
all timer callbacks, switch to using the new timer_setup() and from_timer()
to pass the timer pointer explicitly.

Cc: Kalle Valo <kvalo@codeaurora.org>
Cc: Amitkumar Karwar <amitkarwar@gmail.com>
Cc: Nishant Sarmukadam <nishants@marvell.com>
Cc: Ganapathi Bhat <gbhat@marvell.com>
Cc: Xinming Hu <huxm@marvell.com>
Cc: Arvind Yadav <arvind.yadav.cs@gmail.com>
Cc: Ingo Molnar <mingo@kernel.org>
Cc: Johannes Berg <johannes.berg@intel.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Andrew Zaborowski <andrew.zaborowski@intel.com>
Cc: libertas-dev@lists.infradead.org
Cc: linux-wireless@vger.kernel.org
Cc: netdev@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 drivers/net/wireless/marvell/mwifiex/11n_rxreorder.c | 7 +++----
 drivers/net/wireless/marvell/mwifiex/cmdevt.c        | 5 ++---
 drivers/net/wireless/marvell/mwifiex/init.c          | 7 +++----
 drivers/net/wireless/marvell/mwifiex/main.c          | 3 +--
 drivers/net/wireless/marvell/mwifiex/main.h          | 4 ++--
 drivers/net/wireless/marvell/mwifiex/tdls.c          | 7 +++----
 drivers/net/wireless/marvell/mwifiex/usb.c           | 9 ++++-----
 7 files changed, 18 insertions(+), 24 deletions(-)

diff --git a/drivers/net/wireless/marvell/mwifiex/11n_rxreorder.c b/drivers/net/wireless/marvell/mwifiex/11n_rxreorder.c
index 274dd5a1574a..fd58157d69fb 100644
--- a/drivers/net/wireless/marvell/mwifiex/11n_rxreorder.c
+++ b/drivers/net/wireless/marvell/mwifiex/11n_rxreorder.c
@@ -312,10 +312,10 @@ mwifiex_11n_find_last_seq_num(struct reorder_tmr_cnxt *ctx)
  * them and then dumps the Rx reordering table.
  */
 static void
-mwifiex_flush_data(unsigned long context)
+mwifiex_flush_data(struct timer_list *t)
 {
 	struct reorder_tmr_cnxt *ctx =
-		(struct reorder_tmr_cnxt *) context;
+		from_timer(ctx, t, timer);
 	int start_win, seq_num;
 
 	ctx->timer_is_set = false;
@@ -412,8 +412,7 @@ mwifiex_11n_create_rx_reorder_tbl(struct mwifiex_private *priv, u8 *ta,
 	new_node->timer_context.priv = priv;
 	new_node->timer_context.timer_is_set = false;
 
-	setup_timer(&new_node->timer_context.timer, mwifiex_flush_data,
-		    (unsigned long)&new_node->timer_context);
+	timer_setup(&new_node->timer_context.timer, mwifiex_flush_data, 0);
 
 	for (i = 0; i < win_size; ++i)
 		new_node->rx_reorder_ptr[i] = NULL;
diff --git a/drivers/net/wireless/marvell/mwifiex/cmdevt.c b/drivers/net/wireless/marvell/mwifiex/cmdevt.c
index 0edc5d621304..57c6a880e757 100644
--- a/drivers/net/wireless/marvell/mwifiex/cmdevt.c
+++ b/drivers/net/wireless/marvell/mwifiex/cmdevt.c
@@ -922,10 +922,9 @@ int mwifiex_process_cmdresp(struct mwifiex_adapter *adapter)
  * It will re-send the same command again.
  */
 void
-mwifiex_cmd_timeout_func(unsigned long function_context)
+mwifiex_cmd_timeout_func(struct timer_list *t)
 {
-	struct mwifiex_adapter *adapter =
-		(struct mwifiex_adapter *) function_context;
+	struct mwifiex_adapter *adapter = from_timer(adapter, t, cmd_timer);
 	struct cmd_ctrl_node *cmd_node;
 
 	adapter->is_cmd_timedout = 1;
diff --git a/drivers/net/wireless/marvell/mwifiex/init.c b/drivers/net/wireless/marvell/mwifiex/init.c
index e11919db7818..9005c4129a51 100644
--- a/drivers/net/wireless/marvell/mwifiex/init.c
+++ b/drivers/net/wireless/marvell/mwifiex/init.c
@@ -52,9 +52,9 @@ static int mwifiex_add_bss_prio_tbl(struct mwifiex_private *priv)
 	return 0;
 }
 
-static void wakeup_timer_fn(unsigned long data)
+static void wakeup_timer_fn(struct timer_list *t)
 {
-	struct mwifiex_adapter *adapter = (struct mwifiex_adapter *)data;
+	struct mwifiex_adapter *adapter = from_timer(adapter, t, wakeup_timer);
 
 	mwifiex_dbg(adapter, ERROR, "Firmware wakeup failed\n");
 	adapter->hw_status = MWIFIEX_HW_STATUS_RESET;
@@ -313,8 +313,7 @@ static void mwifiex_init_adapter(struct mwifiex_adapter *adapter)
 	adapter->iface_limit.uap_intf = MWIFIEX_MAX_UAP_NUM;
 	adapter->iface_limit.p2p_intf = MWIFIEX_MAX_P2P_NUM;
 	adapter->active_scan_triggered = false;
-	setup_timer(&adapter->wakeup_timer, wakeup_timer_fn,
-		    (unsigned long)adapter);
+	timer_setup(&adapter->wakeup_timer, wakeup_timer_fn, 0);
 }
 
 /*
diff --git a/drivers/net/wireless/marvell/mwifiex/main.c b/drivers/net/wireless/marvell/mwifiex/main.c
index ee40b739b289..a96bd7e653bf 100644
--- a/drivers/net/wireless/marvell/mwifiex/main.c
+++ b/drivers/net/wireless/marvell/mwifiex/main.c
@@ -100,8 +100,7 @@ static int mwifiex_register(void *card, struct device *dev,
 	}
 	mwifiex_init_lock_list(adapter);
 
-	setup_timer(&adapter->cmd_timer, mwifiex_cmd_timeout_func,
-		    (unsigned long)adapter);
+	timer_setup(&adapter->cmd_timer, mwifiex_cmd_timeout_func, 0);
 
 	return 0;
 
diff --git a/drivers/net/wireless/marvell/mwifiex/main.h b/drivers/net/wireless/marvell/mwifiex/main.h
index a34de8582e91..154c0796c0c5 100644
--- a/drivers/net/wireless/marvell/mwifiex/main.h
+++ b/drivers/net/wireless/marvell/mwifiex/main.h
@@ -1072,7 +1072,7 @@ int mwifiex_complete_cmd(struct mwifiex_adapter *adapter,
 int mwifiex_send_cmd(struct mwifiex_private *priv, u16 cmd_no,
 		     u16 cmd_action, u32 cmd_oid, void *data_buf, bool sync);
 
-void mwifiex_cmd_timeout_func(unsigned long function_context);
+void mwifiex_cmd_timeout_func(struct timer_list *t);
 
 int mwifiex_get_debug_info(struct mwifiex_private *,
 			   struct mwifiex_debug_info *);
@@ -1617,7 +1617,7 @@ void mwifiex_auto_tdls_update_peer_status(struct mwifiex_private *priv,
 					  const u8 *mac, u8 link_status);
 void mwifiex_auto_tdls_update_peer_signal(struct mwifiex_private *priv,
 					  u8 *mac, s8 snr, s8 nflr);
-void mwifiex_check_auto_tdls(unsigned long context);
+void mwifiex_check_auto_tdls(struct timer_list *t);
 void mwifiex_add_auto_tdls_peer(struct mwifiex_private *priv, const u8 *mac);
 void mwifiex_setup_auto_tdls_timer(struct mwifiex_private *priv);
 void mwifiex_clean_auto_tdls(struct mwifiex_private *priv);
diff --git a/drivers/net/wireless/marvell/mwifiex/tdls.c b/drivers/net/wireless/marvell/mwifiex/tdls.c
index e76af2866a19..528fd1fc19d2 100644
--- a/drivers/net/wireless/marvell/mwifiex/tdls.c
+++ b/drivers/net/wireless/marvell/mwifiex/tdls.c
@@ -1389,9 +1389,9 @@ void mwifiex_auto_tdls_update_peer_signal(struct mwifiex_private *priv,
 	spin_unlock_irqrestore(&priv->auto_tdls_lock, flags);
 }
 
-void mwifiex_check_auto_tdls(unsigned long context)
+void mwifiex_check_auto_tdls(struct timer_list *t)
 {
-	struct mwifiex_private *priv = (struct mwifiex_private *)context;
+	struct mwifiex_private *priv = from_timer(priv, t, auto_tdls_timer);
 	struct mwifiex_auto_tdls_peer *tdls_peer;
 	unsigned long flags;
 	u16 reason = WLAN_REASON_TDLS_TEARDOWN_UNSPECIFIED;
@@ -1463,8 +1463,7 @@ void mwifiex_check_auto_tdls(unsigned long context)
 
 void mwifiex_setup_auto_tdls_timer(struct mwifiex_private *priv)
 {
-	setup_timer(&priv->auto_tdls_timer, mwifiex_check_auto_tdls,
-		    (unsigned long)priv);
+	timer_setup(&priv->auto_tdls_timer, mwifiex_check_auto_tdls, 0);
 	priv->auto_tdls_timer_active = true;
 	mod_timer(&priv->auto_tdls_timer,
 		  jiffies + msecs_to_jiffies(MWIFIEX_TIMER_10S));
diff --git a/drivers/net/wireless/marvell/mwifiex/usb.c b/drivers/net/wireless/marvell/mwifiex/usb.c
index f4f2b9b27e32..4bc244801636 100644
--- a/drivers/net/wireless/marvell/mwifiex/usb.c
+++ b/drivers/net/wireless/marvell/mwifiex/usb.c
@@ -1096,12 +1096,12 @@ static int mwifiex_usb_aggr_tx_data(struct mwifiex_adapter *adapter, u8 ep,
 	return -EINPROGRESS;
 }
 
-static void mwifiex_usb_tx_aggr_tmo(unsigned long context)
+static void mwifiex_usb_tx_aggr_tmo(struct timer_list *t)
 {
 	struct urb_context *urb_cnxt = NULL;
 	struct sk_buff *skb_send = NULL;
 	struct tx_aggr_tmr_cnxt *timer_context =
-		(struct tx_aggr_tmr_cnxt *)context;
+		from_timer(timer_context, t, hold_timer);
 	struct mwifiex_adapter *adapter = timer_context->adapter;
 	struct usb_tx_data_port *port = timer_context->port;
 	unsigned long flags;
@@ -1236,9 +1236,8 @@ static int mwifiex_usb_tx_init(struct mwifiex_adapter *adapter)
 		port->tx_aggr.timer_cnxt.port = port;
 		port->tx_aggr.timer_cnxt.is_hold_timer_set = false;
 		port->tx_aggr.timer_cnxt.hold_tmo_msecs = 0;
-		setup_timer(&port->tx_aggr.timer_cnxt.hold_timer,
-			    mwifiex_usb_tx_aggr_tmo,
-			    (unsigned long)&port->tx_aggr.timer_cnxt);
+		timer_setup(&port->tx_aggr.timer_cnxt.hold_timer,
+			    mwifiex_usb_tx_aggr_tmo, 0);
 	}
 
 	return 0;
-- 
2.7.4


-- 
Kees Cook
Pixel Security
