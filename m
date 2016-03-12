From: Leon Romanovsky <leon@leon.nu>
Subject: Re: [PATCH 2/3] net: hns: add Hisilicon RoCE support
Date: Sat, 12 Mar 2016 12:43:01 +0200
Message-ID: <20160312104301.GB15703@leon.nu>
References: <1457692631-9290-1-git-send-email-oulijun@huawei.com>
 <1457692631-9290-3-git-send-email-oulijun@huawei.com>
Reply-To: leon@leon.nu
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dledford@redhat.com, sean.hefty@intel.com,
	hal.rosenstock@gmail.com, davem@davemloft.net,
	jeffrey.t.kirsher@intel.com, jiri@mellanox.com,
	ogerlitz@mellanox.com, linux-rdma@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	gongyangming@huawei.com, xiaokun@huawei.com,
	tangchaofei@huawei.com, haifeng.wei@huawei.com,
	yisen.zhuang@huawei.com, yankejian@huawei.com,
	lisheng011@huawei.com, charles.chenxin@huawei.com,
	linuxarm@huawei.com
To: Lijun Ou <oulijun@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:35995 "EHLO
	mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752702AbcCLKy6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Mar 2016 05:54:58 -0500
Received: by mail-wm0-f50.google.com with SMTP id n186so49226707wmn.1
        for <netdev@vger.kernel.org>; Sat, 12 Mar 2016 02:54:56 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1457692631-9290-3-git-send-email-oulijun@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 11, 2016 at 06:37:10PM +0800, Lijun Ou wrote:
> It added hns_dsaf_roce_reset routine for roce driver.
> RoCE is a feature of hns.
> In hip06 SOC, in roce reset process, it's needed to configure
> dsaf channel reset,port and sl map info.
> 
> Signed-off-by: Lijun Ou <oulijun@huawei.com>
> Signed-off-by: Wei Hu(Xavier) <xavier.huwei@huawei.com>
> Signed-off-by: Lisheng <lisheng011@huawei.com>
> ---
>  drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c | 84 ++++++++++++++++++++++
>  drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.h | 14 ++++
>  drivers/net/ethernet/hisilicon/hns/hns_dsaf_misc.c | 62 +++++++++++++---
>  drivers/net/ethernet/hisilicon/hns/hns_dsaf_reg.h  | 13 ++++
>  4 files changed, 163 insertions(+), 10 deletions(-)
> 
> diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_main.c
> index 38fc5be..a0f0d4f 100644
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
> @@ -2593,6 +2594,89 @@ static struct platform_driver g_dsaf_driver = {
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

Do you have a plan to send a version with enums/defines for this
numbers? Especially for _CHAN_MODE.
