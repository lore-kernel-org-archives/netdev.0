From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [RFC] ipv6: gro: IPV6_GRO_CB(skb)->proto problem
Date: Sat, 06 Oct 2012 21:15:27 +0200
Message-ID: <1349550927.21172.1759.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:62419 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755463Ab2JFTPh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Oct 2012 15:15:37 -0400
Received: by mail-bk0-f46.google.com with SMTP id jk13so1458293bkc.19
        for <netdev@vger.kernel.org>; Sat, 06 Oct 2012 12:15:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It seems IPV6_GRO_CB(skb)->proto can be destroyed in skb_gro_receive()
if a new skb is allocated (to serve as an anchor for frag_list)

At line 3049 we copy NAPI_GRO_CB() only (not the IPV6 specific part)

*NAPI_GRO_CB(nskb) = *NAPI_GRO_CB(p);

So we leave IPV6_GRO_CB(nskb)->proto to 0 (fresh skb allocation) instead
of PROTO_TCP

So ipv6_gro_complete() wont be able to call ops->gro_complete()
[ tcp6_gro_complete() ]

I would fix this by moving proto in NAPI_GRO_CB() [ ie getting rid of
IPV6_GRO_CB ]

Am I missing something ?

(I'll submit a proper patch once/if prior GRO ones are accepted/merged
by David)

Thanks

 include/linux/netdevice.h |    2 ++
 net/ipv6/af_inet6.c       |   11 ++---------
 2 files changed, 4 insertions(+), 9 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 01646aa..3f13441 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1510,6 +1510,8 @@ struct napi_gro_cb {
 	int free;
 #define NAPI_GRO_FREE		  1
 #define NAPI_GRO_FREE_STOLEN_HEAD 2
+
+	u8 proto;
 };
 
 #define NAPI_GRO_CB(skb) ((struct napi_gro_cb *)(skb)->cb)
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index e22e6d8..5c7d809 100644
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
@@ -927,7 +920,7 @@ static int ipv6_gro_complete(struct sk_buff *skb)
 				 sizeof(*iph));
 
 	rcu_read_lock();
-	ops = rcu_dereference(inet6_protos[IPV6_GRO_CB(skb)->proto]);
+	ops = rcu_dereference(inet6_protos[NAPI_GRO_CB(skb)->proto]);
 	if (WARN_ON(!ops || !ops->gro_complete))
 		goto out_unlock;
 
