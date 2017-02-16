From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 10/13] net: Prepare gro for packet consuming gro callbacks
Date: Thu, 16 Feb 2017 13:18:44 +0100
Message-ID: <1487247527-17925-11-git-send-email-steffen.klassert@secunet.com>
References: <1487247527-17925-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:49328 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754684AbdBPMS7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 16 Feb 2017 07:18:59 -0500
In-Reply-To: <1487247527-17925-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The upcomming IPsec ESP gro callbacks will consume the skb,
so prepare for that.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/linux/netdevice.h | 9 +++++++++
 net/core/dev.c            | 7 +++++++
 net/xfrm/Kconfig          | 4 ++++
 3 files changed, 20 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index f9da3ac..9e5d1cd 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -352,6 +352,7 @@ enum gro_result {
 	GRO_HELD,
 	GRO_NORMAL,
 	GRO_DROP,
+	GRO_CONSUMED,
 };
 typedef enum gro_result gro_result_t;
 
@@ -2661,10 +2662,18 @@ static inline void skb_gro_remcsum_cleanup(struct sk_buff *skb,
 	remcsum_unadjust((__sum16 *)ptr, grc->delta);
 }
 
+#ifdef CONFIG_XFRM_OFFLOAD
+static inline void skb_gro_flush_final(struct sk_buff *skb, struct sk_buff **pp, int flush)
+{
+	if (PTR_ERR(pp) != -EINPROGRESS)
+		NAPI_GRO_CB(skb)->flush |= flush;
+}
+#else
 static inline void skb_gro_flush_final(struct sk_buff *skb, struct sk_buff **pp, int flush)
 {
 	NAPI_GRO_CB(skb)->flush |= flush;
 }
+#endif
 
 static inline int dev_hard_header(struct sk_buff *skb, struct net_device *dev,
 				  unsigned short type,
diff --git a/net/core/dev.c b/net/core/dev.c
index 3e1a601..64efbb9 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4505,6 +4505,11 @@ static enum gro_result dev_gro_receive(struct napi_struct *napi, struct sk_buff
 	if (&ptype->list == head)
 		goto normal;
 
+	if (IS_ERR(pp) && PTR_ERR(pp) == -EINPROGRESS) {
+		ret = GRO_CONSUMED;
+		goto ok;
+	}
+
 	same_flow = NAPI_GRO_CB(skb)->same_flow;
 	ret = NAPI_GRO_CB(skb)->free ? GRO_MERGED_FREE : GRO_MERGED;
 
@@ -4609,6 +4614,7 @@ static gro_result_t napi_skb_finish(gro_result_t ret, struct sk_buff *skb)
 
 	case GRO_HELD:
 	case GRO_MERGED:
+	case GRO_CONSUMED:
 		break;
 	}
 
@@ -4680,6 +4686,7 @@ static gro_result_t napi_frags_finish(struct napi_struct *napi,
 		break;
 
 	case GRO_MERGED:
+	case GRO_CONSUMED:
 		break;
 	}
 
diff --git a/net/xfrm/Kconfig b/net/xfrm/Kconfig
index bda1a13..a484451 100644
--- a/net/xfrm/Kconfig
+++ b/net/xfrm/Kconfig
@@ -5,6 +5,10 @@ config XFRM
        bool
        depends on NET
 
+config XFRM_OFFLOAD
+       bool
+       depends on XFRM
+
 config XFRM_ALGO
 	tristate
 	select XFRM
-- 
1.9.1
