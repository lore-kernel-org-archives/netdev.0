From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH 1/3 v2][NET] gen_estimator: faster gen_kill_estimator
Date: Tue, 22 Jan 2008 08:21:52 +0100
Message-ID: <20080122072152.GA977@ff.dom.local>
References: <20080121.162918.148129860.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, slavon@bigtelecom.ru, kaber@trash.net,
	hadi@cyberus.ca
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hu-out-0506.google.com ([72.14.214.234]:3183 "EHLO
	hu-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751365AbYAVHPR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2008 02:15:17 -0500
Received: by hu-out-0506.google.com with SMTP id 19so940222hue.21
        for <netdev@vger.kernel.org>; Mon, 21 Jan 2008 23:15:16 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20080121.162918.148129860.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 22-01-2008 01:29, David Miller wrote:
...
> Fix this right, make a structure like:
> 
> struct kernel_gnet_stats_rate_est {
> 	struct gnet_stats_rate_est	est;
> 	void				*gen_estimator;
> }
> 
> And update all the code as needed.

Thanks! I'll try this...

...But, as a matter of fact I've thought about something similar (of
course much worse), and I was afraid of doing quite a lot of changes
at once, maybe again skip something like here. So, maybe one more
tiny RFC here...

I've tried this from the other side: to make alternative, new api of
gen_estimator functions, and then the rest of changes without hurry.
This looks not very nice, but IMHO should be safer (especially
considering my 'knowledge' of this code and current changes). There
is this not very nice additional parameter used e.g. in
ngen_new_estimator(), but it seems, after all changes, this should
be more visible how and where this could be optimized. (And, after
all, this new pointer shouldn't be used very often, so could sit a
bit further.)

Anyway, if you don't like this idea, let me know and I'll try yours.
It will only need more time for this.

This is done against 2.6.24-rc8-mm1 with this 3/3 cosmetic patch. 
I'll send soon part 2: htb patch to use this.

Regards,
Jarek P.

---

 include/net/gen_stats.h  |   11 +++++
 net/core/gen_estimator.c |   99 ++++++++++++++++++++++++++++++++++++++++++-----
 2 files changed, 101 insertions(+), 9 deletions(-)


diff -Nurp 2.6.24-rc8-mm1-p3-/include/net/gen_stats.h 2.6.24-rc8-mm1-p3+/include/net/gen_stats.h
--- 2.6.24-rc8-mm1-p3-/include/net/gen_stats.h	2007-10-09 22:31:38.000000000 +0200
+++ 2.6.24-rc8-mm1-p3+/include/net/gen_stats.h	2008-01-22 00:13:48.000000000 +0100
@@ -46,4 +46,15 @@ extern int gen_replace_estimator(struct 
 				 struct gnet_stats_rate_est *rate_est,
 				 spinlock_t *stats_lock, struct rtattr *opt);
 
+extern int ngen_new_estimator(struct gnet_stats_basic *bstats,
+			      struct gnet_stats_rate_est *rate_est,
+			      spinlock_t *stats_lock, struct rtattr *opt,
+			      unsigned long *pgen_estimator);
+extern void ngen_kill_estimator(unsigned long *pgen_estimator);
+
+extern int ngen_replace_estimator(struct gnet_stats_basic *bstats,
+				  struct gnet_stats_rate_est *rate_est,
+				  spinlock_t *stats_lock, struct rtattr *opt,
+				  unsigned long *pgen_estimator);
+
 #endif
diff -Nurp 2.6.24-rc8-mm1-p3-/net/core/gen_estimator.c 2.6.24-rc8-mm1-p3+/net/core/gen_estimator.c
--- 2.6.24-rc8-mm1-p3-/net/core/gen_estimator.c	2008-01-22 00:01:30.000000000 +0100
+++ 2.6.24-rc8-mm1-p3+/net/core/gen_estimator.c	2008-01-22 00:22:37.000000000 +0100
@@ -140,26 +140,30 @@ skip:
 }
 
 /**
- * gen_new_estimator - create a new rate estimator
+ * ngen_new_estimator - create a new rate estimator (new version)
  * @bstats: basic statistics
  * @rate_est: rate estimator statistics
  * @stats_lock: statistics lock
  * @opt: rate estimator configuration TLV
+ * @pgen_estimator: pointer to return ngen_new_estimator data
  *
  * Creates a new rate estimator with &bstats as source and &rate_est
  * as destination. A new timer with the interval specified in the
  * configuration TLV is created. Upon each interval, the latest statistics
  * will be read from &bstats and the estimated rate will be stored in
  * &rate_est with the statistics lock grabed during this period.
+ * Called directly for pgen_estimator and possibility of fast kill
+ * or indirectly by gen_new_estimator.
  *
- * Returns 0 on success or a negative error code.
+ * Returns 0 and data pointed by &pgen_estimator on success
+ * or a negative error code.
  *
  * NOTE: Called under rtnl_mutex
  */
-int gen_new_estimator(struct gnet_stats_basic *bstats,
-		      struct gnet_stats_rate_est *rate_est,
-		      spinlock_t *stats_lock,
-		      struct rtattr *opt)
+int ngen_new_estimator(struct gnet_stats_basic *bstats,
+		       struct gnet_stats_rate_est *rate_est,
+		       spinlock_t *stats_lock, struct rtattr *opt,
+		       unsigned long *pgen_estimator)
 {
 	struct gen_estimator *est;
 	struct gnet_estimator *parm = RTA_DATA(opt);
@@ -184,6 +188,7 @@ int gen_new_estimator(struct gnet_stats_
 	est->avbps = rate_est->bps<<5;
 	est->last_packets = bstats->packets;
 	est->avpps = rate_est->pps<<10;
+	*pgen_estimator = (unsigned long)est;
 
 	if (!elist[idx].timer.function) {
 		INIT_LIST_HEAD(&elist[idx].list);
@@ -197,6 +202,32 @@ int gen_new_estimator(struct gnet_stats_
 	return 0;
 }
 
+/**
+ * gen_new_estimator - create a new rate estimator 
+ * @bstats: basic statistics
+ * @rate_est: rate estimator statistics
+ * @stats_lock: statistics lock
+ * @opt: rate estimator configuration TLV
+ *
+ * Creates a new rate estimator with &bstats as source and &rate_est
+ * as destination. A new timer with the interval specified in the
+ * configuration TLV is created. Upon each interval, the latest statistics
+ * will be read from &bstats and the estimated rate will be stored in
+ * &rate_est with the statistics lock grabed during this period.
+ *
+ * Returns 0 on success or a negative error code.
+ *
+ * NOTE: Called under rtnl_mutex
+ */
+int gen_new_estimator(struct gnet_stats_basic *bstats,
+		       struct gnet_stats_rate_est *rate_est,
+		       spinlock_t *stats_lock, struct rtattr *opt)
+{
+	unsigned long dump;
+
+	return ngen_new_estimator(bstats, rate_est, stats_lock, opt, &dump);
+}
+
 static void __gen_kill_estimator(struct rcu_head *head)
 {
 	struct gen_estimator *e = container_of(head,
@@ -209,8 +240,7 @@ static void __gen_kill_estimator(struct 
  * @bstats: basic statistics
  * @rate_est: rate estimator statistics
  *
- * Removes the rate estimator specified by &bstats and &rate_est
- * and deletes the timer.
+ * Removes the rate estimator specified by &bstats and &rate_est.
  *
  * NOTE: Called under rtnl_mutex
  */
@@ -241,6 +271,32 @@ void gen_kill_estimator(struct gnet_stat
 }
 
 /**
+ * ngen_kill_estimator - remove a rate estimator (new version)
+ * @pgen_estimator: gen_estimator data got from ngen_new_estimator
+ *
+ * Removes the rate estimator specified by &pgen_estimator
+ * and replaces it with 0.
+ *
+ * NOTE: Called under rtnl_mutex
+ */
+void ngen_kill_estimator(unsigned long *pgen_estimator)
+{
+	if (pgen_estimator && *pgen_estimator) {
+		struct gen_estimator *e;
+		
+		e = (struct gen_estimator *)*pgen_estimator;
+		*pgen_estimator = 0;
+
+		write_lock_bh(&est_lock);
+		e->bstats = NULL;
+		write_unlock_bh(&est_lock);
+
+		list_del_rcu(&e->list);
+		call_rcu(&e->e_rcu, __gen_kill_estimator);
+	}
+}
+
+/**
  * gen_replace_estimator - replace rate estimator configuration
  * @bstats: basic statistics
  * @rate_est: rate estimator statistics
@@ -260,7 +316,32 @@ int gen_replace_estimator(struct gnet_st
 	return gen_new_estimator(bstats, rate_est, stats_lock, opt);
 }
 
+/**
+ * ngen_replace_estimator - replace rate estimator configuration (new version)
+ * @bstats: basic statistics
+ * @rate_est: rate estimator statistics
+ * @stats_lock: statistics lock
+ * @opt: rate estimator configuration TLV
+ * @pgen_estimator: gen_estimator data got from ngen_new_estimator
+ *
+ * Replaces the configuration of a rate estimator by calling
+ * ngen_kill_estimator and ngen_new_estimator.
+ *
+ * Returns 0 on success or a negative error code.
+ */
+int ngen_replace_estimator(struct gnet_stats_basic *bstats,
+			   struct gnet_stats_rate_est *rate_est,
+			   spinlock_t *stats_lock, struct rtattr *opt,
+		       	   unsigned long *pgen_estimator)
+{
+	ngen_kill_estimator(pgen_estimator);
+	return ngen_new_estimator(bstats, rate_est, stats_lock, opt,
+				  pgen_estimator);
+}
 
-EXPORT_SYMBOL(gen_kill_estimator);
 EXPORT_SYMBOL(gen_new_estimator);
+EXPORT_SYMBOL(gen_kill_estimator);
 EXPORT_SYMBOL(gen_replace_estimator);
+EXPORT_SYMBOL(ngen_new_estimator);
+EXPORT_SYMBOL(ngen_kill_estimator);
+EXPORT_SYMBOL(ngen_replace_estimator);
