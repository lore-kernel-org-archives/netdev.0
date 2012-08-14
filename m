From: Sasha Levin <levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 10/16] dlm: use new hashtable implementation
Date: Tue, 14 Aug 2012 18:24:44 +0200
Message-ID: <1344961490-4068-11-git-send-email-levinsasha928@gmail.com>
References: <1344961490-4068-1-git-send-email-levinsasha928@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, neilb-l3A5Bk7waGM@public.gmane.org, fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org, bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org,
	paul.gortmaker-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, aarcange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, rds-devel-N0ozoZBvEnrZJqsBc5GL+g@public.gmane.org,
	eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, venkat.x.venkatsubra-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org,
	ccaulfie-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org,
	ericvh-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, josh-iaAMLnmF4UmaiuxdJuQwMA@public.gmane.org, rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org,
	lw-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org, mathieu.desnoyers-vg+e7yoeK/dWk0Htik3J/w@public.gmane.org,
	Sasha Levin <levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org,
	linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
	linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ejt-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, teigland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1344961490-4068-1-git-send-email-levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

Switch dlm to use the new hashtable implementation. This reduces the amount of
generic unrelated code in the dlm.

Signed-off-by: Sasha Levin <levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 fs/dlm/lowcomms.c |   47 +++++++++++++----------------------------------
 1 files changed, 13 insertions(+), 34 deletions(-)

diff --git a/fs/dlm/lowcomms.c b/fs/dlm/lowcomms.c
index 522a69f..e36dad2 100644
--- a/fs/dlm/lowcomms.c
+++ b/fs/dlm/lowcomms.c
@@ -55,6 +55,7 @@
 #include <net/sctp/sctp.h>
 #include <net/sctp/user.h>
 #include <net/ipv6.h>
+#include <linux/hashtable.h>
 
 #include "dlm_internal.h"
 #include "lowcomms.h"
@@ -62,7 +63,7 @@
 #include "config.h"
 
 #define NEEDED_RMEM (4*1024*1024)
-#define CONN_HASH_SIZE 32
+#define CONN_HASH_BITS 5
 
 /* Number of messages to send before rescheduling */
 #define MAX_SEND_MSG_COUNT 25
@@ -158,34 +159,21 @@ static int dlm_allow_conn;
 static struct workqueue_struct *recv_workqueue;
 static struct workqueue_struct *send_workqueue;
 
-static struct hlist_head connection_hash[CONN_HASH_SIZE];
+static struct hlist_head connection_hash[CONN_HASH_BITS];
 static DEFINE_MUTEX(connections_lock);
 static struct kmem_cache *con_cache;
 
 static void process_recv_sockets(struct work_struct *work);
 static void process_send_sockets(struct work_struct *work);
 
-
-/* This is deliberately very simple because most clusters have simple
-   sequential nodeids, so we should be able to go straight to a connection
-   struct in the array */
-static inline int nodeid_hash(int nodeid)
-{
-	return nodeid & (CONN_HASH_SIZE-1);
-}
-
 static struct connection *__find_con(int nodeid)
 {
-	int r;
 	struct hlist_node *h;
 	struct connection *con;
 
-	r = nodeid_hash(nodeid);
-
-	hlist_for_each_entry(con, h, &connection_hash[r], list) {
+	hash_for_each_possible(connection_hash, con, h, list, nodeid)
 		if (con->nodeid == nodeid)
 			return con;
-	}
 	return NULL;
 }
 
@@ -196,7 +184,6 @@ static struct connection *__find_con(int nodeid)
 static struct connection *__nodeid2con(int nodeid, gfp_t alloc)
 {
 	struct connection *con = NULL;
-	int r;
 
 	con = __find_con(nodeid);
 	if (con || !alloc)
@@ -206,8 +193,7 @@ static struct connection *__nodeid2con(int nodeid, gfp_t alloc)
 	if (!con)
 		return NULL;
 
-	r = nodeid_hash(nodeid);
-	hlist_add_head(&con->list, &connection_hash[r]);
+	hash_add(connection_hash, &con->list, nodeid);
 
 	con->nodeid = nodeid;
 	mutex_init(&con->sock_mutex);
@@ -235,11 +221,8 @@ static void foreach_conn(void (*conn_func)(struct connection *c))
 	struct hlist_node *h, *n;
 	struct connection *con;
 
-	for (i = 0; i < CONN_HASH_SIZE; i++) {
-		hlist_for_each_entry_safe(con, h, n, &connection_hash[i], list){
-			conn_func(con);
-		}
-	}
+	hash_for_each_safe(connection_hash, i, h, n, con, list)
+		conn_func(con);
 }
 
 static struct connection *nodeid2con(int nodeid, gfp_t allocation)
@@ -262,12 +245,10 @@ static struct connection *assoc2con(int assoc_id)
 
 	mutex_lock(&connections_lock);
 
-	for (i = 0 ; i < CONN_HASH_SIZE; i++) {
-		hlist_for_each_entry(con, h, &connection_hash[i], list) {
-			if (con->sctp_assoc == assoc_id) {
-				mutex_unlock(&connections_lock);
-				return con;
-			}
+	hash_for_each(connection_hash, i, h, con, list) {
+		if (con->sctp_assoc == assoc_id) {
+			mutex_unlock(&connections_lock);
+			return con;
 		}
 	}
 	mutex_unlock(&connections_lock);
@@ -1644,7 +1625,7 @@ static void free_conn(struct connection *con)
 	close_connection(con, true);
 	if (con->othercon)
 		kmem_cache_free(con_cache, con->othercon);
-	hlist_del(&con->list);
+	hash_del(&con->list);
 	kmem_cache_free(con_cache, con);
 }
 
@@ -1673,10 +1654,8 @@ int dlm_lowcomms_start(void)
 {
 	int error = -EINVAL;
 	struct connection *con;
-	int i;
 
-	for (i = 0; i < CONN_HASH_SIZE; i++)
-		INIT_HLIST_HEAD(&connection_hash[i]);
+	hash_init(connection_hash);
 
 	init_local();
 	if (!dlm_local_count) {
-- 
1.7.8.6
