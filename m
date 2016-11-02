From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net-next] net: remove unused argument in checksum unnecessary conversion
Date: Wed,  2 Nov 2016 16:14:11 -0400
Message-ID: <1478117651-24909-1-git-send-email-willemdebruijn.kernel@gmail.com>
Cc: tom@herbertland.com, davem@davemloft.net,
        Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:34564 "EHLO
        mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932366AbcKBUOP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2016 16:14:15 -0400
Received: by mail-qt0-f196.google.com with SMTP id l20so965904qta.1
        for <netdev@vger.kernel.org>; Wed, 02 Nov 2016 13:14:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

The check argument is never used. This code has not changed since
the original introduction in d96535a17dbb ("net: Infrastructure for
checksum unnecessary conversions"). Remove the unused argument and
update all callers.

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 include/linux/netdevice.h | 6 +++---
 include/linux/skbuff.h    | 8 +++-----
 net/ipv4/gre_demux.c      | 3 +--
 net/ipv4/gre_offload.c    | 2 +-
 net/ipv4/udp.c            | 2 +-
 net/ipv4/udp_offload.c    | 2 +-
 net/ipv6/udp.c            | 2 +-
 net/ipv6/udp_offload.c    | 2 +-
 8 files changed, 12 insertions(+), 15 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 66fd61c..ede9e45 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2582,16 +2582,16 @@ static inline bool __skb_gro_checksum_convert_check(struct sk_buff *skb)
 }
 
 static inline void __skb_gro_checksum_convert(struct sk_buff *skb,
-					      __sum16 check, __wsum pseudo)
+					      __wsum pseudo)
 {
 	NAPI_GRO_CB(skb)->csum = ~pseudo;
 	NAPI_GRO_CB(skb)->csum_valid = 1;
 }
 
-#define skb_gro_checksum_try_convert(skb, proto, check, compute_pseudo)	\
+#define skb_gro_checksum_try_convert(skb, proto, compute_pseudo)	\
 do {									\
 	if (__skb_gro_checksum_convert_check(skb))			\
-		__skb_gro_checksum_convert(skb, check,			\
+		__skb_gro_checksum_convert(skb,				\
 					   compute_pseudo(skb, proto));	\
 } while (0)
 
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index cc6e23e..e138591 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -3492,18 +3492,16 @@ static inline bool __skb_checksum_convert_check(struct sk_buff *skb)
 		skb->csum_valid && !skb->csum_bad);
 }
 
-static inline void __skb_checksum_convert(struct sk_buff *skb,
-					  __sum16 check, __wsum pseudo)
+static inline void __skb_checksum_convert(struct sk_buff *skb, __wsum pseudo)
 {
 	skb->csum = ~pseudo;
 	skb->ip_summed = CHECKSUM_COMPLETE;
 }
 
-#define skb_checksum_try_convert(skb, proto, check, compute_pseudo)	\
+#define skb_checksum_try_convert(skb, proto, compute_pseudo)		\
 do {									\
 	if (__skb_checksum_convert_check(skb))				\
-		__skb_checksum_convert(skb, check,			\
-				       compute_pseudo(skb, proto));	\
+		__skb_checksum_convert(skb, compute_pseudo(skb, proto));\
 } while (0)
 
 static inline void skb_remcsum_adjust_partial(struct sk_buff *skb, void *ptr,
diff --git a/net/ipv4/gre_demux.c b/net/ipv4/gre_demux.c
index b798862..05eecf0 100644
--- a/net/ipv4/gre_demux.c
+++ b/net/ipv4/gre_demux.c
@@ -91,8 +91,7 @@ int gre_parse_header(struct sk_buff *skb, struct tnl_ptk_info *tpi,
 			return -EINVAL;
 		}
 
-		skb_checksum_try_convert(skb, IPPROTO_GRE, 0,
-					 null_compute_pseudo);
+		skb_checksum_try_convert(skb, IPPROTO_GRE, null_compute_pseudo);
 		options++;
 	}
 
diff --git a/net/ipv4/gre_offload.c b/net/ipv4/gre_offload.c
index d5cac99..600ecd7 100644
--- a/net/ipv4/gre_offload.c
+++ b/net/ipv4/gre_offload.c
@@ -190,7 +190,7 @@ static struct sk_buff **gre_gro_receive(struct sk_buff **head,
 		if (skb_gro_checksum_simple_validate(skb))
 			goto out_unlock;
 
-		skb_gro_checksum_try_convert(skb, IPPROTO_GRE, 0,
+		skb_gro_checksum_try_convert(skb, IPPROTO_GRE,
 					     null_compute_pseudo);
 	}
 
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 195992e..48bad11 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1869,7 +1869,7 @@ int __udp4_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
 		int ret;
 
 		if (inet_get_convert_csum(sk) && uh->check && !IS_UDPLITE(sk))
-			skb_checksum_try_convert(skb, IPPROTO_UDP, uh->check,
+			skb_checksum_try_convert(skb, IPPROTO_UDP,
 						 inet_compute_pseudo);
 
 		ret = udp_queue_rcv_skb(sk, skb);
diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
index b2be1d9..96c2b44 100644
--- a/net/ipv4/udp_offload.c
+++ b/net/ipv4/udp_offload.c
@@ -321,7 +321,7 @@ static struct sk_buff **udp4_gro_receive(struct sk_buff **head,
 						 inet_gro_compute_pseudo))
 		goto flush;
 	else if (uh->check)
-		skb_gro_checksum_try_convert(skb, IPPROTO_UDP, uh->check,
+		skb_gro_checksum_try_convert(skb, IPPROTO_UDP,
 					     inet_gro_compute_pseudo);
 skip:
 	NAPI_GRO_CB(skb)->is_ipv6 = 0;
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index a7700bb..bf3e703 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -804,7 +804,7 @@ int __udp6_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
 		}
 
 		if (inet_get_convert_csum(sk) && uh->check && !IS_UDPLITE(sk))
-			skb_checksum_try_convert(skb, IPPROTO_UDP, uh->check,
+			skb_checksum_try_convert(skb, IPPROTO_UDP,
 						 ip6_compute_pseudo);
 
 		ret = udpv6_queue_rcv_skb(sk, skb);
diff --git a/net/ipv6/udp_offload.c b/net/ipv6/udp_offload.c
index ac858c4..6df7be0 100644
--- a/net/ipv6/udp_offload.c
+++ b/net/ipv6/udp_offload.c
@@ -135,7 +135,7 @@ static struct sk_buff **udp6_gro_receive(struct sk_buff **head,
 						 ip6_gro_compute_pseudo))
 		goto flush;
 	else if (uh->check)
-		skb_gro_checksum_try_convert(skb, IPPROTO_UDP, uh->check,
+		skb_gro_checksum_try_convert(skb, IPPROTO_UDP,
 					     ip6_gro_compute_pseudo);
 
 skip:
-- 
2.8.0.rc3.226.g39d4020
