From: David Howells <dhowells@redhat.com>
Subject: [PATCH net-next 3/7] rxrpc: Convert rxrpc_local::services to an
 hlist
Date: Thu, 08 Sep 2016 12:43:49 +0100
Message-ID: <147333502980.5646.17084049639550958084.stgit@warthog.procyon.org.uk>
References: <147333500815.5646.1897433750795776938.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: dhowells@redhat.com, linux-afs@lists.infradead.org,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36732 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S941031AbcIHLnw (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 8 Sep 2016 07:43:52 -0400
In-Reply-To: <147333500815.5646.1897433750795776938.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert the rxrpc_local::services list to an hlist so that it can be
accessed under RCU conditions more readily.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 net/rxrpc/af_rxrpc.c     |   10 +++++-----
 net/rxrpc/ar-internal.h  |    4 ++--
 net/rxrpc/call_accept.c  |    2 +-
 net/rxrpc/local_object.c |    4 ++--
 net/rxrpc/security.c     |    2 +-
 5 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/net/rxrpc/af_rxrpc.c b/net/rxrpc/af_rxrpc.c
index 77a132abf140..f13cca1e973e 100644
--- a/net/rxrpc/af_rxrpc.c
+++ b/net/rxrpc/af_rxrpc.c
@@ -156,13 +156,13 @@ static int rxrpc_bind(struct socket *sock, struct sockaddr *saddr, int len)
 
 	if (rx->srx.srx_service) {
 		write_lock_bh(&local->services_lock);
-		list_for_each_entry(prx, &local->services, listen_link) {
+		hlist_for_each_entry(prx, &local->services, listen_link) {
 			if (prx->srx.srx_service == rx->srx.srx_service)
 				goto service_in_use;
 		}
 
 		rx->local = local;
-		list_add_tail(&rx->listen_link, &local->services);
+		hlist_add_head_rcu(&rx->listen_link, &local->services);
 		write_unlock_bh(&local->services_lock);
 
 		rx->sk.sk_state = RXRPC_SERVER_BOUND;
@@ -567,7 +567,7 @@ static int rxrpc_create(struct net *net, struct socket *sock, int protocol,
 	rx->family = protocol;
 	rx->calls = RB_ROOT;
 
-	INIT_LIST_HEAD(&rx->listen_link);
+	INIT_HLIST_NODE(&rx->listen_link);
 	INIT_LIST_HEAD(&rx->secureq);
 	INIT_LIST_HEAD(&rx->acceptq);
 	rwlock_init(&rx->call_lock);
@@ -615,9 +615,9 @@ static int rxrpc_release_sock(struct sock *sk)
 
 	ASSERTCMP(rx->listen_link.next, !=, LIST_POISON1);
 
-	if (!list_empty(&rx->listen_link)) {
+	if (!hlist_unhashed(&rx->listen_link)) {
 		write_lock_bh(&rx->local->services_lock);
-		list_del(&rx->listen_link);
+		hlist_del_rcu(&rx->listen_link);
 		write_unlock_bh(&rx->local->services_lock);
 	}
 
diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index 6dc3a59ce0f2..fd438dc93ee9 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -71,7 +71,7 @@ struct rxrpc_sock {
 	struct sock		sk;
 	rxrpc_notify_new_call_t	notify_new_call; /* Func to notify of new call */
 	struct rxrpc_local	*local;		/* local endpoint */
-	struct list_head	listen_link;	/* link in the local endpoint's listen list */
+	struct hlist_node	listen_link;	/* link in the local endpoint's listen list */
 	struct list_head	secureq;	/* calls awaiting connection security clearance */
 	struct list_head	acceptq;	/* calls awaiting acceptance */
 	struct key		*key;		/* security for this socket */
@@ -186,7 +186,7 @@ struct rxrpc_local {
 	struct list_head	link;
 	struct socket		*socket;	/* my UDP socket */
 	struct work_struct	processor;
-	struct list_head	services;	/* services listening on this endpoint */
+	struct hlist_head	services;	/* services listening on this endpoint */
 	struct rw_semaphore	defrag_sem;	/* control re-enablement of IP DF bit */
 	struct sk_buff_head	accept_queue;	/* incoming calls awaiting acceptance */
 	struct sk_buff_head	reject_queue;	/* packets awaiting rejection */
diff --git a/net/rxrpc/call_accept.c b/net/rxrpc/call_accept.c
index 879a964de80c..4c71efcf82ed 100644
--- a/net/rxrpc/call_accept.c
+++ b/net/rxrpc/call_accept.c
@@ -217,7 +217,7 @@ void rxrpc_accept_incoming_calls(struct rxrpc_local *local)
 
 	/* get the socket providing the service */
 	read_lock_bh(&local->services_lock);
-	list_for_each_entry(rx, &local->services, listen_link) {
+	hlist_for_each_entry(rx, &local->services, listen_link) {
 		if (rx->srx.srx_service == sp->hdr.serviceId &&
 		    rx->sk.sk_state != RXRPC_CLOSE)
 			goto found_service;
diff --git a/net/rxrpc/local_object.c b/net/rxrpc/local_object.c
index a753796fbe8f..610916f4ae34 100644
--- a/net/rxrpc/local_object.c
+++ b/net/rxrpc/local_object.c
@@ -75,7 +75,7 @@ static struct rxrpc_local *rxrpc_alloc_local(const struct sockaddr_rxrpc *srx)
 		atomic_set(&local->usage, 1);
 		INIT_LIST_HEAD(&local->link);
 		INIT_WORK(&local->processor, rxrpc_local_processor);
-		INIT_LIST_HEAD(&local->services);
+		INIT_HLIST_HEAD(&local->services);
 		init_rwsem(&local->defrag_sem);
 		skb_queue_head_init(&local->accept_queue);
 		skb_queue_head_init(&local->reject_queue);
@@ -296,7 +296,7 @@ static void rxrpc_local_destroyer(struct rxrpc_local *local)
 	mutex_unlock(&rxrpc_local_mutex);
 
 	ASSERT(RB_EMPTY_ROOT(&local->client_conns));
-	ASSERT(list_empty(&local->services));
+	ASSERT(hlist_empty(&local->services));
 
 	if (socket) {
 		local->socket = NULL;
diff --git a/net/rxrpc/security.c b/net/rxrpc/security.c
index 814d285ff802..5d79d5a9c944 100644
--- a/net/rxrpc/security.c
+++ b/net/rxrpc/security.c
@@ -131,7 +131,7 @@ int rxrpc_init_server_conn_security(struct rxrpc_connection *conn)
 
 	/* find the service */
 	read_lock_bh(&local->services_lock);
-	list_for_each_entry(rx, &local->services, listen_link) {
+	hlist_for_each_entry(rx, &local->services, listen_link) {
 		if (rx->srx.srx_service == conn->params.service_id)
 			goto found_service;
 	}
