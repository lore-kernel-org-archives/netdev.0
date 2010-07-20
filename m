From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] netlink: netlink_recvmsg() fix
Date: Tue, 20 Jul 2010 15:16:29 +0200
Message-ID: <1279631789.2498.71.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Johannes Berg <johannes@sipsolutions.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:41240 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750786Ab0GTNQd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jul 2010 09:16:33 -0400
Received: by wwj40 with SMTP id 40so829141wwj.1
        for <netdev@vger.kernel.org>; Tue, 20 Jul 2010 06:16:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please note following potential bug was discovered by code review, and
my patch not even tested, please double check !

Thanks

[PATCH net-next-2.6] netlink: netlink_recvmsg() fix

commit 1dacc76d0014 
(net/compat/wext: send different messages to compat tasks)
introduced a race condition on netlink, in case MSG_PEEK is used.

An skb given by skb_recv_datagram() might be shared, we must clone it
before any modification, or risk fatal corruption.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/netlink/af_netlink.c |   19 ++++++++++++-------
 1 file changed, 12 insertions(+), 7 deletions(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 7aeaa83..dad5e81 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1405,7 +1405,7 @@ static int netlink_recvmsg(struct kiocb *kiocb, struct socket *sock,
 	struct netlink_sock *nlk = nlk_sk(sk);
 	int noblock = flags&MSG_DONTWAIT;
 	size_t copied;
-	struct sk_buff *skb, *frag __maybe_unused = NULL;
+	struct sk_buff *skb;
 	int err;
 
 	if (flags&MSG_OOB)
@@ -1440,8 +1440,17 @@ static int netlink_recvmsg(struct kiocb *kiocb, struct socket *sock,
 			kfree_skb(skb);
 			skb = compskb;
 		} else {
-			frag = skb_shinfo(skb)->frag_list;
-			skb_shinfo(skb)->frag_list = NULL;
+			struct sk_buff *nskb = skb_clone(skb, GFP_KERNEL);
+
+			if (!nskb) {
+				skb_free_datagram(sk, skb);
+				err = -ENOMEM;
+				goto out;
+			}
+			kfree_skb(skb);
+			kfree_skb(skb_shinfo(nskb)->frag_list);
+			skb_shinfo(nskb)->frag_list = NULL;
+			skb = nskb;
 		}
 	}
 #endif
@@ -1477,10 +1486,6 @@ static int netlink_recvmsg(struct kiocb *kiocb, struct socket *sock,
 	if (flags & MSG_TRUNC)
 		copied = skb->len;
 
-#ifdef CONFIG_COMPAT_NETLINK_MESSAGES
-	skb_shinfo(skb)->frag_list = frag;
-#endif
-
 	skb_free_datagram(sk, skb);
 
 	if (nlk->cb && atomic_read(&sk->sk_rmem_alloc) <= sk->sk_rcvbuf / 2)


