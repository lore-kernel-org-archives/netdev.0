From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH net-next] packet: Protect packet sk list with mutex
Date: Mon, 20 Aug 2012 18:50:36 +0400
Message-ID: <50324EBC.9060804@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:32806 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756782Ab2HTOup (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Aug 2012 10:50:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In patch eea68e2f (packet: Report socket mclist info via diag module) I've
introduced a "scheduling in atomic" problem in packet diag module -- the
socket list is traversed under rcu_read_lock() while performed under it sk
mclist access requires rtnl lock (i.e. -- mutex) to be taken. Similar thing
was then re-introduced by further packet diag patches (fanount mutex and 
pgvec mutex for rings) :(

Apart from being terribly sorry for the above, I propose to change the
packet sk list protection from spinlock to mutex. This lock currently 
protects only the sklist modifications (that already happen in sleeping 
context) and nothing more.

Am I wrong again and a fine-grained atomic locking is required for
everything that is reported by packet diag instead?

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---

diff --git a/include/net/netns/packet.h b/include/net/netns/packet.h
index cb4e894..4780b08 100644
--- a/include/net/netns/packet.h
+++ b/include/net/netns/packet.h
@@ -8,7 +8,7 @@
 #include <linux/spinlock.h>
 
 struct netns_packet {
-	spinlock_t		sklist_lock;
+	struct mutex		sklist_lock;
 	struct hlist_head	sklist;
 };
 
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 226b2cd..5048672 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -2308,10 +2308,10 @@ static int packet_release(struct socket *sock)
 	net = sock_net(sk);
 	po = pkt_sk(sk);
 
-	spin_lock_bh(&net->packet.sklist_lock);
+	mutex_lock(&net->packet.sklist_lock);
 	sk_del_node_init_rcu(sk);
 	sock_prot_inuse_add(net, sk->sk_prot, -1);
-	spin_unlock_bh(&net->packet.sklist_lock);
+	mutex_unlock(&net->packet.sklist_lock);
 
 	spin_lock(&po->bind_lock);
 	unregister_prot_hook(sk, false);
@@ -2510,10 +2510,10 @@ static int packet_create(struct net *net, struct socket *sock, int protocol,
 		register_prot_hook(sk);
 	}
 
-	spin_lock_bh(&net->packet.sklist_lock);
+	mutex_lock(&net->packet.sklist_lock);
 	sk_add_node_rcu(sk, &net->packet.sklist);
 	sock_prot_inuse_add(net, &packet_proto, 1);
-	spin_unlock_bh(&net->packet.sklist_lock);
+	mutex_unlock(&net->packet.sklist_lock);
 
 	return 0;
 out:
@@ -3766,7 +3766,7 @@ static const struct file_operations packet_seq_fops = {
 
 static int __net_init packet_net_init(struct net *net)
 {
-	spin_lock_init(&net->packet.sklist_lock);
+	mutex_init(&net->packet.sklist_lock);
 	INIT_HLIST_HEAD(&net->packet.sklist);
 
 	if (!proc_net_fops_create(net, "packet", 0, &packet_seq_fops))
diff --git a/net/packet/diag.c b/net/packet/diag.c
index bc33fbe..39bce0d 100644
--- a/net/packet/diag.c
+++ b/net/packet/diag.c
@@ -177,8 +177,8 @@ static int packet_diag_dump(struct sk_buff *skb, struct netlink_callback *cb)
 	net = sock_net(skb->sk);
 	req = nlmsg_data(cb->nlh);
 
-	rcu_read_lock();
-	sk_for_each_rcu(sk, node, &net->packet.sklist) {
+	mutex_lock(&net->packet.sklist_lock);
+	sk_for_each(sk, node, &net->packet.sklist) {
 		if (!net_eq(sock_net(sk), net))
 			continue;
 		if (num < s_num)
@@ -192,7 +192,7 @@ next:
 		num++;
 	}
 done:
-	rcu_read_unlock();
+	mutex_unlock(&net->packet.sklist_lock);
 	cb->args[0] = num;
 
 	return skb->len;
