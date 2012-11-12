From: Joseph Gasparakis <joseph.gasparakis@intel.com>
Subject: [PATCH v2 2/3] vxlan: capture inner headers during encapsulation
Date: Mon, 12 Nov 2012 00:36:57 -0800
Message-ID: <1352709418-28996-3-git-send-email-joseph.gasparakis@intel.com>
References: <1352709418-28996-1-git-send-email-joseph.gasparakis@intel.com>
Cc: Joseph Gasparakis <joseph.gasparakis@intel.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	dmitry@broadcom.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
To: davem@davemloft.net, shemminger@vyatta.com, chrisw@sous-sol.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1352709418-28996-1-git-send-email-joseph.gasparakis@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Populating the inner header pointers of skb for vxlan

Signed-off-by: Joseph Gasparakis <joseph.gasparakis@intel.com>
Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
---
 drivers/net/vxlan.c | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 030559d..14e6c8f 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -694,11 +694,23 @@ static netdev_tx_t vxlan_xmit(struct sk_buff *skb, struct net_device *dev)
 	__be16 df = 0;
 	__u8 tos, ttl;
 	int err;
+	unsigned int offset;
 
 	dst = vxlan_find_dst(vxlan, skb);
 	if (!dst)
 		goto drop;
 
+	offset = skb->data - skb->head;
+
+	skb_reset_inner_mac_header(skb);
+
+	if (skb->network_header)
+		skb_set_inner_network_header(skb, skb->network_header - offset);
+
+	if (skb->transport_header)
+		skb_set_inner_transport_header(skb, skb->transport_header -
+					      offset);
+
 	/* Need space for new headers (invalidates iph ptr) */
 	if (skb_cow_head(skb, VXLAN_HEADROOM))
 		goto drop;
-- 
1.7.11.7
