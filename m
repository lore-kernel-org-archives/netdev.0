From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/15] e1000e: Fix 82572EI that has no hardware timestamp support
Date: Thu, 22 Jan 2015 18:36:58 -0800
Message-ID: <1421980631-1955-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1421980631-1955-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mathias Koehrer <mathias.koehrer@etas.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:16346 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752718AbbAWChQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jan 2015 21:37:16 -0500
In-Reply-To: <1421980631-1955-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mathias Koehrer <mathias.koehrer@etas.com>

With the Intel 82527EI (driver: e1000e) there is an issue when running
the ptpd2 program, that leads to a kernel oops.  The reason is here that
in e1000_xmit_frame() a work queue will be scheduled that has not been
initialized in this case.  The work queue "tx_hwstamp_work" will only be
initialized if adapter->flags & FLAG_HAS_HW_TIMESTAMP set.  This check
is missing in e1000_xmit_frame().

The following patch adds the missing check.

Signed-off-by: Mathias Koehrer <mathias.koehrer@etas.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 38cb586..aa39a81 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -5636,8 +5636,9 @@ static netdev_tx_t e1000_xmit_frame(struct sk_buff *skb,
 	count = e1000_tx_map(tx_ring, skb, first, adapter->tx_fifo_limit,
 			     nr_frags);
 	if (count) {
-		if (unlikely((skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP) &&
-			     !adapter->tx_hwtstamp_skb)) {
+		if (unlikely(skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP) &&
+		    (adapter->flags & FLAG_HAS_HW_TIMESTAMP) &&
+		    !adapter->tx_hwtstamp_skb) {
 			skb_shinfo(skb)->tx_flags |= SKBTX_IN_PROGRESS;
 			tx_flags |= E1000_TX_FLAGS_HWTSTAMP;
 			adapter->tx_hwtstamp_skb = skb_get(skb);
-- 
1.9.3
