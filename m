From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH v2] bridge: Fix crash with vlan filtering and
	tcpdump
Date: Thu, 27 Mar 2014 21:51:18 -0400
Message-ID: <1395971478-10689-1-git-send-email-vyasevic@redhat.com>
Cc: Vlad Yasevich <vyasevic@redhat.com>, bridge@lists.linux-foundation.org
To: netdev@vger.kernel.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

When the vlan filtering is enabled on the bridge, but
the filter is not configured on the bridge device itself,
running tcpdump on the bridge device will result in a
an Oops with NULL pointer dereference.  The reason
is that br_pass_frame_up() will bypass the vlan
check because promisc flag is set.  It will then try
to get the table pointer and process the packet based
on the table.  Since the table pointer is NULL, we oops.
Catch this special condition in br_handle_vlan().

Reported-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
CC: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---

* Changed to use kfree_skb() instead of kfree_skb_list() to
  match the reset of bridge code.
* Fix-up {} style.

 net/bridge/br_input.c | 11 ++++++-----
 net/bridge/br_vlan.c  | 14 ++++++++++++++
 2 files changed, 20 insertions(+), 5 deletions(-)

diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index 28d5446..d0cca3c 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -29,6 +29,7 @@ static int br_pass_frame_up(struct sk_buff *skb)
 	struct net_device *indev, *brdev = BR_INPUT_SKB_CB(skb)->brdev;
 	struct net_bridge *br = netdev_priv(brdev);
 	struct pcpu_sw_netstats *brstats = this_cpu_ptr(br->stats);
+	struct net_port_vlans *pv;
 
 	u64_stats_update_begin(&brstats->syncp);
 	brstats->rx_packets++;
@@ -39,18 +40,18 @@ static int br_pass_frame_up(struct sk_buff *skb)
 	 * packet is allowed except in promisc modue when someone
 	 * may be running packet capture.
 	 */
+	pv = br_get_vlan_info(br);
 	if (!(brdev->flags & IFF_PROMISC) &&
-	    !br_allowed_egress(br, br_get_vlan_info(br), skb)) {
+	    !br_allowed_egress(br, pv, skb)) {
 		kfree_skb(skb);
 		return NET_RX_DROP;
 	}
 
-	skb = br_handle_vlan(br, br_get_vlan_info(br), skb);
-	if (!skb)
-		return NET_RX_DROP;
-
 	indev = skb->dev;
 	skb->dev = brdev;
+	skb = br_handle_vlan(br, pv, skb);
+	if (!skb)
+		return NET_RX_DROP;
 
 	return NF_HOOK(NFPROTO_BRIDGE, NF_BR_LOCAL_IN, skb, indev, NULL,
 		       netif_receive_skb);
diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index 8249ca7..b153cc4 100644
--- a/net/bridge/br_vlan.c
+++ b/net/bridge/br_vlan.c
@@ -144,6 +144,20 @@ struct sk_buff *br_handle_vlan(struct net_bridge *br,
 	if (!br->vlan_enabled)
 		goto out;
 
+	/* Vlan filter table must be configured at this point.  The
+	 * only exception is the bridge is set in promisc mode and the
+	 * packet is destined for the bridge device.  In this case
+	 * pass the packet as is.
+	 */
+	if (!pv) {
+		if ((br->dev->flags & IFF_PROMISC) && skb->dev == br->dev) {
+			goto out;
+		} else {
+			kfree_skb(skb);
+			return NULL;
+		}
+	}
+
 	/* At this point, we know that the frame was filtered and contains
 	 * a valid vlan id.  If the vlan id is set in the untagged bitmap,
 	 * send untagged; otherwise, send tagged.
-- 
1.8.5.3
