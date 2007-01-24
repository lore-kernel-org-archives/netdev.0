From: Masayuki Nakagawa <nakagawa.msy@ncos.nec.co.jp>
Subject: [PATCH 2.6.20-rc5] IPV6: skb is unexpectedly freed.
Date: Tue, 23 Jan 2007 18:15:26 -0800
Message-ID: <45B6C13E.1050204@ncos.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mhuth@mvista.com,
	nakagawa.msy@ncos.nec.co.jp
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway-1237.mvista.com ([63.81.120.158]:1391 "EHLO
	gateway-1237.mvista.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965628AbXAXCsy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jan 2007 21:48:54 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I encountered a kernel panic with my test program, which is a very simple
IPv6 client-server program.
The server side sets IPV6_RECVPKTINFO on a listening socket,
and the client side just sends a message to the server.
Then the kernel panic occurs on the server.
(If you need the test program, please let me know. I can provide it.)

This problem happens because a skb is forcibly freed in
tcp_rcv_state_process().
When a socket in listening state(TCP_LISTEN) receives a syn packet,
then tcp_v6_conn_request() will be called from tcp_rcv_state_process().
If the tcp_v6_conn_request() successfully returns, the skb would be discarded
by __kfree_skb().
However, in case of a listening socket which was already set IPV6_RECVPKTINFO,
an address of the skb will be stored in treq->pktopts and a ref count of the skb
will be incremented in tcp_v6_conn_request().
But, even if the skb is still in use, the skb will be freed.
Then someone still using the freed skb will cause the kernel panic.

I suggest to use kfree_skb() instead of __kfree_skb().

Signed-off-by: Masayuki Nakagawa <nakagawa.msy@ncos.nec.co.jp>

---
--- linux-2.6/net/ipv4/tcp_input.c.orig	2007-01-17 13:25:10.000000000 -0800
+++ linux-2.6/net/ipv4/tcp_input.c	2007-01-17 13:28:48.000000000 -0800
@@ -4420,9 +4420,11 @@ int tcp_rcv_state_process(struct sock *s
 			 * But, this leaves one open to an easy denial of
 		 	 * service attack, and SYN cookies can't defend
 			 * against this problem. So, we drop the data
-			 * in the interest of security over speed.
+			 * in the interest of security over speed unless
+			 * it's still in use.
 			 */
-			goto discard;
+			kfree_skb(skb);
+			return 0;
 		}
 		goto discard;

