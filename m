From: Guenter Roeck <linux@roeck-us.net>
Subject: [PATCH v2 2/8] ide: Drop H8/300 driver
Date: Fri, 30 Aug 2013 16:51:28 -0700
Message-ID: <1377906694-9578-3-git-send-email-linux@roeck-us.net>
References: <1377906694-9578-1-git-send-email-linux@roeck-us.net>
Cc: linux-ide@vger.kernel.org, netdev@vger.kernel.org,
	linux-watchdog@vger.kernel.org, Wim Van Sebroeck <wim@iguana.be>,
	"David S. Miller" <davem@davemloft.net>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Eric Paris <eparis@redhat.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Jiang Liu <jiang.liu@huawei.com>,
	David Howells <dhowells@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Guenter Roeck <linux@roeck-us.net>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1377906694-9578-1-git-send-email-linux@roeck-us.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Architecture is gone, so there is no need to keep its ide driver around.

Cc: Yoshinori Sato <ysato@users.sourceforge.jp>
Acked-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Acked-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
 drivers/ide/Kconfig     |    7 ---
 drivers/ide/Makefile    |    2 -
 drivers/ide/ide-h8300.c |  109 -----------------------------------------------
 3 files changed, 118 deletions(-)
 delete mode 100644 drivers/ide/ide-h8300.c

diff --git a/drivers/ide/Kconfig b/drivers/ide/Kconfig
index 02906ca..5dba90a 100644
--- a/drivers/ide/Kconfig
+++ b/drivers/ide/Kconfig
@@ -722,13 +722,6 @@ config BLK_DEV_IDE_RAPIDE
 	  Say Y here if you want to support the Yellowstone RapIDE controller
 	  manufactured for use with Acorn computers.
 
-config IDE_H8300
-	tristate "H8300 IDE support"
-	depends on H8300
-	default y
-	help
-	  Enables the H8300 IDE driver.
-
 config BLK_DEV_GAYLE
 	tristate "Amiga Gayle IDE interface support"
 	depends on AMIGA
diff --git a/drivers/ide/Makefile b/drivers/ide/Makefile
index af8d016..a04ee82 100644
--- a/drivers/ide/Makefile
+++ b/drivers/ide/Makefile
@@ -78,8 +78,6 @@ obj-$(CONFIG_BLK_DEV_CMD640)		+= cmd640.o
 
 obj-$(CONFIG_BLK_DEV_IDE_PMAC)		+= pmac.o
 
-obj-$(CONFIG_IDE_H8300)			+= ide-h8300.o
-
 obj-$(CONFIG_IDE_GENERIC)		+= ide-generic.o
 obj-$(CONFIG_BLK_DEV_IDEPNP)		+= ide-pnp.o
 
diff --git a/drivers/ide/ide-h8300.c b/drivers/ide/ide-h8300.c
deleted file mode 100644
index 520f42c..0000000
--- a/drivers/ide/ide-h8300.c
+++ /dev/null
@@ -1,109 +0,0 @@
-/*
- * H8/300 generic IDE interface
- */
-
-#include <linux/init.h>
-#include <linux/ide.h>
-
-#include <asm/io.h>
-#include <asm/irq.h>
-
-#define DRV_NAME "ide-h8300"
-
-#define bswap(d) \
-({					\
-	u16 r;				\
-	__asm__("mov.b %w1,r1h\n\t"	\
-		"mov.b %x1,r1l\n\t"	\
-		"mov.w r1,%0"		\
-		:"=r"(r)		\
-		:"r"(d)			\
-		:"er1");		\
-	(r);				\
-})
-
-static void mm_outsw(unsigned long addr, void *buf, u32 len)
-{
-	unsigned short *bp = (unsigned short *)buf;
-	for (; len > 0; len--, bp++)
-		*(volatile u16 *)addr = bswap(*bp);
-}
-
-static void mm_insw(unsigned long addr, void *buf, u32 len)
-{
-	unsigned short *bp = (unsigned short *)buf;
-	for (; len > 0; len--, bp++)
-		*bp = bswap(*(volatile u16 *)addr);
-}
-
-static void h8300_input_data(ide_drive_t *drive, struct ide_cmd *cmd,
-			     void *buf, unsigned int len)
-{
-	mm_insw(drive->hwif->io_ports.data_addr, buf, (len + 1) / 2);
-}
-
-static void h8300_output_data(ide_drive_t *drive, struct ide_cmd *cmd,
-			      void *buf, unsigned int len)
-{
-	mm_outsw(drive->hwif->io_ports.data_addr, buf, (len + 1) / 2);
-}
-
-static const struct ide_tp_ops h8300_tp_ops = {
-	.exec_command		= ide_exec_command,
-	.read_status		= ide_read_status,
-	.read_altstatus		= ide_read_altstatus,
-	.write_devctl		= ide_write_devctl,
-
-	.dev_select		= ide_dev_select,
-	.tf_load		= ide_tf_load,
-	.tf_read		= ide_tf_read,
-
-	.input_data		= h8300_input_data,
-	.output_data		= h8300_output_data,
-};
-
-#define H8300_IDE_GAP (2)
-
-static inline void hw_setup(struct ide_hw *hw)
-{
-	int i;
-
-	memset(hw, 0, sizeof(*hw));
-	for (i = 0; i <= 7; i++)
-		hw->io_ports_array[i] = CONFIG_H8300_IDE_BASE + H8300_IDE_GAP*i;
-	hw->io_ports.ctl_addr = CONFIG_H8300_IDE_ALT;
-	hw->irq = EXT_IRQ0 + CONFIG_H8300_IDE_IRQ;
-}
-
-static const struct ide_port_info h8300_port_info = {
-	.tp_ops			= &h8300_tp_ops,
-	.host_flags		= IDE_HFLAG_NO_IO_32BIT | IDE_HFLAG_NO_DMA,
-	.chipset		= ide_generic,
-};
-
-static int __init h8300_ide_init(void)
-{
-	struct ide_hw hw, *hws[] = { &hw };
-
-	printk(KERN_INFO DRV_NAME ": H8/300 generic IDE interface\n");
-
-	if (!request_region(CONFIG_H8300_IDE_BASE, H8300_IDE_GAP*8, "ide-h8300"))
-		goto out_busy;
-	if (!request_region(CONFIG_H8300_IDE_ALT, H8300_IDE_GAP, "ide-h8300")) {
-		release_region(CONFIG_H8300_IDE_BASE, H8300_IDE_GAP*8);
-		goto out_busy;
-	}
-
-	hw_setup(&hw);
-
-	return ide_host_add(&h8300_port_info, hws, 1, NULL);
-
-out_busy:
-	printk(KERN_ERR "ide-h8300: IDE I/F resource already used.\n");
-
-	return -EBUSY;
-}
-
-module_init(h8300_ide_init);
-
-MODULE_LICENSE("GPL");
-- 
1.7.9.7
