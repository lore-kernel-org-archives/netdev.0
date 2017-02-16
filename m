From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 09/13] net: Add a skb_gro_flush_final helper.
Date: Thu, 16 Feb 2017 13:18:43 +0100
Message-ID: <1487247527-17925-10-git-send-email-steffen.klassert@secunet.com>
References: <1487247527-17925-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:49314 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753618AbdBPMS6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 16 Feb 2017 07:18:58 -0500
In-Reply-To: <1487247527-17925-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a skb_gro_flush_final helper to prepare for  consuming
skbs in call_gro_receive. We will extend this helper to not
touch the skb if the skb is consumed by a gro callback with
a followup patch. We need this to handle the upcomming IPsec
ESP callbacks as they reinject the skb to the napi_gro_receive
asynchronous. The handler is used in all gro_receive functions
that can call the ESP gro handlers.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/linux/netdevice.h | 5 +++++
 net/ethernet/eth.c        | 2 +-
 net/ipv4/af_inet.c        | 2 +-
 net/ipv6/ip6_offload.c    | 2 +-
 4 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 58afbd1..f9da3ac 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2661,6 +2661,11 @@ static inline void skb_gro_remcsum_cleanup(struct sk_buff *skb,
 	remcsum_unadjust((__sum16 *)ptr, grc->delta);
 }
 
+static inline void skb_gro_flush_final(struct sk_buff *skb, struct sk_buff **pp, int flush)
+{
+	NAPI_GRO_CB(skb)->flush |= flush;
+}
+
 static inline int dev_hard_header(struct sk_buff *skb, struct net_device *dev,
 				  unsigned short type,
 				  const void *daddr, const void *saddr,
diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
index efdaaab..c666ff0 100644
--- a/net/ethernet/eth.c
+++ b/net/ethernet/eth.c
@@ -474,7 +474,7 @@ struct sk_buff **eth_gro_receive(struct sk_buff **head,
 out_unlock:
 	rcu_read_unlock();
 out:
-	NAPI_GRO_CB(skb)->flush |= flush;
+	skb_gro_flush_final(skb, pp, flush);
 
 	return pp;
 }
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 685ba53..602d40f 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1423,7 +1423,7 @@ struct sk_buff **inet_gro_receive(struct sk_buff **head, struct sk_buff *skb)
 	rcu_read_unlock();
 
 out:
-	NAPI_GRO_CB(skb)->flush |= flush;
+	skb_gro_flush_final(skb, pp, flush);
 
 	return pp;
 }
diff --git a/net/ipv6/ip6_offload.c b/net/ipv6/ip6_offload.c
index fc7b401..0838e6d 100644
--- a/net/ipv6/ip6_offload.c
+++ b/net/ipv6/ip6_offload.c
@@ -253,7 +253,7 @@ static struct sk_buff **ipv6_gro_receive(struct sk_buff **head,
 	rcu_read_unlock();
 
 out:
-	NAPI_GRO_CB(skb)->flush |= flush;
+	skb_gro_flush_final(skb, pp, flush);
 
 	return pp;
 }
-- 
1.9.1
