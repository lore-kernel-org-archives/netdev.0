From: Stephen Hemminger <shemming@brocade.com>
Subject: [PATCH] fm10k: fix memory leak
Date: Tue, 17 Nov 2015 14:24:27 -0800
Message-ID: <20151117142427.37a4cc36@samsung9>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:60694 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753093AbbKQWYb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2015 17:24:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This was detected by Coverity.
The function skb_cow_head leaves skb alone on failure, so caller needs
to free.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

--- a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c	2015-11-17 13:33:40.032694657 -0800
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c	2015-11-17 14:13:03.086942495 -0800
@@ -627,8 +627,10 @@ static netdev_tx_t fm10k_xmit_frame(stru
 
 		/* verify the skb head is not shared */
 		err = skb_cow_head(skb, 0);
-		if (err)
+		if (err) {
+			dev_kfree_skb(skb);
 			return NETDEV_TX_OK;
+		}
 
 		/* locate vlan header */
 		vhdr = (struct vlan_hdr *)(skb->data + ETH_HLEN);
