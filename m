From: "Guo-Fu Tseng" <cooldavid@cooldavid.org>
Subject: [PATCH] jme: Fix FIFO flush issue
Date: Thu, 23 Feb 2012 02:58:10 +0800
Message-ID: <1329937090-20779-1-git-send-email-cooldavid@cooldavid.org>
Cc: Guo-Fu Tseng <cooldavid@cooldavid.org>,
	"linux-netdev" <netdev@vger.kernel.org>,
	"Steven Chen" <stevenchen@jmicron.com>,
	"Devinchiu" <devinchiu@jmicron.com>, angelli@jmicron.com,
	"Federico Quagliata" <federico@quagliata.org>, stable@kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bbs.cooldavid.org ([114.34.16.17]:53799 "EHLO bbs.cooldavid.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752479Ab2BVTFB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Feb 2012 14:05:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guo-Fu Tseng <cooldavid@cooldavid.org>

Set the RX FIFO flush watermark lower.
According to Federico and JMicron's reply,
setting it to 16QW would be stable on most platforms.
Otherwise, user might experience packet drop issue.

CC: stable@kernel.org
Reported-by: Federico Quagliata <federico@quagliata.org>
Fixed-by: Federico Quagliata <federico@quagliata.org>
Signed-off-by: Guo-Fu Tseng <cooldavid@cooldavid.org>
---
 drivers/net/ethernet/jme.c |   10 +---------
 drivers/net/ethernet/jme.h |    2 +-
 2 files changed, 2 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/jme.c b/drivers/net/ethernet/jme.c
index 1b86d0b..4ea6580 100644
--- a/drivers/net/ethernet/jme.c
+++ b/drivers/net/ethernet/jme.c
@@ -2328,19 +2328,11 @@ jme_change_mtu(struct net_device *netdev, int new_mtu)
 		((new_mtu) < IPV6_MIN_MTU))
 		return -EINVAL;
 
-	if (new_mtu > 4000) {
-		jme->reg_rxcs &= ~RXCS_FIFOTHNP;
-		jme->reg_rxcs |= RXCS_FIFOTHNP_64QW;
-		jme_restart_rx_engine(jme);
-	} else {
-		jme->reg_rxcs &= ~RXCS_FIFOTHNP;
-		jme->reg_rxcs |= RXCS_FIFOTHNP_128QW;
-		jme_restart_rx_engine(jme);
-	}
 
 	netdev->mtu = new_mtu;
 	netdev_update_features(netdev);
 
+	jme_restart_rx_engine(jme);
 	jme_reset_link(jme);
 
 	return 0;
diff --git a/drivers/net/ethernet/jme.h b/drivers/net/ethernet/jme.h
index 4304072..3efc897 100644
--- a/drivers/net/ethernet/jme.h
+++ b/drivers/net/ethernet/jme.h
@@ -730,7 +730,7 @@ enum jme_rxcs_values {
 	RXCS_RETRYCNT_60	= 0x00000F00,
 
 	RXCS_DEFAULT		= RXCS_FIFOTHTP_128T |
-				  RXCS_FIFOTHNP_128QW |
+				  RXCS_FIFOTHNP_16QW |
 				  RXCS_DMAREQSZ_128B |
 				  RXCS_RETRYGAP_256ns |
 				  RXCS_RETRYCNT_32,
-- 
1.7.3.4
