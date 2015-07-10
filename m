From: Thomas Graf <tgraf@suug.ch>
Subject: [RFC net-next 12/22] arp: Inherit metadata dst when creating ARP requests
Date: Fri, 10 Jul 2015 16:19:14 +0200
Message-ID: <85ea0d614578b637ceaef7e76c6a47a37cfe1483.1436537414.git.tgraf@suug.ch>
References: <cover.1436537414.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, dev@openvswitch.org
To: roopa@cumulusnetworks.com, rshearma@brocade.com,
	ebiederm@xmission.com, hannes@stressinduktion.org,
	pshelar@nicira.com, jesse@nicira.com, davem@davemloft.net,
	daniel@iogearbox.net, tom@herbertland.com, edumazet@google.com,
	jiri@resnulli.us, marcelo.leitner@gmail.com,
	stephen@networkplumber.org, jpettit@nicira.com, kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:40627 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932687AbbGJOTo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jul 2015 10:19:44 -0400
In-Reply-To: <cover.1436537414.git.tgraf@suug.ch>
In-Reply-To: <cover.1436537414.git.tgraf@suug.ch>
References: <cover.1436537414.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If output device wants to see the dst, inherit the dst of the
original skb and pass it on to generate the ARP request.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 net/ipv4/arp.c | 71 +++++++++++++++++++++++++++++++++++-----------------------
 1 file changed, 43 insertions(+), 28 deletions(-)

diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 933a928..3400aea 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -291,6 +291,46 @@ static void arp_error_report(struct neighbour *neigh, struct sk_buff *skb)
 	kfree_skb(skb);
 }
 
+/*
+ *	Create and send an arp packet.
+ */
+static void arp_send_dst(int type, int ptype, __be32 dest_ip,
+			 struct net_device *dev, __be32 src_ip,
+			 const unsigned char *dest_hw,
+			 const unsigned char *src_hw,
+			 const unsigned char *target_hw, struct sk_buff *oskb)
+{
+	struct sk_buff *skb;
+
+	/*
+	 *	No arp on this interface.
+	 */
+
+	if (dev->flags&IFF_NOARP)
+		return;
+
+	skb = arp_create(type, ptype, dest_ip, dev, src_ip,
+			 dest_hw, src_hw, target_hw);
+	if (!skb)
+		return;
+
+	if (oskb)
+		skb_dst_copy(skb, oskb);
+
+	arp_xmit(skb);
+}
+
+void arp_send(int type, int ptype, __be32 dest_ip,
+	      struct net_device *dev, __be32 src_ip,
+	      const unsigned char *dest_hw, const unsigned char *src_hw,
+	      const unsigned char *target_hw)
+{
+	arp_send_dst(type, ptype, dest_ip, dev, src_ip, dest_hw, src_hw,
+		     target_hw, NULL);
+}
+EXPORT_SYMBOL(arp_send);
+
+
 static void arp_solicit(struct neighbour *neigh, struct sk_buff *skb)
 {
 	__be32 saddr = 0;
@@ -346,8 +386,9 @@ static void arp_solicit(struct neighbour *neigh, struct sk_buff *skb)
 		}
 	}
 
-	arp_send(ARPOP_REQUEST, ETH_P_ARP, target, dev, saddr,
-		 dst_hw, dev->dev_addr, NULL);
+	arp_send_dst(ARPOP_REQUEST, ETH_P_ARP, target, dev, saddr,
+		     dst_hw, dev->dev_addr, NULL,
+		     dev->priv_flags & IFF_XMIT_DST_RELEASE ? NULL : skb);
 }
 
 static int arp_ignore(struct in_device *in_dev, __be32 sip, __be32 tip)
@@ -597,32 +638,6 @@ void arp_xmit(struct sk_buff *skb)
 EXPORT_SYMBOL(arp_xmit);
 
 /*
- *	Create and send an arp packet.
- */
-void arp_send(int type, int ptype, __be32 dest_ip,
-	      struct net_device *dev, __be32 src_ip,
-	      const unsigned char *dest_hw, const unsigned char *src_hw,
-	      const unsigned char *target_hw)
-{
-	struct sk_buff *skb;
-
-	/*
-	 *	No arp on this interface.
-	 */
-
-	if (dev->flags&IFF_NOARP)
-		return;
-
-	skb = arp_create(type, ptype, dest_ip, dev, src_ip,
-			 dest_hw, src_hw, target_hw);
-	if (!skb)
-		return;
-
-	arp_xmit(skb);
-}
-EXPORT_SYMBOL(arp_send);
-
-/*
  *	Process an arp request.
  */
 
-- 
2.4.3
