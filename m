From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [RFC PATCH 5/6] firewire net: IPv6 support (RFC3146).
Date: Sat, 12 Jan 2013 23:21:37 +0900
Message-ID: <50F17171.3050105@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux1394-devel@lists.sourceforge.net,
	yoshfuji@linux-ipv6.org
To: Stephan Gatzka <stephan.gatzka@gmail.com>,
	Stefan Richter <stefanr@s5r6.in-berlin.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:36692 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753456Ab3ALOVj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Jan 2013 09:21:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Send packets for IPv6 multicast via GASP.

CC: Stephan Gatzka <stephan.gatzka@gmail.com>
CC: Stefan Richter <stefanr@s5r6.in-berlin.de>
Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 drivers/firewire/Kconfig |    8 ++++++++
 drivers/firewire/net.c   |   13 ++++++++++---
 2 files changed, 18 insertions(+), 3 deletions(-)

diff --git a/drivers/firewire/Kconfig b/drivers/firewire/Kconfig
index 7224533..2e3018b 100644
--- a/drivers/firewire/Kconfig
+++ b/drivers/firewire/Kconfig
@@ -51,9 +51,17 @@ config FIREWIRE_NET
 	  other implementations of RFC 2734 as found on several operating
 	  systems.  Multicast support is currently limited.
 
+	  Optional IPv6 support is available if you say Y here.
+
 	  To compile this driver as a module, say M here:  The module will be
 	  called firewire-net.
 
+config FIREWIRE_NET_IPV6
+	bool "IPv6 networking over 1394"
+	depends on FIREWIRE_NET=y
+	help
+	  This enabless IPv6 over IEEE 1394, based on RFC 3146.
+
 config FIREWIRE_NOSY
 	tristate "Nosy - a FireWire traffic sniffer for PCILynx cards"
 	depends on PCI
diff --git a/drivers/firewire/net.c b/drivers/firewire/net.c
index 66c4f1c..a21d2f9 100644
--- a/drivers/firewire/net.c
+++ b/drivers/firewire/net.c
@@ -27,6 +27,8 @@
 #include <linux/spinlock.h>
 
 #include <asm/unaligned.h>
+#include <linux/ipv6.h>
+#include <net/addrconf.h>
 #include <net/arp.h>
 #include <net/firewire.h>
 
@@ -1329,13 +1331,18 @@ static netdev_tx_t fwnet_tx(struct sk_buff *skb, struct net_device *net)
 	dg_size = skb->len;
 
 	/*
-	 * Set the transmission type for the packet.  ARP packets and IP
-	 * broadcast packets are sent via GASP.
+	 * Set the transmission type for the packet.  ARP packets, IPv4
+	 * broadcast packets, IPv6 multicast packets are sent via GASP.
 	 */
 	if (memcmp(hdr_buf.h_dest, net->broadcast, FWNET_ALEN) == 0
 	    || proto == htons(ETH_P_ARP)
 	    || (proto == htons(ETH_P_IP)
-		&& IN_MULTICAST(ntohl(ip_hdr(skb)->daddr)))) {
+		&& IN_MULTICAST(ntohl(ip_hdr(skb)->daddr)))
+#if defined(CONFIG_FIREWIRE_NET_IPV6)
+	    || (proto == htons(ETH_P_IPV6)
+		&& ipv6_addr_is_multicast(&ipv6_hdr(skb)->daddr))
+#endif
+	   ) {
 		max_payload        = dev->broadcast_xmt_max_payload;
 		datagram_label_ptr = &dev->broadcast_xmt_datagramlabel;
 
-- 
1.7.9.5
