From: Patrick McHardy <kaber@trash.net>
Subject: Re: mmotm 2010-04-05-16-09 uploaded
Date: Thu, 08 Apr 2010 17:36:07 +0200
Message-ID: <4BBDF7E7.708@trash.net>
References: <201004052336.o35NaeSE015814@imap1.linux-foundation.org> <13074.1270663309@localhost>            <4BBDC0CC.7080305@trash.net> <6795.1270740197@localhost>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030403000004010505030202"
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: Valdis.Kletnieks@vt.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:39412 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932655Ab0DHPgL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Apr 2010 11:36:11 -0400
In-Reply-To: <6795.1270740197@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------030403000004010505030202
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Valdis.Kletnieks@vt.edu wrote:
> On Thu, 08 Apr 2010 13:41:00 +0200, Patrick McHardy said:
>>> [   11.488579] ===================================================
>>> [   11.489529] [ INFO: suspicious rcu_dereference_check() usage. ]
>>> [   11.489988] ---------------------------------------------------
>>> [   11.490494] net/netfilter/nf_conntrack_ecache.c:88 invoked rcu_dereference_check() without protection!
>>> [   11.491024] 
>> There are some unnecessary rcu_dereference() calls in the conntrack
>> notifier registration and unregistration functions.
>>
>> Does this fix it?
> 
> Well, it *changed* it.  Does the rcu_defererence_check() only fire on the
> first time it hits something, so we've fixed the first one and now we get to
> see the second one?

It appears that way, otherwise you should have seen a second warning in
nf_conntrack_ecache the last time.

> (For what it's worth, if this is going to be one-at-a-time whack-a-mole, I'm
> OK on that, just want to know up front.)

I went through the other files and I believe this should be it.
We already removed most of these incorrect rcu_dereference()
calls a while back.

> [    9.299425] ip_tables: (C) 2000-2006 Netfilter Core Team
> [    9.299486] 
> [    9.299486] ===================================================
> [    9.300499] [ INFO: suspicious rcu_dereference_check() usage. ]
> [    9.301001] ---------------------------------------------------
> [    9.301523] net/netfilter/nf_log.c:55 invoked rcu_dereference_check() without protection!
> [    9.302066] 


--------------030403000004010505030202
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

diff --git a/net/netfilter/nf_conntrack_ecache.c b/net/netfilter/nf_conntrack_ecache.c
index d5a9bcd..849614a 100644
--- a/net/netfilter/nf_conntrack_ecache.c
+++ b/net/netfilter/nf_conntrack_ecache.c
@@ -81,11 +81,9 @@ EXPORT_SYMBOL_GPL(nf_ct_deliver_cached_events);
 int nf_conntrack_register_notifier(struct nf_ct_event_notifier *new)
 {
 	int ret = 0;
-	struct nf_ct_event_notifier *notify;
 
 	mutex_lock(&nf_ct_ecache_mutex);
-	notify = rcu_dereference(nf_conntrack_event_cb);
-	if (notify != NULL) {
+	if (nf_conntrack_event_cb != NULL) {
 		ret = -EBUSY;
 		goto out_unlock;
 	}
@@ -101,11 +99,8 @@ EXPORT_SYMBOL_GPL(nf_conntrack_register_notifier);
 
 void nf_conntrack_unregister_notifier(struct nf_ct_event_notifier *new)
 {
-	struct nf_ct_event_notifier *notify;
-
 	mutex_lock(&nf_ct_ecache_mutex);
-	notify = rcu_dereference(nf_conntrack_event_cb);
-	BUG_ON(notify != new);
+	BUG_ON(nf_conntrack_event_cb != new);
 	rcu_assign_pointer(nf_conntrack_event_cb, NULL);
 	mutex_unlock(&nf_ct_ecache_mutex);
 }
@@ -114,11 +109,9 @@ EXPORT_SYMBOL_GPL(nf_conntrack_unregister_notifier);
 int nf_ct_expect_register_notifier(struct nf_exp_event_notifier *new)
 {
 	int ret = 0;
-	struct nf_exp_event_notifier *notify;
 
 	mutex_lock(&nf_ct_ecache_mutex);
-	notify = rcu_dereference(nf_expect_event_cb);
-	if (notify != NULL) {
+	if (nf_expect_event_cb != NULL) {
 		ret = -EBUSY;
 		goto out_unlock;
 	}
@@ -134,11 +127,8 @@ EXPORT_SYMBOL_GPL(nf_ct_expect_register_notifier);
 
 void nf_ct_expect_unregister_notifier(struct nf_exp_event_notifier *new)
 {
-	struct nf_exp_event_notifier *notify;
-
 	mutex_lock(&nf_ct_ecache_mutex);
-	notify = rcu_dereference(nf_expect_event_cb);
-	BUG_ON(notify != new);
+	BUG_ON(nf_expect_event_cb != new);
 	rcu_assign_pointer(nf_expect_event_cb, NULL);
 	mutex_unlock(&nf_ct_ecache_mutex);
 }
diff --git a/net/netfilter/nf_log.c b/net/netfilter/nf_log.c
index 015725a..908f599 100644
--- a/net/netfilter/nf_log.c
+++ b/net/netfilter/nf_log.c
@@ -35,7 +35,6 @@ static struct nf_logger *__find_logger(int pf, const char *str_logger)
 /* return EEXIST if the same logger is registred, 0 on success. */
 int nf_log_register(u_int8_t pf, struct nf_logger *logger)
 {
-	const struct nf_logger *llog;
 	int i;
 
 	if (pf >= ARRAY_SIZE(nf_loggers))
@@ -52,8 +51,7 @@ int nf_log_register(u_int8_t pf, struct nf_logger *logger)
 	} else {
 		/* register at end of list to honor first register win */
 		list_add_tail(&logger->list[pf], &nf_loggers_l[pf]);
-		llog = rcu_dereference(nf_loggers[pf]);
-		if (llog == NULL)
+		if (nf_loggers[pf] == NULL)
 			rcu_assign_pointer(nf_loggers[pf], logger);
 	}
 
@@ -65,13 +63,11 @@ EXPORT_SYMBOL(nf_log_register);
 
 void nf_log_unregister(struct nf_logger *logger)
 {
-	const struct nf_logger *c_logger;
 	int i;
 
 	mutex_lock(&nf_log_mutex);
 	for (i = 0; i < ARRAY_SIZE(nf_loggers); i++) {
-		c_logger = rcu_dereference(nf_loggers[i]);
-		if (c_logger == logger)
+		if (nf_loggers[i] == logger)
 			rcu_assign_pointer(nf_loggers[i], NULL);
 		list_del(&logger->list[i]);
 	}

--------------030403000004010505030202--
