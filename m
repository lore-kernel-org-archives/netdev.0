From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net 2/3] vxlan: only migrate dynamic FDB entries
Date: Mon, 17 Jun 2013 12:09:58 -0700
Message-ID: <1371496199-5424-3-git-send-email-stephen@networkplumber.org>
References: <1371496199-5424-1-git-send-email-stephen@networkplumber.org>
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:63021 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752687Ab3FQTKH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Jun 2013 15:10:07 -0400
Received: by mail-pd0-f181.google.com with SMTP id 14so3058881pdj.40
        for <netdev@vger.kernel.org>; Mon, 17 Jun 2013 12:10:07 -0700 (PDT)
In-Reply-To: <1371496199-5424-1-git-send-email-stephen@networkplumber.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Only migrate dynamic forwarding table entries, don't modify
static entries. If packet received from incorrect source IP address
assume it is an imposter and drop it.

This patch applies only to -net, a different patch would be needed for earlier
kernels since the NTF_SELF flag was introduced with 3.10.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
---
 drivers/net/vxlan.c |   16 ++++++++++++----
 1 file changed, 12 insertions(+), 4 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 577a069..15a73ec 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -565,8 +565,9 @@ skip:
 
 /* Watch incoming packets to learn mapping between Ethernet address
  * and Tunnel endpoint.
+ * Return true if packet is bogus and should be droppped.
  */
-static void vxlan_snoop(struct net_device *dev,
+static bool vxlan_snoop(struct net_device *dev,
 			__be32 src_ip, const u8 *src_mac)
 {
 	struct vxlan_dev *vxlan = netdev_priv(dev);
@@ -575,7 +576,11 @@ static void vxlan_snoop(struct net_device *dev,
 	f = vxlan_find_mac(vxlan, src_mac);
 	if (likely(f)) {
 		if (likely(f->remote.remote_ip == src_ip))
-			return;
+			return false;
+
+		/* Don't migrate static entries, drop packets */
+		if (!(f->flags & NTF_SELF))
+			return true;
 
 		if (net_ratelimit())
 			netdev_info(dev,
@@ -598,6 +603,8 @@ static void vxlan_snoop(struct net_device *dev,
 					 0, NTF_SELF);
 		spin_unlock(&vxlan->hash_lock);
 	}
+
+	return false;
 }
 
 
@@ -729,8 +736,9 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
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
