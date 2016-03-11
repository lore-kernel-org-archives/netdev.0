From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH 3/3] GSO/UDP: Use skb->len instead of udph->len to
 determine length of original skb
Date: Fri, 11 Mar 2016 14:05:47 -0800
Message-ID: <20160311220547.13431.40563.stgit@localhost.localdomain>
References: <20160311215423.13431.64512.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:34631 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932883AbcCKWFt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Mar 2016 17:05:49 -0500
Received: by mail-pa0-f48.google.com with SMTP id fe3so93189972pab.1
        for <netdev@vger.kernel.org>; Fri, 11 Mar 2016 14:05:48 -0800 (PST)
In-Reply-To: <20160311215423.13431.64512.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is possible for tunnels to end up generating IP or IPv6 datagrams that
are larger than 64K and expecting to be segmented.  As such we need to deal
with length values greater than 64K.  In order to accommodate this we need
to update the code to work with a 32b length value instead of a 16b one.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 net/ipv4/udp_offload.c |   15 ++++++++++-----
 1 file changed, 10 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
index f5abb1ae1358..8a3405a80260 100644
--- a/net/ipv4/udp_offload.c
+++ b/net/ipv4/udp_offload.c
@@ -40,13 +40,19 @@ static struct sk_buff *__skb_udp_tunnel_segment(struct sk_buff *skb,
 	__be16 protocol = skb->protocol;
 	u16 mac_len = skb->mac_len;
 	int udp_offset, outer_hlen;
-	u32 partial;
+	__wsum partial;
 
 	if (unlikely(!pskb_may_pull(skb, tnl_hlen)))
 		goto out;
 
-	/* adjust partial header checksum to negate old length */
-	partial = (__force u32)uh->check + (__force u16)~uh->len;
+	/* Adjust partial header checksum to negate old length.
+	 * We cannot rely on the value contained in uh->len as it is
+	 * possible that the actual value exceeds the boundaries of the
+	 * 16 bit length field due to the header being added outside of an
+	 * IP or IPv6 frame that was already limited to 64K - 1.
+	 */
+	partial = csum_sub(csum_unfold(uh->check),
+			   (__force __wsum)htonl(skb->len));
 
 	/* setup inner skb. */
 	skb->encapsulation = 0;
@@ -119,8 +125,7 @@ static struct sk_buff *__skb_udp_tunnel_segment(struct sk_buff *skb,
 		if (!need_csum)
 			continue;
 
-		uh->check = ~csum_fold((__force __wsum)
-				       ((__force u32)len + partial));
+		uh->check = ~csum_fold(csum_add(partial, (__force __wsum)len));
 
 		if (skb->encapsulation || !offload_csum) {
 			uh->check = gso_make_checksum(skb, ~uh->check);
