From: Florian Westphal <fw@strlen.de>
Subject: [PATCH RFC 01/14] net: gro: shrink napi_gro_cb to fit into hypothetical 44-byte sized skb cb
Date: Mon,  2 Mar 2015 18:40:15 +0100
Message-ID: <1425318028-26531-2-git-send-email-fw@strlen.de>
References: <1425318028-26531-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:54104 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753962AbbCBRkj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2015 12:40:39 -0500
In-Reply-To: <1425318028-26531-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>From 48 down to 42 bytes using reordering + bitfields.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 include/linux/netdevice.h | 28 +++++++++++++---------------
 1 file changed, 13 insertions(+), 15 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 5897b4e..7427185 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1914,8 +1914,11 @@ struct napi_gro_cb {
 	/* This indicates where we are processing relative to skb->data. */
 	int data_offset;
 
-	/* This is non-zero if the packet cannot be merged with the new skb. */
-	u16	flush;
+	/* used in skb_gro_receive() slow path */
+	struct sk_buff *last;
+
+	/* Used in ipv6_gro_receive() and foo-over-udp */
+	u16	proto;
 
 	/* Save the IP ID here and check when we get to the transport layer */
 	u16	flush_id;
@@ -1926,11 +1929,11 @@ struct napi_gro_cb {
 	/* Start offset for remote checksum offload */
 	u16	gro_remcsum_start;
 
-	/* jiffies when first packet was created/queued */
-	unsigned long age;
+	/* used to support CHECKSUM_COMPLETE for tunneling protocols */
+	__wsum	csum;
 
-	/* Used in ipv6_gro_receive() and foo-over-udp */
-	u16	proto;
+	/* jiffies when first packet was created/queued */
+	unsigned int age;
 
 	/* This is non-zero if the packet may be of the same flow. */
 	u8	same_flow:1;
@@ -1950,16 +1953,11 @@ struct napi_gro_cb {
 #define NAPI_GRO_FREE_STOLEN_HEAD 2
 
 	/* Used in foo-over-udp, set in udp[46]_gro_receive */
-	u8	is_ipv6:1;
-
-	/* 7 bit hole */
+	u8	is_ipv6:1,
+		flush:1;
 
-	/* used to support CHECKSUM_COMPLETE for tunneling protocols */
-	__wsum	csum;
-
-	/* used in skb_gro_receive() slow path */
-	struct sk_buff *last;
-};
+	/* 6 bit hole */
+} __packed;
 
 #define NAPI_GRO_CB(skb) ((struct napi_gro_cb *)(skb)->cb)
 
-- 
2.0.5
