From: Tony Cheneau <tony.cheneau-jNfjcPZKvDhg9hUCZPvPmw@public.gmane.org>
Subject: [PATCH v2 net-next 05/12] 6lowpan: use short
	IEEE 802.15.4 addresses for broadcast destination
Date: Mon, 25 Mar 2013 23:59:25 -0400
Message-ID: <1364270372-19430-6-git-send-email-tony.cheneau@amnesiak.org>
References: <1364270372-19430-1-git-send-email-tony.cheneau@amnesiak.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	Alan Ott <alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1364270372-19430-1-git-send-email-tony.cheneau-jNfjcPZKvDhg9hUCZPvPmw@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

The IEEE 802.15.4 standard uses the 0xFFFF short address (2 bytes) for message
broadcasting.

Signed-off-by: Tony Cheneau <tony.cheneau-jNfjcPZKvDhg9hUCZPvPmw@public.gmane.org>
---
 net/ieee802154/6lowpan.c | 23 +++++++++++++++--------
 1 file changed, 15 insertions(+), 8 deletions(-)

diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
index e7f61de..0eebb96 100644
--- a/net/ieee802154/6lowpan.c
+++ b/net/ieee802154/6lowpan.c
@@ -572,21 +572,28 @@ static int lowpan_header_create(struct sk_buff *skb,
 	 * this isn't implemented in mainline yet, so currently we assign 0xff
 	 */
 	{
+		mac_cb(skb)->flags = IEEE802154_FC_TYPE_DATA;
+
 		/* prepare wpan address data */
 		sa.addr_type = IEEE802154_ADDR_LONG;
 		sa.pan_id = 0xff;
-
-		da.addr_type = IEEE802154_ADDR_LONG;
-		da.pan_id = 0xff;
-
-		memcpy(&(da.hwaddr), daddr, 8);
 		memcpy(&(sa.hwaddr), saddr, 8);
 
-		mac_cb(skb)->flags = IEEE802154_FC_TYPE_DATA;
+		da.pan_id = 0xff;
+		/*
+		 * if the destination address is the broadcast address, use the
+		 * corresponding short address
+		 */
+		if (lowpan_is_addr_broadcast(daddr)) {
+			da.addr_type = IEEE802154_ADDR_SHORT;
+			da.short_addr = IEEE802154_ADDR_BROADCAST;
+		} else {
+			da.addr_type = IEEE802154_ADDR_LONG;
+			memcpy(&(da.hwaddr), daddr, 8);
 
-		/* request acknowledgment when possible */
-		if (!lowpan_is_addr_broadcast(daddr))
+			/* request acknowledgment */
 			mac_cb(skb)->flags |= MAC_CB_FLAG_ACKREQ;
+		}
 
 		return dev_hard_header(skb, lowpan_dev_info(dev)->real_dev,
 				type, (void *)&da, (void *)&sa, skb->len);
-- 
1.7.12.4


------------------------------------------------------------------------------
Own the Future-Intel&reg; Level Up Game Demo Contest 2013
Rise to greatness in Intel's independent game demo contest.
Compete for recognition, cash, and the chance to get your game 
on Steam. $5K grand prize plus 10 genre and skill prizes. 
Submit your demo by 6/6/13. http://p.sf.net/sfu/intel_levelupd2d
