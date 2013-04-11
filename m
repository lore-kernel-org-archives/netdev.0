From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH repost for-3.9] pci: avoid work_on_cpu for nested SRIOV
 probes
Date: Thu, 11 Apr 2013 13:41:04 -0700
Message-ID: <20130411204104.GC11956@mtj.dyndns.org>
References: <20130411153030.GA22743@redhat.com>
 <20130411180517.GJ17641@mtj.dyndns.org>
 <20130411185853.GE23301@redhat.com>
 <20130411190408.GM17641@mtj.dyndns.org>
 <20130411191717.GB25515@redhat.com>
 <20130411192005.GN17641@mtj.dyndns.org>
 <20130411203053.GC25515@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	Ming Lei <ming.lei@canonical.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	David Miller <davem@davemloft.net>,
	Roland Dreier <roland@kernel.org>,
	netdev <netdev@vger.kernel.org>, Yan Burman <yanb@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Bjorn Helgaas <bhelgaas@google.com>, linux-pci@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qe0-f54.google.com ([209.85.128.54]:61919 "EHLO
	mail-qe0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933891Ab3DKUlM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Apr 2013 16:41:12 -0400
Content-Disposition: inline
In-Reply-To: <20130411203053.GC25515@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Thu, Apr 11, 2013 at 11:30:53PM +0300, Michael S. Tsirkin wrote:
> Okay, so you are saying it's a false-positive?

Yeah, I think so.  It didn't actually lock up, right?  It it did,
our analysis upto this point is likely to be completely wrong.

> Want to send a patch so Or can try it out?

Hmmm... something like the following on the workqueue side (completely
untested).

diff --git a/include/linux/workqueue.h b/include/linux/workqueue.h
index 8afab27..899d470 100644
--- a/include/linux/workqueue.h
+++ b/include/linux/workqueue.h
@@ -466,14 +466,21 @@ static inline bool __deprecated flush_delayed_work_sync(struct delayed_work *dwo
 }
 
 #ifndef CONFIG_SMP
-static inline long work_on_cpu(unsigned int cpu, long (*fn)(void *), void *arg)
+static inline long work_on_cpu_nested(unsigned int cpu, long (*fn)(void *),
+				      void *arg, int subclass)
 {
 	return fn(arg);
 }
 #else
-long work_on_cpu(unsigned int cpu, long (*fn)(void *), void *arg);
+long work_on_cpu_nested(unsigned int cpu, long (*fn)(void *), void *arg,
+			int subclass);
 #endif /* CONFIG_SMP */
 
+static inline long work_on_cpu(unsigned int cpu, long (*fn)(void *), void *arg)
+{
+	return work_on_cpu_nested(cpu, fn, arg, 0);
+}
+
 #ifdef CONFIG_FREEZER
 extern void freeze_workqueues_begin(void);
 extern bool freeze_workqueues_busy(void);
diff --git a/kernel/workqueue.c b/kernel/workqueue.c
index 81f2457..c2be670 100644
--- a/kernel/workqueue.c
+++ b/kernel/workqueue.c
@@ -3555,25 +3555,30 @@ static void work_for_cpu_fn(struct work_struct *work)
 }
 
 /**
- * work_on_cpu - run a function in user context on a particular cpu
+ * work_on_cpu_nested - run a function in user context on a particular cpu
  * @cpu: the cpu to run on
  * @fn: the function to run
  * @arg: the function arg
+ * @subclass: lockdep subclass
  *
  * This will return the value @fn returns.
  * It is up to the caller to ensure that the cpu doesn't go offline.
  * The caller must not hold any locks which would prevent @fn from completing.
+ *
+ * XXX: explain @subclass
  */
-long work_on_cpu(unsigned int cpu, long (*fn)(void *), void *arg)
+long work_on_cpu_nested(unsigned int cpu, long (*fn)(void *), void *arg,
+			int subclass)
 {
 	struct work_for_cpu wfc = { .fn = fn, .arg = arg };
 
 	INIT_WORK_ONSTACK(&wfc.work, work_for_cpu_fn);
+	lock_set_subclass(&wfc.work.lockdep_map, subclass, _RET_IP_);
 	schedule_work_on(cpu, &wfc.work);
 	flush_work(&wfc.work);
 	return wfc.ret;
 }
-EXPORT_SYMBOL_GPL(work_on_cpu);
+EXPORT_SYMBOL_GPL(work_on_cpu_nested);
 #endif /* CONFIG_SMP */
 
 #ifdef CONFIG_FREEZER
