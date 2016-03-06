From: Leon Romanovsky <leon-2ukJVAZIZ/Y@public.gmane.org>
Subject: Re: [PATCH 1/4] net: hns: add Hisilicon RoCE support(the dependent
 routine)
Date: Sun, 6 Mar 2016 16:25:16 +0200
Message-ID: <20160306142516.GE13396@leon.nu>
References: <1457080877-13456-1-git-send-email-xavier.huwei@huawei.com>
 <1457080877-13456-2-git-send-email-xavier.huwei@huawei.com>
Reply-To: leon-2ukJVAZIZ/Y@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
	ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	gongyangming-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, xiaokun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	tangchaofei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, haifeng.wei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	yisen.zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, yankejian-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	lisheng011-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, charles.chenxin-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org
To: "Wei Hu(Xavier)" <xavier.huwei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1457080877-13456-2-git-send-email-xavier.huwei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Please rewrite your title to be without (...).

On Fri, Mar 04, 2016 at 04:41:14PM +0800, Wei Hu(Xavier) wrote:
> It added hns_dsaf_roce_reset routine for roce driver.
> RoCE is a feature of hns.
> In hip06 SOC, in roce reset process, it's needed to configure
> dsaf channel reset,port and sl map info.
> 
> Signed-off-by: Wei Hu(Xavier) <xavier.huwei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
> Signed-off-by: Lisheng <lisheng011-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
> Signed-off-by: oulijun <oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
> ---
>  drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c | 82 ++++++++++++++++++++++
>  drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h |  7 ++
>  drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c | 62 +++++++++++++---
>  drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h  | 14 ++++
>  4 files changed, 155 insertions(+), 10 deletions(-)
> 
> diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
> index 9439f04..41ba948 100644
> --- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
> +++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
> @@ -12,6 +12,7 @@
>  #include <linux/init.h>
>  #include <linux/interrupt.h>
>  #include <linux/netdevice.h>
> +#include <linux/of_platform.h>
>  #include <linux/platform_device.h>
>  #include <linux/of.h>
>  #include <linux/of_address.h>
> @@ -2556,6 +2557,87 @@ static struct platform_driver g_dsaf_driver = {
>  
>  module_platform_driver(g_dsaf_driver);
>  
> +/**
> + * hns_dsaf_roce_reset - reset dsaf and roce
> + * @dsaf_fwnode: Pointer to framework node for the dasf
> + * @val: 0 - request reset , 1 - drop reset
> + * retuen 0 - success , negative --fail
> + */
> +int hns_dsaf_roce_reset(struct fwnode_handle *dsaf_fwnode, u32 val)
> +{
> +	struct dsaf_device *dsaf_dev;
> +	struct platform_device *pdev;
> +	unsigned int mp;
> +	unsigned int sl;
> +	unsigned int credit;
> +	int i;
> +	const u32 port_map[DSAF_ROCE_CREDIT_CHN][DSAF_ROCE_CHAN_MODE] = {
> +		{0, 0, 0},
> +		{1, 0, 0},
> +		{2, 1, 0},
> +		{3, 1, 0},
> +		{4, 2, 1},
> +		{4, 2, 1},
> +		{5, 3, 1},
> +		{5, 3, 1},
> +	};
> +	const u32 sl_map[DSAF_ROCE_CREDIT_CHN][DSAF_ROCE_CHAN_MODE] = {
> +		{0, 0, 0},
> +		{0, 1, 1},
> +		{0, 0, 2},
> +		{0, 1, 3},
> +		{0, 0, 0},
> +		{1, 1, 1},
> +		{0, 0, 2},
> +		{1, 1, 3},
> +	};

Please prefer enums/defines instead of hard coded values.
it is applicable to whole submitted code.

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
