From: Simon Horman <horms@verge.net.au>
Subject: [PATCH net-next v3] net: Loosen constraints for recalculating checksum in skb_segment()
Date: Mon, 20 May 2013 10:46:49 +0900
Message-ID: <1369014409-14629-1-git-send-email-horms@verge.net.au>
Cc: Jesse Gross <jesse@nicira.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	jarno.rajahalme@nsn.com, Eric Dumazet <eric.dumazet@gmail.com>,
	=?UTF-8?q?Maciej=20=C5=BBenczykowski?= <maze@google.com>,
	Simon Horman <horms@verge.net.au>
To: dev@openvswitch.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:59837 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753755Ab3ETBrQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 May 2013 21:47:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a generic solution to resolve a specific problem that I have observed.

If the encapsulation of an skb changes then ability to offload checksums
may also change. In particular it may be necessary to perform checksumming
in software.

An example of such a case is where a non-GRE packet is received but
is to be encapsulated and transmitted as GRE.

Another example relates to my proposed support for for packets
that are non-MPLS when received but MPLS when transmitted.

The cost of this change is that the value of the csum variable may be
checked when it previously was not. In the case where the csum variable is
true this is pure overhead. In the case where the csum variable is false it
leads to software checksumming, which I believe also leads to correct
checksums in transmitted packets for the cases described above.

Further analysis:

This patch relies on the return value of can_checksum_protocol()
being correct and in turn the return value of skb_network_protocol(),
used to provide the protocol parameter of can_checksum_protocol(),
being correct. It also relies on the features passed to skb_segment()
and in turn to can_checksum_protocol() being correct.

I believe that this problem has not been observed for VLANs because it
appears that almost all drivers, the exception being xgbe, set
vlan_features such that that the checksum offload support for VLAN packets
is greater than or equal to that of non-VLAN packets.

I wonder if the code in xgbe may be an oversight and the hardware does
support checksumming of VLAN packets.  If so it may be worth updating the
vlan_features of the driver as this patch will force such checksums to be
performed in software rather than hardware.

Signed-off-by: Simon Horman <horms@verge.net.au>

---

Tested using the bnx2 driver.

v3
* As suggested by Erec Dumazet:
  - Rename goto label: csum -> perform_csum_check

v2
Rewrite changelog after further analysis
---
 net/core/skbuff.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index af9185d..d629891 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2853,7 +2853,7 @@ struct sk_buff *skb_segment(struct sk_buff *skb, netdev_features_t features)
 						 doffset + tnl_hlen);
 
 		if (fskb != skb_shinfo(skb)->frag_list)
-			continue;
+			goto perform_csum_check;
 
 		if (!sg) {
 			nskb->ip_summed = CHECKSUM_NONE;
@@ -2917,6 +2917,7 @@ skip_fraglist:
 		nskb->len += nskb->data_len;
 		nskb->truesize += nskb->data_len;
 
+perform_csum_check:
 		if (!csum) {
 			nskb->csum = skb_checksum(nskb, doffset,
 						  nskb->len - doffset, 0);
-- 
1.8.2.1
