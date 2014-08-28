From: Tom Herbert <therbert@google.com>
Subject: [PATCH v2 net-next 3/9] net: Allow GRO to use and set levels of
 checksum unnecessary
Date: Wed, 27 Aug 2014 21:26:56 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1408272109090.31960@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f202.google.com ([209.85.160.202]:34376 "EHLO
	mail-yk0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753664AbaH1LXO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Aug 2014 07:23:14 -0400
Received: by mail-yk0-f202.google.com with SMTP id q9so176688ykb.5
        for <netdev@vger.kernel.org>; Thu, 28 Aug 2014 04:23:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow GRO path to "consume" checksums provided in CHECKSUM_UNNECESSARY
and to report new checksums verfied for use in fallback to normal
path.

Change GRO checksum path to track csum_level using a csum_cnt field
in NAPI_GRO_CB. On GRO initialization, if ip_summed is
CHECKSUM_UNNECESSARY set NAPI_GRO_CB(skb)->csum_cnt to
skb->csum_level + 1. For each checksum verified, decrement
NAPI_GRO_CB(skb)->csum_cnt while its greater than zero. If a checksum
is verfied and NAPI_GRO_CB(skb)->csum_cnt == 0, we have verified a
deeper checksum than originally indicated in skbuf so increment
csum_level (or initialize to CHECKSUM_UNNECESSARY if ip_summed is
CHECKSUM_NONE or CHECKSUM_COMPLETE).

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/linux/netdevice.h | 26 ++++++++++++--------------
 net/core/dev.c            | 24 ++++++++++++++++--------
 net/ipv4/gre_offload.c    |  7 ++-----
 net/ipv4/udp_offload.c    |  5 +++--
 4 files changed, 33 insertions(+), 29 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 039b237..cbec9fa 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1888,8 +1888,8 @@ struct napi_gro_cb {
 	/* GRO checksum is valid */
 	u8	csum_valid:1;
 
-	/* Number encapsulation layers crossed */
-	u8	encapsulation;
+	/* Number of checksums via CHECKSUM_UNNECESSARY */
+	u8	csum_cnt:3;
 
 	/* used to support CHECKSUM_COMPLETE for tunneling protocols */
 	__wsum	csum;
@@ -2177,8 +2177,7 @@ static inline bool __skb_gro_checksum_validate_needed(struct sk_buff *skb,
 						      __sum16 check)
 {
 	return (skb->ip_summed != CHECKSUM_PARTIAL &&
-		(skb->ip_summed != CHECKSUM_UNNECESSARY ||
-		 (NAPI_GRO_CB(skb)->encapsulation > skb->encapsulation)) &&
+		NAPI_GRO_CB(skb)->csum_cnt == 0 &&
 		(!zero_okay || check));
 }
 
@@ -2194,18 +2193,17 @@ static inline __sum16 __skb_gro_checksum_validate_complete(struct sk_buff *skb,
 	return __skb_gro_checksum_complete(skb);
 }
 
-/* Update skb for CHECKSUM_UNNECESSARY when we verified a top level
- * checksum or an encapsulated one during GRO. This saves work
- * if we fallback to normal path with the packet.
- */
 static inline void skb_gro_incr_csum_unnecessary(struct sk_buff *skb)
 {
-	if (skb->ip_summed == CHECKSUM_UNNECESSARY) {
-		if (NAPI_GRO_CB(skb)->encapsulation)
-			skb->encapsulation = 1;
-	} else if (skb->ip_summed != CHECKSUM_PARTIAL) {
-		skb->ip_summed = CHECKSUM_UNNECESSARY;
-		skb->encapsulation = 0;
+	if (NAPI_GRO_CB(skb)->csum_cnt > 0) {
+		/* Consume a checksum from CHECKSUM_UNNECESSARY */
+		NAPI_GRO_CB(skb)->csum_cnt--;
+	} else {
+		/* Update skb for CHECKSUM_UNNECESSARY and csum_level when we
+		 * verified a new top level checksum or an encapsulated one
+		 * during GRO. This saves work if we fallback to normal path.
+		 */
+		__skb_incr_checksum_unnecessary(skb);
 	}
 }
 
diff --git a/net/core/dev.c b/net/core/dev.c
index 26d296c..a6077ef 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3962,13 +3962,6 @@ static enum gro_result dev_gro_receive(struct napi_struct *napi, struct sk_buff
 
 	gro_list_prepare(napi, skb);
 
-	if (skb->ip_summed == CHECKSUM_COMPLETE) {
-		NAPI_GRO_CB(skb)->csum = skb->csum;
-		NAPI_GRO_CB(skb)->csum_valid = 1;
-	} else {
-		NAPI_GRO_CB(skb)->csum_valid = 0;
-	}
-
 	rcu_read_lock();
 	list_for_each_entry_rcu(ptype, head, list) {
 		if (ptype->type != type || !ptype->callbacks.gro_receive)
@@ -3980,7 +3973,22 @@ static enum gro_result dev_gro_receive(struct napi_struct *napi, struct sk_buff
 		NAPI_GRO_CB(skb)->flush = 0;
 		NAPI_GRO_CB(skb)->free = 0;
 		NAPI_GRO_CB(skb)->udp_mark = 0;
-		NAPI_GRO_CB(skb)->encapsulation = 0;
+
+		/* Setup for GRO checksum validation */
+		switch (skb->ip_summed) {
+		case CHECKSUM_COMPLETE:
+			NAPI_GRO_CB(skb)->csum = skb->csum;
+			NAPI_GRO_CB(skb)->csum_valid = 1;
+			NAPI_GRO_CB(skb)->csum_cnt = 0;
+			break;
+		case CHECKSUM_UNNECESSARY:
+			NAPI_GRO_CB(skb)->csum_cnt = skb->csum_level + 1;
+			NAPI_GRO_CB(skb)->csum_valid = 0;
+			break;
+		default:
+			NAPI_GRO_CB(skb)->csum_cnt = 0;
+			NAPI_GRO_CB(skb)->csum_valid = 0;
+		}
 
 		pp = ptype->callbacks.gro_receive(&napi->gro_list, skb);
 		break;
diff --git a/net/ipv4/gre_offload.c b/net/ipv4/gre_offload.c
index d1bd169..a4d7965 100644
--- a/net/ipv4/gre_offload.c
+++ b/net/ipv4/gre_offload.c
@@ -172,12 +172,9 @@ static struct sk_buff **gre_gro_receive(struct sk_buff **head,
 	}
 
 	/* Don't bother verifying checksum if we're going to flush anyway. */
-	if (greh->flags & GRE_CSUM) {
-		if (!NAPI_GRO_CB(skb)->flush &&
-		    skb_gro_checksum_simple_validate(skb))
+	if ((greh->flags & GRE_CSUM) && !NAPI_GRO_CB(skb)->flush &&
+	    skb_gro_checksum_simple_validate(skb))
 			goto out_unlock;
-		NAPI_GRO_CB(skb)->encapsulation++;
-	}
 
 	flush = 0;
 
diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
index 8ed460e..a6adff9 100644
--- a/net/ipv4/udp_offload.c
+++ b/net/ipv4/udp_offload.c
@@ -238,12 +238,13 @@ struct sk_buff **udp_gro_receive(struct sk_buff **head, struct sk_buff *skb,
 	int flush = 1;
 
 	if (NAPI_GRO_CB(skb)->udp_mark ||
-	    (!skb->encapsulation && !NAPI_GRO_CB(skb)->csum_valid))
+	    (skb->ip_summed != CHECKSUM_PARTIAL &&
+	     NAPI_GRO_CB(skb)->csum_cnt == 0 &&
+	     !NAPI_GRO_CB(skb)->csum_valid))
 		goto out;
 
 	/* mark that this skb passed once through the udp gro layer */
 	NAPI_GRO_CB(skb)->udp_mark = 1;
-	NAPI_GRO_CB(skb)->encapsulation++;
 
 	rcu_read_lock();
 	uo_priv = rcu_dereference(udp_offload_base);
-- 
2.1.0.rc2.206.gedb03e5
