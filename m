From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH] rtnl: Simplify ASSERT_RTNL
Date: Fri, 28 Sep 2007 18:59:08 -0600
Message-ID: <m1r6ki9tib.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:54015 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756239AbXI2A7U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Sep 2007 20:59:20 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Currently we have the call path:
macvlan_open -> dev_unicast_add -> __dev_set_rx_mode ->
	__dev_set_promiscuity -> ASSERT_RTNL -> mutex_trylock

When mutex debugging is on taking a mutex complains if we are not
allowed to sleep.  At that point we have called netif_tx_lock_bh
so we are clearly not allowed to sleep.  Arguably this is not a
problem for mutex_trylock.

However we can avoid the complaint and make the ASSERT_RTNL code
cheaper, faster and more obvious by simply calling mutex_is_locked.

So this patch adds rtnl_is_locked (which does mutex_is_locked on
the rtnl_mutex) and changes ASSERT_RTNL to use that.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 include/linux/rtnetlink.h |    4 ++--
 net/core/rtnetlink.c      |    5 +++++
 2 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index dff3192..9c21e45 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -714,13 +714,13 @@ extern void rtmsg_ifinfo(int type, struct net_device *dev, unsigned change);
 extern void rtnl_lock(void);
 extern void rtnl_unlock(void);
 extern int rtnl_trylock(void);
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
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 739fbad..8bc68e6 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -85,6 +85,11 @@ int rtnl_trylock(void)
 	return mutex_trylock(&rtnl_mutex);
 }
 
+int rtnl_is_locked(void)
+{
+	return mutex_is_locked(&rtnl_mutex);
+}
+
 int rtattr_parse(struct rtattr *tb[], int maxattr, struct rtattr *rta, int len)
 {
 	memset(tb, 0, sizeof(struct rtattr*)*maxattr);
-- 
1.5.3.rc6.17.g1911

