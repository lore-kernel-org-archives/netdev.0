From: Kelly Daly <kelly@au1.ibm.com>
Subject: [PATCH] Netchannel: default, find, add to socket
Date: Tue, 11 Jul 2006 15:39:25 +1000
Message-ID: <200607111539.25458.kelly@au.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausmtp06.au.ibm.com ([202.81.18.155]:9385 "EHLO
	ausmtp06.au.ibm.com") by vger.kernel.org with ESMTP id S932378AbWGKFjw
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Jul 2006 01:39:52 -0400
Received: from sd0208e0.au.ibm.com (d23rh904.au.ibm.com [202.81.18.202])
	by ausmtp06.au.ibm.com (8.13.6/8.13.6) with ESMTP id k6B5fXRB8486942
	for <netdev@vger.kernel.org>; Tue, 11 Jul 2006 15:41:33 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.250.242])
	by sd0208e0.au.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id k6B5h7gN234192
	for <netdev@vger.kernel.org>; Tue, 11 Jul 2006 15:43:07 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k6B5dhHj018324
	for <netdev@vger.kernel.org>; Tue, 11 Jul 2006 15:39:43 +1000
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Implement finding of correct netchannel for buffer, default netchannel and 
attach a netchannel to a socket

Signed-off-by:  Kelly Daly <kelly@au.ibm.com>

---


diff -urp davem/include/linux/netchannel.h 
kelly_new/include/linux/netchannel.h
--- davem/include/linux/netchannel.h	2006-06-16 15:14:15.000000000 +1000
+++ kelly_new/include/linux/netchannel.h	2006-07-10 14:04:54.000000000 +1000
@@ -19,6 +19,7 @@ struct netchannel {
 	void 			(*netchan_callb)(struct netchannel *);
 	void			*netchan_callb_data;
 	unsigned long		netchan_head;
+	wait_queue_head_t	wq;
 };
 
 extern void netchannel_init(struct netchannel *,
@@ -56,6 +57,11 @@ static inline unsigned char *netchan_buf
 	return netchan_buf_base(bp) + bp->netchan_buf_offset;
 }
 
+static inline int netchan_data_len(const struct netchannel_buftrailer *bp)
+{
+	return bp->netchan_buf_len - bp->netchan_buf_offset;
+}
+
 extern int netchannel_enqueue(struct netchannel *, struct 
netchannel_buftrailer *);
 extern struct netchannel_buftrailer *__netchannel_dequeue(struct netchannel 
*);
 static inline struct netchannel_buftrailer *netchannel_dequeue(struct 
netchannel *np)
@@ -65,6 +71,10 @@ static inline struct netchannel_buftrail
 	return __netchannel_dequeue(np);
 }
 
+extern struct netchannel *find_netchannel(const struct netchannel_buftrailer 
*bp);
+extern int sock_add_netchannel(struct sock *sk);
 extern struct sk_buff *skb_netchan_graft(struct netchannel_buftrailer *, 
gfp_t);
 
 #endif /* _LINUX_NETCHANNEL_H */
diff -urp davem/include/net/inet_hashtables.h 
kelly_new/include/net/inet_hashtables.h
--- davem/include/net/inet_hashtables.h	2006-06-16 14:34:20.000000000 +1000
+++ kelly_new/include/net/inet_hashtables.h	2006-06-19 10:42:45.000000000 
+1000
@@ -418,4 +418,7 @@ static inline struct sock *inet_lookup(s
 
 extern int inet_hash_connect(struct inet_timewait_death_row *death_row,
 			     struct sock *sk);
+extern void  inet_hash_register(u8 proto, struct inet_hashinfo *hashinfo);
+extern struct sock *inet_lookup_proto(u8 protocol, u32 saddr, u16 sport, u32 
daddr, u16 dport, int ifindex);
+
 #endif /* _INET_HASHTABLES_H */
diff -urp davem/include/net/sock.h kelly_new/include/net/sock.h
--- davem/include/net/sock.h	2006-06-16 15:14:16.000000000 +1000
+++ kelly_new/include/net/sock.h	2006-06-19 10:42:45.000000000 +1000
@@ -196,6 +196,7 @@ struct sock {
 	unsigned short		sk_type;
 	int			sk_rcvbuf;
 	socket_lock_t		sk_lock;
+	struct netchannel	*sk_channel;
 	wait_queue_head_t	*sk_sleep;
 	struct dst_entry	*sk_dst_cache;
 	struct xfrm_policy	*sk_policy[2];
diff -urp davem/net/core/dev.c kelly_new/net/core/dev.c
--- davem/net/core/dev.c	2006-06-16 15:14:16.000000000 +1000
+++ kelly_new/net/core/dev.c	2006-07-10 14:11:22.000000000 +1000
@@ -113,9 +113,12 @@
 #include <linux/delay.h>
 #include <linux/wireless.h>
 #include <linux/netchannel.h>
+#include <linux/kthread.h>
+#include <linux/wait.h>
 #include <net/iw_handler.h>
 #include <asm/current.h>
 #include <linux/audit.h>
+#include <net/inet_hashtables.h>
 
 /*
  *	The list of packet types we will receive (as opposed to discard)
@@ -190,6 +193,8 @@ static inline struct hlist_head *dev_ind
 	return &dev_index_head[ifindex & ((1<<NETDEV_HASHBITS)-1)];
 }
 
+static struct netchannel default_netchannel;
+
 /*
  *	Our notifier list
  */
@@ -1854,11 +1859,18 @@ softnet_break:
 	goto out;
 }
 
+void netchannel_wake(struct netchannel *np)
+{
+	wake_up(&np->wq);
+}
+
 void netchannel_init(struct netchannel *np,
 		     void (*callb)(struct netchannel *), void *callb_data)
 {
 	memset(np, 0, sizeof(*np));
 
+	init_waitqueue_head(&np->wq);
+
 	np->netchan_callb	= callb;
 	np->netchan_callb_data	= callb_data;
 }
@@ -1912,6 +1924,122 @@ struct netchannel_buftrailer *__netchann
 }
 EXPORT_SYMBOL_GPL(__netchannel_dequeue);
 
+/* Find the channel for a packet, or return default channel. */
+struct netchannel *find_netchannel(const struct netchannel_buftrailer *bp)
+{
+	struct sock *sk = NULL;
+	int datalen = netchan_data_len(bp);
+
+	switch (bp->netchan_buf_proto) {
+	case __constant_htons(ETH_P_IP): {
+		struct iphdr *ip = (void *)bp - datalen;
+		int iphl = ip->ihl * 4;
+
+		/* FIXME: Do sanity checks, parse packet. */
+
+		if (datalen >+ (iphl + 4) && iphl == sizeof(struct iphdr)) {
+			u16 *ports = (u16 *)ip + 1;
+			sk = inet_lookup_proto(ip->protocol, 
+					 ip->saddr, ports[0],
+					 ip->daddr, ports[1],
+					 bp->netchan_buf_dev->ifindex);
+		}
+		break;
+	}
+	}
+
+	if (sk && sk->sk_channel)
+		return sk->sk_channel;
+	return &default_netchannel;
+}
+EXPORT_SYMBOL_GPL(find_netchannel);
+
+/* add the netchannel to the socket */
+int sock_add_netchannel(struct sock *sk)
+{
+	struct netchannel *np;
+
+	np = kmalloc(sizeof(struct netchannel), GFP_KERNEL);
+	if (!np)
+		return -ENOMEM;
+	netchannel_init(np, netchannel_wake, (void *)np);
+	sk->sk_channel = np;
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(sock_add_netchannel);
+
+/* deal with packets coming to default thread */
+static int netchannel_default_thread(void *unused)
+{
+	struct netchannel *np = &default_netchannel;
+	struct netchannel_buftrailer *nbp;
+	struct sk_buff *skbp;
+	DECLARE_WAITQUEUE(wait, current);
+
+	add_wait_queue(&np->wq, &wait);
+	set_current_state(TASK_UNINTERRUPTIBLE);
+
+	while (!kthread_should_stop()) {
+		while (np->netchan_tail != np->netchan_head) {
+			nbp = netchannel_dequeue(np);
+			skbp = skb_netchan_graft(nbp, GFP_KERNEL);
+			netif_receive_skb(skbp);
+		}
+		schedule();
+		set_current_state(TASK_INTERRUPTIBLE);
+	}
+	
+	remove_wait_queue(&np->wq, &wait);
+	__set_current_state(TASK_RUNNING);
+
+	return 0;
+}
+
 static gifconf_func_t * gifconf_list [NPROTO];
 
 /**
@@ -3426,6 +3554,10 @@ static int __init net_dev_init(void)
 	hotcpu_notifier(dev_cpu_callback, 0);
 	dst_init();
 	dev_mcast_init();
+
+	netchannel_init(&default_netchannel, netchannel_wake, (void 
*)&default_netchannel);
+	kthread_run(netchannel_default_thread, NULL, "nc_def");
+
 	rc = 0;
 out:
 	return rc;
