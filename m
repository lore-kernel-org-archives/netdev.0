From: Philip Rakity <prakity@marvell.com>
Subject: Re: [PATCH] net: add Fast Ethernet driver for PXA168.
Date: Fri, 6 Aug 2010 08:44:02 -0700
Message-ID: <26AE03C2-9D1A-4E63-82E3-DD47BD451B70@marvell.com>
References: <EC64E4604C8024438259B683BB2514E1082B1CB1B0@SC-VEXCH1.marvell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Lennert Buytenhek <buytenh@wantstofly.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Ashish Karkare <akarkare@marvell.com>,
	Prabhanjan Sarnaik <sarnaik@marvell.com>,
	"eric.y.miao@gmail.com" <eric.y.miao@gmail.com>,
	Mark Brown <markb@marvell.com>
To: Sachin Sanap <ssanap@marvell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dakia3.marvell.com ([65.219.4.28]:42762 "EHLO
	dakia3.marvell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761498Ab0HFP5S convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Aug 2010 11:57:18 -0400
In-Reply-To: <EC64E4604C8024438259B683BB2514E1082B1CB1B0@SC-VEXCH1.marvell.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Sachin,

You should change

>>> +		skb = dev_alloc_skb(MAX_PKT_SIZE + ETH_HW_IP_ALIGN);

>> 

to allocatie ADDITIONAL prepend space in the header.  If you are doing ethernet to 802.11 routing or bridging then the wireless driver will not have enough space in front of the header to prepend its headers without having to allocate additional space.   You should check what 802.11n requires.  64 is okay for 11b/g. I would imagine doing something like this.

#define EXTRA_PREPEND_SPACE  64   /* extra header space for wireless headers */

>>> skb = dev_alloc_skb(MAX_PKT_SIZE + ETH_HW_IP_ALIGN + EXTRA_PREPEND_SPACE);

> +             skb_reserve(skb, ETH_HW_IP_ALIGN + EXTRA_PREPEND_SPACE);

etc

Philip


On Aug 6, 2010, at 8:14 AM, Sachin Sanap wrote:

> Thanks Lennert,Eric for your review. Comments inline. I will resend the modified patch as a reply to this email.
>> 
>> On Wed, Aug 04, 2010 at 04:17:50PM +0530, Sachin Sanap wrote:
>> 
>>> This patch adds support for PXA168 Fast Ethernet on Aspenite
>>> board.
>> 
>> There's nothing Aspenite-specific in this patch (nor should there be),
>> so you can leave that part out.
> 
> Removed.
>> 
>> 
>>> Patch generated against Linux 2.6.35-rc5
>>> commit cd5b8f8755a89a57fc8c408d284b8b613f090345
>> 
>> This might be interesting to know but shouldn't be part of the commit
>> message.
> 
> Removed.
>> 
>> 
>>> diff --git a/arch/arm/mach-mmp/include/mach/pxa168_eth.h
>> b/arch/arm/mach-mmp/include/mach/pxa168_eth.h
>>> new file mode 100644
>>> index 0000000..abfd335
>>> --- /dev/null
>>> +++ b/arch/arm/mach-mmp/include/mach/pxa168_eth.h
>>> @@ -0,0 +1,18 @@
>>> +/*
>>> + *pxa168 ethernet platform device data definition file.
>>> + */
>>> +#ifndef __LINUX_PXA168_ETH_H
>>> +#define __LINUX_PXA168_ETH_H
>> 
>> This should just be in include/linux, IMHO, as this unit isn't only used
>> in the PXA168, for one.
> I have moved it to include/linux but the PXA168 name is still there.
> 
>> 
>> 
>>> +struct pxa168_eth_platform_data {
>>> +	int	port_number;
>>> +	u16	phy_addr;
>>> +
>>> +	/* If speed is 0, then speed and duplex are autonegotiated. */
>>> +	u32	speed;		/* 0, SPEED_10, SPEED_100 */
>>> +	u32	duplex;		/* DUPLEX_HALF or DUPLEX_FULL */
>> 
>> phylib treats these three (phy address, speed and duplex) as ints, is
>> there any reason you need these to be of different types?
> 
> 
> Used int at all three places.
> 
>> 
>> 
>>> +	int (*init)(void);
>> 
>> What's this needed for?  The name of this callback is entirely
>> nondescriptive, there's no comment as to when it's called, etc.
> 
> Added a comment for it.
>> 
>> 
>>> diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
>>> index ce2fcdd..5ebf287 100644
>>> --- a/drivers/net/Kconfig
>>> +++ b/drivers/net/Kconfig
>>> @@ -927,6 +927,16 @@ config SMC91X
>>> 	  The module will be called smc91x.  If you want to compile it as a
>>> 	  module, say M here and read
>> <file:Documentation/kbuild/modules.txt>.
>>> 
>>> +config PXA168_ETH
>>> +	tristate "Marvell pxa168 ethernet support"
>>> +	depends on MACH_ASPENITE
>> 
>> You can have it depend on ARM or PXA168, but having it depend on support
>> for one specific board support file is almost certainly wrong.
> 
> Depends on CPU_PXA168.
>> 
>> 
>>> diff --git a/drivers/net/pxa168_eth.c b/drivers/net/pxa168_eth.c
>>> new file mode 100644
>>> index 0000000..618e558
>>> --- /dev/null
>>> +++ b/drivers/net/pxa168_eth.c
>>> @@ -0,0 +1,1723 @@
>>> +/*
>>> + * Driver for PXA168 based boards.
>> 
>> Why not call this "PXA168 ethernet driver"?
> Change done.
>> 
>> 
>>> + * Based on MV643XX driver.
>> 
>> The mv643xx ethernet driver, that is.
> Change done.
>> 
>> 
>>> +#define DRIVER_NAME	"pxa168-mfu"
>> 
>> mfu?
> Its was for multi function unit on Aspenite, changed it to pxa168-eth 
>> 
>> 
>>> +/* smi register */
>>> +#define SMI_BUSY		(1<<28)	/* 0 - Write, 1 - Read  */
>>> +#define SMI_R_VALID		(1<<27)	/* 0 - Write, 1 - Read  */
>>> +#define SMI_OP_W		(0<<26)	/* Write operation      */
>>> +#define SMI_OP_R		(1<<26)	/* Read operation */
>> 
>> (1 << 28)
>> (1 << 27)
>> (0 << 26)
>> 
>> etc (thoughout the file)
> Changed.
> 
>> 
>> 
>>> +struct pxa168_private {
>> 
>> ITYM pxa168_eth_private
> Yes, changed.
>> 
>> 
>>> +	/*
>>> +	 * Used in case RX Ring is empty, which can be caused when
>>> +	 * system does not have resources (skb's)
>>> +	 */
>> 
>> can be caused by
>> can occur when
> Changed.
>> 
>> 
>>> +	struct timer_list timeout;
>>> +	struct mii_bus *smi_bus;
>>> +	struct phy_device *phy;
>>> +
>>> +	/* clock */
>>> +	struct clk *clk;
>>> +	struct pxa168_eth_platform_data *pd;
>>> +	/*
>>> +	 * Ethernet controller base address.
>>> +	 */
>>> +	void __iomem *base;
>>> +
>>> +	u8 *htpr;		/* hash pointer */
>> 
>> IMHO it'd look better if you'd either always put the comment on the same
>> line or put the comment above the member (within the same struct).
>> 
>> Also, 'hash pointer' as a comment isn't very helpful.  Making it
>> 'hardware address filter table' or so would be more descriptive.
> Changed.
>> 
>> 
>>> +struct addr_table_entry {
>>> +	u32 lo;
>>> +	u32 hi;
>>> +};
>> 
>> If the address filter table consists of these structures, it's
>> confusing to make htpr a u8 * and then cast things around.  Better make
>> htpr a void * then.
> Changed.
>> 
>> Also, what about endian-cleanness?  If you run the CPU core in big
>> endian, will the address filter table handling logic in this driver
>> still work?
> 
> 
> Added cpu_to_le32 for the mac_high and mac_low variables before passing them to the add_del_hash_entry. I have not tested it on the Big endian but I think it should now work.
> 
>> 
>> 
>>> +static char marvell_OUI[3] = { 0x02, 0x50, 0x43 };
>> 
>> This isn't even a marvell OUI -- 00:50:43 is a marvell OUI, and
>> anything with 02: is a locally generated address.
>> 
>> Why don't you just use random_ether_addr()?
> Changed to use random_ether_addr.
>> 
>> 
>>> +static inline u32 rdl(struct pxa168_private *mp, int offset)
>>> +{
>>> +	return readl(mp->base + offset);
>>> +}
>> 
>> In mv643xx_eth, 'mp' refers to mv643xx_eth_private, it's funny that
>> you've changed the name of the struct but not that of the variable.
>> 
>> As the rest of the driver looks very very similar to mv643xx_eth, if
>> not pretty much entirely identical in a lot of places, you should give
>> more credit to mv643xx_eth than 'based on', in my opinion.
> Changed the credit line for the same.
>> 
>> 
>>> +static int ethernet_phy_get(struct pxa168_private *mp)
>>> +{
>>> +	unsigned int reg_data;
>>> +
>>> +	/* only support 3 ports */
>>> +	BUG_ON(mp->port_num > 2);
>> 
>> Hm, does it actually support 3 ports?
> No. changed the code.
>> 
>> 
>>> +static void ethernet_phy_set_addr(struct pxa168_private *mp, int
>> phy_addr)
>>> +{
>>> +	u32 reg_data;
>>> +	int addr_shift = 5 * mp->port_num;
>>> +
>>> +	/* only support 3 ports */
>>> +	BUG_ON(mp->port_num > 2);
>>> +
>>> +	reg_data = rdl(mp, PHY_ADDRESS);
>>> +	reg_data &= ~(0x1f << addr_shift);
>>> +	reg_data |= (phy_addr & 0x1f) << addr_shift;
>>> +	wrl(mp, PHY_ADDRESS, reg_data);
>>> +}
>>> +static void ethernet_phy_reset(struct pxa168_private *mp)
>>> +{
>> 
>> Blank line between functions.
>> 
>> 
>>> +	do {
>>> +		data = phy_read(mp->phy, MII_BMCR);
>>> +	} while (data >= 0 && data & BMCR_RESET);
>>> +
>>> +}
>> 
>> No blank line here.
>> 
>> 
>>> +static void rxq_refill(struct net_device *dev)
>>> +{
>>> +	struct pxa168_private *mp = netdev_priv(dev);
>>> +	struct sk_buff *skb;
>>> +	struct rx_desc *p_used_rx_desc;
>>> +	int used_rx_desc;
>>> +
>>> +	while (mp->rx_desc_count < mp->rx_ring_size) {
>>> +
>>> +		skb = dev_alloc_skb(MAX_PKT_SIZE + ETH_HW_IP_ALIGN);
>> 
>> No blank line here.
>> 
>> 
>>> +	if (mp->rx_desc_count == 0) {
>>> +		printk(KERN_INFO "%s: Rx ring is empty\n", dev->name);
>> 
>> I wouldn't printk for this (and certainly not without a rate limit) --
>> going OOM will then just mean that you'll get endless console spam as
>> well, which isn't helpful.
> Hm, removed the printk.
> 
>> 
>> 
>>> +/*
>>> + * --------------------------------------------------------------------
>> --------
>>> + * This function will calculate the hash function of the address.
>>> + * depends on the hash mode and hash size.
>> 
>> Where are the hash mode and size configured?
>> 
>> 
>>> +static u32 hash_function(u32 mac_high, u32 mac_low)
>>> +{
>>> +	u32 hash_result;
>>> +	u32 addr_high;
>>> +	u32 addr_low;
>>> +	u32 addr0;
>>> +	u32 addr1;
>>> +	u32 addr2;
>>> +	u32 addr3;
>>> +	u32 addr_high_swapped;
>>> +	u32 addr_low_swapped;
>>> +
>>> +	addr_high = nibble_swapping_16_bit(mac_high);
>>> +	addr_low = nibble_swapping_32_bit(mac_low);
>>> +
>>> +	addr_high_swapped = flip_4_bits(addr_high & 0xf)
>>> +	    + ((flip_4_bits((addr_high >> 4) & 0xf)) << 4)
>>> +	    + ((flip_4_bits((addr_high >> 8) & 0xf)) << 8)
>>> +	    + ((flip_4_bits((addr_high >> 12) & 0xf)) << 12);
>>> +
>>> +	addr_low_swapped = flip_4_bits(addr_low & 0xf)
>>> +	    + ((flip_4_bits((addr_low >> 4) & 0xf)) << 4)
>>> +	    + ((flip_4_bits((addr_low >> 8) & 0xf)) << 8)
>>> +	    + ((flip_4_bits((addr_low >> 12) & 0xf)) << 12)
>>> +	    + ((flip_4_bits((addr_low >> 16) & 0xf)) << 16)
>>> +	    + ((flip_4_bits((addr_low >> 20) & 0xf)) << 20)
>>> +	    + ((flip_4_bits((addr_low >> 24) & 0xf)) << 24)
>>> +	    + ((flip_4_bits((addr_low >> 28) & 0xf)) << 28);
>>> +
>>> +	addr_high = addr_high_swapped;
>>> +	addr_low = addr_low_swapped;
>>> +
>>> +	addr0 = (addr_low >> 2) & 0x03f;
>>> +	addr1 = (addr_low & 0x003) | ((addr_low >> 8) & 0x7f) << 2;
>>> +	addr2 = (addr_low >> 15) & 0x1ff;
>>> +	addr3 = ((addr_low >> 24) & 0x0ff) | ((addr_high & 1) << 8);
>>> +
>>> +	hash_result = (addr0 << 9) | (addr1 ^ addr2 ^ addr3);
>>> +	hash_result = hash_result & 0x07ff;
>>> +	return hash_result;
>> 
>> As it's only a bunch of XORs, can you not calculate the hash function
>> first and only then do the bit reversal?
>> 
>> 
>>> + * --------------------------------------------------------------------
>> --------
>>> + * This function will add an entry to the address table.
>>> + * depends on the hash mode and hash size that was initialized.
>>> + * Inputs
>>> + * mp - ETHERNET .
>>> + * mac_high - the 2 most significant bytes of the MAC address.
>>> + * mac_low - the 4 least significant bytes of the MAC address.
>>> + * skip - if 1, skip this address.
>> 
>> What does 'skip' do?
>> 
>> 
>>> + * rd   - the RD field in the address table.
>> 
>> And what does that do?
> 
> Added more comments regarding the address filtering and the hash function.
> 
>> 
>> If one has hardware docs, this comment doesn't really add anything,
>> while if one doesn't have hardware docs, this comment doesn't really
>> explain anything -- so the comment isn't very useful.
>> 
>> 
>>> +static void update_hash_table_mac_address(struct pxa168_private *mp,
>>> +					  u8 *oaddr, u8 *addr)
>>> [...]
>>> +static int init_hashtable(struct pxa168_private *mp)
>> 
>> hash_table?
>> 
>> 
>>> +{
>>> +	u8 *addr;
>>> +	dma_addr_t reg_dma;
>>> +
>>> +	if (mp->htpr == NULL) {
>>> +		mp->htpr = dma_alloc_coherent(NULL,
>>> +					      HASH_ADDR_TABLE_SIZE + 7,
>>> +					      &mp->htpr_dma, GFP_KERNEL);
>>> +		if (mp->htpr == NULL)
>>> +			return -ENOMEM;
>>> +	}
>>> +
>>> +	/* align to 8 byte boundary */
>>> +	addr = (u8 *) (((u32) mp->htpr + 7) & ~0x7);
>>> +	reg_dma = (dma_addr_t) (((u32) mp->htpr_dma + 7) & ~0x7);
>> 
>> DMA-API-HOWTO.txt says about dma_alloc_coherent():
>> 
>> 	The cpu return address and the DMA bus master address are both
>> 	guaranteed to be aligned to the smallest PAGE_SIZE order which
>> 	is greater than or equal to the requested size.
>> 
>> So this shuffling isn't needed.
> 
> Hm, removed the shuffling code.
>> 
>> 
>> etc etc.

