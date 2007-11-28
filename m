From: Hideo AOKI <haoki@redhat.com>
Subject: [PATCH 4/4] udp: memory accounting in IPv4
Date: Wed, 28 Nov 2007 13:53:36 -0500
Message-ID: <474DB930.5080409@redhat.com>
References: <474DB80E.5070403@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Satoshi Oshima <satoshi.oshima.fk@hitachi.com>,
	Bill Fink <billfink@mindspring.com>,
	Andi Kleen <andi@firstfloor.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	yoshfuji@linux-ipv6.org,
	Yumiko Sugita <yumiko.sugita.yf@hitachi.com>, haoki@redhat.com
To: Herbert Xu <herbert@gondor.apana.org.au>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:46557 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757185AbXK1Sym (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Nov 2007 13:54:42 -0500
In-Reply-To: <474DB80E.5070403@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds UDP memory usage accounting in IPv4.

Cc: Satoshi Oshima <satoshi.oshima.fk@hitachi.com>
signed-off-by: Hideo Aoki <haoki@redhat.com>
---

 af_inet.c   |   30 +++++++++++++++++++++++++++++-
 ip_output.c |   49 ++++++++++++++++++++++++++++++++++++++++++-------
 udp.c       |   16 ++++++++++++++++
 3 files changed, 87 insertions(+), 8 deletions(-)

diff -pruN net-2.6-udp-take9a2-p3/net/ipv4/af_inet.c net-2.6-udp-take9a2-p4/net/ipv4/af_inet.c
--- net-2.6-udp-take9a2-p3/net/ipv4/af_inet.c	2007-11-28 12:11:02.000000000 -0500
+++ net-2.6-udp-take9a2-p4/net/ipv4/af_inet.c	2007-11-28 12:11:04.000000000 -0500
@@ -126,13 +126,41 @@ extern void ip_mc_drop_socket(struct soc
 static struct list_head inetsw[SOCK_MAX];
 static DEFINE_SPINLOCK(inetsw_lock);

+/**
+ *	__skb_queue_purge_and_sub_memory_allocated
+ *		- empty a list and subtruct memory allocation counter
+ *	@sk:   sk
+ *	@list: list to empty
+ *	Delete all buffers on an &sk_buff list and subtruct the
+ *	truesize of the sk_buff for memory accounting. Each buffer
+ *	is removed from the list and one reference dropped. This
+ *	function does not take the list lock and the caller must
+ *	hold the relevant locks to use it.
+ */
+static inline void __skb_queue_purge_and_sub_memory_allocated(struct sock *sk,
+					struct sk_buff_head *list)
+{
+	struct sk_buff *skb;
+	int purged_skb_size = 0;
+	while ((skb = __skb_dequeue(list)) != NULL) {
+		purged_skb_size += sk_datagram_pages(skb->truesize);
+		kfree_skb(skb);
+	}
+	atomic_sub(purged_skb_size, sk->sk_prot->memory_allocated);
+}
+
 /* New destruction routine */

 void inet_sock_destruct(struct sock *sk)
 {
 	struct inet_sock *inet = inet_sk(sk);

-	__skb_queue_purge(&sk->sk_receive_queue);
+	if (sk->sk_prot->memory_allocated && sk->sk_type != SOCK_STREAM)
+		__skb_queue_purge_and_sub_memory_allocated(sk,
+				&sk->sk_receive_queue);
+	else
+		__skb_queue_purge(&sk->sk_receive_queue);
+
 	__skb_queue_purge(&sk->sk_error_queue);

 	if (sk->sk_type == SOCK_STREAM && sk->sk_state != TCP_CLOSE) {
diff -pruN net-2.6-udp-take9a2-p3/net/ipv4/ip_output.c net-2.6-udp-take9a2-p4/net/ipv4/ip_output.c
--- net-2.6-udp-take9a2-p3/net/ipv4/ip_output.c	2007-11-27 11:11:37.000000000 -0500
+++ net-2.6-udp-take9a2-p4/net/ipv4/ip_output.c	2007-11-28 12:11:09.000000000 -0500
@@ -75,6 +75,7 @@
 #include <net/icmp.h>
 #include <net/checksum.h>
 #include <net/inetpeer.h>
+#include <net/udp.h>
 #include <linux/igmp.h>
 #include <linux/netfilter_ipv4.h>
 #include <linux/netfilter_bridge.h>
@@ -707,16 +708,19 @@ static inline int ip_ufo_append_data(str
 {
 	struct sk_buff *skb;
 	int err;
+	int size = 0;

 	/* There is support for UDP fragmentation offload by network
 	 * device, so create one single skb packet containing complete
 	 * udp datagram
 	 */
 	if ((skb = skb_peek_tail(&sk->sk_write_queue)) == NULL) {
-		skb = sock_alloc_send_skb(sk,
-			hh_len + fragheaderlen + transhdrlen + 20,
-			(flags & MSG_DONTWAIT), &err);
+		size = hh_len + fragheaderlen + transhdrlen + 20;
+		if (!sk_wmem_schedule(sk, size))
+			return -ENOBUFS;

+		skb = sock_alloc_send_skb(sk, size, (flags & MSG_DONTWAIT),
+					  &err);
 		if (skb == NULL)
 			return err;

@@ -737,8 +741,12 @@ static inline int ip_ufo_append_data(str
 		sk->sk_sndmsg_off = 0;
 	}

-	err = skb_append_datato_frags(sk,skb, getfrag, from,
-			       (length - transhdrlen));
+	size = length - transhdrlen;
+	if (!sk_wmem_schedule(sk, size)) {
+		err = -ENOBUFS;
+		goto fail;
+	}
+	err = skb_append_datato_frags(sk, skb, getfrag, from, size);
 	if (!err) {
 		/* specify the length of each IP datagram fragment*/
 		skb_shinfo(skb)->gso_size = mtu - fragheaderlen;
@@ -750,6 +758,7 @@ static inline int ip_ufo_append_data(str
 	/* There is not enough support do UFO ,
 	 * so follow normal path
 	 */
+fail:
 	kfree_skb(skb);
 	return err;
 }
@@ -908,6 +917,12 @@ alloc_new_skb:
 			if (datalen == length + fraggap)
 				alloclen += rt->u.dst.trailer_len;

+			if (!sk_wmem_schedule(sk, alloclen + hh_len + 15 +
+					      sizeof(struct sk_buff))) {
+				err = -ENOBUFS;
+				goto error;
+			}
+
 			if (transhdrlen) {
 				skb = sock_alloc_send_skb(sk,
 						alloclen + hh_len + 15,
@@ -1004,6 +1019,10 @@ alloc_new_skb:
 					frag = &skb_shinfo(skb)->frags[i];
 				}
 			} else if (i < MAX_SKB_FRAGS) {
+				if (!sk_wmem_schedule(sk, PAGE_SIZE)) {
+					err = -ENOBUFS;
+					goto error;
+				}
 				if (atomic_read(&sk->sk_wmem_alloc) + PAGE_SIZE
 				    > 2 * sk->sk_sndbuf) {
 					err = -ENOBUFS;
@@ -1119,6 +1138,12 @@ ssize_t	ip_append_page(struct sock *sk,
 			fraggap = skb_prev->len - maxfraglen;

 			alloclen = fragheaderlen + hh_len + fraggap + 15;
+
+			if (!sk_wmem_schedule(sk, alloclen +
+					      sizeof(struct sk_buff))) {
+				err = -ENOBUFS;
+				goto error;
+			}
 			skb = sock_wmalloc(sk, alloclen, 1, sk->sk_allocation);
 			if (unlikely(!skb)) {
 				err = -ENOBUFS;
@@ -1213,13 +1238,14 @@ int ip_push_pending_frames(struct sock *
 	struct iphdr *iph;
 	__be16 df = 0;
 	__u8 ttl;
-	int err = 0;
+	int err = 0, send_page_size;

 	if ((skb = __skb_dequeue(&sk->sk_write_queue)) == NULL)
 		goto out;
 	tail_skb = &(skb_shinfo(skb)->frag_list);

 	/* move skb->data to ip header from ext header */
+	send_page_size = sk_datagram_pages(skb->truesize);
 	if (skb->data < skb_network_header(skb))
 		__skb_pull(skb, skb_network_offset(skb));
 	while ((tmp_skb = __skb_dequeue(&sk->sk_write_queue)) != NULL) {
@@ -1229,6 +1255,7 @@ int ip_push_pending_frames(struct sock *
 		skb->len += tmp_skb->len;
 		skb->data_len += tmp_skb->len;
 		skb->truesize += tmp_skb->truesize;
+		send_page_size += sk_datagram_pages(tmp_skb->truesize);
 		__sock_put(tmp_skb->sk);
 		tmp_skb->destructor = NULL;
 		tmp_skb->sk = NULL;
@@ -1284,6 +1311,8 @@ int ip_push_pending_frames(struct sock *
 	/* Netfilter gets whole the not fragmented skb. */
 	err = NF_HOOK(PF_INET, NF_IP_LOCAL_OUT, skb, NULL,
 		      skb->dst->dev, dst_output);
+	if (sk->sk_prot->memory_allocated)
+		atomic_sub(send_page_size, sk->sk_prot->memory_allocated);
 	if (err) {
 		if (err > 0)
 			err = inet->recverr ? net_xmit_errno(err) : 0;
@@ -1306,9 +1335,15 @@ error:
 void ip_flush_pending_frames(struct sock *sk)
 {
 	struct sk_buff *skb;
+	int num_flush_mem = 0;

-	while ((skb = __skb_dequeue_tail(&sk->sk_write_queue)) != NULL)
+	while ((skb = __skb_dequeue_tail(&sk->sk_write_queue)) != NULL) {
+		num_flush_mem += sk_datagram_pages(skb->truesize);
 		kfree_skb(skb);
+	}
+
+	if (sk->sk_prot->memory_allocated)
+		atomic_sub(num_flush_mem, sk->sk_prot->memory_allocated);

 	ip_cork_release(inet_sk(sk));
 }
diff -pruN net-2.6-udp-take9a2-p3/net/ipv4/udp.c net-2.6-udp-take9a2-p4/net/ipv4/udp.c
--- net-2.6-udp-take9a2-p3/net/ipv4/udp.c	2007-11-28 12:11:02.000000000 -0500
+++ net-2.6-udp-take9a2-p4/net/ipv4/udp.c	2007-11-28 12:11:09.000000000 -0500
@@ -833,6 +833,7 @@ int udp_recvmsg(struct kiocb *iocb, stru
 	unsigned int ulen, copied;
 	int err;
 	int is_udplite = IS_UDPLITE(sk);
+	int truesize;

 	/*
 	 *	Check any passed addresses
@@ -897,14 +898,18 @@ try_again:
 		err = ulen;

 out_free:
+	truesize = skb->truesize;
 	skb_free_datagram(sk, skb);
+	atomic_sub(sk_datagram_pages(truesize), sk->sk_prot->memory_allocated);
 out:
 	return err;

 csum_copy_err:
 	UDP_INC_STATS_BH(UDP_MIB_INERRORS, is_udplite);

+	truesize = skb->truesize;
 	skb_kill_datagram(sk, skb, flags);
+	atomic_sub(sk_datagram_pages(truesize), sk->sk_prot->memory_allocated);

 	if (noblock)
 		return -EAGAIN;
@@ -946,6 +951,7 @@ int udp_queue_rcv_skb(struct sock * sk,
 {
 	struct udp_sock *up = udp_sk(sk);
 	int rc;
+	int scheduled = 0;

 	/*
 	 *	Charge it to the socket, dropping if the queue is full.
@@ -1022,6 +1028,13 @@ int udp_queue_rcv_skb(struct sock * sk,
 			goto drop;
 	}

+	if (sk_datagram_rmem_schedule(sk, skb))
+		scheduled = skb->truesize;
+	else {
+		UDP_INC_STATS_BH(UDP_MIB_RCVBUFERRORS, up->pcflag);
+		goto drop;
+	}
+
 	if ((rc = sock_queue_rcv_skb(sk,skb)) < 0) {
 		/* Note that an ENOMEM error is charged twice */
 		if (rc == -ENOMEM)
@@ -1035,6 +1048,9 @@ int udp_queue_rcv_skb(struct sock * sk,
 drop:
 	UDP_INC_STATS_BH(UDP_MIB_INERRORS, up->pcflag);
 	kfree_skb(skb);
+	if (scheduled)
+		atomic_sub(sk_datagram_pages(scheduled),
+			   sk->sk_prot->memory_allocated);
 	return -1;
 }

-- 
Hitachi Computer Products (America) Inc.
