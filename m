From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH] net/sun3_82586: Kill array subscript above array bounds warning
Date: Wed, 17 Jul 2013 14:25:05 +0200
Message-ID: <1374063905-4050-1-git-send-email-geert@linux-m68k.org>
Cc: netdev@vger.kernel.org, linux-m68k@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Geert Uytterhoeven <geert@linux-m68k.org>
To: "David S. Miller" <davem@davemloft.net>,
	Sam Creasey <sammy@sammy.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

drivers/net/ethernet/i825xx/sun3_82586.c: In function 'sun3_82586_timeout':
drivers/net/ethernet/i825xx/sun3_82586.c:993:89: warning: array subscript is above array bounds [-Warray-bounds]

Using the default NUM_XMIT_BUFFS = 1, there's only one transmit buffer.
Hence accessing the second buffer is an out-of-bounds access.
Print the command status of the first NOP buffer instead.

Fortunately this actually worked fine, as the layout of transmit and NOP
buffers is sufficiently similar.

Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
  - Untested due to lack of hardware
  - Note that the driver never compiled with the non-default NUM_XMIT_BUFFS > 1

 drivers/net/ethernet/i825xx/sun3_82586.c |    9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/i825xx/sun3_82586.c b/drivers/net/ethernet/i825xx/sun3_82586.c
index 353f57f6..d283d2e 100644
--- a/drivers/net/ethernet/i825xx/sun3_82586.c
+++ b/drivers/net/ethernet/i825xx/sun3_82586.c
@@ -990,7 +990,14 @@ static void sun3_82586_timeout(struct net_device *dev)
 	{
 #ifdef DEBUG
 		printk("%s: xmitter timed out, try to restart! stat: %02x\n",dev->name,p->scb->cus);
-		printk("%s: command-stats: %04x %04x\n",dev->name,swab16(p->xmit_cmds[0]->cmd_status),swab16(p->xmit_cmds[1]->cmd_status));
+		printk("%s: command-stats: %04x %04x\n", dev->name,
+		       swab16(p->xmit_cmds[0]->cmd_status),
+#if (NUM_XMIT_BUFFS > 1)
+		       swab16(p->xmit_cmds[1]->cmd_status)
+#else
+		       swab16(p->nop_cmds[0]->cmd_status)
+#endif
+		);
 		printk("%s: check, whether you set the right interrupt number!\n",dev->name);
 #endif
 		sun3_82586_close(dev);
-- 
1.7.9.5
