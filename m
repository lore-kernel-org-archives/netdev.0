From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: better drop monitoring in ip{6}_recv_error()
Date: Thu, 21 Apr 2016 22:27:32 -0700
Message-ID: <1461302852.7627.29.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f54.google.com ([209.85.213.54]:33751 "EHLO
	mail-vk0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751554AbcDVF1f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Apr 2016 01:27:35 -0400
Received: by mail-vk0-f54.google.com with SMTP id n62so123611617vkb.0
        for <netdev@vger.kernel.org>; Thu, 21 Apr 2016 22:27:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

We should call consume_skb(skb) when skb is properly consumed,
or kfree_skb(skb) when skb must be dropped in error case.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/ip_sockglue.c |   10 +++++-----
 net/ipv6/datagram.c    |   10 +++++-----
 2 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index 279471c4e58f..e3ca3915dc74 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -510,9 +510,10 @@ int ip_recv_error(struct sock *sk, struct msghdr *msg, int len, int *addr_len)
 		copied = len;
 	}
 	err = skb_copy_datagram_msg(skb, 0, msg, copied);
-	if (err)
-		goto out_free_skb;
-
+	if (unlikely(err)) {
+		kfree_skb(skb);
+		return err;
+	}
 	sock_recv_timestamp(msg, sk, skb);
 
 	serr = SKB_EXT_ERR(skb);
@@ -544,8 +545,7 @@ int ip_recv_error(struct sock *sk, struct msghdr *msg, int len, int *addr_len)
 	msg->msg_flags |= MSG_ERRQUEUE;
 	err = copied;
 
-out_free_skb:
-	kfree_skb(skb);
+	consume_skb(skb);
 out:
 	return err;
 }
diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index a73d70119fcd..4b33e54c5753 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -407,9 +407,10 @@ int ipv6_recv_error(struct sock *sk, struct msghdr *msg, int len, int *addr_len)
 		copied = len;
 	}
 	err = skb_copy_datagram_msg(skb, 0, msg, copied);
-	if (err)
-		goto out_free_skb;
-
+	if (unlikely(err)) {
+		kfree_skb(skb);
+		return err;
+	}
 	sock_recv_timestamp(msg, sk, skb);
 
 	serr = SKB_EXT_ERR(skb);
@@ -466,8 +467,7 @@ int ipv6_recv_error(struct sock *sk, struct msghdr *msg, int len, int *addr_len)
 	msg->msg_flags |= MSG_ERRQUEUE;
 	err = copied;
 
-out_free_skb:
-	kfree_skb(skb);
+	consume_skb(skb);
 out:
 	return err;
 }
