From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH 04/10] net/macb: Fix a race in macb_start_xmit()
Date: Fri, 7 Sep 2012 18:34:48 +0200
Message-ID: <504A2228.8050501@atmel.com>
References: <cover.1346775479.git.nicolas.ferre@atmel.com> <40f02ee50a29aaec6c949432a1bcf09f4b027181.1346775479.git.nicolas.ferre@atmel.com> <20120905.173023.2235590074897156746.davem@davemloft.net> <CACiLriTSddM-5pnpii9c+4dA++OrsKovGLabegdwSRLchuSnAA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <linux-arm-kernel@lists.infradead.org>, <plagnioj@jcrosoft.com>,
	<jamie@jamieiles.com>, <linux-kernel@vger.kernel.org>,
	<patrice.vilchez@atmel.com>
To: Havard Skinnemoen <havard@skinnemoen.net>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CACiLriTSddM-5pnpii9c+4dA++OrsKovGLabegdwSRLchuSnAA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/06/2012 05:49 PM, Havard Skinnemoen :
> On Wed, Sep 5, 2012 at 11:30 PM, David Miller <davem@davemloft.net> wrote:
>> From: Nicolas Ferre <nicolas.ferre@atmel.com>
>> Date: Wed, 5 Sep 2012 10:19:11 +0200
>>
>>> From: Havard Skinnemoen <havard@skinnemoen.net>
>>>
>>> Fix a race in macb_start_xmit() where we unconditionally set the TSTART bit.
>>> If an underrun just happened (we do this with interrupts disabled, so it might
>>> not have been handled yet), the controller starts transmitting from the first
>>> entry in the ring, which is usually wrong.
>>> Restart the controller after error handling.
>>>
>>> Signed-off-by: Havard Skinnemoen <havard@skinnemoen.net>
>>> [nicolas.ferre@atmel.com: split patch in topics]
>>> Signed-off-by: Nicolas Ferre <nicolas.ferre@atmel.com>
>>
>> Accumulating special case code and checks into the hot path of TX packet
>> processing is extremely unwise.
>>
>> Instead, when you handle the TX error conditions and reset the chip you
>> should first ensure that there are no flows of control in the transmit
>> function of your driver by using the appropriate locking et al. facilities.
> 
> IIRC, the hardware resets the ring pointers when an error happens, and
> if we set TSTART right after that happens, the hardware will happily
> transmit whatever is sitting in the beginning of the ring. This is
> what I was trying to avoid.
> 
> The details are a bit hazy as it's been a while since I looked at
> this, so it could be that simply letting it happen and using a bigger
> hammer during reset processing might work just as well. Just want to
> make sure y'all understand that we're talking about a race against
> hardware, not against interrupt handlers, threads or anything that can
> be solved by locking :)

Yes, you are right Havard.

I will see if we can let the transmitter go just before being
interrupted by the pending error.

It is true that there are several cases here:
- tx immediately stopped again by the USED bit of a non initialized
descriptor. We thus have to cleanup the error frame but also take care
about the newly queued packet...
- beginning of transmission of a not-related fragment that has just been
queued by the start_xmit; just before catching the pending error IRQ. We
may have to consider the consequences of this!

So, stay tuned ;-)

Best regards,
-- 
Nicolas Ferre
