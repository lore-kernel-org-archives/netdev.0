From: Franklin S Cooper Jr <fcooper-l0cyMroinI0@public.gmane.org>
Subject: Re: [v2,1/3] can: m_can: Make hclk optional
Date: Wed, 20 Sep 2017 19:31:51 -0500
Message-ID: <eb45fe94-c476-3919-603d-ff2a6b13487c@ti.com>
References: <20170724225142.19975-2-fcooper@ti.com>
 <6f574628-51cd-0db8-e5aa-e7ae4a9cf79a@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "Kristo, Tero" <t-kristo-l0cyMroinI0@public.gmane.org>, Tony Lindgren <tony-4v6yS6AI5VpBDgjK7y7TUQ@public.gmane.org>,
        Linux OMAP List <linux-omap-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Sekhar Nori <nsekhar-l0cyMroinI0@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <linux-can-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>,
        <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>, <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        <quentin.schulz-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <6f574628-51cd-0db8-e5aa-e7ae4a9cf79a-l0cyMroinI0@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



On 08/24/2017 03:00 AM, Sekhar Nori wrote:
> + some OMAP folks and Linux OMAP list
> 
> On Tuesday 25 July 2017 04:21 AM, Franklin Cooper wrote:
>> Hclk is the MCAN's interface clock. However, for OMAP based devices such as
>> DRA7 SoC family the interface clock is handled by hwmod. Therefore, this
>> interface clock is managed by hwmod driver via pm_runtime_get and
>> pm_runtime_put calls. Therefore, this interface clock isn't defined in DT
>> and thus the driver shouldn't fail if this clock isn't found.
> 
> I agree that hclk is defined as interface clock for M_CAN IP on DRA76x.
> 
> However, there may be a need for the driver to know the value of hclk to
> properly configure the RAM watchdog register which has a counter
> counting down using hclk. Looks like the driver does not use the RAM
> watchdog today. But if there is a need to configure it in future, it
> might be a problem.

Honestly the RAM watchdog seems like a fundamental design problem.
This RAM watchdog seems to be used in case a request to access the
message ram is made but it hangs for what ever reason. Its even more
complicated since the Message RAM is external to the MCAN IP so its
implementation or how its handled probably differs from device to
device. From example say you do have this error it isn't clear how you
would recover from it. A logically answer would be to reset the entire
IP but that also assumes that Message RAM will be reset along with the
ip which likely depends on each SoC.

But if a readl/writel command hangs will the kernel eventually throw an
error on its on or will the driver just hang? If it does hang can a
driver in the ISR do something to properly terminate the driver or even
recover from it?
> 
> Is there a restriction in OMAP architecture against passing the
> interface clock also in the 'clocks' property in DT. I have not tried it
> myself, but wonder if you hit an issue that led to this patch.

No but not passing the interface clock is typical.
> 
>>
>> Signed-off-by: Franklin S Cooper Jr <fcooper-l0cyMroinI0@public.gmane.org>
>> ---
>> Version 2 changes:
>> Used NULL instead of 0 for unused hclk handle
>>
>>  drivers/net/can/m_can/m_can.c | 9 +++++++--
>>  1 file changed, 7 insertions(+), 2 deletions(-)
>>
>> diff --git a/drivers/net/can/m_can/m_can.c b/drivers/net/can/m_can/m_can.c
>> index f4947a7..ea48e59 100644
>> --- a/drivers/net/can/m_can/m_can.c
>> +++ b/drivers/net/can/m_can/m_can.c
>> @@ -1568,8 +1568,13 @@ static int m_can_plat_probe(struct platform_device *pdev)
>>  	hclk = devm_clk_get(&pdev->dev, "hclk");
>>  	cclk = devm_clk_get(&pdev->dev, "cclk");
>>  
>> -	if (IS_ERR(hclk) || IS_ERR(cclk)) {
>> -		dev_err(&pdev->dev, "no clock found\n");
>> +	if (IS_ERR(hclk)) {
>> +		dev_warn(&pdev->dev, "hclk could not be found\n");
>> +		hclk = NULL;
> 
> What is the purpose of NULL setting the clock. I think this is taking it
> into a very implementation defined territory and the result could be
> different on different architectures. See Russell's explanation here:
> https://lkml.org/lkml/2016/11/10/799
> 
> Thanks,
> Sekhar
> 
>> +	}
>> +
>> +	if (IS_ERR(cclk)) {
>> +		dev_err(&pdev->dev, "cclk could not be found\n");
>>  		ret = -ENODEV;
>>  		goto failed_ret;
>>  	}
>>
> 
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
