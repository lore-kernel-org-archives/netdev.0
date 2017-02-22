From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH RFC v2 06/12] sock: sendmsg zerocopy ulimit
Date: Wed, 22 Feb 2017 11:38:55 -0500
Message-ID: <20170222163901.90834-7-willemdebruijn.kernel@gmail.com>
References: <20170222163901.90834-1-willemdebruijn.kernel@gmail.com>
Cc: Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:35994 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932358AbdBVQji (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Feb 2017 11:39:38 -0500
Received: by mail-qt0-f193.google.com with SMTP id n37so1059142qtb.3
        for <netdev@vger.kernel.org>; Wed, 22 Feb 2017 08:39:33 -0800 (PST)
In-Reply-To: <20170222163901.90834-1-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Bound the number of pages that a user may pin.

Follow the lead of perf tools to maintain a per-user bound on memory
locked pages commit 789f90fcf6b0 ("perf_counter: per user mlock gift")

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 include/linux/sched.h  |  2 +-
 include/linux/skbuff.h |  5 +++++
 net/core/skbuff.c      | 48 ++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 54 insertions(+), 1 deletion(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index ad3ec9ec61f7..943714f8e91a 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -905,7 +905,7 @@ struct user_struct {
 	struct hlist_node uidhash_node;
 	kuid_t uid;
 
-#if defined(CONFIG_PERF_EVENTS) || defined(CONFIG_BPF_SYSCALL)
+#if defined(CONFIG_PERF_EVENTS) || defined(CONFIG_BPF_SYSCALL) || defined(CONFIG_NET)
 	atomic_long_t locked_vm;
 #endif
 };
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index eedac9fd3f0f..a38308b10d76 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -414,6 +414,11 @@ struct ubuf_info {
 		};
 	};
 	atomic_t refcnt;
+
+	struct mmpin {
+		struct user_struct *user;
+		int num_pg;
+	} mmp;
 };
 
 #define skb_uarg(SKB)	((struct ubuf_info *)(skb_shinfo(SKB)->destructor_arg))
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 7a1d6e7703a6..b86e196d6dec 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -914,6 +914,44 @@ struct sk_buff *skb_morph(struct sk_buff *dst, struct sk_buff *src)
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
+			return -ENOMEM;
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
 /* must only be called from process context */
 struct ubuf_info *sock_zerocopy_alloc(struct sock *sk, size_t size)
 {
@@ -926,6 +964,12 @@ struct ubuf_info *sock_zerocopy_alloc(struct sock *sk, size_t size)
 
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
@@ -958,6 +1002,8 @@ struct ubuf_info *sock_zerocopy_realloc(struct sock *sk, size_t size,
 
 		next = (u32)atomic_read(&sk->sk_zckey);
 		if ((u32)(uarg->id + uarg->len) == next) {
+			if (mm_account_pinned_pages(&uarg->mmp, size))
+				return NULL;
 			uarg->len++;
 			atomic_set(&sk->sk_zckey, ++next);
 			return uarg;
@@ -1037,6 +1083,8 @@ EXPORT_SYMBOL_GPL(sock_zerocopy_callback);
 void sock_zerocopy_put(struct ubuf_info *uarg)
 {
 	if (uarg && atomic_dec_and_test(&uarg->refcnt)) {
+		mm_unaccount_pinned_pages(&uarg->mmp);
+
 		if (uarg->callback)
 			uarg->callback(uarg, true);
 		else
-- 
2.11.0.483.g087da7b7c-goog
