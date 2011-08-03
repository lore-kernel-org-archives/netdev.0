From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH] Add pch ieee1588 driver for Intel EG20T PCH
Date: Wed, 3 Aug 2011 21:23:32 +0200
Message-ID: <20110803192331.GA11166@riccoc20.at.omicron.at>
References: <1312352861-10955-1-git-send-email-toshiharu-linux@dsn.okisemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: richard.cochran@omicron.at, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, qi.wang@intel.com,
	yong.y.wang@intel.com, joel.clark@intel.com,
	kok.howg.ewe@intel.com, tomoya-linux@dsn.okisemi.com
To: Toshiharu Okada <toshiharu-linux@dsn.okisemi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:52454 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754726Ab1HCTXc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Aug 2011 15:23:32 -0400
Content-Disposition: inline
In-Reply-To: <1312352861-10955-1-git-send-email-toshiharu-linux@dsn.okisemi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 03, 2011 at 03:27:41PM +0900, Toshiharu Okada wrote:
> This patch is for IEEE1588 driver of Intel EG20T PCH.
> EG20T PCH is the platform controller hub that is used in Intel's
> general embedded platform.
> This driver adds support for using the EG20T PCH as a PTP clock.
> 
> Would you review this patch, although this driver has not been tested yet?

Thanks for offering this patch. Please see my comments, below.

> 
> Signed-off-by: Toshiharu Okada <toshiharu-linux@dsn.okisemi.com>
> ---
>  drivers/ptp/Kconfig   |   13 +
>  drivers/ptp/Makefile  |    1 +
>  drivers/ptp/ptp_pch.c |  629 +++++++++++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 643 insertions(+), 0 deletions(-)
>  create mode 100644 drivers/ptp/ptp_pch.c
> 
> diff --git a/drivers/ptp/Kconfig b/drivers/ptp/Kconfig
> index 68d7201..cd9bc3b 100644
> --- a/drivers/ptp/Kconfig
> +++ b/drivers/ptp/Kconfig
> @@ -72,4 +72,17 @@ config DP83640_PHY
>  	  In order for this to work, your MAC driver must also
>  	  implement the skb_tx_timetamp() function.
>  
> +config PTP_1588_CLOCK_PCH
> +	tristate "Intel PCH EG20T as PTP clock"
> +	depends on PTP_1588_CLOCK
> +	depends on PCH_GBE
> +	help
> +	  This driver adds support for using the PCH EG20T as a PTP
> +	  clock. This clock is only useful if your PTP programs are
> +	  getting hardware time stamps on the PTP Ethernet packets
> +	  using the SO_TIMESTAMPING API.
> +
> +	  To compile this driver as a module, choose M here: the module
> +	  will be called ptp_pch.
> +
>  endmenu
> diff --git a/drivers/ptp/Makefile b/drivers/ptp/Makefile
> index f6933e8..8b58597 100644
> --- a/drivers/ptp/Makefile
> +++ b/drivers/ptp/Makefile
> @@ -5,3 +5,4 @@
>  ptp-y					:= ptp_clock.o ptp_chardev.o ptp_sysfs.o
>  obj-$(CONFIG_PTP_1588_CLOCK)		+= ptp.o
>  obj-$(CONFIG_PTP_1588_CLOCK_IXP46X)	+= ptp_ixp46x.o
> +obj-$(CONFIG_PTP_1588_CLOCK_PCH)	+= ptp_pch.o
> diff --git a/drivers/ptp/ptp_pch.c b/drivers/ptp/ptp_pch.c
> new file mode 100644
> index 0000000..0a804dc
> --- /dev/null
> +++ b/drivers/ptp/ptp_pch.c
> @@ -0,0 +1,629 @@
> +/*
> + * PTP 1588 clock using the EG20T PCH
> + *
> + * Copyright (C) 2010 OMICRON electronics GmbH
> + * Copyright (C) 2010 OKI SEMICONDUCTOR Co., LTD.
> + *
> + * This code was derived from the IXP46X driver.
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License as published by
> + * the Free Software Foundation; version 2 of the License.
> + *
> + * This program is distributed in the hope that it will be useful,
> + * but WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + * GNU General Public License for more details.
> + *
> + * You should have received a copy of the GNU General Public License
> + * along with this program; if not, write to the Free Software
> + * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307, USA.
> + */
> +
> +#include <linux/device.h>
> +#include <linux/err.h>
> +#include <linux/init.h>
> +#include <linux/interrupt.h>
> +#include <linux/io.h>
> +#include <linux/irq.h>
> +#include <linux/kernel.h>
> +#include <linux/module.h>
> +#include <linux/pci.h>
> +#include <linux/ptp_clock_kernel.h>
> +
> +#define STATION_ADDR_LEN	20
> +#define PCI_DEVICE_ID_PCH_1588	0x8819
> +#define IO_MEM_BAR 1
> +
> +
> +/* Register read/write macros */
> +#define PCH_BIT_SET_CHECK(addr, bitmask) \
> +		((ioread32(addr) & (bitmask)) == (bitmask))
> +#define PCH_SET_ADDR_BIT(addr, bitmask)\
> +		iowrite32((ioread32(addr) | (bitmask)), (addr))
> +#define PCH_CLR_ADDR_BIT(addr, bitmask)\
> +		iowrite32((ioread32(addr) & ~(bitmask)), (addr))

I don't really like macros of this sort, just to set and clear
register bits. It doesn't make any fewer lines nor does it clarify the
code. Every driver author will know what is meant by the plain old C,
like:

    x = x | mask;
    x = x & ~mask;

Also, you should consider whether you need to protect against
concurrent access on a register.

> +
> +#define DEFAULT_ADDEND 0xF0000029
> +#define TICKS_NS_SHIFT  4

This driver is based on my ixp46x driver, which is fine because,
looking at the data sheet, it appears that the time stamping unit in
the EG20T PCH is fairly similar.

However, I doubt that these ADDEND and SHIFT values will work for you,
since they were calculated for the frequency compensated clock on the
IXP. They reflect an input clock frequency of 66.666666 MHz and a
nominal frequency of 62.5 MHz (or a period of 16 nanoseconds, thus
SHIFT is 4).

Section 14.6.1.10 in the data sheet seems to imply that the input
clock is 50 MHz. In that case you could use a nominal frequency of
31.25 MHz (period 32 ns, SHIFT 5). However, you need to find out
the actual input clock frequency. If this can vary, then the driver
should allow changing these values.

> +#define N_EXT_TS	2
> +
> +enum pch_status {
> +	PCH_SUCCESS,
> +	PCH_INVALIDPARAM,
> +	PCH_NOTIMESTAMP,
> +	PCH_INTERRUPTMODEINUSE,
> +	PCH_FAILED,
> +	PCH_UNSUPPORTED,
> +};
> +/**
> + * struct pch_ts_regs - IEEE 1588 registers
> + */
> +struct pch_ts_regs {
> +	u32 control;
> +	u32 event;
> +	u32 addend;
> +	u32 accum;
> +	u32 test;
> +	u32 ts_compare;
> +	u32 rsystime_lo;
> +	u32 rsystime_hi;
> +	u32 systime_lo;
> +	u32 systime_hi;
> +	u32 trgt_lo;
> +	u32 trgt_hi;
> +	u32 asms_lo;
> +	u32 asms_hi;
> +	u32 amms_lo;
> +	u32 amms_hi;
> +	u32 ch_control;

You never program this register. But I think the "Mode" field should
be set to 2. The other settings really make no sense at all.  Or do
you set this in the MAC driver?

(I wonder why Intel retained the very limited PTP V1 modes from the
IXP time stamping unit.)

> +	u32 ch_event;
> +	u32 tx_snap_lo;
> +	u32 tx_snap_hi;
> +	u32 rx_snap_lo;
> +	u32 rx_snap_hi;
> +	u32 src_uuid_lo;
> +	u32 src_uuid_hi;
> +	u32 can_status;
> +	u32 can_snap_lo;
> +	u32 can_snap_hi;
> +	u32 ts_sel;
> +	u32 ts_st[6];
> +	u32 reserve1[15];
> +	u32 stl_max_set_en;
> +	u32 stl_max_set;
> +	u32 reserve2[13];
> +	u32 srst;
> +};
> +
> +#define PCH_TSC_RESET		(1 << 0)
> +#define PCH_TSC_TTM_MASK	(1 << 1)
> +#define PCH_TSC_ASMS_MASK	(1 << 2)
> +#define PCH_TSC_AMMS_MASK	(1 << 3)
> +#define PCH_TSC_PPSM_MASK	(1 << 4)
> +#define PCH_TSE_TTIPEND		(1 << 1)
> +#define PCH_TSE_SNS		(1 << 2)
> +#define PCH_TSE_SNM		(1 << 3)
> +#define PCH_TSE_PPS		(1 << 4)
> +#define PCH_CC_MM		(1 << 0)
> +#define PCH_CC_TA		(1 << 1)
> +
> +#define PCH_CC_MODE_SHIFT	16
> +#define PCH_CC_MODE_MASK	0x001F0000
> +#define PCH_CC_VERSION		(1 << 31)
> +#define PCH_CE_TXS		(1 << 0)
> +#define PCH_CE_RXS		(1 << 1)
> +#define PCH_CE_OVR		(1 << 0)
> +#define PCH_CE_VAL		(1 << 1)
> +#define PCH_ECS_ETH		(1 << 0)
> +
> +#define PCH_ECS_CAN		(1 << 1)
> +#define PCH_STATION_BYTES	6
> +
> +#define PCH_IEEE1588_ETH	(1 << 0)
> +#define PCH_IEEE1588_CAN	(1 << 1)
> +/**
> + * struct pch_dev - Driver private data
> + */
> +struct pch_dev {
> +	struct pch_ts_regs *regs;
> +	struct ptp_clock *ptp_clock;
> +	struct ptp_clock_info caps;
> +	int exts0_enabled;
> +	int exts1_enabled;
> +
> +	u32 mem_base;
> +	u32 mem_size;
> +	u32 irq;
> +	u32 suspend:1;
> +	u32 initialized:1;
> +	struct pci_dev *pdev;
> +	spinlock_t lock;

It would be nice to have a short comment telling what this lock
protects. (Yes, I know what it protects, but still that is good
practice to have a comment.)

> +};
> +
> +static inline void pch_eth_enable_set(struct pch_dev *chip)
> +{
> +	/* SET the eth_enable bit */
> +	PCH_SET_ADDR_BIT(&chip->regs->ts_sel, PCH_ECS_ETH);
> +}

I really don't like this or the other similar helper functions,
below. They don't make the driver more understandable or shorter.
This function is only used in one place. You need at least two callers
to justify this.

> +
> +/*
> + * Register access functions
> + */
> +
> +static u64 pch_systime_read(struct pch_ts_regs *regs)
> +{
> +	u64 ns;
> +	u32 lo, hi;
> +
> +	lo = ioread32(&regs->systime_lo);
> +	hi = ioread32(&regs->systime_hi);
> +
> +	ns = ((u64) hi) << 32;
> +	ns |= lo;
> +	ns <<= TICKS_NS_SHIFT;

Here 'ns' will only be in nanoseconds when the ADDEND and SHIFT macros
are correct for the actual machine, as I mentioned above.

> +
> +	return ns;
> +}
> +
> +static void pch_systime_write(struct pch_ts_regs *regs, u64 ns)
> +{
> +	u32 hi, lo;
> +
> +	ns >>= TICKS_NS_SHIFT;
> +	hi = ns >> 32;
> +	lo = ns & 0xffffffff;
> +
> +	iowrite32(lo, &regs->systime_lo);
> +	iowrite32(hi, &regs->systime_hi);
> +}
> +

I think the following helper functions ...

> +static inline u32 pch_pps_evt_get(struct pch_dev *chip)
> +{
> +	/* Poll for PPS event */
> +	return PCH_BIT_SET_CHECK(&chip->regs->event, PCH_TSE_PPS);
> +}
> +
> +static inline u32 pch_amms_evt_get(struct pch_dev *chip)
> +{
> +	/* Poll for Auxiliary Master Mode Snapshot Captured event */
> +	return PCH_BIT_SET_CHECK(&chip->regs->event, PCH_TSE_SNM);
> +}
> +
> +static inline u32 pch_asms_evt_get(struct pch_dev *chip)
> +{
> +	/* Poll for Auxiliary Slave Mode Snapshot Captured event */
> +	return PCH_BIT_SET_CHECK(&chip->regs->event, PCH_TSE_SNS);
> +}
> +
> +static inline u32 pch_ttm_evt_get(struct pch_dev *chip)
> +{
> +	/* Poll for Target Time Reached event */
> +	return PCH_BIT_SET_CHECK(&chip->regs->event, PCH_TSE_TTIPEND);
> +}
> +
> +static inline void pch_pps_evt_clear(struct pch_dev *chip)
> +{
> +	/* Clear PPS event */
> +	PCH_SET_ADDR_BIT(&chip->regs->event, PCH_TSE_PPS);
> +}
> +
> +static inline void pch_amms_evt_clear(struct pch_dev *chip)
> +{
> +	/* Clear Auxiliary Master Mode Snapshot Captured event */
> +	PCH_SET_ADDR_BIT(&chip->regs->event, PCH_TSE_SNM);
> +}
> +
> +static inline void pch_asms_evt_clear(struct pch_dev *chip)
> +{
> +	/* Clear Auxiliary Slave Mode Snapshot Captured event */
> +	PCH_SET_ADDR_BIT(&chip->regs->event, PCH_TSE_SNS);
> +}
> +
> +static inline void pch_ttm_evt_clear(struct pch_dev *chip)
> +{
> +	/* Clear Target Time Reached event */
> +	PCH_SET_ADDR_BIT(&chip->regs->event, PCH_TSE_TTIPEND);
> +}

... are just noise and add nothing useful to the driver.

> +
> +static inline void pch_block_reset(struct pch_dev *chip)
> +{
> +	/* Reset Hardware Assist block */
> +	PCH_SET_ADDR_BIT(&chip->regs->control, PCH_TSC_RESET);
> +	PCH_CLR_ADDR_BIT(&chip->regs->control, PCH_TSC_RESET);
> +}
> +
> +/* This function enables all 64 bits in system time registers [high & low].
> +This is a work-around for non continuous value in the SystemTime Register*/
> +static void pch_set_system_time_count(struct pch_dev *chip)
> +{
> +	iowrite32(0x01, &chip->regs->stl_max_set_en);
> +	iowrite32(0xFFFFFFFF, &chip->regs->stl_max_set);
> +	iowrite32(0x00, &chip->regs->stl_max_set_en);
> +}
> +
> +static void pch_reset(struct pch_dev *chip)
> +{
> +	/* Reset Hardware Assist */
> +	pch_block_reset(chip);
> +
> +	/* enable all 32 bits in system time registers */
> +	pch_set_system_time_count(chip);
> +}

These three, above, are okay, since they encapsulate one logical
operation that takes more than one register access.

However, you might consider whether you need locking here.

> +
> +static void pch_eth_enable(struct pch_dev *chip)
> +{
> +	pch_eth_enable_set(chip);
> +}

Again, this helper only has one caller. Why not just set the bit that
you need in line?

> +
> +/*
> + * Interrupt service routine
> + */
> +static irqreturn_t isr(int irq, void *priv)
> +{
> +	struct pch_dev *pch_dev = priv;
> +	struct pch_ts_regs *regs = pch_dev->regs;
> +	struct ptp_clock_event event;
> +	u32 ack = 0, lo, hi, val;
> +
> +	val = ioread32(&regs->event);
> +
> +	if (val & PCH_TSE_SNS) {
> +		ack |= PCH_TSE_SNS;
> +		if (pch_dev->exts0_enabled) {
> +			hi = ioread32(&regs->asms_hi);
> +			lo = ioread32(&regs->asms_lo);
> +			event.type = PTP_CLOCK_EXTTS;
> +			event.index = 0;
> +			event.timestamp = ((u64) hi) << 32;
> +			event.timestamp |= lo;
> +			event.timestamp <<= TICKS_NS_SHIFT;
> +			ptp_clock_event(pch_dev->ptp_clock, &event);
> +		}
> +	}
> +
> +	if (val & PCH_TSE_SNM) {
> +		ack |= PCH_TSE_SNM;
> +		if (pch_dev->exts1_enabled) {
> +			hi = ioread32(&regs->amms_hi);
> +			lo = ioread32(&regs->amms_lo);
> +			event.type = PTP_CLOCK_EXTTS;
> +			event.index = 1;
> +			event.timestamp = ((u64) hi) << 32;
> +			event.timestamp |= lo;
> +			event.timestamp <<= TICKS_NS_SHIFT;
> +			ptp_clock_event(pch_dev->ptp_clock, &event);
> +		}
> +	}
> +
> +	if (val & PCH_TSE_TTIPEND)
> +		ack |= PCH_TSE_TTIPEND; /* this bit seems to be always set */

This ISR code (and much of the rest of the driver) is copied from the
IXP driver. It would be nice to know if it actually works on the atom
hardware. Do have any hardware to try it on?

> +
> +	if (ack) {
> +		iowrite32(ack, &regs->event);
> +		return IRQ_HANDLED;
> +	} else
> +		return IRQ_NONE;
> +}
> +
> +/*
> + * PTP clock operations
> + */
> +
> +static int ptp_pch_adjfreq(struct ptp_clock_info *ptp, s32 ppb)
> +{
> +	u64 adj;
> +	u32 diff, addend;
> +	int neg_adj = 0;
> +	struct pch_dev *pch_dev = container_of(ptp, struct pch_dev, caps);
> +	struct pch_ts_regs *regs = pch_dev->regs;
> +
> +	if (ppb < 0) {
> +		neg_adj = 1;
> +		ppb = -ppb;
> +	}
> +	addend = DEFAULT_ADDEND;
> +	adj = addend;
> +	adj *= ppb;
> +	diff = div_u64(adj, 1000000000ULL);
> +
> +	addend = neg_adj ? addend - diff : addend + diff;
> +
> +	iowrite32(addend, &regs->addend);
> +
> +	return 0;
> +}
> +
> +static int ptp_pch_adjtime(struct ptp_clock_info *ptp, s64 delta)
> +{
> +	s64 now;
> +	unsigned long flags;
> +	struct pch_dev *pch_dev = container_of(ptp, struct pch_dev, caps);
> +	struct pch_ts_regs *regs = pch_dev->regs;
> +
> +	spin_lock_irqsave(&pch_dev->lock, flags);
> +	now = pch_systime_read(regs);
> +	now += delta;
> +	pch_systime_write(regs, now);
> +	spin_unlock_irqrestore(&pch_dev->lock, flags);
> +
> +	return 0;
> +}
> +
> +static int ptp_pch_gettime(struct ptp_clock_info *ptp, struct timespec *ts)
> +{
> +	u64 ns;
> +	u32 remainder;
> +	unsigned long flags;
> +	struct pch_dev *pch_dev = container_of(ptp, struct pch_dev, caps);
> +	struct pch_ts_regs *regs = pch_dev->regs;
> +
> +	spin_lock_irqsave(&pch_dev->lock, flags);
> +	ns = pch_systime_read(regs);
> +	spin_unlock_irqrestore(&pch_dev->lock, flags);
> +
> +	ts->tv_sec = div_u64_rem(ns, 1000000000, &remainder);
> +	ts->tv_nsec = remainder;
> +	return 0;
> +}
> +
> +static int ptp_pch_settime(struct ptp_clock_info *ptp,
> +			   const struct timespec *ts)
> +{
> +	u64 ns;
> +	unsigned long flags;
> +	struct pch_dev *pch_dev = container_of(ptp, struct pch_dev, caps);
> +	struct pch_ts_regs *regs = pch_dev->regs;
> +
> +	ns = ts->tv_sec * 1000000000ULL;
> +	ns += ts->tv_nsec;
> +
> +	spin_lock_irqsave(&pch_dev->lock, flags);
> +	pch_systime_write(regs, ns);
> +	spin_unlock_irqrestore(&pch_dev->lock, flags);
> +
> +	return 0;
> +}
> +
> +static int ptp_pch_enable(struct ptp_clock_info *ptp,
> +			  struct ptp_clock_request *rq, int on)
> +{
> +	struct pch_dev *pch_dev = container_of(ptp, struct pch_dev, caps);
> +
> +	switch (rq->type) {
> +	case PTP_CLK_REQ_EXTTS:
> +		switch (rq->extts.index) {
> +		case 0:
> +			pch_dev->exts0_enabled = on ? 1 : 0;
> +			break;
> +		case 1:
> +			pch_dev->exts1_enabled = on ? 1 : 0;
> +			break;
> +		default:
> +			return -EINVAL;
> +		}
> +		return 0;
> +	default:
> +		break;
> +	}
> +
> +	return -EOPNOTSUPP;
> +}
> +
> +static struct ptp_clock_info ptp_pch_caps = {
> +	.owner		= THIS_MODULE,
> +	.name		= "PCH timer",
> +	.max_adj	= 66666655,

This should be recalculated once you figure out the input clock and
nominal frequency.

> +	.n_ext_ts	= N_EXT_TS,
> +	.pps		= 0,
> +	.adjfreq	= ptp_pch_adjfreq,
> +	.adjtime	= ptp_pch_adjtime,
> +	.gettime	= ptp_pch_gettime,
> +	.settime	= ptp_pch_settime,
> +	.enable		= ptp_pch_enable,
> +};
> +
> +
> +#ifdef CONFIG_PM
> +static s32 pch_suspend(struct pci_dev *pdev, pm_message_t state)
> +{
> +	struct pch_dev *chip = pci_get_drvdata(pdev);
> +
> +	chip->suspend = 1;

You set this flag here ...

> +	pci_disable_device(pdev);
> +	pci_enable_wake(pdev, PCI_D3hot, 0);
> +
> +	if (pci_save_state(pdev) != 0) {
> +		dev_err(&pdev->dev,
> +			"%s: could not save PCI config state\n", __func__);
> +		return -ENOMEM;
> +	}
> +	pci_set_power_state(pdev, pci_choose_state(pdev, state));
> +
> +	return 0;
> +}
> +
> +static s32 pch_resume(struct pci_dev *pdev)
> +{
> +	s32 ret;
> +	struct pch_dev *chip = pci_get_drvdata(pdev);
> +
> +	pci_set_power_state(pdev, PCI_D0);
> +	pci_restore_state(pdev);
> +	ret = pci_enable_device(pdev);
> +	if (ret) {
> +		dev_err(&pdev->dev, "%s: pci_enable_device failed\n", __func__);
> +		return ret;
> +	}
> +	pci_enable_wake(pdev, PCI_D3hot, 0);
> +	chip->suspend = 0;

... and clear it again here. Why?

> +	return 0;
> +}
> +#else
> +#define pch_suspend NULL
> +#define pch_resume NULL
> +#endif
> +
> +static void __devexit pch_remove(struct pci_dev *pdev)
> +{
> +	struct pch_dev *chip = pci_get_drvdata(pdev);
> +
> +	ptp_clock_unregister(chip->ptp_clock);
> +	/* free the interrupt */
> +	if (pdev->irq != 0)
> +		free_irq(pdev->irq, chip);
> +
> +	/* unmap the virtual IO memory space */
> +	if (chip->regs != 0) {
> +		iounmap(chip->regs);
> +		chip->regs = 0;
> +	}
> +	/* release the reserved IO memory space */
> +	if (chip->mem_base != 0) {
> +		release_mem_region(chip->mem_base, chip->mem_size);
> +		chip->mem_base = 0;
> +	}
> +	pci_disable_device(pdev);
> +	kfree(chip);
> +	dev_info(&pdev->dev, "%s: complete\n", __func__);
> +}
> +
> +static s32 __devinit
> +pch_probe(struct pci_dev *pdev, const struct pci_device_id *id)
> +{
> +	s32 ret;
> +	struct pch_dev *chip;
> +
> +	chip = kzalloc(sizeof(struct pch_dev), GFP_KERNEL);
> +	if (chip == NULL)
> +		return -ENOMEM;
> +
> +	/* enable the 1588 pci device */
> +	ret = pci_enable_device(pdev);
> +	if (ret != 0) {
> +		dev_err(&pdev->dev,
> +			"%s:could not enable the pci device\n", __func__);
> +		goto err_pci_en;
> +	}
> +
> +	chip->mem_base = pci_resource_start(pdev, IO_MEM_BAR);
> +	if (!chip->mem_base) {
> +		dev_err(&pdev->dev,
> +			"%s: could not locate IO memory address\n", __func__);
> +		ret = -ENODEV;
> +		goto err_pci_start;
> +	}
> +
> +	/* retreive the available length of the IO memory space */
> +	chip->mem_size = pci_resource_len(pdev, IO_MEM_BAR);
> +
> +	/* allocate the memory for the device registers */
> +	if (!request_mem_region
> +			    (chip->mem_base, chip->mem_size, "1588_regs")) {

Poor statement break (and this would fit all on one line).

> +		dev_err(&pdev->dev,
> +		    "%s: could not allocate register memory space\n", __func__);

Bad indentation.

> +		ret = -EBUSY;
> +		goto err_req_mem_region;
> +	}
> +
> +	/* get the virtual address to the 1588 registers */
> +	chip->regs = ioremap(chip->mem_base, chip->mem_size);
> +
> +	if (!chip->regs) {
> +		dev_err(&pdev->dev,
> +			"%s: Could not get virtual address\n", __func__);
> +		ret = -ENOMEM;
> +		goto err_ioremap;
> +	}
> +
> +	chip->caps = ptp_pch_caps;
> +	chip->ptp_clock = ptp_clock_register(&chip->caps);
> +
> +	if (IS_ERR(chip->ptp_clock))
> +		return PTR_ERR(chip->ptp_clock);
> +
> +	spin_lock_init(&chip->lock);
> +
> +	ret = request_irq(pdev->irq, &isr, IRQF_SHARED, KBUILD_MODNAME, chip);
> +	if (ret != 0) {
> +		dev_err(&pdev->dev,
> +			"%s: failed to get irq %d\n", __func__, pdev->irq);
> +		goto err_req_irq;
> +	}
> +
> +	chip->initialized = 1;

You set this flag, but never use it.

> +	/* indicate success */
> +	chip->irq = pdev->irq;
> +	chip->pdev = pdev;
> +	pci_set_drvdata(pdev, chip);
> +
> +	/* reset the ieee1588 h/w */
> +	pch_reset(chip);
> +
> +	iowrite32(DEFAULT_ADDEND, &chip->regs->addend);
> +	iowrite32(1, &chip->regs->trgt_lo);
> +	iowrite32(0, &chip->regs->trgt_hi);
> +	iowrite32(PCH_TSE_TTIPEND, &chip->regs->event);
> +	pch_eth_enable(chip);
> +
> +	return 0;
> +
> +err_req_irq:
> +	ptp_clock_unregister(chip->ptp_clock);
> +	iounmap(chip->regs);
> +	chip->regs = 0;
> +
> +err_ioremap:
> +	release_mem_region(chip->mem_base, chip->mem_size);
> +
> +err_req_mem_region:
> +	chip->mem_base = 0;
> +
> +err_pci_start:
> +	pci_disable_device(pdev);
> +
> +err_pci_en:
> +	kfree(chip);
> +	dev_err(&pdev->dev, "%s: probe failed(ret=0x%x)\n", __func__, ret);
> +
> +	return ret;
> +}
> +
> +static DEFINE_PCI_DEVICE_TABLE(pch_gbe_pcidev_id) = {
> +	{.vendor = PCI_VENDOR_ID_INTEL,

Needs a space (or newline) before the dot.

> +	 .device = PCI_DEVICE_ID_PCH_1588
> +	 },
> +	{0}
> +};
> +
> +static struct pci_driver pch_pcidev = {
> +	.name = KBUILD_MODNAME,
> +	.id_table = pch_pcidev_id,

Here you meant "pch_gbe_pcidev_id" instead (or no "gbe" in the PCI
device table).

> +	.probe = pch_probe,
> +	.remove = pch_remove,
> +	.suspend = pch_suspend,
> +	.resume = pch_resume,
> +};
> +
> +static void __exit ptp_pch_exit(void)
> +{
> +	pci_unregister_driver(&pch_pcidev);
> +}
> +
> +static s32 __init ptp_pch_init(void)
> +{
> +	s32 ret;
> +
> +	/* register the driver with the pci core */
> +	ret = pci_register_driver(&pch_pcidev);
> +
> +	return ret;
> +}
> +
> +module_init(ptp_pch_init);
> +module_exit(ptp_pch_exit);
> +
> +MODULE_AUTHOR("OKI SEMICONDUCTOR, <toshiharu-linux@dsn.okisemi.com>");
> +MODULE_DESCRIPTION("PTP clock using the EG20T timer");
> +MODULE_LICENSE("GPL");

Overall, the driver looks okay. I would appreciate if you would take a
look at the comments and submit a revised patch.

I would also like to see how the time stamps are done in the MAC
driver. Have you already posted that?

Feature request: I notice in the data sheet that the time stamping
unit can produce a PPS output. Any chance that you could program this
feature?

Thanks,

Richard


> +
> -- 
> 1.7.4.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
