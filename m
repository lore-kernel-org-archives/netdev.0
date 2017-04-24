From: Manish Chopra <manish.chopra@cavium.com>
Subject: [PATCH net-next 3/6] qede: Disable tunnel offloads for non offloaded UDP ports
Date: Mon, 24 Apr 2017 10:00:46 -0700
Message-ID: <20170424170049.16027-4-manish.chopra@cavium.com>
References: <20170424170049.16027-1-manish.chopra@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0055.outbound.protection.outlook.com ([104.47.32.55]:38144
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S975241AbdDXRBe (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 24 Apr 2017 13:01:34 -0400
In-Reply-To: <20170424170049.16027-1-manish.chopra@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch disables tunnel offloads via ndo_features_check()
if given UDP port is not offloaded to hardware. This in turn
allows to run multiple tunnel interfaces using different UDP ports.

Signed-off-by: Manish Chopra <manish.chopra@cavium.com>
Signed-off-by: Yuval Mintz <yuval.mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qede/qede_fp.c | 23 +++++++++++++++++------
 1 file changed, 17 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qede/qede_fp.c b/drivers/net/ethernet/qlogic/qede/qede_fp.c
index 961b1d3..7b6f41d 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_fp.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_fp.c
@@ -1697,13 +1697,24 @@ netdev_features_t qede_features_check(struct sk_buff *skb,
 		}
 
 		/* Disable offloads for geneve tunnels, as HW can't parse
-		 * the geneve header which has option length greater than 32B.
+		 * the geneve header which has option length greater than 32b
+		 * and disable offloads for the ports which are not offloaded.
 		 */
-		if ((l4_proto == IPPROTO_UDP) &&
-		    ((skb_inner_mac_header(skb) -
-		      skb_transport_header(skb)) > QEDE_MAX_TUN_HDR_LEN))
-			return features & ~(NETIF_F_CSUM_MASK |
-					    NETIF_F_GSO_MASK);
+		if (l4_proto == IPPROTO_UDP) {
+			struct qede_dev *edev = netdev_priv(dev);
+			u16 hdrlen, vxln_port, gnv_port;
+
+			hdrlen = QEDE_MAX_TUN_HDR_LEN;
+			vxln_port = edev->vxlan_dst_port;
+			gnv_port = edev->geneve_dst_port;
+
+			if ((skb_inner_mac_header(skb) -
+			     skb_transport_header(skb)) > hdrlen ||
+			     (ntohs(udp_hdr(skb)->dest) != vxln_port &&
+			      ntohs(udp_hdr(skb)->dest) != gnv_port))
+				return features & ~(NETIF_F_CSUM_MASK |
+						    NETIF_F_GSO_MASK);
+		}
 	}
 
 	return features;
-- 
2.7.2
