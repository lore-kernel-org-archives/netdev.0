From: "Toshiharu Okada" <toshiharu-linux@dsn.okisemi.com>
Subject: Re: [PATCH] Add pch ieee1588 driver for Intel EG20T PCH
Date: Wed, 10 Aug 2011 14:03:32 +0900
Message-ID: <817E42EB77CC464D9F0BA9D4CB92C152@hacdom.okisemi.com>
References: <1312352861-10955-1-git-send-email-toshiharu-linux@dsn.okisemi.com> <20110803192331.GA11166@riccoc20.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <tomoya-linux@dsn.okisemi.com>, <kok.howg.ewe@intel.com>,
	<joel.clark@intel.com>, <yong.y.wang@intel.com>,
	<qi.wang@intel.com>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>, <richard.cochran@omicron.at>
To: "Richard Cochran" <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sm-d311v.smileserver.ne.jp ([203.211.202.206]:17835 "EHLO
	sm-d311v.smileserver.ne.jp" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750966Ab1HJFKW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Aug 2011 01:10:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Richard

I added comment below.
Please confirm them

> +/* Register read/write macros */
> +#define PCH_BIT_SET_CHECK(addr, bitmask) \
> + ((ioread32(addr) & (bitmask)) == (bitmask))
> +#define PCH_SET_ADDR_BIT(addr, bitmask)\
> + iowrite32((ioread32(addr) | (bitmask)), (addr))
> +#define PCH_CLR_ADDR_BIT(addr, bitmask)\
> + iowrite32((ioread32(addr) & ~(bitmask)), (addr))
>
>I don't really like macros of this sort, just to set and clear
>register bits. It doesn't make any fewer lines nor does it clarify the
>code. Every driver author will know what is meant by the plain old C,
>like:
>
>    x = x | mask;
>    x = x & ~mask;
>
>Also, you should consider whether you need to protect against
>concurrent access on a register.

modify

>> +
>> +#define DEFAULT_ADDEND 0xF0000029
>> +#define TICKS_NS_SHIFT  4
>
>This driver is based on my ixp46x driver, which is fine because,
>looking at the data sheet, it appears that the time stamping unit in
>the EG20T PCH is fairly similar.
>
>However, I doubt that these ADDEND and SHIFT values will work for you,
>since they were calculated for the frequency compensated clock on the
>IXP. They reflect an input clock frequency of 66.666666 MHz and a
>nominal frequency of 62.5 MHz (or a period of 16 nanoseconds, thus
>SHIFT is 4).
>
>Section 14.6.1.10 in the data sheet seems to imply that the input
>clock is 50 MHz. In that case you could use a nominal frequency of
>31.25 MHz (period 32 ns, SHIFT 5). However, you need to find out
>the actual input clock frequency. If this can vary, then the driver
>should allow changing these values.

modify as follows.

#define DEFAULT_ADDEND 0xA0000000
#define TICKS_NS_SHIFT  5


>> + u32 asms_hi;
>> + u32 amms_lo;
>> + u32 amms_hi;
>> + u32 ch_control;
>
>You never program this register. But I think the "Mode" field should
>be set to 2. The other settings really make no sense at all.  Or do
>you set this in the MAC driver?
>
>(I wonder why Intel retained the very limited PTP V1 modes from the
>IXP time stamping unit.)

ch_control register was set as 0x80020000    (Version:1, mode:2 )


>> + u32 mem_base;
>> + u32 mem_size;
>> + u32 irq;
>> + u32 suspend:1;
>> + u32 initialized:1;
>> + struct pci_dev *pdev;
>> + spinlock_t lock;
>
>It would be nice to have a short comment telling what this lock
>protects. (Yes, I know what it protects, but still that is good
>practice to have a comment.)

It renames to "register_lock"

>> +static inline void pch_eth_enable_set(struct pch_dev *chip)
>> +{
>> + /* SET the eth_enable bit */
>> + PCH_SET_ADDR_BIT(&chip->regs->ts_sel, PCH_ECS_ETH);
>> +}
>
>I really don't like this or the other similar helper functions,
>below. They don't make the driver more understandable or shorter.
>This function is only used in one place. You need at least two callers
>to justify this.

modify

>I think the following helper functions ...
>
>> +static inline u32 pch_pps_evt_get(struct pch_dev *chip)
>> +{
>> + /* Poll for PPS event */
>> + return PCH_BIT_SET_CHECK(&chip->regs->event, PCH_TSE_PPS);
>> +}
   :
   :
>> +
>> +static inline void pch_ttm_evt_clear(struct pch_dev *chip)
>> +{
>> + /* Clear Target Time Reached event */
>> + PCH_SET_ADDR_BIT(&chip->regs->event, PCH_TSE_TTIPEND);
>> +}
>
>... are just noise and add nothing useful to the driver.

These functions are removed.

>> +static void pch_reset(struct pch_dev *chip)
>> +{
>> + /* Reset Hardware Assist */
>> + pch_block_reset(chip);
>> +
>> + /* enable all 32 bits in system time registers */
>> + pch_set_system_time_count(chip);
>> +}
>
>These three, above, are okay, since they encapsulate one logical
>operation that takes more than one register access.
>
>However, you might consider whether you need locking here.

add spin lock.

>> +static void pch_eth_enable(struct pch_dev *chip)
>> +{
>> + pch_eth_enable_set(chip);
>> +}
>
>Again, this helper only has one caller. Why not just set the bit that
>you need in line?

modify

> +
> +/*
> + * Interrupt service routine
> + */
> +static irqreturn_t isr(int irq, void *priv)
> +{
> + struct pch_dev *pch_dev = priv;
> + struct pch_ts_regs *regs = pch_dev->regs;
> + struct ptp_clock_event event;
> + u32 ack = 0, lo, hi, val;
> +
> + val = ioread32(&regs->event);
> +
> + if (val & PCH_TSE_SNS) {
> + ack |= PCH_TSE_SNS;
> + if (pch_dev->exts0_enabled) {
> + hi = ioread32(&regs->asms_hi);
> + lo = ioread32(&regs->asms_lo);
> + event.type = PTP_CLOCK_EXTTS;
> + event.index = 0;
> + event.timestamp = ((u64) hi) << 32;
> + event.timestamp |= lo;
> + event.timestamp <<= TICKS_NS_SHIFT;
> + ptp_clock_event(pch_dev->ptp_clock, &event);
> + }
> + }
> +
> + if (val & PCH_TSE_SNM) {
> + ack |= PCH_TSE_SNM;
> + if (pch_dev->exts1_enabled) {
> + hi = ioread32(&regs->amms_hi);
> + lo = ioread32(&regs->amms_lo);
> + event.type = PTP_CLOCK_EXTTS;
> + event.index = 1;
> + event.timestamp = ((u64) hi) << 32;
> + event.timestamp |= lo;
> + event.timestamp <<= TICKS_NS_SHIFT;
> + ptp_clock_event(pch_dev->ptp_clock, &event);
> + }
> + }
> +
> + if (val & PCH_TSE_TTIPEND)
> + ack |= PCH_TSE_TTIPEND; /* this bit seems to be always set */
>
>This ISR code (and much of the rest of the driver) is copied from the
>IXP driver. It would be nice to know if it actually works on the atom
>hardware. Do have any hardware to try it on?

We have a board of atom(E600) and EG20T.
However there is no environment for confirming auxiliary snapshot.

>> +static struct ptp_clock_info ptp_pch_caps = {
>> + .owner = THIS_MODULE,
>> + .name = "PCH timer",
>> + .max_adj = 66666655,
>
>This should be recalculated once you figure out the input clock and
>nominal frequency.

modify to .max_adj = 50000000,

>> +#ifdef CONFIG_PM
>> +static s32 pch_suspend(struct pci_dev *pdev, pm_message_t state)
>> +{
>> + struct pch_dev *chip = pci_get_drvdata(pdev);
>> +
>> + chip->suspend = 1;
>
>You set this flag here ...

remove

>> + /* allocate the memory for the device registers */
>> + if (!request_mem_region
>> +     (chip->mem_base, chip->mem_size, "1588_regs")) {
>
>Poor statement break (and this would fit all on one line).

modify

> + dev_err(&pdev->dev,
> +     "%s: could not allocate register memory space\n", __func__);
>
>Bad indentation.

modify

>> + if (ret != 0) {
>> + dev_err(&pdev->dev,
>> + "%s: failed to get irq %d\n", __func__, pdev->irq);
>> + goto err_req_irq;
>> + }
>> +
>> + chip->initialized = 1;
>
>You set this flag, but never use it.

remove

>> +
>> +static DEFINE_PCI_DEVICE_TABLE(pch_gbe_pcidev_id) = {
>> + {.vendor = PCI_VENDOR_ID_INTEL,
>
>Needs a space (or newline) before the dot.

modify

>> +
>> +static struct pci_driver pch_pcidev = {
>> + .name = KBUILD_MODNAME,
>> + .id_table = pch_pcidev_id,
>
>Here you meant "pch_gbe_pcidev_id" instead (or no "gbe" in the PCI
>device table).

modify

>Overall, the driver looks okay. I would appreciate if you would take a
>look at the comments and submit a revised patch.
>
>I would also like to see how the time stamps are done in the MAC
>driver. Have you already posted that?
>

Mac driver already upstreamed. ( drivers/net/pch_gbe)
However the code relevant to IEEE1588 is not contained into Ethernet driver.
I have question about rx/tx snapshot.
Is it necessary to use a snapshot within an Ethernet driver driver?
I was indicated that there must not be any dependence of a device when the 
Ethernet driver was upstreamed.

>Feature request: I notice in the data sheet that the time stamping
>unit can produce a PPS output. Any chance that you could program this
>feature?

Currently, there is no plan.

Best  Regards
Toshiharu Okada 

