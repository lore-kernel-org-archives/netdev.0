From: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
Subject: [PATCH net-next 2/5] 6lowpan: simplify/fix payload length calculation
Date: Tue, 13 May 2014 19:24:03 +0200
Message-ID: <1400001846-5349-3-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
References: <1400001846-5349-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Cc: linux-zigbee-devel@lists.sourceforge.net, davem@davemloft.net,
	Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw1.uni-kl.de ([131.246.120.220]:39668 "EHLO
	mailgw1.uni-kl.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751511AbaEMRYY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2014 13:24:24 -0400
Received: from itwm2.itwm.fhg.de (itwm2.itwm.fhg.de [131.246.191.3])
	by mailgw1.uni-kl.de (8.14.3/8.14.3/Debian-9.4) with ESMTP id s4DHOL50024091
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 13 May 2014 19:24:21 +0200
In-Reply-To: <1400001846-5349-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of accounting for all fields of a packet we can think about,
simply peek the header of a packet we're building and ask ieee802154 how
many bytes of payload space we have. This also accounts for security
headers, which were ignored previously.

Signed-off-by: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
---
 net/ieee802154/6lowpan_rtnl.c |   24 ++++++++++++++++--------
 1 file changed, 16 insertions(+), 8 deletions(-)

diff --git a/net/ieee802154/6lowpan_rtnl.c b/net/ieee802154/6lowpan_rtnl.c
index 0f5a69e..3e11b46 100644
--- a/net/ieee802154/6lowpan_rtnl.c
+++ b/net/ieee802154/6lowpan_rtnl.c
@@ -256,6 +256,19 @@ lowpan_fragment_xmit(struct sk_buff *skb, u8 *head,
 	return dev_queue_xmit(frag);
 }
 
+static int lowpan_fragment_plen(struct sk_buff *skb, int extra)
+{
+	struct ieee802154_hdr hdr;
+
+	ieee802154_hdr_peek(skb, &hdr);
+
+	/* calc the nearest payload length(divided to 8) for a fragment with
+	 * a given 802.15.4 hdr and additional lowpan headers which fits into
+	 * IEEE802154_MTU
+	 */
+	return round_down(ieee802154_max_payload(&hdr) - extra, 8);
+}
+
 static int
 lowpan_skb_fragmentation(struct sk_buff *skb, struct net_device *dev)
 {
@@ -277,12 +290,8 @@ lowpan_skb_fragmentation(struct sk_buff *skb, struct net_device *dev)
 	head[1] = dgram_size & 0xff;
 	memcpy(head + 2, &tag, sizeof(tag));
 
-	/* calc the nearest payload length(divided to 8) for first fragment
-	 * which fits into a IEEE802154_MTU
-	 */
-	frag_plen = round_down(IEEE802154_MTU - header_length -
-			       LOWPAN_FRAG1_HEAD_SIZE - lowpan_size -
-			       IEEE802154_MFR_SIZE, 8);
+	frag_plen = lowpan_fragment_plen(skb, LOWPAN_FRAG1_HEAD_SIZE +
+					 lowpan_size);
 
 	err = lowpan_fragment_xmit(skb, head, header_length,
 				   frag_plen + lowpan_size, 0,
@@ -300,8 +309,7 @@ lowpan_skb_fragmentation(struct sk_buff *skb, struct net_device *dev)
 	head[0] &= ~LOWPAN_DISPATCH_FRAG1;
 	head[0] |= LOWPAN_DISPATCH_FRAGN;
 
-	frag_plen = round_down(IEEE802154_MTU - header_length -
-			       LOWPAN_FRAGN_HEAD_SIZE - IEEE802154_MFR_SIZE, 8);
+	frag_plen = lowpan_fragment_plen(skb, LOWPAN_FRAGN_HEAD_SIZE);
 
 	while (payload_length - offset > 0) {
 		int len = frag_plen;
-- 
1.7.9.5
