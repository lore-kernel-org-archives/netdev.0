From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] rtnetlink: call rtnl_lock_unregistering() in rtnl_link_unregister()
Date: Fri,  9 May 2014 10:47:33 -0700
Message-ID: <1399657653-4909-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Cong Wang <cwang@twopensource.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:43761 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754465AbaEIRrj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2014 13:47:39 -0400
Received: by mail-pa0-f44.google.com with SMTP id ld10so4631003pab.17
        for <netdev@vger.kernel.org>; Fri, 09 May 2014 10:47:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <cwang@twopensource.com>

commit 50624c934db18ab90 (net: Delay default_device_exit_batch until no
devices are unregistering) introduced rtnl_lock_unregistering() for
default_device_exit_batch(). Same race could happen we when rmmod a driver
which calls rtnl_link_unregister() as we call dev->destructor without rtnl
lock.

I know making rtnl_lock_unregistering() a macro is ugly, but I don't find
any less ugly way to fix it unless we duplicate the code. For long term,
I think we should clean up the mess of netdev_run_todo() and net namespce
exit code.

Cc: Eric W. Biederman <ebiederm@xmission.com>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
Signed-off-by: Cong Wang <cwang@twopensource.com>
---
 include/linux/rtnetlink.h | 31 +++++++++++++++++++++++++++++++
 net/core/dev.c            | 32 ++------------------------------
 net/core/rtnetlink.c      |  2 +-
 3 files changed, 34 insertions(+), 31 deletions(-)

diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
index 8e3e66a..e70218d 100644
--- a/include/linux/rtnetlink.h
+++ b/include/linux/rtnetlink.h
@@ -4,6 +4,7 @@
 
 #include <linux/mutex.h>
 #include <linux/netdevice.h>
+#include <linux/wait.h>
 #include <uapi/linux/rtnetlink.h>
 
 extern int rtnetlink_send(struct sk_buff *skb, struct net *net, u32 pid, u32 group, int echo);
@@ -22,6 +23,36 @@ extern void rtnl_lock(void);
 extern void rtnl_unlock(void);
 extern int rtnl_trylock(void);
 extern int rtnl_is_locked(void);
+
+extern wait_queue_head_t netdev_unregistering_wq;
+/* Return with the rtnl_lock held when there are no network
+ * devices unregistering in any network namespace in net_list.
+ */
+#define rtnl_lock_unregistering(net_list, member)			\
+do {									\
+	struct net *net;						\
+	bool unregistering;						\
+	DEFINE_WAIT(wait);						\
+									\
+	for (;;) {							\
+		prepare_to_wait(&netdev_unregistering_wq, &wait,	\
+				TASK_UNINTERRUPTIBLE);			\
+		unregistering = false;					\
+		rtnl_lock();						\
+		list_for_each_entry(net, net_list, member) {		\
+			if (net->dev_unreg_count > 0) {			\
+				unregistering = true;			\
+				break;					\
+			}						\
+		}							\
+		if (!unregistering)					\
+			break;						\
+		__rtnl_unlock();					\
+		schedule();						\
+	}								\
+	finish_wait(&netdev_unregistering_wq, &wait);			\
+} while (0)
+
 #ifdef CONFIG_PROVE_LOCKING
 extern int lockdep_rtnl_is_held(void);
 #else
diff --git a/net/core/dev.c b/net/core/dev.c
index c619b86..25f7ed2 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5541,7 +5541,7 @@ static int dev_new_index(struct net *net)
 
 /* Delayed registration/unregisteration */
 static LIST_HEAD(net_todo_list);
-static DECLARE_WAIT_QUEUE_HEAD(netdev_unregistering_wq);
+DECLARE_WAIT_QUEUE_HEAD(netdev_unregistering_wq);
 
 static void net_set_todo(struct net_device *dev)
 {
@@ -6926,34 +6926,6 @@ static void __net_exit default_device_exit(struct net *net)
 	rtnl_unlock();
 }
 
-static void __net_exit rtnl_lock_unregistering(struct list_head *net_list)
-{
-	/* Return with the rtnl_lock held when there are no network
-	 * devices unregistering in any network namespace in net_list.
-	 */
-	struct net *net;
-	bool unregistering;
-	DEFINE_WAIT(wait);
-
-	for (;;) {
-		prepare_to_wait(&netdev_unregistering_wq, &wait,
-				TASK_UNINTERRUPTIBLE);
-		unregistering = false;
-		rtnl_lock();
-		list_for_each_entry(net, net_list, exit_list) {
-			if (net->dev_unreg_count > 0) {
-				unregistering = true;
-				break;
-			}
-		}
-		if (!unregistering)
-			break;
-		__rtnl_unlock();
-		schedule();
-	}
-	finish_wait(&netdev_unregistering_wq, &wait);
-}
-
 static void __net_exit default_device_exit_batch(struct list_head *net_list)
 {
 	/* At exit all network devices most be removed from a network
@@ -6976,7 +6948,7 @@ static void __net_exit default_device_exit_batch(struct list_head *net_list)
 	 * will run in the rtnl_unlock() at the end of
 	 * default_device_exit_batch.
 	 */
-	rtnl_lock_unregistering(net_list);
+	rtnl_lock_unregistering(net_list, exit_list);
 	list_for_each_entry(net, net_list, exit_list) {
 		for_each_netdev_reverse(net, dev) {
 			if (dev->rtnl_link_ops)
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 9837beb..fd33a83 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -359,7 +359,7 @@ EXPORT_SYMBOL_GPL(__rtnl_link_unregister);
  */
 void rtnl_link_unregister(struct rtnl_link_ops *ops)
 {
-	rtnl_lock();
+	rtnl_lock_unregistering(&net_namespace_list, list);
 	__rtnl_link_unregister(ops);
 	rtnl_unlock();
 }
-- 
1.8.3.1
