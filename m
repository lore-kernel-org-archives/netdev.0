From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 13/17] mv643xx_eth: delete unused and uninteresting interrupt source mask bits
Date: Wed,  3 Sep 2008 14:29:40 +0200
Message-ID: <1220444984-20150-14-git-send-email-buytenh@wantstofly.org>
References: <1220444984-20150-1-git-send-email-buytenh@wantstofly.org>
Cc: Dale Farnsworth <dale@farnsworth.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:52903 "EHLO
	delta.wantstofly.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752718AbYICM3s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2008 08:29:48 -0400
In-Reply-To: <1220444984-20150-1-git-send-email-buytenh@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Delete a couple of unused and uninteresting interrupt source mask bits:
- The receive resource underrun interrupt sources are uninteresting
  because if we are in out-of-memory mode, we are already dealing with
  the issue, and we don't need the hardware to remind us again that we
  are out of memory.
- The LINK and PHY interrupt sources can be coalesced into one define,
  since we always use them together.
- The transmit resource underrun interrupt source can be disabled since
  we never activate the head descriptor of a paged skb until the
  fragments are all activated, so transmit underrun during a packet
  should never happen.
- The INT_EXT_TX_0 define is never used.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 drivers/net/mv643xx_eth.c |   17 ++++++-----------
 1 files changed, 6 insertions(+), 11 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index bd3ca47..e592fac 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -105,14 +105,11 @@ static char mv643xx_eth_driver_version[] = "1.3";
 #define INT_CAUSE(p)			(0x0460 + ((p) << 10))
 #define  INT_TX_END_0			0x00080000
 #define  INT_TX_END			0x07f80000
-#define  INT_RX				0x0007fbfc
+#define  INT_RX				0x000003fc
 #define  INT_EXT			0x00000002
 #define INT_CAUSE_EXT(p)		(0x0464 + ((p) << 10))
-#define  INT_EXT_LINK			0x00100000
-#define  INT_EXT_PHY			0x00010000
-#define  INT_EXT_TX_ERROR_0		0x00000100
-#define  INT_EXT_TX_0			0x00000001
-#define  INT_EXT_TX			0x0000ffff
+#define  INT_EXT_LINK_PHY		0x00110000
+#define  INT_EXT_TX			0x000000ff
 #define INT_MASK(p)			(0x0468 + ((p) << 10))
 #define INT_MASK_EXT(p)			(0x046c + ((p) << 10))
 #define TX_FIFO_URGENT_THRESHOLD(p)	(0x0474 + ((p) << 10))
@@ -1815,11 +1812,11 @@ static irqreturn_t mv643xx_eth_irq(int irq, void *dev_id)
 	int_cause_ext = 0;
 	if (int_cause & INT_EXT) {
 		int_cause_ext = rdl(mp, INT_CAUSE_EXT(mp->port_num))
-				& (INT_EXT_LINK | INT_EXT_PHY | INT_EXT_TX);
+				& (INT_EXT_LINK_PHY | INT_EXT_TX);
 		wrl(mp, INT_CAUSE_EXT(mp->port_num), ~int_cause_ext);
 	}
 
-	if (int_cause_ext & (INT_EXT_PHY | INT_EXT_LINK))
+	if (int_cause_ext & INT_EXT_LINK_PHY)
 		handle_link_event(mp);
 
 	/*
@@ -2059,9 +2056,7 @@ static int mv643xx_eth_open(struct net_device *dev)
 	set_rx_coal(mp, 0);
 	set_tx_coal(mp, 0);
 
-	wrl(mp, INT_MASK_EXT(mp->port_num),
-	    INT_EXT_LINK | INT_EXT_PHY | INT_EXT_TX);
-
+	wrl(mp, INT_MASK_EXT(mp->port_num), INT_EXT_LINK_PHY | INT_EXT_TX);
 	wrl(mp, INT_MASK(mp->port_num), INT_TX_END | INT_RX | INT_EXT);
 
 	return 0;
-- 
1.5.6.4

