From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH net] net: Correctly set segment mac_len in skb_segment().
Date: Thu, 31 Jul 2014 10:33:06 -0400
Message-ID: <1406817186-17844-1-git-send-email-vyasevic@redhat.com>
Cc: Vlad Yasevich <vyasevic@redhat.com>,
	Eric Dumazet <edumazet@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:27210 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751235AbaGaOdT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Jul 2014 10:33:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When performing segmentation, the mac_len value is copied right
out of the original skb.  However, this value is not always set correctly
(like when the packet is VLAN-tagged) and we'll end up copying a bad
value.

One way to demonstrate this is to configure a VM which tags
packets internally and turn off VLAN acceleration on the forwarding
bridge port.  The packets show up corrupt like this:
16:18:24.985548 52:54:00:ab:be:25 > 52:54:00:26:ce:a3, ethertype 802.1Q
(0x8100), length 1518: vlan 100, p 0, ethertype 0x05e0,
        0x0000:  8cdb 1c7c 8cdb 0064 4006 b59d 0a00 6402 ...|...d@.....d.
        0x0010:  0a00 6401 9e0d b441 0a5e 64ec 0330 14fa ..d....A.^d..0..
        0x0020:  29e3 01c9 f871 0000 0101 080a 000a e833)....q.........3
        0x0030:  000f 8c75 6e65 7470 6572 6600 6e65 7470 ...unetperf.netp
        0x0040:  6572 6600 6e65 7470 6572 6600 6e65 7470 erf.netperf.netp
        0x0050:  6572 6600 6e65 7470 6572 6600 6e65 7470 erf.netperf.netp
        0x0060:  6572 6600 6e65 7470 6572 6600 6e65 7470 erf.netperf.netp
        ...

This also leads to awful throughput as GSO packets are dropped and
cause retransmissions.

The solution is to set the mac_len using the values already available
in then new skb.  We've already adjusted all of the header offset, so we
might as well correctly figure out the mac_len using skb_reset_mac_len().
After this change, packets are segmented correctly and performance
is restored.

CC: Eric Dumazet <edumazet@google.com>
Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 net/core/skbuff.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index c1a3303..58ff88e 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2976,9 +2976,9 @@ struct sk_buff *skb_segment(struct sk_buff *head_skb,
 		tail = nskb;
 
 		__copy_skb_header(nskb, head_skb);
-		nskb->mac_len = head_skb->mac_len;
 
 		skb_headers_offset_update(nskb, skb_headroom(nskb) - headroom);
+		skb_reset_mac_len(nskb);
 
 		skb_copy_from_linear_data_offset(head_skb, -tnl_hlen,
 						 nskb->data - tnl_hlen,
-- 
1.9.3
