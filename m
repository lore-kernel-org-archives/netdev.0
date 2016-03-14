From: Leon Romanovsky <leon-2ukJVAZIZ/Y@public.gmane.org>
Subject: Re: [PATCH 2/3] net: hns: add Hisilicon RoCE support
Date: Mon, 14 Mar 2016 08:49:21 +0200
Message-ID: <20160314064921.GA26456@leon.nu>
References: <1457692631-9290-1-git-send-email-oulijun@huawei.com>
 <1457692631-9290-3-git-send-email-oulijun@huawei.com>
 <20160312104301.GB15703@leon.nu>
 <56E60FFC.3000007@huawei.com>
Reply-To: leon-2ukJVAZIZ/Y@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Lijun Ou <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, gongyangming-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	xiaokun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, tangchaofei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, haifeng.wei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	yisen.zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, lisheng011-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	charles.chenxin-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org
To: "Yankejian (Hackim Yim)" <yankejian-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <56E60FFC.3000007-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 14, 2016 at 09:12:28AM +0800, Yankejian (Hackim Yim) wrote:
> 
> 
> On 2016/3/12 18:43, Leon Romanovsky wrote:
> > On Fri, Mar 11, 2016 at 06:37:10PM +0800, Lijun Ou wrote:
> >> It added hns_dsaf_roce_reset routine for roce driver.
> >> RoCE is a feature of hns.
> >> In hip06 SOC, in roce reset process, it's needed to configure
> >> dsaf channel reset,port and sl map info.
> >>
> >> Signed-off-by: Lijun Ou <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
> >> Signed-off-by: Wei Hu(Xavier) <xavier.huwei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
> >> Signed-off-by: Lisheng <lisheng011-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
> >> ---
> >>  drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c | 84 ++++++++++++++++++++++
> >>  drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h | 14 ++++
> >>  drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c | 62 +++++++++++++---
> >>  drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h  | 13 ++++
> >>  4 files changed, 163 insertions(+), 10 deletions(-)
> >>
> >> diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
> >> index 38fc5be..a0f0d4f 100644
> >> --- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
> >> +++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
> >> @@ -12,6 +12,7 @@
> >>  #include <linux/init.h>
> >>  #include <linux/interrupt.h>
> >>  #include <linux/netdevice.h>
> >> +#include <linux/of_platform.h>
> >>  #include <linux/platform_device.h>
> >>  #include <linux/of.h>
> >>  #include <linux/of_address.h>
> >> @@ -2593,6 +2594,89 @@ static struct platform_driver g_dsaf_driver = {
> >>  
> >>  module_platform_driver(g_dsaf_driver);
> >>  
> >> +/**
> >> + * hns_dsaf_roce_reset - reset dsaf and roce
> >> + * @dsaf_fwnode: Pointer to framework node for the dasf
> >> + * @val: 0 - request reset , 1 - drop reset
> >> + * retuen 0 - success , negative --fail
> >> + */
> >> +int hns_dsaf_roce_reset(struct fwnode_handle *dsaf_fwnode, u32 val)
> >> +{
> >> +	struct dsaf_device *dsaf_dev;
> >> +	struct platform_device *pdev;
> >> +	unsigned int mp;
> >> +	unsigned int sl;
> >> +	unsigned int credit;
> >> +	int i;
> >> +	const u32 port_map[DSAF_ROCE_CREDIT_CHN][DSAF_ROCE_CHAN_MODE] = {
> >> +		{0, 0, 0},
> >> +		{1, 0, 0},
> >> +		{2, 1, 0},
> >> +		{3, 1, 0},
> >> +		{4, 2, 1},
> >> +		{4, 2, 1},
> >> +		{5, 3, 1},
> >> +		{5, 3, 1},
> >> +	};
> >> +	const u32 sl_map[DSAF_ROCE_CREDIT_CHN][DSAF_ROCE_CHAN_MODE] = {
> >> +		{0, 0, 0},
> >> +		{0, 1, 1},
> >> +		{0, 0, 2},
> >> +		{0, 1, 3},
> >> +		{0, 0, 0},
> >> +		{1, 1, 1},
> >> +		{0, 0, 2},
> >> +		{1, 1, 3},
> >> +	};
> > Do you have a plan to send a version with enums/defines for this
> > numbers? Especially for _CHAN_MODE.
> >
> > .
> 
> Hi leon,
> 
>     it seems the enums is added in hns_dsaf_main.h, as belows:
> 
> diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h
> index 5fea226..c917b9a 100644
> --- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h
> +++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h
> @@ -40,6 +40,16 @@ struct hns_mac_cb;
>  #define DSAF_DUMP_REGS_NUM 504
>  #define DSAF_STATIC_NUM 28
>  
> +#define DSAF_ROCE_CREDIT_CHN 8
> +#define DSAF_ROCE_CHAN_MODE 3
> +
> +enum dsaf_roce_port_port_mode {
> +	DSAF_ROCE_6PORT_MODE,
> +	DSAF_ROCE_4PORT_MODE,
> +	DSAF_ROCE_2PORT_MODE,
> +	DSAF_ROCE_CHAN_MODE_NUM
> +};
> +

These defines are used as an index entry into si_map and port_map arrays
and seems as not related to the actual data.

I suggest you to take this code back to drawing table, redesign it,
clean unused functions and defines and resubmit it.

Thanks.

> 
> MBR, Kejian
> 
> 
> 
> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
