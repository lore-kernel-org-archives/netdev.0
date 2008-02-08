From: Yoshihiro Shimoda <shimoda.yoshihiro@renesas.com>
Subject: Re: [PATCHv2] net: sh_eth: Add support for Renesas SuperH Ethernet
Date: Fri, 08 Feb 2008 19:40:25 +0900
Message-ID: <47AC3199.5040203@renesas.com>
References: <47AAC3BB.9090107@renesas.com>
 <20080207010529.868e931b.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org,
	David Brownell <david-b@pacbell.net>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.renesas.com ([202.234.163.13]:41498 "EHLO
	mail04.idc.renesas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S933314AbYBHKiq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2008 05:38:46 -0500
Received: from mail04.idc.renesas.com ([127.0.0.1])
 by mail04.idc.renesas.com. (SMSSMTP 4.1.13.45) with SMTP id M2008020819383917554
 for <netdev@vger.kernel.org>; Fri, 08 Feb 2008 19:38:39 +0900
In-reply-to: <20080207010529.868e931b.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Morton wrote:
> On Thu, 07 Feb 2008 17:39:23 +0900 Yoshihiro Shimoda <shimoda.yoshihiro@renesas.com> wrote:
> 
>> Add support for Renesas SuperH Ethernet controller.
>> This driver supported SH7710 and SH7712.
>>
> 
> Nice looking driver.
> 
> Quick comments:

Thank you very much for your comment.

>> +static void __init update_mac_address(struct net_device *ndev)
>> 
>> --- snip ---
>> 
>> +static void __init read_mac_address(struct net_device *ndev)
> 
> Both the above functions are called from non-__init code and hence cannot
> be __init.  sh_eth_tsu_init() is wrong too.  Please check all section
> annotations in the driver.

I understood it. I will modify it.

>> +struct bb_info {
>> +	struct mdiobb_ctrl ctrl;
>> +	u32 addr;
>> +	u32 mmd_msk;/* MMD */
>> +	u32 mdo_msk;
>> +	u32 mdi_msk;
>> +	u32 mdc_msk;
>> +};
> 
> Please cc David Brownell on updates to this driver - perhaps he will find
> time to review the bit-banging interface usage.
> 
>> +/* PHY bit set */
>> +static void bb_set(u32 addr, u32 msk)
>> +{
>> +	ctrl_outl(ctrl_inl(addr) | msk, addr);
>> +}
>> +
>> +/* PHY bit clear */
>> +static void bb_clr(u32 addr, u32 msk)
>> +{
>> +	ctrl_outl((ctrl_inl(addr) & ~msk), addr);
>> +}
>> +
>> +/* PHY bit read */
>> +static int bb_read(u32 addr, u32 msk)
>> +{
>> +	return (ctrl_inl(addr) & msk) != 0;
>> +}
>> +
>> +/* Data I/O pin control */
>> +static inline void sh__mmd_ctrl(struct mdiobb_ctrl *ctrl, int bit)
>> +{
>> +	struct bb_info *bitbang = container_of(ctrl, struct bb_info, ctrl);
>> +	if (bit)
>> +		bb_set(bitbang->addr, bitbang->mmd_msk);
>> +	else
>> +		bb_clr(bitbang->addr, bitbang->mmd_msk);
>> +}
>> +
>> +/* Set bit data*/
>> +static inline void sh__set_mdio(struct mdiobb_ctrl *ctrl, int bit)
>> +{
>> +	struct bb_info *bitbang = container_of(ctrl, struct bb_info, ctrl);
>> +
>> +	if (bit)
>> +		bb_set(bitbang->addr, bitbang->mdo_msk);
>> +	else
>> +		bb_clr(bitbang->addr, bitbang->mdo_msk);
>> +}
>> +
>> +/* Get bit data*/
>> +static inline int sh__get_mdio(struct mdiobb_ctrl *ctrl)
>> +{
>> +	struct bb_info *bitbang = container_of(ctrl, struct bb_info, ctrl);
>> +	return bb_read(bitbang->addr, bitbang->mdi_msk);
>> +}
> 
> There seems to be a fairly random mixture of inline and non-inline here. 
> I'd suggest that you just remove all the `inline's.  The compiler does a
> pretty good job of working doing this for you.

I understood it. I will remove inline. I will not use inline in future
as far as there is not a special reason.

>> +/* MDC pin control */
>> +static inline void sh__mdc_ctrl(struct mdiobb_ctrl *ctrl, int bit)
>> +{
>> +	struct bb_info *bitbang = container_of(ctrl, struct bb_info, ctrl);
>> +
>> +	if (bit)
>> +		bb_set(bitbang->addr, bitbang->mdc_msk);
>> +	else
>> +		bb_clr(bitbang->addr, bitbang->mdc_msk);
>> +}
>> +
>> +/* mdio bus control struct */
>> +static struct mdiobb_ops bb_ops = {
>> +	.owner = THIS_MODULE,
>> +	.set_mdc = sh__mdc_ctrl,
>> +	.set_mdio_dir = sh__mmd_ctrl,
>> +	.set_mdio_data = sh__set_mdio,
>> +	.get_mdio_data = sh__get_mdio,
>> +};
> 
> It's particularly inappropriate that sh__mdc_ctrl() was inlined - it is
> only ever called via a function pointer and hence will never be inlined!

I understood it.

>> ...
>>
>> +static void sh_eth_timer(unsigned long data)
>> +{
>> +	struct net_device *ndev = (struct net_device *)data;
>> +	struct sh_eth_private *mdp = netdev_priv(ndev);
>> +	int next_tick = 10 * HZ;
>> +
>> +	/* We could do something here... nah. */
>> +	mdp->timer.expires = jiffies + next_tick;
>> +	add_timer(&mdp->timer);
> 
> mod_timer() would be neater here.
> 
>> +}
>>
>> --- snip ---
>>
>> +	/* Set the timer to check for link beat. */
>> +	init_timer(&mdp->timer);
>> +	mdp->timer.expires = (jiffies + (24 * HZ)) / 10;/* 2.4 sec. */
>> +	mdp->timer.data = (u32) ndev;
>> +	mdp->timer.function = sh_eth_timer;	/* timer handler */
> 
> setup_timer()

I understood it. I will modify these.

>> +}
>> +
>>
>> +#ifdef __LITTLE_ENDIAN__
>> +static inline void swaps(char *src, int len)
>> +{
>> +	u32 *p = (u32 *)src;
>> +	u32 *maxp;
>> +	maxp = p + ((len + sizeof(u32) - 1) / sizeof(u32));
>> +
>> +	for (; p < maxp; p++)
>> +		*p = swab32(*p);
>> +}
>> +#else
>> +#define swaps(x, y)
>> +#endif
>> +
> 
> I'd say that the big-endian version of swaps() should be a C function
> rather than a macro.  It's nicer to look at, consistent, provides typechecking,
> can help avoid unused-variable warnings (an inline function provides a
> reference to the arguments whereas a macro does not).
> 
> The little-endian version of this function is too large to be inlined.
> 
> This function looks fairly generic.  Are we sure there isn't some library
> function which does this?
> 

I looked for lib/ and include/linux/ and include/linux/byteorder/, but
such function was not found. So I will modify swaps().

Thanks,
Yoshihiro Shimoda
