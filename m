From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 1/7] rxrpc: Fix ASSERTCMP and ASSERTIFCMP to handle
 signed values
Date: Thu, 08 Sep 2016 12:43:35 +0100
Message-ID: <147333501582.5646.10425286458915185767.stgit@warthog.procyon.org.uk>
References: <147333500815.5646.1897433750795776938.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <147333500815.5646.1897433750795776938.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix ASSERTCMP and ASSERTIFCMP to be able to handle signed values by casting
both parameters to the type of the first before comparing.  Without this,
both values are cast to unsigned long, which means that checks for values
less than zero don't work.

The downside of this is that the state enum values in struct rxrpc_call and
struct rxrpc_connection can't be bitfields as __typeof__ can't handle them.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/ar-internal.h |   24 +++++++++++++-----------
 1 file changed, 13 insertions(+), 11 deletions(-)

diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index dbfb9ed17483..6dc3a59ce0f2 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -344,8 +344,8 @@ struct rxrpc_connection {
 	unsigned long		events;
 	unsigned long		idle_timestamp;	/* Time at which last became idle */
 	spinlock_t		state_lock;	/* state-change lock */
-	enum rxrpc_conn_cache_state cache_state : 8;
-	enum rxrpc_conn_proto_state state : 8;	/* current state of connection */
+	enum rxrpc_conn_cache_state cache_state;
+	enum rxrpc_conn_proto_state state;	/* current state of connection */
 	u32			local_abort;	/* local abort code */
 	u32			remote_abort;	/* remote abort code */
 	int			debug_id;	/* debug ID for printks */
@@ -464,8 +464,8 @@ struct rxrpc_call {
 	rwlock_t		state_lock;	/* lock for state transition */
 	u32			abort_code;	/* Local/remote abort code */
 	int			error;		/* Local error incurred */
-	enum rxrpc_call_state	state : 8;	/* current state of call */
-	enum rxrpc_call_completion completion : 8; /* Call completion condition */
+	enum rxrpc_call_state	state;		/* current state of call */
+	enum rxrpc_call_completion completion;	/* Call completion condition */
 	atomic_t		usage;
 	atomic_t		skb_count;	/* Outstanding packets on this call */
 	atomic_t		sequence;	/* Tx data packet sequence counter */
@@ -1014,11 +1014,12 @@ do {								\
 
 #define ASSERTCMP(X, OP, Y)						\
 do {									\
-	unsigned long _x = (unsigned long)(X);				\
-	unsigned long _y = (unsigned long)(Y);				\
+	__typeof__(X) _x = (X);						\
+	__typeof__(Y) _y = (__typeof__(X))(Y);				\
 	if (unlikely(!(_x OP _y))) {					\
-		pr_err("Assertion failed - %lu(0x%lx) %s %lu(0x%lx) is false\n",			\
-		       _x, _x, #OP, _y, _y);				\
+		pr_err("Assertion failed - %lu(0x%lx) %s %lu(0x%lx) is false\n", \
+		       (unsigned long)_x, (unsigned long)_x, #OP,	\
+		       (unsigned long)_y, (unsigned long)_y);		\
 		BUG();							\
 	}								\
 } while (0)
@@ -1033,11 +1034,12 @@ do {								\
 
 #define ASSERTIFCMP(C, X, OP, Y)					\
 do {									\
-	unsigned long _x = (unsigned long)(X);				\
-	unsigned long _y = (unsigned long)(Y);				\
+	__typeof__(X) _x = (X);						\
+	__typeof__(Y) _y = (__typeof__(X))(Y);				\
 	if (unlikely((C) && !(_x OP _y))) {				\
 		pr_err("Assertion failed - %lu(0x%lx) %s %lu(0x%lx) is false\n", \
-		       _x, _x, #OP, _y, _y);				\
+		       (unsigned long)_x, (unsigned long)_x, #OP,	\
+		       (unsigned long)_y, (unsigned long)_y);		\
 		BUG();							\
 	}								\
 } while (0)
