From: Sven Eckelmann <sven@narfation.org>
Subject: [PATCH 1/9] batman-adv: Create roughly equal sized fragments
Date: Mon, 31 Jan 2011 16:20:43 +0100
Message-ID: <1296487251-12552-2-git-send-email-sven@narfation.org>
References: <1296487251-12552-1-git-send-email-sven@narfation.org>
Cc: netdev@vger.kernel.org, Sven Eckelmann <sven@narfation.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from narfation.org ([79.140.41.39]:42648 "EHLO v3-1039.vlinux.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752746Ab1AaPVG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Jan 2011 10:21:06 -0500
In-Reply-To: <1296487251-12552-1-git-send-email-sven@narfation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The routing algorithm must know how large two fragments are to be able to
decide that it is safe to merge them or if it should resubmit without waiting
for the second part. When these two fragments have a too different size, it is
not possible to guess right in every situation.

The user could easily configure the MTU of the attached cards so that one
fragment is forwarded and the other one is added to the fragments table to wait
for the missing part.

For even sized packets, it is possible to split it so that the resulting
packages are equal sized by ignoring the old non-fragment header at the
beginning of the original packet.

This still creates different sized fragments for uneven sized packets.

Reported-by: Russell Senior <russell@personaltelco.net>
Reported-by: Marek Lindner <lindner_marek@yahoo.de>
Signed-off-by: Sven Eckelmann <sven@narfation.org>
---
 net/batman-adv/unicast.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/batman-adv/unicast.c b/net/batman-adv/unicast.c
index ee41fef..811f7fc 100644
--- a/net/batman-adv/unicast.c
+++ b/net/batman-adv/unicast.c
@@ -224,7 +224,7 @@ int frag_send_skb(struct sk_buff *skb, struct bat_priv *bat_priv,
 	struct unicast_frag_packet *frag1, *frag2;
 	int uc_hdr_len = sizeof(struct unicast_packet);
 	int ucf_hdr_len = sizeof(struct unicast_frag_packet);
-	int data_len = skb->len;
+	int data_len = skb->len - uc_hdr_len;
 
 	if (!bat_priv->primary_if)
 		goto dropped;
@@ -232,10 +232,11 @@ int frag_send_skb(struct sk_buff *skb, struct bat_priv *bat_priv,
 	frag_skb = dev_alloc_skb(data_len - (data_len / 2) + ucf_hdr_len);
 	if (!frag_skb)
 		goto dropped;
+	skb_reserve(frag_skb, ucf_hdr_len);
 
 	unicast_packet = (struct unicast_packet *) skb->data;
 	memcpy(&tmp_uc, unicast_packet, uc_hdr_len);
-	skb_split(skb, frag_skb, data_len / 2);
+	skb_split(skb, frag_skb, data_len / 2 + uc_hdr_len);
 
 	if (my_skb_head_push(skb, ucf_hdr_len - uc_hdr_len) < 0 ||
 	    my_skb_head_push(frag_skb, ucf_hdr_len) < 0)
-- 
1.7.2.3

