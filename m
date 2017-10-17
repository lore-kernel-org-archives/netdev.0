From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 53/58] net: atm: Convert timers to use timer_setup()
Date: Mon, 16 Oct 2017 17:29:37 -0700
Message-ID: <1508200182-104605-54-git-send-email-keescook@chromium.org>
References: <1508200182-104605-1-git-send-email-keescook@chromium.org>
Cc: Kees Cook <keescook@chromium.org>,
        Hans Liljestrand <ishkamiel@gmail.com>,
        "Reshetova, Elena" <elena.reshetova@intel.com>,
        Bhumika Goyal <bhumirks@gmail.com>,
        Johannes Berg <johannes.berg@intel.com>,
        Roopa Prabhu <roopa@cumulusnetworks.com>,
        Augusto Mecking Caringi <augustocaringi@gmail.com>,
        Jarod Wilson <jarod@redhat.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        Thomas Gleixner <tglx@linutronix.de>,
        Alexey Dobriyan <adobriyan@gmail.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1508200182-104605-1-git-send-email-keescook@chromium.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In preparation for unconditionally passing the struct timer_list pointer to
all timer callbacks, switch to using the new timer_setup() and from_timer()
to pass the timer pointer explicitly. Also drops a redundant initialization
that is already set up by DEFINE_TIMER.

Cc: "David S. Miller" <davem@davemloft.net>
Cc: Hans Liljestrand <ishkamiel@gmail.com>
Cc: "Reshetova, Elena" <elena.reshetova@intel.com>
Cc: Bhumika Goyal <bhumirks@gmail.com>
Cc: Johannes Berg <johannes.berg@intel.com>
Cc: Roopa Prabhu <roopa@cumulusnetworks.com>
Cc: Augusto Mecking Caringi <augustocaringi@gmail.com>
Cc: Jarod Wilson <jarod@redhat.com>
Cc: Kalle Valo <kvalo@codeaurora.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Alexey Dobriyan <adobriyan@gmail.com>
Cc: netdev@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 net/atm/clip.c |  4 ++--
 net/atm/lec.c  | 19 +++++++++----------
 net/atm/mpc.c  |  1 -
 3 files changed, 11 insertions(+), 13 deletions(-)

diff --git a/net/atm/clip.c b/net/atm/clip.c
index 65f706e4344c..d4f6029d5109 100644
--- a/net/atm/clip.c
+++ b/net/atm/clip.c
@@ -153,7 +153,7 @@ static int neigh_check_cb(struct neighbour *n)
 	return 1;
 }
 
-static void idle_timer_check(unsigned long dummy)
+static void idle_timer_check(struct timer_list *unused)
 {
 	write_lock(&arp_tbl.lock);
 	__neigh_for_each_release(&arp_tbl, neigh_check_cb);
@@ -887,7 +887,7 @@ static int __init atm_clip_init(void)
 	register_netdevice_notifier(&clip_dev_notifier);
 	register_inetaddr_notifier(&clip_inet_notifier);
 
-	setup_timer(&idle_timer, idle_timer_check, 0);
+	timer_setup(&idle_timer, idle_timer_check, 0);
 
 #ifdef CONFIG_PROC_FS
 	{
diff --git a/net/atm/lec.c b/net/atm/lec.c
index a3d93a1bb133..c976196da3ea 100644
--- a/net/atm/lec.c
+++ b/net/atm/lec.c
@@ -1232,7 +1232,7 @@ static void lane2_associate_ind(struct net_device *dev, const u8 *mac_addr,
 #define LEC_ARP_REFRESH_INTERVAL (3*HZ)
 
 static void lec_arp_check_expire(struct work_struct *work);
-static void lec_arp_expire_arp(unsigned long data);
+static void lec_arp_expire_arp(struct timer_list *t);
 
 /*
  * Arp table funcs
@@ -1559,8 +1559,7 @@ static struct lec_arp_table *make_entry(struct lec_priv *priv,
 	}
 	ether_addr_copy(to_return->mac_addr, mac_addr);
 	INIT_HLIST_NODE(&to_return->next);
-	setup_timer(&to_return->timer, lec_arp_expire_arp,
-			(unsigned long)to_return);
+	timer_setup(&to_return->timer, lec_arp_expire_arp, 0);
 	to_return->last_used = jiffies;
 	to_return->priv = priv;
 	skb_queue_head_init(&to_return->tx_wait);
@@ -1569,11 +1568,11 @@ static struct lec_arp_table *make_entry(struct lec_priv *priv,
 }
 
 /* Arp sent timer expired */
-static void lec_arp_expire_arp(unsigned long data)
+static void lec_arp_expire_arp(struct timer_list *t)
 {
 	struct lec_arp_table *entry;
 
-	entry = (struct lec_arp_table *)data;
+	entry = from_timer(entry, t, timer);
 
 	pr_debug("\n");
 	if (entry->status == ESI_ARP_PENDING) {
@@ -1591,10 +1590,10 @@ static void lec_arp_expire_arp(unsigned long data)
 }
 
 /* Unknown/unused vcc expire, remove associated entry */
-static void lec_arp_expire_vcc(unsigned long data)
+static void lec_arp_expire_vcc(struct timer_list *t)
 {
 	unsigned long flags;
-	struct lec_arp_table *to_remove = (struct lec_arp_table *)data;
+	struct lec_arp_table *to_remove = from_timer(to_remove, t, timer);
 	struct lec_priv *priv = to_remove->priv;
 
 	del_timer(&to_remove->timer);
@@ -1799,7 +1798,7 @@ static struct atm_vcc *lec_arp_resolve(struct lec_priv *priv,
 		else
 			send_to_lecd(priv, l_arp_xmt, mac_to_find, NULL, NULL);
 		entry->timer.expires = jiffies + (1 * HZ);
-		entry->timer.function = lec_arp_expire_arp;
+		entry->timer.function = (TIMER_FUNC_TYPE)lec_arp_expire_arp;
 		add_timer(&entry->timer);
 		found = priv->mcast_vcc;
 	}
@@ -1999,7 +1998,7 @@ lec_vcc_added(struct lec_priv *priv, const struct atmlec_ioc *ioc_data,
 		entry->old_recv_push = old_push;
 		entry->status = ESI_UNKNOWN;
 		entry->timer.expires = jiffies + priv->vcc_timeout_period;
-		entry->timer.function = lec_arp_expire_vcc;
+		entry->timer.function = (TIMER_FUNC_TYPE)lec_arp_expire_vcc;
 		hlist_add_head(&entry->next, &priv->lec_no_forward);
 		add_timer(&entry->timer);
 		dump_arp_table(priv);
@@ -2083,7 +2082,7 @@ lec_vcc_added(struct lec_priv *priv, const struct atmlec_ioc *ioc_data,
 	entry->status = ESI_UNKNOWN;
 	hlist_add_head(&entry->next, &priv->lec_arp_empty_ones);
 	entry->timer.expires = jiffies + priv->vcc_timeout_period;
-	entry->timer.function = lec_arp_expire_vcc;
+	entry->timer.function = (TIMER_FUNC_TYPE)lec_arp_expire_vcc;
 	add_timer(&entry->timer);
 	pr_debug("After vcc was added\n");
 	dump_arp_table(priv);
diff --git a/net/atm/mpc.c b/net/atm/mpc.c
index 3b59a053b7cb..4c0d5d614b87 100644
--- a/net/atm/mpc.c
+++ b/net/atm/mpc.c
@@ -800,7 +800,6 @@ static int atm_mpoa_mpoad_attach(struct atm_vcc *vcc, int arg)
 	int err;
 
 	if (mpcs == NULL) {
-		init_timer(&mpc_timer);
 		mpc_timer_refresh();
 
 		/* This lets us now how our LECs are doing */
-- 
2.7.4
