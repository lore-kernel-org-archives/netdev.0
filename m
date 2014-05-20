From: zhangfei <zhangfei.gao@linaro.org>
Subject: Re: [PATCH 1/3] hix5hd2-clock: add complex clk
Date: Tue, 20 May 2014 20:02:50 +0800
Message-ID: <537B446A.2080500@linaro.org>
References: <1400504227-12047-1-git-send-email-zhangfei.gao@linaro.org> <1400504227-12047-2-git-send-email-zhangfei.gao@linaro.org> <063D6719AE5E284EB5DD2968C1650D6D1724924B@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	Jiancheng Xue <xuejiancheng@huawei.com>
To: David Laight <David.Laight@ACULAB.COM>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"arnd@arndb.de" <arnd@arndb.de>,
	"f.fainelli@gmail.com" <f.fainelli@gmail.com>,
	"sergei.shtylyov@cogentembedded.com"
	<sergei.shtylyov@cogentembedded.com>,
	"mark.rutland@arm.com" <mark.rutland@arm.com>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"haifeng.yan@linaro.org" <haifeng.yan@linaro.org>,
	"jchxue@gmail.com" <jchxue@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:64247 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751161AbaETMC5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 May 2014 08:02:57 -0400
Received: by mail-pa0-f48.google.com with SMTP id rd3so263949pab.21
        for <netdev@vger.kernel.org>; Tue, 20 May 2014 05:02:56 -0700 (PDT)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1724924B@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear David

On 05/19/2014 09:11 PM, David Laight wrote:
> From: Zhangfei Gao
> ...
>> diff --git a/drivers/clk/hisilicon/clk-hix5hd2.c b/drivers/clk/hisilicon/clk-hix5hd2.c
>> index e5fcfb4..1b1347f 100644
>> --- a/drivers/clk/hisilicon/clk-hix5hd2.c
>> +++ b/drivers/clk/hisilicon/clk-hix5hd2.c
>> @@ -9,6 +9,8 @@
>>
>>   #include <linux/of_address.h>
>>   #include <dt-bindings/clock/hix5hd2-clock.h>
>> +#include <linux/slab.h>
>> +#include <linux/delay.h>
>>   #include "clk.h"
>>
>>   static struct hisi_fixed_rate_clock hix5hd2_fixed_rate_clks[] __initdata = {
>> @@ -79,8 +81,186 @@ static struct hisi_gate_clock hix5hd2_gate_clks[] __initdata = {
>>   		CLK_SET_RATE_PARENT, 0xa0, 1, 0, },
>>   	{ HIX5HD2_MMC_CIU_RST, "rst_mmc_ciu", "clk_mmc_ciu",
>>   		CLK_SET_RATE_PARENT, 0xa0, 4, CLK_GATE_SET_TO_DISABLE, },
>> +	/*gsf*/
>> +	{ HIX5HD2_FWD_BUS_CLK, "clk_fwd_bus", NULL, 0, 0xcc, 0, 0, },
>> +	{ HIX5HD2_FWD_SYS_CLK, "clk_fwd_sys", "clk_fwd_bus", 0, 0xcc, 5, 0, },
>> +	{ HIX5HD2_MAC0_PHY_CLK, "clk_fephy", "clk_fwd_sys",
>> +		 CLK_SET_RATE_PARENT, 0x120, 0, 0, },
>>   };
>>
>> +enum {TYPE_COMPLEX, TYPE_ETHER};
>
> Shouldn't this be a named enum to make it more obvious
> where the values should be used?
Yes, it's better.
>
>> +
>> +struct hix5hd2_complex_clock {
>> +	unsigned int	id;
>
> Reorder the fields to avoid the implicit pad here.
Curious, what's the impact if there is a pad.
It may inconsistent with other table.

>
>> +	const char	*name;
>> +	const char	*parent_name;
>> +	u32		ctrl_reg;
>> +	u32		ctrl_clk_mask;
>> +	u32		ctrl_rst_mask;
>> +	u32		phy_reg;
>> +	u32		phy_clk_mask;
>> +	u32		phy_rst_mask;
>> +	u32		type;
>> +};
>> +
>> +struct hix5hd2_clk_complex {
>> +	struct clk_hw	hw;
>> +	u32		id;
>> +	void __iomem	*ctrl_reg;
>> +	u32		ctrl_clk_mask;
>> +	u32		ctrl_rst_mask;
>> +	void __iomem	*phy_reg;
>> +	u32		phy_clk_mask;
>> +	u32		phy_rst_mask;
>> +};
>> +
>> +static struct hix5hd2_complex_clock hix5hd2_complex_clks[] __initdata = {
>> +	{HIX5HD2_MAC0_CLK, "clk_mac0", "clk_fephy",
>> +		0xcc, 0xa, 0x500, 0x120, 0, 0x10, TYPE_ETHER},
>> +	{HIX5HD2_MAC1_CLK, "clk_mac1", "clk_fwd_sys",
>> +		0xcc, 0x14, 0xa00, 0x168, 0x2, 0, TYPE_ETHER},
>> +	{HIX5HD2_SATA_CLK, "clk_sata", NULL,
>> +		0xa8, 0x1f, 0x300, 0xac, 0x1, 0x0, TYPE_COMPLEX},
>> +	{HIX5HD2_USB_CLK, "clk_usb", NULL,
>> +		0xb8, 0xff, 0x3f00, 0xbc, 0x7, 0x3f00, TYPE_COMPLEX},
>> +};
>> +
>> +#define to_complex_clk(_hw) container_of(_hw, struct hix5hd2_clk_complex, hw)
>> +
>> +static int clk_ether_enable(struct clk_hw *hw)
>> +{
>> +	struct hix5hd2_clk_complex *clk = to_complex_clk(hw);
>> +	u32 val;
>> +
>> +	val = readl(clk->ctrl_reg);
>> +	val |= clk->ctrl_clk_mask | clk->ctrl_rst_mask;
>> +	writel(val, clk->ctrl_reg);
>> +	udelay(50);
>> +	val &= ~(clk->ctrl_rst_mask);
>> +	writel(val, clk->ctrl_reg);
>
> I'd need to be convinced that the udelay() has the desired effect.
> I suspect you are trying to assert reset for a minimum period.
Yes, it is just want to make sure the reset takeing effect.
In fact, it works without udelay here, it is not required as timing as 
the following mdelay.

> However the first write can be 'posted' by all sorts of hardware
> for all sorts of reasons - so the writes can actually be back to back.
Sorry, not understand.
Do you mean the first write will not take effect immediately, so the two 
write happens continuously.
What's the recommended behavior?

Will use readl_relaxed & writel_relaxed instead.

>
> 	David
>
>> +
>> +	val = readl(clk->phy_reg);
>> +	val |= clk->phy_clk_mask;
>> +	val &= ~(clk->phy_rst_mask);
>> +	writel(val, clk->phy_reg);
>> +	mdelay(10);
>> +
>> +	val &= ~(clk->phy_clk_mask);
>> +	val |= clk->phy_rst_mask;
>> +	writel(val, clk->phy_reg);
>> +	mdelay(10);
>> +
>> +	val |= clk->phy_clk_mask;
>> +	val &= ~(clk->phy_rst_mask);
>> +	writel(val, clk->phy_reg);
>> +	mdelay(30);
>> +	return 0;
>> +}
>> +

Thanks
