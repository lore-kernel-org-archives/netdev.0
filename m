From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH V1 net-next] net/vxlan: Share RX skb de-marking and checksum checks with ovs
Date: Thu, 23 Jan 2014 11:28:13 +0200
Message-ID: <1390469293-2234-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Joseph Gasparakis <joseph.gasparakis@intel.com>,
	Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:43311 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750903AbaAWJ2V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Jan 2014 04:28:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make sure the practice set by commit 0afb166 "vxlan: Add capability
of Rx checksum offload for inner packet" is applied when the skb
goes through the portion of the RX code which is shared between
vxlan netdevices and ovs vxlan port instances.

Cc: Joseph Gasparakis <joseph.gasparakis@intel.com>
Cc: Pravin B Shelar <pshelar@nicira.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---

Dave - I marked it net-next so it goes into 3.14 since "net" isn't 
open yet... from there it should obviously land in -stable of kernels >= 3.12

 drivers/net/vxlan.c |   21 ++++++++++-----------
 1 files changed, 10 insertions(+), 11 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index e1bc925..026a313 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1159,6 +1159,16 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 	if (!vs)
 		goto drop;
 
+	/* If the NIC driver gave us an encapsulated packet
+	 * with the encapsulation mark, the device checksummed it
+	 * for us. Otherwise force the upper layers to verify it.
+	 */
+	if ((skb->ip_summed != CHECKSUM_UNNECESSARY && skb->ip_summed != CHECKSUM_PARTIAL) ||
+	    !skb->encapsulation)
+		skb->ip_summed = CHECKSUM_NONE;
+
+	skb->encapsulation = 0;
+
 	vs->rcv(vs, skb, vxh->vx_vni);
 	return 0;
 
@@ -1217,17 +1227,6 @@ static void vxlan_rcv(struct vxlan_sock *vs,
 
 	skb_reset_network_header(skb);
 
-	/* If the NIC driver gave us an encapsulated packet with
-	 * CHECKSUM_UNNECESSARY and Rx checksum feature is enabled,
-	 * leave the CHECKSUM_UNNECESSARY, the device checksummed it
-	 * for us. Otherwise force the upper layers to verify it.
-	 */
-	if ((skb->ip_summed != CHECKSUM_UNNECESSARY && skb->ip_summed != CHECKSUM_PARTIAL) ||
-	    !skb->encapsulation || !(vxlan->dev->features & NETIF_F_RXCSUM))
-		skb->ip_summed = CHECKSUM_NONE;
-
-	skb->encapsulation = 0;
-
 	if (oip6)
 		err = IP6_ECN_decapsulate(oip6, skb);
 	if (oip)
-- 
1.7.1
