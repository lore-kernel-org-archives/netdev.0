From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH -next] net: cris: make eth_v10.c explicitly non-modular
Date: Mon, 31 Oct 2016 15:32:16 -0400
Message-ID: <20161031193216.28154-1-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>,
        "David S. Miller" <davem@davemloft.net>,
        Mikael Starvik <starvik@axis.com>,
        Jesper Nilsson <jesper.nilsson@axis.com>,
        <linux-cris-kernel@axis.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:45754 "EHLO
        mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S945939AbcJaTdc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2016 15:33:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Makefile/Kconfig currently controlling compilation of this code is:

drivers/net/cris/Makefile:obj-$(CONFIG_ETRAX_ARCH_V10) += eth_v10.o

arch/cris/Kconfig:config ETRAX_ARCH_V10
arch/cris/Kconfig:       bool

...meaning that it currently is not being built as a module by anyone.

Lets remove the couple traces of modular infrastructure use, so that
when reading the driver there is no doubt it is builtin-only.

Since module_init translates to device_initcall in the non-modular
case, the init ordering remains unchanged with this commit.

There was a one line wrapper for the int init function, which made no
sense; hence we just put the device_initcall on the true init function
itself and delete the pointless wrapper.  In doing that we get rid of
the following compile warning:

   WARNING: drivers/net/built-in.o(.text+0x1e28): Section mismatch in
   reference from the function etrax_init_module() to the function
   .init.text:etrax_ethernet_init()

We don't replace module.h with init.h since the file already has that.

Cc: "David S. Miller" <davem@davemloft.net>
Cc: Mikael Starvik <starvik@axis.com>
Cc: Jesper Nilsson <jesper.nilsson@axis.com>
Cc: netdev@vger.kernel.org
Cc: linux-cris-kernel@axis.com
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 drivers/net/cris/eth_v10.c | 11 +----------
 1 file changed, 1 insertion(+), 10 deletions(-)

diff --git a/drivers/net/cris/eth_v10.c b/drivers/net/cris/eth_v10.c
index 221f5f011ff9..b37be25f7459 100644
--- a/drivers/net/cris/eth_v10.c
+++ b/drivers/net/cris/eth_v10.c
@@ -7,9 +7,6 @@
  *
  */
 
-
-#include <linux/module.h>
-
 #include <linux/kernel.h>
 #include <linux/delay.h>
 #include <linux/types.h>
@@ -412,6 +409,7 @@ etrax_ethernet_init(void)
 	led_next_time = jiffies;
 	return 0;
 }
+device_initcall(etrax_ethernet_init)
 
 /* set MAC address of the interface. called from the core after a
  * SIOCSIFADDR ioctl, and from the bootup above.
@@ -1715,11 +1713,6 @@ e100_netpoll(struct net_device* netdev)
 }
 #endif
 
-static int
-etrax_init_module(void)
-{
-	return etrax_ethernet_init();
-}
 
 static int __init
 e100_boot_setup(char* str)
@@ -1742,5 +1735,3 @@ e100_boot_setup(char* str)
 }
 
 __setup("etrax100_eth=", e100_boot_setup);
-
-module_init(etrax_init_module);
-- 
2.8.4
