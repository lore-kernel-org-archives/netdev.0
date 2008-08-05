From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: [PATCH] atl1: deal with hardware rx checksum bug
Date: Mon, 4 Aug 2008 19:05:10 -0500
Message-ID: <20080804190510.4029d91d@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: jeff@garzik.org, csnook@redhat.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmailhost05.isp.att.net ([204.127.217.105]:61263 "EHLO
	fmailhost05.isp.att.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756269AbYHEAFN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Aug 2008 20:05:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The L1 hardware contains a bug that flags a fragmented IP packet
as having an incorrect TCP/UDP checksum, even though the packet
is perfectly valid and its checksum is correct.  There's no way to
distinguish between one of these good packets and a packet that
actually contains a TCP/UDP checksum error, so all we can do is
allow the packet to be handed up to the higher layers and let it
be sorted out there.

Add a comment describing this condition and remove the code that
currently fails to handle what may or may not be a checksum error.

Signed-off-by: Jay Cliburn <jacliburn@bellsouth.net>
---
 drivers/net/atlx/atl1.c |   19 +++++++++++--------
 1 files changed, 11 insertions(+), 8 deletions(-)

diff --git a/drivers/net/atlx/atl1.c b/drivers/net/atlx/atl1.c
index f12e3d1..e6a7bb7 100644
--- a/drivers/net/atlx/atl1.c
+++ b/drivers/net/atlx/atl1.c
@@ -1790,6 +1790,17 @@ static void atl1_rx_checksum(struct atl1_adapter *adapter,
 {
 	struct pci_dev *pdev = adapter->pdev;
 
+	/*
+	 * The L1 hardware contains a bug that erroneously sets the
+	 * PACKET_FLAG_ERR and ERR_FLAG_L4_CHKSUM bits whenever a
+	 * fragmented IP packet is received, even though the packet
+	 * is perfectly valid and its checksum is correct. There's
+	 * no way to distinguish between one of these good packets
+	 * and a packet that actually contains a TCP/UDP checksum
+	 * error, so all we can do is allow it to be handed up to
+	 * the higher layers and let it be sorted out there.
+	 */
+
 	skb->ip_summed = CHECKSUM_NONE;
 
 	if (unlikely(rrd->pkt_flg & PACKET_FLAG_ERR)) {
@@ -1816,14 +1827,6 @@ static void atl1_rx_checksum(struct atl1_adapter *adapter,
 		return;
 	}
 
-	/* IPv4, but hardware thinks its checksum is wrong */
-	if (netif_msg_rx_err(adapter))
-		dev_printk(KERN_DEBUG, &pdev->dev,
-			"hw csum wrong, pkt_flag:%x, err_flag:%x\n",
-			rrd->pkt_flg, rrd->err_flg);
-	skb->ip_summed = CHECKSUM_COMPLETE;
-	skb->csum = htons(rrd->xsz.xsum_sz.rx_chksum);
-	adapter->hw_csum_err++;
 	return;
 }
 
-- 
1.5.5.1
