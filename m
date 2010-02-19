From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] packet: convert socket list to RCU (v3)
Date: Fri, 19 Feb 2010 14:23:59 -0800
Message-ID: <20100219142359.467b9440@nehalam>
References: <20100219215913.819285957@vyatta.com>
	<20100219220111.772997037@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Alexander Viro <viro@zeniv.linux.org.uk>,
	Andrew Morton <akpm@linux-foundation.org>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Peter Oberparleiter <oberpar@linux.vnet.ibm.com>,
	Miklos Szeredi <mszeredi@suse.cz>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jpirko@redhat.com>, Jiri Olsa <jolsa@redhat.com>,
	Ingo Molnar <mingo@elte.hu>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Jamal Hadi Salim <hadi@cyberus.ca>,
	Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:35721 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754976Ab0BSWYV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Feb 2010 17:24:21 -0500
In-Reply-To: <20100219220111.772997037@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert AF_PACKET to use RCU, eliminating one more reader/writer lock.

There is no need for a real sk_del_node_init_rcu(), because sk_del_node_init
is doing the equivalent thing to hlst_del_init_rcu already; but added
some comments to try and make that obvious.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
v2 - > v3: Need to not call remove_packet with lock held.

 include/net/netns/packet.h |    4 ++--
 include/net/sock.h         |   10 ++++++++++
 net/packet/af_packet.c     |   42 ++++++++++++++++++++----------------------
 3 files changed, 32 insertions(+), 24 deletions(-)

--- a/include/net/netns/packet.h	2010-02-19 13:57:59.990116946 -0800
+++ b/include/net/netns/packet.h	2010-02-19 13:58:48.026119562 -0800
@@ -4,11 +4,11 @@
 #ifndef __NETNS_PACKET_H__
 #define __NETNS_PACKET_H__
 
-#include <linux/list.h>
+#include <linux/rculist.h>
 #include <linux/spinlock.h>
 
 struct netns_packet {
-	rwlock_t		sklist_lock;
+	spinlock_t		sklist_lock;
 	struct hlist_head	sklist;
 };
 
--- a/net/packet/af_packet.c	2010-02-19 13:57:59.978117421 -0800
+++ b/net/packet/af_packet.c	2010-02-19 14:14:56.893492702 -0800
@@ -1262,24 +1262,22 @@ static int packet_release(struct socket 
 	net = sock_net(sk);
 	po = pkt_sk(sk);
 
-	write_lock_bh(&net->packet.sklist_lock);
-	sk_del_node_init(sk);
+	spin_lock_bh(&net->packet.sklist_lock);
+	sk_del_node_init_rcu(sk);
 	sock_prot_inuse_add(net, sk->sk_prot, -1);
-	write_unlock_bh(&net->packet.sklist_lock);
-
-	/*
-	 *	Unhook packet receive handler.
-	 */
+	spin_unlock_bh(&net->packet.sklist_lock);
 
+	spin_lock(&po->bind_lock);
 	if (po->running) {
 		/*
-		 *	Remove the protocol hook
+		 * Remove from protocol table
 		 */
-		dev_remove_pack(&po->prot_hook);
 		po->running = 0;
 		po->num = 0;
+		__dev_remove_pack(&po->prot_hook);
 		__sock_put(sk);
 	}
+	spin_unlock(&po->bind_lock);
 
 	packet_flush_mclist(sk);
 
@@ -1291,10 +1289,10 @@ static int packet_release(struct socket 
 	if (po->tx_ring.pg_vec)
 		packet_set_ring(sk, &req, 1, 1);
 
+	synchronize_net();
 	/*
 	 *	Now the socket is dead. No more input will appear.
 	 */
-
 	sock_orphan(sk);
 	sock->sk = NULL;
 
@@ -1478,10 +1476,11 @@ static int packet_create(struct net *net
 		po->running = 1;
 	}
 
-	write_lock_bh(&net->packet.sklist_lock);
-	sk_add_node(sk, &net->packet.sklist);
+	spin_lock_bh(&net->packet.sklist_lock);
+	sk_add_node_rcu(sk, &net->packet.sklist);
 	sock_prot_inuse_add(net, &packet_proto, 1);
-	write_unlock_bh(&net->packet.sklist_lock);
+	spin_unlock_bh(&net->packet.sklist_lock);
+
 	return 0;
 out:
 	return err;
@@ -2075,8 +2074,8 @@ static int packet_notifier(struct notifi
 	struct net_device *dev = data;
 	struct net *net = dev_net(dev);
 
-	read_lock(&net->packet.sklist_lock);
-	sk_for_each(sk, node, &net->packet.sklist) {
+	rcu_read_lock();
+	sk_for_each_rcu(sk, node, &net->packet.sklist) {
 		struct packet_sock *po = pkt_sk(sk);
 
 		switch (msg) {
@@ -2104,18 +2103,19 @@ static int packet_notifier(struct notifi
 			}
 			break;
 		case NETDEV_UP:
-			spin_lock(&po->bind_lock);
-			if (dev->ifindex == po->ifindex && po->num &&
-			    !po->running) {
-				dev_add_pack(&po->prot_hook);
-				sock_hold(sk);
-				po->running = 1;
+			if (dev->ifindex == po->ifindex) {
+				spin_lock(&po->bind_lock);
+				if (po->num && !po->running) {
+					dev_add_pack(&po->prot_hook);
+					sock_hold(sk);
+					po->running = 1;
+				}
+				spin_unlock(&po->bind_lock);
 			}
-			spin_unlock(&po->bind_lock);
 			break;
 		}
 	}
-	read_unlock(&net->packet.sklist_lock);
+	rcu_read_unlock();
 	return NOTIFY_DONE;
 }
 
@@ -2512,24 +2512,24 @@ static struct notifier_block packet_netd
 #ifdef CONFIG_PROC_FS
 
 static void *packet_seq_start(struct seq_file *seq, loff_t *pos)
-	__acquires(seq_file_net(seq)->packet.sklist_lock)
+	__acquires(RCU)
 {
 	struct net *net = seq_file_net(seq);
-	read_lock(&net->packet.sklist_lock);
-	return seq_hlist_start_head(&net->packet.sklist, *pos);
+
+	rcu_read_lock();
+	return seq_hlist_start_head_rcu(&net->packet.sklist, *pos);
 }
 
 static void *packet_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 {
 	struct net *net = seq_file_net(seq);
-	return seq_hlist_next(v, &net->packet.sklist, pos);
+	return seq_hlist_next_rcu(v, &net->packet.sklist, pos);
 }
 
 static void packet_seq_stop(struct seq_file *seq, void *v)
-	__releases(seq_file_net(seq)->packet.sklist_lock)
+	__releases(RCU)
 {
-	struct net *net = seq_file_net(seq);
-	read_unlock(&net->packet.sklist_lock);
+	rcu_read_unlock();
 }
 
 static int packet_seq_show(struct seq_file *seq, void *v)
@@ -2581,7 +2581,7 @@ static const struct file_operations pack
 
 static int __net_init packet_net_init(struct net *net)
 {
-	rwlock_init(&net->packet.sklist_lock);
+	spin_lock_init(&net->packet.sklist_lock);
 	INIT_HLIST_HEAD(&net->packet.sklist);
 
 	if (!proc_net_fops_create(net, "packet", 0, &packet_seq_fops))
--- a/include/net/sock.h	2010-02-19 13:58:00.006118906 -0800
+++ b/include/net/sock.h	2010-02-19 13:58:48.030119401 -0800
@@ -381,6 +381,7 @@ static __inline__ void __sk_del_node(str
 	__hlist_del(&sk->sk_node);
 }
 
+/* NB: equivalent to hlist_del_init_rcu */
 static __inline__ int __sk_del_node_init(struct sock *sk)
 {
 	if (sk_hashed(sk)) {
@@ -421,6 +422,7 @@ static __inline__ int sk_del_node_init(s
 	}
 	return rc;
 }
+#define sk_del_node_init_rcu(sk)	sk_del_node_init(sk)
 
 static __inline__ int __sk_nulls_del_node_init_rcu(struct sock *sk)
 {
@@ -454,6 +456,12 @@ static __inline__ void sk_add_node(struc
 	__sk_add_node(sk, list);
 }
 
+static __inline__ void sk_add_node_rcu(struct sock *sk, struct hlist_head *list)
+{
+	sock_hold(sk);
+	hlist_add_head_rcu(&sk->sk_node, list);
+}
+
 static __inline__ void __sk_nulls_add_node_rcu(struct sock *sk, struct hlist_nulls_head *list)
 {
 	hlist_nulls_add_head_rcu(&sk->sk_nulls_node, list);
@@ -478,6 +486,8 @@ static __inline__ void sk_add_bind_node(
 
 #define sk_for_each(__sk, node, list) \
 	hlist_for_each_entry(__sk, node, list, sk_node)
+#define sk_for_each_rcu(__sk, node, list) \
+	hlist_for_each_entry_rcu(__sk, node, list, sk_node)
 #define sk_nulls_for_each(__sk, node, list) \
 	hlist_nulls_for_each_entry(__sk, node, list, sk_nulls_node)
 #define sk_nulls_for_each_rcu(__sk, node, list) \
