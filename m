From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH v3 2/8] gso: Only allow GSO_PARTIAL if we can
 checksum the inner protocol
Date: Mon, 02 May 2016 09:38:18 -0700
Message-ID: <20160502163818.11809.37649.stgit@ahduyck-xeon-server>
References: <20160502162828.11809.92444.stgit@ahduyck-xeon-server>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: talal@mellanox.com, netdev@vger.kernel.org,
	michael.chan@broadcom.com, alexander.duyck@gmail.com,
	davem@davemloft.net, galp@mellanox.com, ogerlitz@mellanox.com,
	eranbe@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:34028 "EHLO
	mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752688AbcEBQiU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 May 2016 12:38:20 -0400
Received: by mail-pf0-f173.google.com with SMTP id y69so80602132pfb.1
        for <netdev@vger.kernel.org>; Mon, 02 May 2016 09:38:20 -0700 (PDT)
In-Reply-To: <20160502162828.11809.92444.stgit@ahduyck-xeon-server>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch addresses a possible issue that can occur if we get into any odd
corner cases where we support TSO for a given protocol but not the checksum
or scatter-gather offload.  There are few drivers floating around that
setup their tunnels this way and by enforcing the checksum piece we can
avoid mangling any frames.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 net/core/skbuff.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index b8dd2d2e2256..5586be93632f 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3080,8 +3080,7 @@ struct sk_buff *skb_segment(struct sk_buff *head_skb,
 	unsigned int headroom;
 	unsigned int len = head_skb->len;
 	__be16 proto;
-	bool csum;
-	int sg = !!(features & NETIF_F_SG);
+	bool csum, sg;
 	int nfrags = skb_shinfo(head_skb)->nr_frags;
 	int err = -ENOMEM;
 	int i = 0;
@@ -3093,13 +3092,14 @@ struct sk_buff *skb_segment(struct sk_buff *head_skb,
 	if (unlikely(!proto))
 		return ERR_PTR(-EINVAL);
 
+	sg = !!(features & NETIF_F_SG);
 	csum = !!can_checksum_protocol(features, proto);
 
 	/* GSO partial only requires that we trim off any excess that
 	 * doesn't fit into an MSS sized block, so take care of that
 	 * now.
 	 */
-	if (features & NETIF_F_GSO_PARTIAL) {
+	if (sg && csum && (features & NETIF_F_GSO_PARTIAL)) {
 		partial_segs = len / mss;
 		if (partial_segs > 1)
 			mss *= partial_segs;
