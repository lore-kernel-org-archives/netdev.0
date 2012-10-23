From: Tony Cheneau <tony.cheneau-jNfjcPZKvDhg9hUCZPvPmw@public.gmane.org>
Subject: [PATCH net-next 05/15] 6lowpan: use short IEEE
	802.15.4 addresses for broadcast destination
Date: Tue, 23 Oct 2012 00:09:47 -0400
Message-ID: <1350965397-12384-6-git-send-email-tony.cheneau@amnesiak.org>
References: <1350965397-12384-1-git-send-email-tony.cheneau@amnesiak.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Alan Ott <alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org>,
	linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1350965397-12384-1-git-send-email-tony.cheneau-jNfjcPZKvDhg9hUCZPvPmw@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

It is intended that the IEEE 802.15.4 standard uses the 0xFFFF short address (2
bytes) for message broadcasting.

Signed-off-by: Tony Cheneau <tony.cheneau-jNfjcPZKvDhg9hUCZPvPmw@public.gmane.org>
---
 net/ieee802154/6lowpan.c |   21 +++++++++++++--------
 1 files changed, 13 insertions(+), 8 deletions(-)

diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
index 49d91df..8a2ee95 100644
--- a/net/ieee802154/6lowpan.c
+++ b/net/ieee802154/6lowpan.c
@@ -577,21 +577,26 @@ static int lowpan_header_create(struct sk_buff *skb,
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
+		/* if the destination address is the broadcast address,
+		   use short address */
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
1.7.8.6


------------------------------------------------------------------------------
Everyone hates slow websites. So do we.
Make your web apps faster with AppDynamics
Download AppDynamics Lite for free today:
http://p.sf.net/sfu/appdyn_sfd2d_oct
