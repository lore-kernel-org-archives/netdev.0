From: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH net-next] 6lowpan_rtnl: fix
	fragmentation with two fragments
Date: Mon,  2 Jun 2014 11:30:27 +0200
Message-ID: <1401701427-1082-1-git-send-email-alex.aring@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch fix the 6LoWPAN fragmentation for the case if we have exactly
two fragments. The problem is that the (skb_unprocessed >= frag_cap)
condition is always false on the second fragment after sending the first
fragment. A fragmentation with only one fragment doesn't make any sense.
The solution is that we use a do while loop here, that ensures we sending
always a minimum of two fragments if we need a fragmentation.

This issue was introduced by commit d4b2816d67d6e07b2f27037f282d8db03a5829d7
("6lowpan: fix fragmentation").

Signed-off-by: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 net/ieee802154/6lowpan_rtnl.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ieee802154/6lowpan_rtnl.c b/net/ieee802154/6lowpan_rtnl.c
index 1ae8a56..9d57026 100644
--- a/net/ieee802154/6lowpan_rtnl.c
+++ b/net/ieee802154/6lowpan_rtnl.c
@@ -312,7 +312,7 @@ lowpan_xmit_fragmented(struct sk_buff *skb, struct net_device *dev,
 	frag_hdr[0] |= LOWPAN_DISPATCH_FRAGN;
 	frag_cap = round_down(payload_cap - LOWPAN_FRAGN_HEAD_SIZE, 8);
 
-	while (skb_unprocessed >= frag_cap) {
+	do {
 		dgram_offset += frag_len;
 		skb_offset += frag_len;
 		skb_unprocessed -= frag_len;
@@ -328,7 +328,7 @@ lowpan_xmit_fragmented(struct sk_buff *skb, struct net_device *dev,
 				 __func__, frag_tag, skb_offset);
 			goto err;
 		}
-	}
+	} while (skb_unprocessed >= frag_cap);
 
 	consume_skb(skb);
 	return NET_XMIT_SUCCESS;
-- 
1.9.3


------------------------------------------------------------------------------
Learn Graph Databases - Download FREE O'Reilly Book
"Graph Databases" is the definitive new guide to graph databases and their 
applications. Written by three acclaimed leaders in the field, 
this first edition is now available. Download your free book today!
http://p.sf.net/sfu/NeoTech
