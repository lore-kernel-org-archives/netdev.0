From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH] bonding: reset queue mapping prior to transmission to physical device (v3)
Date: Fri,  3 Jun 2011 13:32:33 -0400
Message-ID: <1307122353-3414-1-git-send-email-nhorman@tuxdriver.com>
References: <1307112216.2789.16.camel@bwh-desktop>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:42899 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751216Ab1FCRcw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2011 13:32:52 -0400
In-Reply-To: <1307112216.2789.16.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bonding driver is multiqueue enabled, in which each queue represents a slave
to enable optional steering of output frames to given slaves against the default
output policy.  However, it needs to reset the skb->queue_mapping prior to
queuing to the physical device or the physical slave (if it is multiqueue) could
wind up transmitting on an unintended tx queue

Change Notes:
v2) Based on first pass review, updated the patch to restore the origional queue
mapping that was found in bond_select_queue, rather than simply resetting to
zero.  This preserves the value of queue_mapping when it was set on receive in
the forwarding case which is desireable.

v3) Fixed spelling an casting error in skb->cb

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
CC: "David S. Miller" <davem@davemloft.net>
---
 drivers/net/bonding/bond_main.c |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 17b4dd9..dbb1048 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -400,6 +400,11 @@ int bond_dev_queue_xmit(struct bonding *bond, struct sk_buff *skb,
 {
 	skb->dev = slave_dev;
 	skb->priority = 1;
+	/*
+	 *restore the origional mapping
+	 */
+	skb_set_queue_mapping(skb, ((u16 *)skb->cb)[0]);
+
 	if (unlikely(netpoll_tx_running(slave_dev)))
 		bond_netpoll_send_skb(bond_get_slave_by_dev(bond, slave_dev), skb);
 	else
@@ -4216,6 +4221,11 @@ static u16 bond_select_queue(struct net_device *dev, struct sk_buff *skb)
 	 */
 	u16 txq = skb_rx_queue_recorded(skb) ? skb_get_rx_queue(skb) : 0;
 
+	/*
+ 	 * Save the original txq to restore before passing to the driver
+ 	 */
+	((u16 *)skb->cb)[0] = txq;
+
 	if (unlikely(txq >= dev->real_num_tx_queues)) {
 		do {
 			txq -= dev->real_num_tx_queues;
-- 
1.7.3.4

