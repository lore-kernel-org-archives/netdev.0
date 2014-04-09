From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: [PATCH net] bridge: Fix double free and memory leak around
	br_allowed_ingress
Date: Wed,  9 Apr 2014 17:00:30 +0900
Message-ID: <1397030430-9625-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Cc: Vlad Yasevich <vyasevic@redhat.com>, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org
To: "David S . Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>
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

br_allowed_ingress() has two problems.

1. If br_allowed_ingress() is called by br_handle_frame_finish() and
vlan_untag() in br_allowed_ingress() fails, skb will be freed by both
vlan_untag() and br_handle_frame_finish().

2. If br_allowed_ingress() is called by br_dev_xmit() and
br_allowed_ingress() fails, the skb will not be freed.

Fix these two problems by freeing the skb in br_allowed_ingress()
if it fails.

Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
---
 net/bridge/br_input.c | 2 +-
 net/bridge/br_vlan.c  | 7 ++++---
 2 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index d0cca3c..7985dea 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -73,7 +73,7 @@ int br_handle_frame_finish(struct sk_buff *skb)
 		goto drop;
 
 	if (!br_allowed_ingress(p->br, nbp_get_vlan_info(p), skb, &vid))
-		goto drop;
+		goto out;
 
 	/* insert into forwarding database after filtering to avoid spoofing */
 	br = p->br;
diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index 9151071..4a37161 100644
--- a/net/bridge/br_vlan.c
+++ b/net/bridge/br_vlan.c
@@ -170,7 +170,7 @@ bool br_allowed_ingress(struct net_bridge *br, struct net_port_vlans *v,
 	 * rejected.
 	 */
 	if (!v)
-		return false;
+		goto drop;
 
 	/* If vlan tx offload is disabled on bridge device and frame was
 	 * sent from vlan device on the bridge device, it does not have
@@ -193,7 +193,7 @@ bool br_allowed_ingress(struct net_bridge *br, struct net_port_vlans *v,
 		 * vlan untagged or priority-tagged traffic belongs to.
 		 */
 		if (pvid == VLAN_N_VID)
-			return false;
+			goto drop;
 
 		/* PVID is set on this port.  Any untagged or priority-tagged
 		 * ingress frame is considered to belong to this vlan.
@@ -216,7 +216,8 @@ bool br_allowed_ingress(struct net_bridge *br, struct net_port_vlans *v,
 	/* Frame had a valid vlan tag.  See if vlan is allowed */
 	if (test_bit(*vid, v->vlan_bitmap))
 		return true;
-
+drop:
+	kfree_skb(skb);
 	return false;
 }
 
-- 
1.8.1.2
