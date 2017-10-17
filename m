From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 49/58] net: neterion: Convert timers to use timer_setup()
Date: Mon, 16 Oct 2017 17:29:33 -0700
Message-ID: <1508200182-104605-50-git-send-email-keescook@chromium.org>
References: <1508200182-104605-1-git-send-email-keescook@chromium.org>
Cc: Kees Cook <keescook@chromium.org>, Jon Mason <jdmason@kudzu.us>,
        netdev@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>,
        linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1508200182-104605-1-git-send-email-keescook@chromium.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In preparation for unconditionally passing the struct timer_list pointer to
all timer callbacks, switch to using the new timer_setup() and from_timer()
to pass the timer pointer explicitly.

Cc: Jon Mason <jdmason@kudzu.us>
Cc: netdev@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 drivers/net/ethernet/neterion/s2io.c | 13 ++++---------
 drivers/net/ethernet/neterion/s2io.h |  2 +-
 2 files changed, 5 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/neterion/s2io.c b/drivers/net/ethernet/neterion/s2io.c
index 462eda926b1c..b8983e73265a 100644
--- a/drivers/net/ethernet/neterion/s2io.c
+++ b/drivers/net/ethernet/neterion/s2io.c
@@ -337,12 +337,6 @@ static const char ethtool_driver_stats_keys[][ETH_GSTRING_LEN] = {
 #define S2IO_TEST_LEN	ARRAY_SIZE(s2io_gstrings)
 #define S2IO_STRINGS_LEN	(S2IO_TEST_LEN * ETH_GSTRING_LEN)
 
-#define S2IO_TIMER_CONF(timer, handle, arg, exp)	\
-	init_timer(&timer);				\
-	timer.function = handle;			\
-	timer.data = (unsigned long)arg;		\
-	mod_timer(&timer, (jiffies + exp))		\
-
 /* copy mac addr to def_mac_addr array */
 static void do_s2io_copy_mac_addr(struct s2io_nic *sp, int offset, u64 mac_addr)
 {
@@ -4193,9 +4187,9 @@ static netdev_tx_t s2io_xmit(struct sk_buff *skb, struct net_device *dev)
 }
 
 static void
-s2io_alarm_handle(unsigned long data)
+s2io_alarm_handle(struct timer_list *t)
 {
-	struct s2io_nic *sp = (struct s2io_nic *)data;
+	struct s2io_nic *sp = from_timer(sp, t, alarm_timer);
 	struct net_device *dev = sp->dev;
 
 	s2io_handle_errors(dev);
@@ -7186,7 +7180,8 @@ static int s2io_card_up(struct s2io_nic *sp)
 		return -ENODEV;
 	}
 
-	S2IO_TIMER_CONF(sp->alarm_timer, s2io_alarm_handle, sp, (HZ/2));
+	timer_setup(&sp->alarm_timer, s2io_alarm_handle, 0);
+	mod_timer(&sp->alarm_timer, jiffies + HZ / 2);
 
 	set_bit(__S2IO_STATE_CARD_UP, &sp->state);
 
diff --git a/drivers/net/ethernet/neterion/s2io.h b/drivers/net/ethernet/neterion/s2io.h
index 6c5997dc8afc..1a24a7218794 100644
--- a/drivers/net/ethernet/neterion/s2io.h
+++ b/drivers/net/ethernet/neterion/s2io.h
@@ -1094,7 +1094,7 @@ static int s2io_poll_msix(struct napi_struct *napi, int budget);
 static int s2io_poll_inta(struct napi_struct *napi, int budget);
 static void s2io_init_pci(struct s2io_nic * sp);
 static int do_s2io_prog_unicast(struct net_device *dev, u8 *addr);
-static void s2io_alarm_handle(unsigned long data);
+static void s2io_alarm_handle(struct timer_list *t);
 static irqreturn_t
 s2io_msix_ring_handle(int irq, void *dev_id);
 static irqreturn_t
-- 
2.7.4
