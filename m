From: vyasevich@gmail.com
Subject: [PATCH 5/8] i40e: Fix TSO and hw checksums for non-accelerated vlan packets.
Date: Fri, 22 Aug 2014 22:17:07 -0400
Message-ID: <1408760230-7457-6-git-send-email-vysevich@gmail.com>
References: <1408760230-7457-1-git-send-email-vysevich@gmail.com>
Cc: Vladislav Yasevich <vyasevic@redhat.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	Alex Duyck <alexander.h.duyck@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>,
	Linux NICS <linux.nics@intel.com>,
	e1000-devel@lists.sourceforge.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f170.google.com ([209.85.216.170]:47502 "EHLO
	mail-qc0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751733AbaHWCRe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2014 22:17:34 -0400
Received: by mail-qc0-f170.google.com with SMTP id x3so11804878qcv.1
        for <netdev@vger.kernel.org>; Fri, 22 Aug 2014 19:17:33 -0700 (PDT)
In-Reply-To: <1408760230-7457-1-git-send-email-vysevich@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vladislav Yasevich <vyasevic@redhat.com>

This device claims TSO and checksum support for vlans.  It also
allows a user to control vlan acceleration offloading.  As such,
it is possible to turn off vlan acceleration and configure a vlan
which will continue to support TSO and hw checksums.

In such situation the packet passed down the the device will contain
a vlan header and skb->protocol will be set to ETH_P_8021Q.
The device assumes that skb->protocol contains network protocol
value and uses that value to set up TSO and checksum information.
This results in corrupted frames sent on the wire.

This patch extract the protocol value correctly and corrects TSO
and checksums for non-accelerated traffic.

Fix this by using vlan_get_protocol() helper.

CC: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
CC: Jesse Brandeburg <jesse.brandeburg@intel.com>
CC: Bruce Allan <bruce.w.allan@intel.com>
CC: Carolyn Wyborny <carolyn.wyborny@intel.com>
CC: Don Skidmore <donald.c.skidmore@intel.com>
CC: Greg Rose <gregory.v.rose@intel.com>
CC: Alex Duyck <alexander.h.duyck@intel.com>
CC: John Ronciak <john.ronciak@intel.com>
CC: Mitch Williams <mitch.a.williams@intel.com>
CC: Linux NICS <linux.nics@intel.com>
CC: e1000-devel@lists.sourceforge.net
Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index a51aa37..3247057 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -2295,7 +2295,7 @@ static netdev_tx_t i40e_xmit_frame_ring(struct sk_buff *skb,
 		goto out_drop;
 
 	/* obtain protocol of skb */
-	protocol = skb->protocol;
+	protocol = get_vlan_protocol(skb);
 
 	/* record the location of the first descriptor for this packet */
 	first = &tx_ring->tx_bi[tx_ring->next_to_use];
-- 
1.9.3
