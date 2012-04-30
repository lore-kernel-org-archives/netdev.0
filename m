From: Jaccon Bastiaansen <jaccon.bastiaansen@gmail.com>
Subject: [PATCH 2/2] cs89x0_platform : avoid requesting the i/o memory range twice
Date: Mon, 30 Apr 2012 11:58:09 +0200
Message-ID: <1335779889-30454-1-git-send-email-jaccon.bastiaansen@gmail.com>
Cc: festevam@gmail.com, linux-arm-kernel@lists.infradead.org,
	kernel@pengutronix.de, netdev@vger.kernel.org,
	Jaccon Bastiaansen <jaccon.bastiaansen@gmail.com>
To: s.hauer@pengutronix.de, gfm@funxed.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:53474 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752297Ab2D3J6Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Apr 2012 05:58:16 -0400
Received: by mail-ey0-f174.google.com with SMTP id q12so631024eaa.19
        for <netdev@vger.kernel.org>; Mon, 30 Apr 2012 02:58:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the platform driver option of the cs89x0 driver is used, the i/o
memory range is requested twice, resulting in a failed driver
initialization.

Signed-off-by: Jaccon Bastiaansen <jaccon.bastiaansen@gmail.com>
---
 drivers/net/ethernet/cirrus/cs89x0.c |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/cirrus/cs89x0.c b/drivers/net/ethernet/cirrus/cs89x0.c
index 95737e9..f88a237 100644
--- a/drivers/net/ethernet/cirrus/cs89x0.c
+++ b/drivers/net/ethernet/cirrus/cs89x0.c
@@ -544,14 +544,15 @@ cs89x0_probe1(struct net_device *dev, unsigned long ioaddr, int modular)
 
         }
 
+#ifndef CONFIG_CS89x0_PLATFORM
 	/* Grab the region so we can find another board if autoIRQ fails. */
 	/* WTF is going on here? */
 	if (!request_region(ioaddr & ~3, NETCARD_IO_EXTENT, DRV_NAME)) {
 		printk(KERN_ERR "%s: request_region(0x%lx, 0x%x) failed\n",
 				DRV_NAME, ioaddr, NETCARD_IO_EXTENT);
-		retval = -EBUSY;
-		goto out1;
+		return -EBUSY;
 	}
+#endif
 
 	/* if they give us an odd I/O address, then do ONE write to
            the address port, to get it back to address zero, where we
@@ -565,7 +566,7 @@ cs89x0_probe1(struct net_device *dev, unsigned long ioaddr, int modular)
 				printk(KERN_ERR "%s: bad signature 0x%x\n",
 					dev->name, readword(ioaddr & ~3, ADD_PORT));
 		        	retval = -ENODEV;
-				goto out2;
+				goto out1;
 			}
 	}
 
@@ -580,7 +581,7 @@ cs89x0_probe1(struct net_device *dev, unsigned long ioaddr, int modular)
 			CHIP_EISA_ID_SIG_STR "\n",
 			dev->name, ioaddr, DATA_PORT, tmp);
   		retval = -ENODEV;
-  		goto out2;
+		goto out1;
 	}
 
 	/* Fill in the 'dev' fields. */
@@ -799,13 +800,12 @@ cs89x0_probe1(struct net_device *dev, unsigned long ioaddr, int modular)
 
 	retval = register_netdev(dev);
 	if (retval)
-		goto out3;
+		goto out2;
 	return 0;
-out3:
-	writeword(dev->base_addr, ADD_PORT, PP_ChipID);
 out2:
-	release_region(ioaddr & ~3, NETCARD_IO_EXTENT);
+	writeword(dev->base_addr, ADD_PORT, PP_ChipID);
 out1:
+	release_region(ioaddr & ~3, NETCARD_IO_EXTENT);
 	return retval;
 }
 
-- 
1.7.1
