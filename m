From: Greg Ungerer <gerg@snapgear.com>
Subject: Re: [PATCH 2/2] net: add support for NS8390 based eth controllers
 on some ColdFire CPU boards
Date: Wed, 4 Jul 2012 16:18:25 +1000
Message-ID: <4FF3E031.5040703@snapgear.com>
References: <1341377789-12970-1-git-send-email-gerg@snapgear.com>  <1341377789-12970-3-git-send-email-gerg@snapgear.com> <1341379091.3627.15.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-m68k@vger.kernel.org>,
	Greg Ungerer <gerg@uclinux.org>
To: Joe Perches <joe@perches.com>
Return-path: <linux-m68k-owner@vger.kernel.org>
In-Reply-To: <1341379091.3627.15.camel@joe2Laptop>
Sender: linux-m68k-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Joe,

On 04/07/12 15:18, Joe Perches wrote:
> On Wed, 2012-07-04 at 14:56 +1000, gerg@snapgear.com wrote:
>> From: Greg Ungerer <gerg@uclinux.org>
>>
>> A number of older ColdFire CPU based boards use NS8390 based network
>> controllers. Most use the Davicom 9008F or the UMC 9008F. This driver
>> provides the support code to get these devices working on these platforms.
>
> Hi Greg, just some trivia:

Thanks for the quick feedback!


> []
>
>> diff --git a/drivers/net/ethernet/8390/mcf8390.c b/drivers/net/ethernet/8390/mcf8390.c
>
> []
>
>> +#ifdef NE2000_ODDOFFSET
>> +/*
>> + * A lot of the ColdFire boards use a separate address region for odd offset
>> + * register addresses. The following macros and functions convert and map
>> + * as required. Note that the data port accesses are treated a little
>> + * differently, and always accessed via the insX/outsX functions.
>> + */
>> +#define	NE_PTR(a)	(((a) & 0x1) ? (NE2000_ODDOFFSET + (a) - 1) : (a))
>
> Maybe use static inlines instead of macros?
>
> static inline void *NE_PTR(void *ptr)
> {
> 	if ((unsigned long)ptr & 1)
> 		return ptr - 1 + NE2000_ODDOFFSET;
> 	return ptr;
> }

Ok, that looks better. Though I might make the arg u32, which matches
the way that the address is passed to the IO functions currently.


> []
>
>> +static void mcf8390_get_8390_hdr(struct net_device *dev,
>> +				 struct e8390_pkt_hdr *hdr, int ring_page)
>> +{
> []
>> +	/*
>> +	 * This *shouldn't* happen.
>> +	 * If it does, it's the last thing you'll see
>> +	 */
>> +	if (ei_status.dmaing) {
>> +		netdev_err(dev,
>> +			"%s: DMAing conflict [DMAstat:%d][irqlock:%d]\n",
>> +			 __func__, ei_local->dmaing, ei_local->irqlock);
>
> This message seems to get repeated a few times.
> Maybe another function/macro or maybe a BUG?
>
> 		some_dma_err(dev, __func__, ei_local);

Yep, sure thing. I copied that part "as is", and a few of the other
drivers seem to have it done this way too. No excuses though :-)


>> +static void mcf8390_block_input(struct net_device *dev, int count,
>> +				struct sk_buff *skb, int ring_offset)
>> +{
> []
>> +	/*
>> +	 * This *shouldn't* happen.
>> +	 * If it does, it's the last thing you'll see
>> +	 */
>> +	if (ei_local->dmaing) {
>> +		netdev_err(dev,
>> +			"%s: DMAing conflict [DMAstat:%d][irqlock:%d]\n",
>> +			__func__, ei_local->dmaing, ei_local->irqlock);
>> +		return;
>> +	}
>
>> +static void mcf8390_block_output(struct net_device *dev, int count,
>> +				 const unsigned char *buf,
>> +				 const int start_page)
>> +{
> []
>> +	/*
>> +	 *This *shouldn't* happen.
>> +	 * If it does, it's the last thing you'll see
>> +	 */
>> +	if (ei_local->dmaing) {
>> +		netdev_err(dev,
>> +			"%s: DMAing conflict [DMAstat:%d][irqlock:%d]\n",
>> +			__func__, ei_local->dmaing, ei_local->irqlock);
>> +		return;
>> +	}
>
>> +static int mcf8390_init(struct net_device *dev)
>> +{
>> +	static u32 offsets[] = {
>> +		0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07,
>> +		0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f,
>> +	};
>
> const?  u8?

That is assigned to the "reg_offset" field of "struct ei_device"
(defined in the existing 8390.h) and that is:

     u32 *reg_offset;		/* Register mapping table */

So I can't change this.


>> +	pr_debug("Found ethernet address: %pM\n", dev->dev_addr);
>
> netdev_dbg ?

Sure, will change it.

Thanks for the quick feedback, much appreciated.
I'll send a revised patch in 24 hours or so.

Regards
Greg


------------------------------------------------------------------------
Greg Ungerer  --  Principal Engineer        EMAIL:     gerg@snapgear.com
SnapGear Group, McAfee                      PHONE:       +61 7 3435 2888
8 Gardner Close                             FAX:         +61 7 3217 5323
Milton, QLD, 4064, Australia                WEB: http://www.SnapGear.com
