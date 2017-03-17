From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 03/18] net, l2tp: convert l2tp_session.ref_count from atomic_t to refcount_t
Date: Fri, 17 Mar 2017 13:12:44 +0200
Message-ID: <1489749179-12063-4-git-send-email-elena.reshetova@intel.com>
References: <1489749179-12063-1-git-send-email-elena.reshetova@intel.com>
Cc: linux-kernel@vger.kernel.org,
        linux-decnet-user@lists.sourceforge.net, davem@davemloft.net,
        jmorris@namei.org, kaber@trash.net, yoshfuji@linux-ipv6.org,
        kuznet@ms2.inr.ac.ru, 3chas3@gmail.com, ralf@linux-mips.org,
        stephen@networkplumber.org, jchapman@katalix.com, jhs@mojatatu.com,
        bridge@lists.linux-foundation.org, linux-hams@vger.kernel.org,
        linux-x25@vger.kernel.org, linux-bluetooth@vger.kernel.org,
        marcel@holtmann.org, johan.hedberg@gmail.com, peterz@infradead.org,
        keescook@chromium.org, Elena Reshetova <elena.reshetova@intel.com>,
        Hans Liljestrand <ishkamiel@gmail.com>,
        David Windsor <dwindsor@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1489749179-12063-1-git-send-email-elena.reshetova@intel.com>
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
 net/l2tp/l2tp_core.c |  2 +-
 net/l2tp/l2tp_core.h | 10 +++++-----
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
index 37e9cf3..20ee848 100644
--- a/net/l2tp/l2tp_core.c
+++ b/net/l2tp/l2tp_core.c
@@ -1796,7 +1796,7 @@ struct l2tp_session *l2tp_session_create(int priv_size, struct l2tp_tunnel *tunn
 		/* Bump the reference count. The session context is deleted
 		 * only when this drops to zero.
 		 */
-		l2tp_session_inc_refcount(session);
+		refcount_set(&session->ref_count, 1);
 		l2tp_tunnel_inc_refcount(tunnel);
 
 		/* Ensure tunnel socket isn't deleted */
diff --git a/net/l2tp/l2tp_core.h b/net/l2tp/l2tp_core.h
index b942854..568b721 100644
--- a/net/l2tp/l2tp_core.h
+++ b/net/l2tp/l2tp_core.h
@@ -99,7 +99,7 @@ struct l2tp_session {
 	int			nr_oos_count;	/* For OOS recovery */
 	int			nr_oos_count_max;
 	struct hlist_node	hlist;		/* Hash list node */
-	atomic_t		ref_count;
+	refcount_t		ref_count;
 
 	char			name[32];	/* for logging */
 	char			ifname[IFNAMSIZ];
@@ -271,12 +271,12 @@ int l2tp_ioctl(struct sock *sk, int cmd, unsigned long arg);
  */
 static inline void l2tp_session_inc_refcount_1(struct l2tp_session *session)
 {
-	atomic_inc(&session->ref_count);
+	refcount_inc(&session->ref_count);
 }
 
 static inline void l2tp_session_dec_refcount_1(struct l2tp_session *session)
 {
-	if (atomic_dec_and_test(&session->ref_count))
+	if (refcount_dec_and_test(&session->ref_count))
 		l2tp_session_free(session);
 }
 
@@ -285,14 +285,14 @@ static inline void l2tp_session_dec_refcount_1(struct l2tp_session *session)
 do {									\
 	pr_debug("l2tp_session_inc_refcount: %s:%d %s: cnt=%d\n",	\
 		 __func__, __LINE__, (_s)->name,			\
-		 atomic_read(&_s->ref_count));				\
+		 refcount_read(&_s->ref_count));			\
 	l2tp_session_inc_refcount_1(_s);				\
 } while (0)
 #define l2tp_session_dec_refcount(_s)					\
 do {									\
 	pr_debug("l2tp_session_dec_refcount: %s:%d %s: cnt=%d\n",	\
 		 __func__, __LINE__, (_s)->name,			\
-		 atomic_read(&_s->ref_count));				\
+		 refcount_read(&_s->ref_count));			\
 	l2tp_session_dec_refcount_1(_s);				\
 } while (0)
 #else
-- 
2.7.4
