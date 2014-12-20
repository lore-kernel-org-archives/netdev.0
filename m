From: Sven Eckelmann <sven@narfation.org>
Subject: [PATCH 2/3] batman-adv: Unify fragment size calculation
Date: Sat, 20 Dec 2014 13:48:56 +0100
Message-ID: <1419079737-31107-3-git-send-email-sven@narfation.org>
References: <1419079737-31107-1-git-send-email-sven@narfation.org>
Cc: netdev@vger.kernel.org, Sven Eckelmann <sven@narfation.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from narfation.org ([79.140.41.39]:58304 "EHLO v3-1039.vlinux.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752835AbaLTM61 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 20 Dec 2014 07:58:27 -0500
In-Reply-To: <1419079737-31107-1-git-send-email-sven@narfation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The fragmentation code was replaced in 610bfc6bc99bc83680d190ebc69359a05fc7f605
("batman-adv: Receive fragmented packets and merge") by an implementation which
can handle up to 16 fragments of a packet. The packet is prepared for the split
in fragments by the function batadv_frag_send_packet and the actual split is
done by batadv_frag_create.

Both functions calculate the size of a fragment themself. But their calculation
differs because batadv_frag_send_packet also subtracts ETH_HLEN. Therefore,
the check in batadv_frag_send_packet "can a full fragment can be created?" may
return true even when batadv_frag_create cannot create a full fragment.

The function batadv_frag_create doesn't check the size of the skb before
splitting it and therefore might try to create a larger fragment than the
remaining buffer. This creates an integer underflow and an invalid len is given
to skb_split.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
---
Problem is in the kernel since v3.13 and may be important for the stable tree.


 net/batman-adv/fragmentation.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/batman-adv/fragmentation.c b/net/batman-adv/fragmentation.c
index 8af3461..00f9e14 100644
--- a/net/batman-adv/fragmentation.c
+++ b/net/batman-adv/fragmentation.c
@@ -434,7 +434,7 @@ bool batadv_frag_send_packet(struct sk_buff *skb,
 	 * fragments larger than BATADV_FRAG_MAX_FRAG_SIZE
 	 */
 	mtu = min_t(unsigned, mtu, BATADV_FRAG_MAX_FRAG_SIZE);
-	max_fragment_size = (mtu - header_size - ETH_HLEN);
+	max_fragment_size = mtu - header_size;
 	max_packet_size = max_fragment_size * BATADV_FRAG_MAX_FRAGMENTS;
 
 	/* Don't even try to fragment, if we need more than 16 fragments */
-- 
2.1.4
