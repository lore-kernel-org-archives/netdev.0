From: Kelly Daly <kelly@au1.ibm.com>
Subject: Re: [PATCH 1/3] Rough VJ Channel Implementation - vj_core.patch
Date: Fri, 5 May 2006 12:48:42 +1000
Message-ID: <200605051248.42662.kelly@au.ibm.com>
References: <200604261147.34221.kelly@au.ibm.com> <200605041728.27131.kelly@au.ibm.com> <20060504.161148.44973535.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: rusty@rustcorp.com.au, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausmtp04.au.ibm.com ([202.81.18.152]:14783 "EHLO
	ausmtp04.au.ibm.com") by vger.kernel.org with ESMTP id S932431AbWEECs7
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 May 2006 22:48:59 -0400
Received: from sd0208e0.au.ibm.com (d23rh904.au.ibm.com [202.81.18.202])
	by ausmtp04.au.ibm.com (8.13.6/8.13.5) with ESMTP id k452xM6E228412
	for <netdev@vger.kernel.org>; Fri, 5 May 2006 12:59:22 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.250.242])
	by sd0208e0.au.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id k452q4Cj194464
	for <netdev@vger.kernel.org>; Fri, 5 May 2006 12:52:10 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11/8.13.3) with ESMTP id k452mi5V008726
	for <netdev@vger.kernel.org>; Fri, 5 May 2006 12:48:44 +1000
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20060504.161148.44973535.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 05 May 2006 09:11, David S. Miller wrote:
> I very much fear abuse of the inet_hashes[] array.  So I'd rather
> hide it behind a programmatic interface, something like:

done!  I will continue with implementation of default netchannel for now.


> Thanks!
anytime  =)

Cheers,
K


______________________

diff -urp davem_orig/include/net/inet_hashtables.h kelly/include/net/inet_hashtables.h
--- davem_orig/include/net/inet_hashtables.h	2006-04-27 00:08:32.000000000 +1000
+++ kelly/include/net/inet_hashtables.h	2006-05-05 12:05:33.000000000 +1000
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
+++ kelly/net/core/dev.c	2006-05-05 10:39:22.000000000 +1000
@@ -116,6 +116,7 @@
 #include <net/iw_handler.h>
 #include <asm/current.h>
 #include <linux/audit.h>
+#include <net/inet_hashtables.h>
 
 /*
  *	The list of packet types we will receive (as opposed to discard)
@@ -190,6 +191,8 @@ static inline struct hlist_head *dev_ind
 	return &dev_index_head[ifindex & ((1<<NETDEV_HASHBITS)-1)];
 }
 
+static struct netchannel default_netchannel;
+
 /*
  *	Our notifier list
  */
@@ -1907,6 +1910,34 @@ struct netchannel_buftrailer *__netchann
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
@@ -3421,6 +3452,9 @@ static int __init net_dev_init(void)
 	hotcpu_notifier(dev_cpu_callback, 0);
 	dst_init();
 	dev_mcast_init();
+
+	/* FIXME: This should be attached to thread/threads. */
+	netchannel_init(&default_netchannel, NULL, NULL);
 	rc = 0;
 out:
 	return rc;
diff -urp davem_orig/net/ipv4/inet_hashtables.c kelly/net/ipv4/inet_hashtables.c
--- davem_orig/net/ipv4/inet_hashtables.c	2006-04-27 00:08:33.000000000 +1000
+++ kelly/net/ipv4/inet_hashtables.c	2006-05-05 12:05:33.000000000 +1000
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
