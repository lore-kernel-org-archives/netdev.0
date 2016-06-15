From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net PATCH] mlx4e: Do not attempt to offload VXLAN ports that are
 unrecognized
Date: Wed, 15 Jun 2016 14:42:11 -0700
Message-ID: <20160615214105.14734.93787.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, alexander.duyck@gmail.com
To: eugenia@mellanox.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:33389 "EHLO
	mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751907AbcFOVmP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2016 17:42:15 -0400
Received: by mail-pf0-f181.google.com with SMTP id i123so8797903pfg.0
        for <netdev@vger.kernel.org>; Wed, 15 Jun 2016 14:42:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The mlx4e driver does not support more than one port for VXLAN offload.  As
such expecting the hardware to offload other ports is invalid since it
appears the parsing logic is used to perform Tx checksum and segmentation
offloads.  Use the vxlan_port number to determine in which cases we can
apply the offload and in which cases we can not.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |   11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 973391bfe286..2221403b65e4 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -2447,9 +2447,14 @@ static netdev_features_t mlx4_en_features_check(struct sk_buff *skb,
 	 * strip that feature if this is an IPv6 encapsulated frame.
 	 */
 	if (skb->encapsulation &&
-	    (skb->ip_summed == CHECKSUM_PARTIAL) &&
-	    (ip_hdr(skb)->version != 4))
-		features &= ~(NETIF_F_CSUM_MASK | NETIF_F_GSO_MASK);
+	    (skb->ip_summed == CHECKSUM_PARTIAL)) {
+		struct mlx4_en_priv *priv = netdev_priv(dev);
+
+		if (!priv->vxlan_port ||
+		    (ip_hdr(skb)->version != 4) ||
+		    (udp_hdr(skb)->dest != priv->vxlan_port))
+			features &= ~(NETIF_F_CSUM_MASK | NETIF_F_GSO_MASK);
+	}
 
 	return features;
 }
