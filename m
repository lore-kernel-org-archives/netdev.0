From: Franklin S Cooper Jr <fcooper@ti.com>
Subject: Re: [PATCH v2 1/3] can: m_can: Make hclk optional
Date: Wed, 20 Sep 2017 18:29:43 -0500
Message-ID: <f6011853-9056-c454-6c98-c455310fa7b5@ti.com>
References: <20170724225142.19975-1-fcooper@ti.com>
 <20170724225142.19975-2-fcooper@ti.com>
 <096c73b1-eaa5-8c40-4486-e08a784c0897@gmx.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: =?UTF-8?Q?Mario_H=c3=bcttel?= <mario.huettel@gmx.net>,
        <linux-kernel@vger.kernel.org>, <devicetree@vger.kernel.org>,
        <netdev@vger.kernel.org>, <linux-can@vger.kernel.org>,
        <wg@grandegger.com>, <mkl@pengutronix.de>, <robh+dt@kernel.org>,
        <quentin.schulz@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <096c73b1-eaa5-8c40-4486-e08a784c0897@gmx.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 09/20/2017 05:00 PM, Mario Hüttel wrote:
>> Hclk is the MCAN's interface clock. However, for OMAP based devices such as
>> DRA7 SoC family the interface clock is handled by hwmod. Therefore, this
>> interface clock is managed by hwmod driver via pm_runtime_get and
>> pm_runtime_put calls. Therefore, this interface clock isn't defined in DT
>> and thus the driver shouldn't fail if this clock isn't found.
> I also agree in this point.
> However, there's a problem I want to point out:
> 
> The M_CAN can only function correctly, if the condition
> 'hclk >= cclk' holds true.
> 
> The internal clock domain crossing can fail if this condition
> is violated.
> 
> I thought about adding the condition to the driver to ensure
> correct operation. But I had some problems:
> 
> 1. Determine the clock rates:
>     The devices you've mentioned above don't have an assigned
>     hclk. Is there still a possibility to get the clock frequency?

I believe interface clocks via hwmod aren't exposed to drivers. So the
only way to get access to the clock frequency is to add this interface
clock to dt.

> 
> 2. What to do if 'hclk < cclk'?
>     Is there a general way to process such an error? - I think not.
>     Is a simple warning in case of an error enough?
> 
> Is there a way of ensuring that the condition is always met at all?
> 
> I think it is quite unlikely that the condition is violated, because
> devices that actually run Linux usually have (bus) clock rates that
> are high enough to ensure the correct operation.
> 
> Would it be safe to just ignore this possible fault?

I think alot of peripherals have similar constraints when there is an
interface and functional clock. However, I haven't seen drivers verify
that this kind of constraint is properly met. Personally I think its a
valid fault but one that can be ignored from the driver perspective.
> 
> Regards
> 
> Mario
>    
>>
>> Signed-off-by: Franklin S Cooper Jr <fcooper@ti.com>
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
>> +	}
>> +
>> +	if (IS_ERR(cclk)) {
>> +		dev_err(&pdev->dev, "cclk could not be found\n");
>>  		ret = -ENODEV;
>>  		goto failed_ret;
>>  	}
> 
> 
