From: Jarek Poplawski <jarkao2@o2.pl>
Subject: [PATCH 1/2] RTNL and flush_scheduled_work deadlocks
Date: Mon, 19 Feb 2007 07:13:00 +0100
Message-ID: <20070219061300.GA1640@ff.dom.local>
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
Received: from mx10.go2.pl ([193.17.41.74]:37826 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932115AbXBSGJh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Feb 2007 01:09:37 -0500
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

Here is my patch proposal to enable such thing
(and to make ASSERT_RTNL simpler btw.).

Signed-off-by: Jarek Poplawski <jarkao2@o2.pl>

---

 include/linux/rtnetlink.h |   13 +++++++++++--
 net/core/rtnetlink.c      |   29 ++++++++++++++++++++++++++---
 2 files changed, 37 insertions(+), 5 deletions(-)


diff -Nurp linux-2.6.20-git13-/include/linux/rtnetlink.h linux-2.6.20-git13/include/linux/rtnetlink.h
--- linux-2.6.20-git13-/include/linux/rtnetlink.h	2007-02-04 19:44:54.000000000 +0100
+++ linux-2.6.20-git13/include/linux/rtnetlink.h	2007-02-18 22:56:36.000000000 +0100
@@ -704,16 +704,25 @@ extern int rtnl_trylock(void);
 
 extern void rtnetlink_init(void);
 extern void __rtnl_unlock(void);
+extern int rtnl_assert(void);
 
 #define ASSERT_RTNL() do { \
-	if (unlikely(rtnl_trylock())) { \
-		rtnl_unlock(); \
+	if (unlikely(!rtnl_assert())) { \
 		printk(KERN_ERR "RTNL: assertion failed at %s (%d)\n", \
 		       __FILE__,  __LINE__); \
 		dump_stack(); \
 	} \
 } while(0)
 
+/* Current process shouldn't hold RTNL lock: */
+#define ASSERT_NOT_RTNL() do { \
+	if (unlikely(rtnl_assert())) { \
+		printk(KERN_ERR "NOT_RTNL: assertion failed at %s (%d)\n", \
+		       __FILE__,  __LINE__); \
+		dump_stack(); \
+	} \
+} while(0)
+
 #define BUG_TRAP(x) do { \
 	if (unlikely(!(x))) { \
 		printk(KERN_ERR "KERNEL: assertion (%s) failed at %s (%d)\n", \
diff -Nurp linux-2.6.20-git13-/net/core/rtnetlink.c linux-2.6.20-git13/net/core/rtnetlink.c
--- linux-2.6.20-git13-/net/core/rtnetlink.c	2007-02-15 20:07:11.000000000 +0100
+++ linux-2.6.20-git13/net/core/rtnetlink.c	2007-02-18 22:50:13.000000000 +0100
@@ -57,20 +57,33 @@
 #endif	/* CONFIG_NET_WIRELESS_RTNETLINK */
 
 static DEFINE_MUTEX(rtnl_mutex);
+static struct thread_info *rtnl_owner;
 static struct sock *rtnl;
 
 void rtnl_lock(void)
 {
+#if !defined(CONFIG_DEBUG_MUTEXES) && !defined(CONFIG_DEBUG_SPINLOCK)
+	WARN_ON(rtnl_owner == current_thread_info());
+#endif
 	mutex_lock(&rtnl_mutex);
+	rtnl_owner = current_thread_info();
 }
 
 void __rtnl_unlock(void)
 {
+#if !defined(CONFIG_DEBUG_MUTEXES) && !defined(CONFIG_DEBUG_SPINLOCK)
+	WARN_ON(rtnl_owner != current_thread_info());
+#endif
+	rtnl_owner = NULL;
 	mutex_unlock(&rtnl_mutex);
 }
 
 void rtnl_unlock(void)
 {
+#if !defined(CONFIG_DEBUG_MUTEXES) && !defined(CONFIG_DEBUG_SPINLOCK)
+	WARN_ON(rtnl_owner != current_thread_info());
+#endif
+	rtnl_owner = NULL;
 	mutex_unlock(&rtnl_mutex);
 	if (rtnl && rtnl->sk_receive_queue.qlen)
 		rtnl->sk_data_ready(rtnl, 0);
@@ -79,7 +92,16 @@ void rtnl_unlock(void)
 
 int rtnl_trylock(void)
 {
-	return mutex_trylock(&rtnl_mutex);
+	int ret;
+	
+	if ((ret = mutex_trylock(&rtnl_mutex)))
+		rtnl_owner = current_thread_info();
+	return ret;
+}
+
+int rtnl_assert(void)
+{
+	return (rtnl_owner == current_thread_info());
 }
 
 int rtattr_parse(struct rtattr *tb[], int maxattr, struct rtattr *rta, int len)
@@ -805,9 +827,9 @@ static void rtnetlink_rcv(struct sock *s
 	unsigned int qlen = 0;
 
 	do {
-		mutex_lock(&rtnl_mutex);
+		rtnl_lock();
 		netlink_run_queue(sk, &qlen, &rtnetlink_rcv_msg);
-		mutex_unlock(&rtnl_mutex);
+		__rtnl_unlock();
 
 		netdev_run_todo();
 	} while (qlen);
@@ -893,3 +915,4 @@ EXPORT_SYMBOL(rtnl_unlock);
 EXPORT_SYMBOL(rtnl_unicast);
 EXPORT_SYMBOL(rtnl_notify);
 EXPORT_SYMBOL(rtnl_set_sk_err);
+EXPORT_SYMBOL(rtnl_assert);
