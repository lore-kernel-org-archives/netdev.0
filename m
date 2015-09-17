From: Ksenija Stanojevic <ksenija.stanojevic@gmail.com>
Subject: [PATCH] Replace get_seconds with ktime_get_seconds
Date: Thu, 17 Sep 2015 18:12:53 +0200
Message-ID: <1442506373-3326-1-git-send-email-ksenija.stanojevic@gmail.com>
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, dhowells@redhat.com, arnd@arndb.de,
	Ksenija Stanojevic <ksenija.stanojevic@gmail.com>
To: y2038@lists.linaro.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Replace time_t type and get_seconds function which are not y2038 safe
on 32-bit systems. Function ktime_get_seconds use monotonic instead of
real time and therefore will not cause overflow.

Signed-off-by: Ksenija Stanojevic <ksenija.stanojevic@gmail.com>
Reviewed-by: Arnd Bergmann <arnd@arndb.de>
---
 net/rxrpc/ar-connection.c | 4 ++--
 net/rxrpc/ar-internal.h   | 4 ++--
 net/rxrpc/ar-transport.c  | 4 ++--
 3 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/rxrpc/ar-connection.c b/net/rxrpc/ar-connection.c
index 6631f4f..692b3e6 100644
--- a/net/rxrpc/ar-connection.c
+++ b/net/rxrpc/ar-connection.c
@@ -808,7 +808,7 @@ void rxrpc_put_connection(struct rxrpc_connection *conn)
 
 	ASSERTCMP(atomic_read(&conn->usage), >, 0);
 
-	conn->put_time = get_seconds();
+	conn->put_time = ktime_get_seconds();
 	if (atomic_dec_and_test(&conn->usage)) {
 		_debug("zombie");
 		rxrpc_queue_delayed_work(&rxrpc_connection_reap, 0);
@@ -852,7 +852,7 @@ static void rxrpc_connection_reaper(struct work_struct *work)
 
 	_enter("");
 
-	now = get_seconds();
+	now = ktime_get_seconds();
 	earliest = ULONG_MAX;
 
 	write_lock_bh(&rxrpc_connection_lock);
diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index aef1bd2..2934a73 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -208,7 +208,7 @@ struct rxrpc_transport {
 	struct rb_root		server_conns;	/* server connections on this transport */
 	struct list_head	link;		/* link in master session list */
 	struct sk_buff_head	error_queue;	/* error packets awaiting processing */
-	time_t			put_time;	/* time at which to reap */
+	unsigned long		put_time;	/* time at which to reap */
 	spinlock_t		client_lock;	/* client connection allocation lock */
 	rwlock_t		conn_lock;	/* lock for active/dead connections */
 	atomic_t		usage;
@@ -256,7 +256,7 @@ struct rxrpc_connection {
 	struct rxrpc_crypt	csum_iv;	/* packet checksum base */
 	unsigned long		events;
 #define RXRPC_CONN_CHALLENGE	0		/* send challenge packet */
-	time_t			put_time;	/* time at which to reap */
+	unsigned long		put_time;	/* time at which to reap */
 	rwlock_t		lock;		/* access lock */
 	spinlock_t		state_lock;	/* state-change lock */
 	atomic_t		usage;
diff --git a/net/rxrpc/ar-transport.c b/net/rxrpc/ar-transport.c
index 1976dec..9946467 100644
--- a/net/rxrpc/ar-transport.c
+++ b/net/rxrpc/ar-transport.c
@@ -189,7 +189,7 @@ void rxrpc_put_transport(struct rxrpc_transport *trans)
 
 	ASSERTCMP(atomic_read(&trans->usage), >, 0);
 
-	trans->put_time = get_seconds();
+	trans->put_time = ktime_get_seconds();
 	if (unlikely(atomic_dec_and_test(&trans->usage))) {
 		_debug("zombie");
 		/* let the reaper determine the timeout to avoid a race with
@@ -226,7 +226,7 @@ static void rxrpc_transport_reaper(struct work_struct *work)
 
 	_enter("");
 
-	now = get_seconds();
+	now = ktime_get_seconds();
 	earliest = ULONG_MAX;
 
 	/* extract all the transports that have been dead too long */
-- 
1.9.1
