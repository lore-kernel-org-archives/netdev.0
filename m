From: "Joonwoo Park" <joonwpark81@gmail.com>
Subject: [PATCH 1/2] [VLAN] Don't drop an unclassfied vlan
	packet as PACKET_OTHERHOST
Date: Sun, 11 Nov 2007 09:51:20 +0900
Message-ID: <473651fd.0f10240a.0686.2169@mx.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net,
	'Dave Johnson' <djohnson+linux-kernel@sw.starentnetworks.com>,
	linux-kernel@vger.kernel.org
To: "'David Miller'" <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

IMHO linux should not drop unclassified vlan packets to pass these to sniffers. isn't it?
But, since the __vlan_hwaccel_rx drops unclassified vlan packets, sniffers cannot see them.
This make the __vlan_hwaccel_rx receive and process an unclassified vlan packet as a PACKET_OTHERHOST.
Any check, comments will be appreciated.
Thanks.

Signed-off-by: Joonwoo Park <joonwpark81@gmail.com> 
---
 include/linux/if_vlan.h |   61 ++++++++++++++++++++++++++--------------------
 1 files changed, 34 insertions(+), 27 deletions(-)

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index 976d4b1..e1db5bc 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -170,21 +170,26 @@ static inline int __vlan_hwaccel_rx(struct sk_buff *skb,
 				    unsigned short vlan_tag, int polling)
 {
 	struct net_device_stats *stats;
+	struct net_device *vlan_dev;
 
 	if (skb_bond_should_drop(skb)) {
 		dev_kfree_skb_any(skb);
 		return NET_RX_DROP;
 	}
 
-	skb->dev = vlan_group_get_device(grp, vlan_tag & VLAN_VID_MASK);
-	if (skb->dev == NULL) {
-		dev_kfree_skb_any(skb);
+	vlan_dev = vlan_group_get_device(grp, vlan_tag & VLAN_VID_MASK);
+	if (vlan_dev == NULL) {
+		if (skb->dev == NULL) {
+			dev_kfree_skb_any(skb);
 
-		/* Not NET_RX_DROP, this is not being dropped
-		 * due to congestion.
-		 */
-		return 0;
-	}
+			/* Not NET_RX_DROP, this is not being dropped
+			 * due to congestion.
+			 */
+			return 0;
+		}
+		skb->pkt_type = PACKET_OTHERHOST;
+	} else
+		skb->dev = vlan_dev;
 
 	skb->dev->last_rx = jiffies;
 
@@ -192,25 +197,27 @@ static inline int __vlan_hwaccel_rx(struct sk_buff *skb,
 	stats->rx_packets++;
 	stats->rx_bytes += skb->len;
 
-	skb->priority = vlan_get_ingress_priority(skb->dev, vlan_tag);
-	switch (skb->pkt_type) {
-	case PACKET_BROADCAST:
-		break;
-
-	case PACKET_MULTICAST:
-		stats->multicast++;
-		break;
-
-	case PACKET_OTHERHOST:
-		/* Our lower layer thinks this is not local, let's make sure.
-		 * This allows the VLAN to have a different MAC than the underlying
-		 * device, and still route correctly.
-		 */
-		if (!compare_ether_addr(eth_hdr(skb)->h_dest,
-				       	skb->dev->dev_addr))
-			skb->pkt_type = PACKET_HOST;
-		break;
-	};
+	if (vlan_dev) {
+		skb->priority = vlan_get_ingress_priority(skb->dev, vlan_tag);
+		switch (skb->pkt_type) {
+		case PACKET_BROADCAST:
+			break;
+
+		case PACKET_MULTICAST:
+			stats->multicast++;
+			break;
+
+		case PACKET_OTHERHOST:
+			/* Our lower layer thinks this is not local, let's make sure.
+			 * This allows the VLAN to have a different MAC than the underlying
+			 * device, and still route correctly.
+			 */
+			if (!compare_ether_addr(eth_hdr(skb)->h_dest,
+							skb->dev->dev_addr))
+				skb->pkt_type = PACKET_HOST;
+			break;
+		};
+	}
 
 	return (polling ? netif_receive_skb(skb) : netif_rx(skb));
 }
---


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
