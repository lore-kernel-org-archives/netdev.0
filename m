From: Patrick McHardy <kaber@trash.net>
Subject: Re: mmotm 2010-04-05-16-09 uploaded
Date: Fri, 09 Apr 2010 16:49:16 +0200
Message-ID: <4BBF3E6C.5010708@trash.net>
References: <201004052336.o35NaeSE015814@imap1.linux-foundation.org> <13074.1270663309@localhost> <4BBDC0CC.7080305@trash.net> <6795.1270740197@localhost>            <4BBDF7E7.708@trash.net> <8356.1270774206@localhost>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040807000900090401050007"
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: Valdis.Kletnieks@vt.edu
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <8356.1270774206@localhost>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040807000900090401050007
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Valdis.Kletnieks@vt.edu wrote:
> On Thu, 08 Apr 2010 17:36:07 +0200, Patrick McHardy said:
> 
>> Valdis.Kletnieks@vt.edu wrote:
> 
>>> Well, it *changed* it.  Does the rcu_defererence_check() only fire on the
>>> first time it hits something, so we've fixed the first one and now we get to
>>> see the second one?
>> It appears that way, otherwise you should have seen a second warning in
>> nf_conntrack_ecache the last time.
>>
>>> (For what it's worth, if this is going to be one-at-a-time whack-a-mole, I'm
>>> OK on that, just want to know up front.)
>> I went through the other files and I believe this should be it.
>> We already removed most of these incorrect rcu_dereference()
>> calls a while back.
> 
> Confirming - the second version of the patch fixes all the network-related
> RCU complaints I've been able to trigger...

Thanks. I've added the attached commit to the nf-next tree. I'll push
it to Dave shortly so this can get included in the next tree.


--------------040807000900090401050007
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

>From ed86308f6179d8fa6151c2d0f652aad0091548e2 Mon Sep 17 00:00:00 2001
From: Patrick McHardy <kaber@trash.net>
Date: Fri, 9 Apr 2010 16:42:15 +0200
Subject: [PATCH] netfilter: remove invalid rcu_dereference() calls

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
---
 net/netfilter/nf_conntrack_ecache.c |   18 ++++--------------
 net/netfilter/nf_log.c              |    8 ++------
 2 files changed, 6 insertions(+), 20 deletions(-)

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
-- 
1.7.0.4


--------------040807000900090401050007--
