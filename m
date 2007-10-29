From: "Luis R. Rodriguez" <mcgrof@gmail.com>
Subject: [PATCH] pegasos_eth.c: Fix compile error over MV643XX_ defines
Date: Mon, 29 Oct 2007 17:27:29 -0400
Message-ID: <20071029212729.GA4074@pogo>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Tzachi Perelstein <tzachi@marvell.com>,
	Dale Farnsworth <dale@farnsworth.org>
To: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.231]:43196 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752883AbXJ2V05 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Oct 2007 17:26:57 -0400
Received: by wx-out-0506.google.com with SMTP id h31so1889770wxd
        for <netdev@vger.kernel.org>; Mon, 29 Oct 2007 14:26:55 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This commit made an incorrect assumption:
--
Author: Lennert Buytenhek <buytenh@wantstofly.org>
 Date:   Fri Oct 19 04:10:10 2007 +0200

    mv643xx_eth: Move ethernet register definitions into private header
    
    Move the mv643xx's ethernet-related register definitions from
    include/linux/mv643xx.h into drivers/net/mv643xx_eth.h, since
    they aren't of any use outside the ethernet driver.
    
    Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
    Acked-by: Tzachi Perelstein <tzachi@marvell.com>
    Signed-off-by: Dale Farnsworth <dale@farnsworth.org>
--

arch/powerpc/platforms/chrp/pegasos_eth.c made use of a 3 defines there.

mcgrof@pogo:~/devel/wireless-2.6$ git-describe 

v2.6.24-rc1-138-g0119130

This patch fixes this by internalizing 3 defines onto pegasos which are
simply no longer available elsewhere. Without this your compile will fail
whenever you enable 'Common Hardware Reference Platform (CHRP) based machines',
(CONFIG_PPC_CHRP) as the Makefile for chrp adds it always:

obj-y                           += setup.o time.o pegasos_eth.o pci.o

If these defines are platform specific then they should later just be added 
back to include/linux/mv643xx.h.

Compile error:

  CC      arch/powerpc/platforms/chrp/pegasos_eth.o
arch/powerpc/platforms/chrp/pegasos_eth.c: In function 'Enable_SRAM':
arch/powerpc/platforms/chrp/pegasos_eth.c:150: error: 'MV643XX_ETH_BAR_4' 
undeclared (first use in this function)
arch/powerpc/platforms/chrp/pegasos_eth.c:150: error: (Each undeclared 
identifier is reported only once
arch/powerpc/platforms/chrp/pegasos_eth.c:150: error: for each function it 
appears in.)
arch/powerpc/platforms/chrp/pegasos_eth.c:152: error: 
'MV643XX_ETH_SIZE_REG_4' undeclared (first use in this function)
arch/powerpc/platforms/chrp/pegasos_eth.c:154: error: 
'MV643XX_ETH_BASE_ADDR_ENABLE_REG' undeclared (first use in this function)
make[2]: *** [arch/powerpc/platforms/chrp/pegasos_eth.o] Error 1
make[1]: *** [arch/powerpc/platforms/chrp] Error 2
make: *** [arch/powerpc/platforms] Error 2

Signed-off-by: Luis R. Rodriguez <mcgrof@gmail.com>
---

 arch/powerpc/platforms/chrp/pegasos_eth.c |   11 +++++++----
 1 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/arch/powerpc/platforms/chrp/pegasos_eth.c b/arch/powerpc/platforms/chrp/pegasos_eth.c
index 5bcc58d..1fc9e8c 100644
--- a/arch/powerpc/platforms/chrp/pegasos_eth.c
+++ b/arch/powerpc/platforms/chrp/pegasos_eth.c
@@ -24,6 +24,9 @@
 #define PEGASOS2_SRAM_BASE_ETH0			(PEGASOS2_SRAM_BASE)
 #define PEGASOS2_SRAM_BASE_ETH1			(PEGASOS2_SRAM_BASE_ETH0 + (PEGASOS2_SRAM_SIZE / 2) )
 
+#define PEGASOS2_ETH_BAR_4			0x2220
+#define PEGASOS2_ETH_SIZE_REG_4			0x2224
+#define PEGASOS2_ETH_BASE_ADDR_ENABLE_REG	0x2290
 
 #define PEGASOS2_SRAM_RXRING_SIZE		(PEGASOS2_SRAM_SIZE/4)
 #define PEGASOS2_SRAM_TXRING_SIZE		(PEGASOS2_SRAM_SIZE/4)
@@ -147,13 +150,13 @@ static int Enable_SRAM(void)
 
 	ALong = 0x02;
 	ALong |= PEGASOS2_SRAM_BASE & 0xffff0000;
-	MV_WRITE(MV643XX_ETH_BAR_4, ALong);
+	MV_WRITE(PEGASOS2_ETH_BAR_4, ALong);
 
-	MV_WRITE(MV643XX_ETH_SIZE_REG_4, (PEGASOS2_SRAM_SIZE-1) & 0xffff0000);
+	MV_WRITE(PEGASOS2_ETH_SIZE_REG_4, (PEGASOS2_SRAM_SIZE-1) & 0xffff0000);
 
-	MV_READ(MV643XX_ETH_BASE_ADDR_ENABLE_REG, ALong);
+	MV_READ(PEGASOS2_ETH_BASE_ADDR_ENABLE_REG, ALong);
 	ALong &= ~(1 << 4);
-	MV_WRITE(MV643XX_ETH_BASE_ADDR_ENABLE_REG, ALong);
+	MV_WRITE(PEGASOS2_ETH_BASE_ADDR_ENABLE_REG, ALong);
 
 #ifdef BE_VERBOSE
 	printk("Pegasos II/Marvell MV64361: register unmapped\n");
