From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: [PATCH] [NET]: Remove FASTCALL/fastcall macros
Date: Sun, 16 Dec 2007 20:16:25 -0800
Message-ID: <1197864985.3749.117.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.187]:50955 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751863AbXLQEQV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Dec 2007 23:16:21 -0500
Received: by rv-out-0910.google.com with SMTP id k20so1730684rvb.1
        for <netdev@vger.kernel.org>; Sun, 16 Dec 2007 20:16:21 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

X86_32 was the last user of the FASTCALL/fastcall macros, now that it
uses regparm(3) by default, these macros expand to nothing.

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
---
Dave, this is a wrap-up of my patch in your net-2.6.25.git with
the build breakage fix from Andrew Morton included.  This also
chops the fastcall macro which is also now empty.

Original: 172f5efbe9150a82e8d5b0562bbe128492ac820e
Buildfix: 451ff1232b1ff3d32635ea4844ef0d1376460c21

 drivers/net/ns83820.c          |   12 ++++--------
 include/net/bluetooth/rfcomm.h |    4 ++--
 include/net/sock.h             |    4 ++--
 net/bluetooth/rfcomm/core.c    |    4 ++--
 net/core/dev.c                 |    2 +-
 net/core/sock.c                |    4 ++--
 6 files changed, 13 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ns83820.c b/drivers/net/ns83820.c
index ea71f6d..b42c05f 100644
--- a/drivers/net/ns83820.c
+++ b/drivers/net/ns83820.c
@@ -611,8 +611,7 @@ static inline int rx_refill(struct net_device *ndev, gfp_t gfp)
 	return i ? 0 : -ENOMEM;
 }
 
-static void FASTCALL(rx_refill_atomic(struct net_device *ndev));
-static void fastcall rx_refill_atomic(struct net_device *ndev)
+static void rx_refill_atomic(struct net_device *ndev)
 {
 	rx_refill(ndev, GFP_ATOMIC);
 }
@@ -633,8 +632,7 @@ static inline void clear_rx_desc(struct ns83820 *dev, unsigned i)
 	build_rx_desc(dev, dev->rx_info.descs + (DESC_SIZE * i), 0, 0, CMDSTS_OWN, 0);
 }
 
-static void FASTCALL(phy_intr(struct net_device *ndev));
-static void fastcall phy_intr(struct net_device *ndev)
+static void phy_intr(struct net_device *ndev)
 {
 	struct ns83820 *dev = PRIV(ndev);
 	static const char *speeds[] = { "10", "100", "1000", "1000(?)", "1000F" };
@@ -832,8 +830,7 @@ static void ns83820_cleanup_rx(struct ns83820 *dev)
 	}
 }
 
-static void FASTCALL(ns83820_rx_kick(struct net_device *ndev));
-static void fastcall ns83820_rx_kick(struct net_device *ndev)
+static void ns83820_rx_kick(struct net_device *ndev)
 {
 	struct ns83820 *dev = PRIV(ndev);
 	/*if (nr_rx_empty(dev) >= NR_RX_DESC/4)*/ {
@@ -854,8 +851,7 @@ static void fastcall ns83820_rx_kick(struct net_device *ndev)
 /* rx_irq
  *
  */
-static void FASTCALL(rx_irq(struct net_device *ndev));
-static void fastcall rx_irq(struct net_device *ndev)
+static void rx_irq(struct net_device *ndev)
 {
 	struct ns83820 *dev = PRIV(ndev);
 	struct rx_info *info = &dev->rx_info;
diff --git a/include/net/bluetooth/rfcomm.h b/include/net/bluetooth/rfcomm.h
index 25aa575..98ec7a3 100644
--- a/include/net/bluetooth/rfcomm.h
+++ b/include/net/bluetooth/rfcomm.h
@@ -252,8 +252,8 @@ static inline void rfcomm_dlc_put(struct rfcomm_dlc *d)
 		rfcomm_dlc_free(d);
 }
 
-extern void FASTCALL(__rfcomm_dlc_throttle(struct rfcomm_dlc *d));
-extern void FASTCALL(__rfcomm_dlc_unthrottle(struct rfcomm_dlc *d));
+extern void __rfcomm_dlc_throttle(struct rfcomm_dlc *d);
+extern void __rfcomm_dlc_unthrottle(struct rfcomm_dlc *d);
 
 static inline void rfcomm_dlc_throttle(struct rfcomm_dlc *d)
 {
diff --git a/include/net/sock.h b/include/net/sock.h
index f415992..803d8f2 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -774,14 +774,14 @@ do {									\
 	lockdep_init_map(&(sk)->sk_lock.dep_map, (name), (key), 0);	\
 } while (0)
 
-extern void FASTCALL(lock_sock_nested(struct sock *sk, int subclass));
+extern void lock_sock_nested(struct sock *sk, int subclass);
 
 static inline void lock_sock(struct sock *sk)
 {
 	lock_sock_nested(sk, 0);
 }
 
-extern void FASTCALL(release_sock(struct sock *sk));
+extern void release_sock(struct sock *sk);
 
 /* BH context may only use the following locking interface. */
 #define bh_lock_sock(__sk)	spin_lock(&((__sk)->sk_lock.slock))
diff --git a/net/bluetooth/rfcomm/core.c b/net/bluetooth/rfcomm/core.c
index d3e4e18..0c2c937 100644
--- a/net/bluetooth/rfcomm/core.c
+++ b/net/bluetooth/rfcomm/core.c
@@ -465,7 +465,7 @@ int rfcomm_dlc_send(struct rfcomm_dlc *d, struct sk_buff *skb)
 	return len;
 }
 
-void fastcall __rfcomm_dlc_throttle(struct rfcomm_dlc *d)
+void __rfcomm_dlc_throttle(struct rfcomm_dlc *d)
 {
 	BT_DBG("dlc %p state %ld", d, d->state);
 
@@ -476,7 +476,7 @@ void fastcall __rfcomm_dlc_throttle(struct rfcomm_dlc *d)
 	rfcomm_schedule(RFCOMM_SCHED_TX);
 }
 
-void fastcall __rfcomm_dlc_unthrottle(struct rfcomm_dlc *d)
+void __rfcomm_dlc_unthrottle(struct rfcomm_dlc *d)
 {
 	BT_DBG("dlc %p state %ld", d, d->state);
 
diff --git a/net/core/dev.c b/net/core/dev.c
index 06615df..d48c9cf 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2143,7 +2143,7 @@ static int process_backlog(struct napi_struct *napi, int quota)
  *
  * The entry's receive function will be scheduled to run
  */
-void fastcall __napi_schedule(struct napi_struct *n)
+void __napi_schedule(struct napi_struct *n)
 {
 	unsigned long flags;
 
diff --git a/net/core/sock.c b/net/core/sock.c
index 1182140..2b30cc1 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1616,7 +1616,7 @@ void sock_init_data(struct socket *sock, struct sock *sk)
 	atomic_set(&sk->sk_drops, 0);
 }
 
-void fastcall lock_sock_nested(struct sock *sk, int subclass)
+void lock_sock_nested(struct sock *sk, int subclass)
 {
 	might_sleep();
 	spin_lock_bh(&sk->sk_lock.slock);
@@ -1633,7 +1633,7 @@ void fastcall lock_sock_nested(struct sock *sk, int subclass)
 
 EXPORT_SYMBOL(lock_sock_nested);
 
-void fastcall release_sock(struct sock *sk)
+void release_sock(struct sock *sk)
 {
 	/*
 	 * The sk_lock has mutex_unlock() semantics:
-- 
1.5.4.rc0.1083.gf568



