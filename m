From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net-next v4 7/9] sock: ulimit on MSG_ZEROCOPY pages
Date: Thu,  3 Aug 2017 16:29:43 -0400
Message-ID: <20170803202945.70750-8-willemdebruijn.kernel@gmail.com>
References: <20170803202945.70750-1-willemdebruijn.kernel@gmail.com>
Cc: davem@davemloft.net, linux-api@vger.kernel.org,
        Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f194.google.com ([209.85.216.194]:34004 "EHLO
        mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751773AbdHCU3z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 16:29:55 -0400
In-Reply-To: <20170803202945.70750-1-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Bound the number of pages that a user may pin.

Follow the lead of perf tools to maintain a per-user bound on memory
locked pages commit 789f90fcf6b0 ("perf_counter: per user mlock gift")

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 include/linux/sched/user.h |  3 ++-
 include/linux/skbuff.h     |  5 +++++
 net/core/skbuff.c          | 48 ++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 55 insertions(+), 1 deletion(-)

diff --git a/include/linux/sched/user.h b/include/linux/sched/user.h
index 5d5415e129d4..3c07e4135127 100644
--- a/include/linux/sched/user.h
+++ b/include/linux/sched/user.h
@@ -36,7 +36,8 @@ struct user_struct {
 	struct hlist_node uidhash_node;
 	kuid_t uid;
 
-#if defined(CONFIG_PERF_EVENTS) || defined(CONFIG_BPF_SYSCALL)
+#if defined(CONFIG_PERF_EVENTS) || defined(CONFIG_BPF_SYSCALL) || \
+    defined(CONFIG_NET)
 	atomic_long_t locked_vm;
 #endif
 };
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index f5bdd93a87da..8c0708d2e5e6 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -457,6 +457,11 @@ struct ubuf_info {
 		};
 	};
 	atomic_t refcnt;
+
+	struct mmpin {
+		struct user_struct *user;
+		unsigned int num_pg;
+	} mmp;
 };
 
 #define skb_uarg(SKB)	((struct ubuf_info *)(skb_shinfo(SKB)->destructor_arg))
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index dcee0f64f1fa..42b62c716a33 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -897,6 +897,44 @@ struct sk_buff *skb_morph(struct sk_buff *dst, struct sk_buff *src)
 }
 EXPORT_SYMBOL_GPL(skb_morph);
 
+static int mm_account_pinned_pages(struct mmpin *mmp, size_t size)
+{
+	unsigned long max_pg, num_pg, new_pg, old_pg;
+	struct user_struct *user;
+
+	if (capable(CAP_IPC_LOCK) || !size)
+		return 0;
+
+	num_pg = (size >> PAGE_SHIFT) + 2;	/* worst case */
+	max_pg = rlimit(RLIMIT_MEMLOCK) >> PAGE_SHIFT;
+	user = mmp->user ? : current_user();
+
+	do {
+		old_pg = atomic_long_read(&user->locked_vm);
+		new_pg = old_pg + num_pg;
+		if (new_pg > max_pg)
+			return -ENOBUFS;
+	} while (atomic_long_cmpxchg(&user->locked_vm, old_pg, new_pg) !=
+		 old_pg);
+
+	if (!mmp->user) {
+		mmp->user = get_uid(user);
+		mmp->num_pg = num_pg;
+	} else {
+		mmp->num_pg += num_pg;
+	}
+
+	return 0;
+}
+
+static void mm_unaccount_pinned_pages(struct mmpin *mmp)
+{
+	if (mmp->user) {
+		atomic_long_sub(mmp->num_pg, &mmp->user->locked_vm);
+		free_uid(mmp->user);
+	}
+}
+
 struct ubuf_info *sock_zerocopy_alloc(struct sock *sk, size_t size)
 {
 	struct ubuf_info *uarg;
@@ -913,6 +951,12 @@ struct ubuf_info *sock_zerocopy_alloc(struct sock *sk, size_t size)
 
 	BUILD_BUG_ON(sizeof(*uarg) > sizeof(skb->cb));
 	uarg = (void *)skb->cb;
+	uarg->mmp.user = NULL;
+
+	if (mm_account_pinned_pages(&uarg->mmp, size)) {
+		kfree_skb(skb);
+		return NULL;
+	}
 
 	uarg->callback = sock_zerocopy_callback;
 	uarg->id = ((u32)atomic_inc_return(&sk->sk_zckey)) - 1;
@@ -956,6 +1000,8 @@ struct ubuf_info *sock_zerocopy_realloc(struct sock *sk, size_t size,
 
 		next = (u32)atomic_read(&sk->sk_zckey);
 		if ((u32)(uarg->id + uarg->len) == next) {
+			if (mm_account_pinned_pages(&uarg->mmp, size))
+				return NULL;
 			uarg->len++;
 			uarg->bytelen = bytelen;
 			atomic_set(&sk->sk_zckey, ++next);
@@ -1038,6 +1084,8 @@ EXPORT_SYMBOL_GPL(sock_zerocopy_callback);
 void sock_zerocopy_put(struct ubuf_info *uarg)
 {
 	if (uarg && atomic_dec_and_test(&uarg->refcnt)) {
+		mm_unaccount_pinned_pages(&uarg->mmp);
+
 		if (uarg->callback)
 			uarg->callback(uarg, uarg->zerocopy);
 		else
-- 
2.14.0.rc1.383.gd1ce394fe2-goog
