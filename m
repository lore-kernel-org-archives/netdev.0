From: Jarek Poplawski <jarkao2@o2.pl>
Subject: [PATCH v.2] RTNL and flush_scheduled_work deadlocks
Date: Mon, 5 Mar 2007 09:36:11 +0100
Message-ID: <20070305083611.GA2124@ff.dom.local>
References: <20070216072928.GA1599@ff.dom.local> <45D55FF0.8090309@candelatech.com> <20070216103115.517f1a4c@freekitty> <45D60022.9060701@candelatech.com> <20070219061300.GA1640@ff.dom.local> <45D94347.8060405@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org,
	Kyle Lucke <klucke@us.ibm.com>,
	Raghavendra Koushik <raghavendra.koushik@neterion.com>,
	Al Viro <viro@ftp.linux.org.uk>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:38654 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932406AbXCEIcR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Mar 2007 03:32:17 -0500
Content-Disposition: inline
In-Reply-To: <45D94347.8060405@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Feb 18, 2007 at 10:27:19PM -0800, Ben Greear wrote:
> Jarek Poplawski wrote:
> >On Fri, Feb 16, 2007 at 11:04:02AM -0800, Ben Greear wrote:
...
> >>>On Thu, 15 Feb 2007 23:40:32 -0800
> >>>Ben Greear <greearb@candelatech.com> wrote:
> >>>      
> >>>>Maybe there should be something like an ASSERT_NOT_RTNL() in the 
> >>>>flush_scheduled_work()
> >>>>method?  If it's performance criticial, #ifdef it out if we're not 
> >>>>debugging locks?
...
> For performance reasons, I'd leave the rtnl_owner inside the
> #if debugging locking code....
> 
> You are also changing the semantics of ASSERT_RTNL (assert *this thread* 
> has rtnl, from the
> old behaviour:  assert *some thread* has rtnl).  It may be better this
> way, but it could break code that assumes the old behaviour.
> 
> Ben

Hi,

I'm not sure anybody is interested yet, but I think it's
a good idea so here is a reworked proposal. 

Jarek P.
===

[NET] DEBUG_ASSERT_RTNL and DEBUG_ASSERT_NOT_RTNL macros

Debug RTNL macros usable with CONFIG_DEBUG_MUTEXES on.
Based on suggestions of Ben Greear (to help debugging
flush_schedule_work).

Signed-off-by: Jarek Poplawski <jarkao2@o2.pl>
Cc: Ben Greear <greearb@candelatech.com>

---

 include/linux/rtnetlink.h |   27 +++++++++++++++++++++++++++
 net/core/rtnetlink.c      |   10 ++++++++++
 2 files changed, 37 insertions(+)


diff -Nurp linux-2.6.21-rc2-git2-/include/linux/rtnetlink.h linux-2.6.21-rc2-git2/include/linux/rtnetlink.h
--- linux-2.6.21-rc2-git2-/include/linux/rtnetlink.h	2007-02-04 19:44:54.000000000 +0100
+++ linux-2.6.21-rc2-git2/include/linux/rtnetlink.h	2007-03-04 14:47:00.000000000 +0100
@@ -728,6 +728,33 @@ rtattr_failure:
 	return table;
 }
 
+#ifdef CONFIG_DEBUG_MUTEXES
+extern int debug_rtnl_assert(void);
+
+#define DEBUG_ASSERT_RTNL() do { \
+	if (unlikely(!debug_rtnl_assert())) { \
+		printk(KERN_ERR "DEBUG RTNL:" \
+		       " assertion failed at %s (%d)\n", \
+		       __FILE__,  __LINE__); \
+		dump_stack(); \
+	} \
+} while(0)
+
+#define DEBUG_ASSERT_NOT_RTNL() do { \
+	if (unlikely(debug_rtnl_assert())) { \
+		printk(KERN_ERR "DEBUG NOT RTNL:" \
+		       " assertion failed at %s (%d)\n", \
+		       __FILE__,  __LINE__); \
+		dump_stack(); \
+	} \
+} while(0)
+
+#else
+/* debug_rtnl_assert() invalid here */
+#define DEBUG_ASSERT_RTNL()
+#define DEBUG_ASSERT_NOT_RTNL()
+#endif /* CONFIG_DEBUG_MUTEXES */
+
 #endif /* __KERNEL__ */
 
 
diff -Nurp linux-2.6.21-rc2-git2-/net/core/rtnetlink.c linux-2.6.21-rc2-git2/net/core/rtnetlink.c
--- linux-2.6.21-rc2-git2-/net/core/rtnetlink.c	2007-02-21 19:46:47.000000000 +0100
+++ linux-2.6.21-rc2-git2/net/core/rtnetlink.c	2007-03-04 15:23:34.000000000 +0100
@@ -82,6 +82,13 @@ int rtnl_trylock(void)
 	return mutex_trylock(&rtnl_mutex);
 }
 
+#ifdef CONFIG_DEBUG_MUTEXES
+int debug_rtnl_assert(void)
+{
+	return (rtnl_mutex.owner == current_thread_info());
+}
+#endif
+
 int rtattr_parse(struct rtattr *tb[], int maxattr, struct rtattr *rta, int len)
 {
 	memset(tb, 0, sizeof(struct rtattr*)*maxattr);
@@ -893,3 +900,6 @@ EXPORT_SYMBOL(rtnl_unlock);
 EXPORT_SYMBOL(rtnl_unicast);
 EXPORT_SYMBOL(rtnl_notify);
 EXPORT_SYMBOL(rtnl_set_sk_err);
+#ifdef CONFIG_DEBUG_MUTEXES
+EXPORT_SYMBOL(debug_rtnl_assert);
+#endif
