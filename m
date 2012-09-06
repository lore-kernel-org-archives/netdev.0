From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH 04/10] net/macb: Fix a race in macb_start_xmit()
Date: Thu, 6 Sep 2012 16:52:45 +0200
Message-ID: <5048B8BD.3000804@atmel.com>
References: <cover.1346775479.git.nicolas.ferre@atmel.com> <40f02ee50a29aaec6c949432a1bcf09f4b027181.1346775479.git.nicolas.ferre@atmel.com> <20120905.173023.2235590074897156746.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-arm-kernel@lists.infradead.org>,
	<havard@skinnemoen.net>, <plagnioj@jcrosoft.com>,
	<jamie@jamieiles.com>, <linux-kernel@vger.kernel.org>,
	<patrice.vilchez@atmel.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120905.173023.2235590074897156746.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/05/2012 11:30 PM, David Miller :
> From: Nicolas Ferre <nicolas.ferre@atmel.com>
> Date: Wed, 5 Sep 2012 10:19:11 +0200
> 
>> From: Havard Skinnemoen <havard@skinnemoen.net>
>>
>> Fix a race in macb_start_xmit() where we unconditionally set the TSTART bit.
>> If an underrun just happened (we do this with interrupts disabled, so it might
>> not have been handled yet), the controller starts transmitting from the first
>> entry in the ring, which is usually wrong.
>> Restart the controller after error handling.
>>
>> Signed-off-by: Havard Skinnemoen <havard@skinnemoen.net>
>> [nicolas.ferre@atmel.com: split patch in topics]
>> Signed-off-by: Nicolas Ferre <nicolas.ferre@atmel.com>
> 
> Accumulating special case code and checks into the hot path of TX packet
> processing is extremely unwise.
> 
> Instead, when you handle the TX error conditions and reset the chip you
> should first ensure that there are no flows of control in the transmit
> function of your driver by using the appropriate locking et al. facilities.
> 
> For example, you can quiesce the transmit path by handling the chip error
> interrupt as follows:
> 
> 1) Disable chip interrupt generation.
> 
> 2) Schedule a workqueue so you can process the reset outside of hard
>    interrupt context.
> 
> 3) In the workqueue function, disable NAPI and perform a
>    netif_tx_disable() to guarentee there are no threads of
>    execution trying to queue up packets for TX into the driver.
> 
> 4) Perform your chip reset and whatever else is necessary.
> 
> 5) Re-enable NAPI and TX.
> 
> Then you don't need any special checks in your xmit method at all.

I see... I will rework the series and try to implement this as part of
the "[PATCH 06/10] net/macb: better manage tx errors"

So this patch will disappear in future v2 series and patch 06 will be
seriously modified. In fact I will also try to stack "cosmetic" patches
at the beginning of the series.

Thanks, best regards,
-- 
Nicolas Ferre
