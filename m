From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 11/12] tipc: save sock structure pointer instead of void pointer to tipc_port
Date: Thu, 30 May 2013 15:36:16 -0400
Message-ID: <1369942577-39563-12-git-send-email-paul.gortmaker@windriver.com>
References: <1369942577-39563-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Jon Maloy <jon.maloy@ericsson.com>,
	Ying Xue <ying.xue@windriver.com>,
	Erik Hugne <erik.hugne@ericsson.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:59180 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932477Ab3E3Tgn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 May 2013 15:36:43 -0400
In-Reply-To: <1369942577-39563-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ying Xue <ying.xue@windriver.com>

Directly save sock structure pointer instead of void pointer to avoid
unnecessary cast conversions.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/port.c   | 4 ++--
 net/tipc/port.h   | 6 +++---
 net/tipc/socket.c | 4 ++--
 3 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/net/tipc/port.c b/net/tipc/port.c
index 84b2a57..0bb185a 100644
--- a/net/tipc/port.c
+++ b/net/tipc/port.c
@@ -206,7 +206,7 @@ exit:
  *
  * Returns pointer to (locked) TIPC port, or NULL if unable to create it
  */
-struct tipc_port *tipc_createport(void *usr_handle,
+struct tipc_port *tipc_createport(struct sock *sk,
 			u32 (*dispatcher)(struct tipc_port *, struct sk_buff *),
 			void (*wakeup)(struct tipc_port *),
 			const u32 importance)
@@ -227,7 +227,7 @@ struct tipc_port *tipc_createport(void *usr_handle,
 		return NULL;
 	}
 
-	p_ptr->usr_handle = usr_handle;
+	p_ptr->sk = sk;
 	p_ptr->max_pkt = MAX_PKT_DEFAULT;
 	p_ptr->ref = ref;
 	INIT_LIST_HEAD(&p_ptr->wait_list);
diff --git a/net/tipc/port.h b/net/tipc/port.h
index 6579e47..ef0df6a 100644
--- a/net/tipc/port.h
+++ b/net/tipc/port.h
@@ -46,7 +46,7 @@
 
 /**
  * struct tipc_port - TIPC port structure
- * @usr_handle: pointer to additional user-defined information about port
+ * @sk: pointer to socket handle
  * @lock: pointer to spinlock for controlling access to port
  * @connected: non-zero if port is currently connected to a peer port
  * @conn_type: TIPC type used when connection was established
@@ -72,7 +72,7 @@
  * @subscription: "node down" subscription used to terminate failed connections
  */
 struct tipc_port {
-	void *usr_handle;
+	struct sock *sk;
 	spinlock_t *lock;
 	int connected;
 	u32 conn_type;
@@ -104,7 +104,7 @@ struct tipc_port_list;
 /*
  * TIPC port manipulation routines
  */
-struct tipc_port *tipc_createport(void *usr_handle,
+struct tipc_port *tipc_createport(struct sock *sk,
 		u32 (*dispatcher)(struct tipc_port *, struct sk_buff *),
 		void (*wakeup)(struct tipc_port *), const u32 importance);
 
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 258e98d..8c135c5 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -1407,7 +1407,7 @@ static int backlog_rcv(struct sock *sk, struct sk_buff *buf)
  */
 static u32 dispatch(struct tipc_port *tport, struct sk_buff *buf)
 {
-	struct sock *sk = (struct sock *)tport->usr_handle;
+	struct sock *sk = tport->sk;
 	u32 res;
 
 	/*
@@ -1438,7 +1438,7 @@ static u32 dispatch(struct tipc_port *tport, struct sk_buff *buf)
  */
 static void wakeupdispatch(struct tipc_port *tport)
 {
-	struct sock *sk = (struct sock *)tport->usr_handle;
+	struct sock *sk = tport->sk;
 
 	sk->sk_write_space(sk);
 }
-- 
1.8.1.2
