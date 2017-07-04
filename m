From: Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 03/36] net,
	l2tp: convert l2tp_session.ref_count from atomic_t to refcount_t
Date: Tue,  4 Jul 2017 15:52:58 +0300
Message-ID: <1499172811-16271-4-git-send-email-elena.reshetova@intel.com>
References: <1499172811-16271-1-git-send-email-elena.reshetova@intel.com>
Cc: peterz@infradead.org, jchapman@katalix.com, bfields@fieldses.org,
	linux-sctp@vger.kernel.org, jlayton@poochiereds.net,
	Elena Reshetova <elena.reshetova@intel.com>,
	steffen.klassert@secunet.com, zyan@redhat.com,
	herbert@gondor.apana.org.au, linux-x25@vger.kernel.org,
	linux-rdma@vger.kernel.org, bridge@lists.linux-foundation.org,
	jmorris@namei.org, 3chas3@gmail.com, kuznet@ms2.inr.ac.ru,
	jreuter@yaina.de, keescook@chromium.org,
	santosh.shilimkar@oracle.com, jhs@mojatatu.com,
	Hans Liljestrand <ishkamiel@gmail.com>,
	linux-hams@vger.kernel.org, David Windsor <dwindsor@gmail.com>,
	linux-nfs@vger.kernel.org, sage@redhat.com,
	nhorman@tuxdriver.com, yoshfuji@linux-ipv6.org,
	vyasevich@gmail.com, linux-decnet-user@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, ralf@linux-mips.org,
	kaber@trash.net, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1499172811-16271-1-git-send-email-elena.reshetova@intel.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
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
index 203c4aa..b0c2d4a 100644
--- a/net/l2tp/l2tp_core.c
+++ b/net/l2tp/l2tp_core.c
@@ -1854,7 +1854,7 @@ struct l2tp_session *l2tp_session_create(int priv_size, struct l2tp_tunnel *tunn
 		/* Bump the reference count. The session context is deleted
 		 * only when this drops to zero.
 		 */
-		l2tp_session_inc_refcount(session);
+		refcount_set(&session->ref_count, 1);
 		l2tp_tunnel_inc_refcount(tunnel);
 
 		/* Ensure tunnel socket isn't deleted */
diff --git a/net/l2tp/l2tp_core.h b/net/l2tp/l2tp_core.h
index da58fad..cdb6e33 100644
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
@@ -274,12 +274,12 @@ int l2tp_ioctl(struct sock *sk, int cmd, unsigned long arg);
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
 
@@ -288,14 +288,14 @@ static inline void l2tp_session_dec_refcount_1(struct l2tp_session *session)
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
