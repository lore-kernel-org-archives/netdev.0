From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next v3 2/2] tipc: stricter filtering
	of packets in bearer layer
Date: Thu,  7 Apr 2016 10:09:14 -0400
Message-ID: <1460038154-26856-3-git-send-email-jon.maloy@ericsson.com>
References: <1460038154-26856-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jon Maloy <jon.maloy@ericsson.com>, netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	tipc-discussion@lists.sourceforge.net, ying.xue@windriver.com
To: davem@davemloft.net
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1460038154-26856-1-git-send-email-jon.maloy@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Resetting a bearer/interface, with the consequence of resetting all its
pertaining links, is not an atomic action. This becomes particularly
evident in very large clusters, where a lot of traffic may happen on the
remaining links while we are busy shutting them down. In extreme cases,
we may even see links being re-created and re-established before we are
finished with the job.

To solve this, we now introduce a solution where we temporarily detach
the bearer from the interface when the bearer is reset. This inhibits
all packet reception, while sending still is possible. For the latter,
we use the fact that the device's user pointer now is zero to filter out
which packets can be sent during this situation; i.e., outgoing RESET
messages only.  This filtering serves to speed up the neighbors'
detection of the loss event, and saves us from unnecessary probing.

Acked-by: Ying Xue <ying.xue@windriver.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/bearer.c | 50 +++++++++++++++++++++++++++++++++-----------------
 net/tipc/msg.h    |  5 +++++
 2 files changed, 38 insertions(+), 17 deletions(-)

diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index 20566e9..6f11c62 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -337,23 +337,16 @@ static int tipc_reset_bearer(struct net *net, struct tipc_bearer *b)
  */
 static void bearer_disable(struct net *net, struct tipc_bearer *b)
 {
-	struct tipc_net *tn = net_generic(net, tipc_net_id);
-	u32 i;
+	struct tipc_net *tn = tipc_net(net);
+	int bearer_id = b->identity;
 
 	pr_info("Disabling bearer <%s>\n", b->name);
 	b->media->disable_media(b);
-
-	tipc_node_delete_links(net, b->identity);
+	tipc_node_delete_links(net, bearer_id);
 	RCU_INIT_POINTER(b->media_ptr, NULL);
 	if (b->link_req)
 		tipc_disc_delete(b->link_req);
-
-	for (i = 0; i < MAX_BEARERS; i++) {
-		if (b == rtnl_dereference(tn->bearer_list[i])) {
-			RCU_INIT_POINTER(tn->bearer_list[i], NULL);
-			break;
-		}
-	}
+	RCU_INIT_POINTER(tn->bearer_list[bearer_id], NULL);
 	kfree_rcu(b, rcu);
 }
 
@@ -396,7 +389,7 @@ void tipc_disable_l2_media(struct tipc_bearer *b)
 
 /**
  * tipc_l2_send_msg - send a TIPC packet out over an L2 interface
- * @buf: the packet to be sent
+ * @skb: the packet to be sent
  * @b: the bearer through which the packet is to be sent
  * @dest: peer destination address
  */
@@ -405,17 +398,21 @@ int tipc_l2_send_msg(struct net *net, struct sk_buff *skb,
 {
 	struct net_device *dev;
 	int delta;
+	void *tipc_ptr;
 
 	dev = (struct net_device *)rcu_dereference_rtnl(b->media_ptr);
 	if (!dev)
 		return 0;
 
+	/* Send RESET message even if bearer is detached from device */
+	tipc_ptr = rtnl_dereference(dev->tipc_ptr);
+	if (unlikely(!tipc_ptr && !msg_is_reset(buf_msg(skb))))
+		goto drop;
+
 	delta = dev->hard_header_len - skb_headroom(skb);
 	if ((delta > 0) &&
-	    pskb_expand_head(skb, SKB_DATA_ALIGN(delta), 0, GFP_ATOMIC)) {
-		kfree_skb(skb);
-		return 0;
-	}
+	    pskb_expand_head(skb, SKB_DATA_ALIGN(delta), 0, GFP_ATOMIC))
+		goto drop;
 
 	skb_reset_network_header(skb);
 	skb->dev = dev;
@@ -424,6 +421,9 @@ int tipc_l2_send_msg(struct net *net, struct sk_buff *skb,
 			dev->dev_addr, skb->len);
 	dev_queue_xmit(skb);
 	return 0;
+drop:
+	kfree_skb(skb);
+	return 0;
 }
 
 int tipc_bearer_mtu(struct net *net, u32 bearer_id)
@@ -549,9 +549,18 @@ static int tipc_l2_device_event(struct notifier_block *nb, unsigned long evt,
 {
 	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
 	struct net *net = dev_net(dev);
+	struct tipc_net *tn = tipc_net(net);
 	struct tipc_bearer *b;
+	int i;
 
 	b = rtnl_dereference(dev->tipc_ptr);
+	if (!b) {
+		for (i = 0; i < MAX_BEARERS; b = NULL, i++) {
+			b = rtnl_dereference(tn->bearer_list[i]);
+			if (b && (b->media_ptr == dev))
+				break;
+		}
+	}
 	if (!b)
 		return NOTIFY_DONE;
 
@@ -561,13 +570,20 @@ static int tipc_l2_device_event(struct notifier_block *nb, unsigned long evt,
 	case NETDEV_CHANGE:
 		if (netif_carrier_ok(dev))
 			break;
+	case NETDEV_UP:
+		rcu_assign_pointer(dev->tipc_ptr, b);
+		break;
 	case NETDEV_GOING_DOWN:
+		RCU_INIT_POINTER(dev->tipc_ptr, NULL);
+		synchronize_net();
+		tipc_reset_bearer(net, b);
+		break;
 	case NETDEV_CHANGEMTU:
 		tipc_reset_bearer(net, b);
 		break;
 	case NETDEV_CHANGEADDR:
 		b->media->raw2addr(b, &b->addr,
-				       (char *)dev->dev_addr);
+				   (char *)dev->dev_addr);
 		tipc_reset_bearer(net, b);
 		break;
 	case NETDEV_UNREGISTER:
diff --git a/net/tipc/msg.h b/net/tipc/msg.h
index 55778a0..f34f639 100644
--- a/net/tipc/msg.h
+++ b/net/tipc/msg.h
@@ -779,6 +779,11 @@ static inline bool msg_peer_node_is_up(struct tipc_msg *m)
 	return msg_redundant_link(m);
 }
 
+static inline bool msg_is_reset(struct tipc_msg *hdr)
+{
+	return (msg_user(hdr) == LINK_PROTOCOL) && (msg_type(hdr) == RESET_MSG);
+}
+
 struct sk_buff *tipc_buf_acquire(u32 size);
 bool tipc_msg_validate(struct sk_buff *skb);
 bool tipc_msg_reverse(u32 own_addr, struct sk_buff **skb, int err);
-- 
1.9.1


------------------------------------------------------------------------------
