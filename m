From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Silicom bypass driver promote from staging
Date: Mon, 29 Sep 2014 23:52:24 +0200
Message-ID: <20140929215224.GA1166@electric-eye.fr.zoreil.com>
References: <3BFAEADE799AF145974162DF00E013AF018F80FFCF@exchange2010.silicom.local>
 <20140805150957.GC27303@kroah.com>
 <3BFAEADE799AF145974162DF00E013AF018F814DAB@exchange2010.silicom.local>
 <20140807215115.GB19520@electric-eye.fr.zoreil.com>
 <3BFAEADE799AF145974162DF00E013AF018F8C8A9F@exchange2010.silicom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"arnd@arndb.de" <arnd@arndb.de>, Anna Lukin <annal@silicom.co.il>,
	"gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>
To: David Hendel <david@silicom.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:54076 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751215AbaI2Vwa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2014 17:52:30 -0400
Content-Disposition: inline
In-Reply-To: <3BFAEADE799AF145974162DF00E013AF018F8C8A9F@exchange2010.silicom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Hendel <david@silicom.co.il> :
> Hi all,
> Sorry, for the late response, we had to go over all the code and update as requested and then test to verify, so here it is.

Your messages should look like:

http://marc.info/?l=linux-netdev&m=140720472303311&w=2

(especially the Subject: field)

[...]
> >Notwithstanding Stephen and Jeff's remarks, you should also:
> >- remove the (out-)commented code
> >- reconsider the use of gorilla class macros vs plain functions
> >- stop casting ioremap return into long, then later into void *. It's
> >  void __iomem * and should stay so.
> >- use a consistent locking style and remove BP_SYNC_FLAG
> >- fix the 80 cols limit problem(s) (hardly surprizing after 5 levels of
>  > nested "if")
> >- avoid redefining stuff from include/uapi/linux/mii.h
> > I may be wrong but BPCTLI_MII_CR_POWER_DOWN smells of BMCR_PDOWN and
> >  BPCTLI_PHY_CONTROL, well, MII_BMCR ?
> >- avoid returning with spinlock held (read_reg, wdt_pulse)
> >- start explaining what did change between two submissions
> 
> This is what we changed in updated patch:
> 1. Avoid redefining BIT and MII .
> 2. Fixing returning with spinlock held
> 3. Remove BP_SYNC_FLAG
> 4. Use void __iomem * instead of long long in ioremap return

/me greps mem_map

> +		iounmap((void *)dev->mem_map);
> +		iounmap((void *)(bpctl_dev_arr[i].mem_map));
> +	(writel((value), (void *)(((a)->mem_map) + BPCTLI_##reg)))
> +	readl((void *)((a)->mem_map) + BPCTLI_##reg))
> +	(writel((value), (void *)(((a)->mem_map) + BP10G_##reg)))
> +	readl((void *)((a)->mem_map) + BP10G_##reg))
> +	(writel((value), (void *)(((a)->mem_map) + BP10GB_##reg)))
> +	readl((void *)((a)->mem_map) + BP10GB_##reg))

Please remove the useless void * casts

[...]
> diff -uprN -X linux-3.17-rc1-vanilla/Documentation/dontdiff linux-3.17-rc1-vanilla/drivers/bypass/silicom/bp_ctl/bpctl_mod.c linux-3.17-rc1/drivers/bypass/silicom/bp_ctl/bpctl_mod.c
> --- linux-3.17-rc1-vanilla/drivers/bypass/silicom/bp_ctl/bpctl_mod.c	1970-01-01 02:00:00.000000000 +0200
> +++ linux-3.17-rc1/drivers/bypass/silicom/bp_ctl/bpctl_mod.c	2014-09-09 00:43:05.000000000 +0300
[...]
> +static struct bpctl_dev *lookup_port(struct bpctl_dev *dev)
> +{
> +	struct bpctl_dev *p;
> +	int n;
> +
> +	for (n = 0, p = bpctl_dev_arr; n < device_num && p->pdev; n++, p++) {
> +		if (p->bus == dev->bus
> +			&& p->slot == dev->slot
> +			&& p->func == (dev->func ^ 1))

Binary operators should end the line. They shouldn't start it.

> +			return p;
> +	}
> +	return NULL;
> +}
[...]
> +static int get_dev_idx_bsf(int bus, int slot, int func)
> +{
> +	int idx_dev = 0;
> +
> +	for (idx_dev = 0;
> +		((bpctl_dev_arr[idx_dev].pdev != NULL) &&
> +		 (idx_dev < device_num)); idx_dev++) {
> +		if ((bus == bpctl_dev_arr[idx_dev].bus)
> +			&& (slot == bpctl_dev_arr[idx_dev].slot)
> +			&& (func == bpctl_dev_arr[idx_dev].func))
> +
> +			return idx_dev;
> +	}
> +	return BP_NOT_CAP;

	snort *p = bpctl_dev_arr;
	int i;

	for (i = 0; i < device_num && p->pdev; i++, p++) {
		if (bus == p->bus && slot == p->slot && func == p-> func)
			return i;
	}

It appears multiple times.

> +}
> +
> +static int bp_get_dev_idx_bsf(struct net_device *dev, int *index)
> +{
> +	struct ethtool_drvinfo drvinfo = {0};
> +	char *buf;
> +	int bus, slot, func;
> +
> +	if (dev->ethtool_ops && dev->ethtool_ops->get_drvinfo)
> +		dev->ethtool_ops->get_drvinfo(dev, &drvinfo);
> +	else
> +		return -EOPNOTSUPP;

	if (!dev->ethtool_ops || !dev->ethtool_ops->get_drvinfo)
		return -EOPNOTSUPP;

[...]
> +static void write_pulse(struct bpctl_dev *pbpctl_dev,
> +			unsigned int ctrl_ext,
> +			unsigned char value, unsigned char len)
> +{
> +	unsigned char ctrl_val = 0;
> +	unsigned int i = len;
> +	unsigned int ctrl = 0;
> +	struct bpctl_dev *pbpctl_dev_c = NULL;
> +
> +	switch (pbpctl_dev->nic_type) {
> +	case bp_i80:
> +		ctrl = BPCTL_READ_REG(pbpctl_dev, CTRL_EXT);
> +		break;
> +	case bp_540:
> +		ctrl = BP10G_READ_REG(pbpctl_dev, ESDP);
> +		break;
> +	case bp_10g9:
> +		pbpctl_dev_c = get_status_port(pbpctl_dev);
> +		if (!pbpctl_dev_c)
> +			return;
> +		ctrl = BP10G_READ_REG(pbpctl_dev_c, ESDP);
> +		break;
> +	default:
> +		break;
> +	}
> +
> +	while (i--) {
> +		ctrl_val = (value >> i) & 0x1;
> +		if (ctrl_val) {
[snip]
		if (ctrl_val)
			helper_one(...);
		else
			helper_two(...);

It should help with:

[...]		
> +			case bp_fiber5:
> +				BPCTL_BP_WRITE_REG(pbpctl_dev, CTRL, (ctrl_ext |
> +						BPCTLI_CTRL_EXT_MCLK_DIR5
> +						|
> +						BPCTLI_CTRL_EXT_MDIO_DIR5
> +						|
> +						BPCTLI_CTRL_EXT_MDIO_DATA5
> +						|
> +						BPCTLI_CTRL_EXT_MCLK_DATA5));

as well as:
[...]

> +			case bp_fiber5:
> +				BPCTL_BP_WRITE_REG(pbpctl_dev, CTRL,
> +						((ctrl_ext |
> +						  BPCTLI_CTRL_EXT_MCLK_DIR5 |
> +						  BPCTLI_CTRL_EXT_MDIO_DIR5 |
> +						  BPCTLI_CTRL_EXT_MCLK_DATA5)
> +						  &
> +						  ~
> +						(BPCTLI_CTRL_EXT_MDIO_DATA5)));

[...]
> +			case bp_i80:
> +				BPCTL_BP_WRITE_REG(pbpctl_dev, CTRL,
> +					((ctrl_ext |
> +					  BPCTLI_CTRL_EXT_MDIO_DIR80)
> +					  &
> +					  ~
> +					  (BPCTLI_CTRL_EXT_MDIO_DATA80)));

Excess parenthesis.

[...]
> +static s32 bp75_get_hw_semaphore_generic(struct bpctl_dev *pbpctl_dev)
> +{
[...]
> +	if (i == timeout) {
> +		/* Release semaphores */
> +		bp75_put_hw_semaphore_generic(pbpctl_dev);
> +		pr_err("Can't access the NVM\n");
> +		ret_val = -1;
> +		goto out;
> +	}
> +
> + out:

Useless goto.


> +	return ret_val;
> +}
[...]
> +static s32 bp75_acquire_phy(struct bpctl_dev *pbpctl_dev)
> +{
> +	u16 mask = BPCTLI_SWFW_PHY0_SM;
> +	u32 swfw_sync;
> +	u32 swmask;
> +	u32 fwmask;
> +	s32 ret_val = 0;
> +	s32 i = 0, timeout = 200;
> +
> +	if ((pbpctl_dev->func == 1) || (pbpctl_dev->func == 3))
> +		mask = BPCTLI_SWFW_PHY1_SM;
> +
> +	swmask = mask;
> +	fwmask = mask << 16;
> +
> +	while (i < timeout) {

	for (i = 0; i < timeout; i++)

I won't be able to read all this code and provide much valuable feedback
in a decent timeframe (huge macros, uint32_t and friends are still there).

The style may need more work but it could be necessary to split the big
pile of code into manageable patches (core features, config, more features,
more hardware support ?). Both your internal and external APIs may prove
real showstoppers (*lots* of EXPORT_SYMBOL, proc files and ioctl).

Imho you are pushing a lot of specialized use code and it will take
weeks rather than days of work before it settles down.

-- 
Ueimor
