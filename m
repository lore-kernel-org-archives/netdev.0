From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH net-next] packet: Protect packet sk list with mutex (v2)
Date: Tue, 21 Aug 2012 15:06:47 +0400
Message-ID: <50336BC7.7030209@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:36166 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756872Ab2HULG6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Aug 2012 07:06:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change since v1:

* Fixed inuse counters access spotted by Eric

In patch eea68e2f (packet: Report socket mclist info via diag module) I've
introduced a "scheduling in atomic" problem in packet diag module -- the
socket list is traversed under rcu_read_lock() while performed under it sk
mclist access requires rtnl lock (i.e. -- mutex) to be taken.

[152363.820563] BUG: scheduling while atomic: crtools/12517/0x10000002
[152363.820573] 4 locks held by crtools/12517:
[152363.820581]  #0:  (sock_diag_mutex){+.+.+.}, at: [<ffffffff81a2dcb5>] sock_diag_rcv+0x1f/0x3e
[152363.820613]  #1:  (sock_diag_table_mutex){+.+.+.}, at: [<ffffffff81a2de70>] sock_diag_rcv_msg+0xdb/0x11a
[152363.820644]  #2:  (nlk->cb_mutex){+.+.+.}, at: [<ffffffff81a67d01>] netlink_dump+0x23/0x1ab
[152363.820693]  #3:  (rcu_read_lock){.+.+..}, at: [<ffffffff81b6a049>] packet_diag_dump+0x0/0x1af

Similar thing was then re-introduced by further packet diag patches (fanount 
mutex and pgvec mutex for rings) :(

Apart from being terribly sorry for the above, I propose to change the packet
sk list protection from spinlock to mutex. This lock currently protects two
modifications:

* sklist
* prot inuse counters

The sklist modifications can be just reprotected with mutex since they already
occur in a sleeping context. The inuse counters modifications are trickier -- the
__this_cpu_-s are used inside, thus requiring the caller to handle the potential
issues with contexts himself. Since packet sockets' counters are modified in two 
places only (packet_create and packet_release) we only need to protect the context 
from being preempted. BH disabling is not required in this case.

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
index 226b2cd..79bc69c 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -2308,10 +2308,13 @@ static int packet_release(struct socket *sock)
 	net = sock_net(sk);
 	po = pkt_sk(sk);
 
-	spin_lock_bh(&net->packet.sklist_lock);
+	mutex_lock(&net->packet.sklist_lock);
 	sk_del_node_init_rcu(sk);
+	mutex_unlock(&net->packet.sklist_lock);
+
+	preempt_disable();
 	sock_prot_inuse_add(net, sk->sk_prot, -1);
-	spin_unlock_bh(&net->packet.sklist_lock);
+	preempt_enable();
 
 	spin_lock(&po->bind_lock);
 	unregister_prot_hook(sk, false);
@@ -2510,10 +2513,13 @@ static int packet_create(struct net *net, struct socket *sock, int protocol,
 		register_prot_hook(sk);
 	}
 
-	spin_lock_bh(&net->packet.sklist_lock);
+	mutex_lock(&net->packet.sklist_lock);
 	sk_add_node_rcu(sk, &net->packet.sklist);
+	mutex_unlock(&net->packet.sklist_lock);
+
+	preempt_disable();
 	sock_prot_inuse_add(net, &packet_proto, 1);
-	spin_unlock_bh(&net->packet.sklist_lock);
+	preempt_enable();
 
 	return 0;
 out:
@@ -3766,7 +3772,7 @@ static const struct file_operations packet_seq_fops = {
 
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
