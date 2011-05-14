From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [RFC] ethernet: avoid pre-assigned OUI values in random_ether_addr
Date: Fri, 13 May 2011 17:17:29 -0700
Message-ID: <20110513171729.247b126e@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:35233 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758423Ab1ENARc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 May 2011 20:17:32 -0400
Received: from localhost (localhost.localdomain [127.0.0.1])
	by mail.vyatta.com (Postfix) with ESMTP id F31A118297AF
	for <netdev@vger.kernel.org>; Fri, 13 May 2011 17:17:31 -0700 (PDT)
Received: from mail.vyatta.com ([127.0.0.1])
	by localhost (mail.vyatta.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 1KvVz5PB1Kx9 for <netdev@vger.kernel.org>;
	Fri, 13 May 2011 17:17:31 -0700 (PDT)
Received: from nehalam (static-50-53-80-93.bvtn.or.frontiernet.net [50.53.80.93])
	by mail.vyatta.com (Postfix) with ESMTPSA id 079651829797
	for <netdev@vger.kernel.org>; Fri, 13 May 2011 17:17:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are some addresses in the assigned vendor block that don't obey
the locally assigned convention. These should be avoided by random_ether_addr
assignment.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 include/linux/etherdevice.h |   17 +----------------
 net/ethernet/eth.c          |   42 ++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 43 insertions(+), 16 deletions(-)

--- a/include/linux/etherdevice.h	2011-05-13 12:37:08.199257621 -0700
+++ b/include/linux/etherdevice.h	2011-05-13 16:48:46.722745009 -0700
@@ -45,8 +45,7 @@ extern void eth_header_cache_update(stru
 extern int eth_mac_addr(struct net_device *dev, void *p);
 extern int eth_change_mtu(struct net_device *dev, int new_mtu);
 extern int eth_validate_addr(struct net_device *dev);
-
-
+extern void random_ether_addr(u8 *addr);
 
 extern struct net_device *alloc_etherdev_mqs(int sizeof_priv, unsigned int txqs,
 					    unsigned int rxqs);
@@ -126,20 +125,6 @@ static inline int is_valid_ether_addr(co
 }
 
 /**
- * random_ether_addr - Generate software assigned random Ethernet address
- * @addr: Pointer to a six-byte array containing the Ethernet address
- *
- * Generate a random Ethernet address (MAC) that is not multicast
- * and has the local assigned bit set.
- */
-static inline void random_ether_addr(u8 *addr)
-{
-	get_random_bytes (addr, ETH_ALEN);
-	addr [0] &= 0xfe;	/* clear multicast bit */
-	addr [0] |= 0x02;	/* set local assignment bit (IEEE802) */
-}
-
-/**
  * dev_hw_addr_random - Create random MAC and set device flag
  * @dev: pointer to net_device structure
  * @hwaddr: Pointer to a six-byte array containing the Ethernet address
--- a/net/ethernet/eth.c	2011-05-13 12:37:08.219257985 -0700
+++ b/net/ethernet/eth.c	2011-05-13 17:03:39.412209908 -0700
@@ -392,3 +392,46 @@ ssize_t sysfs_format_mac(char *buf, cons
 	return (ssize_t)l;
 }
 EXPORT_SYMBOL(sysfs_format_mac);
+
+/* These vendors are known to violate the local MAC address assignment
+   convention. Avoid using them. */
+static const struct {
+	u8 oui[3];
+} inuse[] = {
+	{ .oui = { 0x02, 0x07, 0x01 } }, /* Interlan */
+	{ .oui = { 0x02, 0x60, 0x60 } }, /* 3Com */
+	{ .oui = { 0x02, 0x60, 0x8c } }, /* 3Com */
+	{ .oui = { 0x02, 0xa0, 0xc9 } }, /* Intel */
+	{ .oui = { 0x02, 0xaa, 0x3c } }, /* Olivetti */
+	{ .oui = { 0x02, 0xcf, 0x1f } }, /* CMC */
+	{ .oui = { 0x02, 0xe0, 0x3b } }, /* Prominet */
+	{ .oui = { 0x02, 0xe6, 0xd3 } }, /* BTI */
+	{ .oui = { 0x52, 0x54, 0x00 } }, /* Realtek */
+	{ .oui = { 0x52, 0x54, 0x4c } }, /* Novell 2000 */
+	{ .oui = { 0x52, 0x54, 0xab } }, /* Realtec */
+	{ .oui = { 0xe2, 0x0c, 0x0f } }, /* Kingston Technologies */
+};
+
+/**
+ * random_ether_addr - Generate software assigned random Ethernet address
+ * @addr: Pointer to a six-byte array containing the Ethernet address
+ *
+ * Generate a random Ethernet address (MAC) that is not multicast
+ * and has the local assigned bit set.
+ */
+
+void random_ether_addr(u8 *addr)
+{
+	int i;
+
+ retry:
+	get_random_bytes (addr, ETH_ALEN);
+
+	addr [0] &= 0xfe;	/* clear multicast bit */
+	addr [0] |= 0x02;	/* set local assignment bit (IEEE802) */
+
+	for (i = 0; i < ARRAY_SIZE(inuse); i++)
+		if (memcmp(inuse[i].oui, addr, 3) == 0)
+			goto retry;
+}
+EXPORT_SYMBOL(random_ether_addr);
