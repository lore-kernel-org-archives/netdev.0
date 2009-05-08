From: Steven Whitehouse <swhiteho@redhat.com>
Subject: decnet: Use data ready call back, rather than hand coding it
Date: Fri, 08 May 2009 17:30:25 +0100
Message-ID: <1241800225.29604.282.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ccaulfie@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:46201 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753974AbZEHQaz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 May 2009 12:30:55 -0400
Received: from int-mx2.corp.redhat.com (int-mx2.corp.redhat.com [172.16.27.26])
	by mx2.redhat.com (8.13.8/8.13.8) with ESMTP id n48GUv3C022649
	for <netdev@vger.kernel.org>; Fri, 8 May 2009 12:30:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Chrissie, can you test this? I don't have a suitable set up at the
moment. This should be correct though since its taken directly from
sock_queue_rcv_skb from whence the original code was also take in times
past. I did compile test it though.

Signed-off-by: Steven Whitehouse <swhiteho@redhat.com>


diff --git a/net/decnet/dn_nsp_in.c b/net/decnet/dn_nsp_in.c
index 5d8a2a5..932408d 100644
--- a/net/decnet/dn_nsp_in.c
+++ b/net/decnet/dn_nsp_in.c
@@ -578,6 +578,7 @@ out:
 static __inline__ int dn_queue_skb(struct sock *sk, struct sk_buff *skb, int sig, struct sk_buff_head *queue)
 {
 	int err;
+	int skb_len;
 
 	/* Cast skb->rcvbuf to unsigned... It's pointless, but reduces
 	   number of warnings when compiling with -W --ANK
@@ -592,22 +593,12 @@ static __inline__ int dn_queue_skb(struct sock *sk, struct sk_buff *skb, int sig
 	if (err)
 		goto out;
 
+	skb_len = skb->len;
 	skb_set_owner_r(skb, sk);
 	skb_queue_tail(queue, skb);
 
-	/* This code only runs from BH or BH protected context.
-	 * Therefore the plain read_lock is ok here. -DaveM
-	 */
-	read_lock(&sk->sk_callback_lock);
-	if (!sock_flag(sk, SOCK_DEAD)) {
-		struct socket *sock = sk->sk_socket;
-		wake_up_interruptible(sk->sk_sleep);
-		if (sock && sock->fasync_list &&
-		    !test_bit(SOCK_ASYNC_WAITDATA, &sock->flags))
-			__kill_fasync(sock->fasync_list, sig,
-				    (sig == SIGURG) ? POLL_PRI : POLL_IN);
-	}
-	read_unlock(&sk->sk_callback_lock);
+	if (!sock_flag(sk, SOCK_DEAD))
+		sk->sk_data_ready(sk, skb_len);
 out:
 	return err;
 }


