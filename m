From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net v2 01/03] vxlan: only migrate dynamic FDB entries
Date: Mon, 10 Jun 2013 13:13:17 -0700
Message-ID: <20130610131317.0c17ed0d@nehalam.linuxnetplumber.net>
References: <20130610195822.888424947@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:42686 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751997Ab3FJUN0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jun 2013 16:13:26 -0400
Received: by mail-pa0-f47.google.com with SMTP id kl14so1462863pab.34
        for <netdev@vger.kernel.org>; Mon, 10 Jun 2013 13:13:26 -0700 (PDT)
In-Reply-To: <20130610195822.888424947@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Only migrate dynamic forwarding table entries, don't modify
static entries. If packet received from incorrect source IP address
assume it is an imposter and drop it.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

---
Should go to -stable as well.

--- a/drivers/net/vxlan.c	2013-06-06 08:27:07.499595174 -0700
+++ b/drivers/net/vxlan.c	2013-06-06 09:38:54.291654035 -0700
@@ -603,9 +603,10 @@ skip:
 
 /* Watch incoming packets to learn mapping between Ethernet address
  * and Tunnel endpoint.
+ * Return true if packet is bogus and should be droppped.
  */
-static void vxlan_snoop(struct net_device *dev,
-			__be32 src_ip, const u8 *src_mac)
+static bool vxlan_snoop(struct net_device *dev,
+		       __be32 src_ip, const u8 *src_mac)
 {
 	struct vxlan_dev *vxlan = netdev_priv(dev);
 	struct vxlan_fdb *f;
@@ -614,7 +615,11 @@ static void vxlan_snoop(struct net_devic
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
@@ -634,6 +639,8 @@ static void vxlan_snoop(struct net_devic
 				       0, NTF_SELF);
 		spin_unlock(&vxlan->hash_lock);
 	}
+
+	return false;
 }
 
 
@@ -766,8 +773,9 @@ static int vxlan_udp_encap_recv(struct s
 			       vxlan->dev->dev_addr) == 0)
 		goto drop;
 
-	if (vxlan->flags & VXLAN_F_LEARN)
-		vxlan_snoop(skb->dev, oip->saddr, eth_hdr(skb)->h_source);
+	if ((vxlan->flags & VXLAN_F_LEARN) &&
+	    vxlan_snoop(skb->dev, oip->saddr, eth_hdr(skb)->h_source))
+		goto drop;
 
 	__skb_tunnel_rx(skb, vxlan->dev);
 	skb_reset_network_header(skb);
