From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: [PATCH] net/cycx_drv: replace delay_cycx() with ssleep_interruptible()
Date: Mon, 1 Nov 2004 11:48:33 -0800
Message-ID: <20041101194833.GA3391@us.ibm.com>
References: <E1CO1w4-0002YG-VR@sputnik> <4184C6A7.7060400@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kernel-janitors@lists.osdl.org, netdev@oss.sgi.com, acme@conectiva.com.br
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <4184C6A7.7060400@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Oct 31, 2004 at 06:04:07AM -0500, Jeff Garzik wrote:
> janitor@sternwelten.at wrote:
> >-/* Delay */
> >-static void delay_cycx(int sec)
> >-{
> >-	set_current_state(TASK_INTERRUPTIBLE);
> >-	schedule_timeout(sec * HZ);
> >-}
> 
> 
> this _clearly_ wants an ssleep() derivative, not msleep()

Fixed, see patch below.

Description: Use ssleep_interruptible() instead of delay_cycx()
to guarantee the task delays as expected. Remove the prototype and
definition of delay_cycx().

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>


--- 2.6.10-rc1-vanilla/drivers/net/wan/cycx_drv.c	2004-10-30 15:33:28.000000000 -0700
+++ 2.6.10-rc1/drivers/net/wan/cycx_drv.c	2004-11-01 11:46:08.000000000 -0800
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
+		ssleep_interruptible(1);
 	}
 
 	return 0;
@@ -316,7 +315,7 @@ static void cycx_reset_boot(void __iomem
 
 	/* 80186 was in hold, go */
 	writeb(0, addr + START_CPU);
-	delay_cycx(1);
+	ssleep_interruptible(1);
 }
 
 /* Load data.bin file through boot (reset) interface. */
@@ -462,13 +461,13 @@ static int load_cyc2x(struct cycx_hw *hw
 		cycx_reset_boot(hw->dpmbase, reset_image, img_hdr->reset_size);
 		/* reset is waiting for boot */
 		writew(GEN_POWER_ON, pt_cycld);
-		delay_cycx(1);
+		ssleep_interruptible(1);
 
 		for (j = 0 ; j < 3 ; j++)
 			if (!readw(pt_cycld))
 				goto reset_loaded;
 			else
-				delay_cycx(1);
+				ssleep_interruptible(1);
 	}
 
 	printk(KERN_ERR "%s: reset not started.\n", modname);
@@ -495,7 +494,7 @@ reset_loaded:
 
 	/* Arthur Ganzert's tip: wait a while after the firmware loading...
 	   seg abr 26 17:17:12 EST 1999 - acme */
-	delay_cycx(7);
+	ssleep_interruptible(7);
 	printk(KERN_INFO "%s: firmware loaded!\n", modname);
 
 	/* enable interrupts */
@@ -547,20 +546,13 @@ static int get_option_index(long *optlis
 static int reset_cyc2x(void __iomem *addr)
 {
 	writeb(0, addr + RST_ENABLE);
-	delay_cycx(2);
+	ssleep_interruptible(2);
 	writeb(0, addr + RST_DISABLE);
-	delay_cycx(2);
+	ssleep_interruptible(2);
 
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
