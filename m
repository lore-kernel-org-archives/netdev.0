From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 01/58] net/decnet: Convert timers to use timer_setup()
Date: Mon, 16 Oct 2017 17:28:45 -0700
Message-ID: <1508200182-104605-2-git-send-email-keescook@chromium.org>
References: <1508200182-104605-1-git-send-email-keescook@chromium.org>
Cc: Kees Cook <keescook@chromium.org>,
        Johannes Berg <johannes.berg@intel.com>,
        David Ahern <dsa@cumulusnetworks.com>,
        linux-decnet-user@lists.sourceforge.net, netdev@vger.kernel.org,
        Thomas Gleixner <tglx@linutronix.de>,
        linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1508200182-104605-1-git-send-email-keescook@chromium.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In preparation for unconditionally passing the struct timer_list pointer to
all timer callbacks, switch to using the new timer_setup() and from_timer()
to pass the timer pointer explicitly.

Cc: "David S. Miller" <davem@davemloft.net>
Cc: Johannes Berg <johannes.berg@intel.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
Cc: linux-decnet-user@lists.sourceforge.net
Cc: netdev@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 include/net/dn.h        |  7 -------
 include/net/dn_nsp.h    |  1 -
 net/decnet/af_decnet.c  |  4 ----
 net/decnet/dn_dev.c     | 12 +++++-------
 net/decnet/dn_nsp_out.c | 11 -----------
 5 files changed, 5 insertions(+), 30 deletions(-)

diff --git a/include/net/dn.h b/include/net/dn.h
index 913b73d239f5..4394f7d5cfe8 100644
--- a/include/net/dn.h
+++ b/include/net/dn.h
@@ -122,13 +122,6 @@ struct dn_scp                                   /* Session Control Port */
 	unsigned long keepalive;
 	void (*keepalive_fxn)(struct sock *sk);
 
-	/*
-	 * This stuff is for the fast timer for delayed acks
-	 */
-	struct timer_list delack_timer;
-	int delack_pending;
-	void (*delack_fxn)(struct sock *sk);
-
 };
 
 static inline struct dn_scp *DN_SK(struct sock *sk)
diff --git a/include/net/dn_nsp.h b/include/net/dn_nsp.h
index 3a3e33d18456..413a15e5339c 100644
--- a/include/net/dn_nsp.h
+++ b/include/net/dn_nsp.h
@@ -17,7 +17,6 @@
 
 void dn_nsp_send_data_ack(struct sock *sk);
 void dn_nsp_send_oth_ack(struct sock *sk);
-void dn_nsp_delayed_ack(struct sock *sk);
 void dn_send_conn_ack(struct sock *sk);
 void dn_send_conn_conf(struct sock *sk, gfp_t gfp);
 void dn_nsp_send_disc(struct sock *sk, unsigned char type,
diff --git a/net/decnet/af_decnet.c b/net/decnet/af_decnet.c
index 73a0399dc7a2..d4c9a8bbad3e 100644
--- a/net/decnet/af_decnet.c
+++ b/net/decnet/af_decnet.c
@@ -533,10 +533,6 @@ static struct sock *dn_alloc_sock(struct net *net, struct socket *sock, gfp_t gf
 	scp->keepalive = 10 * HZ;
 	scp->keepalive_fxn = dn_keepalive;
 
-	init_timer(&scp->delack_timer);
-	scp->delack_pending = 0;
-	scp->delack_fxn = dn_nsp_delayed_ack;
-
 	dn_start_slow_timer(sk);
 out:
 	return sk;
diff --git a/net/decnet/dn_dev.c b/net/decnet/dn_dev.c
index 4d339de56862..92dbaa3f1eae 100644
--- a/net/decnet/dn_dev.c
+++ b/net/decnet/dn_dev.c
@@ -1038,14 +1038,14 @@ static void dn_eth_down(struct net_device *dev)
 
 static void dn_dev_set_timer(struct net_device *dev);
 
-static void dn_dev_timer_func(unsigned long arg)
+static void dn_dev_timer_func(struct timer_list *t)
 {
-	struct net_device *dev = (struct net_device *)arg;
-	struct dn_dev *dn_db;
+	struct dn_dev *dn_db = from_timer(dn_db, t, timer);
+	struct net_device *dev;
 	struct dn_ifaddr *ifa;
 
 	rcu_read_lock();
-	dn_db = rcu_dereference(dev->dn_ptr);
+	dev = dn_db->dev;
 	if (dn_db->t3 <= dn_db->parms.t2) {
 		if (dn_db->parms.timer3) {
 			for (ifa = rcu_dereference(dn_db->ifa_list);
@@ -1070,8 +1070,6 @@ static void dn_dev_set_timer(struct net_device *dev)
 	if (dn_db->parms.t2 > dn_db->parms.t3)
 		dn_db->parms.t2 = dn_db->parms.t3;
 
-	dn_db->timer.data = (unsigned long)dev;
-	dn_db->timer.function = dn_dev_timer_func;
 	dn_db->timer.expires = jiffies + (dn_db->parms.t2 * HZ);
 
 	add_timer(&dn_db->timer);
@@ -1100,7 +1098,7 @@ static struct dn_dev *dn_dev_create(struct net_device *dev, int *err)
 
 	rcu_assign_pointer(dev->dn_ptr, dn_db);
 	dn_db->dev = dev;
-	init_timer(&dn_db->timer);
+	timer_setup(&dn_db->timer, dn_dev_timer_func, 0);
 
 	dn_db->uptime = jiffies;
 
diff --git a/net/decnet/dn_nsp_out.c b/net/decnet/dn_nsp_out.c
index 66f035e476ea..e50a4adfcf7e 100644
--- a/net/decnet/dn_nsp_out.c
+++ b/net/decnet/dn_nsp_out.c
@@ -491,17 +491,6 @@ void dn_send_conn_ack (struct sock *sk)
 	dn_nsp_send(skb);
 }
 
-void dn_nsp_delayed_ack(struct sock *sk)
-{
-	struct dn_scp *scp = DN_SK(sk);
-
-	if (scp->ackxmt_oth != scp->numoth_rcv)
-		dn_nsp_send_oth_ack(sk);
-
-	if (scp->ackxmt_dat != scp->numdat_rcv)
-		dn_nsp_send_data_ack(sk);
-}
-
 static int dn_nsp_retrans_conn_conf(struct sock *sk)
 {
 	struct dn_scp *scp = DN_SK(sk);
-- 
2.7.4
