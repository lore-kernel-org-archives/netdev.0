From: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH V15 4/4] ptp: Added a clock driver for the National
 Semiconductor PHYTER.
Date: Fri, 22 Apr 2011 12:04:55 +0200
Message-ID: <8a6e839659be320aeb242cb9132734acae1cb09a.1303466103.git.richard.cochran@omicron.at>
References: <cover.1303466102.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org, Alan Cox <alan-qBU/x9rampVanCEyBjwyrvXRex20P6io@public.gmane.org>,
	Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
	Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>,
	Benjamin Herrenschmidt <benh-XVmvHMARGAS8U2dJNN8I7kB+6BGkLq7r@public.gmane.org>,
	Christoph Lameter <cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	John Stultz <john.stultz-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	Krzysztof Halasa <khc-9GfyWEdoJtJmR6Xm/wNWPw@public.gmane.org>,
	Mike Frysinger <vapier-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>,
	Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>,
	Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Rodolfo Giometti <giometti-k2GhghHVRtY@public.gmane.org>,
	Russell King <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>,
	Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <cover.1303466102.git.richard.cochran-3mrvs1K0uXizZXS1Dc/lvw@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch adds support for the PTP clock found on the DP83640.
The basic clock operations and one external time stamp have
been implemented.

Signed-off-by: Richard Cochran <richard.cochran-3mrvs1K0uXizZXS1Dc/lvw@public.gmane.org>
---
 drivers/net/phy/Makefile      |    1 +
 drivers/net/phy/dp83640.c     | 1100 +++++++++++++++++++++++++++++++++++++++++
 drivers/net/phy/dp83640_reg.h |  267 ++++++++++
 drivers/ptp/Kconfig           |   19 +
 4 files changed, 1387 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/phy/dp83640.c
 create mode 100644 drivers/net/phy/dp83640_reg.h

diff --git a/drivers/net/phy/Makefile b/drivers/net/phy/Makefile
index 13bebab..2333215 100644
--- a/drivers/net/phy/Makefile
+++ b/drivers/net/phy/Makefile
@@ -19,6 +19,7 @@ obj-$(CONFIG_FIXED_PHY)		+= fixed.o
 obj-$(CONFIG_MDIO_BITBANG)	+= mdio-bitbang.o
 obj-$(CONFIG_MDIO_GPIO)		+= mdio-gpio.o
 obj-$(CONFIG_NATIONAL_PHY)	+= national.o
+obj-$(CONFIG_DP83640_PHY)	+= dp83640.o
 obj-$(CONFIG_STE10XP)		+= ste10Xp.o
 obj-$(CONFIG_MICREL_PHY)	+= micrel.o
 obj-$(CONFIG_MDIO_OCTEON)	+= mdio-octeon.o
diff --git a/drivers/net/phy/dp83640.c b/drivers/net/phy/dp83640.c
new file mode 100644
index 0000000..d463b8a
--- /dev/null
+++ b/drivers/net/phy/dp83640.c
@@ -0,0 +1,1100 @@
+/*
+ * Driver for the National Semiconductor DP83640 PHYTER
+ *
+ * Copyright (C) 2010 OMICRON electronics GmbH
+ *
+ *  This program is free software; you can redistribute it and/or modify
+ *  it under the terms of the GNU General Public License as published by
+ *  the Free Software Foundation; either version 2 of the License, or
+ *  (at your option) any later version.
+ *
+ *  This program is distributed in the hope that it will be useful,
+ *  but WITHOUT ANY WARRANTY; without even the implied warranty of
+ *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ *  GNU General Public License for more details.
+ *
+ *  You should have received a copy of the GNU General Public License
+ *  along with this program; if not, write to the Free Software
+ *  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
+ */
+#include <linux/ethtool.h>
+#include <linux/kernel.h>
+#include <linux/list.h>
+#include <linux/mii.h>
+#include <linux/module.h>
+#include <linux/net_tstamp.h>
+#include <linux/netdevice.h>
+#include <linux/phy.h>
+#include <linux/ptp_classify.h>
+#include <linux/ptp_clock_kernel.h>
+
+#include "dp83640_reg.h"
+
+#define DP83640_PHY_ID	0x20005ce1
+#define PAGESEL		0x13
+#define LAYER4		0x02
+#define LAYER2		0x01
+#define MAX_RXTS	4
+#define MAX_TXTS	4
+#define N_EXT_TS	1
+#define PSF_PTPVER	2
+#define PSF_EVNT	0x4000
+#define PSF_RX		0x2000
+#define PSF_TX		0x1000
+#define EXT_EVENT	1
+#define EXT_GPIO	1
+#define CAL_EVENT	2
+#define CAL_GPIO	9
+#define CAL_TRIGGER	2
+
+/* phyter seems to miss the mark by 16 ns */
+#define ADJTIME_FIX	16
+
+#if defined(__BIG_ENDIAN)
+#define ENDIAN_FLAG	0
+#elif defined(__LITTLE_ENDIAN)
+#define ENDIAN_FLAG	PSF_ENDIAN
+#endif
+
+#define SKB_PTP_TYPE(__skb) (*(unsigned int *)((__skb)->cb))
+
+struct phy_rxts {
+	u16 ns_lo;   /* ns[15:0] */
+	u16 ns_hi;   /* overflow[1:0], ns[29:16] */
+	u16 sec_lo;  /* sec[15:0] */
+	u16 sec_hi;  /* sec[31:16] */
+	u16 seqid;   /* sequenceId[15:0] */
+	u16 msgtype; /* messageType[3:0], hash[11:0] */
+};
+
+struct phy_txts {
+	u16 ns_lo;   /* ns[15:0] */
+	u16 ns_hi;   /* overflow[1:0], ns[29:16] */
+	u16 sec_lo;  /* sec[15:0] */
+	u16 sec_hi;  /* sec[31:16] */
+};
+
+struct rxts {
+	struct list_head list;
+	unsigned long tmo;
+	u64 ns;
+	u16 seqid;
+	u8  msgtype;
+	u16 hash;
+};
+
+struct dp83640_clock;
+
+struct dp83640_private {
+	struct list_head list;
+	struct dp83640_clock *clock;
+	struct phy_device *phydev;
+	struct work_struct ts_work;
+	int hwts_tx_en;
+	int hwts_rx_en;
+	int layer;
+	int version;
+	/* remember state of cfg0 during calibration */
+	int cfg0;
+	/* remember the last event time stamp */
+	struct phy_txts edata;
+	/* list of rx timestamps */
+	struct list_head rxts;
+	struct list_head rxpool;
+	struct rxts rx_pool_data[MAX_RXTS];
+	/* protects above three fields from concurrent access */
+	spinlock_t rx_lock;
+	/* queues of incoming and outgoing packets */
+	struct sk_buff_head rx_queue;
+	struct sk_buff_head tx_queue;
+};
+
+struct dp83640_clock {
+	/* keeps the instance in the 'phyter_clocks' list */
+	struct list_head list;
+	/* we create one clock instance per MII bus */
+	struct mii_bus *bus;
+	/* protects extended registers from concurrent access */
+	struct mutex extreg_lock;
+	/* remembers which page was last selected */
+	int page;
+	/* our advertised capabilities */
+	struct ptp_clock_info caps;
+	/* protects the three fields below from concurrent access */
+	struct mutex clock_lock;
+	/* the one phyter from which we shall read */
+	struct dp83640_private *chosen;
+	/* list of the other attached phyters, not chosen */
+	struct list_head phylist;
+	/* reference to our PTP hardware clock */
+	struct ptp_clock *ptp_clock;
+};
+
+/* globals */
+
+static int chosen_phy = -1;
+static ushort cal_gpio = 4;
+
+module_param(chosen_phy, int, 0444);
+module_param(cal_gpio, ushort, 0444);
+
+MODULE_PARM_DESC(chosen_phy, \
+	"The address of the PHY to use for the ancillary clock features");
+MODULE_PARM_DESC(cal_gpio, \
+	"Which GPIO line to use for synchronizing multiple PHYs");
+
+/* a list of clocks and a mutex to protect it */
+static LIST_HEAD(phyter_clocks);
+static DEFINE_MUTEX(phyter_clocks_lock);
+
+static void rx_timestamp_work(struct work_struct *work);
+
+/* extended register access functions */
+
+#define BROADCAST_ADDR 31
+
+static inline int broadcast_write(struct mii_bus *bus, u32 regnum, u16 val)
+{
+	return mdiobus_write(bus, BROADCAST_ADDR, regnum, val);
+}
+
+/* Caller must hold extreg_lock. */
+static int ext_read(struct phy_device *phydev, int page, u32 regnum)
+{
+	struct dp83640_private *dp83640 = phydev->priv;
+	int val;
+
+	if (dp83640->clock->page != page) {
+		broadcast_write(phydev->bus, PAGESEL, page);
+		dp83640->clock->page = page;
+	}
+	val = phy_read(phydev, regnum);
+
+	return val;
+}
+
+/* Caller must hold extreg_lock. */
+static void ext_write(int broadcast, struct phy_device *phydev,
+		      int page, u32 regnum, u16 val)
+{
+	struct dp83640_private *dp83640 = phydev->priv;
+
+	if (dp83640->clock->page != page) {
+		broadcast_write(phydev->bus, PAGESEL, page);
+		dp83640->clock->page = page;
+	}
+	if (broadcast)
+		broadcast_write(phydev->bus, regnum, val);
+	else
+		phy_write(phydev, regnum, val);
+}
+
+/* Caller must hold extreg_lock. */
+static int tdr_write(int bc, struct phy_device *dev,
+		     const struct timespec *ts, u16 cmd)
+{
+	ext_write(bc, dev, PAGE4, PTP_TDR, ts->tv_nsec & 0xffff);/* ns[15:0]  */
+	ext_write(bc, dev, PAGE4, PTP_TDR, ts->tv_nsec >> 16);   /* ns[31:16] */
+	ext_write(bc, dev, PAGE4, PTP_TDR, ts->tv_sec & 0xffff); /* sec[15:0] */
+	ext_write(bc, dev, PAGE4, PTP_TDR, ts->tv_sec >> 16);    /* sec[31:16]*/
+
+	ext_write(bc, dev, PAGE4, PTP_CTL, cmd);
+
+	return 0;
+}
+
+/* convert phy timestamps into driver timestamps */
+
+static void phy2rxts(struct phy_rxts *p, struct rxts *rxts)
+{
+	u32 sec;
+
+	sec = p->sec_lo;
+	sec |= p->sec_hi << 16;
+
+	rxts->ns = p->ns_lo;
+	rxts->ns |= (p->ns_hi & 0x3fff) << 16;
+	rxts->ns += ((u64)sec) * 1000000000ULL;
+	rxts->seqid = p->seqid;
+	rxts->msgtype = (p->msgtype >> 12) & 0xf;
+	rxts->hash = p->msgtype & 0x0fff;
+	rxts->tmo = jiffies + HZ;
+}
+
+static u64 phy2txts(struct phy_txts *p)
+{
+	u64 ns;
+	u32 sec;
+
+	sec = p->sec_lo;
+	sec |= p->sec_hi << 16;
+
+	ns = p->ns_lo;
+	ns |= (p->ns_hi & 0x3fff) << 16;
+	ns += ((u64)sec) * 1000000000ULL;
+
+	return ns;
+}
+
+/* ptp clock methods */
+
+static int ptp_dp83640_adjfreq(struct ptp_clock_info *ptp, s32 ppb)
+{
+	struct dp83640_clock *clock =
+		container_of(ptp, struct dp83640_clock, caps);
+	struct phy_device *phydev = clock->chosen->phydev;
+	u64 rate;
+	int neg_adj = 0;
+	u16 hi, lo;
+
+	if (ppb < 0) {
+		neg_adj = 1;
+		ppb = -ppb;
+	}
+	rate = ppb;
+	rate <<= 26;
+	rate = div_u64(rate, 1953125);
+
+	hi = (rate >> 16) & PTP_RATE_HI_MASK;
+	if (neg_adj)
+		hi |= PTP_RATE_DIR;
+
+	lo = rate & 0xffff;
+
+	mutex_lock(&clock->extreg_lock);
+
+	ext_write(1, phydev, PAGE4, PTP_RATEH, hi);
+	ext_write(1, phydev, PAGE4, PTP_RATEL, lo);
+
+	mutex_unlock(&clock->extreg_lock);
+
+	return 0;
+}
+
+static int ptp_dp83640_adjtime(struct ptp_clock_info *ptp, s64 delta)
+{
+	struct dp83640_clock *clock =
+		container_of(ptp, struct dp83640_clock, caps);
+	struct phy_device *phydev = clock->chosen->phydev;
+	struct timespec ts;
+	int err;
+
+	delta += ADJTIME_FIX;
+
+	ts = ns_to_timespec(delta);
+
+	mutex_lock(&clock->extreg_lock);
+
+	err = tdr_write(1, phydev, &ts, PTP_STEP_CLK);
+
+	mutex_unlock(&clock->extreg_lock);
+
+	return err;
+}
+
+static int ptp_dp83640_gettime(struct ptp_clock_info *ptp, struct timespec *ts)
+{
+	struct dp83640_clock *clock =
+		container_of(ptp, struct dp83640_clock, caps);
+	struct phy_device *phydev = clock->chosen->phydev;
+	unsigned int val[4];
+
+	mutex_lock(&clock->extreg_lock);
+
+	ext_write(0, phydev, PAGE4, PTP_CTL, PTP_RD_CLK);
+
+	val[0] = ext_read(phydev, PAGE4, PTP_TDR); /* ns[15:0] */
+	val[1] = ext_read(phydev, PAGE4, PTP_TDR); /* ns[31:16] */
+	val[2] = ext_read(phydev, PAGE4, PTP_TDR); /* sec[15:0] */
+	val[3] = ext_read(phydev, PAGE4, PTP_TDR); /* sec[31:16] */
+
+	mutex_unlock(&clock->extreg_lock);
+
+	ts->tv_nsec = val[0] | (val[1] << 16);
+	ts->tv_sec  = val[2] | (val[3] << 16);
+
+	return 0;
+}
+
+static int ptp_dp83640_settime(struct ptp_clock_info *ptp,
+			       const struct timespec *ts)
+{
+	struct dp83640_clock *clock =
+		container_of(ptp, struct dp83640_clock, caps);
+	struct phy_device *phydev = clock->chosen->phydev;
+	int err;
+
+	mutex_lock(&clock->extreg_lock);
+
+	err = tdr_write(1, phydev, ts, PTP_LOAD_CLK);
+
+	mutex_unlock(&clock->extreg_lock);
+
+	return err;
+}
+
+static int ptp_dp83640_enable(struct ptp_clock_info *ptp,
+			      struct ptp_clock_request *rq, int on)
+{
+	struct dp83640_clock *clock =
+		container_of(ptp, struct dp83640_clock, caps);
+	struct phy_device *phydev = clock->chosen->phydev;
+	u16 evnt;
+
+	switch (rq->type) {
+	case PTP_CLK_REQ_EXTTS:
+		if (rq->extts.index != 0)
+			return -EINVAL;
+		evnt = EVNT_WR | (EXT_EVENT & EVNT_SEL_MASK) << EVNT_SEL_SHIFT;
+		if (on) {
+			evnt |= (EXT_GPIO & EVNT_GPIO_MASK) << EVNT_GPIO_SHIFT;
+			evnt |= EVNT_RISE;
+		}
+		ext_write(0, phydev, PAGE5, PTP_EVNT, evnt);
+		return 0;
+	default:
+		break;
+	}
+
+	return -EOPNOTSUPP;
+}
+
+static u8 status_frame_dst[6] = { 0x01, 0x1B, 0x19, 0x00, 0x00, 0x00 };
+static u8 status_frame_src[6] = { 0x08, 0x00, 0x17, 0x0B, 0x6B, 0x0F };
+
+static void enable_status_frames(struct phy_device *phydev, bool on)
+{
+	u16 cfg0 = 0, ver;
+
+	if (on)
+		cfg0 = PSF_EVNT_EN | PSF_RXTS_EN | PSF_TXTS_EN | ENDIAN_FLAG;
+
+	ver = (PSF_PTPVER & VERSIONPTP_MASK) << VERSIONPTP_SHIFT;
+
+	ext_write(0, phydev, PAGE5, PSF_CFG0, cfg0);
+	ext_write(0, phydev, PAGE6, PSF_CFG1, ver);
+
+	if (!phydev->attached_dev) {
+		pr_warning("dp83640: expected to find an attached netdevice\n");
+		return;
+	}
+
+	if (on) {
+		if (dev_mc_add(phydev->attached_dev, status_frame_dst))
+			pr_warning("dp83640: failed to add mc address\n");
+	} else {
+		if (dev_mc_del(phydev->attached_dev, status_frame_dst))
+			pr_warning("dp83640: failed to delete mc address\n");
+	}
+}
+
+static bool is_status_frame(struct sk_buff *skb, int type)
+{
+	struct ethhdr *h = eth_hdr(skb);
+
+	if (PTP_CLASS_V2_L2 == type &&
+	    !memcmp(h->h_source, status_frame_src, sizeof(status_frame_src)))
+		return true;
+	else
+		return false;
+}
+
+static int expired(struct rxts *rxts)
+{
+	return time_after(jiffies, rxts->tmo);
+}
+
+/* Caller must hold rx_lock. */
+static void prune_rx_ts(struct dp83640_private *dp83640)
+{
+	struct list_head *this, *next;
+	struct rxts *rxts;
+
+	list_for_each_safe(this, next, &dp83640->rxts) {
+		rxts = list_entry(this, struct rxts, list);
+		if (expired(rxts)) {
+			list_del_init(&rxts->list);
+			list_add(&rxts->list, &dp83640->rxpool);
+		}
+	}
+}
+
+/* synchronize the phyters so they act as one clock */
+
+static void enable_broadcast(struct phy_device *phydev, int init_page, int on)
+{
+	int val;
+	phy_write(phydev, PAGESEL, 0);
+	val = phy_read(phydev, PHYCR2);
+	if (on)
+		val |= BC_WRITE;
+	else
+		val &= ~BC_WRITE;
+	phy_write(phydev, PHYCR2, val);
+	phy_write(phydev, PAGESEL, init_page);
+}
+
+static void recalibrate(struct dp83640_clock *clock)
+{
+	s64 now, diff;
+	struct phy_txts event_ts;
+	struct timespec ts;
+	struct list_head *this;
+	struct dp83640_private *tmp;
+	struct phy_device *master = clock->chosen->phydev;
+	u16 cfg0, evnt, ptp_trig, trigger, val;
+
+	trigger = CAL_TRIGGER;
+
+	mutex_lock(&clock->extreg_lock);
+
+	/*
+	 * enable broadcast, disable status frames, enable ptp clock
+	 */
+	list_for_each(this, &clock->phylist) {
+		tmp = list_entry(this, struct dp83640_private, list);
+		enable_broadcast(tmp->phydev, clock->page, 1);
+		tmp->cfg0 = ext_read(tmp->phydev, PAGE5, PSF_CFG0);
+		ext_write(0, tmp->phydev, PAGE5, PSF_CFG0, 0);
+		ext_write(0, tmp->phydev, PAGE4, PTP_CTL, PTP_ENABLE);
+	}
+	enable_broadcast(master, clock->page, 1);
+	cfg0 = ext_read(master, PAGE5, PSF_CFG0);
+	ext_write(0, master, PAGE5, PSF_CFG0, 0);
+	ext_write(0, master, PAGE4, PTP_CTL, PTP_ENABLE);
+
+	/*
+	 * enable an event timestamp
+	 */
+	evnt = EVNT_WR | EVNT_RISE | EVNT_SINGLE;
+	evnt |= (CAL_EVENT & EVNT_SEL_MASK) << EVNT_SEL_SHIFT;
+	evnt |= (cal_gpio & EVNT_GPIO_MASK) << EVNT_GPIO_SHIFT;
+
+	list_for_each(this, &clock->phylist) {
+		tmp = list_entry(this, struct dp83640_private, list);
+		ext_write(0, tmp->phydev, PAGE5, PTP_EVNT, evnt);
+	}
+	ext_write(0, master, PAGE5, PTP_EVNT, evnt);
+
+	/*
+	 * configure a trigger
+	 */
+	ptp_trig = TRIG_WR | TRIG_IF_LATE | TRIG_PULSE;
+	ptp_trig |= (trigger  & TRIG_CSEL_MASK) << TRIG_CSEL_SHIFT;
+	ptp_trig |= (cal_gpio & TRIG_GPIO_MASK) << TRIG_GPIO_SHIFT;
+	ext_write(0, master, PAGE5, PTP_TRIG, ptp_trig);
+
+	/* load trigger */
+	val = (trigger & TRIG_SEL_MASK) << TRIG_SEL_SHIFT;
+	val |= TRIG_LOAD;
+	ext_write(0, master, PAGE4, PTP_CTL, val);
+
+	/* enable trigger */
+	val &= ~TRIG_LOAD;
+	val |= TRIG_EN;
+	ext_write(0, master, PAGE4, PTP_CTL, val);
+
+	/* disable trigger */
+	val = (trigger & TRIG_SEL_MASK) << TRIG_SEL_SHIFT;
+	val |= TRIG_DIS;
+	ext_write(0, master, PAGE4, PTP_CTL, val);
+
+	/*
+	 * read out and correct offsets
+	 */
+	val = ext_read(master, PAGE4, PTP_STS);
+	pr_info("master PTP_STS  0x%04hx", val);
+	val = ext_read(master, PAGE4, PTP_ESTS);
+	pr_info("master PTP_ESTS 0x%04hx", val);
+	event_ts.ns_lo  = ext_read(master, PAGE4, PTP_EDATA);
+	event_ts.ns_hi  = ext_read(master, PAGE4, PTP_EDATA);
+	event_ts.sec_lo = ext_read(master, PAGE4, PTP_EDATA);
+	event_ts.sec_hi = ext_read(master, PAGE4, PTP_EDATA);
+	now = phy2txts(&event_ts);
+
+	list_for_each(this, &clock->phylist) {
+		tmp = list_entry(this, struct dp83640_private, list);
+		val = ext_read(tmp->phydev, PAGE4, PTP_STS);
+		pr_info("slave  PTP_STS  0x%04hx", val);
+		val = ext_read(tmp->phydev, PAGE4, PTP_ESTS);
+		pr_info("slave  PTP_ESTS 0x%04hx", val);
+		event_ts.ns_lo  = ext_read(tmp->phydev, PAGE4, PTP_EDATA);
+		event_ts.ns_hi  = ext_read(tmp->phydev, PAGE4, PTP_EDATA);
+		event_ts.sec_lo = ext_read(tmp->phydev, PAGE4, PTP_EDATA);
+		event_ts.sec_hi = ext_read(tmp->phydev, PAGE4, PTP_EDATA);
+		diff = now - (s64) phy2txts(&event_ts);
+		pr_info("slave offset %lld nanoseconds\n", diff);
+		diff += ADJTIME_FIX;
+		ts = ns_to_timespec(diff);
+		tdr_write(0, tmp->phydev, &ts, PTP_STEP_CLK);
+	}
+
+	/*
+	 * restore status frames
+	 */
+	list_for_each(this, &clock->phylist) {
+		tmp = list_entry(this, struct dp83640_private, list);
+		ext_write(0, tmp->phydev, PAGE5, PSF_CFG0, tmp->cfg0);
+	}
+	ext_write(0, master, PAGE5, PSF_CFG0, cfg0);
+
+	mutex_unlock(&clock->extreg_lock);
+}
+
+/* time stamping methods */
+
+static void decode_evnt(struct dp83640_private *dp83640,
+			struct phy_txts *phy_txts, u16 ests)
+{
+	struct ptp_clock_event event;
+	int words = (ests >> EVNT_TS_LEN_SHIFT) & EVNT_TS_LEN_MASK;
+
+	switch (words) { /* fall through in every case */
+	case 3:
+		dp83640->edata.sec_hi = phy_txts->sec_hi;
+	case 2:
+		dp83640->edata.sec_lo = phy_txts->sec_lo;
+	case 1:
+		dp83640->edata.ns_hi = phy_txts->ns_hi;
+	case 0:
+		dp83640->edata.ns_lo = phy_txts->ns_lo;
+	}
+
+	event.type = PTP_CLOCK_EXTTS;
+	event.index = 0;
+	event.timestamp = phy2txts(&dp83640->edata);
+
+	ptp_clock_event(dp83640->clock->ptp_clock, &event);
+}
+
+static void decode_rxts(struct dp83640_private *dp83640,
+			struct phy_rxts *phy_rxts)
+{
+	struct rxts *rxts;
+	unsigned long flags;
+
+	spin_lock_irqsave(&dp83640->rx_lock, flags);
+
+	prune_rx_ts(dp83640);
+
+	if (list_empty(&dp83640->rxpool)) {
+		pr_warning("dp83640: rx timestamp pool is empty\n");
+		goto out;
+	}
+	rxts = list_first_entry(&dp83640->rxpool, struct rxts, list);
+	list_del_init(&rxts->list);
+	phy2rxts(phy_rxts, rxts);
+	list_add_tail(&rxts->list, &dp83640->rxts);
+out:
+	spin_unlock_irqrestore(&dp83640->rx_lock, flags);
+}
+
+static void decode_txts(struct dp83640_private *dp83640,
+			struct phy_txts *phy_txts)
+{
+	struct skb_shared_hwtstamps shhwtstamps;
+	struct sk_buff *skb;
+	u64 ns;
+
+	/* We must already have the skb that triggered this. */
+
+	skb = skb_dequeue(&dp83640->tx_queue);
+
+	if (!skb) {
+		pr_warning("dp83640: have timestamp but tx_queue empty\n");
+		return;
+	}
+	ns = phy2txts(phy_txts);
+	memset(&shhwtstamps, 0, sizeof(shhwtstamps));
+	shhwtstamps.hwtstamp = ns_to_ktime(ns);
+	skb_complete_tx_timestamp(skb, &shhwtstamps);
+}
+
+static void decode_status_frame(struct dp83640_private *dp83640,
+				struct sk_buff *skb)
+{
+	struct phy_rxts *phy_rxts;
+	struct phy_txts *phy_txts;
+	u8 *ptr;
+	int len, size;
+	u16 ests, type;
+
+	ptr = skb->data + 2;
+
+	for (len = skb_headlen(skb) - 2; len > sizeof(type); len -= size) {
+
+		type = *(u16 *)ptr;
+		ests = type & 0x0fff;
+		type = type & 0xf000;
+		len -= sizeof(type);
+		ptr += sizeof(type);
+
+		if (PSF_RX == type && len >= sizeof(*phy_rxts)) {
+
+			phy_rxts = (struct phy_rxts *) ptr;
+			decode_rxts(dp83640, phy_rxts);
+			size = sizeof(*phy_rxts);
+
+		} else if (PSF_TX == type && len >= sizeof(*phy_txts)) {
+
+			phy_txts = (struct phy_txts *) ptr;
+			decode_txts(dp83640, phy_txts);
+			size = sizeof(*phy_txts);
+
+		} else if (PSF_EVNT == type && len >= sizeof(*phy_txts)) {
+
+			phy_txts = (struct phy_txts *) ptr;
+			decode_evnt(dp83640, phy_txts, ests);
+			size = sizeof(*phy_txts);
+
+		} else {
+			size = 0;
+			break;
+		}
+		ptr += size;
+	}
+}
+
+static int match(struct sk_buff *skb, unsigned int type, struct rxts *rxts)
+{
+	u16 *seqid;
+	unsigned int offset;
+	u8 *msgtype, *data = skb_mac_header(skb);
+
+	/* check sequenceID, messageType, 12 bit hash of offset 20-29 */
+
+	switch (type) {
+	case PTP_CLASS_V1_IPV4:
+	case PTP_CLASS_V2_IPV4:
+		offset = ETH_HLEN + IPV4_HLEN(data) + UDP_HLEN;
+		break;
+	case PTP_CLASS_V1_IPV6:
+	case PTP_CLASS_V2_IPV6:
+		offset = OFF_PTP6;
+		break;
+	case PTP_CLASS_V2_L2:
+		offset = ETH_HLEN;
+		break;
+	case PTP_CLASS_V2_VLAN:
+		offset = ETH_HLEN + VLAN_HLEN;
+		break;
+	default:
+		return 0;
+	}
+
+	if (skb->len + ETH_HLEN < offset + OFF_PTP_SEQUENCE_ID + sizeof(*seqid))
+		return 0;
+
+	if (unlikely(type & PTP_CLASS_V1))
+		msgtype = data + offset + OFF_PTP_CONTROL;
+	else
+		msgtype = data + offset;
+
+	seqid = (u16 *)(data + offset + OFF_PTP_SEQUENCE_ID);
+
+	return (rxts->msgtype == (*msgtype & 0xf) &&
+		rxts->seqid   == ntohs(*seqid));
+}
+
+static void dp83640_free_clocks(void)
+{
+	struct dp83640_clock *clock;
+	struct list_head *this, *next;
+
+	mutex_lock(&phyter_clocks_lock);
+
+	list_for_each_safe(this, next, &phyter_clocks) {
+		clock = list_entry(this, struct dp83640_clock, list);
+		if (!list_empty(&clock->phylist)) {
+			pr_warning("phy list non-empty while unloading");
+			BUG();
+		}
+		list_del(&clock->list);
+		mutex_destroy(&clock->extreg_lock);
+		mutex_destroy(&clock->clock_lock);
+		put_device(&clock->bus->dev);
+		kfree(clock);
+	}
+
+	mutex_unlock(&phyter_clocks_lock);
+}
+
+static void dp83640_clock_init(struct dp83640_clock *clock, struct mii_bus *bus)
+{
+	INIT_LIST_HEAD(&clock->list);
+	clock->bus = bus;
+	mutex_init(&clock->extreg_lock);
+	mutex_init(&clock->clock_lock);
+	INIT_LIST_HEAD(&clock->phylist);
+	clock->caps.owner = THIS_MODULE;
+	sprintf(clock->caps.name, "dp83640 timer");
+	clock->caps.max_adj	= 1953124;
+	clock->caps.n_alarm	= 0;
+	clock->caps.n_ext_ts	= N_EXT_TS;
+	clock->caps.n_per_out	= 0;
+	clock->caps.pps		= 0;
+	clock->caps.adjfreq	= ptp_dp83640_adjfreq;
+	clock->caps.adjtime	= ptp_dp83640_adjtime;
+	clock->caps.gettime	= ptp_dp83640_gettime;
+	clock->caps.settime	= ptp_dp83640_settime;
+	clock->caps.enable	= ptp_dp83640_enable;
+	/*
+	 * Get a reference to this bus instance.
+	 */
+	get_device(&bus->dev);
+}
+
+static int choose_this_phy(struct dp83640_clock *clock,
+			   struct phy_device *phydev)
+{
+	if (chosen_phy == -1 && !clock->chosen)
+		return 1;
+
+	if (chosen_phy == phydev->addr)
+		return 1;
+
+	return 0;
+}
+
+static struct dp83640_clock *dp83640_clock_get(struct dp83640_clock *clock)
+{
+	if (clock)
+		mutex_lock(&clock->clock_lock);
+	return clock;
+}
+
+/*
+ * Look up and lock a clock by bus instance.
+ * If there is no clock for this bus, then create it first.
+ */
+static struct dp83640_clock *dp83640_clock_get_bus(struct mii_bus *bus)
+{
+	struct dp83640_clock *clock = NULL, *tmp;
+	struct list_head *this;
+
+	mutex_lock(&phyter_clocks_lock);
+
+	list_for_each(this, &phyter_clocks) {
+		tmp = list_entry(this, struct dp83640_clock, list);
+		if (tmp->bus == bus) {
+			clock = tmp;
+			break;
+		}
+	}
+	if (clock)
+		goto out;
+
+	clock = kzalloc(sizeof(struct dp83640_clock), GFP_KERNEL);
+	if (!clock)
+		goto out;
+
+	dp83640_clock_init(clock, bus);
+	list_add_tail(&phyter_clocks, &clock->list);
+out:
+	mutex_unlock(&phyter_clocks_lock);
+
+	return dp83640_clock_get(clock);
+}
+
+static void dp83640_clock_put(struct dp83640_clock *clock)
+{
+	mutex_unlock(&clock->clock_lock);
+}
+
+static int dp83640_probe(struct phy_device *phydev)
+{
+	struct dp83640_clock *clock;
+	struct dp83640_private *dp83640;
+	int err = -ENOMEM, i;
+
+	if (phydev->addr == BROADCAST_ADDR)
+		return 0;
+
+	clock = dp83640_clock_get_bus(phydev->bus);
+	if (!clock)
+		goto no_clock;
+
+	dp83640 = kzalloc(sizeof(struct dp83640_private), GFP_KERNEL);
+	if (!dp83640)
+		goto no_memory;
+
+	dp83640->phydev = phydev;
+	INIT_WORK(&dp83640->ts_work, rx_timestamp_work);
+
+	INIT_LIST_HEAD(&dp83640->rxts);
+	INIT_LIST_HEAD(&dp83640->rxpool);
+	for (i = 0; i < MAX_RXTS; i++)
+		list_add(&dp83640->rx_pool_data[i].list, &dp83640->rxpool);
+
+	phydev->priv = dp83640;
+
+	spin_lock_init(&dp83640->rx_lock);
+	skb_queue_head_init(&dp83640->rx_queue);
+	skb_queue_head_init(&dp83640->tx_queue);
+
+	dp83640->clock = clock;
+
+	if (choose_this_phy(clock, phydev)) {
+		clock->chosen = dp83640;
+		clock->ptp_clock = ptp_clock_register(&clock->caps);
+		if (IS_ERR(clock->ptp_clock)) {
+			err = PTR_ERR(clock->ptp_clock);
+			goto no_register;
+		}
+	} else
+		list_add_tail(&dp83640->list, &clock->phylist);
+
+	if (clock->chosen && !list_empty(&clock->phylist))
+		recalibrate(clock);
+	else
+		enable_broadcast(dp83640->phydev, clock->page, 1);
+
+	dp83640_clock_put(clock);
+	return 0;
+
+no_register:
+	clock->chosen = NULL;
+	kfree(dp83640);
+no_memory:
+	dp83640_clock_put(clock);
+no_clock:
+	return err;
+}
+
+static void dp83640_remove(struct phy_device *phydev)
+{
+	struct dp83640_clock *clock;
+	struct list_head *this, *next;
+	struct dp83640_private *tmp, *dp83640 = phydev->priv;
+
+	if (phydev->addr == BROADCAST_ADDR)
+		return;
+
+	enable_status_frames(phydev, false);
+	cancel_work_sync(&dp83640->ts_work);
+
+	clock = dp83640_clock_get(dp83640->clock);
+
+	if (dp83640 == clock->chosen) {
+		ptp_clock_unregister(clock->ptp_clock);
+		clock->chosen = NULL;
+	} else {
+		list_for_each_safe(this, next, &clock->phylist) {
+			tmp = list_entry(this, struct dp83640_private, list);
+			if (tmp == dp83640) {
+				list_del_init(&tmp->list);
+				break;
+			}
+		}
+	}
+
+	dp83640_clock_put(clock);
+	kfree(dp83640);
+}
+
+static int dp83640_hwtstamp(struct phy_device *phydev, struct ifreq *ifr)
+{
+	struct dp83640_private *dp83640 = phydev->priv;
+	struct hwtstamp_config cfg;
+	u16 txcfg0, rxcfg0;
+
+	if (copy_from_user(&cfg, ifr->ifr_data, sizeof(cfg)))
+		return -EFAULT;
+
+	if (cfg.flags) /* reserved for future extensions */
+		return -EINVAL;
+
+	switch (cfg.tx_type) {
+	case HWTSTAMP_TX_OFF:
+		dp83640->hwts_tx_en = 0;
+		break;
+	case HWTSTAMP_TX_ON:
+		dp83640->hwts_tx_en = 1;
+		break;
+	default:
+		return -ERANGE;
+	}
+
+	switch (cfg.rx_filter) {
+	case HWTSTAMP_FILTER_NONE:
+		dp83640->hwts_rx_en = 0;
+		dp83640->layer = 0;
+		dp83640->version = 0;
+		break;
+	case HWTSTAMP_FILTER_PTP_V1_L4_EVENT:
+	case HWTSTAMP_FILTER_PTP_V1_L4_SYNC:
+	case HWTSTAMP_FILTER_PTP_V1_L4_DELAY_REQ:
+		dp83640->hwts_rx_en = 1;
+		dp83640->layer = LAYER4;
+		dp83640->version = 1;
+		break;
+	case HWTSTAMP_FILTER_PTP_V2_L4_EVENT:
+	case HWTSTAMP_FILTER_PTP_V2_L4_SYNC:
+	case HWTSTAMP_FILTER_PTP_V2_L4_DELAY_REQ:
+		dp83640->hwts_rx_en = 1;
+		dp83640->layer = LAYER4;
+		dp83640->version = 2;
+		break;
+	case HWTSTAMP_FILTER_PTP_V2_L2_EVENT:
+	case HWTSTAMP_FILTER_PTP_V2_L2_SYNC:
+	case HWTSTAMP_FILTER_PTP_V2_L2_DELAY_REQ:
+		dp83640->hwts_rx_en = 1;
+		dp83640->layer = LAYER2;
+		dp83640->version = 2;
+		break;
+	case HWTSTAMP_FILTER_PTP_V2_EVENT:
+	case HWTSTAMP_FILTER_PTP_V2_SYNC:
+	case HWTSTAMP_FILTER_PTP_V2_DELAY_REQ:
+		dp83640->hwts_rx_en = 1;
+		dp83640->layer = LAYER4|LAYER2;
+		dp83640->version = 2;
+		break;
+	default:
+		return -ERANGE;
+	}
+
+	txcfg0 = (dp83640->version & TX_PTP_VER_MASK) << TX_PTP_VER_SHIFT;
+	rxcfg0 = (dp83640->version & TX_PTP_VER_MASK) << TX_PTP_VER_SHIFT;
+
+	if (dp83640->layer & LAYER2) {
+		txcfg0 |= TX_L2_EN;
+		rxcfg0 |= RX_L2_EN;
+	}
+	if (dp83640->layer & LAYER4) {
+		txcfg0 |= TX_IPV6_EN | TX_IPV4_EN;
+		rxcfg0 |= RX_IPV6_EN | RX_IPV4_EN;
+	}
+
+	if (dp83640->hwts_tx_en)
+		txcfg0 |= TX_TS_EN;
+
+	if (dp83640->hwts_rx_en)
+		rxcfg0 |= RX_TS_EN;
+
+	mutex_lock(&dp83640->clock->extreg_lock);
+
+	if (dp83640->hwts_tx_en || dp83640->hwts_rx_en) {
+		enable_status_frames(phydev, true);
+		ext_write(0, phydev, PAGE4, PTP_CTL, PTP_ENABLE);
+	}
+
+	ext_write(0, phydev, PAGE5, PTP_TXCFG0, txcfg0);
+	ext_write(0, phydev, PAGE5, PTP_RXCFG0, rxcfg0);
+
+	mutex_unlock(&dp83640->clock->extreg_lock);
+
+	return copy_to_user(ifr->ifr_data, &cfg, sizeof(cfg)) ? -EFAULT : 0;
+}
+
+static void rx_timestamp_work(struct work_struct *work)
+{
+	struct dp83640_private *dp83640 =
+		container_of(work, struct dp83640_private, ts_work);
+	struct list_head *this, *next;
+	struct rxts *rxts;
+	struct skb_shared_hwtstamps *shhwtstamps;
+	struct sk_buff *skb;
+	unsigned int type;
+	unsigned long flags;
+
+	/* Deliver each deferred packet, with or without a time stamp. */
+
+	while ((skb = skb_dequeue(&dp83640->rx_queue)) != NULL) {
+		type = SKB_PTP_TYPE(skb);
+		spin_lock_irqsave(&dp83640->rx_lock, flags);
+		list_for_each_safe(this, next, &dp83640->rxts) {
+			rxts = list_entry(this, struct rxts, list);
+			if (match(skb, type, rxts)) {
+				shhwtstamps = skb_hwtstamps(skb);
+				memset(shhwtstamps, 0, sizeof(*shhwtstamps));
+				shhwtstamps->hwtstamp = ns_to_ktime(rxts->ns);
+				list_del_init(&rxts->list);
+				list_add(&rxts->list, &dp83640->rxpool);
+				break;
+			}
+		}
+		spin_unlock_irqrestore(&dp83640->rx_lock, flags);
+		netif_rx(skb);
+	}
+
+	/* Clear out expired time stamps. */
+
+	spin_lock_irqsave(&dp83640->rx_lock, flags);
+	prune_rx_ts(dp83640);
+	spin_unlock_irqrestore(&dp83640->rx_lock, flags);
+}
+
+static bool dp83640_rxtstamp(struct phy_device *phydev,
+			     struct sk_buff *skb, int type)
+{
+	struct dp83640_private *dp83640 = phydev->priv;
+
+	if (!dp83640->hwts_rx_en)
+		return false;
+
+	if (is_status_frame(skb, type)) {
+		decode_status_frame(dp83640, skb);
+		/* Let the stack drop this frame. */
+		return false;
+	}
+
+	SKB_PTP_TYPE(skb) = type;
+	skb_queue_tail(&dp83640->rx_queue, skb);
+	schedule_work(&dp83640->ts_work);
+
+	return true;
+}
+
+static void dp83640_txtstamp(struct phy_device *phydev,
+			     struct sk_buff *skb, int type)
+{
+	struct dp83640_private *dp83640 = phydev->priv;
+
+	if (!dp83640->hwts_tx_en) {
+		kfree_skb(skb);
+		return;
+	}
+	skb_queue_tail(&dp83640->tx_queue, skb);
+	schedule_work(&dp83640->ts_work);
+}
+
+static struct phy_driver dp83640_driver = {
+	.phy_id		= DP83640_PHY_ID,
+	.phy_id_mask	= 0xfffffff0,
+	.name		= "NatSemi DP83640",
+	.features	= PHY_BASIC_FEATURES,
+	.flags		= 0,
+	.probe		= dp83640_probe,
+	.remove		= dp83640_remove,
+	.config_aneg	= genphy_config_aneg,
+	.read_status	= genphy_read_status,
+	.hwtstamp	= dp83640_hwtstamp,
+	.rxtstamp	= dp83640_rxtstamp,
+	.txtstamp	= dp83640_txtstamp,
+	.driver		= {.owner = THIS_MODULE,}
+};
+
+static int __init dp83640_init(void)
+{
+	return phy_driver_register(&dp83640_driver);
+}
+
+static void __exit dp83640_exit(void)
+{
+	dp83640_free_clocks();
+	phy_driver_unregister(&dp83640_driver);
+}
+
+MODULE_DESCRIPTION("National Semiconductor DP83640 PHY driver");
+MODULE_AUTHOR("Richard Cochran <richard.cochran-3mrvs1K0uXizZXS1Dc/lvw@public.gmane.org>");
+MODULE_LICENSE("GPL");
+
+module_init(dp83640_init);
+module_exit(dp83640_exit);
+
+static struct mdio_device_id dp83640_tbl[] = {
+	{ DP83640_PHY_ID, 0xfffffff0 },
+	{ }
+};
+
+MODULE_DEVICE_TABLE(mdio, dp83640_tbl);
diff --git a/drivers/net/phy/dp83640_reg.h b/drivers/net/phy/dp83640_reg.h
new file mode 100644
index 0000000..e7fe411
--- /dev/null
+++ b/drivers/net/phy/dp83640_reg.h
@@ -0,0 +1,267 @@
+/* dp83640_reg.h
+ * Generated by regen.tcl on Thu Feb 17 10:02:48 AM CET 2011
+ */
+#ifndef HAVE_DP83640_REGISTERS
+#define HAVE_DP83640_REGISTERS
+
+#define PAGE0                     0x0000
+#define PHYCR2                    0x001c /* PHY Control Register 2 */
+
+#define PAGE4                     0x0004
+#define PTP_CTL                   0x0014 /* PTP Control Register */
+#define PTP_TDR                   0x0015 /* PTP Time Data Register */
+#define PTP_STS                   0x0016 /* PTP Status Register */
+#define PTP_TSTS                  0x0017 /* PTP Trigger Status Register */
+#define PTP_RATEL                 0x0018 /* PTP Rate Low Register */
+#define PTP_RATEH                 0x0019 /* PTP Rate High Register */
+#define PTP_RDCKSUM               0x001a /* PTP Read Checksum */
+#define PTP_WRCKSUM               0x001b /* PTP Write Checksum */
+#define PTP_TXTS                  0x001c /* PTP Transmit Timestamp Register, in four 16-bit reads */
+#define PTP_RXTS                  0x001d /* PTP Receive Timestamp Register, in six? 16-bit reads */
+#define PTP_ESTS                  0x001e /* PTP Event Status Register */
+#define PTP_EDATA                 0x001f /* PTP Event Data Register */
+
+#define PAGE5                     0x0005
+#define PTP_TRIG                  0x0014 /* PTP Trigger Configuration Register */
+#define PTP_EVNT                  0x0015 /* PTP Event Configuration Register */
+#define PTP_TXCFG0                0x0016 /* PTP Transmit Configuration Register 0 */
+#define PTP_TXCFG1                0x0017 /* PTP Transmit Configuration Register 1 */
+#define PSF_CFG0                  0x0018 /* PHY Status Frame Configuration Register 0 */
+#define PTP_RXCFG0                0x0019 /* PTP Receive Configuration Register 0 */
+#define PTP_RXCFG1                0x001a /* PTP Receive Configuration Register 1 */
+#define PTP_RXCFG2                0x001b /* PTP Receive Configuration Register 2 */
+#define PTP_RXCFG3                0x001c /* PTP Receive Configuration Register 3 */
+#define PTP_RXCFG4                0x001d /* PTP Receive Configuration Register 4 */
+#define PTP_TRDL                  0x001e /* PTP Temporary Rate Duration Low Register */
+#define PTP_TRDH                  0x001f /* PTP Temporary Rate Duration High Register */
+
+#define PAGE6                     0x0006
+#define PTP_COC                   0x0014 /* PTP Clock Output Control Register */
+#define PSF_CFG1                  0x0015 /* PHY Status Frame Configuration Register 1 */
+#define PSF_CFG2                  0x0016 /* PHY Status Frame Configuration Register 2 */
+#define PSF_CFG3                  0x0017 /* PHY Status Frame Configuration Register 3 */
+#define PSF_CFG4                  0x0018 /* PHY Status Frame Configuration Register 4 */
+#define PTP_SFDCFG                0x0019 /* PTP SFD Configuration Register */
+#define PTP_INTCTL                0x001a /* PTP Interrupt Control Register */
+#define PTP_CLKSRC                0x001b /* PTP Clock Source Register */
+#define PTP_ETR                   0x001c /* PTP Ethernet Type Register */
+#define PTP_OFF                   0x001d /* PTP Offset Register */
+#define PTP_GPIOMON               0x001e /* PTP GPIO Monitor Register */
+#define PTP_RXHASH                0x001f /* PTP Receive Hash Register */
+
+/* Bit definitions for the PHYCR2 register */
+#define BC_WRITE                  (1<<11) /* Broadcast Write Enable */
+
+/* Bit definitions for the PTP_CTL register */
+#define TRIG_SEL_SHIFT            (10)    /* PTP Trigger Select */
+#define TRIG_SEL_MASK             (0x7)
+#define TRIG_DIS                  (1<<9)  /* Disable PTP Trigger */
+#define TRIG_EN                   (1<<8)  /* Enable PTP Trigger */
+#define TRIG_READ                 (1<<7)  /* Read PTP Trigger */
+#define TRIG_LOAD                 (1<<6)  /* Load PTP Trigger */
+#define PTP_RD_CLK                (1<<5)  /* Read PTP Clock */
+#define PTP_LOAD_CLK              (1<<4)  /* Load PTP Clock */
+#define PTP_STEP_CLK              (1<<3)  /* Step PTP Clock */
+#define PTP_ENABLE                (1<<2)  /* Enable PTP Clock */
+#define PTP_DISABLE               (1<<1)  /* Disable PTP Clock */
+#define PTP_RESET                 (1<<0)  /* Reset PTP Clock */
+
+/* Bit definitions for the PTP_STS register */
+#define TXTS_RDY                  (1<<11) /* Transmit Timestamp Ready */
+#define RXTS_RDY                  (1<<10) /* Receive Timestamp Ready */
+#define TRIG_DONE                 (1<<9)  /* PTP Trigger Done */
+#define EVENT_RDY                 (1<<8)  /* PTP Event Timestamp Ready */
+#define TXTS_IE                   (1<<3)  /* Transmit Timestamp Interrupt Enable */
+#define RXTS_IE                   (1<<2)  /* Receive Timestamp Interrupt Enable */
+#define TRIG_IE                   (1<<1)  /* Trigger Interrupt Enable */
+#define EVENT_IE                  (1<<0)  /* Event Interrupt Enable */
+
+/* Bit definitions for the PTP_TSTS register */
+#define TRIG7_ERROR               (1<<15) /* Trigger 7 Error */
+#define TRIG7_ACTIVE              (1<<14) /* Trigger 7 Active */
+#define TRIG6_ERROR               (1<<13) /* Trigger 6 Error */
+#define TRIG6_ACTIVE              (1<<12) /* Trigger 6 Active */
+#define TRIG5_ERROR               (1<<11) /* Trigger 5 Error */
+#define TRIG5_ACTIVE              (1<<10) /* Trigger 5 Active */
+#define TRIG4_ERROR               (1<<9)  /* Trigger 4 Error */
+#define TRIG4_ACTIVE              (1<<8)  /* Trigger 4 Active */
+#define TRIG3_ERROR               (1<<7)  /* Trigger 3 Error */
+#define TRIG3_ACTIVE              (1<<6)  /* Trigger 3 Active */
+#define TRIG2_ERROR               (1<<5)  /* Trigger 2 Error */
+#define TRIG2_ACTIVE              (1<<4)  /* Trigger 2 Active */
+#define TRIG1_ERROR               (1<<3)  /* Trigger 1 Error */
+#define TRIG1_ACTIVE              (1<<2)  /* Trigger 1 Active */
+#define TRIG0_ERROR               (1<<1)  /* Trigger 0 Error */
+#define TRIG0_ACTIVE              (1<<0)  /* Trigger 0 Active */
+
+/* Bit definitions for the PTP_RATEH register */
+#define PTP_RATE_DIR              (1<<15) /* PTP Rate Direction */
+#define PTP_TMP_RATE              (1<<14) /* PTP Temporary Rate */
+#define PTP_RATE_HI_SHIFT         (0)     /* PTP Rate High 10-bits */
+#define PTP_RATE_HI_MASK          (0x3ff)
+
+/* Bit definitions for the PTP_ESTS register */
+#define EVNTS_MISSED_SHIFT        (8)     /* Indicates number of events missed */
+#define EVNTS_MISSED_MASK         (0x7)
+#define EVNT_TS_LEN_SHIFT         (6)     /* Indicates length of the Timestamp field in 16-bit words minus 1 */
+#define EVNT_TS_LEN_MASK          (0x3)
+#define EVNT_RF                   (1<<5)  /* Indicates whether the event is a rise or falling event */
+#define EVNT_NUM_SHIFT            (2)     /* Indicates Event Timestamp Unit which detected an event */
+#define EVNT_NUM_MASK             (0x7)
+#define MULT_EVNT                 (1<<1)  /* Indicates multiple events were detected at the same time */
+#define EVENT_DET                 (1<<0)  /* PTP Event Detected */
+
+/* Bit definitions for the PTP_EDATA register */
+#define E7_RISE                   (1<<15) /* Indicates direction of Event 7 */
+#define E7_DET                    (1<<14) /* Indicates Event 7 detected */
+#define E6_RISE                   (1<<13) /* Indicates direction of Event 6 */
+#define E6_DET                    (1<<12) /* Indicates Event 6 detected */
+#define E5_RISE                   (1<<11) /* Indicates direction of Event 5 */
+#define E5_DET                    (1<<10) /* Indicates Event 5 detected */
+#define E4_RISE                   (1<<9)  /* Indicates direction of Event 4 */
+#define E4_DET                    (1<<8)  /* Indicates Event 4 detected */
+#define E3_RISE                   (1<<7)  /* Indicates direction of Event 3 */
+#define E3_DET                    (1<<6)  /* Indicates Event 3 detected */
+#define E2_RISE                   (1<<5)  /* Indicates direction of Event 2 */
+#define E2_DET                    (1<<4)  /* Indicates Event 2 detected */
+#define E1_RISE                   (1<<3)  /* Indicates direction of Event 1 */
+#define E1_DET                    (1<<2)  /* Indicates Event 1 detected */
+#define E0_RISE                   (1<<1)  /* Indicates direction of Event 0 */
+#define E0_DET                    (1<<0)  /* Indicates Event 0 detected */
+
+/* Bit definitions for the PTP_TRIG register */
+#define TRIG_PULSE                (1<<15) /* generate a Pulse rather than a single edge */
+#define TRIG_PER                  (1<<14) /* generate a periodic signal */
+#define TRIG_IF_LATE              (1<<13) /* trigger immediately if already past */
+#define TRIG_NOTIFY               (1<<12) /* Trigger Notification Enable */
+#define TRIG_GPIO_SHIFT           (8)     /* Trigger GPIO Connection, value 1-12 */
+#define TRIG_GPIO_MASK            (0xf)
+#define TRIG_TOGGLE               (1<<7)  /* Trigger Toggle Mode Enable */
+#define TRIG_CSEL_SHIFT           (1)     /* Trigger Configuration Select */
+#define TRIG_CSEL_MASK            (0x7)
+#define TRIG_WR                   (1<<0)  /* Trigger Configuration Write */
+
+/* Bit definitions for the PTP_EVNT register */
+#define EVNT_RISE                 (1<<14) /* Event Rise Detect Enable */
+#define EVNT_FALL                 (1<<13) /* Event Fall Detect Enable */
+#define EVNT_SINGLE               (1<<12) /* enable single event capture operation */
+#define EVNT_GPIO_SHIFT           (8)     /* Event GPIO Connection, value 1-12 */
+#define EVNT_GPIO_MASK            (0xf)
+#define EVNT_SEL_SHIFT            (1)     /* Event Select */
+#define EVNT_SEL_MASK             (0x7)
+#define EVNT_WR                   (1<<0)  /* Event Configuration Write */
+
+/* Bit definitions for the PTP_TXCFG0 register */
+#define SYNC_1STEP                (1<<15) /* insert timestamp into transmit Sync Messages */
+#define DR_INSERT                 (1<<13) /* Insert Delay_Req Timestamp in Delay_Resp (dangerous) */
+#define NTP_TS_EN                 (1<<12) /* Enable Timestamping of NTP Packets */
+#define IGNORE_2STEP              (1<<11) /* Ignore Two_Step flag for One-Step operation */
+#define CRC_1STEP                 (1<<10) /* Disable checking of CRC for One-Step operation */
+#define CHK_1STEP                 (1<<9)  /* Enable UDP Checksum correction for One-Step Operation */
+#define IP1588_EN                 (1<<8)  /* Enable IEEE 1588 defined IP address filter */
+#define TX_L2_EN                  (1<<7)  /* Layer2 Timestamp Enable */
+#define TX_IPV6_EN                (1<<6)  /* IPv6 Timestamp Enable */
+#define TX_IPV4_EN                (1<<5)  /* IPv4 Timestamp Enable */
+#define TX_PTP_VER_SHIFT          (1)     /* Enable Timestamp capture for IEEE 1588 version X */
+#define TX_PTP_VER_MASK           (0xf)
+#define TX_TS_EN                  (1<<0)  /* Transmit Timestamp Enable */
+
+/* Bit definitions for the PTP_TXCFG1 register */
+#define BYTE0_MASK_SHIFT          (8)     /* Bit mask to be used for matching Byte0 of the PTP Message */
+#define BYTE0_MASK_MASK           (0xff)
+#define BYTE0_DATA_SHIFT          (0)     /* Data to be used for matching Byte0 of the PTP Message */
+#define BYTE0_DATA_MASK           (0xff)
+
+/* Bit definitions for the PSF_CFG0 register */
+#define MAC_SRC_ADD_SHIFT         (11)    /* Status Frame Mac Source Address */
+#define MAC_SRC_ADD_MASK          (0x3)
+#define MIN_PRE_SHIFT             (8)     /* Status Frame Minimum Preamble */
+#define MIN_PRE_MASK              (0x7)
+#define PSF_ENDIAN                (1<<7)  /* Status Frame Endian Control */
+#define PSF_IPV4                  (1<<6)  /* Status Frame IPv4 Enable */
+#define PSF_PCF_RD                (1<<5)  /* Control Frame Read PHY Status Frame Enable */
+#define PSF_ERR_EN                (1<<4)  /* Error PHY Status Frame Enable */
+#define PSF_TXTS_EN               (1<<3)  /* Transmit Timestamp PHY Status Frame Enable */
+#define PSF_RXTS_EN               (1<<2)  /* Receive Timestamp PHY Status Frame Enable */
+#define PSF_TRIG_EN               (1<<1)  /* Trigger PHY Status Frame Enable */
+#define PSF_EVNT_EN               (1<<0)  /* Event PHY Status Frame Enable */
+
+/* Bit definitions for the PTP_RXCFG0 register */
+#define DOMAIN_EN                 (1<<15) /* Domain Match Enable */
+#define ALT_MAST_DIS              (1<<14) /* Alternate Master Timestamp Disable */
+#define USER_IP_SEL               (1<<13) /* Selects portion of IP address accessible thru PTP_RXCFG2 */
+#define USER_IP_EN                (1<<12) /* Enable User-programmed IP address filter */
+#define RX_SLAVE                  (1<<11) /* Receive Slave Only */
+#define IP1588_EN_SHIFT           (8)     /* Enable IEEE 1588 defined IP address filters */
+#define IP1588_EN_MASK            (0xf)
+#define RX_L2_EN                  (1<<7)  /* Layer2 Timestamp Enable */
+#define RX_IPV6_EN                (1<<6)  /* IPv6 Timestamp Enable */
+#define RX_IPV4_EN                (1<<5)  /* IPv4 Timestamp Enable */
+#define RX_PTP_VER_SHIFT          (1)     /* Enable Timestamp capture for IEEE 1588 version X */
+#define RX_PTP_VER_MASK           (0xf)
+#define RX_TS_EN                  (1<<0)  /* Receive Timestamp Enable */
+
+/* Bit definitions for the PTP_RXCFG1 register */
+#define BYTE0_MASK_SHIFT          (8)     /* Bit mask to be used for matching Byte0 of the PTP Message */
+#define BYTE0_MASK_MASK           (0xff)
+#define BYTE0_DATA_SHIFT          (0)     /* Data to be used for matching Byte0 of the PTP Message */
+#define BYTE0_DATA_MASK           (0xff)
+
+/* Bit definitions for the PTP_RXCFG3 register */
+#define TS_MIN_IFG_SHIFT          (12)    /* Minimum Inter-frame Gap */
+#define TS_MIN_IFG_MASK           (0xf)
+#define ACC_UDP                   (1<<11) /* Record Timestamp if UDP Checksum Error */
+#define ACC_CRC                   (1<<10) /* Record Timestamp if CRC Error */
+#define TS_APPEND                 (1<<9)  /* Append Timestamp for L2 */
+#define TS_INSERT                 (1<<8)  /* Enable Timestamp Insertion */
+#define PTP_DOMAIN_SHIFT          (0)     /* PTP Message domainNumber field */
+#define PTP_DOMAIN_MASK           (0xff)
+
+/* Bit definitions for the PTP_RXCFG4 register */
+#define IPV4_UDP_MOD              (1<<15) /* Enable IPV4 UDP Modification */
+#define TS_SEC_EN                 (1<<14) /* Enable Timestamp Seconds */
+#define TS_SEC_LEN_SHIFT          (12)    /* Inserted Timestamp Seconds Length */
+#define TS_SEC_LEN_MASK           (0x3)
+#define RXTS_NS_OFF_SHIFT         (6)     /* Receive Timestamp Nanoseconds offset */
+#define RXTS_NS_OFF_MASK          (0x3f)
+#define RXTS_SEC_OFF_SHIFT        (0)     /* Receive Timestamp Seconds offset */
+#define RXTS_SEC_OFF_MASK         (0x3f)
+
+/* Bit definitions for the PTP_COC register */
+#define PTP_CLKOUT_EN             (1<<15) /* PTP Clock Output Enable */
+#define PTP_CLKOUT_SEL            (1<<14) /* PTP Clock Output Source Select */
+#define PTP_CLKOUT_SPEEDSEL       (1<<13) /* PTP Clock Output I/O Speed Select */
+#define PTP_CLKDIV_SHIFT          (0)     /* PTP Clock Divide-by Value */
+#define PTP_CLKDIV_MASK           (0xff)
+
+/* Bit definitions for the PSF_CFG1 register */
+#define PTPRESERVED_SHIFT         (12)    /* PTP v2 reserved field */
+#define PTPRESERVED_MASK          (0xf)
+#define VERSIONPTP_SHIFT          (8)     /* PTP v2 versionPTP field */
+#define VERSIONPTP_MASK           (0xf)
+#define TRANSPORT_SPECIFIC_SHIFT  (4)     /* PTP v2 Header transportSpecific field */
+#define TRANSPORT_SPECIFIC_MASK   (0xf)
+#define MESSAGETYPE_SHIFT         (0)     /* PTP v2 messageType field */
+#define MESSAGETYPE_MASK          (0xf)
+
+/* Bit definitions for the PTP_SFDCFG register */
+#define TX_SFD_GPIO_SHIFT         (4)     /* TX SFD GPIO Select, value 1-12 */
+#define TX_SFD_GPIO_MASK          (0xf)
+#define RX_SFD_GPIO_SHIFT         (0)     /* RX SFD GPIO Select, value 1-12 */
+#define RX_SFD_GPIO_MASK          (0xf)
+
+/* Bit definitions for the PTP_INTCTL register */
+#define PTP_INT_GPIO_SHIFT        (0)     /* PTP Interrupt GPIO Select */
+#define PTP_INT_GPIO_MASK         (0xf)
+
+/* Bit definitions for the PTP_CLKSRC register */
+#define CLK_SRC_SHIFT             (14)    /* PTP Clock Source Select */
+#define CLK_SRC_MASK              (0x3)
+#define CLK_SRC_PER_SHIFT         (0)     /* PTP Clock Source Period */
+#define CLK_SRC_PER_MASK          (0x7f)
+
+/* Bit definitions for the PTP_OFF register */
+#define PTP_OFFSET_SHIFT          (0)     /* PTP Message offset from preceding header */
+#define PTP_OFFSET_MASK           (0xff)
+
+#endif
diff --git a/drivers/ptp/Kconfig b/drivers/ptp/Kconfig
index fcfafd0..68d7201 100644
--- a/drivers/ptp/Kconfig
+++ b/drivers/ptp/Kconfig
@@ -53,4 +53,23 @@ config PTP_1588_CLOCK_IXP46X
 	  To compile this driver as a module, choose M here: the module
 	  will be called ptp_ixp46x.
 
+comment "Enable PHYLIB and NETWORK_PHY_TIMESTAMPING to see the additional clocks."
+	depends on PTP_1588_CLOCK && (PHYLIB=n || NETWORK_PHY_TIMESTAMPING=n)
+
+config DP83640_PHY
+	tristate "Driver for the National Semiconductor DP83640 PHYTER"
+	depends on PTP_1588_CLOCK
+	depends on NETWORK_PHY_TIMESTAMPING
+	depends on PHYLIB
+	---help---
+	  Supports the DP83640 PHYTER with IEEE 1588 features.
+
+	  This driver adds support for using the DP83640 as a PTP
+	  clock. This clock is only useful if your PTP programs are
+	  getting hardware time stamps on the PTP Ethernet packets
+	  using the SO_TIMESTAMPING API.
+
+	  In order for this to work, your MAC driver must also
+	  implement the skb_tx_timetamp() function.
+
 endmenu
-- 
1.7.0.4
