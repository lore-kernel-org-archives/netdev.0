From: Finn Thain <fthain@telegraphics.com.au>
Subject: [PATCH] mac8390: fix regression caused during net_device_ops conversion
Date: Tue, 26 May 2009 12:50:12 +1000 (EST)
Message-ID: <Pine.LNX.4.64.0905261243230.22373@loopy.telegraphics.com.au>
References: <Pine.LNX.4.64.0905260116120.18180@loopy.telegraphics.com.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	linux-m68k@vger.kernel.org, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-m68k-owner@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0905260116120.18180@loopy.telegraphics.com.au>
Sender: linux-m68k-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Changeset ca17584bf2ad1b1e37a5c0e4386728cc5fc9dabc broke mac8390 by adding 
8390.o to the link. That meant that lib8390.c was included twice, once in 
mac8390.c and once in 8390.c, subject to different macros. This patch 
reverts that by avoiding the wrappers in 8390.c. They seem to be of no 
value since COMPAT_NET_DEV_OPS is going away soon.

Tested with a Kinetics EtherPort card.

Signed-off-by: Finn Thain <fthain@telegraphics.com.au>

---

Resent with netdev list CC'd as requested.


--- linux-2.6.29.orig/drivers/net/Makefile	2009-05-25 23:52:32.000000000 +1000
+++ linux-2.6.29/drivers/net/Makefile	2009-05-25 23:41:36.000000000 +1000
@@ -100,7 +100,7 @@
 obj-$(CONFIG_NET) += Space.o loopback.o
 obj-$(CONFIG_SEEQ8005) += seeq8005.o
 obj-$(CONFIG_NET_SB1000) += sb1000.o
-obj-$(CONFIG_MAC8390) += mac8390.o 8390.o
+obj-$(CONFIG_MAC8390) += mac8390.o
 obj-$(CONFIG_APNE) += apne.o 8390.o
 obj-$(CONFIG_PCMCIA_PCNET) += 8390.o
 obj-$(CONFIG_HP100) += hp100.o
--- linux-2.6.29.orig/drivers/net/mac8390.c	2009-03-24 10:12:14.000000000 +1100
+++ linux-2.6.29/drivers/net/mac8390.c	2009-05-25 23:44:28.000000000 +1000
@@ -304,7 +304,7 @@
 	if (!MACH_IS_MAC)
 		return ERR_PTR(-ENODEV);
 
-	dev = alloc_ei_netdev();
+	dev = ____alloc_ei_netdev(0);
 	if (!dev)
 		return ERR_PTR(-ENOMEM);
 
@@ -481,10 +481,10 @@
 static const struct net_device_ops mac8390_netdev_ops = {
 	.ndo_open 		= mac8390_open,
 	.ndo_stop		= mac8390_close,
-	.ndo_start_xmit		= ei_start_xmit,
-	.ndo_tx_timeout		= ei_tx_timeout,
-	.ndo_get_stats		= ei_get_stats,
-	.ndo_set_multicast_list = ei_set_multicast_list,
+	.ndo_start_xmit		= __ei_start_xmit,
+	.ndo_tx_timeout		= __ei_tx_timeout,
+	.ndo_get_stats		= __ei_get_stats,
+	.ndo_set_multicast_list = __ei_set_multicast_list,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_change_mtu		= eth_change_mtu,
