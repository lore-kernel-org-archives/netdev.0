From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net-next RFC 09/10] sock: sendmsg zerocopy ulimit
Date: Thu, 20 Aug 2015 10:36:48 -0400
Message-ID: <1440081408-12302-10-git-send-email-willemb@google.com>
References: <1440081408-12302-1-git-send-email-willemb@google.com>
Cc: mst@redhat.com, jasowang@redhat.com,
	Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f178.google.com ([209.85.220.178]:34134 "EHLO
	mail-qk0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751942AbbHTOg7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2015 10:36:59 -0400
Received: by qkfh127 with SMTP id h127so16061095qkf.1
        for <netdev@vger.kernel.org>; Thu, 20 Aug 2015 07:36:58 -0700 (PDT)
In-Reply-To: <1440081408-12302-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Bound the number of pages that a userspace process may pin.

Account pinned pages to the locked page count (`ulimit -l`) of the
caller and fail beyond the administrator controlled threshold, similar
to infiniband.

Use an atomic variable to avoid having to take mmap_sem. Taking the
lock is expensive and requires scheduling a worker on destruction,
as taking the lock may sleep, but ubuf_info are often destroyed in
atomic context.

The current mm_struct.pinned_vm_ is a hack. A non-RFC patchset would
convert unsigned long pinned_vm_ and all its callers (infiniband) to
atomic_long_t.

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 include/linux/mm_types.h |  1 +
 include/linux/skbuff.h   |  5 +++++
 net/core/skbuff.c        | 46 ++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 52 insertions(+)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 0038ac7..dc6e12a 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -402,6 +402,7 @@ struct mm_struct {
 	unsigned long total_vm;		/* Total pages mapped */
 	unsigned long locked_vm;	/* Pages that have PG_mlocked set */
 	unsigned long pinned_vm;	/* Refcount permanently increased */
+	atomic_t pinned_vm_;
 	unsigned long shared_vm;	/* Shared pages (files) */
 	unsigned long exec_vm;		/* VM_EXEC & ~VM_WRITE */
 	unsigned long stack_vm;		/* VM_GROWSUP/DOWN */
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index c1ea855..95a9f75 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -331,6 +331,11 @@ struct ubuf_info {
 		};
 	};
 	atomic_t refcnt;
+
+	struct mmpin {
+		struct mm_struct *mm;
+		int num_pg;
+	} mmp;
 };
 
 #define skb_uarg(SKB)	((struct ubuf_info *)(skb_shinfo(SKB)->destructor_arg))
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 4ae60ee..3742968 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -840,6 +840,42 @@ struct sk_buff *skb_morph(struct sk_buff *dst, struct sk_buff *src)
 }
 EXPORT_SYMBOL_GPL(skb_morph);
 
+static int mm_account_pinned_pages(struct mmpin *mmp, size_t size)
+{
+	unsigned long max_pg, num_pg, new_pg, old_pg;
+	struct mm_struct *mm;
+
+	if (capable(CAP_IPC_LOCK) || !size)
+		return 0;
+
+	num_pg = (size >> PAGE_SHIFT) + 2;	/* worst case */
+	max_pg = rlimit(RLIMIT_MEMLOCK) >> PAGE_SHIFT;
+	mm = mmp->mm ? : current->mm;
+
+	do {
+		old_pg = atomic_read(&mm->pinned_vm_);
+		new_pg = old_pg + num_pg;
+		if (new_pg > max_pg)
+			return -ENOMEM;
+	} while (atomic_cmpxchg(&mm->pinned_vm_, old_pg, new_pg) != old_pg);
+
+	if (!mmp->mm) {
+		mmp->mm = mm;
+		atomic_inc(&mm->mm_count);
+	}
+
+	mmp->num_pg += num_pg;
+	return 0;
+}
+
+static void mm_unaccount_pinned_pages(struct mmpin *mmp)
+{
+	if (mmp->mm) {
+		atomic_sub(mmp->num_pg, &mmp->mm->pinned_vm_);
+		mmdrop(mmp->mm);
+	}
+}
+
 /* must only be called from process context */
 struct ubuf_info *sock_zerocopy_alloc(struct sock *sk, size_t size)
 {
@@ -852,6 +888,12 @@ struct ubuf_info *sock_zerocopy_alloc(struct sock *sk, size_t size)
 
 	BUILD_BUG_ON(sizeof(*uarg) > sizeof(skb->cb));
 	uarg = (void *)skb->cb;
+	uarg->mmp.mm = NULL;
+
+	if (mm_account_pinned_pages(&uarg->mmp, size)) {
+		kfree_skb(skb);
+		return NULL;
+	}
 
 	uarg->callback = sock_zerocopy_callback;
 	uarg->id = ((u16)atomic_inc_return(&sk->sk_zckey)) - 1;
@@ -880,6 +922,8 @@ struct ubuf_info *sock_zerocopy_realloc(struct sock *sk, size_t size,
 
 		next = atomic_read(&sk->sk_zckey);
 		if ((u16)(uarg->id + uarg->len) == next) {
+			if (mm_account_pinned_pages(&uarg->mmp, size))
+				return NULL;
 			uarg->len++;
 			atomic_set(&sk->sk_zckey, ++next);
 			return uarg;
@@ -946,6 +990,8 @@ EXPORT_SYMBOL_GPL(sock_zerocopy_callback);
 void sock_zerocopy_put(struct ubuf_info *uarg)
 {
 	if (uarg && atomic_dec_and_test(&uarg->refcnt)) {
+		mm_unaccount_pinned_pages(&uarg->mmp);
+
 		/* if !len, there was only 1 call, and it was aborted */
 		if (uarg->callback && uarg->len)
 			uarg->callback(uarg, true);
-- 
2.5.0.276.gf5e568e
