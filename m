From: Jason Wang <jason77.wang@gmail.com>
Subject: Re: [PATCH] smsc911x: add disable and re-enable Rx int to de-assert
 interrupt pin
Date: Fri, 24 Dec 2010 10:18:00 +0800
Message-ID: <4D1402D8.2040709@gmail.com>
References: <1293100993-3956-1-git-send-email-jason77.wang@gmail.com> <20101223.095917.59696176.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jason77.wang@gmail.com, netdev@vger.kernel.org,
	steve.glendinning@smsc.com, linux-omap@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <20101223.095917.59696176.davem@davemloft.net>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Jason Wang <jason77.wang@gmail.com>
> Date: Thu, 23 Dec 2010 18:43:13 +0800
>
>   
>> When kernel enters irqhanlder, it will check the Rx interrupt status
>> bit, if Rx status is set but can't call napi_schedule(), it will do
>> nothing and directly return form irqhandler. This situation is prone
>> to be produced when we repeatly call irqhandler through netpoll
>> interface(i.e kgdboe connecting).
>>
>> This is a potential risk for those level triggered platforms(i.e
>> ti_omap3evm), because if we don't handle Rx int and just return from
>> irqhandler, the irq pin will be keeping asserted, the level triggered
>> platforms will have no chance to jump out from the Rx irq. The whole
>> system will hung into the irq subsystem.
>>
>> To solve it, we add a disable/re-enable Rx int operation for this
>> situation, this operation can de-assert interrupt pin for this time
>> and will leave the received data and status in the FIFO for later
>> interrupts to handle.
>>
>> Signed-off-by: Jason Wang <jason77.wang@gmail.com>
>>     
>
>   
Hi David,

Thanks for your comments.
> You absolutely cannot do this.
>
> You now can race with the NAPI completion code turning the RX
> interrupts back on, and you'll leave the chip with RX interrupts
> disabled.
>   
I think my modification almost have the same execution path as the 
original design and don't produce the race condition with NAPI threads.

The original design is:
If (can call napi_schedule) {
disable rx int;
call napi_schedule()
} else {
keep rx int enabled;
return;
}

my modification is:
disable rx int;
if (can call napi_schedule) {
call napi_schedule();
} else {
re-enable rx int; // this will de-assert interrupt pin for this time
return;
}

So my modification is: if we can call napi_schedule(), we will disable 
the rx int until the NAPI thread re-enable it. if we can't call 
napi_schedule(), the rx int will keep enabled. This logic is almost same 
as the original design. I can't figure out why original design is safe 
while my modification is risky.


Add more info:

the Freescale imx31pdk, imx51pdk and ti_omap3evm boards all use this 
driver, before apply this modification, their kgdboe connecting is not 
stable. After applied this patch, their nfs root is as good as before 
and their kgdboe connecting is stable.

Thanks,
Jason.
> You must solve your level triggered interrupt some other way, every
> NAPI based device must manage the interrupt disabling carefully and
> only when the napi POLL is successfully scheduled in order to avoid
> races.
>
> And especially you must not make a crazy hack like this for obscure
> things like kgdboe.
>
>   

