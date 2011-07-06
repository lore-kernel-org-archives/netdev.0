From: David Miller <davem@davemloft.net>
Subject: [PATCH v3 1/4] packet: Add helpers to register/unregister
 ->prot_hook
Date: Tue, 05 Jul 2011 20:39:54 -0700 (PDT)
Message-ID: <20110705.203954.1973681312122686509.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: victor@inliniac.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58504 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751968Ab1GFDj7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2011 23:39:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/packet/af_packet.c |  103 +++++++++++++++++++++++++++--------------------
 1 files changed, 59 insertions(+), 44 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 461b16f..bb281bf 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -222,6 +222,55 @@ struct packet_skb_cb {
 
 #define PACKET_SKB_CB(__skb)	((struct packet_skb_cb *)((__skb)->cb))
 
+static inline struct packet_sock *pkt_sk(struct sock *sk)
+{
+	return (struct packet_sock *)sk;
+}
+
+/* register_prot_hook must be invoked with the po->bind_lock held,
+ * or from a context in which asynchronous accesses to the packet
+ * socket is not possible (packet_create()).
+ */
+static void register_prot_hook(struct sock *sk)
+{
+	struct packet_sock *po = pkt_sk(sk);
+	if (!po->running) {
+		dev_add_pack(&po->prot_hook);
+		sock_hold(sk);
+		po->running = 1;
+	}
+}
+
+/* {,__}unregister_prot_hook() must be invoked with the po->bind_lock
+ * held.   If the sync parameter is true, we will temporarily drop
+ * the po->bind_lock and do a synchronize_net to make sure no
+ * asynchronous packet processing paths still refer to the elements
+ * of po->prot_hook.  If the sync parameter is false, it is the
+ * callers responsibility to take care of this.
+ */
+static void __unregister_prot_hook(struct sock *sk, bool sync)
+{
+	struct packet_sock *po = pkt_sk(sk);
+
+	po->running = 0;
+	__dev_remove_pack(&po->prot_hook);
+	__sock_put(sk);
+
+	if (sync) {
+		spin_unlock(&po->bind_lock);
+		synchronize_net();
+		spin_lock(&po->bind_lock);
+	}
+}
+
+static void unregister_prot_hook(struct sock *sk, bool sync)
+{
+	struct packet_sock *po = pkt_sk(sk);
+
+	if (po->running)
+		__unregister_prot_hook(sk, sync);
+}
+
 static inline __pure struct page *pgv_to_page(void *addr)
 {
 	if (is_vmalloc_addr(addr))
@@ -324,11 +373,6 @@ static inline void packet_increment_head(struct packet_ring_buffer *buff)
 	buff->head = buff->head != buff->frame_max ? buff->head+1 : 0;
 }
 
-static inline struct packet_sock *pkt_sk(struct sock *sk)
-{
-	return (struct packet_sock *)sk;
-}
-
 static void packet_sock_destruct(struct sock *sk)
 {
 	skb_queue_purge(&sk->sk_error_queue);
@@ -1337,15 +1381,7 @@ static int packet_release(struct socket *sock)
 	spin_unlock_bh(&net->packet.sklist_lock);
 
 	spin_lock(&po->bind_lock);
-	if (po->running) {
-		/*
-		 * Remove from protocol table
-		 */
-		po->running = 0;
-		po->num = 0;
-		__dev_remove_pack(&po->prot_hook);
-		__sock_put(sk);
-	}
+	unregister_prot_hook(sk, false);
 	if (po->prot_hook.dev) {
 		dev_put(po->prot_hook.dev);
 		po->prot_hook.dev = NULL;
@@ -1392,15 +1428,7 @@ static int packet_do_bind(struct sock *sk, struct net_device *dev, __be16 protoc
 	lock_sock(sk);
 
 	spin_lock(&po->bind_lock);
-	if (po->running) {
-		__sock_put(sk);
-		po->running = 0;
-		po->num = 0;
-		spin_unlock(&po->bind_lock);
-		dev_remove_pack(&po->prot_hook);
-		spin_lock(&po->bind_lock);
-	}
-
+	unregister_prot_hook(sk, true);
 	po->num = protocol;
 	po->prot_hook.type = protocol;
 	if (po->prot_hook.dev)
@@ -1413,9 +1441,7 @@ static int packet_do_bind(struct sock *sk, struct net_device *dev, __be16 protoc
 		goto out_unlock;
 
 	if (!dev || (dev->flags & IFF_UP)) {
-		dev_add_pack(&po->prot_hook);
-		sock_hold(sk);
-		po->running = 1;
+		register_prot_hook(sk);
 	} else {
 		sk->sk_err = ENETDOWN;
 		if (!sock_flag(sk, SOCK_DEAD))
@@ -1542,9 +1568,7 @@ static int packet_create(struct net *net, struct socket *sock, int protocol,
 
 	if (proto) {
 		po->prot_hook.type = proto;
-		dev_add_pack(&po->prot_hook);
-		sock_hold(sk);
-		po->running = 1;
+		register_prot_hook(sk);
 	}
 
 	spin_lock_bh(&net->packet.sklist_lock);
@@ -2240,9 +2264,7 @@ static int packet_notifier(struct notifier_block *this, unsigned long msg, void
 			if (dev->ifindex == po->ifindex) {
 				spin_lock(&po->bind_lock);
 				if (po->running) {
-					__dev_remove_pack(&po->prot_hook);
-					__sock_put(sk);
-					po->running = 0;
+					__unregister_prot_hook(sk, false);
 					sk->sk_err = ENETDOWN;
 					if (!sock_flag(sk, SOCK_DEAD))
 						sk->sk_error_report(sk);
@@ -2259,11 +2281,8 @@ static int packet_notifier(struct notifier_block *this, unsigned long msg, void
 		case NETDEV_UP:
 			if (dev->ifindex == po->ifindex) {
 				spin_lock(&po->bind_lock);
-				if (po->num && !po->running) {
-					dev_add_pack(&po->prot_hook);
-					sock_hold(sk);
-					po->running = 1;
-				}
+				if (po->num)
+					register_prot_hook(sk);
 				spin_unlock(&po->bind_lock);
 			}
 			break;
@@ -2530,10 +2549,8 @@ static int packet_set_ring(struct sock *sk, struct tpacket_req *req,
 	was_running = po->running;
 	num = po->num;
 	if (was_running) {
-		__dev_remove_pack(&po->prot_hook);
 		po->num = 0;
-		po->running = 0;
-		__sock_put(sk);
+		__unregister_prot_hook(sk, false);
 	}
 	spin_unlock(&po->bind_lock);
 
@@ -2564,11 +2581,9 @@ static int packet_set_ring(struct sock *sk, struct tpacket_req *req,
 	mutex_unlock(&po->pg_vec_lock);
 
 	spin_lock(&po->bind_lock);
-	if (was_running && !po->running) {
-		sock_hold(sk);
-		po->running = 1;
+	if (was_running) {
 		po->num = num;
-		dev_add_pack(&po->prot_hook);
+		register_prot_hook(sk);
 	}
 	spin_unlock(&po->bind_lock);
 
-- 
1.7.5.4

