From: Weiping Pan <wpan@redhat.com>
Subject: [RFC PATCH net-next 4/4 V4] try to fix performance regression
Date: Wed, 12 Dec 2012 22:29:09 +0800
Message-ID: <5e333588f6cb48cc3464b2263dcaa734b952e4c1.1355320534.git.wpan@redhat.com>
References: <20121210.160230.1883556145617090938.davem@davemloft.net>
Cc: brutus@google.com, netdev@vger.kernel.org,
	Weiping Pan <wpan@redhat.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:21489 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754072Ab2LLO3L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Dec 2012 09:29:11 -0500
In-Reply-To: <20121210.160230.1883556145617090938.davem@davemloft.net>
In-Reply-To: <117a10f9575d95d6a9ea4602ea7376e2b6d5ccd1.1355320533.git.wpan@redhat.com>
References: <117a10f9575d95d6a9ea4602ea7376e2b6d5ccd1.1355320533.git.wpan@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1 do not share tail skb between sender and receiver
2 reduce the use of sock->sk_lock.slock

--------------------------------------------------------------------------
TCP friends performance results start


BASE means normal tcp with friends DISABLED.
AF_UNIX means sockets for local interprocess communication, for reference.
FRIENDS means tcp with friends ENABLED.
I set -s 51882 -m 16384 -M 87380 for all the three kinds of sockets by default.
The first percentage number is FRIENDS/BASE.
The second percentage number is FRIENDS/AF_UNIX.
We set -i 10,2 -I 95,20 to stabilize the statistics.



      BASE    AF_UNIX    FRIENDS               TCP_STREAM
   7952.97   10864.86   13440.08  168%  123%



      BASE    AF_UNIX    FRIENDS               TCP_MAERTS
   6743.78          -   13809.97  204%    -%



      BASE    AF_UNIX    FRIENDS             TCP_SENDFILE
     11758          -      18483  157%    -%


TCP_SENDFILE can not work with -i 10,2 -I 95,20 (strange), so I use average.



        MS       BASE    AF_UNIX    FRIENDS            TCP_STREAM_MS
         1      10.70       5.40       4.02   37%   74%
         2      28.01       9.67       7.97   28%   82%
         4      55.53      19.78      16.48   29%   83%
         8     115.40      38.22      33.51   29%   87%
        16     227.31      81.06      67.70   29%   83%
        32     446.20     166.59     129.31   28%   77%
        64     849.04     336.77     259.43   30%   77%
       128    1440.50     661.88     530.43   36%   80%
       256    2404.70    1279.67    1029.15   42%   80%
       512    4331.53    2501.30    1942.21   44%   77%
      1024    6819.78    4622.37    4128.10   60%   89%
      2048   10544.60    6348.81    6349.59   60%  100%
      4096   12830.41    8324.43    7984.43   62%   95%
      8192   13462.65    8355.49   11079.37   82%  132%
     16384    9960.87   10840.13   13037.81  130%  120%
     32768    8749.31   11372.15   15087.08  172%  132%
     65536    7580.27   12150.23   14971.42  197%  123%
    131072    6727.74   11451.34   13604.78  202%  118%
    262144    7673.14   11613.10   11436.97  149%   98%
    524288    7366.17   11675.95   11559.43  156%   99%
   1048576    6608.57   11883.01   10103.20  152%   85%
MS means Message Size in bytes, that is -m -M for netperf



        RR       BASE    AF_UNIX    FRIENDS                TCP_RR_RR
         1   19716.88   34451.39   34574.12  175%  100%
         2   19836.74   34297.00   34671.29  174%  101%
         4   19874.71   34456.48   34552.13  173%  100%
         8   18882.93   34123.00   34661.48  183%  101%
        16   19179.09   34358.47   34599.16  180%  100%
        32   20140.08   34326.35   34616.30  171%  100%
        64   19473.39   34382.05   34583.10  177%  100%
       128   19699.62   34012.03   34566.14  175%  101%
       256   19740.44   34529.71   34624.07  175%  100%
       512   18929.46   33673.06   33932.83  179%  100%
      1024   18738.98   33724.78   33313.44  177%   98%
      2048   17315.61   32982.24   32361.39  186%   98%
      4096   16585.81   31345.85   31073.32  187%   99%
      8192   11933.16   27851.10   27166.94  227%   97%
     16384    9717.19   21746.12   22583.40  232%  103%
     32768    7044.35   12927.23   16253.26  230%  125%
     65536    5038.96    8945.74    7982.61  158%   89%
    131072    2860.64    4981.78    4417.16  154%   88%
    262144    1633.45    2765.27    2739.36  167%   99%
    524288     796.68    1429.79    1445.21  181%  101%
   1048576     379.78        per     730.05  192%     %
RR means Request Response Message Size in bytes, that is -r req,resp for netperf



        RR       BASE    AF_UNIX    FRIENDS               TCP_CRR_RR
         1    5531.49          -    5861.86  105%    -%
         2    5506.13          -    5845.53  106%    -%
         4    5523.27          -    5853.43  105%    -%
         8    5503.73          -    5836.44  106%    -%
        16    5516.23          -    5842.29  105%    -%
        32    5557.37          -    5858.29  105%    -%
        64    5517.51          -    5892.64  106%    -%
       128    5504.18          -    5841.44  106%    -%
       256    5512.82          -    5842.60  105%    -%
       512    5496.36          -    5837.72  106%    -%
      1024    5465.24          -    5827.99  106%    -%
      2048    5550.15          -    5812.88  104%    -%
      4096    5292.75          -    5824.45  110%    -%
      8192    4917.06          -    5705.12  116%    -%
     16384    4278.63          -    5318.39  124%    -%
     32768    3611.86          -    4930.30  136%    -%
     65536      77.35          -    3847.43 4974%    -%
    131072      47.65          -    2811.58 5900%    -%
    262144     805.13          -       4.88    0%    -%
    524288     583.08          -       4.78    0%    -%
   1048576     369.52          -       5.02    1%    -%
RR means Request Response Message Size in bytes, that is -r req,resp for netperf -H 127.0.0.1



TCP friends performance results end
--------------------------------------------------------------------------


Performance analysis:
1 Friends shows better performance than loopback in TCP_RR, TCP_MAERTS and
TCP_SENDFILE, same in TCP_CRR_RR.

2 In TCP_STREAM, Friends shows much worse perofrmance (30%) than loopback if
the message size if small, and it shows worse performance (80%) than AF_UNIX.

3 Compared with last performance report, Friends shows worse performance in
TCP_RR.

Friends VS AF_UNIX
I think the lock use is much similar this time.
May the locking contention is not the bottle neck ?

Friends VS loopback
I have reduced the locking contention as much as possible,
but it still shows bad performance.
May the locking contention is not the bottle neck ?


Signed-off-by: Weiping Pan <wpan@redhat.com>
---
 include/net/tcp.h |   10 --
 net/ipv4/tcp.c    |  327 ++++++++++++++++++++++-------------------------------
 2 files changed, 136 insertions(+), 201 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 5f82770..80a8ec9 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -688,15 +688,6 @@ void tcp_send_window_probe(struct sock *sk);
 #define TCPHDR_ECE 0x40
 #define TCPHDR_CWR 0x80
 
-/* If skb_get_friend() != NULL, TCP friends per packet state.
- */
-struct friend_skb_parm {
-	bool	tail_inuse;		/* In use by skb_get_friend() send while */
-					/* on sk_receive_queue for tail put */
-};
-
-#define TCP_FRIEND_CB(tcb) (&(tcb)->header.hf)
-
 /* This is what the send packet queuing engine uses to pass
  * TCP per-packet control information to the transmission code.
  * We also store the host-order sequence numbers in here too.
@@ -709,7 +700,6 @@ struct tcp_skb_cb {
 #if IS_ENABLED(CONFIG_IPV6)
 		struct inet6_skb_parm	h6;
 #endif
-		struct friend_skb_parm	hf;
 	} header;	/* For incoming frames		*/
 	__u32		seq;		/* Starting sequence number	*/
 	__u32		end_seq;	/* SEQ + FIN + SYN + datalen	*/
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index e9d82e0..f008d60 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -336,25 +336,24 @@ static inline int tcp_friend_validate(struct sock *sk, struct sock **friendp,
 	return 1;
 }
 
-static inline int tcp_friend_send_lock(struct sock *friend)
+static inline int tcp_friend_get_state(struct sock *friend)
 {
 	int err = 0;
 
 	spin_lock_bh(&friend->sk_lock.slock);
-	if (unlikely(friend->sk_shutdown & RCV_SHUTDOWN)) {
-		spin_unlock_bh(&friend->sk_lock.slock);
+	if (unlikely(friend->sk_shutdown & RCV_SHUTDOWN))
 		err = -ECONNRESET;
-	}
+	spin_unlock_bh(&friend->sk_lock.slock);
 
 	return err;
 }
 
-static inline void tcp_friend_recv_lock(struct sock *friend)
+static inline void tcp_friend_state_lock(struct sock *friend)
 {
 	spin_lock_bh(&friend->sk_lock.slock);
 }
 
-static void tcp_friend_unlock(struct sock *friend)
+static inline void tcp_friend_state_unlock(struct sock *friend)
 {
 	spin_unlock_bh(&friend->sk_lock.slock);
 }
@@ -639,71 +638,32 @@ int tcp_ioctl(struct sock *sk, int cmd, unsigned long arg)
 }
 EXPORT_SYMBOL(tcp_ioctl);
 
-/*
- * Friend receive_queue tail skb space? If true, set tail_inuse.
- * Else if RCV_SHUTDOWN, return *copy = -ECONNRESET.
- */
-static inline struct sk_buff *tcp_friend_tail(struct sock *friend, int *copy)
-{
-	struct sk_buff	*skb = NULL;
-	int		sz = 0;
-
-	if (skb_peek_tail(&friend->sk_receive_queue)) {
-		sz = tcp_friend_send_lock(friend);
-		if (!sz) {
-			skb = skb_peek_tail(&friend->sk_receive_queue);
-			if (skb && skb->friend) {
-				if (!*copy)
-					sz = skb_tailroom(skb);
-				else {
-					sz = *copy - skb->len;
-					if (sz < 0)
-						sz = 0;
-				}
-				if (sz > 0)
-					TCP_FRIEND_CB(TCP_SKB_CB(skb))->
-							tail_inuse = true;
-			}
-			tcp_friend_unlock(friend);
-		}
-	}
-
-	*copy = sz;
-	return skb;
-}
-
-static inline void tcp_friend_seq(struct sock *sk, int copy, int charge)
-{
-	struct sock	*friend = sk->sk_friend;
-	struct tcp_sock *tp = tcp_sk(friend);
-
-	if (charge) {
-		sk_mem_charge(friend, charge);
-		atomic_add(charge, &friend->sk_rmem_alloc);
-	}
-	tp->rcv_nxt += copy;
-	tp->rcv_wup += copy;
-	tcp_friend_unlock(friend);
-
-	tp = tcp_sk(sk);
-	tp->snd_nxt += copy;
-	tp->pushed_seq += copy;
-	tp->snd_una += copy;
-	tp->snd_up += copy;
-}
-
 static inline bool tcp_friend_push(struct sock *sk, struct sk_buff *skb)
 {
-	struct sock	*friend = sk->sk_friend;
-	int		wait = false;
+	struct sock *friend = sk->sk_friend;
+	struct tcp_sock *tp = NULL;
+	int wait = false;
+
+	tcp_friend_state_lock(friend);
 
 	skb_set_owner_r(skb, friend);
-	__skb_queue_tail(&friend->sk_receive_queue, skb);
 	if (!sk_rmem_schedule(friend, skb, skb->truesize))
 		wait = true;
+	__skb_queue_tail(&friend->sk_receive_queue, skb);
+
+	tcp_friend_state_unlock(friend);
 
-	tcp_friend_seq(sk, skb->len, 0);
-	if (skb == skb_peek(&friend->sk_receive_queue))
+	tp = tcp_sk(friend);
+	tp->rcv_nxt += skb->len;
+	tp->rcv_wup += skb->len;
+
+	tp = tcp_sk(sk);
+	tp->snd_nxt += skb->len;
+	tp->pushed_seq += skb->len;
+	tp->snd_una += skb->len;
+	tp->snd_up += skb->len;
+
+	if (skb_queue_len(&friend->sk_receive_queue) == 1)
 		friend->sk_data_ready(friend, 0);
 
 	return wait;
@@ -728,7 +688,6 @@ static inline void skb_entail(struct sock *sk, struct sk_buff *skb)
 	tcb->seq     = tcb->end_seq = tp->write_seq;
 	if (sk->sk_friend) {
 		skb->friend = sk;
-		TCP_FRIEND_CB(tcb)->tail_inuse = false;
 		return;
 	}
 	skb->csum    = 0;
@@ -1048,8 +1007,17 @@ static ssize_t do_tcp_sendpages(struct sock *sk, struct page **pages, int poffse
 	if (sk->sk_err || (sk->sk_shutdown & SEND_SHUTDOWN))
 		goto out_err;
 
+	if (friend) {
+		err = tcp_friend_get_state(friend);
+		if (err) {
+			sk->sk_err = -err;
+			err = -EPIPE;
+			goto out_err;
+		}
+	}
+
 	while (psize > 0) {
-		struct sk_buff *skb;
+		struct sk_buff *skb = NULL;
 		struct tcp_skb_cb *tcb;
 		struct page *page = pages[poffset / PAGE_SIZE];
 		int copy, i;
@@ -1059,12 +1027,10 @@ static ssize_t do_tcp_sendpages(struct sock *sk, struct page **pages, int poffse
 
 		if (friend) {
 			copy = size_goal;
-			skb = tcp_friend_tail(friend, &copy);
-			if (copy < 0) {
-				sk->sk_err = -copy;
-				err = -EPIPE;
-				goto out_err;
-			}
+			if (skb)
+				copy = copy - skb->len;
+			else
+				copy = 0;
 		} else if (!tcp_send_head(sk)) {
 			skb = NULL;
 			copy = 0;
@@ -1078,9 +1044,17 @@ new_segment:
 			if (!sk_stream_memory_free(sk))
 				goto wait_for_sndbuf;
 
-			if (friend)
+			if (friend) {
+				if (skb) {
+					if (tcp_friend_push(sk, skb))
+						goto wait_for_sndbuf;
+				}
+
+				/*
+				 * new skb
+				 */
 				skb = tcp_friend_alloc_skb(sk, 0);
-			else
+			} else
 				skb = sk_stream_alloc_skb(sk, 0,
 							  sk->sk_allocation);
 			if (!skb)
@@ -1097,10 +1071,7 @@ new_segment:
 		i = skb_shinfo(skb)->nr_frags;
 		can_coalesce = skb_can_coalesce(skb, i, page, offset);
 		if (!can_coalesce && i >= MAX_SKB_FRAGS) {
-			if (friend) {
-				if (TCP_FRIEND_CB(tcb)->tail_inuse)
-					TCP_FRIEND_CB(tcb)->tail_inuse = false;
-			} else
+			if (!friend)
 				tcp_mark_push(tp, skb);
 			goto new_segment;
 		}
@@ -1124,20 +1095,9 @@ new_segment:
 		psize -= copy;
 
 		if (friend) {
-			err = tcp_friend_send_lock(friend);
-			if (err) {
-				sk->sk_err = -err;
-				err = -EPIPE;
-				goto out_err;
-			}
 			tcb->end_seq += copy;
-			if (TCP_FRIEND_CB(tcb)->tail_inuse) {
-				TCP_FRIEND_CB(tcb)->tail_inuse = false;
-				tcp_friend_seq(sk, copy, copy);
-			} else {
-				if (tcp_friend_push(sk, skb))
-					goto wait_for_sndbuf;
-			}
+			if (tcp_friend_push(sk, skb))
+				goto wait_for_sndbuf;
 			if (!psize)
 				goto out;
 			continue;
@@ -1172,6 +1132,18 @@ wait_for_memory:
 		if ((err = sk_stream_wait_memory(sk, &timeo)) != 0)
 			goto do_error;
 
+		if (friend) {
+			if (skb) {
+				tcp_friend_state_lock(friend);
+				if (!sk_rmem_schedule(friend, skb, skb->truesize)) {
+					tcp_friend_state_unlock(friend);
+					goto wait_for_sndbuf;
+				}
+				tcp_friend_state_unlock(friend);
+				skb = NULL;
+			}
+		}
+
 		if (!friend)
 			mss_now = tcp_send_mss(sk, &size_goal, flags);
 	}
@@ -1266,7 +1238,7 @@ int tcp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	struct iovec *iov;
 	struct sock *friend = sk->sk_friend;
 	struct tcp_sock *tp = tcp_sk(sk);
-	struct sk_buff *skb;
+	struct sk_buff *skb = NULL;
 	struct tcp_skb_cb *tcb;
 	int iovlen, flags, err, copied = 0;
 	int mss_now = 0, size_goal = size, copied_syn = 0, offset = 0;
@@ -1330,6 +1302,15 @@ int tcp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 
 	sg = !!(sk->sk_route_caps & NETIF_F_SG);
 
+	if (friend) {
+		err = tcp_friend_get_state(friend);
+		if (err) {
+			sk->sk_err = -err;
+			err = -EPIPE;
+			goto out_err;
+		}
+	}
+
 	while (--iovlen >= 0) {
 		size_t seglen = iov->iov_len;
 		unsigned char __user *from = iov->iov_base;
@@ -1350,12 +1331,10 @@ int tcp_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 			int max = size_goal;
 
 			if (friend) {
-				skb = tcp_friend_tail(friend, &copy);
-				if (copy < 0) {
-					sk->sk_err = -copy;
-					err = -EPIPE;
-					goto out_err;
-				}
+				if (skb)
+					copy = skb_availroom(skb);
+				else
+					copy = 0;
 			} else {
 				skb = tcp_write_queue_tail(sk);
 				if (tcp_send_head(sk)) {
@@ -1370,9 +1349,21 @@ new_segment:
 				if (!sk_stream_memory_free(sk))
 					goto wait_for_sndbuf;
 
-				if (friend)
+				if (friend) {
+					if (skb) {
+						/*
+						 * Friend push old skb
+						 */
+
+						if (tcp_friend_push(sk, skb))
+							goto wait_for_sndbuf;
+					}
+
+					/*
+					 * new skb
+					 */
 					skb = tcp_friend_alloc_skb(sk, max);
-				else {
+				} else {
 					/* Allocate new segment. If the
 					 * interface is SG, allocate skb
 					 * fitting to single page.
@@ -1455,32 +1446,23 @@ new_segment:
 			copied += copy;
 			seglen -= copy;
 
-			if (friend) {
-				err = tcp_friend_send_lock(friend);
-				if (err) {
-					sk->sk_err = -err;
-					err = -EPIPE;
-					goto out_err;
-				}
-				tcb->end_seq += copy;
-				if (TCP_FRIEND_CB(tcb)->tail_inuse) {
-					TCP_FRIEND_CB(tcb)->tail_inuse = false;
-					tcp_friend_seq(sk, copy, 0);
-				} else {
-					if (tcp_friend_push(sk, skb))
-						goto wait_for_sndbuf;
-				}
-				continue;
-			}
-
 			tcb->end_seq += copy;
+
 			skb_shinfo(skb)->gso_segs = 0;
 
 			if (copied == copy)
 				tcb->tcp_flags &= ~TCPHDR_PSH;
 
-			if (seglen == 0 && iovlen == 0)
+			if (seglen == 0 && iovlen == 0) {
+				if (friend && skb) {
+					if (tcp_friend_push(sk, skb))
+						goto wait_for_sndbuf;
+				}
 				goto out;
+			}
+
+			if (friend)
+				continue;
 
 			if (skb->len < max || (flags & MSG_OOB) || unlikely(tp->repair))
 				continue;
@@ -1501,6 +1483,17 @@ wait_for_memory:
 			if ((err = sk_stream_wait_memory(sk, &timeo)) != 0)
 				goto do_error;
 
+			if (friend) {
+				if (skb) {
+					tcp_friend_state_lock(friend);
+					if (!sk_rmem_schedule(friend, skb, skb->truesize)) {
+						tcp_friend_state_unlock(friend);
+						goto wait_for_sndbuf;
+					}
+					tcp_friend_state_unlock(friend);
+					skb = NULL;
+				}
+			}
 			if (!friend)
 				mss_now = tcp_send_mss(sk, &size_goal, flags);
 		}
@@ -1514,10 +1507,7 @@ out:
 
 do_fault:
 	if (skb->friend) {
-		if (TCP_FRIEND_CB(tcb)->tail_inuse)
-			TCP_FRIEND_CB(tcb)->tail_inuse = false;
-		else
-			__kfree_skb(skb);
+		__kfree_skb(skb);
 	} else if (!skb->len) {
 		tcp_unlink_write_queue(skb, sk);
 		/* It is the one place in all of TCP, except connection
@@ -1787,8 +1777,6 @@ int tcp_read_sock(struct sock *sk, read_descriptor_t *desc,
 	err = tcp_friend_validate(sk, &friend, &timeo);
 	if (err < 0)
 		return err;
-	if (friend)
-		tcp_friend_recv_lock(sk);
 
 	while ((skb = tcp_recv_skb(sk, seq, &offset, &len)) != NULL) {
 		if (len > 0) {
@@ -1803,9 +1791,6 @@ int tcp_read_sock(struct sock *sk, read_descriptor_t *desc,
 					break;
 			}
 
-			if (friend)
-				tcp_friend_unlock(sk);
-
 			used = recv_actor(desc, skb, offset, len);
 			if (used < 0) {
 				if (!copied)
@@ -1817,21 +1802,7 @@ int tcp_read_sock(struct sock *sk, read_descriptor_t *desc,
 				offset += used;
 			}
 
-			if (friend)
-				tcp_friend_recv_lock(sk);
-			if (skb->friend) {
-				len = (u32)(TCP_SKB_CB(skb)->end_seq - seq);
-				if (len > 0) {
-					/*
-					 * Friend did an skb_put() while we
-					 * were away so process the same skb.
-					 */
-					if (!desc->count)
-						break;
-					tp->copied_seq = seq;
-					goto again;
-				}
-			} else {
+			if (!skb->friend) {
 				/*
 				 * If recv_actor drops the lock (e.g. TCP
 				 * splice receive) the skb pointer might be
@@ -1844,19 +1815,25 @@ int tcp_read_sock(struct sock *sk, read_descriptor_t *desc,
 					break;
 			}
 		}
+
 		if (!skb->friend && tcp_hdr(skb)->fin) {
 			sk_eat_skb(sk, skb, false);
 			++seq;
 			break;
 		}
 		if (skb->friend) {
-			if (!TCP_FRIEND_CB(TCP_SKB_CB(skb))->tail_inuse) {
-				__skb_unlink(skb, &sk->sk_receive_queue);
-				__kfree_skb(skb);
-				tcp_friend_write_space(sk);
+			len = (u32)(TCP_SKB_CB(skb)->end_seq - seq);
+			if (len > 0) {
+				if (!desc->count)
+					break;
+				tp->copied_seq = seq;
+				goto again;
 			}
-			tcp_friend_unlock(sk);
-			tcp_friend_recv_lock(sk);
+			tcp_friend_state_lock(sk);
+			__skb_unlink(skb, &sk->sk_receive_queue);
+			__kfree_skb(skb);
+			tcp_friend_state_unlock(sk);
+			tcp_friend_write_space(sk);
 		} else
 			sk_eat_skb(sk, skb, 0);
 		if (!desc->count)
@@ -1866,7 +1843,6 @@ int tcp_read_sock(struct sock *sk, read_descriptor_t *desc,
 	tp->copied_seq = seq;
 
 	if (friend) {
-		tcp_friend_unlock(sk);
 		tcp_friend_write_space(sk);
 	} else {
 		tcp_rcv_space_adjust(sk);
@@ -1903,7 +1879,6 @@ int tcp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	bool copied_early = false;
 	struct sk_buff *skb;
 	u32 urg_hole = 0;
-	bool locked = false;
 
 	lock_sock(sk);
 
@@ -1991,11 +1966,6 @@ int tcp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		 * slock, end_seq updated, so we can only use the bytes
 		 * from *seq to end_seq!
 		 */
-		if (friend && !locked) {
-			tcp_friend_recv_lock(sk);
-			locked = true;
-		}
-
 		skb_queue_walk(&sk->sk_receive_queue, skb) {
 			tcb = TCP_SKB_CB(skb);
 			offset = *seq - tcb->seq;
@@ -2003,20 +1973,14 @@ int tcp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 				if (skb->friend) {
 					used = (u32)(tcb->end_seq - *seq);
 					if (used > 0) {
-						tcp_friend_unlock(sk);
-						locked = false;
 						/* Can use it all */
 						goto found_ok_skb;
 					}
 					/* No data to copyout */
 					if (flags & MSG_PEEK)
 						continue;
-					if (!TCP_FRIEND_CB(tcb)->tail_inuse)
-						goto unlink;
-					break;
+					goto unlink;
 				}
-				tcp_friend_unlock(sk);
-				locked = false;
 			}
 
 			/* Now that we have two receive queues this
@@ -2043,11 +2007,6 @@ int tcp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 
 		/* Well, if we have backlog, try to process it now yet. */
 
-		if (friend && locked) {
-			tcp_friend_unlock(sk);
-			locked = false;
-		}
-
 		if (copied >= target && !sk->sk_backlog.tail)
 			break;
 
@@ -2262,17 +2221,7 @@ do_prequeue:
 		len -= used;
 		offset += used;
 
-		tcp_rcv_space_adjust(sk);
-
-skip_copy:
-		if (tp->urg_data && after(tp->copied_seq, tp->urg_seq)) {
-			tp->urg_data = 0;
-			tcp_fast_path_check(sk);
-		}
-
 		if (skb->friend) {
-			tcp_friend_recv_lock(sk);
-			locked = true;
 			used = (u32)(tcb->end_seq - *seq);
 			if (used) {
 				/*
@@ -2280,29 +2229,28 @@ skip_copy:
 				 * so if more to do process the same skb.
 				 */
 				if (len > 0) {
-					tcp_friend_unlock(sk);
-					locked = false;
 					goto found_ok_skb;
 				}
 				continue;
 			}
-			if (TCP_FRIEND_CB(tcb)->tail_inuse) {
-				/* Give sendmsg a chance */
-				tcp_friend_unlock(sk);
-				locked = false;
-				continue;
-			}
 			if (!(flags & MSG_PEEK)) {
 		unlink:
+				tcp_friend_state_lock(sk);
 				__skb_unlink(skb, &sk->sk_receive_queue);
 				__kfree_skb(skb);
-				tcp_friend_unlock(sk);
-				locked = false;
+				tcp_friend_state_unlock(sk);
 				tcp_friend_write_space(sk);
 			}
 			continue;
 		}
 
+		tcp_rcv_space_adjust(sk);
+skip_copy:
+		if (tp->urg_data && after(tp->copied_seq, tp->urg_seq)) {
+			tp->urg_data = 0;
+			tcp_fast_path_check(sk);
+		}
+
 		if (offset < skb->len)
 			continue;
 		else if (tcp_hdr(skb)->fin)
@@ -2323,9 +2271,6 @@ skip_copy:
 		break;
 	} while (len > 0);
 
-	if (friend && locked)
-		tcp_friend_unlock(sk);
-
 	if (user_recv) {
 		if (!skb_queue_empty(&tp->ucopy.prequeue)) {
 			int chunk;
-- 
1.7.4.4
