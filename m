From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 01/10] vxlan: only migrate dynamic FDB entries
Date: Tue,  4 Jun 2013 21:24:05 -0700
Message-ID: <1370406254-6341-1-git-send-email-stephen@networkplumber.org>
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:34153 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750854Ab3FEEYU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jun 2013 00:24:20 -0400
Received: by mail-pd0-f177.google.com with SMTP id u10so1222229pdi.22
        for <netdev@vger.kernel.org>; Tue, 04 Jun 2013 21:24:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Only migrate dynamic forwarding table entries, don't modify
static entries. If packet received from incorrect source IP address
assume it is an imposter and drop it.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

---
Should go to -stable as well.
---
 drivers/net/vxlan.c |   17 ++++++++++++-----
 1 file changed, 12 insertions(+), 5 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 8111565..536082a 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -604,8 +604,8 @@ skip:
 /* Watch incoming packets to learn mapping between Ethernet address
  * and Tunnel endpoint.
  */
-static void vxlan_snoop(struct net_device *dev,
-			__be32 src_ip, const u8 *src_mac)
+static int vxlan_snoop(struct net_device *dev,
+		       __be32 src_ip, const u8 *src_mac)
 {
 	struct vxlan_dev *vxlan = netdev_priv(dev);
 	struct vxlan_fdb *f;
@@ -614,7 +614,11 @@ static void vxlan_snoop(struct net_device *dev,
 	f = vxlan_find_mac(vxlan, src_mac);
 	if (likely(f)) {
 		if (likely(f->remote.remote_ip == src_ip))
-			return;
+			return 0;
+
+		/* Don't migrate static entries, drop packets */
+		if (!(f->flags & NTF_SELF))
+			return 1;
 
 		if (net_ratelimit())
 			netdev_info(dev,
@@ -634,6 +638,8 @@ static void vxlan_snoop(struct net_device *dev,
 				       0, NTF_SELF);
 		spin_unlock(&vxlan->hash_lock);
 	}
+
+	return 0;
 }
 
 
@@ -766,8 +772,9 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 			       vxlan->dev->dev_addr) == 0)
 		goto drop;
 
-	if (vxlan->flags & VXLAN_F_LEARN)
-		vxlan_snoop(skb->dev, oip->saddr, eth_hdr(skb)->h_source);
+	if ((vxlan->flags & VXLAN_F_LEARN) &&
+	    vxlan_snoop(skb->dev, oip->saddr, eth_hdr(skb)->h_source))
+		goto drop;
 
 	__skb_tunnel_rx(skb, vxlan->dev);
 	skb_reset_network_header(skb);
-- 
1.7.10.4
