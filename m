From: Alexander Schulz <alex@shark-linux.de>
Subject: Reading MAC Address from a CS89x0 without eeprom
Date: Thu, 08 Jan 2009 20:25:01 +0100
Message-ID: <4966530D.3050103@shark-linux.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: alex@shark-linux.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shark-linux.de ([81.169.184.142]:58276 "EHLO shark-linux.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751474AbZAHTaH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Jan 2009 14:30:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

on my machine, an ARM based board, there is a SUN-like openprom
firmware that initializes hardware using one global eeprom. It
also initializes the network chip (CS89x0) with a MAC Address. The
current Linux driver has the ability to read the address from the
chip but it only does it if it detects an eeprom attached to the
chip. There is no dedicated eeprom on my board. So I would like
to include something like the following possibility to read the mac
address from the chip anyway. I discussed this on the ARM devel
list and was redirected here, so I hope you can help me.

Thanks
   Alexander

diff -udpNr -x '*.cmd' -x '*.o'
linux-2.6.28-git6-org/drivers/net/cs89x0.c linux-2.6.28/drivers/net/cs89x0.c
--- linux-2.6.28-git6-org/drivers/net/cs89x0.c  2009-01-04
12:07:04.000000000 +0100
+++ linux-2.6.28/drivers/net/cs89x0.c   2009-01-08 17:17:32.000000000 +0100
@@ -670,8 +670,14 @@ cs89x0_probe1(struct net_device *dev, in
          } else
   #endif

+#ifndef CONFIG_CS89x0_NOEEPROM
+        /* On some systems the chip might be initialized by firmware
+         * even though it does not have an EEPROM.
+         * So let's read the config from the chip anyway. */
           if ((readreg(dev, PP_SelfST) & (EEPROM_OK | EEPROM_PRESENT)) ==
-             (EEPROM_OK|EEPROM_PRESENT)) {
+             (EEPROM_OK|EEPROM_PRESENT))
+#endif
+              {
                  /* Load the MAC. */
                  for (i=0; i < ETH_ALEN/2; i++) {
                          unsigned int Addr;
diff -udpNr -x '*.cmd' -x '*.o'
linux-2.6.28-git6-org/drivers/net/Kconfig linux-2.6.28/drivers/net/Kconfig
--- linux-2.6.28-git6-org/drivers/net/Kconfig   2009-01-04
12:07:02.000000000 +0100
+++ linux-2.6.28/drivers/net/Kconfig    2009-01-08 17:22:32.000000000 +0100
@@ -1424,6 +1424,19 @@ config CS89x0_NONISA_IRQ
          depends on CS89x0 != n
          depends on MACH_IXDP2351 || ARCH_IXDP2X01 || ARCH_PNX010X ||
MACH_MX31ADS

+config CS89x0_NOEEPROM
+       bool "Always read MAC Address from the chip"
+       depends on CS89x0 != n
+       default y if ARCH_SHARK
+       ---help---
+         If you say Y here, the MAC address is read from the CS89x0
+         even if there is no EEPROM connected to it that could hold
+         the address. This is useful if the chip was previously
+         initialized by some firmware or bootloader that uses other
+         means to determine a unique MAC address like a global EEPROM
+         for many different hardware settings.
+
+
   config TC35815
          tristate "TOSHIBA TC35815 Ethernet support"
          depends on NET_PCI && PCI && MIPS
