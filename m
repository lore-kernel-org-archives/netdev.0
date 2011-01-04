From: Kurt Van Dijck <kurt.van.dijck-/BeEPy95v10@public.gmane.org>
Subject: [PATCH net-next-2.6 v2 1/2] can: add driver for Softing card
Date: Tue, 4 Jan 2011 16:07:59 +0100
Message-ID: <20110104150759.GB321@e-circ.dyndns.org>
References: <20110104150513.GA321@e-circ.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110104150513.GA321-MxZ6Iy/zr/UdbCeoMzGj59i2O/JbrIOy@public.gmane.org>
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
 drivers/net/can/softing/softing.h          |  193 ++++++
 drivers/net/can/softing/softing_fw.c       |  648 ++++++++++++++++++++
 drivers/net/can/softing/softing_main.c     |  903 ++++++++++++++++++++++++++++
 drivers/net/can/softing/softing_platform.h |   38 ++
 8 files changed, 1806 insertions(+), 0 deletions(-)

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
index 0000000..72d3adb
--- /dev/null
+++ b/drivers/net/can/softing/softing.h
@@ -0,0 +1,193 @@
+/*
+ * softing common interfaces
+ *
+ * by Kurt Van Dijck, 06-2008
+ */
+
+#include <linux/atomic.h>
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
+	spinlock_t spin; /* protect this structure & DPRAM access */
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
+		int svc_count;
+		unsigned int dpram_position;
+	} irq;
+	struct {
+		int pending;
+		int last_bus;
+		/*
+		 * keep the bus that last tx'd a message,
+		 * in order to let every netdev queue resume
+		 */
+	} tx;
+	__iomem uint8_t *dpram;
+	unsigned long dpram_phys;
+	unsigned long dpram_size;
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
+extern int softing_fct_cmd(struct softing *card, int16_t cmd, uint16_t vector,
+		const char *msg);
+
+extern int softing_bootloader_command(struct softing *card, int16_t cmd,
+		const char *msg);
+
+/* Load firmware after reset */
+extern int softing_load_fw(const char *file, struct softing *card,
+			__iomem uint8_t *virt, unsigned int size, int offset);
+
+/* Load final application firmware after bootloader */
+extern int softing_load_app_fw(const char *file, struct softing *card);
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
+#define DPRAM_RX		0x0000
+	#define DPRAM_RX_SIZE	32
+	#define DPRAM_RX_CNT	16
+#define DPRAM_RX_RD		0x0201	/* uint8_t */
+#define DPRAM_RX_WR		0x0205	/* uint8_t */
+#define DPRAM_RX_LOST		0x0207	/* uint8_t */
+
+#define DPRAM_FCT_PARAM		0x0300	/* int16_t [20] */
+#define DPRAM_FCT_RESULT	0x0328	/* int16_t */
+#define DPRAM_FCT_HOST		0x032b	/* uint16_t */
+
+#define DPRAM_INFO_BUSSTATE	0x0331	/* uint16_t */
+#define DPRAM_INFO_BUSSTATE2	0x0335	/* uint16_t */
+#define DPRAM_INFO_ERRSTATE	0x0339	/* uint16_t */
+#define DPRAM_INFO_ERRSTATE2	0x033d	/* uint16_t */
+#define DPRAM_RESET		0x0341	/* uint16_t */
+#define DPRAM_CLR_RECV_FIFO	0x0345	/* uint16_t */
+#define DPRAM_RESET_TIME	0x034d	/* uint16_t */
+#define DPRAM_TIME		0x0350	/* uint64_t */
+#define DPRAM_WR_START		0x0358	/* uint8_t */
+#define DPRAM_WR_END		0x0359	/* uint8_t */
+#define DPRAM_RESET_RX_FIFO	0x0361	/* uint16_t */
+#define DPRAM_RESET_TX_FIFO	0x0364	/* uint8_t */
+#define DPRAM_READ_FIFO_LEVEL	0x0365	/* uint8_t */
+#define DPRAM_RX_FIFO_LEVEL	0x0366	/* uint16_t */
+#define DPRAM_TX_FIFO_LEVEL	0x0366	/* uint16_t */
+
+#define DPRAM_TX		0x0400	/* uint16_t */
+	#define DPRAM_TX_SIZE	16
+	#define DPRAM_TX_CNT	32
+#define DPRAM_TX_RD		0x0601	/* uint8_t */
+#define DPRAM_TX_WR		0x0605	/* uint8_t */
+
+#define DPRAM_COMMAND		0x07e0	/* uint16_t */
+#define DPRAM_RECEIPT		0x07f0	/* uint16_t */
+#define DPRAM_IRQ_TOHOST	0x07fe	/* uint8_t */
+#define DPRAM_IRQ_TOCARD	0x07ff	/* uint8_t */
+
+#define DPRAM_V2_RESET		0x0e00	/* uint8_t */
+#define DPRAM_V2_IRQ_TOHOST	0x0e02	/* uint8_t */
+
+#define TXMAX	(DPRAM_TX_CNT - 1)
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
+/*
+ * some inline DPRAM acces function
+ * to prevent extra dependency between softing & softingcs
+ */
+/* reset DPRAM */
+static inline void softing_set_reset_dpram(struct softing *card)
+{
+	if (card->pdat->generation >= 2) {
+		uint8_t tmp;
+		spin_lock_bh(&card->spin);
+		tmp = ioread8(&card->dpram[DPRAM_V2_RESET]);
+		tmp &= ~1;
+		iowrite8(tmp, &card->dpram[DPRAM_V2_RESET]);
+		spin_unlock_bh(&card->spin);
+	}
+}
+
+static inline void softing_clr_reset_dpram(struct softing *card)
+{
+	if (card->pdat->generation >= 2) {
+		uint8_t tmp;
+		spin_lock_bh(&card->spin);
+		tmp = ioread8(&card->dpram[DPRAM_V2_RESET]);
+		tmp |= 1;
+		iowrite8(tmp, &card->dpram[DPRAM_V2_RESET]);
+		spin_unlock_bh(&card->spin);
+	}
+}
+
diff --git a/drivers/net/can/softing/softing_fw.c b/drivers/net/can/softing/softing_fw.c
new file mode 100644
index 0000000..03ed853
--- /dev/null
+++ b/drivers/net/can/softing/softing_fw.c
@@ -0,0 +1,648 @@
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
+int softing_fct_cmd(struct softing *card, int16_t cmd, uint16_t vector,
+		const char *msg)
+{
+	int ret;
+	unsigned long stamp;
+
+	if (vector == RES_OK)
+		vector = RES_NONE;
+	iowrite16(cmd, &card->dpram[DPRAM_FCT_PARAM]);
+	iowrite8(vector >> 8, &card->dpram[DPRAM_FCT_HOST + 1]);
+	iowrite8(vector, &card->dpram[DPRAM_FCT_HOST]);
+
+	/* be sure to flush this to the card */
+	wmb();
+	stamp = jiffies + 1 * HZ;
+	/* wait for card */
+	do {
+		/* DPRAM_FCT_HOST is _not_ aligned */
+		ret = ioread8(&card->dpram[DPRAM_FCT_HOST]) +
+			(ioread8(&card->dpram[DPRAM_FCT_HOST + 1]) << 8);
+		/* don't have any cached variables */
+		rmb();
+		if (ret == RES_OK) {
+			/* don't read return-value now */
+			ret = ioread16(&card->dpram[DPRAM_FCT_RESULT]);
+			if (ret)
+				dev_alert(&card->pdev->dev,
+					"%s returned %u\n", msg, ret);
+			return 0;
+		}
+		if (time_after(jiffies, stamp))
+			break;
+		/* process context => relax */
+		usleep_range(500, 10000);
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
+		/* make sure to return something not 0 */
+		return ret ?: 1;
+	}
+}
+
+int softing_bootloader_command(struct softing *card, int16_t cmd,
+		const char *msg)
+{
+	int ret;
+	unsigned long stamp;
+	iowrite16(RES_NONE, &card->dpram[DPRAM_RECEIPT]);
+	iowrite16(cmd, &card->dpram[DPRAM_COMMAND]);
+	/* be sure to flush this to the card */
+	wmb();
+	stamp = jiffies + 3 * HZ;
+	/* wait for card */
+	do {
+		ret = ioread16(&card->dpram[DPRAM_RECEIPT]);
+		/* don't have any cached variables */
+		rmb();
+		if (ret == RES_OK)
+			return 0;
+		if (time_after(jiffies, stamp))
+			break;
+		/* process context => relax */
+		usleep_range(500, 10000);
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
+			msg, cmd);
+		break;
+	default:
+		dev_alert(&card->pdev->dev, "%s: bad response from card: %i\n",
+			msg, ret);
+		break;
+	}
+	return ret ?: 1;
+}
+
+static int fw_parse(const uint8_t **pmem, uint16_t *ptype, uint32_t *paddr,
+		uint16_t *plen, const uint8_t **pdat)
+{
+	uint16_t checksum[2];
+	const uint8_t *mem;
+	const uint8_t *end;
+
+	mem = *pmem;
+	*ptype = le16_to_cpup((void *)&mem[0]);
+	*paddr = le32_to_cpup((void *)&mem[2]);
+	*plen = le16_to_cpup((void *)&mem[6]);
+	*pdat = &mem[8];
+	/* verify checksum */
+	end = &mem[8 + *plen];
+	checksum[0] = le16_to_cpup((void *)end);
+	for (checksum[1] = 0; mem < end; ++mem)
+		checksum[1] += *mem;
+	if (checksum[0] != checksum[1])
+		return -EINVAL;
+	/* increment */
+	*pmem += 10 + *plen;
+	return 0;
+}
+
+int softing_load_fw(const char *file, struct softing *card,
+			__iomem uint8_t *dpram, unsigned int size, int offset)
+{
+	const struct firmware *fw;
+	int ret, ok = 0;
+	const uint8_t *mem, *end, *dat;
+	uint16_t type, len;
+	uint32_t addr;
+	uint8_t buf[1024];
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
+	ret = fw_parse(&mem, &type, &addr, &len, &dat);
+	if (ret < 0)
+		goto fw_end;
+	if (type != 0xffff) {
+		dev_alert(&card->pdev->dev, "firware starts with type 0x%04x\n",
+			type);
+		goto fw_end;
+	}
+	if (strncmp("Structured Binary Format, Softing GmbH" , dat, len)) {
+		dev_info(&card->pdev->dev, "firware string '%.*s'\n", len, dat);
+		goto fw_end;
+	}
+	ok |= 1;
+	/* ok, we had a header */
+	while (mem < end) {
+		ret = fw_parse(&mem, &type, &addr, &len, &dat);
+		if (ret)
+			break;
+		if (type == 3) {
+			/* start address */
+			ok |= 2;
+			continue;
+		} else if (type == 1) {
+			/* eof */
+			ok |= 4;
+			goto fw_end;
+		} else if (type != 0) {
+			dev_alert(&card->pdev->dev,
+					"unknown record type 0x%04x\n", type);
+			break;
+		}
+
+		if ((addr + len + offset) > size) {
+			dev_alert(&card->pdev->dev,
+				"firmware out of range (0x%08x / 0x%08x)\n",
+				(addr + len + offset), size);
+			goto fw_end;
+		}
+		memcpy_toio(&dpram[addr + offset], dat, len);
+		/* be sure to flush caches from IO space */
+		mb();
+		if (len > sizeof(buf)) {
+			dev_info(&card->pdev->dev,
+				"record too big for verify (%u)\n", len);
+			continue;
+		}
+		/* verify record data */
+		memcpy_fromio(buf, &dpram[addr + offset], len);
+		if (!memcmp(buf, dat, len))
+			/* is ok */
+			continue;
+		dev_alert(&card->pdev->dev, "0x%08x:0x%03x at 0x%u failed\n",
+				addr, len, addr + offset);
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
+	const uint8_t *mem, *end, *dat;
+	int ret, ok = 0, j;
+	uint16_t type, len;
+	uint32_t addr, start_addr = 0;
+	unsigned int sum, rx_sum;
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
+	ret = fw_parse(&mem, &type, &addr, &len, &dat);
+	if (ret)
+		goto fw_end;
+	if (type != 0xffff) {
+		dev_alert(&card->pdev->dev, "firware starts with type 0x%04x\n",
+			type);
+		goto fw_end;
+	}
+	if (strncmp("Structured Binary Format, Softing GmbH", dat, len)) {
+		dev_alert(&card->pdev->dev, "firware string '%.*s' fault\n",
+				len, dat);
+		goto fw_end;
+	}
+	ok |= 1;
+	/* ok, we had a header */
+	while (mem < end) {
+		ret = fw_parse(&mem, &type, &addr, &len, &dat);
+		if (ret)
+			break;
+
+		if (type == 3) {
+			/* start address */
+			start_addr = addr;
+			ok |= 2;
+			continue;
+		} else if (type == 1) {
+			/* eof */
+			ok |= 4;
+			goto fw_end;
+		} else if (type != 0) {
+			dev_alert(&card->pdev->dev,
+					"unknown record type 0x%04x\n", type);
+			break;
+		}
+
+		/* regualar data */
+		for (sum = 0, j = 0; j < len; ++j)
+			sum += dat[j];
+		/* work in 16bit (target) */
+		sum &= 0xffff;
+
+		memcpy_toio(&card->dpram[card->pdat->app.offs], dat, len);
+		iowrite32(card->pdat->app.offs + card->pdat->app.addr,
+				&card->dpram[DPRAM_COMMAND + 2]);
+		iowrite32(addr, &card->dpram[DPRAM_COMMAND + 6]);
+		iowrite16(len, &card->dpram[DPRAM_COMMAND + 10]);
+		iowrite8(1, &card->dpram[DPRAM_COMMAND + 12]);
+		if (softing_bootloader_command(card, 1, "loading app."))
+			goto fw_end;
+		/* verify checksum */
+		rx_sum = ioread16(&card->dpram[DPRAM_RECEIPT + 2]);
+		if (rx_sum != sum) {
+			dev_alert(&card->pdev->dev, "SRAM seems to be damaged"
+				", wanted 0x%04x, got 0x%04x\n", sum, rx_sum);
+			goto fw_end;
+		}
+	}
+fw_end:
+	release_firmware(fw);
+	if (ok != 7)
+		goto fw_failed;
+	/* got start, start_addr, & eof */
+	iowrite32(start_addr, &card->dpram[DPRAM_COMMAND + 2]);
+	iowrite8(1, &card->dpram[DPRAM_COMMAND + 6]);
+	if (softing_bootloader_command(card, 3, "start app."))
+		goto fw_failed;
+	dev_info(&card->pdev->dev, "firmware %s up\n", file);
+	return 0;
+fw_failed:
+	dev_info(&card->pdev->dev, "firmware %s failed\n", file);
+	return ret ?: -EINVAL;
+}
+
+static int softing_reset_chip(struct softing *card)
+{
+	do {
+		/* reset chip */
+		iowrite8(0, &card->dpram[DPRAM_RESET_RX_FIFO]);
+		iowrite8(0, &card->dpram[DPRAM_RESET_RX_FIFO+1]);
+		iowrite8(1, &card->dpram[DPRAM_RESET]);
+		iowrite8(0, &card->dpram[DPRAM_RESET+1]);
+
+		if (!softing_fct_cmd(card, 0, 0, "reset_chip"))
+			break;
+		if (signal_pending(current))
+			goto failed;
+		/* sync */
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
+	const struct can_bittiming *bt;
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
+		/* init chip 1 */
+		bt = &priv->can.bittiming;
+		iowrite16(bt->brp, &card->dpram[DPRAM_FCT_PARAM + 2]);
+		iowrite16(bt->sjw, &card->dpram[DPRAM_FCT_PARAM + 4]);
+		iowrite16(bt->phase_seg1 + bt->prop_seg,
+				&card->dpram[DPRAM_FCT_PARAM + 6]);
+		iowrite16(bt->phase_seg2, &card->dpram[DPRAM_FCT_PARAM + 8]);
+		iowrite16((priv->can.ctrlmode & CAN_CTRLMODE_3_SAMPLES) ? 1 : 0,
+				&card->dpram[DPRAM_FCT_PARAM + 10]);
+		if (softing_fct_cmd(card, 1, 0, "initialize_chip[0]"))
+			goto failed;
+		/* set mode */
+		iowrite16(0, &card->dpram[DPRAM_FCT_PARAM + 2]);
+		iowrite16(0, &card->dpram[DPRAM_FCT_PARAM + 4]);
+		if (softing_fct_cmd(card, 3, 0, "set_mode[0]"))
+			goto failed;
+		/* set filter */
+		/* 11bit id & mask */
+		iowrite16(0x0000, &card->dpram[DPRAM_FCT_PARAM + 2]);
+		iowrite16(0x07ff, &card->dpram[DPRAM_FCT_PARAM + 4]);
+		/* 29bit id.lo & mask.lo & id.hi & mask.hi */
+		iowrite16(0x0000, &card->dpram[DPRAM_FCT_PARAM + 6]);
+		iowrite16(0xffff, &card->dpram[DPRAM_FCT_PARAM + 8]);
+		iowrite16(0x0000, &card->dpram[DPRAM_FCT_PARAM + 10]);
+		iowrite16(0x1fff, &card->dpram[DPRAM_FCT_PARAM + 12]);
+		if (softing_fct_cmd(card, 7, 0, "set_filter[0]"))
+			goto failed;
+		/* set output control */
+		iowrite16(priv->output, &card->dpram[DPRAM_FCT_PARAM + 2]);
+		if (softing_fct_cmd(card, 5, 0, "set_output[0]"))
+			goto failed;
+	}
+	if (mask_start & 2) {
+		netdev = card->net[1];
+		priv = netdev_priv(netdev);
+		error_reporting += softing_error_reporting(netdev);
+		/* init chip2 */
+		bt = &priv->can.bittiming;
+		iowrite16(bt->brp, &card->dpram[DPRAM_FCT_PARAM + 2]);
+		iowrite16(bt->sjw, &card->dpram[DPRAM_FCT_PARAM + 4]);
+		iowrite16(bt->phase_seg1 + bt->prop_seg,
+				&card->dpram[DPRAM_FCT_PARAM + 6]);
+		iowrite16(bt->phase_seg2, &card->dpram[DPRAM_FCT_PARAM + 8]);
+		iowrite16((priv->can.ctrlmode & CAN_CTRLMODE_3_SAMPLES) ? 1 : 0,
+				&card->dpram[DPRAM_FCT_PARAM + 10]);
+		if (softing_fct_cmd(card, 2, 0, "initialize_chip[1]"))
+			goto failed;
+		/* set mode2 */
+		iowrite16(0, &card->dpram[DPRAM_FCT_PARAM + 2]);
+		iowrite16(0, &card->dpram[DPRAM_FCT_PARAM + 4]);
+		if (softing_fct_cmd(card, 4, 0, "set_mode[1]"))
+			goto failed;
+		/* set filter2 */
+		/* 11bit id & mask */
+		iowrite16(0x0000, &card->dpram[DPRAM_FCT_PARAM + 2]);
+		iowrite16(0x07ff, &card->dpram[DPRAM_FCT_PARAM + 4]);
+		/* 29bit id.lo & mask.lo & id.hi & mask.hi */
+		iowrite16(0x0000, &card->dpram[DPRAM_FCT_PARAM + 6]);
+		iowrite16(0xffff, &card->dpram[DPRAM_FCT_PARAM + 8]);
+		iowrite16(0x0000, &card->dpram[DPRAM_FCT_PARAM + 10]);
+		iowrite16(0x1fff, &card->dpram[DPRAM_FCT_PARAM + 12]);
+		if (softing_fct_cmd(card, 8, 0, "set_filter[1]"))
+			goto failed;
+		/* set output control2 */
+		iowrite16(priv->output, &card->dpram[DPRAM_FCT_PARAM + 2]);
+		if (softing_fct_cmd(card, 6, 0, "set_output[1]"))
+			goto failed;
+	}
+	/* enable_error_frame */
+	/*
+	if (error_reporting) {
+		if (softing_fct_cmd(card, 51, 0, "enable_error_frame"))
+			goto failed;
+	}
+	*/
+	/* initialize interface */
+	iowrite16(1, &card->dpram[DPRAM_FCT_PARAM + 2]);
+	iowrite16(1, &card->dpram[DPRAM_FCT_PARAM + 4]);
+	iowrite16(1, &card->dpram[DPRAM_FCT_PARAM + 6]);
+	iowrite16(1, &card->dpram[DPRAM_FCT_PARAM + 8]);
+	iowrite16(1, &card->dpram[DPRAM_FCT_PARAM + 10]);
+	iowrite16(1, &card->dpram[DPRAM_FCT_PARAM + 12]);
+	iowrite16(1, &card->dpram[DPRAM_FCT_PARAM + 14]);
+	iowrite16(1, &card->dpram[DPRAM_FCT_PARAM + 16]);
+	iowrite16(1, &card->dpram[DPRAM_FCT_PARAM + 18]);
+	iowrite16(1, &card->dpram[DPRAM_FCT_PARAM + 20]);
+	if (softing_fct_cmd(card, 17, 0, "initialize_interface"))
+		goto failed;
+	/* enable_fifo */
+	if (softing_fct_cmd(card, 36, 0, "enable_fifo"))
+		goto failed;
+	/* enable fifo tx ack */
+	if (softing_fct_cmd(card, 13, 0, "fifo_tx_ack[0]"))
+		goto failed;
+	/* enable fifo tx ack2 */
+	if (softing_fct_cmd(card, 14, 0, "fifo_tx_ack[1]"))
+		goto failed;
+	/* enable timestamps */
+	/* is default, no code found */
+	/* start_chip */
+	if (softing_fct_cmd(card, 11, 0, "start_chip"))
+		goto failed;
+	iowrite8(0, &card->dpram[DPRAM_INFO_BUSSTATE]);
+	iowrite8(0, &card->dpram[DPRAM_INFO_BUSSTATE2]);
+	dev_info(&card->pdev->dev, "%s up\n", __func__);
+	if (card->pdat->generation < 2) {
+		iowrite8(0, &card->dpram[DPRAM_V2_IRQ_TOHOST]);
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
index 0000000..4f74075
--- /dev/null
+++ b/drivers/net/can/softing/softing_main.c
@@ -0,0 +1,903 @@
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
+	uint8_t *ptr;
+	uint8_t fifo_wr, fifo_rd;
+	struct can_frame *cf = (struct can_frame *)skb->data;
+	uint8_t buf[DPRAM_TX_SIZE];
+
+	if (can_dropped_invalid_skb(dev, skb))
+		return NETDEV_TX_OK;
+
+	spin_lock(&card->spin);
+
+	ret = NETDEV_TX_BUSY;
+	if (!card->fw.up)
+		goto xmit_done;
+	if (card->tx.pending >= TXMAX)
+		goto xmit_done;
+	if (priv->tx.pending >= TX_ECHO_SKB_MAX)
+		goto xmit_done;
+	fifo_wr = ioread8(&card->dpram[DPRAM_TX_WR]);
+	fifo_rd = ioread8(&card->dpram[DPRAM_TX_RD]);
+	if (fifo_wr == fifo_rd)
+		/* fifo full */
+		goto xmit_done;
+	memset(buf, 0, sizeof(buf));
+	ptr = buf;
+	*ptr = CMD_TX;
+	if (cf->can_id & CAN_RTR_FLAG)
+		*ptr |= CMD_RTR;
+	if (cf->can_id & CAN_EFF_FLAG)
+		*ptr |= CMD_XTD;
+	if (priv->index)
+		*ptr |= CMD_BUS2;
+	++ptr;
+	*ptr++ = cf->can_dlc;
+	*ptr++ = (cf->can_id >> 0);
+	*ptr++ = (cf->can_id >> 8);
+	if (cf->can_id & CAN_EFF_FLAG) {
+		*ptr++ = (cf->can_id >> 16);
+		*ptr++ = (cf->can_id >> 24);
+	} else {
+		/* increment 1, not 2 as you might think */
+		ptr += 1;
+	}
+	if (!(cf->can_id & CAN_RTR_FLAG))
+		memcpy(ptr, &cf->data[0], cf->can_dlc);
+	memcpy_toio(&card->dpram[DPRAM_TX + DPRAM_TX_SIZE * fifo_wr],
+			buf, DPRAM_TX_SIZE);
+	if (++fifo_wr >= DPRAM_TX_CNT)
+		fifo_wr = 0;
+	iowrite8(fifo_wr, &card->dpram[DPRAM_TX_WR]);
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
+	spin_unlock(&card->spin);
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
+	int lost_msg;
+	uint8_t fifo_rd, fifo_wr;
+	unsigned int cnt = 0;
+	uint8_t *ptr;
+	u32 tmp;
+	u8 cmd;
+	uint8_t buf[DPRAM_RX_SIZE];
+
+	memset(&msg, 0, sizeof(msg));
+	/* test for lost msgs */
+	lost_msg = ioread8(&card->dpram[DPRAM_RX_LOST]);
+	if (lost_msg) {
+		/* reset condition */
+		iowrite8(0, &card->dpram[DPRAM_RX_LOST]);
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
+	fifo_rd = ioread8(&card->dpram[DPRAM_RX_RD]);
+	fifo_wr = ioread8(&card->dpram[DPRAM_RX_WR]);
+
+	if (++fifo_rd >= DPRAM_RX_CNT)
+		fifo_rd = 0;
+	if (fifo_wr == fifo_rd)
+		return cnt;
+
+	memcpy_fromio(buf, &card->dpram[DPRAM_RX + DPRAM_RX_SIZE*fifo_rd],
+			DPRAM_RX_SIZE);
+	mb();
+	/* trigger dual port RAM */
+	iowrite8(fifo_rd, &card->dpram[DPRAM_RX_RD]);
+
+	ptr = buf;
+	cmd = *ptr++;
+	if (cmd == 0xff) {
+		/* not quite usefull, probably the card has got out */
+		dev_alert(&card->pdev->dev, "got cmd 0x%02x,"
+			" I suspect the card is lost\n", cmd);
+		return 0;
+	}
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
+		/* update DPRAM */
+		iowrite8(state, &card->dpram[priv->index ?
+				DPRAM_INFO_BUSSTATE2 : DPRAM_INFO_BUSSTATE]);
+		/* timestamp */
+		tmp = le32_to_cpup((void *)ptr);
+		ptr += 4;
+		ktime = softing_raw2ktime(card, tmp);
+
+		++priv->can.can_stats.bus_error;
+		++netdev->stats.rx_errors;
+		/* update internal status */
+		if (can_state != priv->can.state) {
+			priv->can.state = can_state;
+			if (can_state == CAN_STATE_ERROR_PASSIVE)
+				++priv->can.can_stats.error_passive;
+			if (can_state == CAN_STATE_BUS_OFF) {
+				/* this calls can_close_cleanup() */
+				can_bus_off(netdev);
+				netif_stop_queue(netdev);
+			}
+			/* trigger socketcan */
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
+			msg.can_id |= le32_to_cpup((void *)ptr);
+			ptr += 4;
+		} else {
+			msg.can_id |= le16_to_cpup((void *)ptr);
+			ptr += 2;
+		}
+		/* timestamp */
+		tmp = le32_to_cpup((void *)ptr);
+		ptr += 4;
+		ktime = softing_raw2ktime(card, tmp);
+		if (!(msg.can_id & CAN_RTR_FLAG))
+			memcpy(&msg.data[0], ptr, 8);
+		ptr += 8;
+		/* update socket */
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
+static irqreturn_t softing_irq_thread(int irq, void *dev_id)
+{
+	struct softing *card = (struct softing *)dev_id;
+	struct net_device *netdev;
+	struct softing_priv *priv;
+	int j, offset, work_done;
+
+	work_done = 0;
+	spin_lock_bh(&card->spin);
+	while (softing_handle_1(card) > 0) {
+		++card->irq.svc_count;
+		++work_done;
+	}
+	spin_unlock_bh(&card->spin);
+	/* resume tx queue's */
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
+		++work_done;
+		netif_wake_queue(netdev);
+	}
+	return work_done ? IRQ_HANDLED : IRQ_NONE;
+}
+
+/*
+ * interrupt routines:
+ * schedule the 'real interrupt handler'
+ */
+static
+irqreturn_t softing_irq_v2(int irq, void *dev_id)
+{
+	struct softing *card = (struct softing *)dev_id;
+	uint8_t ir;
+
+	ir = ioread8(&card->dpram[DPRAM_V2_IRQ_TOHOST]);
+	iowrite8(0, &card->dpram[DPRAM_V2_IRQ_TOHOST]);
+	return (1 == ir) ? IRQ_WAKE_THREAD : IRQ_NONE;
+}
+
+static
+irqreturn_t softing_irq_v1(int irq, void *dev_id)
+{
+	struct softing *card = (struct softing *)dev_id;
+	uint8_t ir;
+
+	ir = ioread8(&card->dpram[DPRAM_IRQ_TOHOST]);
+	iowrite8(0, &card->dpram[DPRAM_IRQ_TOHOST]);
+	return ir ? IRQ_WAKE_THREAD : IRQ_NONE;
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
+		/* softing_startstop does close_candev() */
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
+		ret = request_threaded_irq(card->irq.nr,
+				(card->pdat->generation >= 2)
+					? softing_irq_v2 : softing_irq_v1,
+				softing_irq_thread, IRQF_SHARED,
+				dev_name(&card->pdev->dev), card);
+		if (ret) {
+			dev_alert(&card->pdev->dev,
+					"request_threaded_irq(%u) failed\n",
+					card->irq.nr);
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
+}
+
+static int softing_card_boot(struct softing *card)
+{
+	int j;
+	static const uint8_t stream[] = {
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
+	for (j = 0; (j + sizeof(stream)) < card->dpram_size;
+			j += sizeof(stream)) {
+
+		memcpy_toio(&card->dpram[j], stream, sizeof(stream));
+		/* flush IO cache */
+		mb();
+		memcpy_fromio(back, &card->dpram[j], sizeof(stream));
+
+		if (!memcmp(back, stream, sizeof(stream)))
+			continue;
+		/* memory is not equal */
+		dev_alert(&card->pdev->dev, "dpram failed at 0x%04x\n", j);
+		goto open_failed;
+	}
+	wmb();
+	/* load boot firmware */
+	if (softing_load_fw(card->pdat->boot.fw, card, card->dpram,
+				 card->dpram_size,
+				 card->pdat->boot.offs -
+				 card->pdat->boot.addr))
+		goto open_failed;
+	/* load loader firmware */
+	if (softing_load_fw(card->pdat->load.fw, card, card->dpram,
+				 card->dpram_size,
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
+	/* reset chip */
+	iowrite8(0, &card->dpram[DPRAM_RESET_RX_FIFO]);
+	iowrite8(0, &card->dpram[DPRAM_RESET_RX_FIFO+1]);
+	iowrite8(1, &card->dpram[DPRAM_RESET]);
+	iowrite8(0, &card->dpram[DPRAM_RESET+1]);
+	/* sync */
+	if (softing_fct_cmd(card, 99, 0x55, "sync-a"))
+		goto open_failed;
+	if (softing_fct_cmd(card, 99, 0xaa, "sync-a"))
+		goto open_failed;
+	/* reset chip */
+	if (softing_fct_cmd(card, 0, 0, "reset_chip"))
+		goto open_failed;
+	/* get_serial */
+	if (softing_fct_cmd(card, 43, 0, "get_serial_number"))
+		goto open_failed;
+	card->id.serial = ioread32(&card->dpram[DPRAM_FCT_PARAM]);
+	/* get_version */
+	if (softing_fct_cmd(card, 12, 0, "get_version"))
+		goto open_failed;
+	card->id.fw = ioread16(&card->dpram[DPRAM_FCT_PARAM + 2]);
+	card->id.hw = ioread16(&card->dpram[DPRAM_FCT_PARAM + 4]);
+	card->id.lic = ioread16(&card->dpram[DPRAM_FCT_PARAM + 6]);
+	card->id.chip[0] = ioread16(&card->dpram[DPRAM_FCT_PARAM + 8]);
+	card->id.chip[1] = ioread16(&card->dpram[DPRAM_FCT_PARAM + 10]);
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
+static const DEVICE_ATTR(channel, S_IRUGO, show_channel, NULL);
+static const DEVICE_ATTR(chip, S_IRUGO, show_chip, NULL);
+static const DEVICE_ATTR(output, S_IRUGO | S_IWUSR, show_output, store_output);
+
+static const struct attribute *const netdev_sysfs_attrs[] = {
+	&dev_attr_channel.attr,
+	&dev_attr_chip.attr,
+	&dev_attr_output.attr,
+	NULL,
+};
+static const struct attribute_group netdev_sysfs_group = {
+	.name  = NULL,
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
+		return NULL;
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
+	priv->can.ctrlmode_supported =
+		CAN_CTRLMODE_3_SAMPLES;/* | CAN_CTRLMODE_BERR_REPORTING */;
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
+static DEVICE_ATTR(name, 0444, show_##name, NULL)
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
+	NULL,
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
+	/* first, disable card*/
+	softing_card_shutdown(card);
+
+	for (j = 0; j < ARRAY_SIZE(card->net); ++j) {
+		if (!card->net[j])
+			continue;
+		softing_netdev_cleanup(card->net[j]);
+		card->net[j] = NULL;
+	}
+	sysfs_remove_group(&pdev->dev.kobj, &softing_pdev_group);
+
+	iounmap(card->dpram);
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
+
+	ret = -EINVAL;
+	pres = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+	if (!pres)
+		goto platform_resource_failed;;
+	card->dpram_phys = pres->start;
+	card->dpram_size = pres->end - pres->start + 1;
+	card->dpram = ioremap_nocache(card->dpram_phys, card->dpram_size);
+	if (!card->dpram) {
+		dev_alert(&card->pdev->dev, "dpram ioremap failed\n");
+		goto ioremap_failed;
+	}
+
+	pres = platform_get_resource(pdev, IORESOURCE_IRQ, 0);
+	if (pres)
+		card->irq.nr = pres->start;
+
+	/* reset card */
+	ret = -EIO;
+	if (softing_card_boot(card)) {
+		dev_alert(&pdev->dev, "failed to boot\n");
+		goto boot_failed;
+	}
+
+	/* only now, the chip's are known */
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
+			card->net[j] = NULL;
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
+	iounmap(card->dpram);
+ioremap_failed:
+platform_resource_failed:
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
+MODULE_DESCRIPTION("Softing DPRAM CAN driver");
+MODULE_AUTHOR("Kurt Van Dijck <kurt.van.dijck-/BeEPy95v10@public.gmane.org>");
+MODULE_LICENSE("GPL");
diff --git a/drivers/net/can/softing/softing_platform.h b/drivers/net/can/softing/softing_platform.h
new file mode 100644
index 0000000..678df36
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
+	 * 2nd only SJA1000
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
