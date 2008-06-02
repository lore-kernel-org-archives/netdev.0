From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] SMSC LAN911x and LAN921x vendor driver
Date: Mon, 2 Jun 2008 16:54:17 +0100
Message-ID: <20080602155415.GA6192@solarflare.com>
References: <1211200476-21297-1-git-send-email-steve.glendinning@smsc.com> <1212403502-4604-1-git-send-email-steve.glendinning@smsc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Michael.Hennerich@analog.com,
	Enrik.Berkhan@ge.com, hennerich@blackfin.uclinux.org,
	ian.saturley@smsc.com, uclinux-dist-devel@blackfin.uclinux.org,
	catalin.marinas@arm.com, Bahadir Balban <Bahadir.Balban@arm.com>,
	Dustin Mcintire <dustin@sensoria.com>,
	Bill Gatliff <bgat@billgatliff.com>
To: Steve Glendinning <steve.glendinning@smsc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-69-137-158.dsl.in-addr.zen.co.uk ([82.69.137.158]:41334 "EHLO
	uklogin.uk.level5networks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755967AbYFBPz2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2008 11:55:28 -0400
Content-Disposition: inline
In-Reply-To: <1212403502-4604-1-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Steve Glendinning wrote:
[...]
> +static inline void smsc911x_reg_write(u32 val, struct smsc911x_data *pdata,
> +				      u32 reg)

It's more common to make the value the last parameter to a write-register
function.

[...]
> +/* Fetches a MAC register value. Assumes phy_lock is acquired */
> +static u32 smsc911x_mac_read(struct smsc911x_data *pdata, unsigned int offset)
> +{
> +	unsigned int temp;
> +
> +#ifdef CONFIG_DEBUG_SPINLOCK
> +	if (!spin_is_locked(&pdata->phy_lock))
> +		SMSC_WARNING("phy_lock not held");
> +#endif				/* CONFIG_DEBUG_SPINLOCK */

This is replicated in several functions; why not make it a macro, and use
the standard warning macro:

#ifdef CONFIG_DEBUG_SPINLOCK
#define ASSERT_PHY_LOCK(pdata) WARN_ON(!spin_is_locked(&pdata->phy_lock))
#else
#define ASSERT_PHY_LOCK(pdata) do {} while (0)
#endif

(Also, why is it called phy_lock if it's also used by the MAC access
functions?)

[...]
> +/* Set a mac register, phy_lock must be acquired before calling */
> +static void smsc911x_mac_write(struct smsc911x_data *pdata,
> +			       unsigned int offset, u32 val)
> +{
> +	unsigned int temp;
> +
> +#ifdef CONFIG_DEBUG_SPINLOCK
> +	if (!spin_is_locked(&pdata->phy_lock))
> +		SMSC_WARNING("phy_lock not held");
> +#endif				/* CONFIG_DEBUG_SPINLOCK */
> +
> +	temp = smsc911x_reg_read(pdata, MAC_CSR_CMD);
> +	if (unlikely(temp & MAC_CSR_CMD_CSR_BUSY_)) {
> +		SMSC_WARNING("smsc911x_mac_write failed, MAC busy at entry");
> +		return;
> +	}

Shouldn't this return an error code?

[...]
> +/* Sets a phy register, phy_lock must be acquired before calling */
> +static void smsc911x_phy_write(struct smsc911x_data *pdata,
> +			       unsigned int index, u16 val)
> +{
> +	unsigned int addr;
> +	int i;
> +
> +#ifdef CONFIG_DEBUG_SPINLOCK
> +	if (!spin_is_locked(&pdata->phy_lock))
> +		SMSC_WARNING("phy_lock not held");
> +#endif				/* CONFIG_DEBUG_SPINLOCK */
> +
> +	/* Confirm MII not busy */
> +	if (unlikely(smsc911x_mac_read(pdata, MII_ACC) & MII_ACC_MII_BUSY_)) {
> +		SMSC_WARNING("MII is busy in smsc911x_write_phy???");
> +		return;
> +	}

Similarly for this function.

[...]
> +/* called by phy_initialise and loopback test */
> +static int smsc911x_phy_reset(struct smsc911x_data *pdata)
> +{
> +	unsigned int temp;
> +	unsigned int i = 100000;
> +	unsigned long flags;
> +
> +	SMSC_TRACE("Performing PHY BCR Reset");
> +	spin_lock_irqsave(&pdata->phy_lock, flags);
> +	smsc911x_phy_write(pdata, MII_BMCR, BMCR_RESET);
> +	do {
> +		udelay(10);
> +		temp = smsc911x_phy_read(pdata, MII_BMCR);
> +	} while ((i--) && (temp & BMCR_RESET));
> +	spin_unlock_irqrestore(&pdata->phy_lock, flags);

I think this was already mentioned, but that's a very long time to busy-
wait.  Maybe you could find a way to block PHY access that doesn't require
holding phy_lock; then you could sleep while waiting.

[...]
> +static int smsc911x_phy_loopbacktest(struct smsc911x_data *pdata)
> +{
> +	int result = 0;
> +	unsigned int i;
> +	unsigned int val;
> +	unsigned long flags;
> +
> +	/* Initialise tx packet using broadcast destination address */
> +	for (i = 0; i < 6; i++)
> +		pdata->loopback_tx_pkt[i] = (char)0xFF;

The cast to char is just noise.

[...]
> +	/* Set length type field */
> +	pdata->loopback_tx_pkt[12] = 0x00;
> +	pdata->loopback_tx_pkt[13] = 0x00;
> +	for (i = 14; i < MIN_PACKET_SIZE; i++)
> +		pdata->loopback_tx_pkt[i] = (char)i;

The comment applies to the following two lines only, so you could do with a
blank line after them.

> +	val = smsc911x_reg_read(pdata, HW_CFG);
> +	val &= HW_CFG_TX_FIF_SZ_;
> +	val |= HW_CFG_SF_;
> +	smsc911x_reg_write(val, pdata, HW_CFG);
> +
> +	smsc911x_reg_write(TX_CFG_TX_ON_, pdata, TX_CFG);
> +	smsc911x_reg_write((((unsigned int)pdata->loopback_rx_pkt)
> +			    & 0x03) << 8, pdata, RX_CFG);
> +
> +	for (i = 0; i < 10; i++) {
> +		/* Set PHY to 10/FD, no ANEG, and loopback mode */
> +		spin_lock_irqsave(&pdata->phy_lock, flags);
> +		smsc911x_phy_write(pdata, MII_BMCR, 0x4100);

You could write BMCR_LOOPBACK | BMCR_FULLDPLX instead of 0x4100; then the
comment is unnecessary.

[...]
> +/* Update link mode if any thing has changed */
> +static void smsc911x_phy_update_linkmode(struct net_device *dev, int init)
[...]
> +#ifdef USE_LED1_WORK_AROUND

Shouldn't this workaround be controlled by platform data or a module
parameter rather than a compile-time option which isn't in Kconfig?  I
notice this macro is defined by default, so maybe it shouldn't be
conditional at all.

[...]
> +static int smsc911x_soft_reset(struct smsc911x_data *pdata)
> +{
> +	unsigned int timeout;
> +	unsigned int temp;
> +
> +	/* Reset the LAN911x */
> +	smsc911x_reg_write(HW_CFG_SRST_, pdata, HW_CFG);
> +	timeout = 10;
> +	do {
> +		udelay(10);
> +		temp = smsc911x_reg_read(pdata, HW_CFG);
> +	} while ((--timeout) && (temp & HW_CFG_SRST_));
> +
> +	if (unlikely(temp & HW_CFG_SRST_)) {
> +		SMSC_WARNING("Failed to complete reset");
> +		return -ENODEV;

I think this should be -EIO unless this is only called during probe.

[...]
> +static int smsc911x_open(struct net_device *dev)
[...]
> +	timeout = 1000;
> +	while (timeout--) {
> +		smp_rmb();

I think you're trying to ensure that software_irq_signal is re-read each
time round the loop.  For that you should use barrier(), not smp_rmb().
However, msleep() acts as a compiler barrier already.  So just remove the
smp_rmb().

> +		if (pdata->software_irq_signal)
> +			break;
> +		msleep(1);
> +	}
> +
> +	if (!pdata->software_irq_signal) {
> +		printk(KERN_WARNING "%s: ISR failed signaling test (IRQ %d)\n",
> +		       dev->name, dev->irq);
> +		return -ENODEV;
> +	}
> +	SMSC_TRACE("IRQ handler passed test using IRQ %d", dev->irq);
> +
> +	printk(KERN_INFO "%s: SMSC911x/921x identified at %#08lx, IRQ: %d\n",
> +	       dev->name, (unsigned long)pdata->ioaddr, dev->irq);

Should use dev_info().

[...]
> +static void smsc911x_ethtool_getdrvinfo(struct net_device *dev,
> +					struct ethtool_drvinfo *info)
> +{
> +	strncpy(info->driver, SMSC_CHIPNAME, sizeof(info->driver));
> +	strncpy(info->version, SMSC_DRV_VERSION, sizeof(info->version));
> +	strncpy(info->bus_info, dev->dev.parent->bus_id,
> +		sizeof(info->bus_info));
> +}

Use strlcpy(), not strncpy().

[...]
> +static void smsc911x_ethtool_setmsglevel(struct net_device *dev, u32 level)
> +{
> +	struct smsc911x_data *pdata = netdev_priv(dev);
> +	pdata->msg_enable = level;
> +}

It would be nice if the logging macros actually tested msg_enable too. ;-)

[...]
> +static int smsc911x_ethtool_get_eeprom(struct net_device *dev,
> +				       struct ethtool_eeprom *eeprom, u8 *data)
> +{
> +	struct smsc911x_data *pdata = netdev_priv(dev);
> +	u8 eeprom_data[SMSC911X_EEPROM_SIZE];
> +	int len;
> +	int i;
> +
> +	smsc911x_eeprom_enable_access(pdata);
> +
> +	len = min(eeprom->len, SMSC911X_EEPROM_SIZE);
> +	for (i = 0; i < len; i++) {
> +		int ret = smsc911x_eeprom_read_location(pdata, i, eeprom_data);
> +		if (ret < 0) {
> +			eeprom->len = 0;
> +			return ret;
> +		}
> +	}

Doesn't this need to take eeprom->offset into account?

[...]
> +	printk(KERN_INFO
> +	       "%s: SMSC911x MAC Address: %02x:%02x:%02x:%02x:%02x:%02x\n",
> +	       dev->name, dev->dev_addr[0], dev->dev_addr[1], dev->dev_addr[2],
> +	       dev->dev_addr[3], dev->dev_addr[4], dev->dev_addr[5]);

This should use print_mac().

[...]
> +/* SMSC911x registers and bitfields */
> +#define RX_DATA_FIFO			0x00
> +
> +#define TX_DATA_FIFO			0x20
> +#define TX_CMD_A_ON_COMP_		0x80000000

Why do these flag/mask names have trailing underscores?

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
