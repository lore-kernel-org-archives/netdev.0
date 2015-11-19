From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] net: tulip: turn compile-time warning into dev_warn()
Date: Thu, 19 Nov 2015 11:42:26 +0100
Message-ID: <9720627.53btSdPcQU@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: will.deacon@arm.com, ard.biesheuvel@linaro.org,
	Grant Grundler <grundler@parisc-linux.org>
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.10]:59497 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932541AbbKSKmo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2015 05:42:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The tulip driver causes annoying build-time warnings for allmodconfig
builds for all recent architectures:

dec/tulip/winbond-840.c:910:2: warning: #warning Processor architecture undefined
dec/tulip/tulip_core.c:101:2: warning: #warning Processor architecture undefined!

This is the last remaining warning for arm64, and I'd like to get rid of
it. We don't really know the cache line size, architecturally it would
be at least 16 bytes, but all implementations I found have 64 or 128
bytes. Configuring tulip for 32-byte lines as we do on ARM32 seems to
be the safe but slow default, and nobody who cares about performance these
days would use a tulip chip anyway, so we can just use that.

To save the next person the job of trying to find out what this is for
and picking a default for their architecture just to kill off the warning,
I'm now removing the preprocessor #warning and turning it into a pr_warn
or dev_warn that prints the equivalent information when the driver gets
loaded.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>

diff --git a/drivers/net/ethernet/dec/tulip/tulip_core.c b/drivers/net/ethernet/dec/tulip/tulip_core.c
index ed41559bae77..b553409e04ad 100644
--- a/drivers/net/ethernet/dec/tulip/tulip_core.c
+++ b/drivers/net/ethernet/dec/tulip/tulip_core.c
@@ -98,8 +98,7 @@ static int csr0 = 0x01A00000 | 0x4800;
 #elif defined(__mips__)
 static int csr0 = 0x00200000 | 0x4000;
 #else
-#warning Processor architecture undefined!
-static int csr0 = 0x00A00000 | 0x4800;
+static int csr0;
 #endif
 
 /* Operational parameters that usually are not changed. */
@@ -1982,6 +1981,12 @@ static int __init tulip_init (void)
 	pr_info("%s", version);
 #endif
 
+	if (!csr0) {
+		pr_warn("tulip: unknown CPU architecture, using default csr0\n");
+		/* default to 8 longword cache line alignment */
+		csr0 = 0x00A00000 | 0x4800;
+	}
+
 	/* copy module parms into globals */
 	tulip_rx_copybreak = rx_copybreak;
 	tulip_max_interrupt_work = max_interrupt_work;
diff --git a/drivers/net/ethernet/dec/tulip/winbond-840.c b/drivers/net/ethernet/dec/tulip/winbond-840.c
index 9beb3d34d4ba..3c0e4d5c5fef 100644
--- a/drivers/net/ethernet/dec/tulip/winbond-840.c
+++ b/drivers/net/ethernet/dec/tulip/winbond-840.c
@@ -907,7 +907,7 @@ static void init_registers(struct net_device *dev)
 #elif defined(CONFIG_SPARC) || defined (CONFIG_PARISC) || defined(CONFIG_ARM)
 	i |= 0x4800;
 #else
-#warning Processor architecture undefined
+	dev_warn(&dev->dev, "unknown CPU architecture, using default csr0 setting\n");
 	i |= 0x4800;
 #endif
 	iowrite32(i, ioaddr + PCIBusCfg);
