From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] net: atm/mpc: Stop using open-coded timer .data field
Date: Tue, 24 Oct 2017 01:46:45 -0700
Message-ID: <20171024084645.GA23963@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bhumika Goyal <bhumirks@gmail.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Alexey Dobriyan <adobriyan@gmail.com>,
        "Reshetova, Elena" <elena.reshetova@intel.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In preparation for unconditionally passing the struct timer_list pointer to
all timer callbacks, switch to using an explicit static variable to hold
additional expiration details.

Cc: "David S. Miller" <davem@davemloft.net>
Cc: Bhumika Goyal <bhumirks@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexey Dobriyan <adobriyan@gmail.com>
Cc: "Reshetova, Elena" <elena.reshetova@intel.com>
Cc: netdev@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 net/atm/mpc.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/net/atm/mpc.c b/net/atm/mpc.c
index b43d99430eb6..883d25778fa4 100644
--- a/net/atm/mpc.c
+++ b/net/atm/mpc.c
@@ -95,7 +95,7 @@ static netdev_tx_t mpc_send_packet(struct sk_buff *skb,
 static int mpoa_event_listener(struct notifier_block *mpoa_notifier,
 			       unsigned long event, void *dev);
 static void mpc_timer_refresh(void);
-static void mpc_cache_check(unsigned long checking_time);
+static void mpc_cache_check(struct timer_list *unused);
 
 static struct llc_snap_hdr llc_snap_mpoa_ctrl = {
 	0xaa, 0xaa, 0x03,
@@ -1407,15 +1407,17 @@ static void clean_up(struct k_message *msg, struct mpoa_client *mpc, int action)
 	msg_to_mpoad(msg, mpc);
 }
 
+static unsigned long checking_time;
+
 static void mpc_timer_refresh(void)
 {
 	mpc_timer.expires = jiffies + (MPC_P2 * HZ);
-	mpc_timer.data = mpc_timer.expires;
-	mpc_timer.function = mpc_cache_check;
+	checking_time = mpc_timer.expires;
+	mpc_timer.function = (TIMER_FUNC_TYPE)mpc_cache_check;
 	add_timer(&mpc_timer);
 }
 
-static void mpc_cache_check(unsigned long checking_time)
+static void mpc_cache_check(struct timer_list *unused)
 {
 	struct mpoa_client *mpc = mpcs;
 	static unsigned long previous_resolving_check_time;
-- 
2.7.4


-- 
Kees Cook
Pixel Security
