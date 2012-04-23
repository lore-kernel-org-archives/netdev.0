From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH 2/2 net-next] af_netlink: drop_monitor/dropwatch friendly
Date: Mon, 23 Apr 2012 09:30:29 +0200
Message-ID: <1335166229.3293.14.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:47959 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753758Ab2DWHad (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Apr 2012 03:30:33 -0400
Received: by mail-bk0-f46.google.com with SMTP id ik5so8325026bkc.19
        for <netdev@vger.kernel.org>; Mon, 23 Apr 2012 00:30:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Need to consume_skb() instead of kfree_skb() in netlink_dump() and
netlink_unicast_kernel() to avoid false dropwatch positives.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/netlink/af_netlink.c |   12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 85d27f9..b3025a6 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -154,6 +154,12 @@ static void netlink_destroy_callback(struct netlink_callback *cb)
 	kfree(cb);
 }
 
+static void netlink_consume_callback(struct netlink_callback *cb)
+{
+	consume_skb(cb->skb);
+	kfree(cb);
+}
+
 static void netlink_sock_destruct(struct sock *sk)
 {
 	struct netlink_sock *nlk = nlk_sk(sk);
@@ -902,8 +908,10 @@ static int netlink_unicast_kernel(struct sock *sk, struct sk_buff *skb)
 		ret = skb->len;
 		skb_set_owner_r(skb, sk);
 		nlk->netlink_rcv(skb);
+		consume_skb(skb);
+	} else {
+		kfree_skb(skb);
 	}
-	kfree_skb(skb);
 	sock_put(sk);
 	return ret;
 }
@@ -1728,7 +1736,7 @@ static int netlink_dump(struct sock *sk)
 	nlk->cb = NULL;
 	mutex_unlock(nlk->cb_mutex);
 
-	netlink_destroy_callback(cb);
+	netlink_consume_callback(cb);
 	return 0;
 
 errout_skb:
