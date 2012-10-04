From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [RFC] vxlan: use ether header as fallback hash
Date: Wed, 3 Oct 2012 21:39:06 -0700
Message-ID: <20121003213906.09b57539@nehalam.linuxnetplumber.net>
References: <20121001223232.566037595@vyatta.com>
	<20121001223254.349753999@vyatta.com>
	<CAEP_g=9Y3MmsABQJyi508FEgs4635tnaVqk4Ncwbpm41bLskhg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: Jesse Gross <jesse@nicira.com>, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:41972 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751406Ab2JDEjn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Oct 2012 00:39:43 -0400
In-Reply-To: <CAEP_g=9Y3MmsABQJyi508FEgs4635tnaVqk4Ncwbpm41bLskhg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

VXLAN bases source UDP port based on flow to help the
receiver to be able to load balance based on outer header
contents.

This patches changes the algorithm to better handle packets
that can not be categorized by the rxhash() function.
It adds a fallback to use jhash on the Ether header.

It also fixes a bug where the old code could assign 0 as a port
value.


Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
RFC for now, compile tested only

--- a/drivers/net/vxlan.c	2012-10-03 21:25:43.747968165 -0700
+++ b/drivers/net/vxlan.c	2012-10-03 21:36:10.213805422 -0700
@@ -622,12 +622,30 @@ static inline u8 vxlan_ecn_encap(u8 tos,
 	return INET_ECN_encapsulate(tos, inner);
 }
 
+/* Compute hash to use for source port
+ *   first choice to use L4 flow hash since it will spread
+ *     better and maybe available from hardware
+ *   secondary choice is to use jhash on the Ethernet header
+ * Always returns non-zero value
+ */
+static u16 vxlan_flow_hash(struct sk_buff *skb)
+{
+	u16 hash = skb_get_rxhash(skb);
+
+	if (!hash)
+		hash = jhash(skb->data, 3, skb->protocol);
+
+	if (!hash)
+		hash = 1;
+
+	return hash;
+}
+
 /* Transmit local packets over Vxlan
  *
  * Outer IP header inherits ECN and DF from inner header.
  * Outer UDP destination is the VXLAN assigned port.
- *           source port is based on hash of flow if available
- *                       otherwise use a random value
+ *           source port is based on hash of flow
  */
 static netdev_tx_t vxlan_xmit(struct sk_buff *skb, struct net_device *dev)
 {
@@ -641,8 +659,8 @@ static netdev_tx_t vxlan_xmit(struct sk_
 	struct flowi4 fl4;
 	struct vxlan_fdb *f;
 	unsigned int pkt_len = skb->len;
-	u32 hash;
 	__be32 dst;
+	__be16 src_port;
 	__be16 df = 0;
 	__u8 tos, ttl;
 	int err;
@@ -670,7 +688,7 @@ static netdev_tx_t vxlan_xmit(struct sk_
 	if (tos == 1)
 		tos = vxlan_get_dsfield(old_iph, skb);
 
-	hash = skb_get_rxhash(skb);
+	src_port = (__force __be16) vxlan_flow_hash(skb);
 
 	rt = ip_route_output_gre(dev_net(dev), &fl4, dst,
 				 vxlan->saddr, vxlan->vni,
@@ -703,7 +721,7 @@ static netdev_tx_t vxlan_xmit(struct sk_
 	uh = udp_hdr(skb);
 
 	uh->dest = htons(vxlan_port);
-	uh->source = hash ? :random32();
+	uh->source = src_port;
 
 	uh->len = htons(skb->len);
 	uh->check = 0;
