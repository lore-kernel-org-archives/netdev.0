From: Angelo Dureghello <angelo70@gmail.com>
Subject: dm9000: adding support for coldfire
Date: Thu, 30 Dec 2010 23:28:59 +0100
Message-ID: <4D1D07AB.70809@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:39510 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750744Ab0L3W3I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Dec 2010 17:29:08 -0500
Received: by fxm20 with SMTP id 20so11528759fxm.19
        for <netdev@vger.kernel.org>; Thu, 30 Dec 2010 14:29:06 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

i have succesfully working dm9000e with MCF5307 with kernel 2.6.36.2.
If the data bus of the cpu (big endian) is cross-wired to the dm9000, no 
addition to actual 1.31 driver should be needed (untested, see patch 
comments).

In my case, i wired D0:31 of cpu directly straight to D0:31 of dm9000e.
In case this wiring configuration would be supported, i post this patch.
If this "straight-wiring" will not be considered a supported/standard 
way of connectiong to dm9000e, i can cross wire the bus on my board.

Regards,
angelo


*** dm9000.c.orig    2010-12-30 23:19:39.747836070 +0100
--- dm9000.c    2010-12-30 22:50:17.167899041 +0100
***************
*** 48,53 ****
--- 48,74 ----
   #define CARDNAME    "dm9000"
   #define DRV_VERSION    "1.31"

+ #ifdef CONFIG_COLDFIRE
+ /**
+  * Coldfire processors are big endian, so to use this driver
+  * without any change wiring should be done crossing the bytes:
+  *
+  * 8  bit mode, D24:31 cpu to D0:7   dm9000
+  * 16 bit mode, D24:31 cpu to D0:7   dm9000
+  *              D16:23 cpu to D8:15  dm9000
+  * 32 bit mode, D24:31 cpu to D0:7   dm9000
+  *              D16:23 cpu to D8:15  dm9000
+  *              D8 :15 cpu to D16:23 dm9000
+  *              D0 :7  cpu to D24:31 dm9000
+  *
+  * If the Coldfire bus has been wired straight to dm9000,
+  * following define/patch must be used.
+  *
+  * 32 bit mode, D0:31  straight wired : BE2LE32BIT
+  */
+ #define BE2LE32BIT     1
+ #endif
+
   /*
    * Transmit timeout, default 5 seconds.
    */
***************
*** 158,166 ****
--- 179,195 ----
       dev_dbg(db->dev, "resetting device\n");

       /* RESET device */
+ #ifdef BE2LE32BIT
+     writel(DM9000_NCR, db->io_addr);
+ #else
       writeb(DM9000_NCR, db->io_addr);
+ #endif
       udelay(200);
+ #ifdef BE2LE32BIT
+     writel(NCR_RST, db->io_data);
+ #else
       writeb(NCR_RST, db->io_data);
+ #endif
       udelay(200);
   }

***************
*** 170,177 ****
--- 199,211 ----
   static u8
   ior(board_info_t * db, int reg)
   {
+ #ifdef BE2LE32BIT
+     writel(reg, db->io_addr);
+     return (u8)readl(db->io_data);
+ #else
       writeb(reg, db->io_addr);
       return readb(db->io_data);
+ #endif
   }

   /*
***************
*** 181,223 ****
--- 215,310 ----
   static void
   iow(board_info_t * db, int reg, int value)
   {
+ #ifdef BE2LE32BIT
+     writel(reg, db->io_addr);
+     writel(value, db->io_data);
+ #else
       writeb(reg, db->io_addr);
       writeb(value, db->io_data);
+ #endif
   }

   /* routines for sending block to chip */

   static void dm9000_outblk_8bit(void __iomem *reg, void *data, int count)
   {
+ #ifdef CONFIG_COLDFIRE
+     u8 *p=(u8 *)data;
+
+     while (count--)
+ #ifdef BE2LE32BIT
+         writel((int)(*p++), reg);
+ #else
+         writeb(*p++, reg);
+ #endif
+ #else
       writesb(reg, data, count);
+ #endif
   }

   static void dm9000_outblk_16bit(void __iomem *reg, void *data, int count)
   {
+ #ifdef CONFIG_COLDFIRE
+     // TO DO
+ #else
       writesw(reg, data, (count+1) >> 1);
+ #endif
   }

   static void dm9000_outblk_32bit(void __iomem *reg, void *data, int count)
   {
+ #ifdef CONFIG_COLDFIRE
+     u32 *p = (u32*)data;
+
+     count = (count+3)>>2;
+
+     while (count--)
+         writel(le32_to_cpu(*p++), reg);
+ #else
       writesl(reg, data, (count+3) >> 2);
+ #endif
   }

   /* input block from chip to memory */

   static void dm9000_inblk_8bit(void __iomem *reg, void *data, int count)
   {
+ #ifdef CONFIG_COLDFIRE
+     u8 *p=data;
+
+     while (count--)
+         *p++ = readb(reg);
+ #else
       readsb(reg, data, count);
+ #endif
   }


   static void dm9000_inblk_16bit(void __iomem *reg, void *data, int count)
   {
+ #ifdef CONFIG_COLDFIRE
+ #ifdef BE2LE32BIT
+     /* to do */
+ #else
+     /* to do */
+ #endif
+ #else
       readsw(reg, data, (count+1) >> 1);
+ #endif
   }

   static void dm9000_inblk_32bit(void __iomem *reg, void *data, int count)
   {
+ #ifdef CONFIG_COLDFIRE
+     unsigned long *p=data;
+
+     count = (count + 3) >> 2;
+
+     while (count--)
+         *p++ = le32_to_cpu(readl(reg));
+ #else
       readsl(reg, data, (count+3) >> 2);
+ #endif
   }

   /* dump block from chip to null */
***************
*** 228,234 ****
--- 315,325 ----
       int tmp;

       for (i = 0; i < count; i++)
+ #ifdef BE2LE32BIT
+         tmp = readl(reg);
+ #else
           tmp = readb(reg);
+ #endif
   }

   static void dm9000_dumpblk_16bit(void __iomem *reg, int count)
***************
*** 239,245 ****
--- 330,341 ----
       count = (count + 1) >> 1;

       for (i = 0; i < count; i++)
+ #ifdef BE2LE32BIT
+         tmp = readl(reg);
+ #else
           tmp = readw(reg);
+ #endif
+
   }

   static void dm9000_dumpblk_32bit(void __iomem *reg, int count)
***************
*** 863,870 ****
       netif_wake_queue(dev);

       /* Restore previous register address */
       writeb(reg_save, db->io_addr);
!     spin_unlock_irqrestore(&db->lock, flags);
   }

   static void dm9000_send_packet(struct net_device *dev,
--- 959,971 ----
       netif_wake_queue(dev);

       /* Restore previous register address */
+ #ifdef BE2LE32BIT
+     writel(reg_save, db->io_addr);
+ #else
       writeb(reg_save, db->io_addr);
! #endif
!
!     spin_unlock_irqrestore(&db->lock,flags);
   }

   static void dm9000_send_packet(struct net_device *dev,
***************
*** 908,914 ****
--- 1009,1019 ----
       spin_lock_irqsave(&db->lock, flags);

       /* Move data to DM9000 TX RAM */
+ #ifdef BE2LE32BIT
+    writel(DM9000_MWCMD, db->io_addr);
+ #else
       writeb(DM9000_MWCMD, db->io_addr);
+ #endif

       (db->outblk)(db->io_data, skb->data, skb->len);
       dev->stats.tx_bytes += skb->len;
***************
*** 981,987 ****
           ior(db, DM9000_MRCMDX);    /* Dummy read */

           /* Get most updated data */
!         rxbyte = readb(db->io_data);

           /* Status check: this byte must be 0 or 1 */
           if (rxbyte & DM9000_PKT_ERR) {
--- 1086,1096 ----
           ior(db, DM9000_MRCMDX);    /* Dummy read */

           /* Get most updated data */
! #ifdef BE2LE32BIT
!       rxbyte = (u8)readl(db->io_data);
! #else
!       rxbyte = readb(db->io_data);
! #endif

           /* Status check: this byte must be 0 or 1 */
           if (rxbyte & DM9000_PKT_ERR) {
***************
*** 996,1003 ****

           /* A packet ready now & Get status/length */
           GoodPacket = true;
-         writeb(DM9000_MRCMD, db->io_addr);

           (db->inblk)(db->io_data, &rxhdr, sizeof(rxhdr));

           RxLen = le16_to_cpu(rxhdr.RxLen);
--- 1105,1117 ----

           /* A packet ready now & Get status/length */
           GoodPacket = true;

+ #ifdef BE2LE32BIT
+         writel(DM9000_MRCMD, db->io_addr);
+ #else
+       writeb(DM9000_MRCMD, db->io_addr);
+ #endif
+
           (db->inblk)(db->io_data, &rxhdr, sizeof(rxhdr));

           RxLen = le16_to_cpu(rxhdr.RxLen);
***************
*** 1077,1083 ****
       unsigned long flags;
       u8 reg_save;

!     dm9000_dbg(db, 3, "entering %s\n", __func__);

       /* A real interrupt coming */

--- 1191,1197 ----
       unsigned long flags;
       u8 reg_save;

!     //dm9000_dbg(db, 3, "entering %s\n", __func__);

       /* A real interrupt coming */

***************
*** 1085,1091 ****
       spin_lock_irqsave(&db->lock, flags);

       /* Save previous register address */
!     reg_save = readb(db->io_addr);

       /* Disable all interrupts */
       iow(db, DM9000_IMR, IMR_PAR);
--- 1199,1209 ----
       spin_lock_irqsave(&db->lock, flags);

       /* Save previous register address */
! #ifdef BE2LE32BIT
!    reg_save = (u8)readl(db->io_addr);
! #else
!    reg_save = readb(db->io_addr);
! #endif

       /* Disable all interrupts */
       iow(db, DM9000_IMR, IMR_PAR);
***************
*** 1100,1106 ****
       /* Received the coming packet */
       if (int_status & ISR_PRS)
           dm9000_rx(dev);
!
       /* Trnasmit Interrupt check */
       if (int_status & ISR_PTS)
           dm9000_tx_done(dev, db);
--- 1218,1224 ----
       /* Received the coming packet */
       if (int_status & ISR_PRS)
           dm9000_rx(dev);
!
       /* Trnasmit Interrupt check */
       if (int_status & ISR_PTS)
           dm9000_tx_done(dev, db);
***************
*** 1116,1123 ****
       iow(db, DM9000_IMR, db->imr_all);

       /* Restore previous register address */
       writeb(reg_save, db->io_addr);
!
       spin_unlock_irqrestore(&db->lock, flags);

       return IRQ_HANDLED;
--- 1234,1245 ----
       iow(db, DM9000_IMR, db->imr_all);

       /* Restore previous register address */
+ #ifdef BE2LE32BIT
+     writel(reg_save, db->io_addr);
+ #else
       writeb(reg_save, db->io_addr);
! #endif
!
       spin_unlock_irqrestore(&db->lock, flags);

       return IRQ_HANDLED;
***************
*** 1233,1243 ****
       int ret;

       mutex_lock(&db->addr_lock);
!
       spin_lock_irqsave(&db->lock,flags);

       /* Save previous register address */
!     reg_save = readb(db->io_addr);

       /* Fill the phyxcer register into REG_0C */
       iow(db, DM9000_EPAR, DM9000_PHY | reg);
--- 1355,1369 ----
       int ret;

       mutex_lock(&db->addr_lock);
!
       spin_lock_irqsave(&db->lock,flags);

       /* Save previous register address */
! #ifdef BE2LE32BIT
!    reg_save = (u8)readl(db->io_addr);
! #else
!    reg_save = readb(db->io_addr);
! #endif

       /* Fill the phyxcer register into REG_0C */
       iow(db, DM9000_EPAR, DM9000_PHY | reg);
***************
*** 1250,1256 ****
       dm9000_msleep(db, 1);        /* Wait read complete */

       spin_lock_irqsave(&db->lock,flags);
!     reg_save = readb(db->io_addr);

       iow(db, DM9000_EPCR, 0x0);    /* Clear phyxcer read command */

--- 1376,1386 ----
       dm9000_msleep(db, 1);        /* Wait read complete */

       spin_lock_irqsave(&db->lock,flags);
! #ifdef BE2LE32BIT
!    reg_save = (u8)readl(db->io_addr);
! #else
!    reg_save = readb(db->io_addr);
! #endif

       iow(db, DM9000_EPCR, 0x0);    /* Clear phyxcer read command */

***************
*** 1258,1266 ****
       ret = (ior(db, DM9000_EPDRH) << 8) | ior(db, DM9000_EPDRL);

       /* restore the previous address */
       writeb(reg_save, db->io_addr);
!     spin_unlock_irqrestore(&db->lock,flags);

       mutex_unlock(&db->addr_lock);

       dm9000_dbg(db, 5, "phy_read[%02x] -> %04x\n", reg, ret);
--- 1388,1401 ----
       ret = (ior(db, DM9000_EPDRH) << 8) | ior(db, DM9000_EPDRL);

       /* restore the previous address */
+ #ifdef BE2LE32BIT
+     writel(reg_save, db->io_addr);
+ #else
       writeb(reg_save, db->io_addr);
! #endif

+     spin_unlock_irqrestore(&db->lock,flags);
+
       mutex_unlock(&db->addr_lock);

       dm9000_dbg(db, 5, "phy_read[%02x] -> %04x\n", reg, ret);
***************
*** 1284,1290 ****
       spin_lock_irqsave(&db->lock,flags);

       /* Save previous register address */
!     reg_save = readb(db->io_addr);

       /* Fill the phyxcer register into REG_0C */
       iow(db, DM9000_EPAR, DM9000_PHY | reg);
--- 1419,1429 ----
       spin_lock_irqsave(&db->lock,flags);

       /* Save previous register address */
! #ifdef BE2LE32BIT
!    reg_save = (u8)readl(db->io_addr);
! #else
!    reg_save = readb(db->io_addr);
! #endif

       /* Fill the phyxcer register into REG_0C */
       iow(db, DM9000_EPAR, DM9000_PHY | reg);
***************
*** 1295,1312 ****

       iow(db, DM9000_EPCR, EPCR_EPOS | EPCR_ERPRW);    /* Issue phyxcer 
write command */

       writeb(reg_save, db->io_addr);
       spin_unlock_irqrestore(&db->lock, flags);

       dm9000_msleep(db, 1);        /* Wait write complete */

       spin_lock_irqsave(&db->lock,flags);
!     reg_save = readb(db->io_addr);

       iow(db, DM9000_EPCR, 0x0);    /* Clear phyxcer write command */

       /* restore the previous address */
       writeb(reg_save, db->io_addr);

       spin_unlock_irqrestore(&db->lock, flags);
       mutex_unlock(&db->addr_lock);
--- 1434,1464 ----

       iow(db, DM9000_EPCR, EPCR_EPOS | EPCR_ERPRW);    /* Issue phyxcer 
write command */

+ #ifdef BE2LE32BIT
+     writel(reg_save, db->io_addr);
+ #else
       writeb(reg_save, db->io_addr);
+ #endif
+
       spin_unlock_irqrestore(&db->lock, flags);

       dm9000_msleep(db, 1);        /* Wait write complete */

       spin_lock_irqsave(&db->lock,flags);
! #ifdef BE2LE32BIT
!    reg_save = (u8)readl(db->io_addr);
! #else
!    reg_save = readb(db->io_addr);
! #endif

       iow(db, DM9000_EPCR, 0x0);    /* Clear phyxcer write command */

       /* restore the previous address */
+ #ifdef BE2LE32BIT
+     writel(reg_save, db->io_addr);
+ #else
       writeb(reg_save, db->io_addr);
+ #endif

       spin_unlock_irqrestore(&db->lock, flags);
       mutex_unlock(&db->addr_lock);

