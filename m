From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH net-next] tg3: inconsistent interrupt value reported
Date: Fri, 31 Oct 2008 12:38:51 -0400
Message-ID: <20081031163851.GA16253@gospo.rdu.redhat.com>
References: <20081031155421.GB6181@gospo.rdu.redhat.com> <490B2DA4.30903@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mcarlson@broadcom.com, netdev@vger.kernel.org, mchan@broadcom.com,
	davem@davemloft.net
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:44153 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751530AbYJaQjA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Oct 2008 12:39:00 -0400
Content-Disposition: inline
In-Reply-To: <490B2DA4.30903@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 31, 2008 at 12:09:08PM -0400, Jeff Garzik wrote:
> Andy Gospodarek wrote:
>> Systems that use MSI do not report the correct 'Interrupt' value in
>> ifconfig output.  This patch sets dev->irq after initializing the
>> interrupt as the value will change when using MSI.
>>
>> I suspect this is a problem with a lot of drivers, so I'll snoop around
>> and post some more patches if needed.
>>
>> Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
>> ---
>>
>>  tg3.c |    5 ++++-
>>  1 file changed, 4 insertions(+), 1 deletion(-)
>>
>> diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
>> index eb9f8f3..fa95e99 100644
>> --- a/drivers/net/tg3.c
>> +++ b/drivers/net/tg3.c
>> @@ -7892,6 +7892,7 @@ static int tg3_request_irq(struct tg3 *tp)
>>  	irq_handler_t fn;
>>  	unsigned long flags;
>>  	struct net_device *dev = tp->dev;
>> +	int ret;
>>   	if (tp->tg3_flags2 & TG3_FLG2_USING_MSI) {
>>  		fn = tg3_msi;
>> @@ -7904,7 +7905,9 @@ static int tg3_request_irq(struct tg3 *tp)
>>  			fn = tg3_interrupt_tagged;
>>  		flags = IRQF_SHARED | IRQF_SAMPLE_RANDOM;
>>  	}
>> -	return (request_irq(tp->pdev->irq, fn, flags, dev->name, dev));
>> +	ret = request_irq(tp->pdev->irq, fn, flags, dev->name, dev);
>> +	dev->irq = tp->pdev->irq;
>> +	return ret;
>
> The ifconfig value is useless, and was never designed to carry and  
> display that kind of information (MSI vectors, etc.).
>
> In fact, part of the reason why the ethtool bus-id information was added  
> was to give better insight into the hardware attached to the device,  
> notably including the interrupt information.
>
> In modern drivers (read: newer than [E]ISA), dev->irq use is  
> inconsistent and largely for __best effort__ display purposes only.
>
> I'd argue that a policy of leaving dev->irq at zero might be a better  
> idea.  That ensures users do not pay attention to what is already an  
> inconsistent/truncate/device-dependent piece of information.
>

This came up because the output is currently wrong.

# ifconfig eth0 | grep Inter && grep eth0 /proc/interrupts
          Interrupt:169 Memory:f6000000-f6012100
122:       2894           0          0         PCI-MSI  eth0

Some drivers take the stand of not setting dev->irq anything (like most
of the Intel drivers), but I didn't take that route with tg3 (or with
the others I'd planned) simply because I didn't want to hear crying
about breaking user-space with a patch that would make that line
disappear.

If this seems like a reasonable change that we can force on user-space
I'll post a patch that drops the setting of dev->irq all together, so
this disappers.



