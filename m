From: janitor@sternwelten.at
Subject: [patch 13/18]  net/cycx_drv: replace 	delay_cycx() with msleep_interruptible()
Date: Sun, 31 Oct 2004 00:43:00 +0200
Message-ID: <E1CO1w4-0002YG-VR@sputnik>
Cc: netdev@oss.sgi.com, janitor@sternwelten.at, nacc@us.ibm.com,
        acme@conectiva.com.br
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org




Any comments would be appreciated.

Description: Use msleep_interruptible() instead of delay_cycx()
to guarantee the task delays as expected. Remove the prototype and
definition of delay_cycx().

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
Acked-by: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Signed-off-by: Maximilian Attems <janitor@sternwelten.at>

---

 linux-2.6.10-rc1-max/drivers/net/wan/cycx_drv.c |   24 ++++++++----------------
 1 files changed, 8 insertions(+), 16 deletions(-)

diff -puN drivers/net/wan/cycx_drv.c~msleep_interruptible-drivers_net_wan_cycx_drv drivers/net/wan/cycx_drv.c
--- linux-2.6.10-rc1/drivers/net/wan/cycx_drv.c~msleep_interruptible-drivers_net_wan_cycx_drv	2004-10-24 17:05:17.000000000 +0200
+++ linux-2.6.10-rc1-max/drivers/net/wan/cycx_drv.c	2004-10-24 17:05:17.000000000 +0200
@@ -56,7 +56,7 @@
 #include <linux/sched.h>	/* for jiffies, HZ, etc. */
 #include <linux/cycx_drv.h>	/* API definitions */
 #include <linux/cycx_cfm.h>	/* CYCX firmware module definitions */
-#include <linux/delay.h>	/* udelay */
+#include <linux/delay.h>	/* udelay, msleep */
 #include <asm/io.h>		/* read[wl], write[wl], ioremap, iounmap */
 
 #define	MOD_VERSION	0
@@ -74,7 +74,6 @@ static int reset_cyc2x(void __iomem *add
 static int detect_cyc2x(void __iomem *addr);
 
 /* Miscellaneous functions */
-static void delay_cycx(int sec);
 static int get_option_index(long *optlist, long optval);
 static u16 checksum(u8 *buf, u32 len);
 
@@ -259,7 +258,7 @@ static int memory_exists(void __iomem *a
 			if (readw(addr + 0x10) == TEST_PATTERN)
 				return 1;
 
-		delay_cycx(1);
+		msleep_interruptible(1000);
 	}
 
 	return 0;
@@ -316,7 +315,7 @@ static void cycx_reset_boot(void __iomem
 
 	/* 80186 was in hold, go */
 	writeb(0, addr + START_CPU);
-	delay_cycx(1);
+	msleep_interruptible(1000);
 }
 
 /* Load data.bin file through boot (reset) interface. */
@@ -462,13 +461,13 @@ static int load_cyc2x(struct cycx_hw *hw
 		cycx_reset_boot(hw->dpmbase, reset_image, img_hdr->reset_size);
 		/* reset is waiting for boot */
 		writew(GEN_POWER_ON, pt_cycld);
-		delay_cycx(1);
+		msleep_interruptible(1000);
 
 		for (j = 0 ; j < 3 ; j++)
 			if (!readw(pt_cycld))
 				goto reset_loaded;
 			else
-				delay_cycx(1);
+				msleep_interruptible(1000);
 	}
 
 	printk(KERN_ERR "%s: reset not started.\n", modname);
@@ -495,7 +494,7 @@ reset_loaded:
 
 	/* Arthur Ganzert's tip: wait a while after the firmware loading...
 	   seg abr 26 17:17:12 EST 1999 - acme */
-	delay_cycx(7);
+	msleep_interruptible(7000);
 	printk(KERN_INFO "%s: firmware loaded!\n", modname);
 
 	/* enable interrupts */
@@ -547,20 +546,13 @@ static int get_option_index(long *optlis
 static int reset_cyc2x(void __iomem *addr)
 {
 	writeb(0, addr + RST_ENABLE);
-	delay_cycx(2);
+	msleep_interruptible(2000);
 	writeb(0, addr + RST_DISABLE);
-	delay_cycx(2);
+	msleep_interruptible(2000);
 
 	return memory_exists(addr);
 }
 
-/* Delay */
-static void delay_cycx(int sec)
-{
-	set_current_state(TASK_INTERRUPTIBLE);
-	schedule_timeout(sec * HZ);
-}
-
 /* Calculate 16-bit CRC using CCITT polynomial. */
 static u16 checksum(u8 *buf, u32 len)
 {
_
