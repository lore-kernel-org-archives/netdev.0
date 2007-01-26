From: Masayuki Nakagawa <nakagawa.msy@ncos.nec.co.jp>
Subject: [PATCH] TCP: Replace __kfree_skb() with kfree_skb()
Date: Thu, 25 Jan 2007 19:37:07 -0800
Message-ID: <45B97763.8000305@ncos.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: nakagawa.msy@ncos.nec.co.jp, mhuth@mvista.com,
	netdev@vger.kernel.org
To: davem@davemloft.net, yoshfuji@linux-ipv6.org,
	herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway-1237.mvista.com ([63.81.120.158]:19516 "EHLO
	gateway-1237.mvista.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030733AbXAZDhL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jan 2007 22:37:11 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch simply replaces __kfree_skb() in exit path with kfree_skb().
In tcp_rcv_state_process(), generally skbs should be destroyed only when
the ref count is zero.
That is the way things are supposed to be done in the kernel.

This change might reveals a memory leak of skb.
If it happens, it would be because someone doesn't deal with the skb properly.

Signed-off-by: Masayuki Nakagawa <nakagawa.msy@ncos.nec.co.jp>

--- linux-2.6/net/ipv4/tcp_input.c.orig	2007-01-25 07:04:35.000000000 -0800
+++ linux-2.6/net/ipv4/tcp_input.c	2007-01-25 07:05:05.000000000 -0800
@@ -4423,8 +4423,6 @@ int tcp_rcv_state_process(struct sock *s
 			 * in the interest of security over speed unless
 			 * it's still in use.
 			 */
-			kfree_skb(skb);
-			return 0;
 		}
 		goto discard;

@@ -4634,7 +4632,7 @@ int tcp_rcv_state_process(struct sock *s

 	if (!queued) {
 discard:
-		__kfree_skb(skb);
+		kfree_skb(skb);
 	}
 	return 0;
 }
