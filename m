From: Kurt Van Dijck <kurt.van.dijck-/BeEPy95v10@public.gmane.org>
Subject: [PATCH net-next-2.6 1/2] can: add driver for Softing card
Date: Thu, 23 Dec 2010 10:43:03 +0100
Message-ID: <20101223094302.GB325@e-circ.dyndns.org>
References: <20101223093627.GA325@e-circ.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20101223093627.GA325-MxZ6Iy/zr/UdbCeoMzGj59i2O/JbrIOy@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch adds a driver for the platform:softing device.
This will create (up to) 2 CAN network devices from 1
platform:softing device

Signed-off-by: Kurt Van Dijck <kurt.van.dijck-/BeEPy95v10@public.gmane.org>

---
 drivers/net/can/Kconfig                    |    2 +
 drivers/net/can/Makefile                   |    1 +
 drivers/net/can/softing/Kconfig            |   16 +
 drivers/net/can/softing/Makefile           |    5 +
 drivers/net/can/softing/softing.h          |  216 +++++++
 drivers/net/can/softing/softing_fw.c       |  664 ++++++++++++++++++++
 drivers/net/can/softing/softing_main.c     |  935 ++++++++++++++++++++++++++++
 drivers/net/can/softing/softing_platform.h |   38 ++
 8 files changed, 1877 insertions(+), 0 deletions(-)

diff --git a/drivers/net/can/Kconfig b/drivers/net/can/Kconfig
index d5a9db6..986195e 100644
--- a/drivers/net/can/Kconfig
+++ b/drivers/net/can/Kconfig
@@ -117,6 +117,8 @@ source "drivers/net/can/sja1000/Kconfig"
 
 source "drivers/net/can/usb/Kconfig"
 
+source "drivers/net/can/softing/Kconfig"
+
 config CAN_DEBUG_DEVICES
 	bool "CAN devices debugging messages"
 	depends on CAN
diff --git a/drivers/net/can/Makefile b/drivers/net/can/Makefile
index 07ca159..53c82a7 100644
--- a/drivers/net/can/Makefile
+++ b/drivers/net/can/Makefile
@@ -9,6 +9,7 @@ obj-$(CONFIG_CAN_DEV)		+= can-dev.o
 can-dev-y			:= dev.o
 
 obj-y				+= usb/
+obj-y				+= softing/
 
 obj-$(CONFIG_CAN_SJA1000)	+= sja1000/
 obj-$(CONFIG_CAN_MSCAN)		+= mscan/
diff --git a/drivers/net/can/softing/Kconfig b/drivers/net/can/softing/Kconfig
new file mode 100644
index 0000000..072f337
--- /dev/null
+++ b/drivers/net/can/softing/Kconfig
@@ -0,0 +1,16 @@
+config CAN_SOFTING
+	tristate "Softing Gmbh CAN generic support"
+	depends on CAN_DEV
+	---help---
+	  Support for CAN cards from Softing Gmbh & some cards
+	  from Vector Gmbh.
+	  Softing Gmbh CAN cards come with 1 or 2 physical busses.
+	  Those cards typically use Dual Port RAM to communicate
+	  with the host CPU. The interface is then identical for PCI
+	  and PCMCIA cards. This driver operates on a platform device,
+	  which has been created by softing_cs or softing_pci driver.
+	  Warning:
+	  The API of the card does not allow fine control per bus, but
+	  controls the 2 busses on the card together.
+	  As such, some actions (start/stop/busoff recovery) on 1 bus
+	  must bring down the other bus too temporarily.
diff --git a/drivers/net/can/softing/Makefile b/drivers/net/can/softing/Makefile
new file mode 100644
index 0000000..7878b7b
--- /dev/null
+++ b/drivers/net/can/softing/Makefile
@@ -0,0 +1,5 @@
+
+softing-y := softing_main.o softing_fw.o
+obj-$(CONFIG_CAN_SOFTING)        += softing.o
+
+ccflags-$(CONFIG_CAN_DEBUG_DEVICES) := -DDEBUG
diff --git a/drivers/net/can/softing/softing.h b/drivers/net/can/softing/softing.h
new file mode 100644
index 0000000..99046a7
--- /dev/null
+++ b/drivers/net/can/softing/softing.h
@@ -0,0 +1,216 @@
+/*
+ * softing common interfaces
+ *
+ * by Kurt Van Dijck, 06-2008
+ */
+
+#include <linux/netdevice.h>
+#include <linux/ktime.h>
+#include <linux/mutex.h>
+#include <linux/spinlock.h>
+#include <linux/can.h>
+#include <linux/can/dev.h>
+
+#include "softing_platform.h"
+
+#ifndef CAN_CTRLMODE_BERR_REPORTING
+#define CAN_CTRLMODE_BERR_REPORTING 0
+#endif
+
+struct softing;
+
+struct softing_priv {
+	struct can_priv can;	/* must be the first member! */
+	struct net_device *netdev;
+	struct softing *card;
+	struct {
+		int pending;
+		/* variables wich hold the circular buffer */
+		int echo_put;
+		int echo_get;
+	} tx;
+	struct can_bittiming_const btr_const;
+	int index;
+	u8 output;
+	u16 chip;
+};
+#define netdev2softing(netdev)	((struct softing_priv *)netdev_priv(netdev))
+
+struct softing {
+	const struct softing_platform_data *pdat;
+	struct platform_device *pdev;
+	struct net_device *net[2];
+	spinlock_t	 spin; /* protect this structure & DPRAM access */
+	ktime_t ts_ref;
+	ktime_t ts_overflow; /* timestamp overflow value, in ktime */
+
+	struct {
+		/* indication of firmware status */
+		int up;
+		/* protection of the 'up' variable */
+		struct mutex lock;
+	} fw;
+	struct {
+		int nr;
+		int requested;
+		struct tasklet_struct bh;
+		int svc_count;
+	} irq;
+	struct {
+		int pending;
+		int last_bus;
+		/* keep the bus that last tx'd a message,
+		 * in order to let every netdev queue resume
+		 */
+	} tx;
+	struct {
+		unsigned long phys;
+		unsigned long size;
+		unsigned char *virt;
+		unsigned char *end;
+		struct softing_fct  *fct;
+		struct softing_info *info;
+		struct softing_rx  *rx;
+		struct softing_tx  *tx;
+		struct softing_irq *irq;
+		unsigned short *command;
+		unsigned short *receipt;
+	} dpram;
+	struct {
+		u32  serial, fw, hw, lic;
+		u16  chip[2];
+		u32  freq;
+	} id;
+};
+
+extern int softing_default_output(struct net_device *netdev);
+
+extern ktime_t softing_raw2ktime(struct softing *card, u32 raw);
+
+extern int softing_fct_cmd(struct softing *card
+			, int cmd, int vector, const char *msg);
+
+extern int softing_bootloader_command(struct softing *card
+			, int command, const char *msg);
+
+/* reset DPRAM */
+static inline void softing_set_reset_dpram(struct softing *card)
+{
+	if (card->pdat->generation >= 2) {
+		spin_lock_bh(&card->spin);
+		card->dpram.virt[0xe00] &= ~1;
+		spin_unlock_bh(&card->spin);
+	}
+}
+
+static inline void softing_clr_reset_dpram(struct softing *card)
+{
+	if (card->pdat->generation >= 2) {
+		spin_lock_bh(&card->spin);
+		card->dpram.virt[0xe00] |= 1;
+		spin_unlock_bh(&card->spin);
+	}
+}
+
+/* Load firmware after reset */
+extern int softing_load_fw(const char *file, struct softing *card,
+			unsigned char *virt, unsigned int size, int offset);
+
+/* Load final application firmware after bootloader */
+extern int softing_load_app_fw(const char *file, struct softing *card);
+
+extern int softing_reset_chip(struct softing *card);
+
+/*
+ * enable or disable irq
+ * only called with fw.lock locked
+ */
+extern int softing_enable_irq(struct softing *card, int enable);
+
+/* start/stop 1 bus on card */
+extern int softing_startstop(struct net_device *netdev, int up);
+
+/* netif_rx() */
+extern int softing_netdev_rx(struct net_device *netdev,
+		const struct can_frame *msg, ktime_t ktime);
+
+/* SOFTING DPRAM mappings */
+struct softing_rx {
+	u8  fifo[16][32];
+	u8  dummy1;
+	u16 rd;
+	u16 dummy2;
+	u16 wr;
+	u16  dummy3;
+	u16 lost_msg;
+} __attribute__((packed));
+
+#define TXMAX	31
+struct softing_tx {
+	u8  fifo[32][16];
+	u8  dummy1;
+	u16 rd;
+	u16 dummy2;
+	u16 wr;
+	u8  dummy3;
+} __attribute__((packed));
+
+struct softing_irq {
+	u8 to_host;
+	u8 to_card;
+} __attribute__((packed));
+
+struct softing_fct {
+	s16 param[20]; /* 0 is index */
+	s16 returned;
+	u8  dummy;
+	u16 host_access;
+} __attribute__((packed));
+
+struct softing_info {
+	u8  dummy1;
+	u16 bus_state;
+	u16 dummy2;
+	u16 bus_state2;
+	u16 dummy3;
+	u16 error_state;
+	u16 dummy4;
+	u16 error_state2;
+	u16 dummy5;
+	u16 reset;
+	u16 dummy6;
+	u16 clear_rcv_fifo;
+	u16 dummy7;
+	u16 dummyxx;
+	u16 dummy8;
+	u16 time_reset;
+	u8  dummy9;
+	u32 time;
+	u32 time_wrap;
+	u8  wr_start;
+	u8  wr_end;
+	u8  dummy10;
+	u16 dummy12;
+	u16 dummy12x;
+	u16 dummy13;
+	u16 reset_rcv_fifo;
+	u8  dummy14;
+	u8  reset_xmt_fifo;
+	u8  read_fifo_levels;
+	u16 rcv_fifo_level;
+	u16 xmt_fifo_level;
+} __attribute__((packed));
+
+/* DPRAM return codes */
+#define RES_NONE	0
+#define RES_OK		1
+#define RES_NOK		2
+#define RES_UNKNOWN	3
+/* DPRAM flags */
+#define CMD_TX		0x01
+#define CMD_ACK		0x02
+#define CMD_XTD		0x04
+#define CMD_RTR		0x08
+#define CMD_ERR		0x10
+#define CMD_BUS2	0x80
+
diff --git a/drivers/net/can/softing/softing_fw.c b/drivers/net/can/softing/softing_fw.c
new file mode 100644
index 0000000..f61299c
--- /dev/null
+++ b/drivers/net/can/softing/softing_fw.c
@@ -0,0 +1,664 @@
+/*
+* drivers/net/can/softing/softing_fw.c
+*
+* Copyright (C) 2008-2010
+*
+* - Kurt Van Dijck, EIA Electronics
+*
+* This program is free software; you can redistribute it and/or modify
+* it under the terms of the version 2 of the GNU General Public License
+* as published by the Free Software Foundation
+*
+* This program is distributed in the hope that it will be useful,
+* but WITHOUT ANY WARRANTY; without even the implied warranty of
+* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
+* GNU General Public License for more details.
+*
+* You should have received a copy of the GNU General Public License
+* along with this program; if not, write to the Free Software
+* Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
+*/
+
+#include <linux/firmware.h>
+#include <linux/sched.h>
+#include <asm/div64.h>
+
+#include "softing.h"
+
+int softing_fct_cmd(struct softing *card, int cmd, int vector, const char *msg)
+{
+	int ret;
+	unsigned long stamp;
+	if (vector == RES_OK)
+		vector = RES_NONE;
+	card->dpram.fct->param[0] = cmd;
+	card->dpram.fct->host_access = vector;
+	/* be sure to flush this to the card */
+	wmb();
+	stamp = jiffies;
+	/*wait for card */
+	do {
+		ret = card->dpram.fct->host_access;
+		/* don't have any cached variables */
+		rmb();
+		if (ret == RES_OK) {
+			/*don't read return-value now */
+			ret = card->dpram.fct->returned;
+			if (ret)
+				dev_alert(&card->pdev->dev,
+					"%s returned %u\n", msg, ret);
+			return 0;
+		}
+		if ((jiffies - stamp) >= 1 * HZ)
+			break;
+		if (in_interrupt())
+			/* go as fast as possible */
+			continue;
+		/* process context => relax */
+		schedule();
+	} while (!signal_pending(current));
+
+	if (ret == RES_NONE) {
+		dev_alert(&card->pdev->dev,
+			"%s, no response from card on %u/0x%02x\n",
+			msg, cmd, vector);
+		return 1;
+	} else {
+		dev_alert(&card->pdev->dev,
+			"%s, bad response from card on %u/0x%02x, 0x%04x\n",
+			msg, cmd, vector, ret);
+		/*make sure to return something not 0 */
+		return ret ? ret : 1;
+	}
+}
+
+int softing_bootloader_command(struct softing *card
+		, int command, const char *msg)
+{
+	int ret;
+	unsigned long stamp;
+	card->dpram.receipt[0] = RES_NONE;
+	card->dpram.command[0] = command;
+	/* be sure to flush this to the card */
+	wmb();
+	stamp = jiffies;
+	/*wait for card */
+	do {
+		ret = card->dpram.receipt[0];
+		/* don't have any cached variables */
+		rmb();
+		if (ret == RES_OK)
+			return 0;
+		if ((jiffies - stamp) >= (3 * HZ))
+			break;
+		schedule();
+	} while (!signal_pending(current));
+
+	switch (ret) {
+	case RES_NONE:
+		dev_alert(&card->pdev->dev, "%s: no response from card\n", msg);
+		break;
+	case RES_NOK:
+		dev_alert(&card->pdev->dev, "%s: response from card nok\n",
+				msg);
+		break;
+	case RES_UNKNOWN:
+		dev_alert(&card->pdev->dev, "%s: command 0x%04x unknown\n",
+			msg, command);
+		break;
+	default:
+		dev_alert(&card->pdev->dev, "%s: bad response from card: %i\n",
+			msg, ret);
+		break;
+	}
+	return ret ? ret : 1;
+}
+
+struct fw_hdr {
+	u16 type;
+	u32 addr;
+	u16 len;
+	u16 checksum;
+	const unsigned char *base;
+} __attribute__ ((packed));
+
+static int fw_parse(const unsigned char **pmem, struct fw_hdr *hdr)
+{
+	u16 tmp;
+	const unsigned char *mem;
+	const unsigned char *end;
+	mem = *pmem;
+	hdr->type = (mem[0] << 0) | (mem[1] << 8);
+	hdr->addr = (mem[2] << 0) | (mem[3] << 8)
+		 | (mem[4] << 16) | (mem[5] << 24);
+	hdr->len = (mem[6] << 0) | (mem[7] << 8);
+	hdr->base = &mem[8];
+	hdr->checksum =
+		 (hdr->base[hdr->len] << 0) | (hdr->base[hdr->len + 1] << 8);
+	for (tmp = 0, mem = *pmem, end = &hdr->base[hdr->len]; mem < end; ++mem)
+		tmp += *mem;
+	if (tmp != hdr->checksum)
+		return -EINVAL;
+	*pmem += 10 + hdr->len;
+	return 0;
+}
+
+int softing_load_fw(const char *file, struct softing *card,
+			unsigned char *virt, unsigned int size, int offset)
+{
+	const struct firmware *fw;
+	const unsigned char *mem;
+	const unsigned char *end;
+	int ret = 0;
+	u32 start_addr;
+	struct fw_hdr rec;
+	int ok = 0;
+	unsigned char buf[1024];
+
+	ret = request_firmware(&fw, file, &card->pdev->dev);
+	if (ret) {
+		dev_alert(&card->pdev->dev, "request_firmware(%s) got %i\n",
+			file, ret);
+		return ret;
+	}
+	dev_dbg(&card->pdev->dev, "%s, firmware(%s) got %u bytes"
+		", offset %c0x%04x\n",
+		card->pdat->name, file, (unsigned int)fw->size,
+		(offset >= 0) ? '+' : '-', (unsigned int)abs(offset));
+	/* parse the firmware */
+	mem = fw->data;
+	end = &mem[fw->size];
+	/* look for header record */
+	ret = fw_parse(&mem, &rec);
+	if (ret < 0)
+		goto fw_end;
+	if (rec.type != 0xffff) {
+		dev_alert(&card->pdev->dev, "firware starts with type 0x%04x\n",
+			rec.type);
+		goto fw_end;
+	}
+	if (strncmp("Structured Binary Format, Softing GmbH"
+			, rec.base, rec.len)) {
+		dev_info(&card->pdev->dev, "firware string '%.*s'\n",
+			rec.len, rec.base);
+		goto fw_end;
+	}
+	ok |= 1;
+	/* ok, we had a header */
+	while (mem < end) {
+		ret = fw_parse(&mem, &rec);
+		if (ret)
+			break;
+		if (rec.type == 3) {
+			/*start address */
+			start_addr = rec.addr;
+			ok |= 2;
+			continue;
+		} else if (rec.type == 1) {
+			/*eof */
+			ok |= 4;
+			goto fw_end;
+		} else if (rec.type != 0) {
+			dev_alert(&card->pdev->dev, "unknown record type 0x%04x\n",
+				rec.type);
+			break;
+		}
+
+		if ((rec.addr + rec.len + offset) > size) {
+			dev_alert(&card->pdev->dev,
+				"firmware out of range (0x%08x / 0x%08x)\n",
+				(rec.addr + rec.len + offset), size);
+			goto fw_end;
+		}
+		memcpy_toio(&virt[rec.addr + offset],
+				 rec.base, rec.len);
+		/* be sure to flush caches from IO space */
+		mb();
+		if (rec.len > sizeof(buf)) {
+			dev_info(&card->pdev->dev,
+				"record is big (%u bytes), not verifying\n",
+				rec.len);
+			continue;
+		}
+		/* verify record data */
+		memcpy_fromio(buf, &virt[rec.addr + offset], rec.len);
+		if (!memcmp(buf, rec.base, rec.len))
+			/* is ok */
+			continue;
+		dev_alert(&card->pdev->dev, "0x%08x:0x%03x at 0x%p failed\n",
+			rec.addr, rec.len, &virt[rec.addr + offset]);
+		goto fw_end;
+	}
+fw_end:
+	release_firmware(fw);
+	if (0x5 == (ok & 0x5))
+		/* got eof & start */
+		return 0;
+	dev_info(&card->pdev->dev, "firmware %s failed\n", file);
+	return ret ?: -EINVAL;
+}
+
+int softing_load_app_fw(const char *file, struct softing *card)
+{
+	const struct firmware *fw;
+	const unsigned char *mem;
+	const unsigned char *end;
+	int ret;
+	struct fw_hdr rec;
+	int ok = 0;
+	u32 start_addr = 0;
+	u16 rx_sum;
+	unsigned int sum;
+	const unsigned char *mem_lp;
+	const unsigned char *mem_end;
+	struct cpy {
+		u32 src;
+		u32 dst;
+		u16 len;
+		u8 do_cs;
+	} __attribute__((packed)) *pcpy =
+		 (struct cpy *)&card->dpram.command[1];
+	struct cmd {
+		u32 start;
+		u8 autorestart;
+	} __attribute__((packed)) *pcmdstart =
+		(struct cmd *)&card->dpram.command[1];
+
+	ret = request_firmware(&fw, file, &card->pdev->dev);
+	if (ret) {
+		dev_alert(&card->pdev->dev, "request_firmware(%s) got %i\n",
+			file, ret);
+		return ret;
+	}
+	dev_dbg(&card->pdev->dev, "firmware(%s) got %lu bytes\n",
+		file, (unsigned long)fw->size);
+	/* parse the firmware */
+	mem = fw->data;
+	end = &mem[fw->size];
+	/* look for header record */
+	ret = fw_parse(&mem, &rec);
+	if (ret)
+		goto fw_end;
+	if (rec.type != 0xffff) {
+		dev_alert(&card->pdev->dev, "firware starts with type 0x%04x\n",
+			rec.type);
+		goto fw_end;
+	}
+	if (strncmp("Structured Binary Format, Softing GmbH"
+		, rec.base, rec.len)) {
+		dev_alert(&card->pdev->dev, "firware string '%.*s' fault\n",
+			rec.len, rec.base);
+		goto fw_end;
+	}
+	ok |= 1;
+	/* ok, we had a header */
+	while (mem < end) {
+		ret = fw_parse(&mem, &rec);
+		if (ret)
+			break;
+
+		if (rec.type == 3) {
+			/*start address */
+			start_addr = rec.addr;
+			ok |= 2;
+			continue;
+		} else if (rec.type == 1) {
+			/*eof */
+			ok |= 4;
+			goto fw_end;
+		} else if (rec.type != 0) {
+			dev_alert(&card->pdev->dev, "unknown record type 0x%04x\n",
+				rec.type);
+			break;
+		}
+		/* regualar data */
+		for (sum = 0, mem_lp = rec.base, mem_end = &mem_lp[rec.len];
+			mem_lp < mem_end; ++mem_lp)
+			sum += *mem_lp;
+
+		memcpy_toio(&card->dpram. virt[card->pdat->app.offs],
+				 rec.base, rec.len);
+		pcpy->src = card->pdat->app.offs + card->pdat->app.addr;
+		pcpy->dst = rec.addr;
+		pcpy->len = rec.len;
+		pcpy->do_cs = 1;
+		if (softing_bootloader_command(card, 1, "loading app."))
+			goto fw_end;
+		/*verify checksum */
+		rx_sum = card->dpram.receipt[1];
+		if (rx_sum != (sum & 0xffff)) {
+			dev_alert(&card->pdev->dev, "SRAM seems to be damaged"
+				", wanted 0x%04x, got 0x%04x\n", sum, rx_sum);
+			goto fw_end;
+		}
+	}
+fw_end:
+	release_firmware(fw);
+	if (ok != 7)
+		goto fw_failed;
+	/*got start, start_addr, & eof */
+	pcmdstart->start = start_addr;
+	pcmdstart->autorestart = 1;
+	if (softing_bootloader_command(card, 3, "start app."))
+		goto fw_failed;
+	dev_info(&card->pdev->dev, "firmware %s up\n", file);
+	return 0;
+fw_failed:
+	dev_info(&card->pdev->dev, "firmware %s failed\n", file);
+	return ret ?: -EINVAL;
+}
+
+int softing_reset_chip(struct softing *card)
+{
+	do {
+		/*reset chip */
+		card->dpram.info->reset_rcv_fifo = 0;
+		card->dpram.info->reset = 1;
+		if (!softing_fct_cmd(card, 0, 0, "reset_chip"))
+			break;
+		if (signal_pending(current))
+			goto failed;
+		/*sync */
+		if (softing_fct_cmd(card, 99, 0x55, "sync-a"))
+			goto failed;
+		if (softing_fct_cmd(card, 99, 0xaa, "sync-a"))
+			goto failed;
+	} while (1);
+	card->tx.pending = 0;
+	return 0;
+failed:
+	return -EIO;
+}
+
+static void softing_initialize_timestamp(struct softing *card)
+{
+	uint64_t ovf;
+
+	card->ts_ref = ktime_get();
+
+	/* 16MHz is the reference */
+	ovf = 0x100000000ULL * 16;
+	do_div(ovf, card->pdat->freq ?: 16);
+
+	card->ts_overflow = ktime_add_us(ktime_set(0, 0), ovf);
+}
+
+ktime_t softing_raw2ktime(struct softing *card, u32 raw)
+{
+	uint64_t rawl;
+	ktime_t now, real_offset;
+	ktime_t target;
+	ktime_t tmp;
+
+	now = ktime_get();
+	real_offset = ktime_sub(ktime_get_real(), now);
+
+	/* find nsec from card */
+	rawl = raw * 16;
+	do_div(rawl, card->pdat->freq ?: 16);
+	target = ktime_add_us(card->ts_ref, rawl);
+	/* test for overflows */
+	tmp = ktime_add(target, card->ts_overflow);
+	while (unlikely(ktime_to_ns(tmp) > ktime_to_ns(now))) {
+		card->ts_ref = ktime_add(card->ts_ref, card->ts_overflow);
+		target = tmp;
+		tmp = ktime_add(target, card->ts_overflow);
+	}
+	return ktime_add(target, real_offset);
+}
+
+static inline int softing_error_reporting(struct net_device *netdev)
+{
+	struct softing_priv *priv = netdev_priv(netdev);
+
+	return (priv->can.ctrlmode & CAN_CTRLMODE_BERR_REPORTING)
+		? 1 : 0;
+}
+
+int softing_startstop(struct net_device *dev, int up)
+{
+	int ret;
+	struct softing *card;
+	struct softing_priv *priv;
+	struct net_device *netdev;
+	int mask_start;
+	int j, error_reporting;
+	struct can_frame msg;
+
+	priv = netdev_priv(dev);
+	card = priv->card;
+
+	if (!card->fw.up)
+		return -EIO;
+
+	ret = mutex_lock_interruptible(&card->fw.lock);
+	if (ret)
+		return ret;
+
+	mask_start = 0;
+	if (dev && up)
+		/* prepare to start this bus as well */
+		mask_start |= (1 << priv->index);
+	/* bring netdevs down */
+	for (j = 0; j < ARRAY_SIZE(card->net); ++j) {
+		netdev = card->net[j];
+		if (!netdev)
+			continue;
+		priv = netdev_priv(netdev);
+
+		if (dev != netdev)
+			netif_stop_queue(netdev);
+
+		if (netif_running(netdev)) {
+			if (dev != netdev)
+				mask_start |= (1 << j);
+			priv->tx.pending = 0;
+			priv->tx.echo_put = 0;
+			priv->tx.echo_get = 0;
+			/* this bus' may just have called open_candev()
+			 * which is rather stupid to call close_candev()
+			 * already
+			 * but we may come here from busoff recovery too
+			 * in which case the echo_skb _needs_ flushing too.
+			 * just be sure to call open_candev() again
+			 */
+			close_candev(netdev);
+		}
+		priv->can.state = CAN_STATE_STOPPED;
+	}
+	card->tx.pending = 0;
+
+	softing_enable_irq(card, 0);
+	ret = softing_reset_chip(card);
+	if (ret)
+		goto failed;
+	if (!mask_start)
+		/* no busses to be brought up */
+		goto card_done;
+
+	if ((mask_start & 1) && (mask_start & 2)
+			&& (softing_error_reporting(card->net[0])
+				!= softing_error_reporting(card->net[1]))) {
+		dev_alert(&card->pdev->dev,
+				"err_reporting flag differs for busses\n");
+		goto invalid;
+	}
+	error_reporting = 0;
+	if (mask_start & 1) {
+		netdev = card->net[0];
+		priv = netdev_priv(netdev);
+		error_reporting += softing_error_reporting(netdev);
+		/*init chip 1 */
+		card->dpram.fct->param[1] = priv->can.bittiming.brp;
+		card->dpram.fct->param[2] = priv->can.bittiming.sjw;
+		card->dpram.fct->param[3] =
+			priv->can.bittiming.phase_seg1 +
+			priv->can.bittiming.prop_seg;
+		card->dpram.fct->param[4] =
+			priv->can.bittiming.phase_seg2;
+		card->dpram.fct->param[5] = (priv->can.ctrlmode &
+			CAN_CTRLMODE_3_SAMPLES) ? 1 : 0;
+		if (softing_fct_cmd(card, 1, 0, "initialize_chip[0]"))
+			goto failed;
+		/*set mode */
+		card->dpram.fct->param[1] = 0;
+		card->dpram.fct->param[2] = 0;
+		if (softing_fct_cmd(card, 3, 0, "set_mode[0]"))
+			goto failed;
+		/*set filter */
+		card->dpram.fct->param[1] = 0x0000;/*card->bus[0].s.msg; */
+		card->dpram.fct->param[2] = 0x07ff;/*card->bus[0].s.msk; */
+		card->dpram.fct->param[3] = 0x0000;/*card->bus[0].l.msg; */
+		card->dpram.fct->param[4] = 0xffff;/*card->bus[0].l.msk; */
+		card->dpram.fct->param[5] = 0x0000;/*card->bus[0].l.msg >> 16;*/
+		card->dpram.fct->param[6] = 0x1fff;/*card->bus[0].l.msk >> 16;*/
+		if (softing_fct_cmd(card, 7, 0, "set_filter[0]"))
+			goto failed;
+		/*set output control */
+		card->dpram.fct->param[1] = priv->output;
+		if (softing_fct_cmd(card, 5, 0, "set_output[0]"))
+			goto failed;
+	}
+	if (mask_start & 2) {
+		netdev = card->net[1];
+		priv = netdev_priv(netdev);
+		error_reporting += softing_error_reporting(netdev);
+		/*init chip2 */
+		card->dpram.fct->param[1] = priv->can.bittiming.brp;
+		card->dpram.fct->param[2] = priv->can.bittiming.sjw;
+		card->dpram.fct->param[3] =
+			priv->can.bittiming.phase_seg1 +
+			priv->can.bittiming.prop_seg;
+		card->dpram.fct->param[4] =
+			priv->can.bittiming.phase_seg2;
+		card->dpram.fct->param[5] = (priv->can.ctrlmode &
+			CAN_CTRLMODE_3_SAMPLES) ? 1 : 0;
+		if (softing_fct_cmd(card, 2, 0, "initialize_chip[1]"))
+			goto failed;
+		/*set mode2 */
+		card->dpram.fct->param[1] = 0;
+		card->dpram.fct->param[2] = 0;
+		if (softing_fct_cmd(card, 4, 0, "set_mode[1]"))
+			goto failed;
+		/*set filter2 */
+		card->dpram.fct->param[1] = 0x0000;/*card->bus[1].s.msg; */
+		card->dpram.fct->param[2] = 0x07ff;/*card->bus[1].s.msk; */
+		card->dpram.fct->param[3] = 0x0000;/*card->bus[1].l.msg; */
+		card->dpram.fct->param[4] = 0xffff;/*card->bus[1].l.msk; */
+		card->dpram.fct->param[5] = 0x0000;/*card->bus[1].l.msg >> 16;*/
+		card->dpram.fct->param[6] = 0x1fff;/*card->bus[1].l.msk >> 16;*/
+		if (softing_fct_cmd(card, 8, 0, "set_filter[1]"))
+			goto failed;
+		/*set output control2 */
+		card->dpram.fct->param[1] = priv->output;
+		if (softing_fct_cmd(card, 6, 0, "set_output[1]"))
+			goto failed;
+	}
+	/*enable_error_frame */
+	if (error_reporting) {
+		if (softing_fct_cmd(card, 51, 0, "enable_error_frame"))
+			goto failed;
+	}
+	/*initialize interface */
+	card->dpram.fct->param[1] = 1;
+	card->dpram.fct->param[2] = 1;
+	card->dpram.fct->param[3] = 1;
+	card->dpram.fct->param[4] = 1;
+	card->dpram.fct->param[5] = 1;
+	card->dpram.fct->param[6] = 1;
+	card->dpram.fct->param[7] = 1;
+	card->dpram.fct->param[8] = 1;
+	card->dpram.fct->param[9] = 1;
+	card->dpram.fct->param[10] = 1;
+	if (softing_fct_cmd(card, 17, 0, "initialize_interface"))
+		goto failed;
+	/*enable_fifo */
+	if (softing_fct_cmd(card, 36, 0, "enable_fifo"))
+		goto failed;
+	/*enable fifo tx ack */
+	if (softing_fct_cmd(card, 13, 0, "fifo_tx_ack[0]"))
+		goto failed;
+	/*enable fifo tx ack2 */
+	if (softing_fct_cmd(card, 14, 0, "fifo_tx_ack[1]"))
+		goto failed;
+	/*enable timestamps */
+	/*is default, no code found */
+	/*start_chip */
+	if (softing_fct_cmd(card, 11, 0, "start_chip"))
+		goto failed;
+	card->dpram.info->bus_state = 0;
+	card->dpram.info->bus_state2 = 0;
+	dev_info(&card->pdev->dev, "%s up\n", __func__);
+	if (card->pdat->generation < 2) {
+		card->dpram.irq->to_host = 0;
+		/* flush the DPRAM caches */
+		wmb();
+	}
+
+	softing_initialize_timestamp(card);
+
+	/*
+	 * do socketcan notifications/status changes
+	 * from here, no errors should occur, or the failed: part
+	 * must be reviewed
+	 */
+	memset(&msg, 0, sizeof(msg));
+	msg.can_id = CAN_ERR_FLAG | CAN_ERR_RESTARTED;
+	msg.can_dlc = CAN_ERR_DLC;
+	for (j = 0; j < ARRAY_SIZE(card->net); ++j) {
+		if (!(mask_start & (1 << j)))
+			continue;
+		netdev = card->net[j];
+		if (!netdev)
+			continue;
+		priv = netdev_priv(netdev);
+		priv->can.state = CAN_STATE_ERROR_ACTIVE;
+		open_candev(netdev);
+		if (dev != netdev) {
+			/* notify other busses on the restart */
+			softing_netdev_rx(netdev, &msg, ktime_set(0, 0));
+			++priv->can.can_stats.restarts;
+		}
+		netif_wake_queue(netdev);
+	}
+
+	/* enable interrupts */
+	ret = softing_enable_irq(card, 1);
+	if (ret)
+		goto failed;
+card_done:
+	mutex_unlock(&card->fw.lock);
+	return 0;
+failed:
+	dev_alert(&card->pdev->dev, "firmware failed, going idle\n");
+invalid:
+	softing_enable_irq(card, 0);
+	softing_reset_chip(card);
+	mutex_unlock(&card->fw.lock);
+	/* bring all other interfaces down */
+	for (j = 0; j < ARRAY_SIZE(card->net); ++j) {
+		netdev = card->net[j];
+		if (!netdev)
+			continue;
+		dev_close(netdev);
+	}
+	return -EIO;
+}
+
+int softing_default_output(struct net_device *netdev)
+{
+	struct softing_priv *priv = netdev_priv(netdev);
+	struct softing *card = priv->card;
+
+	switch (priv->chip) {
+	case 1000:
+		if (card->pdat->generation < 2)
+			return 0xfb;
+		return 0xfa;
+	case 5:
+		return 0x60;
+	default:
+		return 0x40;
+	}
+}
+
diff --git a/drivers/net/can/softing/softing_main.c b/drivers/net/can/softing/softing_main.c
new file mode 100644
index 0000000..a3d94d4
--- /dev/null
+++ b/drivers/net/can/softing/softing_main.c
@@ -0,0 +1,935 @@
+/*
+* drivers/net/can/softing/softing_main.c
+*
+* Copyright (C) 2008-2010
+*
+* - Kurt Van Dijck, EIA Electronics
+*
+* This program is free software; you can redistribute it and/or modify
+* it under the terms of the version 2 of the GNU General Public License
+* as published by the Free Software Foundation
+*
+* This program is distributed in the hope that it will be useful,
+* but WITHOUT ANY WARRANTY; without even the implied warranty of
+* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
+* GNU General Public License for more details.
+*
+* You should have received a copy of the GNU General Public License
+* along with this program; if not, write to the Free Software
+* Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
+*/
+
+#include <linux/version.h>
+#include <linux/module.h>
+#include <linux/init.h>
+#include <linux/interrupt.h>
+
+#include "softing.h"
+
+#define TX_ECHO_SKB_MAX (TXMAX/2)
+
+/*
+ * test is a specific CAN netdev
+ * is online (ie. up 'n running, not sleeping, not busoff
+ */
+static inline int canif_is_active(struct net_device *netdev)
+{
+	struct can_priv *can = netdev_priv(netdev);
+	if (!netif_running(netdev))
+		return 0;
+	return (can->state <= CAN_STATE_ERROR_PASSIVE);
+}
+
+/* trigger the tx queue-ing */
+static netdev_tx_t
+softing_netdev_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct softing_priv *priv = netdev_priv(dev);
+	struct softing *card = priv->card;
+	int ret;
+	int bhlock;
+	u8 *ptr;
+	u8 cmd;
+	unsigned int fifo_wr;
+	struct can_frame msg;
+
+	if (can_dropped_invalid_skb(dev, skb))
+		return NETDEV_TX_OK;
+
+	if (in_interrupt()) {
+		bhlock = 0;
+		spin_lock(&card->spin);
+	} else {
+		bhlock = 1;
+		spin_lock_bh(&card->spin);
+	}
+	ret = NETDEV_TX_BUSY;
+	if (!card->fw.up)
+		goto xmit_done;
+	if (card->tx.pending >= TXMAX)
+		goto xmit_done;
+	if (priv->tx.pending >= TX_ECHO_SKB_MAX)
+		goto xmit_done;
+	fifo_wr = card->dpram.tx->wr;
+	if (fifo_wr == card->dpram.tx->rd)
+		/*fifo full */
+		goto xmit_done;
+	memcpy(&msg, skb->data, sizeof(msg));
+	ptr = &card->dpram.tx->fifo[fifo_wr][0];
+	cmd = CMD_TX;
+	if (msg.can_id & CAN_RTR_FLAG)
+		cmd |= CMD_RTR;
+	if (msg.can_id & CAN_EFF_FLAG)
+		cmd |= CMD_XTD;
+	if (priv->index)
+		cmd |= CMD_BUS2;
+	*ptr++ = cmd;
+	*ptr++ = msg.can_dlc;
+	*ptr++ = (msg.can_id >> 0);
+	*ptr++ = (msg.can_id >> 8);
+	if (msg.can_id & CAN_EFF_FLAG) {
+		*ptr++ = (msg.can_id >> 16);
+		*ptr++ = (msg.can_id >> 24);
+	} else {
+		/*increment 1, not 2 as you might think */
+		ptr += 1;
+	}
+	if (!(msg.can_id & CAN_RTR_FLAG))
+		memcpy_toio(ptr, &msg.data[0], msg.can_dlc);
+	if (++fifo_wr >=
+		 sizeof(card->dpram.tx->fifo) /
+		 sizeof(card->dpram.tx->fifo[0]))
+		fifo_wr = 0;
+	card->dpram.tx->wr = fifo_wr;
+	card->tx.last_bus = priv->index;
+	++card->tx.pending;
+	++priv->tx.pending;
+	can_put_echo_skb(skb, dev, priv->tx.echo_put);
+	++priv->tx.echo_put;
+	if (priv->tx.echo_put >= TX_ECHO_SKB_MAX)
+		priv->tx.echo_put = 0;
+	/* can_put_echo_skb() saves the skb, safe to return TX_OK */
+	ret = NETDEV_TX_OK;
+xmit_done:
+	if (bhlock)
+		spin_unlock_bh(&card->spin);
+	else
+		spin_unlock(&card->spin);
+	if (card->tx.pending >= TXMAX) {
+		int j;
+		for (j = 0; j < ARRAY_SIZE(card->net); ++j) {
+			if (card->net[j])
+				netif_stop_queue(card->net[j]);
+		}
+	}
+	if (ret != NETDEV_TX_OK)
+		netif_stop_queue(dev);
+
+	return ret;
+}
+
+/*
+ * shortcut for skb delivery
+ */
+int softing_netdev_rx(struct net_device *netdev,
+		const struct can_frame *msg, ktime_t ktime)
+{
+	struct sk_buff *skb;
+	struct can_frame *cf;
+	int ret;
+
+	skb = alloc_can_skb(netdev, &cf);
+	if (!skb)
+		return -ENOMEM;
+	memcpy(cf, msg, sizeof(*msg));
+	skb->tstamp = ktime;
+	ret = netif_rx(skb);
+	if (ret == NET_RX_DROP)
+		++netdev->stats.rx_dropped;
+	return ret;
+}
+
+/*
+ * softing_handle_1
+ * pop 1 entry from the DPRAM queue, and process
+ */
+static int softing_handle_1(struct softing *card)
+{
+	int j;
+	struct net_device *netdev;
+	struct softing_priv *priv;
+	ktime_t ktime;
+	struct can_frame msg;
+
+	unsigned int fifo_rd;
+	unsigned int cnt = 0;
+	u8 *ptr;
+	u32 tmp;
+	u8 cmd;
+
+	memset(&msg, 0, sizeof(msg));
+	if (card->dpram.rx->lost_msg) {
+		/*reset condition */
+		card->dpram.rx->lost_msg = 0;
+		/* prepare msg */
+		msg.can_id = CAN_ERR_FLAG | CAN_ERR_CRTL;
+		msg.can_dlc = CAN_ERR_DLC;
+		msg.data[1] = CAN_ERR_CRTL_RX_OVERFLOW;
+		/*
+		 * service to all busses, we don't know which it was applicable
+		 * but only service busses that are online
+		 */
+		for (j = 0; j < ARRAY_SIZE(card->net); ++j) {
+			netdev = card->net[j];
+			if (!netdev)
+				continue;
+			if (!canif_is_active(netdev))
+				/* a dead bus has no overflows */
+				continue;
+			++netdev->stats.rx_over_errors;
+			softing_netdev_rx(netdev, &msg, ktime_set(0, 0));
+		}
+		/* prepare for other use */
+		memset(&msg, 0, sizeof(msg));
+		++cnt;
+	}
+
+	fifo_rd = card->dpram.rx->rd;
+	if (++fifo_rd >= ARRAY_SIZE(card->dpram.rx->fifo))
+		fifo_rd = 0;
+
+	if (card->dpram.rx->wr == fifo_rd)
+		return cnt;
+
+	ptr = &card->dpram.rx->fifo[fifo_rd][0];
+
+	cmd = *ptr++;
+	if (cmd == 0xff) {
+		/*not quite usefull, probably the card has got out */
+		dev_alert(&card->pdev->dev, "got cmd 0x%02x,"
+			" I suspect the card is lost\n", cmd);
+	}
+	/*mod_trace("0x%02x", cmd);*/
+	netdev = card->net[0];
+	if (cmd & CMD_BUS2)
+		netdev = card->net[1];
+	priv = netdev_priv(netdev);
+
+	if (cmd & CMD_ERR) {
+		u8 can_state;
+		u8 state;
+		state = *ptr++;
+
+		msg.can_id = CAN_ERR_FLAG;
+		msg.can_dlc = CAN_ERR_DLC;
+
+		if (state & 0x80) {
+			can_state = CAN_STATE_BUS_OFF;
+			msg.can_id |= CAN_ERR_BUSOFF;
+			state = 2;
+		} else if (state & 0x60) {
+			can_state = CAN_STATE_ERROR_PASSIVE;
+			msg.can_id |= CAN_ERR_BUSERROR;
+			msg.data[1] = CAN_ERR_CRTL_TX_PASSIVE;
+			state = 1;
+		} else {
+			can_state = CAN_STATE_ERROR_ACTIVE;
+			state = 0;
+			msg.can_id |= CAN_ERR_BUSERROR;
+		}
+		/*update DPRAM */
+		if (!priv->index)
+			card->dpram.info->bus_state = state;
+		else
+			card->dpram.info->bus_state2 = state;
+		/*timestamp */
+		tmp = (ptr[0] <<  0) | (ptr[1] <<  8)
+		    | (ptr[2] << 16) | (ptr[3] << 24);
+		ptr += 4;
+		ktime = softing_raw2ktime(card, tmp);
+		/*trigger dual port RAM */
+		mb();
+		card->dpram.rx->rd = fifo_rd;
+
+		++priv->can.can_stats.bus_error;
+		++netdev->stats.rx_errors;
+		/*update internal status */
+		if (can_state != priv->can.state) {
+			priv->can.state = can_state;
+			if (can_state == CAN_STATE_ERROR_PASSIVE)
+				++priv->can.can_stats.error_passive;
+			if (can_state == CAN_STATE_BUS_OFF) {
+				/* this calls can_close_cleanup() */
+				can_bus_off(netdev);
+				netif_stop_queue(netdev);
+			}
+			/*trigger socketcan */
+			softing_netdev_rx(netdev, &msg, ktime);
+		}
+
+	} else {
+		if (cmd & CMD_RTR)
+			msg.can_id |= CAN_RTR_FLAG;
+		/* acknowledge, was tx msg
+		 * no real tx flag to set
+		if (cmd & CMD_ACK) {
+		}
+		 */
+		msg.can_dlc = get_can_dlc(*ptr++);
+		if (cmd & CMD_XTD) {
+			msg.can_id |= CAN_EFF_FLAG;
+			msg.can_id |= (ptr[0] <<  0) | (ptr[1] <<  8)
+				    | (ptr[2] << 16) | (ptr[3] << 24);
+			ptr += 4;
+		} else {
+			msg.can_id |= (ptr[0] << 0) | (ptr[1] << 8);
+			ptr += 2;
+		}
+		tmp = (ptr[0] <<  0) | (ptr[1] <<  8)
+		    | (ptr[2] << 16) | (ptr[3] << 24);
+		ptr += 4;
+		ktime = softing_raw2ktime(card, tmp);
+		memcpy_fromio(&msg.data[0], ptr, 8);
+		ptr += 8;
+		/*trigger dual port RAM */
+		mb();
+		card->dpram.rx->rd = fifo_rd;
+		/*update socket */
+		if (cmd & CMD_ACK) {
+			struct sk_buff *skb;
+			skb = priv->can.echo_skb[priv->tx.echo_get];
+			if (skb)
+				skb->tstamp = ktime;
+			can_get_echo_skb(netdev, priv->tx.echo_get);
+			++priv->tx.echo_get;
+			if (priv->tx.echo_get >= TX_ECHO_SKB_MAX)
+				priv->tx.echo_get = 0;
+			if (priv->tx.pending)
+				--priv->tx.pending;
+			if (card->tx.pending)
+				--card->tx.pending;
+			++netdev->stats.tx_packets;
+			netdev->stats.tx_bytes += msg.can_dlc;
+		} else {
+			++netdev->stats.rx_packets;
+			netdev->stats.rx_bytes += msg.can_dlc;
+			softing_netdev_rx(netdev, &msg, ktime);
+		}
+	}
+	++cnt;
+	return cnt;
+}
+
+/*
+ * real interrupt handler
+ */
+static void softing_handler(unsigned long param)
+{
+	struct softing *card = (struct softing *)param;
+	struct net_device *netdev;
+	struct softing_priv *priv;
+	int j;
+	int offset;
+
+	spin_lock(&card->spin);
+	while (softing_handle_1(card) > 0)
+		++card->irq.svc_count;
+	spin_unlock(&card->spin);
+	/*resume tx queue's */
+	offset = card->tx.last_bus;
+	for (j = 0; j < ARRAY_SIZE(card->net); ++j) {
+		if (card->tx.pending >= TXMAX)
+			break;
+		netdev = card->net[(j + offset + 1) % card->pdat->nbus];
+		if (!netdev)
+			continue;
+		priv = netdev_priv(netdev);
+		if (!canif_is_active(netdev))
+			/* it makes no sense to wake dead busses */
+			continue;
+		if (priv->tx.pending >= TX_ECHO_SKB_MAX)
+			continue;
+		netif_wake_queue(netdev);
+	}
+}
+
+/*
+ * interrupt routines:
+ * schedule the 'real interrupt handler'
+ */
+static
+irqreturn_t softing_irq_new(int irq, void *dev_id)
+{
+	struct softing *card = (struct softing *)dev_id;
+	unsigned char ir;
+	ir = card->dpram.virt[0xe02];
+	card->dpram.virt[0xe02] = 0;
+	if (card->dpram.rx->rd == 0xffff) {
+		dev_alert(&card->pdev->dev, "I think the card is gone\n");
+		return IRQ_NONE;
+	}
+	if (ir == 1) {
+		tasklet_schedule(&card->irq.bh);
+		return IRQ_HANDLED;
+	} else if (ir == 0x10) {
+		return IRQ_NONE;
+	} else {
+		return IRQ_NONE;
+	}
+}
+
+static
+irqreturn_t softing_irq_old(int irq, void *dev_id)
+{
+	struct softing *card = (struct softing *)dev_id;
+	unsigned char irq_host;
+	irq_host = card->dpram.irq->to_host;
+	/* make sure we have a copy, before clearing the variable in DPRAM */
+	rmb();
+	card->dpram.irq->to_host = 0;
+	/* make sure we cleared it */
+	wmb();
+	if (card->dpram.rx->rd == 0xffff) {
+		dev_alert(&card->pdev->dev, "I think the card is gone\n");
+		return IRQ_NONE;
+	}
+	tasklet_schedule(&card->irq.bh);
+	return IRQ_HANDLED;
+}
+
+/*
+ * netdev/candev inter-operability
+ */
+static int softing_netdev_open(struct net_device *ndev)
+{
+	int ret;
+
+	/* check or determine and set bittime */
+	ret = open_candev(ndev);
+	if (ret)
+		goto failed;
+	ret = softing_startstop(ndev, 1);
+	if (ret)
+		goto failed;
+	return 0;
+failed:
+	return ret;
+}
+
+static int softing_netdev_stop(struct net_device *ndev)
+{
+	int ret;
+
+	netif_stop_queue(ndev);
+
+	/* softing cycle does close_candev() */
+	ret = softing_startstop(ndev, 0);
+	return ret;
+}
+
+static int softing_candev_set_mode(struct net_device *ndev, enum can_mode mode)
+{
+	int ret;
+
+	switch (mode) {
+	case CAN_MODE_START:
+		/* softing cycle does close_candev() */
+		ret = softing_startstop(ndev, 1);
+		return ret;
+	case CAN_MODE_STOP:
+	case CAN_MODE_SLEEP:
+		return -EOPNOTSUPP;
+	}
+	return 0;
+}
+
+/*
+ * Softing device management helpers
+ */
+int softing_enable_irq(struct softing *card, int enable)
+{
+	int ret;
+	if (!enable) {
+		if (card->irq.requested && card->irq.nr) {
+			free_irq(card->irq.nr, card);
+			card->irq.requested = 0;
+		}
+		return 0;
+	}
+	if (!card->irq.requested && (card->irq.nr)) {
+		ret = request_irq(card->irq.nr,
+				(card->pdat->generation >= 2)
+					? softing_irq_new : softing_irq_old,
+				IRQF_SHARED, dev_name(&card->pdev->dev), card);
+		if (ret) {
+			dev_alert(&card->pdev->dev, "%s, request_irq(%u) failed\n",
+				card->pdat->name, card->irq.nr);
+			return ret;
+		}
+		card->irq.requested = 1;
+	}
+	return 0;
+}
+
+static void softing_card_shutdown(struct softing *card)
+{
+	int fw_up = 0;
+	dev_dbg(&card->pdev->dev, "%s()\n", __func__);
+	if (mutex_lock_interruptible(&card->fw.lock))
+		/* return -ERESTARTSYS*/;
+	fw_up = card->fw.up;
+	card->fw.up = 0;
+
+	if (card->irq.requested && card->irq.nr) {
+		free_irq(card->irq.nr, card);
+		card->irq.requested = 0;
+	}
+	if (fw_up) {
+		if (card->pdat->enable_irq)
+			card->pdat->enable_irq(card->pdev, 0);
+		softing_set_reset_dpram(card);
+		if (card->pdat->reset)
+			card->pdat->reset(card->pdev, 1);
+	}
+	mutex_unlock(&card->fw.lock);
+	tasklet_kill(&card->irq.bh);
+}
+
+static int softing_card_boot(struct softing *card)
+{
+	unsigned char *lp;
+	static const unsigned char stream[] = {
+		0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, };
+	unsigned char back[sizeof(stream)];
+	dev_dbg(&card->pdev->dev, "%s()\n", __func__);
+
+	if (mutex_lock_interruptible(&card->fw.lock))
+		return -ERESTARTSYS;
+	if (card->fw.up) {
+		mutex_unlock(&card->fw.lock);
+		return 0;
+	}
+	/* reset board */
+	if (card->pdat->enable_irq)
+		card->pdat->enable_irq(card->pdev, 1);
+	/* boot card */
+	softing_set_reset_dpram(card);
+	if (card->pdat->reset)
+		card->pdat->reset(card->pdev, 1);
+	for (lp = card->dpram.virt; &lp[sizeof(stream)] <= card->dpram.end;
+		lp += sizeof(stream)) {
+
+		memcpy_toio(lp, stream, sizeof(stream));
+		/* flush IO cache */
+		mb();
+		memcpy_fromio(back, lp, sizeof(stream));
+
+		if (!memcmp(back, stream, sizeof(stream)))
+			continue;
+		/* memory is not equal */
+		dev_alert(&card->pdev->dev, "write to dpram failed at 0x%04lx\n",
+			(unsigned long)(lp - card->dpram.virt));
+		goto open_failed;
+	}
+	wmb();
+	/*load boot firmware */
+	if (softing_load_fw(card->pdat->boot.fw, card, card->dpram.virt,
+				 card->dpram.size,
+				 card->pdat->boot.offs -
+				 card->pdat->boot.addr))
+		goto open_failed;
+	/*load load firmware */
+	if (softing_load_fw(card->pdat->load.fw, card, card->dpram.virt,
+				 card->dpram.size,
+				 card->pdat->load.offs -
+				 card->pdat->load.addr))
+		goto open_failed;
+
+	if (card->pdat->reset)
+		card->pdat->reset(card->pdev, 0);
+	softing_clr_reset_dpram(card);
+	if (softing_bootloader_command(card, 0, "card boot"))
+		goto open_failed;
+	if (softing_load_app_fw(card->pdat->app.fw, card))
+		goto open_failed;
+	/*reset chip */
+	card->dpram.info->reset_rcv_fifo = 0;
+	card->dpram.info->reset = 1;
+	/*sync */
+	if (softing_fct_cmd(card, 99, 0x55, "sync-a"))
+		goto open_failed;
+	if (softing_fct_cmd(card, 99, 0xaa, "sync-a"))
+		goto open_failed;
+	/*reset chip */
+	if (softing_fct_cmd(card, 0, 0, "reset_chip"))
+		goto open_failed;
+	/*get_serial */
+	if (softing_fct_cmd(card, 43, 0, "get_serial_number"))
+		goto open_failed;
+	card->id.serial =
+		 (u16) card->dpram.fct->param[1] +
+		 (((u16) card->dpram.fct->param[2]) << 16);
+	/*get_version */
+	if (softing_fct_cmd(card, 12, 0, "get_version"))
+		goto open_failed;
+	card->id.fw = (u16) card->dpram.fct->param[1];
+	card->id.hw = (u16) card->dpram.fct->param[2];
+	card->id.lic = (u16) card->dpram.fct->param[3];
+	card->id.chip[0] = (u16) card->dpram.fct->param[4];
+	card->id.chip[1] = (u16) card->dpram.fct->param[5];
+
+	dev_info(&card->pdev->dev, "card booted, type %s, "
+			"serial %u, fw %u, hw %u, lic %u, chip (%u,%u)\n",
+		  card->pdat->name, card->id.serial, card->id.fw, card->id.hw,
+		  card->id.lic, card->id.chip[0], card->id.chip[1]);
+
+	card->fw.up = 1;
+	mutex_unlock(&card->fw.lock);
+	return 0;
+open_failed:
+	card->fw.up = 0;
+	if (card->pdat->enable_irq)
+		card->pdat->enable_irq(card->pdev, 0);
+	softing_set_reset_dpram(card);
+	if (card->pdat->reset)
+		card->pdat->reset(card->pdev, 1);
+	mutex_unlock(&card->fw.lock);
+	return -EIO;
+}
+
+/*
+ * netdev sysfs
+ */
+static ssize_t show_channel(struct device *dev
+		, struct device_attribute *attr, char *buf)
+{
+	struct net_device *ndev = to_net_dev(dev);
+	struct softing_priv *priv = netdev2softing(ndev);
+	return sprintf(buf, "%i\n", priv->index);
+}
+
+static ssize_t show_chip(struct device *dev
+		, struct device_attribute *attr, char *buf)
+{
+	struct net_device *ndev = to_net_dev(dev);
+	struct softing_priv *priv = netdev2softing(ndev);
+	return sprintf(buf, "%i\n", priv->chip);
+}
+
+static ssize_t show_output(struct device *dev
+		, struct device_attribute *attr, char *buf)
+{
+	struct net_device *ndev = to_net_dev(dev);
+	struct softing_priv *priv = netdev2softing(ndev);
+	return sprintf(buf, "0x%02x\n", priv->output);
+}
+
+static ssize_t store_output(struct device *dev
+		, struct device_attribute *attr
+		, const char *buf, size_t count)
+{
+	struct net_device *ndev = to_net_dev(dev);
+	struct softing_priv *priv = netdev2softing(ndev);
+	struct softing *card = priv->card;
+	unsigned long val;
+	int ret;
+
+	ret = strict_strtoul(buf, 0, &val);
+	if (ret < 0)
+		return ret;
+	val &= 0xFF;
+
+	ret = mutex_lock_interruptible(&card->fw.lock);
+	if (ret)
+		return -ERESTARTSYS;
+	if (netif_running(ndev)) {
+		mutex_unlock(&card->fw.lock);
+		return -EBUSY;
+	}
+	priv->output = val;
+	mutex_unlock(&card->fw.lock);
+	return count;
+}
+
+static const DEVICE_ATTR(channel, S_IRUGO, show_channel, 0);
+static const DEVICE_ATTR(chip, S_IRUGO, show_chip, 0);
+static const DEVICE_ATTR(output, S_IRUGO | S_IWUSR, show_output, store_output);
+
+static const struct attribute *const netdev_sysfs_attrs[] = {
+	&dev_attr_channel.attr,
+	&dev_attr_chip.attr,
+	&dev_attr_output.attr,
+	0,
+};
+static const struct attribute_group netdev_sysfs_group = {
+	.name  = 0,
+	.attrs = (struct attribute **)netdev_sysfs_attrs,
+};
+
+static const struct net_device_ops softing_netdev_ops = {
+	.ndo_open = softing_netdev_open,
+	.ndo_stop = softing_netdev_stop,
+	.ndo_start_xmit	= softing_netdev_start_xmit,
+};
+
+static const struct can_bittiming_const softing_btr_const = {
+	.tseg1_min = 1,
+	.tseg1_max = 16,
+	.tseg2_min = 1,
+	.tseg2_max = 8,
+	.sjw_max = 4, /* overruled */
+	.brp_min = 1,
+	.brp_max = 32, /* overruled */
+	.brp_inc = 1,
+};
+
+
+static struct net_device *softing_netdev_create(
+		struct softing *card, u16 chip_id)
+{
+	struct net_device *netdev;
+	struct softing_priv *priv;
+
+	netdev = alloc_candev(sizeof(*priv), TX_ECHO_SKB_MAX);
+	if (!netdev) {
+		dev_alert(&card->pdev->dev, "alloc_candev failed\n");
+		return 0;
+	}
+	priv = netdev_priv(netdev);
+	priv->netdev = netdev;
+	priv->card = card;
+	memcpy(&priv->btr_const, &softing_btr_const, sizeof(priv->btr_const));
+	priv->btr_const.brp_max = card->pdat->max_brp;
+	priv->btr_const.sjw_max = card->pdat->max_sjw;
+	priv->can.bittiming_const = &priv->btr_const;
+	priv->can.clock.freq = 8000000;
+	priv->chip = chip_id;
+	priv->output = softing_default_output(netdev);
+	SET_NETDEV_DEV(netdev, &card->pdev->dev);
+
+	netdev->flags |= IFF_ECHO;
+	netdev->netdev_ops	= &softing_netdev_ops;
+	priv->can.do_set_mode	= softing_candev_set_mode;
+	priv->can.ctrlmode_supported = CAN_CTRLMODE_3_SAMPLES |
+		CAN_CTRLMODE_BERR_REPORTING;
+
+	return netdev;
+}
+
+static int softing_netdev_register(struct net_device *netdev)
+{
+	int ret;
+
+	/*
+	 * provide bus-specific sysfs attributes _during_ the uevent
+	 */
+	netdev->sysfs_groups[0] = &netdev_sysfs_group;
+	ret = register_candev(netdev);
+	if (ret) {
+		dev_alert(&netdev->dev, "register failed\n");
+		return ret;
+	}
+	return 0;
+}
+
+static void softing_netdev_cleanup(struct net_device *netdev)
+{
+	unregister_candev(netdev);
+	free_candev(netdev);
+}
+
+/*
+ * sysfs for Platform device
+ */
+#define DEV_ATTR_RO(name, member) \
+static ssize_t show_##name(struct device *dev, \
+		struct device_attribute *attr, char *buf) \
+{ \
+	struct softing *card = platform_get_drvdata(to_platform_device(dev)); \
+	return sprintf(buf, "%u\n", card->member); \
+} \
+static DEVICE_ATTR(name, 0444, show_##name, 0)
+
+DEV_ATTR_RO(serial	, id.serial);
+DEV_ATTR_RO(firmware	, id.fw);
+DEV_ATTR_RO(hardware	, id.hw);
+DEV_ATTR_RO(license	, id.lic);
+DEV_ATTR_RO(freq	, id.freq);
+DEV_ATTR_RO(txpending	, tx.pending);
+
+static struct attribute *softing_pdev_attrs[] = {
+	&dev_attr_serial.attr,
+	&dev_attr_firmware.attr,
+	&dev_attr_hardware.attr,
+	&dev_attr_license.attr,
+	&dev_attr_freq.attr,
+	&dev_attr_txpending.attr,
+	0,
+};
+
+static const struct attribute_group softing_pdev_group = {
+	.attrs = softing_pdev_attrs,
+};
+
+/*
+ * platform driver
+ */
+static int softing_pdev_remove(struct platform_device *pdev)
+{
+	struct softing *card = platform_get_drvdata(pdev);
+	int j;
+
+	/*first, disable card*/
+	softing_card_shutdown(card);
+	tasklet_kill(&card->irq.bh);
+
+	for (j = 0; j < ARRAY_SIZE(card->net); ++j) {
+		if (!card->net[j])
+			continue;
+		softing_netdev_cleanup(card->net[j]);
+		card->net[j] = 0;
+	}
+	sysfs_remove_group(&pdev->dev.kobj, &softing_pdev_group);
+
+	iounmap(card->dpram.virt);
+	kfree(card);
+	return 0;
+}
+
+static int softing_pdev_probe(struct platform_device *pdev)
+{
+	const struct softing_platform_data *pdat = pdev->dev.platform_data;
+	struct softing *card;
+	struct net_device *netdev;
+	struct softing_priv *priv;
+	struct resource *pres;
+	int ret;
+	int j;
+
+	if (!pdat) {
+		dev_warn(&pdev->dev, "no platform data\n");
+		return -EINVAL;
+	}
+	if (pdat->nbus > ARRAY_SIZE(card->net)) {
+		dev_warn(&pdev->dev, "%u nets??\n", pdat->nbus);
+		return -EINVAL;
+	}
+
+	card = kzalloc(sizeof(*card), GFP_KERNEL);
+	if (!card)
+		return -ENOMEM;
+	card->pdat = pdat;
+	card->pdev = pdev;
+	platform_set_drvdata(pdev, card);
+	/* try_module_get(THIS_MODULE); */
+	mutex_init(&card->fw.lock);
+	spin_lock_init(&card->spin);
+	tasklet_init(&card->irq.bh, softing_handler, (unsigned long)card);
+
+	ret = -EINVAL;
+	pres = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+	if (!pres)
+		goto ioremap_failed;
+	card->dpram.phys = pres->start;
+	card->dpram.size = pres->end - pres->start + 1;
+	card->dpram.virt = ioremap_nocache(card->dpram.phys, card->dpram.size);
+	if (!card->dpram.virt) {
+		dev_alert(&card->pdev->dev, "dpram ioremap failed\n");
+		goto ioremap_failed;
+	}
+	card->dpram.end = &card->dpram.virt[card->dpram.size];
+	/*initialize_board */
+	card->dpram.rx = (struct softing_rx *)&card->dpram.virt[0x0000];
+	card->dpram.tx = (struct softing_tx *)&card->dpram.virt[0x0400];
+	card->dpram.fct = (struct softing_fct *)&card->dpram.virt[0x0300];
+	card->dpram.info = (struct softing_info *)&card->dpram.virt[0x0330];
+	card->dpram.command = (unsigned short *)&card->dpram.virt[0x07e0];
+	card->dpram.receipt = (unsigned short *)&card->dpram.virt[0x07f0];
+	card->dpram.irq = (struct softing_irq *)&card->dpram.virt[0x07fe];
+
+	pres = platform_get_resource(pdev, IORESOURCE_IRQ, 0);
+	if (pres)
+		card->irq.nr = pres->start;
+
+	/*reset card */
+	ret = -EIO;
+	if (softing_card_boot(card)) {
+		dev_alert(&pdev->dev, "failed to boot\n");
+		goto boot_failed;
+	}
+
+	/*only now, the chip's are known */
+	card->id.freq = card->pdat->freq * 1000000UL;
+
+	ret = sysfs_create_group(&pdev->dev.kobj, &softing_pdev_group);
+	if (ret < 0) {
+		dev_alert(&card->pdev->dev, "sysfs failed\n");
+		goto sysfs_failed;
+	}
+
+	ret = -ENOMEM;
+	for (j = 0; j < ARRAY_SIZE(card->net); ++j) {
+		card->net[j] = netdev =
+			softing_netdev_create(card, card->id.chip[j]);
+		if (!netdev) {
+			dev_alert(&pdev->dev, "failed to make can[%i]", j);
+			goto netdev_failed;
+		}
+		priv = netdev_priv(card->net[j]);
+		priv->index = j;
+		ret = softing_netdev_register(netdev);
+		if (ret) {
+			free_candev(netdev);
+			card->net[j] = 0;
+			dev_alert(&card->pdev->dev,
+				"failed to register can[%i]\n", j);
+			goto netdev_failed;
+		}
+	}
+	dev_info(&card->pdev->dev, "card initialised\n");
+	return 0;
+
+netdev_failed:
+	for (j = 0; j < ARRAY_SIZE(card->net); ++j) {
+		if (!card->net[j])
+			continue;
+		softing_netdev_cleanup(card->net[j]);
+	}
+	sysfs_remove_group(&pdev->dev.kobj, &softing_pdev_group);
+sysfs_failed:
+	softing_card_shutdown(card);
+boot_failed:
+	iounmap(card->dpram.virt);
+ioremap_failed:
+	tasklet_kill(&card->irq.bh);
+	kfree(card);
+	return ret;
+}
+
+static struct platform_driver softing_driver = {
+	.driver = {
+		.name = "softing",
+		.owner = THIS_MODULE,
+	},
+	.probe = softing_pdev_probe,
+	.remove = softing_pdev_remove,
+};
+
+MODULE_ALIAS("platform:softing");
+
+static int __init softing_start(void)
+{
+	return platform_driver_register(&softing_driver);
+}
+
+static void __exit softing_stop(void)
+{
+	platform_driver_unregister(&softing_driver);
+}
+
+module_init(softing_start);
+module_exit(softing_stop);
+
+MODULE_DESCRIPTION("socketcan softing driver");
+MODULE_AUTHOR("Kurt Van Dijck <kurt.van.dijck-/BeEPy95v10@public.gmane.org>");
+MODULE_LICENSE("GPL");
diff --git a/drivers/net/can/softing/softing_platform.h b/drivers/net/can/softing/softing_platform.h
new file mode 100644
index 0000000..9ff69a1
--- /dev/null
+++ b/drivers/net/can/softing/softing_platform.h
@@ -0,0 +1,38 @@
+
+#include <linux/platform_device.h>
+
+#ifndef _SOFTING_DEVICE_H_
+#define _SOFTING_DEVICE_H_
+
+/* softing firmware directory prefix */
+#define fw_dir "softing-4.6/"
+
+struct softing_platform_data {
+	unsigned int manf;
+	unsigned int prod;
+	/* generation
+	 * 1st with NEC or SJA1000
+	 * 8bit, exclusive interrupt, ...
+	 * 2nd only SJA11000
+	 * 16bit, shared interrupt
+	 */
+	int generation;
+	int nbus; /* # busses on device */
+	unsigned int freq; /* crystal in MHz */
+	unsigned int max_brp;
+	unsigned int max_sjw;
+	unsigned long dpram_size;
+	char name[32];
+	struct {
+		unsigned long offs;
+		unsigned long addr;
+		const char *fw;
+	} boot, load, app;
+	/* reset() function, bring pdev in or out of reset, depending on
+	   value */
+	int (*reset)(struct platform_device *pdev, int value);
+	int (*enable_irq)(struct platform_device *pdev, int value);
+};
+
+#endif
+
