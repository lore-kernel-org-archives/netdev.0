From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 25/31] net/atm/mpc: Use separate static data field with with static timer
Date: Thu, 31 Aug 2017 16:29:37 -0700
Message-ID: <1504222183-61202-26-git-send-email-keescook@chromium.org>
References: <1504222183-61202-1-git-send-email-keescook@chromium.org>
Cc: Kees Cook <keescook@chromium.org>,
        "David S. Miller" <davem@davemloft.net>,
        Andrew Morton <akpm@linux-foundation.org>,
        Alexey Dobriyan <adobriyan@gmail.com>,
        "Reshetova, Elena" <elena.reshetova@intel.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:37107 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752242AbdHaXtT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 31 Aug 2017 19:49:19 -0400
Received: by mail-pg0-f42.google.com with SMTP id 83so3183336pgb.4
        for <netdev@vger.kernel.org>; Thu, 31 Aug 2017 16:49:18 -0700 (PDT)
In-Reply-To: <1504222183-61202-1-git-send-email-keescook@chromium.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In preparation for changing the timer callback argument to the timer
pointer, move to a separate static data variable.

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
index 5baa31b8500c..fc24a46500ae 100644
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
