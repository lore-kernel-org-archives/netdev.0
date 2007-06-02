From: Miklos Szeredi <miklos@szeredi.hu>
Subject: [PATCH] fix race in AF_UNIX
Date: Sat, 02 Jun 2007 23:50:55 +0200
Message-ID: <E1HubUt-0004Hb-00@dorka.pomaz.szeredi.hu>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3.sa.ew.hu ([212.108.200.82]:51293 "EHLO
	mail-gw3.sa.ew.hu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759736AbXFBVvK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Jun 2007 17:51:10 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Miklos Szeredi <mszeredi@suse.cz>

A recv() on an AF_UNIX, SOCK_STREAM socket can race with a
send()+close() on the peer, causing recv() to return zero, even though
the sent data should be received.

This happens if the send() and the close() is performed between
skb_dequeue() and checking sk->sk_shutdown in unix_stream_recvmsg():

process A  skb_dequeue() returns NULL, there's no data in the socket queue
process B  new data is inserted onto the queue by unix_stream_sendmsg()
process B  sk->sk_shutdown is set to SHUTDOWN_MASK by unix_release_sock()
process A  sk->sk_shutdown is checked, unix_release_sock() returns zero

I'm surprised nobody noticed this, it's not hard to trigger.  Maybe
it's just (un)luck with the timing.

It's possible to work around this bug in userspace, by retrying the
recv() once in case of a zero return value.

Signed-off-by: Miklos Szeredi <mszeredi@suse.cz>
---

Index: linux-2.6.22-rc2/net/unix/af_unix.c
===================================================================
--- linux-2.6.22-rc2.orig/net/unix/af_unix.c	2007-06-02 23:45:47.000000000 +0200
+++ linux-2.6.22-rc2/net/unix/af_unix.c	2007-06-02 23:45:49.000000000 +0200
@@ -1711,20 +1711,23 @@ static int unix_stream_recvmsg(struct ki
 		int chunk;
 		struct sk_buff *skb;
 
+		unix_state_rlock(sk);
 		skb = skb_dequeue(&sk->sk_receive_queue);
 		if (skb==NULL)
 		{
 			if (copied >= target)
-				break;
+				goto unlock;
 
 			/*
 			 *	POSIX 1003.1g mandates this order.
 			 */
 
 			if ((err = sock_error(sk)) != 0)
-				break;
+				goto unlock;
 			if (sk->sk_shutdown & RCV_SHUTDOWN)
-				break;
+				goto unlock;
+
+			unix_state_runlock(sk);
 			err = -EAGAIN;
 			if (!timeo)
 				break;
@@ -1738,7 +1741,11 @@ static int unix_stream_recvmsg(struct ki
 			}
 			mutex_lock(&u->readlock);
 			continue;
+ unlock:
+			unix_state_runlock(sk);
+			break;
 		}
+		unix_state_runlock(sk);
 
 		if (check_creds) {
 			/* Never glue messages from different writers */
