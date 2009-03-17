From: Arthur Jones <ajones@riverbed.com>
Subject: [net-next PATCH] e1000e: allow tx of pre-formatted vlan tagged
	packets
Date: Tue, 17 Mar 2009 12:59:05 -0700
Message-ID: <20090317195905.GA22551@ajones-laptop.nbttech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <e1000-devel@lists.sourceforge.net>, <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.riverbed.com ([206.169.144.7]:40269 "EHLO
	smtp2.riverbed.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752118AbZCQT7I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2009 15:59:08 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As with igb, when the e1000e driver is fed 802.1q
packets with hardware checksum on, it chokes with an
error of the form:

checksum_partial proto=81!

As the logic there was not smart enough to look into
the vlan header to pick out the encapsulated protocol.

There are times when we'd like to send these packets
out without having to configure a vlan on the interface.
Here we check for the vlan tag and allow the packet to
go out with the correct hardware checksum.

Thanks to Kand Ly <kand@riverbed.com> for discovering the
issue and the coming up with a solution.  This patch is
based upon his work.

Fixups from Stephen Hemminger <shemminger@vyatta.com> and
Alexander Duyck <alexander.h.duyck@intel.com>.

Signed-off-by: Arthur Jones <ajones@riverbed.com>
---
 drivers/net/e1000e/netdev.c |   11 +++++++++--
 1 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index e74eb3c..6d6221a 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -3769,11 +3769,17 @@ static bool e1000_tx_csum(struct e1000_adapter *adapter, struct sk_buff *skb)
 	unsigned int i;
 	u8 css;
 	u32 cmd_len = E1000_TXD_CMD_DEXT;
+	__be16 protocol;
 
 	if (skb->ip_summed != CHECKSUM_PARTIAL)
 		return 0;
 
-	switch (skb->protocol) {
+	if (skb->protocol == cpu_to_be16(ETH_P_8021Q))
+		protocol = vlan_eth_hdr(skb)->h_vlan_encapsulated_proto;
+	else
+		protocol = skb->protocol;
+
+	switch (protocol) {
 	case cpu_to_be16(ETH_P_IP):
 		if (ip_hdr(skb)->protocol == IPPROTO_TCP)
 			cmd_len |= E1000_TXD_CMD_TCP;
@@ -3785,7 +3791,8 @@ static bool e1000_tx_csum(struct e1000_adapter *adapter, struct sk_buff *skb)
 		break;
 	default:
 		if (unlikely(net_ratelimit()))
-			e_warn("checksum_partial proto=%x!\n", skb->protocol);
+			e_warn("checksum_partial proto=%x!\n",
+			       be16_to_cpu(protocol));
 		break;
 	}
 
-- 
1.5.6.3
