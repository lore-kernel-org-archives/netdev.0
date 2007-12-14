From: akpm@linux-foundation.org
Subject: [patch 2/4] net: use mutex_is_locked() for ASSERT_RTNL()
Date: Thu, 13 Dec 2007 16:02:36 -0800
Message-ID: <200712140002.lBE02aGO025491@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:50332 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1762278AbXLNACi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2007 19:02:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>

ASSERT_RTNL() uses mutex_trylock(), but it's better to use mutex_is_locked().

Make that change, and remove rtnl_trylock() altogether.

(not tested yet!)

Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/cxgb3/cxgb3_main.c |    3 +--
 include/linux/rtnetlink.h      |    5 ++---
 net/core/rtnetlink.c           |    7 ++++---
 3 files changed, 7 insertions(+), 8 deletions(-)

diff -puN drivers/net/cxgb3/cxgb3_main.c~net-use-mutex_is_locked-for-assert_rtnl drivers/net/cxgb3/cxgb3_main.c
--- a/drivers/net/cxgb3/cxgb3_main.c~net-use-mutex_is_locked-for-assert_rtnl
+++ a/drivers/net/cxgb3/cxgb3_main.c
@@ -2191,7 +2191,7 @@ static void check_t3b2_mac(struct adapte
 {
 	int i;
 
-	if (!rtnl_trylock())	/* synchronize with ifdown */
+	if (rtnl_is_locked())	/* synchronize with ifdown */
 		return;
 
 	for_each_port(adapter, i) {
@@ -2219,7 +2219,6 @@ static void check_t3b2_mac(struct adapte
 			p->mac.stats.num_resets++;
 		}
 	}
-	rtnl_unlock();
 }
 
 
diff -puN include/linux/rtnetlink.h~net-use-mutex_is_locked-for-assert_rtnl include/linux/rtnetlink.h
--- a/include/linux/rtnetlink.h~net-use-mutex_is_locked-for-assert_rtnl
+++ a/include/linux/rtnetlink.h
@@ -751,14 +751,13 @@ extern void rtmsg_ifinfo(int type, struc
 /* RTNL is used as a global lock for all changes to network configuration  */
 extern void rtnl_lock(void);
 extern void rtnl_unlock(void);
-extern int rtnl_trylock(void);
+extern int rtnl_is_locked(void);
 
 extern void rtnetlink_init(void);
 extern void __rtnl_unlock(void);
 
 #define ASSERT_RTNL() do { \
-	if (unlikely(rtnl_trylock())) { \
-		rtnl_unlock(); \
+	if (unlikely(!rtnl_is_locked())) { \
 		printk(KERN_ERR "RTNL: assertion failed at %s (%d)\n", \
 		       __FILE__,  __LINE__); \
 		dump_stack(); \
diff -puN net/core/rtnetlink.c~net-use-mutex_is_locked-for-assert_rtnl net/core/rtnetlink.c
--- a/net/core/rtnetlink.c~net-use-mutex_is_locked-for-assert_rtnl
+++ a/net/core/rtnetlink.c
@@ -77,9 +77,10 @@ void rtnl_unlock(void)
 	netdev_run_todo();
 }
 
-int rtnl_trylock(void)
+/* Return non-zero if rtnl_mutex is presently held */
+int rtnl_is_locked(void)
 {
-	return mutex_trylock(&rtnl_mutex);
+	return mutex_is_locked(&rtnl_mutex);
 }
 
 int rtattr_parse(struct rtattr *tb[], int maxattr, struct rtattr *rta, int len)
@@ -1424,7 +1425,7 @@ EXPORT_SYMBOL(rtattr_parse);
 EXPORT_SYMBOL(__rtattr_parse_nested_compat);
 EXPORT_SYMBOL(rtnetlink_put_metrics);
 EXPORT_SYMBOL(rtnl_lock);
-EXPORT_SYMBOL(rtnl_trylock);
+EXPORT_SYMBOL(rtnl_is_locked);
 EXPORT_SYMBOL(rtnl_unlock);
 EXPORT_SYMBOL(rtnl_unicast);
 EXPORT_SYMBOL(rtnl_notify);
_
