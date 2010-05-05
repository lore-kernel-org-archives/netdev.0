From: David Daney <ddaney@caviumnetworks.com>
Subject: [PATCH 4/6] netdev: octeon_mgmt: Free TX skbufs in a timely manner.
Date: Wed,  5 May 2010 16:03:11 -0700
Message-ID: <1273100593-11043-5-git-send-email-ddaney@caviumnetworks.com>
References: <1273100593-11043-1-git-send-email-ddaney@caviumnetworks.com>
Cc: linux-mips@linux-mips.org, David Daney <ddaney@caviumnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3.caviumnetworks.com ([12.108.191.235]:1670 "EHLO
	mail3.caviumnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758123Ab0EEXDu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 May 2010 19:03:50 -0400
In-Reply-To: <1273100593-11043-1-git-send-email-ddaney@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We also reduce the high water mark to 1 so skbufs are not stranded for
long periods of time.  Since we are cleaning after each packet, no
need to do it in the transmit path.

Signed-off-by: David Daney <ddaney@caviumnetworks.com>
---
 drivers/net/octeon/octeon_mgmt.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/octeon/octeon_mgmt.c b/drivers/net/octeon/octeon_mgmt.c
index 633fa89..3cf6f62 100644
--- a/drivers/net/octeon/octeon_mgmt.c
+++ b/drivers/net/octeon/octeon_mgmt.c
@@ -832,9 +832,9 @@ static int octeon_mgmt_open(struct net_device *netdev)
 	mix_irhwm.s.irhwm = 0;
 	cvmx_write_csr(CVMX_MIXX_IRHWM(port), mix_irhwm.u64);
 
-	/* Interrupt when we have 5 or more packets to clean.  */
+	/* Interrupt when we have 1 or more packets to clean.  */
 	mix_orhwm.u64 = 0;
-	mix_orhwm.s.orhwm = 5;
+	mix_orhwm.s.orhwm = 1;
 	cvmx_write_csr(CVMX_MIXX_ORHWM(port), mix_orhwm.u64);
 
 	/* Enable receive and transmit interrupts */
@@ -995,7 +995,6 @@ static int octeon_mgmt_xmit(struct sk_buff *skb, struct net_device *netdev)
 	cvmx_write_csr(CVMX_MIXX_ORING2(port), 1);
 
 	netdev->trans_start = jiffies;
-	octeon_mgmt_clean_tx_buffers(p);
 	octeon_mgmt_update_tx_stats(netdev);
 	return NETDEV_TX_OK;
 }
-- 
1.6.6.1

