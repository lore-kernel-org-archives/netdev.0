From: Ondrej Zary <linux@rainbow-software.org>
Subject: [PATCH] de2104x: fix ethtool
Date: Mon, 27 Sep 2010 23:41:45 +0200
Message-ID: <201009272341.50668.linux@rainbow-software.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Kernel development list <linux-kernel@vger.kernel.org>
To: jgarzik@pobox.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When the interface is up, using ethtool breaks it because:
a) link is put down but media_timer interval is not shortened to NO_LINK
b) rxtx is stopped but not restarted

Also manual 10baseT-HD (and probably FD too - untested) mode does not work -
the link is forced up, packets are transmitted but nothing is received.
Changing CSR14 value to match documentation (not disabling link check) fixes this.

Signed-off-by: Ondrej Zary <linux@rainbow-software.org>

--- linux-2.6.36-rc3-/drivers/net/tulip/de2104x.c	2010-09-26 21:58:42.000000000 +0200
+++ linux-2.6.36-rc3/drivers/net/tulip/de2104x.c	2010-09-27 23:36:51.000000000 +0200
@@ -364,9 +364,9 @@ static u16 t21040_csr15[] = { 0, 0, 0x00
 
 /* 21041 transceiver register settings: TP AUTO, BNC, AUI, TP, TP FD*/
 static u16 t21041_csr13[] = { 0xEF01, 0xEF09, 0xEF09, 0xEF01, 0xEF09, };
-static u16 t21041_csr14[] = { 0xFFFF, 0xF7FD, 0xF7FD, 0x6F3F, 0x6F3D, };
+static u16 t21041_csr14[] = { 0xFFFF, 0xF7FD, 0xF7FD, 0x7F3F, 0x7F3D, };
 /* If on-chip autonegotiation is broken, use half-duplex (FF3F) instead */
-static u16 t21041_csr14_brk[] = { 0xFF3F, 0xF7FD, 0xF7FD, 0x6F3F, 0x6F3D, };
+static u16 t21041_csr14_brk[] = { 0xFF3F, 0xF7FD, 0xF7FD, 0x7F3F, 0x7F3D, };
 static u16 t21041_csr15[] = { 0x0008, 0x0006, 0x000E, 0x0008, 0x0008, };
 
 
@@ -1596,12 +1596,15 @@ static int __de_set_settings(struct de_p
 		return 0; /* nothing to change */
 
 	de_link_down(de);
+	mod_timer(&de->media_timer, jiffies + DE_TIMER_NO_LINK);
 	de_stop_rxtx(de);
 
 	de->media_type = new_media;
 	de->media_lock = media_lock;
 	de->media_advertise = ecmd->advertising;
 	de_set_media(de);
+	if (netif_running(de->dev))
+		de_start_rxtx(de);
 
 	return 0;
 }


-- 
Ondrej Zary
