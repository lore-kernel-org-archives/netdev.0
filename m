From: David Miller <davem@davemloft.net>
Subject: Re: Fix bugs in "Whether sock accept queue is full" checking
Date: Fri, 02 Mar 2007 12:51:58 -0800 (PST)
Message-ID: <20070302.125158.88476099.davem@davemloft.net>
References: <1171470657.7414.15.camel@LINE>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: weid@np.css.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37582
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S965589AbXCBUv7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Mar 2007 15:51:59 -0500
In-Reply-To: <1171470657.7414.15.camel@LINE>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: weidong <weid@np.css.fujitsu.com>
Date: Wed, 14 Feb 2007 11:30:57 -0500

> diff -ruN old/include/net/sock.h new/include/net/sock.h
> --- old/include/net/sock.h	2007-02-03 08:38:21.000000000 -0500
> +++ new/include/net/sock.h	2007-02-03 08:38:30.000000000 -0500
> @@ -426,7 +426,7 @@
>  
>  static inline int sk_acceptq_is_full(struct sock *sk)
>  {
> -	return sk->sk_ack_backlog > sk->sk_max_ack_backlog;
> +	return sk->sk_ack_backlog >= sk->sk_max_ack_backlog;
>  }
>  
>  /*

I've applied this patch, and also fixed a similar case
I spotted in AF_UNIX after doing a quick audit.

Thank you.

commit 626d548a8d145a032cff9237245f8ac9d9056ac1
Author: David S. Miller <davem@sunset.davemloft.net>
Date:   Fri Mar 2 12:49:23 2007 -0800

    [AF_UNIX]: Test against sk_max_ack_backlog properly.
    
    This brings things inline with the sk_acceptq_is_full() bug
    fix.  The limit test should be x >= sk_max_ack_backlog.
    
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 6069716..51ca438 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -934,7 +934,7 @@ static long unix_wait_for_peer(struct sock *other, long timeo)
 
 	sched = !sock_flag(other, SOCK_DEAD) &&
 		!(other->sk_shutdown & RCV_SHUTDOWN) &&
-		(skb_queue_len(&other->sk_receive_queue) >
+		(skb_queue_len(&other->sk_receive_queue) >=
 		 other->sk_max_ack_backlog);
 
 	unix_state_runlock(other);
@@ -1008,7 +1008,7 @@ restart:
 	if (other->sk_state != TCP_LISTEN)
 		goto out_unlock;
 
-	if (skb_queue_len(&other->sk_receive_queue) >
+	if (skb_queue_len(&other->sk_receive_queue) >=
 	    other->sk_max_ack_backlog) {
 		err = -EAGAIN;
 		if (!timeo)
@@ -1381,7 +1381,7 @@ restart:
 	}
 
 	if (unix_peer(other) != sk &&
-	    (skb_queue_len(&other->sk_receive_queue) >
+	    (skb_queue_len(&other->sk_receive_queue) >=
 	     other->sk_max_ack_backlog)) {
 		if (!timeo) {
 			err = -EAGAIN;
