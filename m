From: Mike McCormack <mikem@ring3k.org>
Subject: [PATCH] sky2: Avoid transmits during sky2_down()
Date: Fri, 31 Jul 2009 20:57:42 +0900
Message-ID: <392fb48f0907310457t15d8f9bbmdf77f062c423a475@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.154]:60986 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751403AbZGaL5n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jul 2009 07:57:43 -0400
Received: by fg-out-1718.google.com with SMTP id e12so67956fga.17
        for <netdev@vger.kernel.org>; Fri, 31 Jul 2009 04:57:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stephen,

This patch supersedes my previous patch "sky2: Avoid transmitting
during sky2_restart".

I have reworked the patch to avoid crashes during both sky2_restart()
and sky2_set_ringparam().

Without this patch, the sky2 driver can be crashed by doing:

# pktgen eth1 &    (transmit many packets on eth1)
# ethtool -G eth1 tx 510

I am aware you object to storing extra state, but I can't see a way
around this. Without remembering that we're restarting,
netif_wake_queue() is called in the ISR from sky2_tx_complete(), and
netif_tx_lock() is used in sky2_tx_done().  If anybody can see a way
around this, please let me know.

thanks,

Mike

----

During sky2_restart() or sky2_set_ringparam(), the tx queue needs to be
 shutdown in sky2_down() to avoid accessing a NULL tx_ring.

Signed-off-by: Mike McCormack <mikem@ring3k.org>
---
 drivers/net/sky2.c |   14 +++++++++++++-
 drivers/net/sky2.h |    1 +
 2 files changed, 14 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index 661abd0..1415a83 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -1488,6 +1488,8 @@ static int sky2_up(struct net_device *dev)
 	sky2_set_vlan_mode(hw, port, sky2->vlgrp != NULL);
 #endif

+	sky2->restarting = 0;
+
 	err = sky2_rx_start(sky2);
 	if (err)
 		goto err_out;
@@ -1500,6 +1502,9 @@ static int sky2_up(struct net_device *dev)

 	sky2_set_multicast(dev);

+	/* wake queue incase we are restarting */
+	netif_wake_queue(dev);
+
 	if (netif_msg_ifup(sky2))
 		printk(KERN_INFO PFX "%s: enabling interface\n", dev->name);
 	return 0;
@@ -1533,6 +1538,8 @@ static inline int tx_dist(unsigned tail, unsigned head)
 /* Number of list elements available for next tx */
 static inline int tx_avail(const struct sky2_port *sky2)
 {
+	if (unlikely(sky2->restarting))
+		return 0;
 	return sky2->tx_pending - tx_dist(sky2->tx_cons, sky2->tx_prod);
 }

@@ -1818,6 +1825,10 @@ static int sky2_down(struct net_device *dev)
 	if (netif_msg_ifdown(sky2))
 		printk(KERN_INFO PFX "%s: disabling interface\n", dev->name);

+	/* explicitly shut off tx incase we're restarting */
+	sky2->restarting = 1;
+	netif_tx_disable(dev);
+
 	/* Force flow control off */
 	sky2_write8(hw, SK_REG(port, GMAC_CTRL), GMC_PAUSE_OFF);

@@ -2359,7 +2370,7 @@ static inline void sky2_tx_done(struct
net_device *dev, u16 last)
 {
 	struct sky2_port *sky2 = netdev_priv(dev);

-	if (netif_running(dev)) {
+	if (likely(netif_running(dev) && !sky2->restarting)) {
 		netif_tx_lock(dev);
 		sky2_tx_complete(sky2, last);
 		netif_tx_unlock(dev);
@@ -4283,6 +4294,7 @@ static __devinit struct net_device
*sky2_init_netdev(struct sky2_hw *hw,
 	spin_lock_init(&sky2->phy_lock);
 	sky2->tx_pending = TX_DEF_PENDING;
 	sky2->rx_pending = RX_DEF_PENDING;
+	sky2->restarting = 0;

 	hw->dev[port] = dev;

diff --git a/drivers/net/sky2.h b/drivers/net/sky2.h
index b5549c9..4486b06 100644
--- a/drivers/net/sky2.h
+++ b/drivers/net/sky2.h
@@ -2051,6 +2051,7 @@ struct sky2_port {
 	u8		     duplex;	/* DUPLEX_HALF, DUPLEX_FULL */
 	u8		     rx_csum;
 	u8		     wol;
+	u8		     restarting;
  	enum flow_control    flow_mode;
  	enum flow_control    flow_status;

-- 
1.5.6.5
