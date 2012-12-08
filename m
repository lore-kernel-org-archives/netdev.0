From: Joseph Gasparakis <joseph.gasparakis@intel.com>
Subject: [PATCH v4 5/5] vxlan: Add capability of Rx checksum offload for inner packet
Date: Fri,  7 Dec 2012 16:14:18 -0800
Message-ID: <1354925658-24115-6-git-send-email-joseph.gasparakis@intel.com>
References: <1354925658-24115-1-git-send-email-joseph.gasparakis@intel.com>
Cc: Joseph Gasparakis <joseph.gasparakis@intel.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	dmitry@broadcom.com, saeed.bishara@gmail.com,
	bhutchings@solarflare.com
To: davem@davemloft.net, shemminger@vyatta.com, chrisw@sous-sol.org,
	gospo@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1354925658-24115-1-git-send-email-joseph.gasparakis@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds capability in vxlan to identify received
checksummed inner packets and signal them to the upper layers of
the stack. The driver needs to set the skb->encapsulation bit
and also set the skb->ip_summed to CHECKSUM_UNNECESSARY.

Signed-off-by: Joseph Gasparakis <joseph.gasparakis@intel.com>
---
 drivers/net/vxlan.c | 16 ++++++++++++++--
 1 file changed, 14 insertions(+), 2 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 88b31f2..3b3fdf6 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -607,7 +607,17 @@ static int vxlan_udp_encap_recv(struct sock *sk, struct sk_buff *skb)
 
 	__skb_tunnel_rx(skb, vxlan->dev);
 	skb_reset_network_header(skb);
-	skb->ip_summed = CHECKSUM_NONE;
+
+	/* If the NIC driver gave us an encapsulated packet with
+	 * CHECKSUM_UNNECESSARY and Rx checksum feature is enabled,
+	 * leave the CHECKSUM_UNNECESSARY, the device checksummed it
+	 * for us. Otherwise force the upper layers to verify it.
+	 */
+	if (skb->ip_summed != CHECKSUM_UNNECESSARY || !skb->encapsulation ||
+	    !(vxlan->dev->features & NETIF_F_RXCSUM))
+		skb->ip_summed = CHECKSUM_NONE;
+
+	skb->encapsulation = 0;
 
 	err = IP_ECN_decapsulate(oip, skb);
 	if (unlikely(err)) {
@@ -1175,7 +1185,9 @@ static void vxlan_setup(struct net_device *dev)
 	dev->features	|= NETIF_F_LLTX;
 	dev->features	|= NETIF_F_NETNS_LOCAL;
 	dev->features	|= NETIF_F_SG | NETIF_F_HW_CSUM;
-	dev->hw_features |= NETIF_F_SG | NETIF_F_HW_CSUM;
+	dev->features   |= NETIF_F_RXCSUM;
+
+	dev->hw_features |= NETIF_F_SG | NETIF_F_HW_CSUM | NETIF_F_RXCSUM;
 	dev->priv_flags	&= ~IFF_XMIT_DST_RELEASE;
 
 	spin_lock_init(&vxlan->hash_lock);
-- 
1.7.11.7
