From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH]: Preliminary release of Sun Neptune driver
Date: Wed, 19 Sep 2007 14:59:00 -0700
Message-ID: <20070919145900.759ef19e@freepuppy.rosehill.hemminger.net>
References: <20070918.151528.84360712.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ariel.Hendel@sun.com, greg.onufer@sun.com,
	jeff@garzik.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:33020 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751727AbXISV7V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2007 17:59:21 -0400
In-Reply-To: <20070918.151528.84360712.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

O
> +#define DRV_MODULE_NAME		"niu"
> +#define PFX DRV_MODULE_NAME	": "
> +#define DRV_MODULE_VERSION	"0.06"
> +#define DRV_MODULE_RELDATE	"September 18, 2007"
> +
> +static char version[] __devinitdata =
> +	DRV_MODULE_NAME ".c:v" DRV_MODULE_VERSION " (" DRV_MODULE_RELDATE ")\n";
> +
> +MODULE_AUTHOR("David S. Miller (davem@davemloft.net)");
> +MODULE_DESCRIPTION("NIU ethernet driver");
> +MODULE_LICENSE("GPL");
> +MODULE_VERSION(DRV_MODULE_VERSION);
> +
> +#ifndef DMA_44BIT_MASK
> +#define DMA_44BIT_MASK	0x00000fffffffffffULL
> +#endif
> +
> +#ifndef PCI_DEVICE_ID_SUN_NEPTUNE
> +#define PCI_DEVICE_ID_SUN_NEPTUNE	0xabcd
> +#endif

Why bother defining the ID, and what good does driver_data do you?

> +static struct pci_device_id niu_pci_tbl[] = {
> +	{PCI_DEVICE(PCI_VENDOR_ID_SUN, PCI_DEVICE_ID_SUN_NEPTUNE),
> +	 .driver_data = 0xff},
> +	{}
> +};
> +
> +MODULE_DEVICE_TABLE(pci, niu_pci_tbl);
> +
> +#define NIU_TX_TIMEOUT			(5 * HZ)
> +
> +#define nr64(reg)		readq(np->regs + (reg))
> +#define nw64(val, reg)		writeq((val), np->regs + (reg))

Macro's that make assumptions about context (ie variable name np)
are evil and bad style.


> +#define nr64_mac(reg)		readq(np->mac_regs + (reg))
> +#define nw64_mac(val, reg)	writeq((val), np->mac_regs + (reg))
> +
> +#define nr64_ipp(reg)		readq(np->regs + np->ipp_off + (reg))
> +#define nw64_ipp(val, reg)	writeq((val), np->regs + np->ipp_off + (reg))
> +
> +#define nr64_pcs(reg)		readq(np->regs + np->pcs_off + (reg))
> +#define nw64_pcs(val, reg)	writeq((val), np->regs + np->pcs_off + (reg))
> +
> +#define nr64_xpcs(reg)		readq(np->regs + np->xpcs_off + (reg))
> +#define nw64_xpcs(val, reg)	writeq((val), np->regs + np->xpcs_off + (reg))
> +
> +static unsigned int niu_debug;
> +#define NIU_DEBUG_INTERRUPT	0x00000001
> +#define NIU_DEBUG_TX_WORK	0x00000002
> +#define NIU_DEBUG_RX_WORK	0x00000004
> +#define NIU_DEBUG_POLL		0x00000008
> +#define NIU_DEBUG_PROBE		0x00010000
> +#define NIU_DEBUG_MDIO		0x00020000
> +#define NIU_DEBUG_MII		0x00040000
> +#define NIU_DEBUG_INIT_HW	0x00080000
> +#define NIU_DEBUG_STOP_HW	0x00080000


Please use or extend already existing netif_msg debug methods.

> +module_param(niu_debug, int, 0);
> +MODULE_PARM_DESC(niu_debug,
> +"NIU bitmapped debugging message enable value:\n"
> +"	0x00000001	Log interrupt events\n"
> +"	0x00000002	Log TX work\n"
> +"	0x00000004	Log RX work\n"
> +"	0x00000008	Log NAPI poll\n"
> +"	0x00010000	Log device probe events\n"
> +"	0x00020000	Log MDIO reads and writes\n"
> +"	0x00040000	Log MII reads and writes\n"
> +"	0x00080000	Log HW initialization\n"
> +"	0x00100000	Log HW shutdown\n"
> +);
> +
> +#define niudbg(TYPE, f, a...) \
> +do {	if (niu_debug & NIU_DEBUG_##TYPE) \
> +		printk(KERN_ERR PFX f, ## a); \
> +} while (0)
> +
> +#define niu_lock_parent(np, flags) \
> +	spin_lock_irqsave(&np->parent->lock, flags)
> +#define niu_unlock_parent(np, flags) \
> +	spin_unlock_irqrestore(&np->parent->lock, flags)
>

Wrapping locking is poor style and makes code review harder.

> +static int niu_wait_bits_clear_mac(struct niu *np, unsigned long reg, u64 bits,
> +				   int limit, int delay)
> +{
> +	BUILD_BUG_ON(limit <= 0 || delay < 0);

There is no way compiler can evaluate limit or delay.

> +	while (--limit >= 0) {
> +		u64 val = nr64_mac(reg);
> +
> +		if (!(val & bits))
> +			break;
> +		udelay(delay);
> +	}
> +	if (limit < 0)
> +		return -ENODEV;
> +	return 0;
> +}
> +
> +static int niu_set_and_wait_clear_mac(struct niu *np, unsigned long reg,
> +				      u64 bits, int limit, int delay,
> +				      const char *reg_name)
> +{
> +	int err;
> +
> +	nw64_mac(bits, reg);
> +	err = niu_wait_bits_clear_mac(np, reg, bits, limit, delay);
> +	if (err)
> +		printk(KERN_ERR PFX "%s: bits (%lx) of register %s "
> +		       "would not clear, val[%lx]\n",
> +		       np->dev->name, bits, reg_name,
> +		       nr64_mac(reg));
> +	return err;
> +}
> +
> +static int niu_wait_bits_clear_ipp(struct niu *np, unsigned long reg, u64 bits,
> +				   int limit, int delay)
> +{
> +	BUILD_BUG_ON(limit <= 0 || delay < 0);
> +	while (--limit >= 0) {
> +		u64 val = nr64_ipp(reg);
> +
> +		if (!(val & bits))
> +			break;
> +		udelay(delay);
> +	}
> +	if (limit < 0)
> +		return -ENODEV;
> +	return 0;
> +}
> +
> +static int niu_set_and_wait_clear_ipp(struct niu *np, unsigned long reg,
> +				      u64 bits, int limit, int delay,
> +				      const char *reg_name)
> +{
> +	int err;
> +	u64 val;
> +
> +	val = nr64_ipp(reg);
> +	val |= bits;
> +	nw64_ipp(val, reg);
> +
> +	err = niu_wait_bits_clear_ipp(np, reg, bits, limit, delay);
> +	if (err)
> +		printk(KERN_ERR PFX "%s: bits (%lx) of register %s "
> +		       "would not clear, val[%lx]\n",
> +		       np->dev->name, bits, reg_name,
> +		       nr64_ipp(reg));
> +	return err;
> +}
> +
> +static int niu_wait_bits_clear(struct niu *np, unsigned long reg, u64 bits,
> +			       int limit, int delay)
> +{
> +	BUILD_BUG_ON(limit <= 0 || delay < 0);
> +	while (--limit >= 0) {
> +		u64 val = nr64(reg);
> +
> +		if (!(val & bits))
> +			break;
> +		udelay(delay);
> +	}
> +	if (limit < 0)
> +		return -ENODEV;
> +	return 0;
> +}
> +
> +static int niu_set_and_wait_clear(struct niu *np, unsigned long reg,
> +				  u64 bits, int limit, int delay,
> +				  const char *reg_name)
> +{
> +	int err;
> +
> +	nw64(bits, reg);
> +	err = niu_wait_bits_clear(np, reg, bits, limit, delay);
> +	if (err)
> +		printk(KERN_ERR PFX "%s: bits (%lx) of register %s "
> +		       "would not clear, val[%lx]\n",
> +		       np->dev->name, bits, reg_name,
> +		       nr64(reg));
> +	return err;
> +}
> +
> +static void niu_ldg_rearm(struct niu *np, struct niu_ldg *lp, int on)
> +{
> +	u64 val = (u64) lp->timer;
> +
> +	if (on)
> +		val |= LDG_IMGMT_ARM;
> +
> +	nw64(val, LDG_IMGMT(lp->ldg_num));
> +}
> +
> +static int niu_ldn_irq_enable(struct niu *np, int ldn, int on)
> +{
> +	unsigned long mask_reg, bits;
> +	u64 val;
> +
> +	if (ldn < 0 || ldn > LDN_MAX)
> +		return -EINVAL;
> +
> +	if (ldn < 64) {
> +		mask_reg = LD_IM0(ldn);
> +		bits = LD_IM0_MASK;
> +	} else {
> +		mask_reg = LD_IM1(ldn - 64);
> +		bits = LD_IM1_MASK;
> +	}
> +
> +	val = nr64(mask_reg);
> +	if (on)
> +		val &= ~bits;
> +	else
> +		val |= bits;
> +	nw64(val, mask_reg);
> +
> +	return 0;
> +}
> +
> +static int niu_enable_ldn_in_ldg(struct niu *np, struct niu_ldg *lp, int on)
> +{
> +	struct niu_parent *parent = np->parent;
> +	int i;
> +
> +	for (i = 0; i <= LDN_MAX; i++) {
> +		int err;
> +
> +		if (parent->ldg_map[i] != lp->ldg_num)
> +			continue;
> +
> +		err = niu_ldn_irq_enable(np, i, on);
> +		if (err)
> +			return err;
> +	}
> +	return 0;
> +}
> +
> +static int niu_enable_interrupts(struct niu *np, int on)
> +{
> +	int i;
> +
> +	for (i = 0; i < np->num_ldg; i++) {
> +		struct niu_ldg *lp = &np->ldg[i];
> +		int err;
> +
> +		err = niu_enable_ldn_in_ldg(np, lp, on);
> +		if (err)
> +			return err;
> +	}
> +	for (i = 0; i < np->num_ldg; i++)
> +		niu_ldg_rearm(np, &np->ldg[i], on);
> +
> +	return 0;
> +}
> +
> +static __u32 phy_encode(__u32 type, int port)
> +{
> +	return (type << (port * 2));
> +}
> +
> +static __u32 phy_decode(__u32 val, int port)
> +{
> +	return (val >> (port * 2)) & PORT_TYPE_MASK;
> +}

Why are you using __u32?  That is reserved for values going out
to user space.
