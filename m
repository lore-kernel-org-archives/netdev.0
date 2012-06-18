From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next] ixgbe: simplify padding and length checks (v2)
Date: Mon, 18 Jun 2012 16:31:11 -0700
Message-ID: <20120618163111.4e46493b@nehalam.linuxnetplumber.net>
References: <20120618105816.5fdd0b90@nehalam.linuxnetplumber.net>
	<4FDF9B37.3030804@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:57445 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752544Ab2FRXbR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Jun 2012 19:31:17 -0400
In-Reply-To: <4FDF9B37.3030804@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The check for length <= 0 is bogus because length is unsigned, and network
stack never sends zero length packets (unless it is totally broken).

The check for really small packets can be optimized (using unlikely)
and calling skb_pad directly.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c	2012-06-18 10:53:09.130376800 -0700
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c	2012-06-18 15:20:44.364951004 -0700
@@ -6380,17 +6380,12 @@ static netdev_tx_t ixgbe_xmit_frame(stru
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	struct ixgbe_ring *tx_ring;
 
-	if (skb->len <= 0) {
-		dev_kfree_skb_any(skb);
-		return NETDEV_TX_OK;
-	}
-
 	/*
 	 * The minimum packet size for olinfo paylen is 17 so pad the skb
 	 * in order to meet this minimum size requirement.
 	 */
-	if (skb->len < 17) {
-		if (skb_padto(skb, 17))
+	if (unlikely(skb->len < 17)) {
+		if (skb_pad(skb, 17 - skb->len))
 			return NETDEV_TX_OK;
 		skb->len = 17;
 	}
