From: Joseph Gasparakis <joseph.gasparakis@intel.com>
Subject: [PATCH v2 3/3] ipgre: capture inner headers during encapsulation
Date: Sun, 11 Nov 2012 19:04:10 -0800
Message-ID: <1352689450-4092-1-git-send-email-joseph.gasparakis@intel.com>
Cc: Joseph Gasparakis <joseph.gasparakis@intel.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
To: davem@davemloft.net, shemminger@vyatta.com, chrisw@sous-sol.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Populating the inner header pointers of skb for ipgre
This patch has been compile-tested only.

v2 Makes sure that checksumming does not take place if the offload flag is set in the skb's netdev features

Signed-off-by: Joseph Gasparakis <joseph.gasparakis@intel.com>
Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
---
 net/ipv4/ip_gre.c | 15 ++++++++++++++-
 1 file changed, 14 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 7240f8e..e35ed52 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -766,8 +766,10 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
 	int    gre_hlen;
 	__be32 dst;
 	int    mtu;
+	unsigned int offset;
 
-	if (skb->ip_summed == CHECKSUM_PARTIAL &&
+	if (!(skb->dev->features & NETIF_F_HW_CSUM_ENC_BIT) &&
+	    skb->ip_summed == CHECKSUM_PARTIAL &&
 	    skb_checksum_help(skb))
 		goto tx_error;
 
@@ -902,6 +904,17 @@ static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev
 			tunnel->err_count = 0;
 	}
 
+	offset = skb->data - skb->head;
+
+	skb_reset_inner_mac_header(skb);
+
+	if (skb->network_header)
+		skb_set_inner_network_header(skb, skb->network_header - offset);
+
+	if (skb->transport_header)
+		skb_set_inner_transport_header(skb, skb->transport_header -
+					       offset);
+
 	max_headroom = LL_RESERVED_SPACE(tdev) + gre_hlen + rt->dst.header_len;
 
 	if (skb_headroom(skb) < max_headroom || skb_shared(skb)||
-- 
1.7.11.7
