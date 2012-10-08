From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] ipv6: gro: fix PV6_GRO_CB(skb)->proto problem
Date: Mon, 08 Oct 2012 21:38:50 +0200
Message-ID: <1349725130.21172.3663.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:47929 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751260Ab2JHTiy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2012 15:38:54 -0400
Received: by mail-bk0-f46.google.com with SMTP id jk13so2246472bkc.19
        for <netdev@vger.kernel.org>; Mon, 08 Oct 2012 12:38:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

It seems IPV6_GRO_CB(skb)->proto can be destroyed in skb_gro_receive()
if a new skb is allocated (to serve as an anchor for frag_list)

We copy NAPI_GRO_CB() only (not the IPV6 specific part) in :

*NAPI_GRO_CB(nskb) = *NAPI_GRO_CB(p);

So we leave IPV6_GRO_CB(nskb)->proto to 0 (fresh skb allocation) instead
of IPPROTO_TCP (6)

ipv6_gro_complete() isnt able to call ops->gro_complete()
[ tcp6_gro_complete() ]

Fix this by moving proto in NAPI_GRO_CB() and getting rid of
IPV6_GRO_CB

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>
---
 include/linux/netdevice.h |    3 +++
 net/ipv6/af_inet6.c       |   11 ++---------
 2 files changed, 5 insertions(+), 9 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 0a36fff..4b9035c 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1513,6 +1513,9 @@ struct napi_gro_cb {
 
 	/* jiffies when first packet was created/queued */
 	unsigned long age;
+
+	/* Used in ipv6_gro_receive() */
+	int	proto;
 };
 
 #define NAPI_GRO_CB(skb) ((struct napi_gro_cb *)(skb)->cb)
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index f757e3b..a974247 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -822,13 +822,6 @@ out:
 	return segs;
 }
 
-struct ipv6_gro_cb {
-	struct napi_gro_cb napi;
-	int proto;
-};
-
-#define IPV6_GRO_CB(skb) ((struct ipv6_gro_cb *)(skb)->cb)
-
 static struct sk_buff **ipv6_gro_receive(struct sk_buff **head,
 					 struct sk_buff *skb)
 {
@@ -874,7 +867,7 @@ static struct sk_buff **ipv6_gro_receive(struct sk_buff **head,
 		iph = ipv6_hdr(skb);
 	}
 
-	IPV6_GRO_CB(skb)->proto = proto;
+	NAPI_GRO_CB(skb)->proto = proto;
 
 	flush--;
 	nlen = skb_network_header_len(skb);
@@ -930,7 +923,7 @@ static int ipv6_gro_complete(struct sk_buff *skb)
 				 sizeof(*iph));
 
 	rcu_read_lock();
-	ops = rcu_dereference(inet6_protos[IPV6_GRO_CB(skb)->proto]);
+	ops = rcu_dereference(inet6_protos[NAPI_GRO_CB(skb)->proto]);
 	if (WARN_ON(!ops || !ops->gro_complete))
 		goto out_unlock;
 
