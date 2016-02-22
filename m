From: Ajit Khaparde <ajit.khaparde@broadcom.com>
Subject: [PATCH net-next 2/2] be2net: Fix a UE caused by passing large frames to the ASIC
Date: Tue, 23 Feb 2016 00:35:01 +0530
Message-ID: <1456167901-31495-1-git-send-email-ajit.khaparde@broadcom.com>
To: ajit.khaparde@broadcom.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmrelayp1.emulex.com ([138.239.112.140]:53689 "EHLO
	CMRELAYP1.ad.emulex.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751952AbcBVTG7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Feb 2016 14:06:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In QnQ configurations like Flex-10 where the VLANs are inserted by the
ASIC, on rare occasions the HW is encountering a scenario where the
final frame length ends to be greater than what the ASIC can support.

This is because when the TXULP pulls the TX WRB to check the length
of the frame to be transmitted it also adds the size of VLANs to be
inserted by the HW to the length of the frame indicated in the WRB,
which in some cases fails the range check.  This causes a UE.

Avoid this by trimming the skb length to accommodate the VLAN insertion.

Signed-off-by: Ajit Khaparde <ajit.khaparde@broadcom.com>
---
 drivers/net/ethernet/emulex/benet/be.h      |  3 +++
 drivers/net/ethernet/emulex/benet/be_main.c | 11 ++++++++++-
 2 files changed, 13 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index 756f25b..ee584c5 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -72,6 +72,9 @@
 #define BE_MAX_MTU              (BE_MAX_JUMBO_FRAME_SIZE -	\
 				 (ETH_HLEN + ETH_FCS_LEN))
 
+/* Accommodate for QnQ configurations where VLAN insertion is enabled in HW */
+#define BE_MAX_GSO_SIZE		(65535 - 2 * VLAN_HLEN)
+
 #define BE_NUM_VLANS_SUPPORTED	64
 #define BE_MAX_EQD		128u
 #define	BE_MAX_TX_FRAG_COUNT	30
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 0bd64f1..17422b2 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -1123,6 +1123,8 @@ static struct sk_buff *be_xmit_workarounds(struct be_adapter *adapter,
 					   struct sk_buff *skb,
 					   struct be_wrb_params *wrb_params)
 {
+	int err;
+
 	/* Lancer, SH and BE3 in SRIOV mode have a bug wherein
 	 * packets that are 32b or less may cause a transmit stall
 	 * on that port. The workaround is to pad such packets
@@ -1139,6 +1141,13 @@ static struct sk_buff *be_xmit_workarounds(struct be_adapter *adapter,
 			return NULL;
 	}
 
+	/* The stack can send us skbs with length greater than
+	 * what the HW can handle. Trim the extra bytes.
+	 */
+	WARN_ON_ONCE(skb->len > BE_MAX_GSO_SIZE);
+	err = pskb_trim(skb, BE_MAX_GSO_SIZE);
+	WARN_ON(err);
+
 	return skb;
 }
 
@@ -4850,7 +4859,7 @@ static void be_netdev_init(struct net_device *netdev)
 
 	netdev->flags |= IFF_MULTICAST;
 
-	netif_set_gso_max_size(netdev, 65535 - ETH_HLEN);
+	netif_set_gso_max_size(netdev, BE_MAX_GSO_SIZE - ETH_HLEN);
 
 	netdev->netdev_ops = &be_netdev_ops;
 
-- 
2.4.3
