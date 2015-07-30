From: Matan Barak <matanb@mellanox.com>
Subject: [PATCH for-next V7 01/10] net/ipv6: Export addrconf_ifid_eui48
Date: Thu, 30 Jul 2015 18:33:22 +0300
Message-ID: <1438270411-17648-2-git-send-email-matanb@mellanox.com>
References: <1438270411-17648-1-git-send-email-matanb@mellanox.com>
Cc: Matan Barak <matanb@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
	linux-rdma@vger.kernel.org, Sean Hefty <sean.hefty@intel.com>,
	Somnath Kotur <Somnath.Kotur@Avagotech.Com>,
	Moni Shoua <monis@mellanox.com>, talal@mellanox.com,
	haggaie@mellanox.com, netdev@vger.kernel.org
To: Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:45221 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751182AbbG3PeW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Jul 2015 11:34:22 -0400
In-Reply-To: <1438270411-17648-1-git-send-email-matanb@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For loopback purposes, RoCE devices should have a default GID in the
port GID table, even when the interface is down. In order to do so,
we use the IPv6 link local address which would have been genenrated
for the related Ethernet netdevice when it goes up as a default GID.

addrconf_ifid_eui48 is used to gernerate this address, export it.

Signed-off-by: Matan Barak <matanb@mellanox.com>
---
 include/net/addrconf.h | 31 +++++++++++++++++++++++++++++++
 net/ipv6/addrconf.c    | 31 -------------------------------
 2 files changed, 31 insertions(+), 31 deletions(-)

diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index def59d3..431fdfa 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -91,6 +91,37 @@ int ipv6_rcv_saddr_equal(const struct sock *sk, const struct sock *sk2);
 void addrconf_join_solict(struct net_device *dev, const struct in6_addr *addr);
 void addrconf_leave_solict(struct inet6_dev *idev, const struct in6_addr *addr);
 
+static inline int addrconf_ifid_eui48(u8 *eui, struct net_device *dev)
+{
+	if (dev->addr_len != ETH_ALEN)
+		return -1;
+	memcpy(eui, dev->dev_addr, 3);
+	memcpy(eui + 5, dev->dev_addr + 3, 3);
+
+	/*
+	 * The zSeries OSA network cards can be shared among various
+	 * OS instances, but the OSA cards have only one MAC address.
+	 * This leads to duplicate address conflicts in conjunction
+	 * with IPv6 if more than one instance uses the same card.
+	 *
+	 * The driver for these cards can deliver a unique 16-bit
+	 * identifier for each instance sharing the same card.  It is
+	 * placed instead of 0xFFFE in the interface identifier.  The
+	 * "u" bit of the interface identifier is not inverted in this
+	 * case.  Hence the resulting interface identifier has local
+	 * scope according to RFC2373.
+	 */
+	if (dev->dev_id) {
+		eui[3] = (dev->dev_id >> 8) & 0xFF;
+		eui[4] = dev->dev_id & 0xFF;
+	} else {
+		eui[3] = 0xFF;
+		eui[4] = 0xFE;
+		eui[0] ^= 2;
+	}
+	return 0;
+}
+
 static inline unsigned long addrconf_timeout_fixup(u32 timeout,
 						   unsigned int unit)
 {
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 21c2c81..5b0c041 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1845,37 +1845,6 @@ static void addrconf_leave_anycast(struct inet6_ifaddr *ifp)
 	__ipv6_dev_ac_dec(ifp->idev, &addr);
 }
 
-static int addrconf_ifid_eui48(u8 *eui, struct net_device *dev)
-{
-	if (dev->addr_len != ETH_ALEN)
-		return -1;
-	memcpy(eui, dev->dev_addr, 3);
-	memcpy(eui + 5, dev->dev_addr + 3, 3);
-
-	/*
-	 * The zSeries OSA network cards can be shared among various
-	 * OS instances, but the OSA cards have only one MAC address.
-	 * This leads to duplicate address conflicts in conjunction
-	 * with IPv6 if more than one instance uses the same card.
-	 *
-	 * The driver for these cards can deliver a unique 16-bit
-	 * identifier for each instance sharing the same card.  It is
-	 * placed instead of 0xFFFE in the interface identifier.  The
-	 * "u" bit of the interface identifier is not inverted in this
-	 * case.  Hence the resulting interface identifier has local
-	 * scope according to RFC2373.
-	 */
-	if (dev->dev_id) {
-		eui[3] = (dev->dev_id >> 8) & 0xFF;
-		eui[4] = dev->dev_id & 0xFF;
-	} else {
-		eui[3] = 0xFF;
-		eui[4] = 0xFE;
-		eui[0] ^= 2;
-	}
-	return 0;
-}
-
 static int addrconf_ifid_eui64(u8 *eui, struct net_device *dev)
 {
 	if (dev->addr_len != IEEE802154_ADDR_LEN)
-- 
2.1.0

Cc: netdev@vger.kernel.org
