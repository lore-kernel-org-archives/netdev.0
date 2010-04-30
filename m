From: Tom Herbert <therbert@google.com>
Subject: [PATCH] tcp: SO_TIMESTAMP implementation for TCP
Date: Thu, 29 Apr 2010 23:07:54 -0700 (PDT)
Message-ID: <alpine.DEB.1.00.1004292246440.12776@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:17988 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758357Ab0D3RFl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Apr 2010 13:05:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implement SO_TIMESTAMP{NS} for TCP.  When this socket option is enabled
on a TCP socket, a timestamp for received data can be returned in the
ancillary data of a recvmsg with control message type SCM_TIMESTAMP{NS}.
The timestamp chosen is that of the skb most recently received from
which data was copied.  This is useful in debugging and timing
network operations.

Signed-off-by: Tom Herbert <therbert@google.com>
---
diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index a778ee0..7dbb662 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -314,6 +314,7 @@ struct tcp_sock {
  	u32	snd_sml;	/* Last byte of the most recently transmitted small packet */
 	u32	rcv_tstamp;	/* timestamp of last received ACK (for keepalives) */
 	u32	lsndtime;	/* timestamp of last sent data packet (for restart window) */
+	ktime_t lrxcopytime;	/* timestamp of newest data in copy to user space */
 
 	/* Data for direct copy to user */
 	struct {
@@ -466,6 +467,15 @@ static inline struct tcp_sock *tcp_sk(const struct sock *sk)
 	return (struct tcp_sock *)sk;
 }
 
+static inline void tcp_update_lrxcopytime(struct sock *sk,
+					  const struct sk_buff *skb)
+{
+	struct tcp_sock *tp = tcp_sk(sk);
+
+	if (unlikely(skb->tstamp.tv64 >  tp->lrxcopytime.tv64))
+		tp->lrxcopytime = skb->tstamp;
+}
+
 struct tcp_timewait_sock {
 	struct inet_timewait_sock tw_sk;
 	u32			  tw_rcv_nxt;
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 8ce2974..c7f107a 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1381,6 +1381,27 @@ int tcp_read_sock(struct sock *sk, read_descriptor_t *desc,
 	return copied;
 }
 
+static inline void tcp_sock_recv_timestamp(struct msghdr *msg, struct sock *sk)
+{
+	struct tcp_sock *tp = tcp_sk(sk);
+
+	if (likely(!sock_flag(sk, SOCK_RCVTSTAMP)))
+		return;
+
+	if (msg->msg_controllen >= sizeof(struct timeval) &&
+	    tp->lrxcopytime.tv64) {
+		if (sock_flag(sk, SOCK_RCVTSTAMPNS)) {
+			struct timespec ts = ktime_to_timespec(tp->lrxcopytime);
+			put_cmsg(msg, SOL_SOCKET, SCM_TIMESTAMPNS,
+				 sizeof(ts), &ts);
+		} else {
+			struct timeval tv = ktime_to_timeval(tp->lrxcopytime);
+			put_cmsg(msg, SOL_SOCKET, SCM_TIMESTAMP,
+			    sizeof(tv), &tv);
+		}
+	}
+}
+
 /*
  *	This routine copies from a sock struct into the user buffer.
  *
@@ -1414,6 +1435,7 @@ int tcp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 		goto out;
 
 	timeo = sock_rcvtimeo(sk, nonblock);
+	tp->lrxcopytime.tv64 = 0;
 
 	/* Urgent data needs to be handled specially. */
 	if (flags & MSG_OOB)
@@ -1691,6 +1713,8 @@ do_prequeue:
 					break;
 				}
 			}
+
+			tcp_update_lrxcopytime(sk, skb);
 		}
 
 		*seq += used;
@@ -1758,6 +1782,8 @@ skip_copy:
 	 * on connected socket. I was just happy when found this 8) --ANK
 	 */
 
+	tcp_sock_recv_timestamp(msg, sk);
+
 	/* Clean up data we have read: This will do ACK frames. */
 	tcp_cleanup_rbuf(sk, copied);
 
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index e82162c..b94ad16 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4397,6 +4397,7 @@ static void tcp_data_queue(struct sock *sk, struct sk_buff *skb)
 				tp->copied_seq += chunk;
 				eaten = (chunk == skb->len && !th->fin);
 				tcp_rcv_space_adjust(sk);
+				tcp_update_lrxcopytime(sk, skb);
 			}
 			local_bh_disable();
 		}
@@ -5061,6 +5062,7 @@ static int tcp_copy_to_iovec(struct sock *sk, struct sk_buff *skb, int hlen)
 		tp->ucopy.len -= chunk;
 		tp->copied_seq += chunk;
 		tcp_rcv_space_adjust(sk);
+		tcp_update_lrxcopytime(sk, skb);
 	}
 
 	local_bh_disable();
@@ -5120,6 +5122,7 @@ static int tcp_dma_try_early_copy(struct sock *sk, struct sk_buff *skb,
 		tp->ucopy.len -= chunk;
 		tp->copied_seq += chunk;
 		tcp_rcv_space_adjust(sk);
+		tcp_update_lrxcopytime(sk, skb);
 
 		if ((tp->ucopy.len == 0) ||
 		    (tcp_flag_word(tcp_hdr(skb)) & TCP_FLAG_PSH) ||
