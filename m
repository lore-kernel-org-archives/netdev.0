From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH] ipv6: alternative version of S/390 shared NIC support
Date: Sun, 16 Jan 2005 12:54:31 +0100
Message-ID: <20050116115431.GA13617@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: waldi@debian.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net, pavlic@de.ibm.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Let's try again solvign the EUI64 generation for S/390.  I looked over
the IBM patch and I think it can be done a lot simpler:

 - put a dev_id field in struct net_device, so that it uses space that
   would be wasted by padding otherwise.
 - if this fields is non-null let ipv6_generate_eui64 use the algorithm
   from the QETH code to generate an EUI that's different for each
   OS instance.  See code comments for details.


--- 1.23/drivers/s390/net/qeth_main.c	2005-01-04 00:49:39 +01:00
+++ edited/drivers/s390/net/qeth_main.c	2005-01-16 12:33:52 +01:00
@@ -5033,27 +5033,6 @@
 	return 0;
 }
 
-#ifdef CONFIG_QETH_IPV6
-int
-qeth_ipv6_generate_eui64(u8 * eui, struct net_device *dev)
-{
-	switch (dev->type) {
-	case ARPHRD_ETHER:
-	case ARPHRD_FDDI:
-	case ARPHRD_IEEE802_TR:
-		if (dev->addr_len != ETH_ALEN)
-			return -1;
-		memcpy(eui, dev->dev_addr, 3);
-		memcpy(eui + 5, dev->dev_addr + 3, 3);
-		eui[3] = (dev->dev_id >> 8) & 0xff;
-		eui[4] = dev->dev_id & 0xff;
-		return 0;
-	}
-	return -1;
-
-}
-#endif
-
 static void
 qeth_get_mac_for_ipm(__u32 ipm, char *mac, struct net_device *dev)
 {
@@ -5587,11 +5566,8 @@
 	}
 #ifdef CONFIG_QETH_IPV6
 	/*IPv6 address autoconfiguration stuff*/
-	card->dev->dev_id = card->info.unique_id & 0xffff;
 	if (!(card->info.unique_id & UNIQUE_ID_NOT_BY_CARD))
-		card->dev->generate_eui64 = qeth_ipv6_generate_eui64;
-
-
+		card->dev->dev_id = card->info.unique_id & 0xffff;
 #endif
 	dev->hard_header_parse = NULL;
 	dev->set_mac_address = qeth_layer2_set_mac_address;
--- 1.95/include/linux/netdevice.h	2005-01-10 21:23:55 +01:00
+++ edited/include/linux/netdevice.h	2005-01-16 12:32:07 +01:00
@@ -345,6 +345,7 @@
 	unsigned char		broadcast[MAX_ADDR_LEN];	/* hw bcast add	*/
 	unsigned char		dev_addr[MAX_ADDR_LEN];	/* hw address	*/
 	unsigned char		addr_len;	/* hardware address length	*/
+	unsigned short          dev_id;		/* for shared network cards */
 
 	struct dev_mc_list	*mc_list;	/* Multicast mac addresses	*/
 	int			mc_count;	/* Number of installed mcasts	*/
--- 1.128/net/ipv6/addrconf.c	2005-01-14 22:30:07 +01:00
+++ edited/net/ipv6/addrconf.c	2005-01-16 12:29:51 +01:00
@@ -1079,10 +1079,29 @@
 		if (dev->addr_len != ETH_ALEN)
 			return -1;
 		memcpy(eui, dev->dev_addr, 3);
-		memcpy(eui + 5, dev->dev_addr+3, 3);
-		eui[3] = 0xFF;
-		eui[4] = 0xFE;
-		eui[0] ^= 2;
+		memcpy(eui + 5, dev->dev_addr + 3, 3);
+
+		/*
+		 * The zSeries OSA network cards can be shared among various
+		 * OS instances, but the OSA cards have only one MAC address.
+		 * This leads to duplicate address conflicts in conjunction
+		 * with IPv6 if more than one instance uses the same card.
+		 * 
+		 * The driver for these cards can deliver a unique 16-bit
+		 * identifier for each instance sharing the same card.  It is
+		 * placed instead of 0xFFFE in the interface identifier.  The
+		 * "u" bit of the interface identifier is not inverted in this
+		 * case.  Hence the resulting interface identifier has local
+		 * scope according to RFC2373.
+		 */
+		if (dev->dev_id) {
+			eui[3] = (dev->dev_id >> 8) & 0xFF;
+			eui[4] = dev->dev_id & 0xFF;
+		} else {
+			eui[3] = 0xFF;
+			eui[4] = 0xFE;
+			eui[0] ^= 2;
+		}
 		return 0;
 	case ARPHRD_ARCNET:
 		/* XXX: inherit EUI-64 from other interface -- yoshfuji */
