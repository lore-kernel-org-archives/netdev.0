From: Finn Thain <fthain@telegraphics.com.au>
Subject: Re: [PATCH] mac8390: fix regression caused during net_device_ops
 conversion, take 2
Date: Thu, 28 May 2009 15:26:43 +1000 (EST)
Message-ID: <Pine.LNX.4.64.0905281454450.9036@loopy.telegraphics.com.au>
References: <Pine.LNX.4.64.0905260116120.18180@loopy.telegraphics.com.au>
 <10f740e80905270149q2b906d53u8bf71b7d382a57a3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-m68k@vger.kernel.org,
	Geert Uytterhoeven <geert.uytterhoeven@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from loopy.telegraphics.com.au ([202.45.126.152]:38008 "EHLO
	loopy.telegraphics.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755531AbZE1F0u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2009 01:26:50 -0400
In-Reply-To: <10f740e80905270149q2b906d53u8bf71b7d382a57a3@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Changeset ca17584bf2ad1b1e37a5c0e4386728cc5fc9dabc broke mac8390 by adding 
8390.o to the link. That meant that lib8390.c was included twice, once in 
mac8390.c and once in 8390.c, subject to different macros. This patch 
reverts that by avoiding the wrappers in 8390.c. They seem to be of no 
value since COMPAT_NET_DEV_OPS is going away soon.

Tested with a Kinetics EtherPort card.

Signed-off-by: Finn Thain <fthain@telegraphics.com.au>

---

Take 2: this one should make CONFIG_NET_POLL_CONTROLLER=y buildable again. 
Sorry about that.


--- linux-2.6.29.orig/drivers/net/Makefile	2009-05-28 15:15:13.000000000 +1000
+++ linux-2.6.29/drivers/net/Makefile	2009-05-28 15:15:54.000000000 +1000
@@ -304,7 +304,7 @@
 	if (!MACH_IS_MAC)
 		return ERR_PTR(-ENODEV);
 
-	dev = alloc_ei_netdev();
+	dev = ____alloc_ei_netdev(0);
 	if (!dev)
 		return ERR_PTR(-ENOMEM);
 
@@ -481,15 +481,15 @@
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
 #ifdef CONFIG_NET_POLL_CONTROLLER
-	.ndo_poll_controller	= ei_poll,
+	.ndo_poll_controller	= __ei_poll,
 #endif
 };
 
