From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Yet more fixes to etherh.c
Date: Sat, 21 Feb 2009 19:36:33 +0000
Message-ID: <20090221193633.GD16596@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>
To: linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:58352 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751729AbZBUTgl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Feb 2009 14:36:41 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Further to a71558d, this is round five of fixes to make etherh work
again. As mainline kernels stand, the fixes in b9a9b4b were the wrong
approach.

The 8390 driver was structured by Al Viro to allow the flexibility required
by platforms.  lib8390.c contains the core code which drivers explicitly
include:
- 8390.c includes lib8390.c to provide the standard ISA based driver.
- etherh.c includes it with the accessors defined for RiscPC platforms,
  where it is addressed via the MMIO accessors with a device dependent
  register spacing.

Other platform drivers do something similar.

However, b9a9b4b caused the kernel to contain not only the etherh private
build of lib8390 (included in etherh.c) but also lib8390.c itself, and
referred the new net_device_ops methods to the ISA version.  The result
of this is is not pretty:

Unable to handle kernel paging request at virtual address 12032030
pgd = c8330000
[12032030] *pgd=00000000
Internal error: Oops: 18331805 [#1]
Modules linked in: ipv6
CPU: 0    Not tainted  (2.6.29-rc3 #167)
PC is at do_set_multicast_list+0xd0/0x190
LR is at bitrev32+0x28/0x34
pc : [<c017aab4>]    lr : [<c0139120>]    psr: a0000093
sp : c8321d9c  ip : c8321d84  fp : c8321dbc
r10: c80c6800  r9 : 00000000  r8 : c80c6b60
r7 : c80c6b80  r6 : cc80c800  r5 : c80c6800  r4 : 00000000
r3 : cc80c80c  r2 : 00000004  r1 : 00000007  r0 : e0000000
Flags: NzCv  IRQs off  FIQs on  Mode SVC_32  ISA ARM  Segment user
...

Fix up b9a9b4b by making etherh's net_device_ops refer to the internal
lib8390 functions, and remove the build of the ISA 8390.c driver.

Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>

diff --git a/drivers/net/arm/Makefile b/drivers/net/arm/Makefile
index c69c0cd..811a3cc 100644
--- a/drivers/net/arm/Makefile
+++ b/drivers/net/arm/Makefile
@@ -4,7 +4,7 @@
 #
 
 obj-$(CONFIG_ARM_AM79C961A)	+= am79c961a.o
-obj-$(CONFIG_ARM_ETHERH)	+= etherh.o ../8390.o
+obj-$(CONFIG_ARM_ETHERH)	+= etherh.o
 obj-$(CONFIG_ARM_ETHER3)	+= ether3.o
 obj-$(CONFIG_ARM_ETHER1)	+= ether1.o
 obj-$(CONFIG_ARM_AT91_ETHER)	+= at91_ether.o
diff --git a/drivers/net/arm/etherh.c b/drivers/net/arm/etherh.c
index 54b52e5..f52f668 100644
--- a/drivers/net/arm/etherh.c
+++ b/drivers/net/arm/etherh.c
@@ -641,15 +641,15 @@ static const struct net_device_ops etherh_netdev_ops = {
 	.ndo_open		= etherh_open,
 	.ndo_stop		= etherh_close,
 	.ndo_set_config		= etherh_set_config,
-	.ndo_start_xmit		= ei_start_xmit,
-	.ndo_tx_timeout		= ei_tx_timeout,
-	.ndo_get_stats		= ei_get_stats,
-	.ndo_set_multicast_list = ei_set_multicast_list,
+	.ndo_start_xmit		= __ei_start_xmit,
+	.ndo_tx_timeout		= __ei_tx_timeout,
+	.ndo_get_stats		= __ei_get_stats,
+	.ndo_set_multicast_list = __ei_set_multicast_list,
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_set_mac_address	= eth_mac_addr,
 	.ndo_change_mtu		= eth_change_mtu,
 #ifdef CONFIG_NET_POLL_CONTROLLER
-	.ndo_poll_controller	= ei_poll,
+	.ndo_poll_controller	= __ei_poll,
 #endif
 };
 
