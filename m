From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next 1/6] net: Support for csum_bad in skbuff
Date: Sun, 31 Aug 2014 15:12:41 -0700
Message-ID: <1409523166-9215-2-git-send-email-therbert@google.com>
References: <1409523166-9215-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:43959 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751707AbaHaWNK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Aug 2014 18:13:10 -0400
Received: by mail-pa0-f48.google.com with SMTP id ey11so10675288pad.7
        for <netdev@vger.kernel.org>; Sun, 31 Aug 2014 15:13:09 -0700 (PDT)
In-Reply-To: <1409523166-9215-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This flag indicates that an invalid checksum was detected in the
packet. __skb_mark_checksum_bad helper function was added to set this.

Checksums can be marked bad from a driver or the GRO path (the latter
is implemented in this patch). csum_bad is checked in
__skb_checksum_validate_complete (i.e. calling that when ip_summed ==
CHECKSUM_NONE).

csum_bad works in conjunction with ip_summed value. In the case that
ip_summed is CHECKSUM_NONE and csum_bad is set, this implies that the
first (or next) checksum encountered in the packet is bad. When
ip_summed is CHECKSUM_UNNECESSARY, the first checksum after the last
one validated is bad. For example, if ip_summed == CHECKSUM_UNNECESSARY,
csum_level == 1, and csum_bad is set-- then the third checksum in the
packet is bad. In the normal path, the packet will be dropped when
processing the protocol layer of the bad checksum:
__skb_decr_checksum_unnecessary called twice for the good checksums
changing ip_summed to CHECKSUM_NONE so that
__skb_checksum_validate_complete is called to validate the third
checksum and that will fail since csum_bad is set.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/linux/netdevice.h |  4 +++-
 include/linux/skbuff.h    | 21 ++++++++++++++++++++-
 net/core/dev.c            |  2 +-
 3 files changed, 24 insertions(+), 3 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 456eb1f..024d8c1 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2216,7 +2216,9 @@ static inline void skb_gro_incr_csum_unnecessary(struct sk_buff *skb)
 	if (__skb_gro_checksum_validate_needed(skb, zero_okay, check))	\
 		__ret = __skb_gro_checksum_validate_complete(skb,	\
 				compute_pseudo(skb, proto));		\
-	if (!__ret)							\
+	if (__ret)							\
+		__skb_mark_checksum_bad(skb);				\
+	else								\
 		skb_gro_incr_csum_unnecessary(skb);			\
 	__ret;								\
 })
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index c93b585..23710a2 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -617,7 +617,8 @@ struct sk_buff {
 
 	kmemcheck_bitfield_begin(flags3);
 	__u8			csum_level:2;
-	/* 14 bit hole */
+	__u8			csum_bad:1;
+	/* 13 bit hole */
 	kmemcheck_bitfield_end(flags3);
 
 	__be16			inner_protocol;
@@ -2825,6 +2826,21 @@ static inline void __skb_incr_checksum_unnecessary(struct sk_buff *skb)
 	}
 }
 
+static inline void __skb_mark_checksum_bad(struct sk_buff *skb)
+{
+	/* Mark current checksum as bad (typically called from GRO
+	 * path). In the case that ip_summed is CHECKSUM_NONE
+	 * this must be the first checksum encountered in the packet.
+	 * When ip_summed is CHECKSUM_UNNECESSARY, this is the first
+	 * checksum after the last one validated. For UDP, a zero
+	 * checksum can not be marked as bad.
+	 */
+
+	if (skb->ip_summed == CHECKSUM_NONE ||
+	    skb->ip_summed == CHECKSUM_UNNECESSARY)
+		skb->csum_bad = 1;
+}
+
 /* Check if we need to perform checksum complete validation.
  *
  * Returns true if checksum complete is needed, false otherwise
@@ -2866,6 +2882,9 @@ static inline __sum16 __skb_checksum_validate_complete(struct sk_buff *skb,
 			skb->csum_valid = 1;
 			return 0;
 		}
+	} else if (skb->csum_bad) {
+		/* ip_summed == CHECKSUM_NONE in this case */
+		return 1;
 	}
 
 	skb->csum = psum;
diff --git a/net/core/dev.c b/net/core/dev.c
index a6077ef..960df22 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3957,7 +3957,7 @@ static enum gro_result dev_gro_receive(struct napi_struct *napi, struct sk_buff
 	if (!(skb->dev->features & NETIF_F_GRO))
 		goto normal;
 
-	if (skb_is_gso(skb) || skb_has_frag_list(skb))
+	if (skb_is_gso(skb) || skb_has_frag_list(skb) || skb->csum_bad)
 		goto normal;
 
 	gro_list_prepare(napi, skb);
-- 
2.1.0.rc2.206.gedb03e5
