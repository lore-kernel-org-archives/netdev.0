From: domen@coderock.org
Subject: [patch 06/19] net/xirc2ps_cs: replace Wait() with msleep()
Date: Wed, 12 Jan 2005 00:10:24 +0100
Message-ID: <20050111231024.CEF821F228@trashy.coderock.org>
Cc: netdev@oss.sgi.com, domen@coderock.org, nacc@us.ibm.com,
        janitor@sternwelten.at
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org




Any comments would be appreciated.

Description: Use msleep() instead of Wait() to guarantee the task delays
as expected. Remove definition of Wait().

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
Signed-off-by: Maximilian Attems <janitor@sternwelten.at>
Signed-off-by: Domen Puncer <domen@coderock.org>
---


 kj-domen/drivers/net/pcmcia/xirc2ps_cs.c |   23 +++++++++--------------
 1 files changed, 9 insertions(+), 14 deletions(-)

diff -puN drivers/net/pcmcia/xirc2ps_cs.c~msleep-drivers_net_irda_pcmcia_xirc2ps_cs drivers/net/pcmcia/xirc2ps_cs.c
--- kj/drivers/net/pcmcia/xirc2ps_cs.c~msleep-drivers_net_irda_pcmcia_xirc2ps_cs	2005-01-10 18:00:00.000000000 +0100
+++ kj-domen/drivers/net/pcmcia/xirc2ps_cs.c	2005-01-10 18:00:00.000000000 +0100
@@ -418,11 +418,6 @@ next_tuple(client_handle_t handle, tuple
 #define PutByte(reg,value) outb((value), ioaddr+(reg))
 #define PutWord(reg,value) outw((value), ioaddr+(reg))
 
-#define Wait(n) do { \
-	set_current_state(TASK_UNINTERRUPTIBLE); \
-	schedule_timeout(n); \
-} while (0)
-
 /*====== Functions used for debugging =================================*/
 #if defined(PCMCIA_DEBUG) && 0 /* reading regs may change system status */
 static void
@@ -1716,12 +1711,12 @@ hardreset(struct net_device *dev)
     SelectPage(4);
     udelay(1);
     PutByte(XIRCREG4_GPR1, 0);	     /* clear bit 0: power down */
-    Wait(HZ/25);		     /* wait 40 msec */
+    msleep(40);				     /* wait 40 msec */
     if (local->mohawk)
 	PutByte(XIRCREG4_GPR1, 1);	 /* set bit 0: power up */
     else
 	PutByte(XIRCREG4_GPR1, 1 | 4);	 /* set bit 0: power up, bit 2: AIC */
-    Wait(HZ/50);		     /* wait 20 msec */
+    msleep(20);			     /* wait 20 msec */
 }
 
 static void
@@ -1735,9 +1730,9 @@ do_reset(struct net_device *dev, int ful
 
     hardreset(dev);
     PutByte(XIRCREG_CR, SoftReset); /* set */
-    Wait(HZ/50);		     /* wait 20 msec */
+    msleep(20);			     /* wait 20 msec */
     PutByte(XIRCREG_CR, 0);	     /* clear */
-    Wait(HZ/25);		     /* wait 40 msec */
+    msleep(40);			     /* wait 40 msec */
     if (local->mohawk) {
 	SelectPage(4);
 	/* set pin GP1 and GP2 to output  (0x0c)
@@ -1748,7 +1743,7 @@ do_reset(struct net_device *dev, int ful
     }
 
     /* give the circuits some time to power up */
-    Wait(HZ/2);		/* about 500ms */
+    msleep(500);			/* about 500ms */
 
     local->last_ptr_value = 0;
     local->silicon = local->mohawk ? (GetByte(XIRCREG4_BOV) & 0x70) >> 4
@@ -1767,7 +1762,7 @@ do_reset(struct net_device *dev, int ful
 	SelectPage(0x42);
 	PutByte(XIRCREG42_SWC1, 0x80);
     }
-    Wait(HZ/25);		     /* wait 40 msec to let it complete */
+    msleep(40);			     /* wait 40 msec to let it complete */
 
   #ifdef PCMCIA_DEBUG
     if (pc_debug) {
@@ -1826,7 +1821,7 @@ do_reset(struct net_device *dev, int ful
 	    printk(KERN_INFO "%s: MII selected\n", dev->name);
 	    SelectPage(2);
 	    PutByte(XIRCREG2_MSR, GetByte(XIRCREG2_MSR) | 0x08);
-	    Wait(HZ/50);
+	    msleep(20);
 	} else {
 	    printk(KERN_INFO "%s: MII detected; using 10mbs\n",
 		   dev->name);
@@ -1835,7 +1830,7 @@ do_reset(struct net_device *dev, int ful
 		PutByte(XIRCREG42_SWC1, 0xC0);
 	    else  /* enable 10BaseT */
 		PutByte(XIRCREG42_SWC1, 0x80);
-	    Wait(HZ/25);	/* wait 40 msec to let it complete */
+	    msleep(40);			/* wait 40 msec to let it complete */
 	}
 	if (full_duplex)
 	    PutByte(XIRCREG1_ECR, GetByte(XIRCREG1_ECR | FullDuplex));
@@ -1928,7 +1923,7 @@ init_mii(struct net_device *dev)
 	 * Fixme: Better to use a timer here!
 	 */
 	for (i=0; i < 35; i++) {
-	    Wait(HZ/10);	 /* wait 100 msec */
+	    msleep(100);	 /* wait 100 msec */
 	    status = mii_rd(ioaddr,  0, 1);
 	    if ((status & 0x0020) && (status & 0x0004))
 		break;
_
