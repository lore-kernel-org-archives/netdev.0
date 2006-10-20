From: akpm@osdl.org
Subject: [patch 2/8] 8139too: force media setting cleanup
Date: Fri, 20 Oct 2006 14:42:04 -0700
Message-ID: <200610202142.k9KLg5ne003715@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, leewkb@yahoo.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:17284 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S2992755AbWJTVmp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2006 17:42:45 -0400
To: jeff@garzik.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bernard Lee <leewkb@yahoo.com>

Setting bit 4 & 5 alone in 8139too module media option does not really
force 100Mbps full-duplex mode.  When media option bit 0-3 is cleared,
8139too module does not force media setting.  Therefore, bit 0-3 requires
to be set for bit 4 & 5 to take effect.  The hidden bit 0-3 setting is not
stated in module description.

It can be fixed by changing rtl8139_private structure default_port bitfield
from 4-bit to 6-bit.

Besides, module media bit 9 is a duplicate of bit 4 (full-duplex).  It is
suggested that bit 9 is freed.  A remark is added to module description
that bit 0 can be used to force setting.  It helps to clarify 10Mbps
half-duplex mode.

Signed-off-by: Bernard Lee <leewkb@yahoo.com>
Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/net/8139too.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff -puN drivers/net/8139too.c~8139too-force-media-setting-fix drivers/net/8139too.c
--- a/drivers/net/8139too.c~8139too-force-media-setting-fix
+++ a/drivers/net/8139too.c
@@ -586,7 +586,7 @@ struct rtl8139_private {
 	signed char phys[4];		/* MII device addresses. */
 	char twistie, twist_row, twist_col;	/* Twister tune state. */
 	unsigned int watchdog_fired : 1;
-	unsigned int default_port : 4;	/* Last dev->if_port value. */
+	unsigned int default_port : 6;	/* Last dev->if_port value. */
 	unsigned int have_thread : 1;
 	spinlock_t lock;
 	spinlock_t rx_lock;
@@ -612,7 +612,7 @@ module_param_array(full_duplex, int, NUL
 module_param(debug, int, 0);
 MODULE_PARM_DESC (debug, "8139too bitmapped message enable number");
 MODULE_PARM_DESC (multicast_filter_limit, "8139too maximum number of filtered multicast addresses");
-MODULE_PARM_DESC (media, "8139too: Bits 4+9: force full duplex, bit 5: 100Mbps");
+MODULE_PARM_DESC (media, "8139too: bit 0: force setting, bit 4: full duplex, bit 5: 100Mbps");
 MODULE_PARM_DESC (full_duplex, "8139too: Force full duplex for board(s) (1)");
 
 static int read_eeprom (void __iomem *ioaddr, int location, int addr_len);
@@ -1068,8 +1068,8 @@ static int __devinit rtl8139_init_one (s
 	/* The lower four bits are the media type. */
 	option = (board_idx >= MAX_UNITS) ? 0 : media[board_idx];
 	if (option > 0) {
-		tp->mii.full_duplex = (option & 0x210) ? 1 : 0;
-		tp->default_port = option & 0xFF;
+		tp->mii.full_duplex = (option & 0x10) ? 1 : 0;
+		tp->default_port = option & 0x3F;
 		if (tp->default_port)
 			tp->mii.force_media = 1;
 	}
_
