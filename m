From: Dave Wiltshire <david.wiltshire@gmx.com>
Subject: [PATCH 1/3] skbuff: Update truesize in pskb_expand_head
Date: Wed, 12 Jun 2013 19:05:32 +1000
Message-ID: <1371027934-1955-2-git-send-email-david.wiltshire@gmx.com>
References: <1371027934-1955-1-git-send-email-david.wiltshire@gmx.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	nsujir@broadcom.com, mchan@broadcom.com, rmody@brocade.com,
	jcliburn@gmail.com, chris.snook@gmail.com,
	jeffrey.t.kirsher@intel.com, bruce.w.allan@intel.com,
	alexander.h.duyck@intel.com, cooldavid@cooldavid.org,
	linux-driver@qlogic.com, linux-wimax@intel.com,
	wimax@linuxwimax.org, linux-wireless@vger.kernel.org,
	viro@zeniv.linux.org.uk, eparis@redhat.com, edumazet@google.com,
	dev@openvswitch.org, jhs@mojatatu.com,
	Dave Wiltshire <david.wiltshire@gmx.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.22]:57410 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755940Ab3FLJGB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Jun 2013 05:06:01 -0400
In-Reply-To: <1371027934-1955-1-git-send-email-david.wiltshire@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some call sites to pskb_expand_head subsequently update the skb truesize
and others don't (even with non-zero arguments). This is likely a memory
audit leak. Fixed this up by moving the memory accounting to the
skbuff.c file and removing it from the calling sites.

Signed-off-by: Dave Wiltshire <david.wiltshire@gmx.com>
---
 drivers/net/wireless/mwl8k.c |    1 -
 kernel/audit.c               |    2 --
 net/core/skbuff.c            |    1 +
 net/netlink/af_netlink.c     |    3 +--
 net/wireless/util.c          |    2 --
 5 files changed, 2 insertions(+), 7 deletions(-)

diff --git a/drivers/net/wireless/mwl8k.c b/drivers/net/wireless/mwl8k.c
index 6820fce..802c8d7 100644
--- a/drivers/net/wireless/mwl8k.c
+++ b/drivers/net/wireless/mwl8k.c
@@ -845,7 +845,6 @@ mwl8k_add_dma_header(struct mwl8k_priv *priv, struct sk_buff *skb,
 					"Failed to reallocate TX buffer\n");
 			return;
 		}
-		skb->truesize += REDUCED_TX_HEADROOM;
 	}
 
 	reqd_hdrlen = sizeof(*tr) + head_pad;
diff --git a/kernel/audit.c b/kernel/audit.c
index 21c7fa6..e05b57b 100644
--- a/kernel/audit.c
+++ b/kernel/audit.c
@@ -1157,7 +1157,6 @@ struct audit_buffer *audit_log_start(struct audit_context *ctx, gfp_t gfp_mask,
 static inline int audit_expand(struct audit_buffer *ab, int extra)
 {
 	struct sk_buff *skb = ab->skb;
-	int oldtail = skb_tailroom(skb);
 	int ret = pskb_expand_head(skb, 0, extra, ab->gfp_mask);
 	int newtail = skb_tailroom(skb);
 
@@ -1166,7 +1165,6 @@ static inline int audit_expand(struct audit_buffer *ab, int extra)
 		return 0;
 	}
 
-	skb->truesize += newtail - oldtail;
 	return newtail;
 }
 
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index edf3757..125bb7e 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -1061,6 +1061,7 @@ int pskb_expand_head(struct sk_buff *skb, int nhead, int ntail,
 	if (!data)
 		goto nodata;
 	size = SKB_WITH_OVERHEAD(ksize(data));
+	skb->truesize += size - skb_end_offset(skb);
 
 	/* Copy only real data... and, alas, header. This should be
 	 * optimized for the cases when header is void.
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 9b6b115..77fd986 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1565,8 +1565,7 @@ static struct sk_buff *netlink_trim(struct sk_buff *skb, gfp_t allocation)
 		skb = nskb;
 	}
 
-	if (!pskb_expand_head(skb, 0, -delta, allocation))
-		skb->truesize -= delta;
+	pskb_expand_head(skb, 0, -delta, allocation);
 
 	return skb;
 }
diff --git a/net/wireless/util.c b/net/wireless/util.c
index f5ad4d9..5710aa2 100644
--- a/net/wireless/util.c
+++ b/net/wireless/util.c
@@ -533,8 +533,6 @@ int ieee80211_data_from_8023(struct sk_buff *skb, const u8 *addr,
 
 		if (pskb_expand_head(skb, head_need, 0, GFP_ATOMIC))
 			return -ENOMEM;
-
-		skb->truesize += head_need;
 	}
 
 	if (encaps_data) {
-- 
1.7.10.4
