From: Florian Westphal <fw@strlen.de>
Subject: [PATCH next] sched: remove NET_XMIT_POLICED
Date: Fri, 10 Jun 2016 14:21:29 +0200
Message-ID: <1465561289-15401-1-git-send-email-fw@strlen.de>
Cc: a@unstable.cc, sw@simonwunderlich.de, mareklindner@neomailbox.ch,
	sven@narfation.org, Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:35906 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751225AbcFJMVQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jun 2016 08:21:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

... its not returned anywhere.

BATMAN uses it as an intermediate return value to signal
forwarding vs. buffering, but it will not return POLICED to
callers outside of BATMAN.

sch_atm uses it, but on closer look its not returned either since
the initialisation is always overwritten with qdisc_enqueue() retval.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 include/linux/netdevice.h | 1 -
 net/batman-adv/routing.c  | 2 +-
 net/batman-adv/send.c     | 4 ++--
 net/core/pktgen.c         | 1 -
 net/sched/sch_api.c       | 2 --
 net/sched/sch_atm.c       | 3 +--
 6 files changed, 4 insertions(+), 9 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 5415623..745a408 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -90,7 +90,6 @@ void netdev_set_default_ethtool_ops(struct net_device *dev,
 #define NET_XMIT_SUCCESS	0x00
 #define NET_XMIT_DROP		0x01	/* skb dropped			*/
 #define NET_XMIT_CN		0x02	/* congestion notification	*/
-#define NET_XMIT_POLICED	0x03	/* skb is shot by police	*/
 #define NET_XMIT_MASK		0x0f	/* qdisc flags in net/sch_generic.h */
 
 /* NET_XMIT_CN is special. It does not guarantee that this packet is lost. It
diff --git a/net/batman-adv/routing.c b/net/batman-adv/routing.c
index e3857ed..f75091c 100644
--- a/net/batman-adv/routing.c
+++ b/net/batman-adv/routing.c
@@ -653,7 +653,7 @@ static int batadv_route_unicast_packet(struct sk_buff *skb,
 				   len + ETH_HLEN);
 
 		ret = NET_RX_SUCCESS;
-	} else if (res == NET_XMIT_POLICED) {
+	} else if (res == -EINPROGRESS) {
 		/* skb was buffered and consumed */
 		ret = NET_RX_SUCCESS;
 	}
diff --git a/net/batman-adv/send.c b/net/batman-adv/send.c
index f2f1256..b1a4e8a 100644
--- a/net/batman-adv/send.c
+++ b/net/batman-adv/send.c
@@ -156,7 +156,7 @@ int batadv_send_unicast_skb(struct sk_buff *skb,
  * attempted.
  *
  * Return: NET_XMIT_SUCCESS on success, NET_XMIT_DROP on failure, or
- * NET_XMIT_POLICED if the skb is buffered for later transmit.
+ * -EINPROGRESS if the skb is buffered for later transmit.
  */
 int batadv_send_skb_to_orig(struct sk_buff *skb,
 			    struct batadv_orig_node *orig_node,
@@ -188,7 +188,7 @@ int batadv_send_skb_to_orig(struct sk_buff *skb,
 	 * network coding fails, then send the packet as usual.
 	 */
 	if (recv_if && batadv_nc_skb_forward(skb, neigh_node)) {
-		ret = NET_XMIT_POLICED;
+		ret = -EINPROGRESS;
 	} else {
 		batadv_send_unicast_skb(skb, neigh_node);
 		ret = NET_XMIT_SUCCESS;
diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 8b02df0..f74ab9c 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -3463,7 +3463,6 @@ xmit_more:
 		break;
 	case NET_XMIT_DROP:
 	case NET_XMIT_CN:
-	case NET_XMIT_POLICED:
 		/* skb has been consumed */
 		pkt_dev->errors++;
 		break;
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index d4a8bbf..7460d56 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -95,8 +95,6 @@ static int tclass_notify(struct net *net, struct sk_buff *oskb,
      Expected action: do not backoff, but wait until queue will clear.
    NET_XMIT_CN	 	- probably this packet enqueued, but another one dropped.
      Expected action: backoff or ignore
-   NET_XMIT_POLICED	- dropped by police.
-     Expected action: backoff or error to real-time apps.
 
    Auxiliary routines:
 
diff --git a/net/sched/sch_atm.c b/net/sched/sch_atm.c
index 7e6c12d..ac298d3 100644
--- a/net/sched/sch_atm.c
+++ b/net/sched/sch_atm.c
@@ -362,8 +362,7 @@ static int atm_tc_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	struct atm_qdisc_data *p = qdisc_priv(sch);
 	struct atm_flow_data *flow;
 	struct tcf_result res;
-	int result;
-	int ret = NET_XMIT_POLICED;
+	int result, ret;
 
 	pr_debug("atm_tc_enqueue(skb %p,sch %p,[qdisc %p])\n", skb, sch, p);
 	result = TC_POLICE_OK;	/* be nice to gcc */
-- 
2.7.3
