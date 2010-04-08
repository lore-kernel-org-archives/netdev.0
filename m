From: Patrick McHardy <kaber@trash.net>
Subject: Re: mmotm 2010-04-05-16-09 uploaded
Date: Thu, 08 Apr 2010 13:41:00 +0200
Message-ID: <4BBDC0CC.7080305@trash.net>
References: <201004052336.o35NaeSE015814@imap1.linux-foundation.org> <13074.1270663309@localhost>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030704070607030103010608"
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: Valdis.Kletnieks@vt.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:35541 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752156Ab0DHLlC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Apr 2010 07:41:02 -0400
In-Reply-To: <13074.1270663309@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------030704070607030103010608
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Valdis.Kletnieks@vt.edu wrote:
> On Mon, 05 Apr 2010 16:09:45 PDT, akpm@linux-foundation.org said:
>> The mm-of-the-moment snapshot 2010-04-05-16-09 has been uploaded to
>>
>>    http://userweb.kernel.org/~akpm/mmotm/
> 
> Seen in dmesg, 2.6.34-rc2-mmotm0323 didn't do this. Tossing it at all the
> likely suspects, hopefully somebody will recognize it and save me the
> bisecting. ;)
> 
> [   11.488535] ctnetlink v0.93: registering with nfnetlink.
> [   11.488579] 
> [   11.488579] ===================================================
> [   11.489529] [ INFO: suspicious rcu_dereference_check() usage. ]
> [   11.489988] ---------------------------------------------------
> [   11.490494] net/netfilter/nf_conntrack_ecache.c:88 invoked rcu_dereference_check() without protection!
> [   11.491024] 
> [   11.491024] other info that might help us debug this:
> [   11.491025] 
> [   11.492834] 
> [   11.492835] rcu_scheduler_active = 1, debug_locks = 0
> [   11.494124] 1 lock held by swapper/1:
> [   11.494776]  #0:  (nf_ct_ecache_mutex){+.+...}, at: [<ffffffff8148c606>] nf_conntrack_register_notifier+0x1a/0x76
> [   11.495505] 

There are some unnecessary rcu_dereference() calls in the conntrack
notifier registration and unregistration functions.

Does this fix it?


--------------030704070607030103010608
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

--------------030704070607030103010608--
