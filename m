From: Jarek Poplawski <jarkao2@o2.pl>
Subject: [PATCH 2/2] RTNL and flush_scheduled_work deadlocks
Date: Mon, 19 Feb 2007 07:55:48 +0100
Message-ID: <20070219065548.GA1686@ff.dom.local>
References: <20070216072928.GA1599@ff.dom.local> <45D55FF0.8090309@candelatech.com> <20070216103115.517f1a4c@freekitty> <45D60022.9060701@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org,
	Kyle Lucke <klucke@us.ibm.com>,
	Raghavendra Koushik <raghavendra.koushik@neterion.com>,
	Al Viro <viro@ftp.linux.org.uk>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from poczta.o2.pl ([193.17.41.142]:38838 "EHLO poczta.o2.pl"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S932184AbXBSGw1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Feb 2007 01:52:27 -0500
Content-Disposition: inline
In-Reply-To: <45D60022.9060701@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 16, 2007 at 11:04:02AM -0800, Ben Greear wrote:
> Stephen Hemminger wrote:
> >On Thu, 15 Feb 2007 23:40:32 -0800
> >Ben Greear <greearb@candelatech.com> wrote:
> 
> >>Maybe there should be something like an ASSERT_NOT_RTNL() in the 
> >>flush_scheduled_work()
> >>method?  If it's performance criticial, #ifdef it out if we're not 
> >>debugging locks?
> >>
> >
> >You can't safely add a check like that. What if another cpu had acquired
> >RTNL and was unrelated.
> 
> I guess there isn't a way to see if *this* thread is the owner of the RTNL
> currently?  I think lockdep knows the owner...maybe could query it somehow,
> or just save the owner in the mutex object when debugging is enabled...


And here is my patch proposal to fix the whole problem
other way: by enabling all those flushes with RTNL.

The main idea is the function calling flush has RTNL
lock but, while flushing, it doesn't use this for
anything else. So it can "lend" this lock to work
functions being flushed. If work function needs RTNL
lock and it is running under a flush, it can do like
it had this lock because a function with a real RTNL
lock doesn't do anything except waiting for a flush
end. And if there is no flush, this work function
simply can use the real RTNL lock. (And of course these
work functions can't call a flush directly or
indirectly themselves!)

So to use this we only need such changes:

 ... some_delayed_work_func(...)
 {
	...
-	rtnl_lock();
+	rtnl_lock_work();
	...
-	rtnl_unlock();
+	rtnl_unlock_work();
 }

 ... some_delayed_work_func(...)
 {
	...
+	rtnl_set_flush();
	flush_scheduled_work;
	/* or cancel_rearming_delayed_work(...); etc. */
+	rtnl_unset_flush();
 }

(Or there could be added some wrappers like:
rtnl_flush_scheduled_work etc. with these rtnl_set/unset
included.)

PS: destroy_workqueue() is one of dangerous too.

This patch should be applied after my earlier:
PATCH 1/2. (But if this idea is wrong, PATCH 1/2
could be used independently.)

Signed-off-by: Jarek Poplawski <jarkao2@o2.pl>

---

 include/linux/rtnetlink.h |   15 ++++++++++
 net/core/rtnetlink.c      |   65 ++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 80 insertions(+)


diff -Nurp linux-2.6.20-git13-rtnl1-/include/linux/rtnetlink.h linux-2.6.20-git13-rtnl1/include/linux/rtnetlink.h
--- linux-2.6.20-git13-rtnl1-/include/linux/rtnetlink.h	2007-02-18 23:05:26.000000000 +0100
+++ linux-2.6.20-git13-rtnl1/include/linux/rtnetlink.h	2007-02-18 23:25:28.000000000 +0100
@@ -706,6 +706,21 @@ extern void rtnetlink_init(void);
 extern void __rtnl_unlock(void);
 extern int rtnl_assert(void);
 
+/* 
+ * To use in work and delayed_work functions instead of rtnl_lock etc.
+ * (rtnl_unlock_work should be used instead of __rtnl_unlock and rtnl_unlock;
+ * rtnl_assert, ASSERT_RTNL and ASSERT_NOT_RTNL need no changes):
+ */
+extern void rtnl_lock_work(void);
+extern void rtnl_unlock_work(void);
+extern int rtnl_trylock_work(void);
+/*
+ * To use by functions holding RTNL lock - just before and after calling
+ * flush_scheduled_work or other functions with workqueue flushing:
+ */
+extern void rtnl_set_flush(void);
+extern void rtnl_unset_flush(void);
+
 #define ASSERT_RTNL() do { \
 	if (unlikely(!rtnl_assert())) { \
 		printk(KERN_ERR "RTNL: assertion failed at %s (%d)\n", \
diff -Nurp linux-2.6.20-git13-rtnl1-/net/core/rtnetlink.c linux-2.6.20-git13-rtnl1/net/core/rtnetlink.c
--- linux-2.6.20-git13-rtnl1-/net/core/rtnetlink.c	2007-02-18 22:50:13.000000000 +0100
+++ linux-2.6.20-git13-rtnl1/net/core/rtnetlink.c	2007-02-18 22:49:16.000000000 +0100
@@ -58,6 +58,11 @@
 
 static DEFINE_MUTEX(rtnl_mutex);
 static struct thread_info *rtnl_owner;
+/* rtnl_mutex proxy while flushing workqueue: */
+static DEFINE_MUTEX(rtnl_mutex_work);
+/* set/unset under rtnl_mutex by flush caller: */
+static struct thread_info *rtnl_flush_owner;
+
 static struct sock *rtnl;
 
 void rtnl_lock(void)
@@ -104,6 +109,61 @@ int rtnl_assert(void)
 	return (rtnl_owner == current_thread_info());
 }
 
+void rtnl_lock_work(void)
+{
+#if !defined(CONFIG_DEBUG_MUTEXES) && !defined(CONFIG_DEBUG_SPINLOCK)
+	WARN_ON(rtnl_owner == current_thread_info());
+#endif
+	mutex_lock(&rtnl_mutex_work);
+	if (!rtnl_flush_owner)
+		mutex_lock(&rtnl_mutex);
+
+	rtnl_owner = current_thread_info();
+}
+
+void rtnl_unlock_work(void)
+{
+#if !defined(CONFIG_DEBUG_MUTEXES) && !defined(CONFIG_DEBUG_SPINLOCK)
+	WARN_ON(rtnl_owner != current_thread_info());
+#endif
+	rtnl_owner = rtnl_flush_owner;
+	if (!rtnl_flush_owner)
+		mutex_unlock(&rtnl_mutex);
+
+	mutex_unlock(&rtnl_mutex_work);
+}
+
+int rtnl_trylock_work(void)
+{
+	int ret;
+
+	if ((ret = mutex_trylock(&rtnl_mutex_work)))
+		if (!rtnl_flush_owner)
+			ret = mutex_trylock(&rtnl_mutex);
+
+	if (ret)
+		rtnl_owner = current_thread_info();
+
+	return ret;
+}
+
+void rtnl_set_flush(void)
+{
+#if !defined(CONFIG_DEBUG_MUTEXES) && !defined(CONFIG_DEBUG_SPINLOCK)
+	WARN_ON(rtnl_owner != current_thread_info() || rtnl_flush_owner);
+#endif
+	rtnl_flush_owner = current_thread_info();
+}
+
+void rtnl_unset_flush(void)
+{
+#if !defined(CONFIG_DEBUG_MUTEXES) && !defined(CONFIG_DEBUG_SPINLOCK)
+	WARN_ON(rtnl_owner != current_thread_info() ||
+		rtnl_owner != rtnl_flush_owner);
+#endif
+	rtnl_flush_owner = NULL;
+}
+
 int rtattr_parse(struct rtattr *tb[], int maxattr, struct rtattr *rta, int len)
 {
 	memset(tb, 0, sizeof(struct rtattr*)*maxattr);
@@ -916,3 +976,8 @@ EXPORT_SYMBOL(rtnl_unicast);
 EXPORT_SYMBOL(rtnl_notify);
 EXPORT_SYMBOL(rtnl_set_sk_err);
 EXPORT_SYMBOL(rtnl_assert);
+EXPORT_SYMBOL(rtnl_lock_work);
+EXPORT_SYMBOL(rtnl_trylock_work);
+EXPORT_SYMBOL(rtnl_unlock_work);
+EXPORT_SYMBOL(rtnl_set_flush);
+EXPORT_SYMBOL(rtnl_unset_flush);
