From: Sergei Shtylyov <sshtylyov@ru.mvista.com>
Subject: [PATCH] Fix RTL8019AS init for Toshiba RBTX49xx boards
Date: Tue, 09 May 2006 00:58:28 +0400
Message-ID: <445FB0F4.4050103@ru.mvista.com>
References: <444291E9.2070407@ru.mvista.com>	<20060417.110945.59031594.nemoto@toshiba-tops.co.jp>	<444392CF.7070808@ru.mvista.com> <20060418.000918.95064811.anemo@mba.ocn.ne.jp> <4443BD39.4030200@ru.mvista.com> <4443BE71.6090908@ru.mvista.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070200070802050502020507"
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtsoft2.corbina.net ([85.21.88.2]:32214 "HELO
	mail.dev.rtsoft.ru") by vger.kernel.org with SMTP id S1750859AbWEHU7e
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 May 2006 16:59:34 -0400
To: shemminger@osdl.org
In-Reply-To: <4443BE71.6090908@ru.mvista.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070200070802050502020507
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

    Ensure that 8-bit mode is selected for the on-board Realtek RTL8019AS chip
on Toshiba RBHMA4x00, get rid of the duplicate #ifdef's when setting
ei_status.word16.
    The chip's datasheet says that the PSTOP register shouldn't exceed 0x60 in
8-bit mode -- ensure this too.

Signed-off-by: Sergei Shtylyov <sshtylyov@ru.mvista.com>


--------------070200070802050502020507
Content-Type: text/plain;
 name="RBTX49xx-RTL8019AS-init-fix.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="RBTX49xx-RTL8019AS-init-fix.patch"

Index: linus/drivers/net/ne.c
===================================================================
--- linus.orig/drivers/net/ne.c
+++ linus/drivers/net/ne.c
@@ -139,8 +139,9 @@ bad_clone_list[] __initdata = {
 
 #if defined(CONFIG_PLAT_MAPPI)
 #  define DCR_VAL 0x4b
-#elif defined(CONFIG_PLAT_OAKS32R)
-#  define DCR_VAL 0x48
+#elif defined(CONFIG_PLAT_OAKS32R)  || \
+   defined(CONFIG_TOSHIBA_RBTX4927) || defined(CONFIG_TOSHIBA_RBTX4938)
+#  define DCR_VAL 0x48		/* 8-bit mode */
 #else
 #  define DCR_VAL 0x49
 #endif
@@ -396,10 +397,22 @@ static int __init ne_probe1(struct net_d
 		/* We must set the 8390 for word mode. */
 		outb_p(DCR_VAL, ioaddr + EN0_DCFG);
 		start_page = NESM_START_PG;
-		stop_page = NESM_STOP_PG;
+
+		/*
+		 * Realtek RTL8019AS datasheet says that the PSTOP register
+		 * shouldn't exceed 0x60 in 8-bit mode.
+		 * This chip can be identified by reading the signature from
+		 * the  remote byte count registers (otherwise write-only)...
+		 */
+		if ((DCR_VAL & 0x01) == 0 &&		/* 8-bit mode */
+		    inb(ioaddr + EN0_RCNTLO) == 0x50 &&
+		    inb(ioaddr + EN0_RCNTHI) == 0x70)
+			stop_page = 0x60;
+		else
+			stop_page = NESM_STOP_PG;
 	} else {
 		start_page = NE1SM_START_PG;
-		stop_page = NE1SM_STOP_PG;
+		stop_page  = NE1SM_STOP_PG;
 	}
 
 #if  defined(CONFIG_PLAT_MAPPI) || defined(CONFIG_PLAT_OAKS32R)
@@ -509,15 +522,9 @@ static int __init ne_probe1(struct net_d
 	ei_status.name = name;
 	ei_status.tx_start_page = start_page;
 	ei_status.stop_page = stop_page;
-#if defined(CONFIG_TOSHIBA_RBTX4927) || defined(CONFIG_TOSHIBA_RBTX4938)
-	wordlength = 1;
-#endif
 
-#ifdef CONFIG_PLAT_OAKS32R
-	ei_status.word16 = 0;
-#else
-	ei_status.word16 = (wordlength == 2);
-#endif
+	/* Use 16-bit mode only if this wasn't overridden by DCR_VAL */
+	ei_status.word16 = (wordlength == 2 && (DCR_VAL & 0x01));
 
 	ei_status.rx_start_page = start_page + TX_PAGES;
 #ifdef PACKETBUF_MEMSIZE




--------------070200070802050502020507--
