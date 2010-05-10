From: Patrick McHardy <kaber@trash.net>
Subject: Re: mmotm 2010-04-28 - RCU whinges
Date: Mon, 10 May 2010 18:53:48 +0200
Message-ID: <4BE83A1C.5000508@trash.net>
References: <201004290021.o3T0L04Y028017@imap1.linux-foundation.org>	 <5702.1272822394@localhost> <1272865137.2173.179.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010005020008040209080803"
Cc: Valdis.Kletnieks@vt.edu, Andrew Morton <akpm@linux-foundation.org>,
	Peter Zijlstra <peterz@infradead.org>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1272865137.2173.179.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010005020008040209080803
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 8bit

Eric Dumazet wrote:
> Le dimanche 02 mai 2010 à 13:46 -0400, Valdis.Kletnieks@vt.edu a écrit :
>> On Wed, 28 Apr 2010 16:53:32 PDT, akpm@linux-foundation.org said:
>>> The mm-of-the-moment snapshot 2010-04-28-16-53 has been uploaded to
>>>
>>>    http://userweb.kernel.org/~akpm/mmotm/
>> I thought we swatted all these, hit another one...
>>
>> [    9.131490] ctnetlink v0.93: registering with nfnetlink.
>> [    9.131535]
>> [    9.131535] ===================================================
>> [    9.131704] [ INFO: suspicious rcu_dereference_check() usage. ]
>> [    9.131794] ---------------------------------------------------
>> [    9.131883] net/netfilter/nf_conntrack_ecache.c:88 invoked rcu_dereference_check() without protection!
>> [    9.131977]
>> [    9.131977] other info that might help us debug this:
>> [    9.131978]
>> [    9.132218]
>> [    9.132219] rcu_scheduler_active = 1, debug_locks = 0
>> [    9.132434] 1 lock held by swapper/1:
>> [    9.132519]  #0:  (nf_ct_ecache_mutex){+.+...}, at: [<ffffffff8148922d>] nf_conntrack_register_notifier+0x1a/0x75
>> [    9.132938]
>> [    9.132939] stack backtrace:
>> [    9.133129] Pid: 1, comm: swapper Tainted: G        W   2.6.34-rc5-mmotm0428 #1
>> [    9.133220] Call Trace:
>> [    9.133319]  [<ffffffff81064832>] lockdep_rcu_dereference+0xaa/0xb2
>> [    9.133410]  [<ffffffff81489250>] nf_conntrack_register_notifier+0x3d/0x75
>> [    9.133521]  [<ffffffff81b5a157>] ctnetlink_init+0x71/0xd5
>> [    9.133627]  [<ffffffff81b5a0e6>] ? ctnetlink_init+0x0/0xd5
>> [    9.133735]  [<ffffffff810001ef>] do_one_initcall+0x59/0x14e
>> [    9.133843]  [<ffffffff81b2e68a>] kernel_init+0x144/0x1ce
>> [    9.133949]  [<ffffffff81003414>] kernel_thread_helper+0x4/0x10
>> [    9.134060]  [<ffffffff81598a40>] ? restore_args+0x0/0x30
>> [    9.134196]  [<ffffffff81b2e546>] ? kernel_init+0x0/0x1ce
>> [    9.134328]  [<ffffffff81003410>] ? kernel_thread_helper+0x0/0x10
>> [    9.134530] ip_tables: (C) 2000-2006 Netfilter Core Team
>> [    9.134655] TCP bic registered
>>
> 
> Thanks for the report !
> 
> We can use rcu_dereference_protected() in those cases.
> 
> [PATCH] net: Use rcu_dereference_protected in nf_conntrack_ecache
> 
> Writers own nf_ct_ecache_mutex.

I've committed this patch to my tree, which also fixes up the nf_log
changes I already had queued.

I've also figured out how to prevent the false commits from showing
up using the '^' notation, I'll submit everything after some final
testing.



--------------010005020008040209080803
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

commit b56f2d55c6c22b0c5774b3b22e336fb6cc5f4094
Author: Patrick McHardy <kaber@trash.net>
Date:   Mon May 10 18:47:57 2010 +0200

    netfilter: use rcu_dereference_protected()
    
    Restore the rcu_dereference() calls in conntrack/expectation notifier
    and logger registration/unregistration, but use the _protected variant,
    which will be required by the upcoming __rcu annotations.
    
    Based on patch by Eric Dumazet <eric.dumazet@gmail.com>
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/nf_conntrack_ecache.c b/net/netfilter/nf_conntrack_ecache.c
index a94ac3a..cdcc764 100644
--- a/net/netfilter/nf_conntrack_ecache.c
+++ b/net/netfilter/nf_conntrack_ecache.c
@@ -82,9 +82,12 @@ EXPORT_SYMBOL_GPL(nf_ct_deliver_cached_events);
 int nf_conntrack_register_notifier(struct nf_ct_event_notifier *new)
 {
 	int ret = 0;
+	struct nf_ct_event_notifier *notify;
 
 	mutex_lock(&nf_ct_ecache_mutex);
-	if (nf_conntrack_event_cb != NULL) {
+	notify = rcu_dereference_protected(nf_conntrack_event_cb,
+					   lockdep_is_held(&nf_ct_ecache_mutex));
+	if (notify != NULL) {
 		ret = -EBUSY;
 		goto out_unlock;
 	}
@@ -100,8 +103,12 @@ EXPORT_SYMBOL_GPL(nf_conntrack_register_notifier);
 
 void nf_conntrack_unregister_notifier(struct nf_ct_event_notifier *new)
 {
+	struct nf_ct_event_notifier *notify;
+
 	mutex_lock(&nf_ct_ecache_mutex);
-	BUG_ON(nf_conntrack_event_cb != new);
+	notify = rcu_dereference_protected(nf_conntrack_event_cb,
+					   lockdep_is_held(&nf_ct_ecache_mutex));
+	BUG_ON(notify != new);
 	rcu_assign_pointer(nf_conntrack_event_cb, NULL);
 	mutex_unlock(&nf_ct_ecache_mutex);
 }
@@ -110,9 +117,12 @@ EXPORT_SYMBOL_GPL(nf_conntrack_unregister_notifier);
 int nf_ct_expect_register_notifier(struct nf_exp_event_notifier *new)
 {
 	int ret = 0;
+	struct nf_exp_event_notifier *notify;
 
 	mutex_lock(&nf_ct_ecache_mutex);
-	if (nf_expect_event_cb != NULL) {
+	notify = rcu_dereference_protected(nf_expect_event_cb,
+					   lockdep_is_held(&nf_ct_ecache_mutex));
+	if (notify != NULL) {
 		ret = -EBUSY;
 		goto out_unlock;
 	}
@@ -128,8 +138,12 @@ EXPORT_SYMBOL_GPL(nf_ct_expect_register_notifier);
 
 void nf_ct_expect_unregister_notifier(struct nf_exp_event_notifier *new)
 {
+	struct nf_exp_event_notifier *notify;
+
 	mutex_lock(&nf_ct_ecache_mutex);
-	BUG_ON(nf_expect_event_cb != new);
+	notify = rcu_dereference_protected(nf_expect_event_cb,
+					   lockdep_is_held(&nf_ct_ecache_mutex));
+	BUG_ON(notify != new);
 	rcu_assign_pointer(nf_expect_event_cb, NULL);
 	mutex_unlock(&nf_ct_ecache_mutex);
 }
diff --git a/net/netfilter/nf_log.c b/net/netfilter/nf_log.c
index 908f599..7df37fd 100644
--- a/net/netfilter/nf_log.c
+++ b/net/netfilter/nf_log.c
@@ -35,6 +35,7 @@ static struct nf_logger *__find_logger(int pf, const char *str_logger)
 /* return EEXIST if the same logger is registred, 0 on success. */
 int nf_log_register(u_int8_t pf, struct nf_logger *logger)
 {
+	const struct nf_logger *llog;
 	int i;
 
 	if (pf >= ARRAY_SIZE(nf_loggers))
@@ -51,7 +52,9 @@ int nf_log_register(u_int8_t pf, struct nf_logger *logger)
 	} else {
 		/* register at end of list to honor first register win */
 		list_add_tail(&logger->list[pf], &nf_loggers_l[pf]);
-		if (nf_loggers[pf] == NULL)
+		llog = rcu_dereference_protected(nf_loggers[pf],
+						 lockdep_is_held(&nf_log_mutex));
+		if (llog == NULL)
 			rcu_assign_pointer(nf_loggers[pf], logger);
 	}
 
@@ -63,11 +66,14 @@ EXPORT_SYMBOL(nf_log_register);
 
 void nf_log_unregister(struct nf_logger *logger)
 {
+	const struct nf_logger *c_logger;
 	int i;
 
 	mutex_lock(&nf_log_mutex);
 	for (i = 0; i < ARRAY_SIZE(nf_loggers); i++) {
-		if (nf_loggers[i] == logger)
+		c_logger = rcu_dereference_protected(nf_loggers[i],
+						     lockdep_is_held(&nf_log_mutex));
+		if (c_logger == logger)
 			rcu_assign_pointer(nf_loggers[i], NULL);
 		list_del(&logger->list[i]);
 	}

--------------010005020008040209080803--
