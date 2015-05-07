From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [PATCH 02/10] igb: Don't use NETDEV_FRAG_PAGE_MAX_SIZE in
 descriptor calculation
Date: Wed, 06 May 2015 21:11:45 -0700
Message-ID: <20150507041145.1873.66455.stgit@ahduyck-vm-fedora22>
References: <20150507035558.1873.52664.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, davem@davemloft.net,
	eric.dumazet@gmail.com
To: netdev@vger.kernel.org, linux-mm@kvack.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52373 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750806AbbEGELq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 May 2015 00:11:46 -0400
In-Reply-To: <20150507035558.1873.52664.stgit@ahduyck-vm-fedora22>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change updates igb so that it will correctly perform the descriptor
count calculation.  Previously it was taking NETDEV_FRAG_PAGE_MAX_SIZE
into account with isn't really correct since a different value is used to
determine the size of the pages used for TCP.  That is actually determined
by SKB_FRAG_PAGE_ORDER.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c |   11 +++--------
 1 file changed, 3 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index d3b4098fce48..1394642e4859 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -4974,6 +4974,7 @@ netdev_tx_t igb_xmit_frame_ring(struct sk_buff *skb,
 	struct igb_tx_buffer *first;
 	int tso;
 	u32 tx_flags = 0;
+	unsigned short f;
 	u16 count = TXD_USE_COUNT(skb_headlen(skb));
 	__be16 protocol = vlan_get_protocol(skb);
 	u8 hdr_len = 0;
@@ -4984,14 +4985,8 @@ netdev_tx_t igb_xmit_frame_ring(struct sk_buff *skb,
 	 *       + 1 desc for context descriptor,
 	 * otherwise try next time
 	 */
-	if (NETDEV_FRAG_PAGE_MAX_SIZE > IGB_MAX_DATA_PER_TXD) {
-		unsigned short f;
-
-		for (f = 0; f < skb_shinfo(skb)->nr_frags; f++)
-			count += TXD_USE_COUNT(skb_shinfo(skb)->frags[f].size);
-	} else {
-		count += skb_shinfo(skb)->nr_frags;
-	}
+	for (f = 0; f < skb_shinfo(skb)->nr_frags; f++)
+		count += TXD_USE_COUNT(skb_shinfo(skb)->frags[f].size);
 
 	if (igb_maybe_stop_tx(tx_ring, count + 3)) {
 		/* this is a hard error */
