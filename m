From: greearb@candelatech.com
Subject: [PATCH v2 5/5] e1000e:  Support sending frame with custom FCS.
Date: Sat, 18 Jun 2011 13:47:25 -0700
Message-ID: <1308430045-24816-6-git-send-email-greearb@candelatech.com>
References: <1308430045-24816-1-git-send-email-greearb@candelatech.com>
Cc: Ben Greear <greearb@candelatech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:53647 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752151Ab1FRUso (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Jun 2011 16:48:44 -0400
In-Reply-To: <1308430045-24816-1-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

This is good for testing by injecting frames with invalid
FCS onto a network.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
:100644 100644 3310c3d... 011a95f... M	drivers/net/e1000e/netdev.c
 drivers/net/e1000e/netdev.c |   11 +++++++++++
 1 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 3310c3d..011a95f 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -4417,6 +4417,7 @@ link_up:
 #define E1000_TX_FLAGS_VLAN		0x00000002
 #define E1000_TX_FLAGS_TSO		0x00000004
 #define E1000_TX_FLAGS_IPV4		0x00000008
+#define E1000_TX_FLAGS_NO_FCS		0x00000010
 #define E1000_TX_FLAGS_VLAN_MASK	0xffff0000
 #define E1000_TX_FLAGS_VLAN_SHIFT	16
 
@@ -4681,6 +4682,9 @@ static void e1000_tx_queue(struct e1000_adapter *adapter,
 		txd_upper |= (tx_flags & E1000_TX_FLAGS_VLAN_MASK);
 	}
 
+	if (unlikely(tx_flags & E1000_TX_FLAGS_NO_FCS))
+		txd_lower &= ~(E1000_TXD_CMD_IFCS);
+
 	i = tx_ring->next_to_use;
 
 	do {
@@ -4698,6 +4702,10 @@ static void e1000_tx_queue(struct e1000_adapter *adapter,
 
 	tx_desc->lower.data |= cpu_to_le32(adapter->txd_cmd);
 
+	/* txd_cmd re-enables FCS, so we'll re-disable it here as desired. */
+	if (unlikely(tx_flags & E1000_TX_FLAGS_NO_FCS))
+		tx_desc->lower.data &= ~(cpu_to_le32(E1000_TXD_CMD_IFCS));
+
 	/*
 	 * Force memory writes to complete before letting h/w
 	 * know there are new descriptors to fetch.  (Only
@@ -4900,6 +4908,9 @@ static netdev_tx_t e1000_xmit_frame(struct sk_buff *skb,
 	if (skb->protocol == htons(ETH_P_IP))
 		tx_flags |= E1000_TX_FLAGS_IPV4;
 
+	if (unlikely(skb->use_specified_ether_crc))
+		tx_flags |= E1000_TX_FLAGS_NO_FCS;
+
 	/* if count is 0 then mapping error has occurred */
 	count = e1000_tx_map(adapter, skb, first, max_per_txd, nr_frags, mss);
 	if (count) {
-- 
1.7.3.4

