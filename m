From: Patrick McHardy <kaber@trash.net>
Subject: Re: mmotm 2010-04-28 - RCU whinges
Date: Mon, 10 May 2010 17:40:58 +0200
Message-ID: <4BE8290A.2080707@trash.net>
References: <1272865137.2173.179.camel@edumazet-laptop>	<1272865267.2173.180.camel@edumazet-laptop>	<1272865436.2173.182.camel@edumazet-laptop> <20100502.225509.233880079.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030908070500050408000807"
Cc: eric.dumazet@gmail.com, Valdis.Kletnieks@vt.edu,
	akpm@linux-foundation.org, peterz@infradead.org,
	linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, paulmck@linux.vnet.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20100502.225509.233880079.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030908070500050408000807
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 8bit

David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Mon, 03 May 2010 07:43:56 +0200
> 
>> Le lundi 03 mai 2010 à 07:41 +0200, Eric Dumazet a écrit :
>>
>>> Oops scratch that, I'll resend a correct version.
>>>
>>>
>> Sorry, patch _is_ fine, I had one brain collapse when re-reading it, I
>> thought a different mutex was in use in one of the functions.
> 
> Ok, Patrick please review, thanks.

Actually we don't need the rcu_dereference() calls at all since
registration and unregistration are protected by the mutexes.

I queued this patch in nf-next, the only reason why I haven't
submitted it yet is that I was unable to get git to cleanly export
only the proper set of patches meant for -next due to a few merges,
it insists on including 5 patches already merged upstream. If you
don't mind ignoring the first 5 patches in the series, I'll send a
pull request tonight.



--------------030908070500050408000807
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

commit ed86308f6179d8fa6151c2d0f652aad0091548e2
Author: Patrick McHardy <kaber@trash.net>
Date:   Fri Apr 9 16:42:15 2010 +0200

    netfilter: remove invalid rcu_dereference() calls
    
    The CONFIG_PROVE_RCU option discovered a few invalid uses of
    rcu_dereference() in netfilter. In all these cases, the code code
    intends to check whether a pointer is already assigned when
    performing registration or whether the assigned pointer matches
    when performing unregistration. The entire registration/
    unregistration is protected by a mutex, so we don't need the
    rcu_dereference() calls.
    
    Reported-by: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>
    Tested-by: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

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

--------------030908070500050408000807--
