From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 17/17] net: convert packet_fanout.sk_ref from atomic_t to refcount_t
Date: Thu, 16 Mar 2017 17:29:07 +0200
Message-ID: <1489678147-21404-18-git-send-email-elena.reshetova@intel.com>
References: <1489678147-21404-1-git-send-email-elena.reshetova@intel.com>
Cc: bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, kaber@trash.net,
        stephen@networkplumber.org, peterz@infradead.org,
        keescook@chromium.org, Elena Reshetova <elena.reshetova@intel.com>,
        Hans Liljestrand <ishkamiel@gmail.com>,
        David Windsor <dwindsor@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1489678147-21404-1-git-send-email-elena.reshetova@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

refcount_t type and corresponding API should be
used instead of atomic_t when the variable is used as
a reference counter. This allows to avoid accidental
refcounter overflows that might lead to use-after-free
situations.

Signed-off-by: Elena Reshetova <elena.reshetova@intel.com>
Signed-off-by: Hans Liljestrand <ishkamiel@gmail.com>
Signed-off-by: Kees Cook <keescook@chromium.org>
Signed-off-by: David Windsor <dwindsor@gmail.com>
---
 net/packet/af_packet.c | 8 ++++----
 net/packet/internal.h  | 4 +++-
 2 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index ad5e5dc..ef868a7 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1698,7 +1698,7 @@ static int fanout_add(struct sock *sk, u16 id, u16 type_flags)
 		match->flags = flags;
 		INIT_LIST_HEAD(&match->list);
 		spin_lock_init(&match->lock);
-		atomic_set(&match->sk_ref, 0);
+		refcount_set(&match->sk_ref, 0);
 		fanout_init_data(match);
 		match->prot_hook.type = po->prot_hook.type;
 		match->prot_hook.dev = po->prot_hook.dev;
@@ -1712,10 +1712,10 @@ static int fanout_add(struct sock *sk, u16 id, u16 type_flags)
 	    match->prot_hook.type == po->prot_hook.type &&
 	    match->prot_hook.dev == po->prot_hook.dev) {
 		err = -ENOSPC;
-		if (atomic_read(&match->sk_ref) < PACKET_FANOUT_MAX) {
+		if (refcount_read(&match->sk_ref) < PACKET_FANOUT_MAX) {
 			__dev_remove_pack(&po->prot_hook);
 			po->fanout = match;
-			atomic_inc(&match->sk_ref);
+			refcount_set(&match->sk_ref, refcount_read(&match->sk_ref) + 1);
 			__fanout_link(sk, po);
 			err = 0;
 		}
@@ -1744,7 +1744,7 @@ static struct packet_fanout *fanout_release(struct sock *sk)
 	if (f) {
 		po->fanout = NULL;
 
-		if (atomic_dec_and_test(&f->sk_ref))
+		if (refcount_dec_and_test(&f->sk_ref))
 			list_del(&f->list);
 		else
 			f = NULL;
diff --git a/net/packet/internal.h b/net/packet/internal.h
index 9ee4631..94d1d40 100644
--- a/net/packet/internal.h
+++ b/net/packet/internal.h
@@ -1,6 +1,8 @@
 #ifndef __PACKET_INTERNAL_H__
 #define __PACKET_INTERNAL_H__
 
+#include <linux/refcount.h>
+
 struct packet_mclist {
 	struct packet_mclist	*next;
 	int			ifindex;
@@ -86,7 +88,7 @@ struct packet_fanout {
 	struct list_head	list;
 	struct sock		*arr[PACKET_FANOUT_MAX];
 	spinlock_t		lock;
-	atomic_t		sk_ref;
+	refcount_t		sk_ref;
 	struct packet_type	prot_hook ____cacheline_aligned_in_smp;
 };
 
-- 
2.7.4
