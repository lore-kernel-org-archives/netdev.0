From: Hideo AOKI <haoki@redhat.com>
Subject: [PATCH 4/4] [UDP]: memory accounting in IPv4
Date: Sat, 15 Dec 2007 00:15:34 -0500
Message-ID: <476362F6.1030700@redhat.com>
References: <47636120.4050701@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Takahiro Yasui <tyasui@redhat.com>,
	Masami Hiramatsu <mhiramat@redhat.com>,
	Satoshi Oshima <satoshi.oshima.fk@hitachi.com>,
	billfink@mindspring.com, Andi Kleen <andi@firstfloor.org>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	yoshfuji@linux-ipv6.org,
	Yumiko Sugita <yumiko.sugita.yf@hitachi.com>, haoki@redhat.com
To: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:54501 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751112AbXLOFWg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Dec 2007 00:22:36 -0500
In-Reply-To: <47636120.4050701@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This patch adds UDP memory usage accounting in IPv4.

Send buffer accounting is performed by IP layer, because skbuff is
allocated in the layer.

Receive buffer is charged, when the buffer successfully received.
Destructor of the buffer does un charging and reclaiming, when the
buffer is freed. To set destructor at proper place, we introduce
udp_set_owner_r().

In addition, to make sure that sk_forward_alloc is totally uncharged
in socket destruction, a reclaiming is added to inet_sock_destruct().

Cc: Satoshi Oshima <satoshi.oshima.fk@hitachi.com>
signed-off-by: Takahiro Yasui <tyasui@redhat.com>
signed-off-by: Masami Hiramatsu <mhiramat@redhat.com>
signed-off-by: Hideo Aoki <haoki@redhat.com>
---

 af_inet.c   |    2 ++
 ip_output.c |   46 ++++++++++++++++++++++++++++++++++++++++++++--
 udp.c       |   16 +++++++++++++++-
 3 files changed, 61 insertions(+), 3 deletions(-)

diff -pruN net-2.6-udp-take10a4-p3/net/ipv4/af_inet.c net-2.6-udp-take10a4-p4/net/ipv4/af_inet.c
--- net-2.6-udp-take10a4-p3/net/ipv4/af_inet.c	2007-12-14 20:27:54.000000000 -0500
+++ net-2.6-udp-take10a4-p4/net/ipv4/af_inet.c	2007-12-14 21:06:54.000000000 -0500
@@ -144,6 +144,8 @@ void inet_sock_destruct(struct sock *sk)
 		printk("Attempt to release alive inet socket %p\n", sk);
 		return;
 	}
+	if (sk->sk_type == SOCK_DGRAM)
+		sk_datagram_mem_reclaim(sk);

 	BUG_TRAP(!atomic_read(&sk->sk_rmem_alloc));
 	BUG_TRAP(!atomic_read(&sk->sk_wmem_alloc));
diff -pruN net-2.6-udp-take10a4-p3/net/ipv4/ip_output.c net-2.6-udp-take10a4-p4/net/ipv4/ip_output.c
--- net-2.6-udp-take10a4-p3/net/ipv4/ip_output.c	2007-12-14 16:42:04.000000000 -0500
+++ net-2.6-udp-take10a4-p4/net/ipv4/ip_output.c	2007-12-14 21:06:54.000000000 -0500
@@ -707,6 +707,7 @@ static inline int ip_ufo_append_data(str
 {
 	struct sk_buff *skb;
 	int err;
+	int first_size, second_size;

 	/* There is support for UDP fragmentation offload by network
 	 * device, so create one single skb packet containing complete
@@ -720,6 +721,11 @@ static inline int ip_ufo_append_data(str
 		if (skb == NULL)
 			return err;

+		if (!sk_account_wmem_charge(sk, skb->truesize)) {
+			err = -ENOBUFS;
+			goto fail;
+		}
+
 		/* reserve space for Hardware header */
 		skb_reserve(skb, hh_len);

@@ -736,6 +742,7 @@ static inline int ip_ufo_append_data(str
 		skb->csum = 0;
 		sk->sk_sndmsg_off = 0;
 	}
+	first_size = skb->truesize;

 	err = skb_append_datato_frags(sk,skb, getfrag, from,
 			       (length - transhdrlen));
@@ -743,6 +750,15 @@ static inline int ip_ufo_append_data(str
 		/* specify the length of each IP datagram fragment*/
 		skb_shinfo(skb)->gso_size = mtu - fragheaderlen;
 		skb_shinfo(skb)->gso_type = SKB_GSO_UDP;
+
+		second_size = skb->truesize - first_size;
+		if (!sk_account_wmem_charge(sk, second_size)) {
+			sk_account_uncharge(sk, first_size);
+			sk_mem_reclaim(sk);
+			err = -ENOBUFS;
+			goto fail;
+		}
+
 		__skb_queue_tail(&sk->sk_write_queue, skb);

 		return 0;
@@ -750,6 +766,7 @@ static inline int ip_ufo_append_data(str
 	/* There is not enough support do UFO ,
 	 * so follow normal path
 	 */
+fail:
 	kfree_skb(skb);
 	return err;
 }
@@ -924,6 +941,11 @@ alloc_new_skb:
 			}
 			if (skb == NULL)
 				goto error;
+			if (!sk_account_wmem_charge(sk, skb->truesize)) {
+				err = -ENOBUFS;
+				kfree_skb(skb);
+				goto error;
+			}

 			/*
 			 *	Fill in the control structures
@@ -954,6 +976,8 @@ alloc_new_skb:
 			copy = datalen - transhdrlen - fraggap;
 			if (copy > 0 && getfrag(from, data + transhdrlen, offset, copy, fraggap, skb) < 0) {
 				err = -EFAULT;
+				sk_account_uncharge(sk, skb->truesize);
+				sk_mem_reclaim(sk);
 				kfree_skb(skb);
 				goto error;
 			}
@@ -1023,6 +1047,10 @@ alloc_new_skb:
 				frag = &skb_shinfo(skb)->frags[i];
 				skb->truesize += PAGE_SIZE;
 				atomic_add(PAGE_SIZE, &sk->sk_wmem_alloc);
+				if (!sk_account_wmem_charge(sk, PAGE_SIZE)) {
+					err = -ENOBUFS;
+					goto error;
+				}
 			} else {
 				err = -EMSGSIZE;
 				goto error;
@@ -1124,6 +1152,11 @@ ssize_t	ip_append_page(struct sock *sk,
 				err = -ENOBUFS;
 				goto error;
 			}
+			if (!sk_account_wmem_charge(sk, skb->truesize)) {
+				kfree_skb(skb);
+				err = -ENOBUFS;
+				goto error;
+			}

 			/*
 			 *	Fill in the control structures
@@ -1213,13 +1246,14 @@ int ip_push_pending_frames(struct sock *
 	struct iphdr *iph;
 	__be16 df = 0;
 	__u8 ttl;
-	int err = 0;
+	int err = 0, send_size;

 	if ((skb = __skb_dequeue(&sk->sk_write_queue)) == NULL)
 		goto out;
 	tail_skb = &(skb_shinfo(skb)->frag_list);

 	/* move skb->data to ip header from ext header */
+	send_size = skb->truesize;
 	if (skb->data < skb_network_header(skb))
 		__skb_pull(skb, skb_network_offset(skb));
 	while ((tmp_skb = __skb_dequeue(&sk->sk_write_queue)) != NULL) {
@@ -1229,6 +1263,7 @@ int ip_push_pending_frames(struct sock *
 		skb->len += tmp_skb->len;
 		skb->data_len += tmp_skb->len;
 		skb->truesize += tmp_skb->truesize;
+		send_size += tmp_skb->truesize;
 		__sock_put(tmp_skb->sk);
 		tmp_skb->destructor = NULL;
 		tmp_skb->sk = NULL;
@@ -1284,6 +1319,8 @@ int ip_push_pending_frames(struct sock *
 	/* Netfilter gets whole the not fragmented skb. */
 	err = NF_HOOK(PF_INET, NF_IP_LOCAL_OUT, skb, NULL,
 		      skb->dst->dev, dst_output);
+	sk_account_uncharge(sk, send_size);
+	sk_mem_reclaim(sk);
 	if (err) {
 		if (err > 0)
 			err = inet->recverr ? net_xmit_errno(err) : 0;
@@ -1306,10 +1343,15 @@ error:
 void ip_flush_pending_frames(struct sock *sk)
 {
 	struct sk_buff *skb;
+	int truesize = 0;

-	while ((skb = __skb_dequeue_tail(&sk->sk_write_queue)) != NULL)
+	while ((skb = __skb_dequeue_tail(&sk->sk_write_queue)) != NULL) {
+		truesize += skb->truesize;
 		kfree_skb(skb);
+	}

+	sk_account_uncharge(sk, truesize);
+	sk_mem_reclaim(sk);
 	ip_cork_release(inet_sk(sk));
 }

diff -pruN net-2.6-udp-take10a4-p3/net/ipv4/udp.c net-2.6-udp-take10a4-p4/net/ipv4/udp.c
--- net-2.6-udp-take10a4-p3/net/ipv4/udp.c	2007-12-14 20:27:54.000000000 -0500
+++ net-2.6-udp-take10a4-p4/net/ipv4/udp.c	2007-12-14 21:06:54.000000000 -0500
@@ -934,6 +934,13 @@ int udp_disconnect(struct sock *sk, int
 	return 0;
 }

+void udp_set_owner_r(struct sk_buff *skb, struct sock *sk)
+{
+	skb->sk = sk;
+	skb->destructor = sk_datagram_rfree;
+	atomic_add(skb->truesize, &sk->sk_rmem_alloc);
+}
+
 /* returns:
  *  -1: error
  *   0: success
@@ -1022,10 +1029,17 @@ int udp_queue_rcv_skb(struct sock * sk,
 			goto drop;
 	}

-	if ((rc = sock_queue_rcv_skb(sk,skb)) < 0) {
+	if (!sk_account_rmem_charge(sk, skb->truesize)) {
+		UDP_INC_STATS_BH(UDP_MIB_RCVBUFERRORS, up->pcflag);
+		goto drop;
+	}
+
+	if ((rc = sock_queue_rcv_skb_with_owner(sk, skb, udp_set_owner_r)) < 0) {
 		/* Note that an ENOMEM error is charged twice */
 		if (rc == -ENOMEM)
 			UDP_INC_STATS_BH(UDP_MIB_RCVBUFERRORS, up->pcflag);
+		sk_account_uncharge(sk, skb->truesize);
+		sk_datagram_mem_reclaim(sk);
 		goto drop;
 	}

-- 
Hitachi Computer Products (America) Inc.
