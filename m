From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 5/11][TG3]: Remove reset during MAC address changes.
Date: Fri, 04 May 2007 17:52:58 -0700
Message-ID: <1178326378.4859.21.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3931 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1767925AbXEEAFq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 May 2007 20:05:46 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[TG3]: Remove reset during MAC address changes.

The reset was added a while back so that ASF could re-init whatever
MAC address it wanted to use after the MAC address was changed.
Instead of resetting, we can just keep MAC address 1 unchanged during
MAC address changes if MAC address 1 is different from MAC address 0.

This fixes 2 problems:

1. Bonding calls set_mac_address in contexts that cannot sleep.
It no longer sleeps with the chip reset removed.

2. When ASF shares the same MAC address as the NIC, it needs to
always do that even when the MAC address is changed. 

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index e829262..6094d6b 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -5934,7 +5934,7 @@ static int tg3_load_tso_firmware(struct tg3 *tp)
 
 
 /* tp->lock is held. */
-static void __tg3_set_mac_addr(struct tg3 *tp)
+static void __tg3_set_mac_addr(struct tg3 *tp, int skip_mac_1)
 {
 	u32 addr_high, addr_low;
 	int i;
@@ -5946,6 +5946,8 @@ static void __tg3_set_mac_addr(struct tg3 *tp)
 		    (tp->dev->dev_addr[4] <<  8) |
 		    (tp->dev->dev_addr[5] <<  0));
 	for (i = 0; i < 4; i++) {
+		if (i == 1 && skip_mac_1)
+			continue;
 		tw32(MAC_ADDR_0_HIGH + (i * 8), addr_high);
 		tw32(MAC_ADDR_0_LOW + (i * 8), addr_low);
 	}
@@ -5972,7 +5974,7 @@ static int tg3_set_mac_addr(struct net_device *dev, void *p)
 {
 	struct tg3 *tp = netdev_priv(dev);
 	struct sockaddr *addr = p;
-	int err = 0;
+	int err = 0, skip_mac_1 = 0;
 
 	if (!is_valid_ether_addr(addr->sa_data))
 		return -EINVAL;
@@ -5983,22 +5985,21 @@ static int tg3_set_mac_addr(struct net_device *dev, void *p)
 		return 0;
 
 	if (tp->tg3_flags & TG3_FLAG_ENABLE_ASF) {
-		/* Reset chip so that ASF can re-init any MAC addresses it
-		 * needs.
-		 */
-		tg3_netif_stop(tp);
-		tg3_full_lock(tp, 1);
+		u32 addr0_high, addr0_low, addr1_high, addr1_low;
 
-		tg3_halt(tp, RESET_KIND_SHUTDOWN, 1);
-		err = tg3_restart_hw(tp, 0);
-		if (!err)
-			tg3_netif_start(tp);
-		tg3_full_unlock(tp);
-	} else {
-		spin_lock_bh(&tp->lock);
-		__tg3_set_mac_addr(tp);
-		spin_unlock_bh(&tp->lock);
+		addr0_high = tr32(MAC_ADDR_0_HIGH);
+		addr0_low = tr32(MAC_ADDR_0_LOW);
+		addr1_high = tr32(MAC_ADDR_1_HIGH);
+		addr1_low = tr32(MAC_ADDR_1_LOW);
+
+		/* Skip MAC addr 1 if ASF is using it. */
+		if ((addr0_high != addr1_high || addr0_low != addr1_low) &&
+		    !(addr1_high == 0 && addr1_low == 0))
+			skip_mac_1 = 1;
 	}
+	spin_lock_bh(&tp->lock);
+	__tg3_set_mac_addr(tp, skip_mac_1);
+	spin_unlock_bh(&tp->lock);
 
 	return err;
 }
@@ -6315,7 +6316,7 @@ static int tg3_reset_hw(struct tg3 *tp, int reset_phy)
 		     tp->rx_jumbo_ptr);
 
 	/* Initialize MAC address and backoff seed. */
-	__tg3_set_mac_addr(tp);
+	__tg3_set_mac_addr(tp, 0);
 
 	/* MTU + ethernet header + FCS + optional VLAN tag */
 	tw32(MAC_RX_MTU_SIZE, tp->dev->mtu + ETH_HLEN + 8);


