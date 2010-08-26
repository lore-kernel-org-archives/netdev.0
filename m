From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: select(writefds) don't hang up when a peer close
 connection
Date: Thu, 26 Aug 2010 12:21:04 -0700 (PDT)
Message-ID: <20100826.122104.115920380.davem@davemloft.net>
References: <1282785886.22839.199.camel@localhost>
	<20100826125357.F667.A69D9226@jp.fujitsu.com>
	<1282824448.2263.3.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kosaki.motohiro@jp.fujitsu.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, yoshfuji@linux-ipv6.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51065
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752752Ab0HZTUt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Aug 2010 15:20:49 -0400
In-Reply-To: <1282824448.2263.3.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Thu, 26 Aug 2010 13:07:28 +0100

> By the way, I was able to reproduce this bug in RHEL 3 (kernel based on
> 2.4.21) so it seems to have been around for a while.

It's existed since September 1998:

commit 6275af56642b5b9ed9ef15bf5d9718661c5fe79d
Author: freitag <freitag>
Date:   Sat Sep 26 06:20:25 1998 +0000

    Some small fixes.
    
    - Remove second check for sk->err in poll as discussed with Linus.
    - Don't signal writability when the local end has been shut down.
    - Comment fixes.

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 5a09639..16d4308 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -5,7 +5,7 @@
  *
  *		Implementation of the Transmission Control Protocol(TCP).
  *
- * Version:	$Id: tcp.c,v 1.123 1998-09-23 19:52:39 davem Exp $
+ * Version:	$Id: tcp.c,v 1.124 1998-09-26 06:20:25 freitag Exp $
  *
  * Authors:	Ross Biro, <bir7@leland.Stanford.Edu>
  *		Fred N. van Kempen, <waltje@uWalt.NL.Mugnet.ORG>
@@ -591,18 +591,19 @@ unsigned int tcp_poll(struct file * file, struct socket *sock, poll_table *wait)
 		mask |= POLLHUP;
 
 	/* Connected? */
-	if ((1 << sk->state) & ~(TCPF_SYN_SENT|TCPF_SYN_RECV)) {
+	if ((1 << sk->state) & ~(TCPF_SYN_SENT|TCPF_SYN_RECV)) { 
 		if ((tp->rcv_nxt != tp->copied_seq) &&
 		    (tp->urg_seq != tp->copied_seq ||
 		     tp->rcv_nxt != tp->copied_seq+1 ||
 		     sk->urginline || !tp->urg_data))
 			mask |= POLLIN | POLLRDNORM;
 
-		/* Always wake the user up when an error occurred */
-		if (sock_wspace(sk) >= tcp_min_write_space(sk, tp) || sk->err) {
-			mask |= POLLOUT | POLLWRNORM;
-		} else {
-			sk->socket->flags |= SO_NOSPACE; /* send SIGIO later */
+		if (!(sk->shutdown & SEND_SHUTDOWN)) { 
+			if (sock_wspace(sk) >= tcp_min_write_space(sk, tp)) { 
+				mask |= POLLOUT | POLLWRNORM;
+			} else {  /* send SIGIO later */
+				sk->socket->flags |= SO_NOSPACE;  
+			}
 		}
 
 		if (tp->urg_data & URG_VALID)
@@ -733,6 +734,9 @@ static void wait_for_tcp_memory(struct sock * sk)
 	lock_sock(sk);
 }
 
+/* When all user supplied data has been queued set the PSH bit */ 
+#define PSH_NEEDED (seglen == 0 && iovlen == 0) 
+
 /*
  *	This routine copies from a user buffer into a socket,
  *	and starts the transmit system.
@@ -768,6 +772,9 @@ int tcp_do_sendmsg(struct sock *sk, int iovlen, struct iovec *iov, int flags)
 		while(seglen > 0) {
 			int copy, tmp, queue_it;
 
+			if (err) 
+				goto do_fault2;
+
 			/* Stop on errors. */
 			if (sk->err)
 				goto do_sock_err;
@@ -810,12 +817,24 @@ int tcp_do_sendmsg(struct sock *sk, int iovlen, struct iovec *iov, int flags)
 							from, skb_put(skb, copy),
 							copy, skb->csum, &err);
 					}
+					/*
+					 * FIXME: the *_user functions should
+					 *	  return how much data was
+					 *	  copied before the fault
+					 *	  occured and then a partial
+					 *	  packet with this data should
+					 *	  be sent.  Unfortunately 
+					 *	  csum_and_copy_from_user doesn't
+					 *	  return this information. 
+					 *	  ATM it might send partly zeroed
+					 *	  data in this case.
+					 */ 
 					tp->write_seq += copy;
 					TCP_SKB_CB(skb)->end_seq += copy;
 					from += copy;
 					copied += copy;
 					seglen -= copy;
-					if(!seglen && !iovlen)
+					if (PSH_NEEDED)
 						TCP_SKB_CB(skb)->flags |= TCPCB_FLAG_PSH;
 					continue;
 				}
@@ -831,7 +850,7 @@ int tcp_do_sendmsg(struct sock *sk, int iovlen, struct iovec *iov, int flags)
 			 * actually do is use the whole MSS.  Since
 			 * the results in the right edge of the packet
 			 * being outside the window, it will be queued
-			 * for later rather than sent.
+			 * for later rather than sent.  
 			 */
 			copy = tp->snd_wnd - (tp->snd_nxt - tp->snd_una);
 			if(copy >= (tp->max_window >> 1))
@@ -884,7 +903,7 @@ int tcp_do_sendmsg(struct sock *sk, int iovlen, struct iovec *iov, int flags)
 
 			/* Prepare control bits for TCP header creation engine. */
 			TCP_SKB_CB(skb)->flags = (TCPCB_FLAG_ACK |
-						  ((!seglen && !iovlen) ?
+						  (PSH_NEEDED ?
 						   TCPCB_FLAG_PSH : 0));
 			TCP_SKB_CB(skb)->sacked = 0;
 			if (flags & MSG_OOB) {
@@ -933,9 +952,12 @@ do_interrupted:
 	return err;
 do_fault:
 	kfree_skb(skb);
+do_fault2: 
 	return -EFAULT;
 }
 
+#undef PSH_NEEDED
+
 /*
  *	Send an ack if one is backlogged at this point. Ought to merge
  *	this with tcp_send_ack().
@@ -1050,8 +1072,6 @@ static void cleanup_rbuf(struct sock *sk, int copied)
 		tcp_eat_skb(sk, skb);
 	}
 
-	SOCK_DEBUG(sk, "sk->rspace = %lu\n", sock_rspace(sk));
-
   	/* We send an ACK if we can now advertise a non-zero window
 	 * which has been raised "significantly".
   	 */
