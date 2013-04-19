From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 2/2] net: Loosen constraints for recalculating checksum in skb_segment()
Date: Fri, 19 Apr 2013 16:29:55 +0900
Message-ID: <1366356595-3405-3-git-send-email-horms@verge.net.au>
References: <1366356595-3405-1-git-send-email-horms@verge.net.au>
Cc: Jesse Gross <jesse@nicira.com>, jarno.rajahalme@nsn.com,
	Joseph Gasparakis <joseph.gasparakis@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	=?UTF-8?q?Maciej=20=C5=BBenczykowski?= <maze@google.com>,
	Simon Horman <horms@verge.net.au>
To: dev@openvswitch.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:53596 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757271Ab3DSHaN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Apr 2013 03:30:13 -0400
In-Reply-To: <1366356595-3405-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the case where a non-MPLS GSO skb becomes an MPLS GSO skb, via
Open vSwitch's push MPLS action it is desirable to provide segmentation
in software. In this case the original protocol of the skb may have allowed
its checksumming to be offloaded but this may no longer be supported now
the skb is MPLS. Actually it seems to me that this is the likely case.

In order to allow the checksum to be updated in this case loosen
the rules for recalculating the checksum on in skb_segment().

N.B.: I must confess that I am a little unsure of the details of
the implementation of skb_checksum(). But I have observed that this
is necessary as skb_checksum() hits the following:

		if (!hsize && i >= nfrags) {
			...
			fskb = fskb->next;
			...
		}
		...
		if (fskb != skb_shinfo(skb)->frag_list)
			...

Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/core/skbuff.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 7504371..e3bb024 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2825,7 +2825,7 @@ struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features)
 						 doffset + tnl_hlen);
 
 		if (fskb != skb_shinfo(skb)->frag_list)
-			continue;
+			goto csum;
 
 		if (!sg) {
 			nskb->ip_summed = CHECKSUM_NONE;
@@ -2889,6 +2889,7 @@ skip_fraglist:
 		nskb->len += nskb->data_len;
 		nskb->truesize += nskb->data_len;
 
+csum:
 		if (!csum) {
 			nskb->csum = skb_checksum(nskb, doffset,
 						  nskb->len - doffset, 0);
-- 
1.7.10.4
