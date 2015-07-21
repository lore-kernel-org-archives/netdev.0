From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net-next 13/22] arp: Inherit metadata dst when creating ARP requests
Date: Tue, 21 Jul 2015 10:43:57 +0200
Message-ID: <2b3f52bcb192b1d0a6b74251791c7f84501dd300.1437468140.git.tgraf@suug.ch>
References: <cover.1437468140.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, dev@openvswitch.org
To: roopa@cumulusnetworks.com, rshearma@brocade.com,
	ebiederm@xmission.com, hannes@stressinduktion.org,
	pshelar@nicira.com, jesse@nicira.com, davem@davemloft.net,
	daniel@iogearbox.net, tom@herbertland.com, edumazet@google.com,
	jiri@resnulli.us, marcelo.leitner@gmail.com,
	stephen@networkplumber.org, jpettit@nicira.com, kaber@trash.net,
	simon.horman@netronome.com, joestringer@nicira.com, ja@ssi.bg,
	ast@plumgrid.com, weichunc@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:40067 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754226AbbGUIo1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jul 2015 04:44:27 -0400
In-Reply-To: <cover.1437468140.git.tgraf@suug.ch>
In-Reply-To: <cover.1437468140.git.tgraf@suug.ch>
References: <cover.1437468140.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If output device wants to see the dst, inherit the dst of the
original skb and pass it on to generate the ARP request.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 net/ipv4/arp.c | 65 +++++++++++++++++++++++++++++++++-------------------------
 1 file changed, 37 insertions(+), 28 deletions(-)

diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 933a928..1d59e50 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -291,6 +291,40 @@ static void arp_error_report(struct neighbour *neigh, struct sk_buff *skb)
 	kfree_skb(skb);
 }
 
+/* Create and send an arp packet. */
+static void arp_send_dst(int type, int ptype, __be32 dest_ip,
+			 struct net_device *dev, __be32 src_ip,
+			 const unsigned char *dest_hw,
+			 const unsigned char *src_hw,
+			 const unsigned char *target_hw, struct sk_buff *oskb)
+{
+	struct sk_buff *skb;
+
+	/* arp on this interface. */
+	if (dev->flags & IFF_NOARP)
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
 static void arp_solicit(struct neighbour *neigh, struct sk_buff *skb)
 {
 	__be32 saddr = 0;
@@ -346,8 +380,9 @@ static void arp_solicit(struct neighbour *neigh, struct sk_buff *skb)
 		}
 	}
 
-	arp_send(ARPOP_REQUEST, ETH_P_ARP, target, dev, saddr,
-		 dst_hw, dev->dev_addr, NULL);
+	arp_send_dst(ARPOP_REQUEST, ETH_P_ARP, target, dev, saddr,
+		     dst_hw, dev->dev_addr, NULL,
+		     dev->priv_flags & IFF_XMIT_DST_RELEASE ? NULL : skb);
 }
 
 static int arp_ignore(struct in_device *in_dev, __be32 sip, __be32 tip)
@@ -597,32 +632,6 @@ void arp_xmit(struct sk_buff *skb)
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
