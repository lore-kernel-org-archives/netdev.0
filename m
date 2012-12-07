From: Joseph Gasparakis <joseph.gasparakis@intel.com>
Subject: [PATCH v3 3/4] vxlan: capture inner headers during encapsulation
Date: Thu,  6 Dec 2012 17:56:58 -0800
Message-ID: <1354845419-22483-4-git-send-email-joseph.gasparakis@intel.com>
References: <1354845419-22483-1-git-send-email-joseph.gasparakis@intel.com>
Cc: Joseph Gasparakis <joseph.gasparakis@intel.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	dmitry@broadcom.com, saeed.bishara@gmail.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: davem@davemloft.net, shemminger@vyatta.com, chrisw@sous-sol.org,
	gospo@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1354845419-22483-1-git-send-email-joseph.gasparakis@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Allow VXLAN to make use of Tx checksum offloading and Tx scatter-gather.
The advantage to these two changes is that it also allows the VXLAN to
make use of GSO.

Signed-off-by: Joseph Gasparakis <joseph.gasparakis@intel.com>
Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 drivers/net/vxlan.c |   10 +++++++++-
 1 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index ce77b8b..88b31f2 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -876,6 +876,11 @@ static netdev_tx_t vxlan_xmit(struct sk_buff *skb, struct net_device *dev)
 		goto drop;
 	}
 
+	if (!skb->encapsulation) {
+		skb_reset_inner_headers(skb);
+		skb->encapsulation = 1;
+	}
+
 	/* Need space for new headers (invalidates iph ptr) */
 	if (skb_cow_head(skb, VXLAN_HEADROOM))
 		goto drop;
@@ -947,7 +952,8 @@ static netdev_tx_t vxlan_xmit(struct sk_buff *skb, struct net_device *dev)
 	vxlan_set_owner(dev, skb);
 
 	/* See iptunnel_xmit() */
-	skb->ip_summed = CHECKSUM_NONE;
+	if (skb->ip_summed != CHECKSUM_PARTIAL)
+		skb->ip_summed = CHECKSUM_NONE;
 	ip_select_ident(iph, &rt->dst, NULL);
 
 	err = ip_local_out(skb);
@@ -1168,6 +1174,8 @@ static void vxlan_setup(struct net_device *dev)
 	dev->tx_queue_len = 0;
 	dev->features	|= NETIF_F_LLTX;
 	dev->features	|= NETIF_F_NETNS_LOCAL;
+	dev->features	|= NETIF_F_SG | NETIF_F_HW_CSUM;
+	dev->hw_features |= NETIF_F_SG | NETIF_F_HW_CSUM;
 	dev->priv_flags	&= ~IFF_XMIT_DST_RELEASE;
 
 	spin_lock_init(&vxlan->hash_lock);
-- 
1.7.6.4
