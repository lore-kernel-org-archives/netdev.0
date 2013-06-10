From: Giancarlo Asnaghi <giancarlo.asnaghi@st.com>
Subject: [PATCH 2/3] drivers/net/most: add MediaLB driver for sta2x11
Date: Mon, 10 Jun 2013 14:52:36 +0200
Message-ID: <f532cd60414d5b53d7d7766696f3aae81c33c66f.1370856733.git.asnaghi@st.com>
References: <cover.1370856733.git.asnaghi@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Alessandro Rubini <rubini@gnudd.com>,
	Federico Vaga <federico.vaga@gmail.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <cover.1370856733.git.asnaghi@st.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

See the lkml message "[PATCH 0/3] MOST network protocol" sent on Jun
10th 2013 about this code and the missing "Signed-off" lines.

---
 drivers/net/Makefile          |    1 +
 drivers/net/most/Kconfig      |   10 +
 drivers/net/most/Makefile     |    6 +
 drivers/net/most/sta2x11mlb.c | 1181 +++++++++++++++++++++++++++++++++++++++++
 drivers/net/most/sta2x11mlb.h |  275 ++++++++++
 5 files changed, 1473 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/most/Kconfig
 create mode 100644 drivers/net/most/Makefile
 create mode 100644 drivers/net/most/sta2x11mlb.c
 create mode 100644 drivers/net/most/sta2x11mlb.h

diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index ef3d090..0604d16 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -37,6 +37,7 @@ obj-$(CONFIG_FDDI) += fddi/
 obj-$(CONFIG_HIPPI) += hippi/
 obj-$(CONFIG_HAMRADIO) += hamradio/
 obj-$(CONFIG_IRDA) += irda/
+obj-$(CONFIG_MOST) += most/
 obj-$(CONFIG_PLIP) += plip/
 obj-$(CONFIG_PPP) += ppp/
 obj-$(CONFIG_PPP_ASYNC) += ppp/
diff --git a/drivers/net/most/Kconfig b/drivers/net/most/Kconfig
new file mode 100644
index 0000000..cc64e4e
--- /dev/null
+++ b/drivers/net/most/Kconfig
@@ -0,0 +1,10 @@
+menu "MOST Device Drivers"
+	depends on MOST
+
+config MOST_STA2X11_MLB
+	tristate "The STA2X11 MOST block"
+	depends on MOST && STA2X11
+	---help---
+	  Adds support for MLB on the sta2x11
+
+endmenu
diff --git a/drivers/net/most/Makefile b/drivers/net/most/Makefile
new file mode 100644
index 0000000..8729533
--- /dev/null
+++ b/drivers/net/most/Makefile
@@ -0,0 +1,6 @@
+#
+#  Makefile for the Linux Media Oriented Systems Transport drivers.
+#
+
+obj-$(CONFIG_MOST_TIMB_MLB)	+= timbmlb.o
+obj-$(CONFIG_MOST_STA2X11_MLB)	+= sta2x11mlb.o
diff --git a/drivers/net/most/sta2x11mlb.c b/drivers/net/most/sta2x11mlb.c
new file mode 100644
index 0000000..2e4b6b2
--- /dev/null
+++ b/drivers/net/most/sta2x11mlb.c
@@ -0,0 +1,1181 @@
+/*
+ * sta2x11mlb.c Driver for the sta2x11 MLB block
+ * Copyright (c) 2010-2011 Wind River
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
+ */
+
+#include <linux/module.h>
+#include <linux/pci.h>
+#include <linux/interrupt.h>
+#include <linux/debugfs.h>
+#include <linux/platform_device.h>
+#include <linux/mfd/sta2x11-mfd.h>
+#include <net/most/most.h>
+
+#include "sta2x11mlb.h"
+
+
+static int ehcid;
+module_param(ehcid, int, S_IRUGO);
+
+static int speed = DCCR_MCS_512FS;
+module_param(speed, int, S_IRUGO);
+
+static int syncc = 8;
+module_param(syncc, int, S_IRUGO);
+
+static int syncb = 64;
+module_param(syncb, int, S_IRUGO);
+
+#define debug_reg(_reg)			\
+{					\
+	.name	= __stringify(_reg),	\
+	.offset	= _reg,			\
+}
+
+static const struct debugfs_reg32 sta2x11_mlb_regs[] = {
+		debug_reg(MLB_DCCR),
+		debug_reg(MLB_SSCR),
+		debug_reg(MLB_SMCR),
+		debug_reg(MLB_VCCR),
+		debug_reg(MLB_SBCR),
+		debug_reg(MLB_ABCR),
+		debug_reg(MLB_CBCR),
+		debug_reg(MLB_IBCR),
+		debug_reg(MLB_CICR),
+
+		debug_reg(MLB_CECR(0)),
+		debug_reg(MLB_CSCR(0)),
+		debug_reg(MLB_CNBCR(0)),
+		debug_reg(MLB_LCBCR(0)),
+
+		debug_reg(MLB_CECR(1)),
+		debug_reg(MLB_CSCR(1)),
+		debug_reg(MLB_CNBCR(1)),
+		debug_reg(MLB_LCBCR(1)),
+
+		debug_reg(MLB_CECR(2)),
+		debug_reg(MLB_CSCR(2)),
+		debug_reg(MLB_CNBCR(2)),
+		debug_reg(MLB_LCBCR(2)),
+
+		debug_reg(MLB_CECR(3)),
+		debug_reg(MLB_CSCR(3)),
+		debug_reg(MLB_CNBCR(3)),
+		debug_reg(MLB_LCBCR(3)),
+};
+
+/**
+ * sta2x11_mlb_write - write directly to hardware register
+ * @dev: structure containing hardware address
+ * @reg: register offset
+ * @val: value to be written
+ *
+ * write a 32 bit value into a register
+ */
+static void sta2x11_mlb_write(struct sta2x11_mlb *dev, u32 reg, u32 val)
+{
+	writel(val, dev->base + reg);
+}
+
+/**
+ * sta2x11_mlb_read - read directly from hardware register
+ * @dev: structure containing hardware address
+ * @reg: register offset
+ *
+ * read a 32 bit value into from register
+ * return value: register contents
+ */
+static u32 sta2x11_mlb_read(struct sta2x11_mlb *dev, u32 reg)
+{
+	return readl(dev->base + reg);
+}
+
+/**
+ * sta2x11_mlb_reset - reset MLB interface
+ * @dev: structure containing hardware address
+ *
+ * The device is reset and a busy wait is done until it is ready. If the
+ * reset takes more than 1000 cycle, probably there is an the hardware failure
+ */
+static void sta2x11_mlb_reset(struct sta2x11_mlb *dev)
+{
+	int i = 1000;
+
+	sta2x11_mlb_write(dev, MLB_DCCR, DCCR_MRS_BIT);
+	while ((sta2x11_mlb_read(dev, MLB_DCCR) & DCCR_MRS_BIT) && i > 0)
+		i--;
+	if (!i)
+		dev_err(dev->mdev->parent, "failed to reset MLB\n");
+}
+
+/**
+ * skip_next - read and discard data
+ * @dev: structure containing hardware address
+ * @ch: number of channel
+ * @status: contains updated channel status
+ *
+ * read until buffer is empty or the beginning of a new packet.
+ *
+ * return value: first word of new packet, undefined if no new packet.
+ */
+static int sta2x11_mlb_skip_next(struct sta2x11_mlb *dev, u8 ch, int *status)
+{
+	int word = 0;
+
+	while(1) {
+		*status = sta2x11_mlb_read(dev, MLB_CSCR(ch));
+		if (*status & (CSCR_BM_BIT |CSCR_MRPS_BIT))
+			return word;
+		sta2x11_mlb_write(dev, MLB_CSCR(ch), *status & 0xffff);
+		word = sta2x11_mlb_read(dev, MLB_CCBCR(ch));
+	}
+}
+
+/**
+ * sta2x11_mlb_rx_sync - receive from one channel of type CHAN_SYNC
+ *
+ * @dev: sta2x11_mlb instance to use
+ * @skb: buffer where store data
+ * @skb_size: number of bytes to read
+ * @ch: channel number
+ */
+static void sta2x11_mlb_rx_sync(struct sta2x11_mlb *dev, struct sk_buff *skb, int skb_size, u8 ch)
+{
+	u32 status;
+	u32 *data;
+
+	status = sta2x11_mlb_read(dev, MLB_CSCR(ch));
+	while ((skb->len < skb_size) && !(status & CSCR_BM_BIT)) {
+		data = (u32 *)skb_put(skb, sizeof(*data));
+		*data = sta2x11_mlb_read(dev, MLB_CCBCR(ch));
+		status = sta2x11_mlb_read(dev, MLB_CSCR(ch));
+	}
+}
+
+/**
+ * sta2x11_mlb_rx_ctl_async - receive from one channel of type ASYNC or CTL
+ *
+ * @dev: sta2x11_mlb instance to use
+ * @skb: buffer where store data
+ * @skb_size: number of bytes to read
+ * @ch: channel number
+ *
+ * return value: 0 if no error occurs, -EBUSY if buffer is empty
+ */
+static int sta2x11_mlb_rx_ctl_async(struct sta2x11_mlb *dev,
+				     struct sk_buff *skb, int skb_size, u8 ch)
+{
+	struct sta2x11_mlb_chan *chn = &dev->channels[ch];
+	u32 status;
+	u32 *data;
+	int word;
+	int len;
+
+	while (1) {
+		status = sta2x11_mlb_read(dev, MLB_CSCR(ch));
+		sta2x11_mlb_write(dev, MLB_CSCR(ch), status & 0xffff);
+		if (status & CSCR_REC_ERR) {
+			pr_info("MLB: rec. error %x\n", status);
+			chn->len = 0;
+			word = sta2x11_mlb_skip_next(dev, ch, &status);
+			if (status & CSCR_MRPS_BIT)
+				goto newword;
+		}
+		if (status & CSCR_BM_BIT) {
+			/* The buffer is empty, nothing to do */
+			return -EBUSY; /* FIXME better error code */
+		}
+		word = sta2x11_mlb_read(dev, MLB_CCBCR(ch));
+newword:
+		if (!chn->len)
+			chn->len = ntohs(word) + 2;
+		if (chn->len > skb_size) {
+			pr_info("MLB: len. error %d\n", chn->len);
+			chn->len = 0;
+			word = sta2x11_mlb_skip_next(dev, ch, &status);
+			if (status & CSCR_MRPS_BIT)
+				goto newword;
+			continue;
+		}
+		len = chn->len - skb->len;
+		if (len > sizeof(word))
+			len = sizeof(word);
+		data = (u32 *) skb_put(skb, len);
+		*data = word;
+		if (skb->len >= chn->len)
+			break;
+	}
+
+	return 0;
+}
+
+/**
+ * __sta2x11_mlb_rx - receive from one channel
+ * @dev: structure containing all information
+ * @ch: channel number
+ *
+ * read data from one channel and deliver to MOST layer if complete
+ * get new buffer from MOST layer if there is none in use.
+ * in case of an error discard data, no message to MOST layer.
+ */
+static void sta2x11_mlb_rx(struct sta2x11_mlb *dev, u8 ch)
+{
+	unsigned long flags;
+	int skb_size, ret;
+	struct sta2x11_mlb_chan *chn;
+	struct sk_buff *skb;
+
+	chn = &dev->channels[ch];
+	switch (chn->type) {
+	case CHAN_CTL:
+		skb_size = CTRL_FRAME_SIZE;
+		break;
+	case CHAN_ASYNC:
+		skb_size = MLB_MAX_BUF;
+		break;
+	case CHAN_SYNC:
+		skb_size = SYNC_FRAME_SIZE;
+		break;
+	default:
+		return;
+		break;
+	}
+	if (!spin_trylock_irqsave(&dev->lock, flags))
+		return;
+	skb = chn->skb;
+	if (!skb) {
+		chn->len = 0;
+		skb = most_skb_alloc(skb_size, GFP_ATOMIC);
+		chn->skb = skb;
+		if (!skb)
+			goto out;
+	}
+
+	if (chn->type == CHAN_SYNC) {
+		sta2x11_mlb_rx_sync(dev, skb, skb_size, ch);
+	} else {
+		ret = sta2x11_mlb_rx_ctl_async(dev, skb, skb_size, ch);
+		if (ret)
+			goto out;
+	}
+
+	chn->skb = NULL;
+	chn->len = 0;
+	spin_unlock_irqrestore(&dev->lock, flags);
+	/* deliver SKB upstreams */
+	skb->dev = (void *)dev->mdev;
+	most_cb(skb)->channel_type = chn->type;
+	most_cb(skb)->channel = chn->chan;
+
+	most_recv_frame(skb);
+
+out:
+	spin_unlock_irqrestore(&dev->lock, flags);
+}
+
+/**
+ * __sta2x11_mlb_tx - transmit one buffer
+ * @dev: structure containing all information
+ * @ch: channel number
+ *
+ * get one buffer from MOST layer and transmit it.
+ * release buffer if transmission is complete.
+ *
+ * return value: 0, transmission was attempted
+ *
+ * 1, no buffer is to be transmitted
+ */
+static int sta2x11_mlb_tx(struct sta2x11_mlb *dev, u8 ch)
+{
+	unsigned long flags;
+	struct sk_buff *skb;
+	struct sta2x11_mlb_chan *chn;
+	int status;
+	int len;
+	u32 word;
+	int i;
+
+	/* check if we have sync */
+	if (dev->mlb_lock == MLB_UNLOCKED)
+		return 0;
+
+	if (!spin_trylock_irqsave(&dev->lock, flags))
+		return 0;
+	chn = &dev->channels[ch];
+	skb = chn->skb;
+	if (!skb) {
+		skb = skb_dequeue(&chn->data_q);
+		if (!skb) {
+			spin_unlock_irqrestore(&dev->lock, flags);
+			return 1;
+		}
+		chn->skb = skb;
+		chn->pos = 0;
+	}
+	status = 0;
+	status = sta2x11_mlb_read(dev, MLB_CSCR(ch));
+	for (i = chn->pos; i < skb->len; i += 4) {
+
+		status = sta2x11_mlb_read(dev, MLB_CSCR(ch));
+		if (status & CSCR_REC_ERR) {
+			sta2x11_mlb_write(dev, MLB_CSCR(ch), status & 0xffff);
+			dev_err(&dev->pdev->dev, "MLB: tx state, pos: %x, %d\n",
+				status, i);
+			status = sta2x11_mlb_read(dev, MLB_CSCR(ch));
+			if (status & CSCR_REC_ERR) {
+				dev_err(&dev->pdev->dev,
+					"MLB: tx2state, pos: %x, %d\n",
+					status, i);
+				kfree_skb(skb);
+				chn->skb = NULL;
+				spin_unlock_irqrestore(&dev->lock, flags);
+				return 0;
+			}
+		}
+		if (status & CSCR_BF_BIT) {
+			chn->pos = i;
+			break;
+		}
+		len = skb->len - i;
+		if (len < sizeof(u32)) {
+			word = 0;
+			memcpy(&word, skb->data + i, len);
+			sta2x11_mlb_write(dev, MLB_CNBCR(ch), word);
+		} else
+			sta2x11_mlb_write(dev, MLB_CNBCR(ch),
+				  *(u32 *) (skb->data + i));
+	}
+
+	sta2x11_mlb_write(dev, MLB_CSCR(ch), status & 0xffff);
+	if (i >= skb->len) {
+		kfree_skb(skb);
+		chn->skb = NULL;
+		spin_unlock_irqrestore(&dev->lock, flags);
+		return 0;
+	}
+	spin_unlock_irqrestore(&dev->lock, flags);
+	return 0;
+}
+
+/**
+ * __config_channel - set hardware depending on information from higher layer
+ * @dev: structure containing all information
+ * @ch: channel number
+ *
+ * The parameters for one channel are set.
+ * return value: 0, no error
+ *
+ * -EINVAL, some parameter error, check kernel log.
+ */
+static int sta2x11_mlb_config_channel(struct sta2x11_mlb *dev, u8 ch)
+{
+	u32 val;
+	u32 mode;
+	int sta2x11_mlb_type;
+	struct sta2x11_mlb_chan *chn;
+
+	chn = &dev->channels[ch];
+	chn->pos = 0;
+	chn->len = 0;
+	chn->skb = NULL;
+	mode = MLB_IO;
+	chn->mode = mode;
+
+	val = 0;
+	val |= CECR_CE_BIT;
+	switch (chn->dir) {
+	case MLB_READ:
+		break;
+	case MLB_WRITE:
+		val |= CECR_TR_BIT;
+		break;
+	default:
+		dev_err(dev->mdev->parent, "unknown direction %d\n", chn->dir);
+		return -EINVAL;
+		break;
+	}
+
+	/* channel type (synchronous, isochronous, asyn, control) */
+	switch (chn->type) {
+	case CHAN_CTL:
+		sta2x11_mlb_type = CECR_CT_CTRL;
+		break;
+	case CHAN_SYNC:
+		sta2x11_mlb_type = CECR_CT_SYNC;
+		break;
+	case CHAN_ASYNC:
+		sta2x11_mlb_type = CECR_CT_ASYN;
+		break;
+	default:
+		dev_err(dev->mdev->parent, "unknown type %d\n", chn->type);
+		return -EINVAL;
+		break;
+	}
+	val |= sta2x11_mlb_type << CECR_CT_SHIFT;
+
+	/* setup mode */
+	switch (mode) {
+	case MLB_DMA:
+		val |= (CECR_MDS_DMAPP << CECR_MDS_SHIFT);
+		break;
+	case MLB_IO:
+		val |= (CECR_MDS_IO << CECR_MDS_SHIFT);
+		val |= CECR_MTSR_BIT;
+		break;
+	default:
+		dev_err(dev->mdev->parent, "unknown mode %d\n", mode);
+		return -EINVAL;
+		break;
+	}
+
+	/* channel address  */
+	val |= (chn->chan >> 1) << CECR_CA_SHIFT;
+	chn->initialized = 1;
+	sta2x11_mlb_write(dev, MLB_CECR(ch), val);
+	return 0;
+}
+
+/**
+ * sta2x11_mlb_serve_interrupt - handles channel interrupt
+ * @dev: the device instance
+ * @ch: channel number that raise an interrupt
+ */
+static void sta2x11_mlb_serve_interrupt(struct sta2x11_mlb *dev, u8 ch) {
+	struct sta2x11_mlb_chan *chn;
+	int ret, status;
+	u32 val;
+
+	chn = &dev->channels[ch];
+	if (unlikely(!chn->initialized)) {
+		dev_info(&dev->pdev->dev,
+			 "non-initialized channel %d\n", ch);
+		return;
+	}
+	switch (chn->dir) {
+	case MLB_READ:
+		sta2x11_mlb_rx(dev, ch);
+		break;
+	case MLB_WRITE:
+		status = sta2x11_mlb_read(dev, MLB_CSCR(ch));
+		if (status & CSCR_REC_ERR) {
+			val = status & 0xffff;
+			sta2x11_mlb_write(dev, MLB_CSCR(ch), val);
+			dev_err(&dev->pdev->dev,
+				"MLB: tx ir state %x\n",
+				status);
+		}
+
+		ret = sta2x11_mlb_tx(dev, ch);
+		if (ret) {
+			val = sta2x11_mlb_read(dev, MLB_CECR(ch));
+			val |= CECR_MTSR_BIT;
+			sta2x11_mlb_write(dev, MLB_CECR(ch), val);
+		}
+		break;
+	}
+
+}
+
+/**
+ * sta2x11_mlb_interrupt - Handles mlb interrupts
+ * @irq: unused, only one interrupt numer used
+ * @_dev: pointer to dev structure
+ *
+ * all channels are checked, if possible data transfer is done.
+ * MLB and MOSt status is updated.
+ * return value: IRQ_NONE, nothing done, interrupte was not for us
+ *
+ * IRQ_HANDLED, otherwise
+ */
+static irqreturn_t sta2x11_mlb_interrupt(int irq, void *_dev)
+{
+	int i;
+	int irq_redo_cnt = 0;
+	struct sta2x11_mlb *dev = _dev;
+	u32 pending;
+	int handled = 0;
+	int sscr;
+
+	sscr = sta2x11_mlb_read(dev, MLB_SSCR);
+	sscr &= SSCR_SDMU_BIT | SSCR_SDML_BIT | SSCR_SDSC_BIT |
+	    SSCR_SDCS_BIT | SSCR_SDNU_BIT | SSCR_SDNL_BIT | SSCR_SDR_BIT;
+	if (sscr != 0) {
+		if (sscr & SSCR_SDNU_BIT)
+			dev->net_lock = MLB_UNLOCKED;
+		if (sscr & SSCR_SDNL_BIT)
+			dev->net_lock = MLB_LOCKED;
+		if (sscr & SSCR_SDMU_BIT)
+			dev->mlb_lock = MLB_UNLOCKED;
+		if (sscr & SSCR_SDML_BIT)
+			dev->mlb_lock = MLB_LOCKED;
+		sta2x11_mlb_write(dev, MLB_SSCR, sscr);
+		handled = 1;
+	}
+
+	while ((pending = sta2x11_mlb_read(dev, MLB_CICR))) {
+		for (i = 0; i < MAX_CHANNELS; i++) {
+			if (!(pending & (1 << i)))
+				continue; /* nothing to do */
+			sta2x11_mlb_serve_interrupt(dev, i);
+			handled = 1;
+		}
+
+		if (irq_redo_cnt++ > 5)
+			dev_warn(&dev->pdev->dev, "Possible interrupt loop");
+	}
+
+	return IRQ_RETVAL(handled);
+}
+
+/**
+ * reset_all_chans - turn off all channels
+ * @dev: structure containing hardware address
+ *
+ * all channels are turned off.
+ */
+static void sta2x11_mlb_reset_all_chans(struct sta2x11_mlb *dev)
+{
+	u8 ch;
+	for (ch = 0; ch < MAX_CHANNELS; ch++)
+		sta2x11_mlb_write(dev, MLB_CECR(ch), 0);
+}
+
+/**
+ * config_mlb - set parameter common to all channels
+ * @dev: structure containing hardware address
+ *
+ * set speed, host id  and endianness
+ *
+ * return value : 0, always successful.
+ */
+static int sta2x11_mlb_config_mlb(struct sta2x11_mlb *dev)
+{
+	u32 dccr = 0;
+
+	sta2x11_mlb_reset(dev);
+	sta2x11_mlb_reset_all_chans(dev);
+
+	/* allow all system interrupts */
+	sta2x11_mlb_write(dev, MLB_SMCR, 0);
+	dccr = (MLB_DEV_ADDRESS(ehcid) >> 1) << DCCR_MDA_SHIFT;
+	dccr |= (speed << DCCR_MCS_SHIFT) | MLB_LE_ENABLE | DCCR_MDE_BIT;
+	sta2x11_mlb_write(dev, MLB_DCCR, dccr);
+	return 0;
+}
+
+/**
+ * poll_func - check if channels are ready
+ * @data: point to dev
+ *
+ * check all active channel if data can be transferred.
+ * restart timer.
+ */
+static void sta2x11_mlb_poll_func(unsigned long data)
+{
+	struct sta2x11_mlb *dev;
+	u32 val;
+	int i;
+
+	dev = (struct sta2x11_mlb *)data;
+	for (i = 0; i < MAX_CHANNELS; i++) {
+		if (!(dev->active_channels & (1 << i)))
+			continue; /* Skip un-active */
+
+		switch (dev->channels[i].dir) {
+		case MLB_READ:
+			val = sta2x11_mlb_read(dev, MLB_CSCR(i));
+			if (!(val & CSCR_BM_BIT))
+				sta2x11_mlb_rx(dev, i);
+			break;
+		case MLB_WRITE:
+			sta2x11_mlb_tx(dev, i);
+			break;
+		}
+	}
+	mod_timer(&dev->poll_timer, jiffies + 1);
+}
+
+/**
+ * get_chan - get next free channel number depending on type
+ * @dev: structure containing all information
+ * @type: type of channel SYNC or not SYNC.
+ *
+ *
+ * SYNC channels have a reserved number range, in order to use the
+ * larger buffers.
+ *
+ * return value: channel number, if a channel is free
+ *
+ * -ENODEV, else
+ */
+static int sta2x11_mlb_get_chan(struct sta2x11_mlb *dev, enum most_chan_type type)
+{
+	int i;
+	int start_chan;
+	int end_chan;
+
+	if (type == CHAN_SYNC) {
+		start_chan = MAX_CHANNELS - syncc;
+		end_chan = MAX_CHANNELS;
+	} else {
+		start_chan = 0;
+		end_chan = MAX_CHANNELS - syncc;
+	}
+	for (i = start_chan; i < end_chan; i++) {
+		if (!(dev->active_channels & (1 << i))) {
+			dev->active_channels |= 1 << i;
+			return i;
+		}
+	}
+	return -ENODEV;
+}
+
+/**
+ * free_chan - free channel in list
+ * @dev: structure containing all information
+ * @channel: channel to be freed
+ *
+ * Channel is marked as free. No checks are done.
+ */
+static void sta2x11_mlb_free_chan(struct sta2x11_mlb *dev, int channel)
+{
+	dev->active_channels &= ~(1 << channel);
+}
+
+/**
+ * sta2x11_mlb_conf_channel - setup a single channel
+ * @mdev: struct from socket layer
+ * @type: type of channel
+ * @channel: number of channel
+ * @flags: up or down
+ *
+ * in case of shutdown read all pending data.
+ */
+static int sta2x11_mlb_conf_channel(struct most_dev *mdev,
+				    enum most_chan_type type,
+				    u8 channel, u8 flags)
+{
+	struct sta2x11_mlb *dev = (struct sta2x11_mlb *)mdev->driver_data;
+	unsigned long irq_flags;
+	struct sta2x11_mlb_chan *chn;
+	int err = -EINVAL;
+	int ch;
+	u32 val;
+
+	dev_dbg(mdev->parent, "%s: channel: %d, flags: %x\n",
+		__func__, channel, flags);
+
+	if (!channel || (channel & 0x1) || (channel > MAX_LCHAN))
+		return -EINVAL;
+
+	spin_lock_irqsave(&dev->lock, irq_flags);
+	if (flags & MOST_CONF_FLAG_UP) {
+
+
+		ch = sta2x11_mlb_get_chan(dev, type);
+		if (ch < 0)
+			goto out;
+		dev->chantab[channel >> 1] = ch;
+		chn = &dev->channels[ch];
+		chn->chan = channel;
+		chn->type = type;
+		chn->dir = (flags & MOST_CONF_FLAG_TX) ? MLB_WRITE : MLB_READ;
+		err = sta2x11_mlb_config_channel(dev, ch);
+
+	} else {
+		ch = dev->chantab[channel >> 1];
+		if (ch < 0 || ch > MAX_CHANNELS)
+			goto out;
+
+		chn = &dev->channels[ch];
+
+		if (chn->dir == MLB_READ) {
+			/* disable interrupts and channel */
+			val = CECR_MLFS_BIT | CECR_MBER_BIT | CECR_MTSR_BIT;
+			val |= CECR_MRSR_BIT | CECR_MDBR_BIT | CECR_MPRO_BIT;
+			sta2x11_mlb_write(dev, MLB_CECR(ch), val);
+
+			while (!(sta2x11_mlb_read(dev, MLB_CSCR(ch)) & CSCR_BM_BIT))
+				sta2x11_mlb_read(dev, MLB_CCBCR(ch));
+		} else {
+			/* only disable interrupts */
+			val = sta2x11_mlb_read(dev, MLB_CECR(ch));
+			val |= CECR_MLFS_BIT | CECR_MBER_BIT | CECR_MTSR_BIT;
+			val |= CECR_MRSR_BIT | CECR_MDBR_BIT | CECR_MPRO_BIT;
+			sta2x11_mlb_write(dev, MLB_CECR(ch), val);
+		}
+		sta2x11_mlb_free_chan(dev, ch);
+		dev->chantab[channel >> 1] = -1;
+		chn->chan = 0;
+		chn->initialized = 0;
+		err = 0;
+	}
+out:
+	spin_unlock_irqrestore(&dev->lock, irq_flags);
+	return err;
+}
+
+static void sta2x11_mlb_set_lcbcr(struct sta2x11_mlb *dev,
+				  u8 ch, int pos, int size)
+{
+	u32 val;
+
+	val = ((10 / 2) << LCBCR_TH_SHIFT);
+	val |= ((size / 4 - 1) << LCBCR_BD_SHIFT);
+	val |= (pos / 4 << LCBCR_SA_SHIFT);
+	sta2x11_mlb_write(dev, MLB_LCBCR(ch), val);
+}
+/**
+ * sta2x11_mlb_open - open device
+ * @mdev: MOST layer data containg pointer to dev
+ *
+ * open the device. This is done once for all channels.
+ * setup internal buffers.
+ * Wait for device to become ready.
+ * Initialize timer.
+ * return value: 0, no error.
+ *
+ * -EINVAL, device is not ready
+ *
+ *  else, configuration error
+ */
+static int sta2x11_mlb_open(struct most_dev *mdev)
+{
+	struct sta2x11_mlb *dev = (struct sta2x11_mlb *)mdev->driver_data;
+	int i;
+	int rc;
+	u8 ch;
+	int async_size;
+	int buf_pos;
+	u32 val;
+
+	rc = sta2x11_mlb_config_mlb(dev);
+	if (rc < 0)
+		return rc;
+
+	syncb &= ~3;
+	async_size = (INTRAM - (syncc * syncb)) / (MAX_CHANNELS - syncc);
+	async_size &= ~3;
+	buf_pos = 0;
+	for (ch = 0; ch < MAX_CHANNELS - syncc; ch++) {
+		int size = ((ch < MAX_CHANNELS - syncc) ? async_size : syncb);
+		sta2x11_mlb_set_lcbcr(dev, ch, buf_pos, size);
+		buf_pos += size;
+	}
+
+	dev->active_channels = 0;
+	i = 50;
+	while ((dev->mlb_lock == MLB_UNLOCKED) && (i-- > 0))
+		msleep_interruptible(1);
+	if (i <= 0)
+		return -EINVAL;
+	for (i = 0; i < (MAX_LCHAN >> 1); i++)
+		dev->chantab[i] = -1;
+	for (i = 0; i < MAX_CHANNELS; i++) {
+		val = sta2x11_mlb_read(dev, MLB_CSCR(i)) & 0xffff;
+		sta2x11_mlb_write(dev, MLB_CSCR(i), val);
+		skb_queue_head_init(&dev->channels[i].data_q);
+	}
+
+	setup_timer(&dev->poll_timer,
+		    sta2x11_mlb_poll_func, (unsigned long)dev);
+	dev->poll_timer.expires = jiffies + 1;
+	add_timer(&dev->poll_timer);
+	dev->opened = 1;
+	return rc;
+}
+
+/**
+ * sta2x11_mlb_close - close all channels
+ * @mdev: device information from socket layer
+ *
+ * remove all pending buffers.
+ * remove timer.
+ *
+ * return value: 0, always successful
+ */
+static int sta2x11_mlb_close(struct most_dev *mdev)
+{
+	struct sta2x11_mlb *dev = (struct sta2x11_mlb *)mdev->driver_data;
+	int i;
+
+	dev->active_channels = 0;
+
+	if (!dev->opened)
+		return 0;
+
+	dev->opened = 0;
+	del_timer_sync(&dev->poll_timer);
+	for (i = 0; i < MAX_CHANNELS; i++)
+		skb_queue_purge(&dev->channels[i].data_q);
+
+	return 0;
+}
+
+/**
+ * sta2x11_mlb_send - send one buffer
+ * @skb: buffer from MOST layer
+ *
+ * send one buffer, data is queued.
+ *
+ * return value: 0, no error
+ *
+ * -EINVAL, device not opened, illegal channel type  or wrong channel number
+ */
+static int sta2x11_mlb_send(struct sk_buff *skb)
+{
+	struct most_dev *mdev = (struct most_dev *)skb->dev;
+	struct sta2x11_mlb *dev = (struct sta2x11_mlb *)mdev->driver_data;
+	u32 val;
+	u8 channel;
+	u8 ch;
+
+	if (!dev->opened)
+		return -EINVAL;
+	channel = most_cb(skb)->channel;
+	if (!channel || (channel & 0x1) || (channel > MAX_LCHAN)) {
+		dev_warn(&dev->pdev->dev,"%s: Got illegal channel: %d\n",
+		       __func__, most_cb(skb)->channel);
+		return -EINVAL;
+	}
+	ch = dev->chantab[channel >> 1];
+	if (ch >= MAX_CHANNELS)
+		return -EINVAL;
+	switch (most_cb(skb)->channel_type) {
+	case CHAN_SYNC:
+		skb_queue_tail(&dev->channels[ch].data_q, skb);
+		sta2x11_mlb_tx(dev, ch);
+		val = sta2x11_mlb_read(dev, MLB_CECR(ch)) & ~CECR_MTSR_BIT;
+		sta2x11_mlb_write(dev, MLB_CECR(ch), val);
+		break;
+	case CHAN_CTL:
+	case CHAN_ASYNC:
+		skb_queue_tail(&dev->channels[ch].data_q, skb);
+		sta2x11_mlb_tx(dev, ch);
+		break;
+	default:
+		dev_warn(&dev->pdev->dev,
+			"%s: Got unsupported channel type: %d\n",
+			__func__, most_cb(skb)->channel_type);
+		kfree_skb(skb);
+		return -EINVAL;
+		break;
+	}
+	return 0;
+}
+
+/**
+ * configure - configure the PCI device
+ * @pdev: PCI device
+ *
+ * enable and configure device.
+ * return value: 0, no error
+ *
+ * -1, region could not be mapped or interrupt not available
+ */
+static int sta2x11_mlb_configure(struct pci_dev *pdev)
+{
+	struct sta2x11_mlb *dev;
+	int ret;
+	void __iomem * const *piot;
+
+	dev = (struct sta2x11_mlb *)pci_get_drvdata(pdev);
+
+	ret = pci_enable_device(pdev);
+	if (ret) {
+		dev_err(&pdev->dev, "failed to enable device\n");
+		goto no_enable;
+	}
+
+	/* request all memory regions associated with this device */
+
+	ret = pcim_iomap_regions(pdev, BAR_MASK, KBUILD_MODNAME);
+	if (ret)
+		goto no_ioremap;
+	piot = pcim_iomap_table(pdev);
+	if (piot)
+		dev->base = piot[BAR];
+
+	pci_set_master(pdev);
+	pci_enable_msi(pdev);
+
+	dev_dbg(&pdev->dev, "requesting irq %d\n", pdev->irq);
+	ret = request_irq(pdev->irq, sta2x11_mlb_interrupt, IRQF_SHARED,
+			KBUILD_MODNAME, dev);
+	if (ret) {
+		dev_err(&pdev->dev, "failed to allocate IRQ %d\n", pdev->irq);
+		goto no_irq;
+	}
+	dev_dbg(&pdev->dev, "configured ok\n");
+
+	return 0;
+
+no_irq:
+	dev_dbg(&pdev->dev, "unmapping io\n");
+	pcim_iounmap_regions(pdev, BAR_MASK);
+no_ioremap:
+	pci_disable_device(pdev);
+no_enable:
+	return ret;
+}
+
+/**
+ * unconfigure - release PCI device
+ * @pdev: PCI device
+ *
+ * release device at PCI level and free local data.
+ * free interrupt.
+ * unmap regions.
+ * unregister at MOST socker layer
+ */
+static void sta2x11_mlb_unconfigure(struct pci_dev *pdev)
+{
+	struct sta2x11_mlb *dev;
+
+	dev = pci_get_drvdata(pdev);
+
+	if (dev->base) {
+		sta2x11_mlb_reset_all_chans(dev);
+		sta2x11_mlb_write(dev, MLB_DCCR, 0);
+		dev_dbg(&pdev->dev, "unmap io @%p\n", dev->base);
+	}
+
+
+	free_irq(pdev->irq, dev);
+
+	pcim_iounmap_regions(pdev, BAR_MASK);
+	pci_disable_msi(pdev);
+	pci_disable_device(pdev);
+	kfree(dev);
+}
+
+/**
+ * probe - check if device is present and allocate data structures
+ * @pcidev: PCI device
+ * @id: not used
+ *
+ * initialize local data.
+ * check module parameters here.
+ * register at MOST socket layer.
+ *
+ * return value: 0, no error
+ *
+ * -ENOMEM, no memory for internal structures.
+ *
+ *  other, errno defining cause
+ */
+static int sta2x11_mlb_probe(struct pci_dev *pdev,
+			     const struct pci_device_id *id)
+{
+	struct sta2x11_mlb *dev;
+	int err = 0;
+
+	if (ehcid < 0 || ehcid > 3) {
+		dev_err(&pdev->dev, "invalid ehcid value %d\n", ehcid);
+		return -EINVAL;
+	}
+	if (speed < DCCR_MCS_256FS || speed > DCCR_MCS_1024FS) {
+		dev_err(&pdev->dev, "invalid speed grade %d\n", speed);
+		return -EINVAL;
+	}
+	if (syncc < 0 || syncc > MAX_CHANNELS - 2) {
+		dev_err(&pdev->dev, "invalid syncc value %d\n", syncc);
+		return -EINVAL;
+	}
+	if (syncb < 32 || syncb > 256) {
+		dev_err(&pdev->dev, "invalid syncb size %d\n", syncb);
+		return -EINVAL;
+	}
+
+	dev = kzalloc(sizeof(*dev), GFP_KERNEL);
+	if (!dev)
+		return -ENOMEM;
+
+	dev->mdev = most_alloc_dev();
+	if (!dev->mdev) {
+		err = -ENOMEM;
+		goto err_alloc_dev;
+	}
+
+	dev->pdev = pdev;
+	dev->mdev->owner = THIS_MODULE;
+	dev->mdev->driver_data = dev;
+	dev->mdev->parent = &pdev->dev;
+	dev->mdev->open = sta2x11_mlb_open;
+	dev->mdev->close = sta2x11_mlb_close;
+	dev->mdev->send = sta2x11_mlb_send;
+	dev->mdev->conf_channel = sta2x11_mlb_conf_channel;
+
+	dev->mlb_lock = MLB_UNLOCKED;
+	dev->net_lock = MLB_UNLOCKED;
+	dev->active_channels = 0;
+	dev->opened = 0;
+	dev->disabled = 0;
+
+	spin_lock_init(&dev->lock);
+
+	pci_set_drvdata(pdev, dev);
+
+	err = sta2x11_mlb_configure(pdev);
+	if (err)
+		goto err_configure;
+
+	/* register to the MOST layer */
+	err = most_register_dev(dev->mdev);
+	if (err)
+		goto err_register;
+
+	dev_dbg(&pdev->dev, "most devname <%s>\n", dev->mdev->name);
+
+	dev->regset = kmalloc(sizeof(struct debugfs_regset32), GFP_KERNEL);
+	if (dev->regset) {
+		dev->regset->regs = sta2x11_mlb_regs;
+		dev->regset->nregs = ARRAY_SIZE(sta2x11_mlb_regs);
+		dev->regset->base = dev->base;
+		dev->dentry = debugfs_create_regset32("registers", S_IRUGO,
+						      NULL, dev->regset);
+		if (IS_ERR(dev->dentry)) {
+			dev_dbg(&dev->pdev->dev, "failed to register debugfs\n");
+		}
+	}
+	return 0;
+
+err_register:
+	sta2x11_mlb_unconfigure(pdev);
+err_configure:
+	most_free_dev(dev->mdev);
+err_alloc_dev:
+	kfree(dev);
+	return err;
+}
+
+/**
+ * remove - unconfigure device
+ * @pcidev: PCI device
+ *
+ * The device is set to a state before initialization.
+ * All resources are freed.
+ */
+static void sta2x11_mlb_remove(struct pci_dev *pdev)
+{
+	struct sta2x11_mlb *dev = pci_get_drvdata(pdev);
+
+	if (dev->regset) {
+		if (!IS_ERR_OR_NULL(dev->dentry)) {
+			debugfs_remove(dev->dentry);
+		}
+		kfree(dev->regset);
+	}
+
+	most_unregister_dev(dev->mdev);
+	sta2x11_mlb_unconfigure(pdev);
+	most_free_dev(dev->mdev);
+	kfree(dev);
+}
+
+#ifdef CONFIG_PM
+/**
+ * suspend - suspend device
+ * @pdev: PCI device
+ * @state: new power state
+ *
+ * attempts to set device to a new power state.
+ * all data are discarded, everything has to be set up again after power up.
+ *
+ * return value: 0, always successful, even if hardware does not support
+ * power management
+ */
+static int sta2x11_mlb_suspend(struct pci_dev *pdev, pm_message_t state)
+{
+	struct sta2x11_mlb *dev = pci_get_drvdata(pdev);
+	int i;
+
+	if (dev->opened) {
+		del_timer(&dev->poll_timer);
+		for (i = 0; i < MAX_CHANNELS; i++)
+			skb_queue_purge(&dev->channels[i].data_q);
+		dev->opened = 0;
+	}
+	/* save pci state */
+	pci_save_state(pdev);
+	if (pci_set_power_state(pdev, pci_choose_state(pdev, state))) {
+		pci_disable_device(pdev);
+		dev->disabled = 1;
+	}
+	dev_dbg(&pdev->dev,"MLB: suspend\n");
+	return 0;
+}
+
+/**
+ * resume - set device to power on state.
+ * @pdev: PCI device
+ *
+ * set device to power on state.
+ * return value: 0, no error
+ *
+ * other, errno of error.
+ */
+static int sta2x11_mlb_resume(struct pci_dev *pdev)
+{
+	struct sta2x11_mlb *dev = pci_get_drvdata(pdev);
+	int err;
+
+	dev_dbg(&pdev->dev, "MLB: resume\n");
+	/* restore pci state */
+	if (dev->disabled) {
+		err = pci_enable_device(pdev);
+		if (err) {
+			dev_warn(&pdev->dev, "MLB: Can't enable device.\n");
+			return err;
+		}
+		dev->disabled = 0;
+	}
+	err = pci_set_power_state(pdev, PCI_D0);
+	if (err) {
+		pci_disable_device(pdev);
+		dev_warn(&pdev->dev, "MLB: Can't enable device.\n");
+		return err;
+	}
+
+	pci_restore_state(pdev);
+
+	return 0;
+}
+#endif
+
+static DEFINE_PCI_DEVICE_TABLE(ids) = {
+	{PCI_DEVICE(PCI_VENDOR_ID_STMICRO, 0xcc12)},
+	{0,}
+};
+
+static struct pci_driver sta2x11_sta2x11_mlb_driver = {
+	.name = KBUILD_MODNAME,
+	.id_table = ids,
+	.probe = sta2x11_mlb_probe,
+	.remove = sta2x11_mlb_remove,
+#ifdef CONFIG_PM
+	.suspend = sta2x11_mlb_suspend,
+	.resume = sta2x11_mlb_resume,
+#endif
+};
+
+module_pci_driver(sta2x11_sta2x11_mlb_driver);
+
+MODULE_AUTHOR("Wind River");
+MODULE_DESCRIPTION("ConneXt MediaLB Driver");
+MODULE_LICENSE("GPL v2");
+MODULE_VERSION("0.3");
+MODULE_DEVICE_TABLE(pci, ids);
diff --git a/drivers/net/most/sta2x11mlb.h b/drivers/net/most/sta2x11mlb.h
new file mode 100644
index 0000000..2458ba8
--- /dev/null
+++ b/drivers/net/most/sta2x11mlb.h
@@ -0,0 +1,275 @@
+
+#ifndef STA2X11MLB_H_
+#define STA2X11MLB_H_
+
+#define BAR      0
+#define BAR_MASK 1
+
+/* size of internal RAM in "quadlets" */
+#define INTRAM 1024
+#define MAX_CHANNELS 30
+#define MAX_LCHAN 126
+
+#define MLB_DCCR 0x00
+#define MLB_SSCR 0x04
+#define MLB_SDCR 0x08
+#define MLB_SMCR 0x0c
+#define MLB_VCCR 0x1c
+#define MLB_SBCR 0x20
+#define MLB_ABCR 0x24
+#define MLB_CBCR 0x28
+#define MLB_IBCR 0x2c
+#define MLB_CICR 0x30
+
+#define MLB_CECR(n)   (0x10*(n)+0x40)
+#define MLB_CSCR(n)   (0x10*(n)+0x44)
+#define MLB_CCBCR(n)  (0x10*(n)+0x48)
+#define MLB_CNBCR(n)  (0x10*(n)+0x4c)
+#define MLB_LCBCR(n)  (0x04*(n)+0x280)
+
+/* Device Control Configuration Register bit definitions
+ */
+#define DCCR_MDE_BIT         (1<<31)
+#define DCCR_LBM_BIT         (1<<30)
+#define DCCR_MCS_MASK            0x3
+#define DCCR_MCS_SHIFT            28
+/*bit 27 reserved */
+#define DCCR_MLK_BIT         (1<<26)
+#define DCCR_MLE_BIT         (1<<25)
+#define DCCR_MHRE_BIT        (1<<24)
+#define DCCR_MRS_BIT         (1<<23)
+/*bits 22-8 reserved */
+#define DCCR_MDA_MASK           0xff
+#define DCCR_MDA_SHIFT             0
+
+#define DCCR_MCS_256FS            0
+#define DCCR_MCS_512FS            1
+#define DCCR_MCS_1024FS           2
+
+/* System Status Configuration Register bit definitions
+ */
+#define SSCR_SSRE_BIT         (1<<7)
+#define SSCR_SDMU_BIT         (1<<6)
+#define SSCR_SDML_BIT         (1<<5)
+#define SSCR_SDSC_BIT         (1<<4)
+#define SSCR_SDCS_BIT         (1<<3)
+#define SSCR_SDNU_BIT         (1<<2)
+#define SSCR_SDNL_BIT         (1<<1)
+#define SSCR_SDR_BIT          (1<<0)
+
+/* System Mask Configuration Register bit definitions
+ */
+#define SMCR_SMMU_BIT         (1<<6)
+#define SMCR_SMML_BIT         (1<<5)
+#define SMCR_SMSC_BIT         (1<<4)
+#define SMCR_SMCS_BIT         (1<<3)
+#define SMCR_SMNU_BIT         (1<<2)
+#define SMCR_SMNL_BIT         (1<<1)
+#define SMCR_SMR_BIT          (1<<0)
+
+/* Version Control Configuration Register (VCCR) bit definitions
+ */
+#define VCCR_UMA_MASK           0xff
+#define VCCR_UMA_SHIFT            24
+#define VCCR_UMI_MASK           0xff
+#define VCCR_UMI_SHIFT            16
+#define VCCR_MMA_MASK           0xff
+#define VCCR_MMA_SHIFT             8
+#define VCCR_MMI_MASK           0xff
+#define VCCR_MMI_SHIFT             0
+
+/* Channel n Entry Configuration Register  bit definitions
+ */
+#define CECR_CE_BIT (1<<31)
+#define CECR_TR_BIT (1<<30)
+#define CECR_CT_MASK 0x3
+#define CECR_CT_SHIFT 28
+#define CECR_PCE_BIT (1<<27)
+#define CECR_FSE_BIT (1<<27)
+#define CECR_FCE_BIT (1<<27)
+#define CECR_MDS_MASK 0x3
+#define CECR_MDS_SHIFT 25
+/* bit 24 reserved */
+#define CECR_MASK_MASK 0xff	/* I've already decided on the naming convention
+				 * when I found this bit-field :-)
+				 */
+#define CECR_MASK_SHIFT 16
+
+/* bit 23 reserved */
+#define CECR_MLFS_BIT (1<<22)
+/* bit 21 reserved */
+#define CECR_MBER_BIT (1<<20)
+#define CECR_MBST_BIT (1<<19)
+#define CECR_MTSR_BIT (1<<19)
+#define CECR_MBDO_BIT (1<<18)
+#define CECR_MRSR_BIT (1<<18)
+#define CECR_MDBR_BIT (1<<17)
+#define CECR_MPRO_BIT (1<<16)
+
+#define CECR_FSCD_BIT (1<<15)
+#define CECR_IPL_MASK  0xff
+#define CECR_IPL_SHIFT  8
+#define CECR_PCTH_MASK  0xf
+#define CECR_PCTH_SHIFT   8
+#define CECR_FSPC_MASK  0xf
+#define CECR_FSPC_SHIFT   8
+#define CECR_CA_MASK    0xff
+#define CECR_CA_SHIFT     0
+
+#define CECR_MDS_DMAPP 0
+#define CECR_MDS_DMACR 1
+#define CECR_MDS_IO    2
+
+#define CECR_CT_SYNC      0
+#define CECR_CT_ISOC      1
+#define CECR_CT_ASYN      2
+#define CECR_CT_CTRL      3
+
+/* Channel n Status Configuration Register (CSCR) bit definitions
+ */
+#define CSCR_BM_BIT   (1<<31)
+#define CSCR_BF_BIT   (1<<30)
+#define CSCR_IVB_MASK     0x3
+#define CSCR_IVB_SHIFT     18
+#define CSCR_GIRB_BIT (1<<17)
+#define CSCR_GB_BIT   (1<<17)
+#define CSCR_RDY_BIT  (1<<16)
+#define CSCR_STS_MASK  0xffff
+#define CSCR_STS_SHIFT      0
+
+#define CSCR_MRPS_BIT (1<<9)
+#define CSCR_MRPA_BIT (1<<8)
+/* bit 7 reserved */
+#define CSCR_MLFS_BIT (1<<6)
+#define CSCR_MHBE_BIT (1<<5)
+#define CSCR_MBER_BIT (1<<4)
+#define CSCR_MBST_BIT (1<<3)
+#define CSCR_MTSR_BIT (1<<3)
+#define CSCR_MBDO_BIT (1<<2)
+#define CSCR_MRSR_BIT (1<<2)
+#define CSCR_MDBR_BIT (1<<1)
+#define CSCR_MPRO_BIT (1<<0)
+
+#define CSCR_REC_ERR (CSCR_MPRO_BIT|CSCR_MDBR_BIT|CSCR_MRPA_BIT)
+/* Channel n Current Buffer Configuration Register (CCBCR) bit definitions
+ * Channel n Next Buffer Configuration Register (CNBCR) bit definitions
+ *
+ * Will be filled in later when we support DMA. in IO mode they are
+ * plain 32bit register for receive/transmit data buffer
+ */
+
+/* Local Channel n Buffer Configuration Register (LCBCR) bit definitions
+ */
+#define LCBCR_TH_MASK   0xff
+#define LCBCR_TH_SHIFT    22
+#define LCBCR_BD_MASK   0x7f
+#define LCBCR_BD_SHIFT    13
+#define LCBCR_SA_MASK   0xff
+#define LCBCR_SA_SHIFT     0
+
+/* enable little endian mode if required */
+#if defined(__LITTLE_ENDIAN)
+#define MLB_LE_ENABLE DCCR_MLE_BIT
+#else
+#if defined(__BIG_ENDIAN)
+#define MLB_LE_ENABLE 0
+#else
+#error endianness unknown
+#endif
+#endif
+
+/* 0x180 : first external host controller */
+#define MLB_DEV_ADDRESS(i) (0x180+2*(i))
+
+/* default values for INIC */
+#define FROM_INIC 2
+#define TO_INIC 4
+
+#define RXC 0
+#define TXC 1
+
+/* Direction of channel */
+enum direction {
+	MLB_READ,
+	MLB_WRITE
+};
+
+enum mode {
+	MLB_DMA,
+	MLB_IO
+};
+
+enum lock {
+	MLB_UNLOCKED,
+	MLB_LOCKED
+};
+
+#define MLB_MAX_BUF (1024*sizeof(u32))
+#define MLB_DMA_SIZE (MLB_MAX_BUF*MAX_CHANNELS)
+
+/* setting to higher value is not useful: we are transferring in real time */
+#define SYNC_FRAME_SIZE (32*sizeof(u32))
+#define CTRL_FRAME_SIZE 64
+#define ASYNC_FRAME_SIZE MLB_MAX_BUF
+
+/**
+ * struct channel - Information for one channel
+ * @initialized: tells if channel is initialized.
+ * @chan: logical channel number used on MOST layer
+ * @type: type, async, syn or control
+ * @dir: direction, read or write
+ * @mode: mode, DMA or IO
+ * @len: size of buffer
+ * @pos: current position in buffer
+ * @skb: socket buffer from MOST layer
+ * @data_q: queue for buffer handling
+ * @data: buffer, testing only
+ */
+struct sta2x11_mlb_chan {
+	int initialized;
+	u8 chan;
+	u8 type;
+	enum direction dir;
+	enum mode mode;
+	int len;
+	int pos;
+	struct sk_buff *skb;
+	struct sk_buff_head data_q;
+	u32 *data;
+};
+
+/**
+ * struct private - all data for one instance of MLB
+ * @base: hardware base address
+ * @pdev: PCI device
+ * @mdev: most device
+ * @lock: spinlock for hardware access
+ * @disabled: hardware is shutdown, or being shut down
+ * @opened: device is opened
+ * @poll_timer: timer for MLB device in case of lost interrupt or buffer not
+ *	emptied
+ * @active_channels: bitmap of active channels
+ * @mlb_lock: indicates MLB locked
+ * @net_lock: indicates MOST locked
+ * @chantab: converts internal channel number to MOST channel number.
+ * @channels: data for individual channel
+ * @dentry: debug fs dentry instance
+ */
+struct sta2x11_mlb {
+	void *base;
+	struct pci_dev *pdev;
+	struct most_dev *mdev;
+	spinlock_t lock;	/* mutual exclusion */
+	int disabled;
+	int opened;
+	struct timer_list poll_timer;
+	u32 active_channels;
+	enum lock mlb_lock;
+	enum lock net_lock;
+	u8 chantab[(MAX_LCHAN >> 1) + 1];
+	struct sta2x11_mlb_chan channels[MAX_CHANNELS];
+	struct dentry *dentry;
+	struct debugfs_regset32 *regset;
+};
+
+#endif /* STA2X11MLB_H_ */
-- 
1.7.7.2
