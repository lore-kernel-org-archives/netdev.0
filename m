From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 41/58] net/atm/mpc: Stop using open-coded timer .data field
Date: Mon, 16 Oct 2017 17:29:25 -0700
Message-ID: <1508200182-104605-42-git-send-email-keescook@chromium.org>
References: <1508200182-104605-1-git-send-email-keescook@chromium.org>
Cc: Kees Cook <keescook@chromium.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Alexey Dobriyan <adobriyan@gmail.com>,
        "Reshetova, Elena" <elena.reshetova@intel.com>,
        netdev@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>,
        linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1508200182-104605-1-git-send-email-keescook@chromium.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In preparation for unconditionally passing the struct timer_list pointer to
all timer callbacks, switch to using an explicit static variable to hold
additional expiration details.

Cc: "David S. Miller" <davem@davemloft.net>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexey Dobriyan <adobriyan@gmail.com>
Cc: "Reshetova, Elena" <elena.reshetova@intel.com>
Cc: netdev@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 net/atm/mpc.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/atm/mpc.c b/net/atm/mpc.c
index 63138c8c2269..3b59a053b7cb 100644
--- a/net/atm/mpc.c
+++ b/net/atm/mpc.c
@@ -95,7 +95,7 @@ static netdev_tx_t mpc_send_packet(struct sk_buff *skb,
 static int mpoa_event_listener(struct notifier_block *mpoa_notifier,
 			       unsigned long event, void *dev);
 static void mpc_timer_refresh(void);
-static void mpc_cache_check(unsigned long checking_time);
+static void mpc_cache_check(unsigned long unused);
 
 static struct llc_snap_hdr llc_snap_mpoa_ctrl = {
 	0xaa, 0xaa, 0x03,
@@ -121,7 +121,8 @@ static struct notifier_block mpoa_notifier = {
 
 struct mpoa_client *mpcs = NULL; /* FIXME */
 static struct atm_mpoa_qos *qos_head = NULL;
-static DEFINE_TIMER(mpc_timer, NULL);
+static DEFINE_TIMER(mpc_timer, mpc_cache_check);
+static unsigned long checking_time;
 
 
 static struct mpoa_client *find_mpc_by_itfnum(int itf)
@@ -1411,12 +1412,11 @@ static void clean_up(struct k_message *msg, struct mpoa_client *mpc, int action)
 static void mpc_timer_refresh(void)
 {
 	mpc_timer.expires = jiffies + (MPC_P2 * HZ);
-	mpc_timer.data = mpc_timer.expires;
-	mpc_timer.function = mpc_cache_check;
+	checking_time = mpc_timer.expires;
 	add_timer(&mpc_timer);
 }
 
-static void mpc_cache_check(unsigned long checking_time)
+static void mpc_cache_check(unsigned long unused)
 {
 	struct mpoa_client *mpc = mpcs;
 	static unsigned long previous_resolving_check_time;
-- 
2.7.4
