From: Jiri Pirko <jpirko@redhat.com>
Subject: [PATCH v3] vlan: Fix the ingress VLAN_FLAG_REORDER_HDR check
Date: Fri, 10 Jun 2011 10:35:41 +0200
Message-ID: <20110610083539.GB17568@minipsycho.redhat.com>
References: <m11uzcidvq.fsf_-_@fess.ebiederm.org>
 <BANLkTikjdz+LkavRiuqdDNS6+djAer-a0A@mail.gmail.com>
 <BANLkTikM1TuO_S9LuJv30uV9oGgLjE09Xw@mail.gmail.com>
 <20110605.141446.1838641439880246155.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: xiaosuo@gmail.com, pratnakarlx@gmail.com, ebiederm@xmission.com,
	shemminger@linux-foundation.org, greearb@candelatech.com,
	nicolas.2p.debian@gmail.com, netdev@vger.kernel.org,
	kaber@trash.net, fubar@us.ibm.com, eric.dumazet@gmail.com,
	andy@greyhouse.net, jesse@nicira.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:21142 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751149Ab1FJIf5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Jun 2011 04:35:57 -0400
Content-Disposition: inline
In-Reply-To: <20110605.141446.1838641439880246155.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please review. I'm not sure if there wouldn't be necessary to control
for rx accelerated skbs. Smoke tested.

Subject: [patch net-2.6 v3] vlan: Fix the ingress VLAN_FLAG_REORDER_HDR check

Testing of VLAN_FLAG_REORDER_HDR does not belong in vlan_untag
but rather in vlan_do_receive.  Otherwise the vlan header
will not be properly put on the packet in the case of
vlan header accelleration.

As we remove the check from vlan_check_reorder_header
rename it vlan_reorder_header to keep the naming clean.

Use a simple if statement instead of a complicated switch
statement to decided that we need to increment rx_stats
for a multicast packet.

Hopefully at somepoint we will just declare the case where
VLAN_FLAG_REORDER_HDR is cleared as unsupported and remove
the code.  Until then this keeps it working correctly.

Use vlan_unreorder_header to revert actions previously done by
vlan_untag->vlan_reorder_header in case VLAN_FLAG_REORDER_HDR is not set

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 net/8021q/vlan_core.c |   75 ++++++++++++++++++++++++++++--------------------
 1 files changed, 44 insertions(+), 31 deletions(-)

diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index 41495dc..d71cc81 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -4,6 +4,33 @@
 #include <linux/netpoll.h>
 #include "vlan.h"
 
+static struct sk_buff *vlan_reorder_header(struct sk_buff *skb)
+{
+	if (skb_cow(skb, skb_headroom(skb)) < 0)
+		return NULL;
+	/* Lifted from Gleb's VLAN code... */
+	memmove(skb->data - ETH_HLEN, skb->data - VLAN_ETH_HLEN, 12);
+	skb->mac_header += VLAN_HLEN;
+	return skb;
+}
+
+/* Should be used only to revert vlan_reorder_header action */
+static struct sk_buff *vlan_unreorder_header(struct sk_buff *skb)
+{
+	unsigned char *mac_header;
+	struct vlan_ethhdr *veth;
+
+	if (skb_cow(skb, skb_headroom(skb)) < 0)
+		return NULL;
+	skb->mac_header -= VLAN_HLEN;
+	mac_header = skb_mac_header(skb);
+	memmove(mac_header, mac_header + VLAN_HLEN, 12);
+	veth = (struct vlan_ethhdr *) mac_header;
+	veth->h_vlan_proto = htons(ETH_P_8021Q);
+	veth->h_vlan_TCI = htons(skb->vlan_tci);
+	return skb;
+}
+
 bool vlan_do_receive(struct sk_buff **skbp)
 {
 	struct sk_buff *skb = *skbp;
@@ -23,6 +50,21 @@ bool vlan_do_receive(struct sk_buff **skbp)
 		return false;
 
 	skb->dev = vlan_dev;
+	if (skb->pkt_type == PACKET_OTHERHOST) {
+		/* Our lower layer thinks this is not local, let's make sure.
+		 * This allows the VLAN to have a different MAC than the
+		 * underlying device, and still route correctly. */
+		if (!compare_ether_addr(eth_hdr(skb)->h_dest,
+					vlan_dev->dev_addr))
+			skb->pkt_type = PACKET_HOST;
+	}
+
+	if (!(vlan_dev_info(vlan_dev)->flags & VLAN_FLAG_REORDER_HDR)) {
+		skb = *skbp = vlan_unreorder_header(skb);
+		if (!skb)
+			return false;
+	}
+
 	skb->priority = vlan_get_ingress_priority(vlan_dev, skb->vlan_tci);
 	skb->vlan_tci = 0;
 
@@ -31,22 +73,8 @@ bool vlan_do_receive(struct sk_buff **skbp)
 	u64_stats_update_begin(&rx_stats->syncp);
 	rx_stats->rx_packets++;
 	rx_stats->rx_bytes += skb->len;
-
-	switch (skb->pkt_type) {
-	case PACKET_BROADCAST:
-		break;
-	case PACKET_MULTICAST:
+	if (skb->pkt_type == PACKET_MULTICAST)
 		rx_stats->rx_multicast++;
-		break;
-	case PACKET_OTHERHOST:
-		/* Our lower layer thinks this is not local, let's make sure.
-		 * This allows the VLAN to have a different MAC than the
-		 * underlying device, and still route correctly. */
-		if (!compare_ether_addr(eth_hdr(skb)->h_dest,
-					vlan_dev->dev_addr))
-			skb->pkt_type = PACKET_HOST;
-		break;
-	}
 	u64_stats_update_end(&rx_stats->syncp);
 
 	return true;
@@ -89,21 +117,6 @@ gro_result_t vlan_gro_frags(struct napi_struct *napi, struct vlan_group *grp,
 }
 EXPORT_SYMBOL(vlan_gro_frags);
 
-static struct sk_buff *vlan_check_reorder_header(struct sk_buff *skb)
-{
-	if (vlan_dev_info(skb->dev)->flags & VLAN_FLAG_REORDER_HDR) {
-		if (skb_cow(skb, skb_headroom(skb)) < 0)
-			skb = NULL;
-		if (skb) {
-			/* Lifted from Gleb's VLAN code... */
-			memmove(skb->data - ETH_HLEN,
-				skb->data - VLAN_ETH_HLEN, 12);
-			skb->mac_header += VLAN_HLEN;
-		}
-	}
-	return skb;
-}
-
 static void vlan_set_encap_proto(struct sk_buff *skb, struct vlan_hdr *vhdr)
 {
 	__be16 proto;
@@ -161,7 +174,7 @@ struct sk_buff *vlan_untag(struct sk_buff *skb)
 	skb_pull_rcsum(skb, VLAN_HLEN);
 	vlan_set_encap_proto(skb, vhdr);
 
-	skb = vlan_check_reorder_header(skb);
+	skb = vlan_reorder_header(skb);
 	if (unlikely(!skb))
 		goto err_free;
 
-- 
1.7.5.2

