From: Martin Josefsson <gandalf@wlug.westbo.se>
Subject: raw ipv6 broken in 2.4.19
Date: 12 Aug 2002 21:07:38 +0200
Sender: owner-netdev@oss.sgi.com
Message-ID: <1029179259.791.31.camel@tux>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
List-Id: netdev.vger.kernel.org

Hi Alexey,

raw ipv6 doesn't work in 2.4.19, I've traced it to part of a patch that
went in between -pre7 and -pre8 back in April 23. Reverting the patch
below makes it work again in two machines. (part of changeset 1.383.17.3
in marcelos BK tree)

The description of that part in the changeset is:

"IPv6 raw had missing sk->filter handling and rawv6_rcv missing some
checksum processing."

The symptoms were that ping6 didn't work, it complained about:

ping: recvmsg: No route to host

but icmp echo-requests were sent out and icmp echo-replies were
recieved.
Ip6InDiscards increased for each icmp echo-reply recieved, but
Ip6InDelivers also increased for each packet recieved.

And traceroute6 returned bogus addresses most of the time (it was either
the correct address or a bogus one but always the same bogus address
independent of which ip the response came from)

Tested against Linux and OpenBSD with the same results.


--- 1.8/net/ipv6/raw.c	Thu Mar 14 00:46:57 2002
+++ 1.9/net/ipv6/raw.c	Tue Apr 23 04:13:30 2002
@@ -278,6 +278,16 @@
 
 static inline int rawv6_rcv_skb(struct sock * sk, struct sk_buff * skb)
 {
+#if defined(CONFIG_FILTER)
+	if (sk->filter && skb->ip_summed != CHECKSUM_UNNECESSARY) {
+		if ((unsigned short)csum_fold(skb_checksum(skb, 0, skb->len, skb->csum))) {
+			IP6_INC_STATS_BH(Ip6InDiscards);
+			kfree_skb(skb);
+			return 0;
+		}
+		skb->ip_summed = CHECKSUM_UNNECESSARY;
+	}
+#endif
 	/* Charge it to the socket. */
 	if (sock_queue_rcv_skb(sk,skb)<0) {
 		IP6_INC_STATS_BH(Ip6InDiscards);
@@ -298,9 +308,33 @@
  */
 int rawv6_rcv(struct sock *sk, struct sk_buff *skb)
 {
+	if (!sk->tp_pinfo.tp_raw.checksum)
+		skb->ip_summed = CHECKSUM_UNNECESSARY;
+
+	if (skb->ip_summed != CHECKSUM_UNNECESSARY) {
+		if (skb->ip_summed == CHECKSUM_HW) {
+			skb->ip_summed = CHECKSUM_UNNECESSARY;
+			if (csum_ipv6_magic(&skb->nh.ipv6h->saddr,
+					    &skb->nh.ipv6h->daddr,
+					    skb->len, sk->num, skb->csum)) {
+				NETDEBUG(if (net_ratelimit()) printk(KERN_DEBUG "raw v6 hw csum failure.\n"));
+				skb->ip_summed = CHECKSUM_NONE;
+			}
+		}
+		if (skb->ip_summed == CHECKSUM_NONE)
+			skb->csum = ~csum_ipv6_magic(&skb->nh.ipv6h->saddr,
+						     &skb->nh.ipv6h->daddr,
+						     skb->len, sk->num, 0);
+	}
+
 	if (sk->protinfo.af_inet.hdrincl) {
-		__skb_push(skb, skb->nh.raw - skb->data);
-		skb->h.raw = skb->nh.raw;
+		if (skb->ip_summed != CHECKSUM_UNNECESSARY &&
+		    (unsigned short)csum_fold(skb_checksum(skb, 0, skb->len, skb->csum))) {
+			IP6_INC_STATS_BH(Ip6InDiscards);
+			kfree_skb(skb);
+			return 0;
+		}
+		skb->ip_summed = CHECKSUM_UNNECESSARY;
 	}
 
 	rawv6_rcv_skb(sk, skb);
@@ -339,7 +373,17 @@
   		msg->msg_flags |= MSG_TRUNC;
   	}
 
-	err = skb_copy_datagram_iovec(skb, 0, msg->msg_iov, copied);
+	if (skb->ip_summed==CHECKSUM_UNNECESSARY) {
+		err = skb_copy_datagram_iovec(skb, 0, msg->msg_iov, copied);
+	} else if (msg->msg_flags&MSG_TRUNC) {
+		if ((unsigned short)csum_fold(skb_checksum(skb, 0, skb->len, skb->csum)))
+			goto csum_copy_err;
+		err = skb_copy_datagram_iovec(skb, 0, msg->msg_iov, copied);
+	} else {
+		err = skb_copy_and_csum_datagram_iovec(skb, 0, msg->msg_iov);
+		if (err == -EINVAL)
+			goto csum_copy_err;
+	}
 	if (err)
 		goto out_free;
 
@@ -366,6 +410,27 @@
 	skb_free_datagram(sk, skb);
 out:
 	return err;
+
+csum_copy_err:
+	/* Clear queue. */
+	if (flags&MSG_PEEK) {
+		int clear = 0;
+		spin_lock_irq(&sk->receive_queue.lock);
+		if (skb == skb_peek(&sk->receive_queue)) {
+			__skb_unlink(skb, &sk->receive_queue);
+			clear = 1;
+		}
+		spin_unlock_irq(&sk->receive_queue.lock);
+		if (clear)
+			kfree_skb(skb);
+	}
+
+	/* Error for blocking case is chosen to masquerade
+	   as some normal condition.
+	 */
+	err = (flags&MSG_DONTWAIT) ? -EAGAIN : -EHOSTUNREACH;
+	IP6_INC_STATS_USER(Ip6InDiscards);
+	goto out_free;
 }
 
 /*


-- 
/Martin

Never argue with an idiot. They drag you down to their level, then beat
you with experience.
