From: Roger Quadros <rogerq@ti.com>
Subject: Re: [PATCH v2 1/3] can: c_can_platform: Fix c_can_hw_raminit_ti()
 and add timeout
Date: Tue, 9 Sep 2014 17:45:40 +0300
Message-ID: <540F1294.9080107@ti.com>
References: <1410273070-22485-1-git-send-email-rogerq@ti.com> <1410273070-22485-2-git-send-email-rogerq@ti.com> <540F0FEE.2040202@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <tony@atomide.com>, <tglx@linutronix.de>, <mugunthanvnm@ti.com>,
	<george.cherian@ti.com>, <balbi@ti.com>, <nsekhar@ti.com>,
	<sergei.shtylyov@cogentembedded.com>, <linux-omap@vger.kernel.org>,
	<linux-can@vger.kernel.org>, <netdev@vger.kernel.org>
To: Nishanth Menon <nm@ti.com>, <wg@grandegger.com>,
	<mkl@pengutronix.de>
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <540F0FEE.2040202@ti.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/09/2014 05:34 PM, Nishanth Menon wrote:
> On 09/09/2014 09:31 AM, Roger Quadros wrote:
>> Pass the correct 'mask' and 'value' bits to c_can_hw_raminit_wait_ti().
>> They seem to have been swapped in the usage instances.
>>
>> TI's RAMINIT DONE mechanism is buggy and may not always be
>> set after the START bit is set. So add a timeout mechanism to
>> c_can_hw_raminit_wait_ti().
>>
>> Signed-off-by: Roger Quadros <rogerq@ti.com>
>> ---
>>  drivers/net/can/c_can/c_can_platform.c | 14 +++++++++++---
>>  1 file changed, 11 insertions(+), 3 deletions(-)
>>
>> diff --git a/drivers/net/can/c_can/c_can_platform.c b/drivers/net/can/c_can/c_can_platform.c
>> index 109cb44..b144e71 100644
>> --- a/drivers/net/can/c_can/c_can_platform.c
>> +++ b/drivers/net/can/c_can/c_can_platform.c
>> @@ -75,10 +75,18 @@ static void c_can_plat_write_reg_aligned_to_32bit(const struct c_can_priv *priv,
>>  static void c_can_hw_raminit_wait_ti(const struct c_can_priv *priv, u32 mask,
>>  				  u32 val)
>>  {
>> +	int timeout = 0;
>>  	/* We look only at the bits of our instance. */
>>  	val &= mask;
>> -	while ((readl(priv->raminit_ctrlreg) & mask) != val)
>> +	while ((readl(priv->raminit_ctrlreg) & mask) != val) {
>>  		udelay(1);
>> +		timeout++;
>> +
>> +		if (timeout == 1000) {
> 
> How did we come up with this number?

wild guess ;), that it should be set in a few microseconds and the delay is not too
large.

Till I don't hear from hardware guys, it will remain a guess.

> 
>> +			dev_err(&priv->dev->dev, "%s: time out\n", __func__);
>> +			break;
> lets say we did timeout..
> see below:
>> +		}
>> +	}
>>  }
>>  
>>  static void c_can_hw_raminit_ti(const struct c_can_priv *priv, bool enable)
>> @@ -97,14 +105,14 @@ static void c_can_hw_raminit_ti(const struct c_can_priv *priv, bool enable)
>>  	ctrl |= CAN_RAMINIT_DONE_MASK(priv->instance);
>>  	writel(ctrl, priv->raminit_ctrlreg);
>>  	ctrl &= ~CAN_RAMINIT_DONE_MASK(priv->instance);
>> -	c_can_hw_raminit_wait_ti(priv, ctrl, mask);
>> +	c_can_hw_raminit_wait_ti(priv, mask, ctrl);
>>  
>>  	if (enable) {
>>  		/* Set start bit and wait for the done bit. */
>>  		ctrl |= CAN_RAMINIT_START_MASK(priv->instance);
>>  		writel(ctrl, priv->raminit_ctrlreg);
>>  		ctrl |= CAN_RAMINIT_DONE_MASK(priv->instance);
>> -		c_can_hw_raminit_wait_ti(priv, ctrl, mask);
>> +		c_can_hw_raminit_wait_ti(priv, mask, ctrl);
> 
> is it possible for us to continue? does it make sense for us to change
> that void to a int and handle error cascading?

I will verify this first to check if the hardware works or not in the failing case.
Considering we never checked for the DONE bit in our earlier TI releases maybe it works.

But I'll verify and get back.
> 
>>  	}
>>  	spin_unlock(&raminit_lock);
>>  }
>>
> 
> 

cheers,
-roger
