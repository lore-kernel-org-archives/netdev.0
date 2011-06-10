From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: [PATCH 2/3] NET: am79c961: ensure multicast filter is correctly set
 at open
Date: Fri, 10 Jun 2011 11:52:14 +0100
Message-ID: <E1QUzK2-0004BA-MC@rmk-PC.arm.linux.org.uk>
References: <20110610105122.GA27087@flint.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:35113 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755257Ab1FJKwS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jun 2011 06:52:18 -0400
Received: from e0022681537dd.dyn.arm.linux.org.uk ([2002:4e20:1eda:1:222:68ff:fe15:37dd] helo=rmk-PC.arm.linux.org.uk)
	by caramon.arm.linux.org.uk with esmtpsa (TLSv1:AES256-SHA:256)
	(Exim 4.72)
	(envelope-from <rmk@arm.linux.org.uk>)
	id 1QUzK3-0006Q6-PH
	for netdev@vger.kernel.org; Fri, 10 Jun 2011 11:52:16 +0100
Received: from rmk by rmk-PC.arm.linux.org.uk with local (Exim 4.76)
	(envelope-from <rmk@arm.linux.org.uk>)
	id 1QUzK2-0004BA-MC
	for netdev@vger.kernel.org; Fri, 10 Jun 2011 11:52:15 +0100
In-Reply-To: <20110610105122.GA27087@flint.arm.linux.org.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We were clearing out the multicast filter whenever the interface was
upped, and not setting the mode bits correctly.  This can cause
problems if there are any multicast addresses already set at this
point, or if ALLMULTI was set.

Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
---
 drivers/net/arm/am79c961a.c |   77 ++++++++++++++++++++++--------------------
 1 files changed, 40 insertions(+), 37 deletions(-)

diff --git a/drivers/net/arm/am79c961a.c b/drivers/net/arm/am79c961a.c
index 084b67f..79d88a0 100644
--- a/drivers/net/arm/am79c961a.c
+++ b/drivers/net/arm/am79c961a.c
@@ -196,6 +196,42 @@ am79c961_ramtest(struct net_device *dev, unsigned int val)
 	return errorcount;
 }
 
+static void am79c961_mc_hash(char *addr, u16 *hash)
+{
+	if (addr[0] & 0x01) {
+		int idx, bit;
+		u32 crc;
+
+		crc = ether_crc_le(ETH_ALEN, addr);
+
+		idx = crc >> 30;
+		bit = (crc >> 26) & 15;
+
+		hash[idx] |= 1 << bit;
+	}
+}
+
+static unsigned int am79c961_get_rx_mode(struct net_device *dev, u16 *hash)
+{
+	unsigned int mode = MODE_PORT_10BT;
+
+	if (dev->flags & IFF_PROMISC) {
+		mode |= MODE_PROMISC;
+		memset(hash, 0xff, 4 * sizeof(*hash));
+	} else if (dev->flags & IFF_ALLMULTI) {
+		memset(hash, 0xff, 4 * sizeof(*hash));
+	} else {
+		struct netdev_hw_addr *ha;
+
+		memset(hash, 0, 4 * sizeof(*hash));
+
+		netdev_for_each_mc_addr(ha, dev)
+			am79c961_mc_hash(ha->addr, hash);
+	}
+
+	return mode;
+}
+
 static void
 am79c961_init_for_open(struct net_device *dev)
 {
@@ -203,6 +239,7 @@ am79c961_init_for_open(struct net_device *dev)
 	unsigned long flags;
 	unsigned char *p;
 	u_int hdr_addr, first_free_addr;
+	u16 multi_hash[4], mode = am79c961_get_rx_mode(dev, multi_hash);
 	int i;
 
 	/*
@@ -218,16 +255,12 @@ am79c961_init_for_open(struct net_device *dev)
 	write_ireg (dev->base_addr, 2, 0x0000); /* MODE register selects media */
 
 	for (i = LADRL; i <= LADRH; i++)
-		write_rreg (dev->base_addr, i, 0);
+		write_rreg (dev->base_addr, i, multi_hash[i - LADRL]);
 
 	for (i = PADRL, p = dev->dev_addr; i <= PADRH; i++, p += 2)
 		write_rreg (dev->base_addr, i, p[0] | (p[1] << 8));
 
-	i = MODE_PORT_10BT;
-	if (dev->flags & IFF_PROMISC)
-		i |= MODE_PROMISC;
-
-	write_rreg (dev->base_addr, MODE, i);
+	write_rreg (dev->base_addr, MODE, mode);
 	write_rreg (dev->base_addr, POLLINT, 0);
 	write_rreg (dev->base_addr, SIZERXR, -RX_BUFFERS);
 	write_rreg (dev->base_addr, SIZETXR, -TX_BUFFERS);
@@ -340,21 +373,6 @@ am79c961_close(struct net_device *dev)
 	return 0;
 }
 
-static void am79c961_mc_hash(char *addr, unsigned short *hash)
-{
-	if (addr[0] & 0x01) {
-		int idx, bit;
-		u32 crc;
-
-		crc = ether_crc_le(ETH_ALEN, addr);
-
-		idx = crc >> 30;
-		bit = (crc >> 26) & 15;
-
-		hash[idx] |= 1 << bit;
-	}
-}
-
 /*
  * Set or clear promiscuous/multicast mode filter for this adapter.
  */
@@ -362,24 +380,9 @@ static void am79c961_setmulticastlist (struct net_device *dev)
 {
 	struct dev_priv *priv = netdev_priv(dev);
 	unsigned long flags;
-	unsigned short multi_hash[4], mode;
+	u16 multi_hash[4], mode = am79c961_get_rx_mode(dev, multi_hash);
 	int i, stopped;
 
-	mode = MODE_PORT_10BT;
-
-	if (dev->flags & IFF_PROMISC) {
-		mode |= MODE_PROMISC;
-	} else if (dev->flags & IFF_ALLMULTI) {
-		memset(multi_hash, 0xff, sizeof(multi_hash));
-	} else {
-		struct netdev_hw_addr *ha;
-
-		memset(multi_hash, 0x00, sizeof(multi_hash));
-
-		netdev_for_each_mc_addr(ha, dev)
-			am79c961_mc_hash(ha->addr, multi_hash);
-	}
-
 	spin_lock_irqsave(&priv->chip_lock, flags);
 
 	stopped = read_rreg(dev->base_addr, CSR0) & CSR0_STOP;
-- 
1.7.4.4

