From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net] netlink: preserve netlink pkt_type on dev_queue_xmit_nit
Date: Fri, 11 Apr 2014 20:25:29 +0200
Message-ID: <1397240729-32667-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, Jakub Zawadzki <darkjames-ws@darkjames.pl>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32917 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754521AbaDKSZe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Apr 2014 14:25:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In dev_queue_xmit_nit(), we unconditionally overwrite
the pkt_type of the new skb clone to PACKET_OUTGOING,
thus in packet sockets, we always propagate this to
sll_pkttype member of struct sockaddr_ll.

Hence, probe for skb_nit_type_netlink() and in case
we tap on a non-netlink socket, overwrite the setting
to PACKET_OUTGOING just as before. I think we can mark
the _non_-netlink sockets as likely since i) we don't
expect such heavy load in netlink messages as we do
with network packets, and ii) tapping on netlink
messages is rather to be considered a rare event
compared to tapping on network packets.

I have tested this with capturing on latest netsniff-ng
and propagation works fine. While at it, we also fixed
up the comment style and added two cases where their
conditions are to be considered unlikely() as well.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Cc: Jakub Zawadzki <darkjames-ws@darkjames.pl>
---
 include/linux/skbuff.h |  7 +++++++
 net/core/dev.c         | 21 +++++++++++----------
 2 files changed, 18 insertions(+), 10 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 08074a8..11445bf 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -33,6 +33,7 @@
 #include <linux/dma-mapping.h>
 #include <linux/netdev_features.h>
 #include <linux/sched.h>
+#include <linux/if_packet.h>
 #include <net/flow_keys.h>
 
 /* A. Checksumming of received packets by device.
@@ -2974,6 +2975,12 @@ int skb_checksum_setup(struct sk_buff *skb, bool recalculate);
 
 u32 __skb_get_poff(const struct sk_buff *skb);
 
+static inline bool skb_nit_type_netlink(const struct sk_buff *skb)
+{
+	return skb->pkt_type == PACKET_USER ||
+	       skb->pkt_type == PACKET_KERNEL;
+}
+
 /**
  * skb_head_is_locked - Determine if the skb->head is locked down
  * @skb: skb to check
diff --git a/net/core/dev.c b/net/core/dev.c
index 14dac06..5bed6b8 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1742,7 +1742,7 @@ static void dev_queue_xmit_nit(struct sk_buff *skb, struct net_device *dev)
 		 * they originated from - MvS (miquels@drinkel.ow.org)
 		 */
 		if ((ptype->dev == dev || !ptype->dev) &&
-		    (!skb_loop_sk(ptype, skb))) {
+		    !skb_loop_sk(ptype, skb)) {
 			if (pt_prev) {
 				deliver_skb(skb2, pt_prev, skb->dev);
 				pt_prev = ptype;
@@ -1750,27 +1750,28 @@ static void dev_queue_xmit_nit(struct sk_buff *skb, struct net_device *dev)
 			}
 
 			skb2 = skb_clone(skb, GFP_ATOMIC);
-			if (!skb2)
+			if (unlikely(!skb2))
 				break;
 
 			net_timestamp_set(skb2);
 
-			/* skb->nh should be correctly
-			   set by sender, so that the second statement is
-			   just protection against buggy protocols.
+			/* skb->nh should be correctly set by sender, so
+			 * that the second statement is just protection
+			 * against buggy protocols.
 			 */
 			skb_reset_mac_header(skb2);
 
-			if (skb_network_header(skb2) < skb2->data ||
-			    skb_network_header(skb2) > skb_tail_pointer(skb2)) {
+			if (unlikely(skb_network_header(skb2) < skb2->data ||
+				     skb_network_header(skb2) >
+				     skb_tail_pointer(skb2))) {
 				net_crit_ratelimited("protocol %04x is buggy, dev %s\n",
-						     ntohs(skb2->protocol),
-						     dev->name);
+						     ntohs(skb2->protocol), dev->name);
 				skb_reset_network_header(skb2);
 			}
 
 			skb2->transport_header = skb2->network_header;
-			skb2->pkt_type = PACKET_OUTGOING;
+			if (likely(!skb_nit_type_netlink(skb2)))
+				skb2->pkt_type = PACKET_OUTGOING;
 			pt_prev = ptype;
 		}
 	}
-- 
1.7.11.7
