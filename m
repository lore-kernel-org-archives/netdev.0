From: Andrew Grover <andrew.grover@intel.com>
Subject: [PATCH 8/10] [IOAT] Make sk_eat_skb() IOAT-aware
Date: Thu, 20 Apr 2006 13:50:34 -0700 (PDT)
Message-ID: <Pine.LNX.4.44.0604201341090.22544-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmr19.intel.com ([134.134.136.18]:2966 "EHLO
	orsfmr004.jf.intel.com") by vger.kernel.org with ESMTP
	id S1751277AbWDTUue (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Apr 2006 16:50:34 -0400
Received: from orsfmr100.jf.intel.com (orsfmr100.jf.intel.com [10.7.209.16])
	by orsfmr004.jf.intel.com (8.12.10/8.12.10/d: major-outer.mc,v 1.1 2004/09/17 17:50:56 root Exp $) with ESMTP id k3KKoYiN024894
	for <netdev@vger.kernel.org>; Thu, 20 Apr 2006 20:50:34 GMT
Received: from nwlxmail01.jf.intel.com (nwlxmail01.jf.intel.com [10.7.171.40])
	by orsfmr100.jf.intel.com (8.12.10/8.12.10/d: major-inner.mc,v 1.2 2004/09/17 18:05:01 root Exp $) with ESMTP id k3KKoY2u016175
	for <netdev@vger.kernel.org>; Thu, 20 Apr 2006 20:50:34 GMT
Received: from isotope.jf.intel.com (isotope.jf.intel.com [10.23.35.8])
	by nwlxmail01.jf.intel.com (8.12.10/8.12.9/MailSET/Hub) with ESMTP id k3KKoYhF021546
	for <netdev@vger.kernel.org>; Thu, 20 Apr 2006 13:50:34 -0700
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Add an extra argument to sk_eat_skb, and make it move early copied packets
to the async_wait_queue instead of freeing them.
Signed-off-by: Chris Leech <christopher.leech@intel.com>

---

 include/net/sock.h |   13 ++++++++++++-
 net/dccp/proto.c   |    4 ++--
 net/ipv4/tcp.c     |    8 ++++----
 net/llc/af_llc.c   |    2 +-

diff --git a/include/net/sock.h b/include/net/sock.h
index 190809c..e3723b6 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1272,11 +1272,22 @@ sock_recv_timestamp(struct msghdr *msg, 
  * This routine must be called with interrupts disabled or with the socket
  * locked so that the sk_buff queue operation is ok.
 */
-static inline void sk_eat_skb(struct sock *sk, struct sk_buff *skb)
+#ifdef CONFIG_NET_DMA
+static inline void sk_eat_skb(struct sock *sk, struct sk_buff *skb, int copied_early)
+{
+	__skb_unlink(skb, &sk->sk_receive_queue);
+	if (!copied_early)
+		__kfree_skb(skb);
+	else
+		__skb_queue_tail(&sk->sk_async_wait_queue, skb);
+}
+#else
+static inline void sk_eat_skb(struct sock *sk, struct sk_buff *skb, int copied_early)
 {
 	__skb_unlink(skb, &sk->sk_receive_queue);
 	__kfree_skb(skb);
 }
+#endif
 
 extern void sock_enable_timestamp(struct sock *sk);
 extern int sock_get_timestamp(struct sock *, struct timeval __user *);
diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index 1ff7328..35d7dfd 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -719,7 +719,7 @@ int dccp_recvmsg(struct kiocb *iocb, str
 		}
 		dccp_pr_debug("packet_type=%s\n",
 			      dccp_packet_name(dh->dccph_type));
-		sk_eat_skb(sk, skb);
+		sk_eat_skb(sk, skb, 0);
 verify_sock_status:
 		if (sock_flag(sk, SOCK_DONE)) {
 			len = 0;
@@ -773,7 +773,7 @@ verify_sock_status:
 		}
 	found_fin_ok:
 		if (!(flags & MSG_PEEK))
-			sk_eat_skb(sk, skb);
+			sk_eat_skb(sk, skb, 0);
 		break;
 	} while (1);
 out:
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index b10f78c..2346539 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1072,11 +1072,11 @@ int tcp_read_sock(struct sock *sk, read_
 				break;
 		}
 		if (skb->h.th->fin) {
-			sk_eat_skb(sk, skb);
+			sk_eat_skb(sk, skb, 0);
 			++seq;
 			break;
 		}
-		sk_eat_skb(sk, skb);
+		sk_eat_skb(sk, skb, 0);
 		if (!desc->count)
 			break;
 	}
@@ -1356,14 +1356,14 @@ skip_copy:
 		if (skb->h.th->fin)
 			goto found_fin_ok;
 		if (!(flags & MSG_PEEK))
-			sk_eat_skb(sk, skb);
+			sk_eat_skb(sk, skb, 0);
 		continue;
 
 	found_fin_ok:
 		/* Process the FIN. */
 		++*seq;
 		if (!(flags & MSG_PEEK))
-			sk_eat_skb(sk, skb);
+			sk_eat_skb(sk, skb, 0);
 		break;
 	} while (len > 0);
 
diff --git a/net/llc/af_llc.c b/net/llc/af_llc.c
index 5a04db7..7465170 100644
--- a/net/llc/af_llc.c
+++ b/net/llc/af_llc.c
@@ -789,7 +789,7 @@ static int llc_ui_recvmsg(struct kiocb *
 			continue;
 
 		if (!(flags & MSG_PEEK)) {
-			sk_eat_skb(sk, skb);
+			sk_eat_skb(sk, skb, 0);
 			*seq = 0;
 		}
 	} while (len > 0);
-- 
1.2.6



