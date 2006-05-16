From: Kelly Daly <kelly@au1.ibm.com>
Subject: Re: [PATCH 1/3] Rough VJ Channel Implementation - vj_core.patch
Date: Tue, 16 May 2006 11:02:29 +1000
Message-ID: <200605161102.29472.kelly@au.ibm.com>
References: <200604261147.34221.kelly@au.ibm.com> <20060504.161148.44973535.davem@davemloft.net> <200605051248.42662.kelly@au.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausmtp06.au.ibm.com ([202.81.18.155]:49895 "EHLO
	ausmtp06.au.ibm.com") by vger.kernel.org with ESMTP
	id S1750905AbWEPBDN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 May 2006 21:03:13 -0400
Received: from sd0208e0.au.ibm.com (d23rh904.au.ibm.com [202.81.18.202])
	by ausmtp06.au.ibm.com (8.13.6/8.13.6) with ESMTP id k4G14p1X2527270
	for <netdev@vger.kernel.org>; Tue, 16 May 2006 11:05:06 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.250.237])
	by sd0208e0.au.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id k4G15fI2170648
	for <netdev@vger.kernel.org>; Tue, 16 May 2006 11:05:52 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11/8.13.3) with ESMTP id k4G12LGs017743
	for <netdev@vger.kernel.org>; Tue, 16 May 2006 11:02:21 +1000
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <200605051248.42662.kelly@au.ibm.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 05 May 2006 12:48, Kelly Daly wrote:
> done!  I will continue with implementation of default netchannel for now.

___________________


diff -urp davem_orig/include/net/inet_hashtables.h kelly/include/net/inet_hashtables.h
--- davem_orig/include/net/inet_hashtables.h	2006-04-27 00:08:32.000000000 +1000
+++ kelly/include/net/inet_hashtables.h	2006-05-05 12:45:44.000000000 +1000
@@ -418,4 +418,7 @@ static inline struct sock *inet_lookup(s
 
 extern int inet_hash_connect(struct inet_timewait_death_row *death_row,
 			     struct sock *sk);
+extern void inet_hash_register(u8 proto, struct inet_hashinfo *hashinfo);
+extern struct sock *inet_lookup_proto(u8 protocol, u32 saddr, u16 sport, u32 daddr, u16 dport, int ifindex);
+
 #endif /* _INET_HASHTABLES_H */
diff -urp davem_orig/include/net/sock.h kelly/include/net/sock.h
--- davem_orig/include/net/sock.h	2006-05-02 13:42:10.000000000 +1000
+++ kelly/include/net/sock.h	2006-05-04 14:28:59.000000000 +1000
@@ -196,6 +196,7 @@ struct sock {
 	unsigned short		sk_type;
 	int			sk_rcvbuf;
 	socket_lock_t		sk_lock;
+	struct netchannel	*sk_channel;
 	wait_queue_head_t	*sk_sleep;
 	struct dst_entry	*sk_dst_cache;
 	struct xfrm_policy	*sk_policy[2];
diff -urp davem_orig/net/core/dev.c kelly/net/core/dev.c
--- davem_orig/net/core/dev.c	2006-04-27 15:49:27.000000000 +1000
+++ kelly/net/core/dev.c	2006-05-15 12:21:41.000000000 +1000
@@ -113,9 +113,11 @@
 #include <linux/delay.h>
 #include <linux/wireless.h>
 #include <linux/netchannel.h>
+#include <linux/kthread.h>
 #include <net/iw_handler.h>
 #include <asm/current.h>
 #include <linux/audit.h>
+#include <net/inet_hashtables.h>
 
 /*
  *	The list of packet types we will receive (as opposed to discard)
@@ -190,6 +192,10 @@ static inline struct hlist_head *dev_ind
 	return &dev_index_head[ifindex & ((1<<NETDEV_HASHBITS)-1)];
 }
 
+/*      default netchannel shtuff */
+static struct netchannel default_netchannel;
+static wait_queue_head_t default_netchannel_wq;
+
 /*
  *	Our notifier list
  */
@@ -1854,6 +1860,35 @@ softnet_break:
 	goto out;
 }
 
+static void default_netchannel_wake(struct netchannel *np)
+{
+	wake_up(&default_netchannel_wq);
+}
+
+/* handles default chan buffers that nobody else wants */
+static int default_netchannel_thread(void *unused)
+{
+	wait_queue_t wait;
+	struct netchannel_buftrailer *bp;
+	struct sk_buff *skbp;
+
+	wait.private = current;
+	wait.func = default_wake_function;;
+	INIT_LIST_HEAD(&wait.task_list);
+
+	add_wait_queue(&default_netchannel_wq, &wait);
+	set_current_state(TASK_UNINTERRUPTIBLE);
+	while (!kthread_should_stop()) {
+		bp = __netchannel_dequeue(&default_netchannel);
+		skbp = skb_netchan_graft(bp, GFP_ATOMIC);
+		netif_receive_skb(skbp);
+	}
+	remove_wait_queue(&default_netchannel_wq, &wait);
+	__set_current_state(TASK_RUNNING);
+	return 0;
+}
+
 void netchannel_init(struct netchannel *np,
 		     void (*callb)(struct netchannel *), void *callb_data)
 {
@@ -1907,6 +1942,34 @@ struct netchannel_buftrailer *__netchann
 }
 EXPORT_SYMBOL_GPL(__netchannel_dequeue);
 
+
+/* Find the channel for a packet, or return default channel. */
+struct netchannel *find_netchannel(const struct netchannel_buftrailer *np)
+{
+	struct sock *sk = NULL;
+	unsigned long dlen = np->netchan_buf_len - np->netchan_buf_offset;
+	void *data = (void *)np - dlen;
+
+	switch (np->netchan_buf_proto) {
+	case __constant_htons(ETH_P_IP): {
+		struct iphdr *ip = data;
+		int iphl = ip->ihl * 4;
+
+		if (dlen >= (iphl + 4) && iphl == sizeof(struct iphdr)) {
+			u16 *ports = (u16 *)(ip + 1);
+			sk = inet_lookup_proto(ip->protocol,
+					       ip->saddr, ports[0],
+					       ip->daddr, ports[1],
+					       np->netchan_buf_dev->ifindex);
+			break;
+		}
+	}
+	}
+	if (sk && sk->sk_channel)
+		return sk->sk_channel;
+	return &default_netchannel;
+}
+
 static gifconf_func_t * gifconf_list [NPROTO];
 
 /**
@@ -3375,6 +3438,7 @@ static int dev_cpu_callback(struct notif
 static int __init net_dev_init(void)
 {
 	int i, rc = -ENOMEM;
+	struct task_struct *netchan_thread;
 
 	BUG_ON(!dev_boot_phase);
 
@@ -3421,7 +3485,12 @@ static int __init net_dev_init(void)
 	hotcpu_notifier(dev_cpu_callback, 0);
 	dst_init();
 	dev_mcast_init();
-	rc = 0;
+
+	netchannel_init(&default_netchannel, default_netchannel_wake, NULL);
+	netchan_thread = kthread_run(default_netchannel_thread, NULL, "kvj_def");
+
+	if (!IS_ERR(netchan_thread)) 	/* kthread_run returned thread */
+		rc = 0;
 out:
 	return rc;
 }
diff -urp davem_orig/net/ipv4/inet_hashtables.c kelly/net/ipv4/inet_hashtables.c
--- davem_orig/net/ipv4/inet_hashtables.c	2006-04-27 00:08:33.000000000 +1000
+++ kelly/net/ipv4/inet_hashtables.c	2006-05-05 12:45:44.000000000 +1000
@@ -337,3 +337,25 @@ out:
 }
 
 EXPORT_SYMBOL_GPL(inet_hash_connect);
+
+static struct inet_hashinfo *inet_hashes[256];
+
+void inet_hash_register(u8 proto, struct inet_hashinfo *hashinfo)
+{
+	BUG_ON(inet_hashes[proto]);
+	inet_hashes[proto] = hashinfo;
+}
+EXPORT_SYMBOL(inet_hash_register);
+
+struct sock *inet_lookup_proto(u8 protocol, u32 saddr, u16 sport, u32 daddr, u16 dport, int ifindex)
+{
+	struct sock *sk = NULL;
+	if (inet_hashes[protocol]) {
+		sk = inet_lookup(inet_hashes[protocol], 
+				 saddr, sport,
+				 daddr, dport,
+				 ifindex);
+	}
+	return sk;
+}
+EXPORT_SYMBOL(inet_lookup_proto);
diff -urp davem_orig/net/ipv4/tcp.c kelly/net/ipv4/tcp.c
--- davem_orig/net/ipv4/tcp.c	2006-04-27 00:08:33.000000000 +1000
+++ kelly/net/ipv4/tcp.c	2006-05-05 11:29:18.000000000 +1000
@@ -2173,6 +2173,7 @@ void __init tcp_init(void)
 	       tcp_hashinfo.ehash_size << 1, tcp_hashinfo.bhash_size);
 
 	tcp_register_congestion_control(&tcp_reno);
+	inet_hash_register(IPPROTO_TCP, &tcp_hashinfo);
 }
 
 EXPORT_SYMBOL(tcp_close);
