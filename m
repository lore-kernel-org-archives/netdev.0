From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: [PATCH] atl1: fix frame length bug
Date: Mon, 14 Jan 2008 19:56:41 -0600
Message-ID: <1200362201-30987-1-git-send-email-jacliburn@bellsouth.net>
Cc: csnook@redhat.com, david.harris@cpni-inc.com,
	netdev@vger.kernel.org, Jay Cliburn <jacliburn@bellsouth.net>
To: jeff@garzik.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmailhost06.isp.att.net ([204.127.217.106]:55326 "EHLO
	fmailhost06.isp.att.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750818AbYAOB4n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2008 20:56:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver sets up the hardware to accept a frame with max length
equal to MTU + Ethernet header + FCS + VLAN tag, but we neglect to
add the VLAN tag size to the ingress buffer.  When a VLAN-tagged
frame arrives, the hardware passes it, but bad things happen
because the buffer is too small.  This patch fixes that.

Thanks to David Harris for reporting the bug and testing the fix.

Tested-by: David Harris <david.harris@cpni-inc.com>
Signed-off-by: Jay Cliburn <jacliburn@bellsouth.net>
---
 drivers/net/atl1/atl1_main.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/atl1/atl1_main.c b/drivers/net/atl1/atl1_main.c
index 35b0a7d..9200ee5 100644
--- a/drivers/net/atl1/atl1_main.c
+++ b/drivers/net/atl1/atl1_main.c
@@ -120,7 +120,7 @@ static int __devinit atl1_sw_init(struct atl1_adapter *adapter)
 	struct atl1_hw *hw = &adapter->hw;
 	struct net_device *netdev = adapter->netdev;
 
-	hw->max_frame_size = netdev->mtu + ETH_HLEN + ETH_FCS_LEN;
+	hw->max_frame_size = netdev->mtu + ETH_HLEN + ETH_FCS_LEN + VLAN_HLEN;
 	hw->min_frame_size = ETH_ZLEN + ETH_FCS_LEN;
 
 	adapter->wol = 0;
@@ -688,7 +688,7 @@ static int atl1_change_mtu(struct net_device *netdev, int new_mtu)
 {
 	struct atl1_adapter *adapter = netdev_priv(netdev);
 	int old_mtu = netdev->mtu;
-	int max_frame = new_mtu + ETH_HLEN + ETH_FCS_LEN;
+	int max_frame = new_mtu + ETH_HLEN + ETH_FCS_LEN + VLAN_HLEN;
 
 	if ((max_frame < ETH_ZLEN + ETH_FCS_LEN) ||
 	    (max_frame > MAX_JUMBO_FRAME_SIZE)) {
@@ -853,8 +853,8 @@ static u32 atl1_configure(struct atl1_adapter *adapter)
 	/* set Interrupt Clear Timer */
 	iowrite16(adapter->ict, hw->hw_addr + REG_CMBDISDMA_TIMER);
 
-	/* set MTU, 4 : VLAN */
-	iowrite32(hw->max_frame_size + 4, hw->hw_addr + REG_MTU);
+	/* set max frame size hw will accept */
+	iowrite32(hw->max_frame_size, hw->hw_addr + REG_MTU);
 
 	/* jumbo size & rrd retirement timer */
 	value = (((u32) hw->rx_jumbo_th & RXQ_JMBOSZ_TH_MASK)
-- 
1.5.3.7

