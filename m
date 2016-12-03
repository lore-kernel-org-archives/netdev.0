From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/18] i40e: Be much more verbose about what we can and cannot offload
Date: Sat,  3 Dec 2016 01:19:13 -0800
Message-ID: <20161203091930.14268-2-jeffrey.t.kirsher@intel.com>
References: <20161203091930.14268-1-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, guru.anbalagane@oracle.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:6457 "EHLO mga09.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750745AbcLCJU2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 3 Dec 2016 04:20:28 -0500
In-Reply-To: <20161203091930.14268-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change makes it so that we are much more robust about defining what we
can and cannot offload.  Previously we were just checking for the L4 tunnel
header length, however there are other fields we should be verifying as
there are multiple scenarios in which we cannot perform hardware offloads.

In addition the device only supports GSO as long as the MSS is 64 or
greater.  We were not checking this so an MSS less than that was resulting
in Tx hangs.

Change-ID: I5e2fd5f3075c73601b4b36327b771c64fcb6c31b
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 52 ++++++++++++++++++++++++-----
 1 file changed, 44 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 5c6a5ce..2d91274 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -9070,10 +9070,6 @@ static int i40e_ndo_bridge_getlink(struct sk_buff *skb, u32 pid, u32 seq,
 				       0, 0, nlflags, filter_mask, NULL);
 }
 
-/* Hardware supports L4 tunnel length of 128B (=2^7) which includes
- * inner mac plus all inner ethertypes.
- */
-#define I40E_MAX_TUNNEL_HDR_LEN 128
 /**
  * i40e_features_check - Validate encapsulated packet conforms to limits
  * @skb: skb buff
@@ -9084,12 +9080,52 @@ static netdev_features_t i40e_features_check(struct sk_buff *skb,
 					     struct net_device *dev,
 					     netdev_features_t features)
 {
-	if (skb->encapsulation &&
-	    ((skb_inner_network_header(skb) - skb_transport_header(skb)) >
-	     I40E_MAX_TUNNEL_HDR_LEN))
-		return features & ~(NETIF_F_CSUM_MASK | NETIF_F_GSO_MASK);
+	size_t len;
+
+	/* No point in doing any of this if neither checksum nor GSO are
+	 * being requested for this frame.  We can rule out both by just
+	 * checking for CHECKSUM_PARTIAL
+	 */
+	if (skb->ip_summed != CHECKSUM_PARTIAL)
+		return features;
+
+	/* We cannot support GSO if the MSS is going to be less than
+	 * 64 bytes.  If it is then we need to drop support for GSO.
+	 */
+	if (skb_is_gso(skb) && (skb_shinfo(skb)->gso_size < 64))
+		features &= ~NETIF_F_GSO_MASK;
+
+	/* MACLEN can support at most 63 words */
+	len = skb_network_header(skb) - skb->data;
+	if (len & ~(63 * 2))
+		goto out_err;
+
+	/* IPLEN and EIPLEN can support at most 127 dwords */
+	len = skb_transport_header(skb) - skb_network_header(skb);
+	if (len & ~(127 * 4))
+		goto out_err;
+
+	if (skb->encapsulation) {
+		/* L4TUNLEN can support 127 words */
+		len = skb_inner_network_header(skb) - skb_transport_header(skb);
+		if (len & ~(127 * 2))
+			goto out_err;
+
+		/* IPLEN can support at most 127 dwords */
+		len = skb_inner_transport_header(skb) -
+		      skb_inner_network_header(skb);
+		if (len & ~(127 * 4))
+			goto out_err;
+	}
+
+	/* No need to validate L4LEN as TCP is the only protocol with a
+	 * a flexible value and we support all possible values supported
+	 * by TCP, which is at most 15 dwords
+	 */
 
 	return features;
+out_err:
+	return features & ~(NETIF_F_CSUM_MASK | NETIF_F_GSO_MASK);
 }
 
 static const struct net_device_ops i40e_netdev_ops = {
-- 
2.9.3
