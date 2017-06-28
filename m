From: Mike Galbraith <efault@gmx.de>
Subject: kernel (master) build failure w. !CONFIG_NET_RX_BUSY_POLL
Date: Wed, 28 Jun 2017 10:01:00 +0200
Message-ID: <1498636860.5505.28.camel@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: RT <linux-rt-users@vger.kernel.org>
To: netdev <netdev@vger.kernel.org>
Return-path: <linux-rt-users-owner@vger.kernel.org>
Sender: linux-rt-users-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Greetings network wizards,

The latest RT explicitly disables CONFIG_NET_RX_BUSY_POLL, thus
uncovering $subject.  Below is what I did about it.

	-Mike

net: Move napi_hash_add/del() inside CONFIG_NET_RX_BUSY_POLL

Since 545cd5e5ec54 ("net: Busy polling should ignore sender CPUs"),
kernel build fails when CONFIG_NET_RX_BUSY_POLL is disabled.  Move
napi_hash_add/del() accordingly.

Banged-upon-by: Mike Galbraith <efault@gmx.de>
---
 include/linux/netdevice.h |    8 ++++++++
 net/core/dev.c            |   12 ++++++++----
 2 files changed, 16 insertions(+), 4 deletions(-)

--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -479,6 +479,8 @@ static inline bool napi_complete(struct
 	return napi_complete_done(n, 0);
 }
 
+#ifdef CONFIG_NET_RX_BUSY_POLL
+
 /**
  *	napi_hash_del - remove a NAPI from global table
  *	@napi: NAPI context
@@ -493,6 +495,12 @@ static inline bool napi_complete(struct
  */
 bool napi_hash_del(struct napi_struct *napi);
 
+#else /* !CONFIG_NET_RX_BUSY_POLL */
+
+static inline bool napi_hash_del(struct napi_struct *napi) { return false; }
+
+#endif /* CONFIG_NET_RX_BUSY_POLL */
+
 /**
  *	napi_disable - prevent NAPI from scheduling
  *	@n: NAPI context
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -184,11 +184,13 @@ static int call_netdevice_notifiers_info
 DEFINE_RWLOCK(dev_base_lock);
 EXPORT_SYMBOL(dev_base_lock);
 
+#ifdef CONFIG_NET_RX_BUSY_POLL
 /* protects napi_hash addition/deletion and napi_gen_id */
 static DEFINE_SPINLOCK(napi_hash_lock);
 
 static unsigned int napi_gen_id = NR_CPUS;
 static DEFINE_READ_MOSTLY_HASHTABLE(napi_hash, 8);
+#endif
 
 static seqcount_t devnet_rename_seq;
 static DEFINE_MUTEX(devnet_rename_mutex);
@@ -5185,6 +5187,8 @@ bool napi_complete_done(struct napi_stru
 }
 EXPORT_SYMBOL(napi_complete_done);
 
+#if defined(CONFIG_NET_RX_BUSY_POLL)
+
 /* must be called under rcu_read_lock(), as we dont take a reference */
 static struct napi_struct *napi_by_id(unsigned int napi_id)
 {
@@ -5198,8 +5202,6 @@ static struct napi_struct *napi_by_id(un
 	return NULL;
 }
 
-#if defined(CONFIG_NET_RX_BUSY_POLL)
-
 #define BUSY_POLL_BUDGET 8
 
 static void busy_poll_stop(struct napi_struct *napi, void *have_poll_lock)
@@ -5300,8 +5302,6 @@ void napi_busy_loop(unsigned int napi_id
 }
 EXPORT_SYMBOL(napi_busy_loop);
 
-#endif /* CONFIG_NET_RX_BUSY_POLL */
-
 static void napi_hash_add(struct napi_struct *napi)
 {
 	if (test_bit(NAPI_STATE_NO_BUSY_POLL, &napi->state) ||
@@ -5341,6 +5341,8 @@ bool napi_hash_del(struct napi_struct *n
 }
 EXPORT_SYMBOL_GPL(napi_hash_del);
 
+#endif /* CONFIG_NET_RX_BUSY_POLL */
+
 static enum hrtimer_restart napi_watchdog(struct hrtimer *timer)
 {
 	struct napi_struct *napi;
@@ -5377,7 +5379,9 @@ void netif_napi_add(struct net_device *d
 	napi->poll_owner = -1;
 #endif
 	set_bit(NAPI_STATE_SCHED, &napi->state);
+#ifdef CONFIG_NET_RX_BUSY_POLL
 	napi_hash_add(napi);
+#endif
 }
 EXPORT_SYMBOL(netif_napi_add);
 
