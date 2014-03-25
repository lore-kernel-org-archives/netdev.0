From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: [Xen-devel] [PATCH net V2] xen-netback: disable rogue vif in
 kthread context
Date: Tue, 25 Mar 2014 13:40:14 +0000
Message-ID: <5331873E.8070606@citrix.com>
References: <1395750051-15932-1-git-send-email-wei.liu2@citrix.com> <53317ECA.4040406@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <xen-devel@lists.xen.org>,
	Ian Campbell <ian.campbell@citrix.com>, <edwin@etorok.net>,
	<paul.durrant@citrix.com>
To: David Vrabel <david.vrabel@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:61310 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751539AbaCYNkR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 09:40:17 -0400
In-Reply-To: <53317ECA.4040406@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 25/03/14 13:04, David Vrabel wrote:
> On 25/03/14 12:20, Wei Liu wrote:
>> When netback discovers frontend is sending malformed packet it will
>> disables the interface which serves that frontend.
>>
>> However disabling a network interface involving taking a mutex which
>> cannot be done in softirq context, so we need to defer this process to
>> kthread context.
>>
>> This patch does the following:
>> 1. introduce a flag to indicate the interface is disabled.
>> 2. check that flag in TX path, don't do any work if it's true.
>> 3. check that flag in RX path, turn off that interface if it's true.
>>
>> The reason to disable it in RX path is because RX uses kthread. After
>> this change the behavior of netback is still consistent -- it won't do
>> any TX work for a rogue frontend, and the interface will be eventually
>> turned off.
> [...]
>> --- a/drivers/net/xen-netback/interface.c
>> +++ b/drivers/net/xen-netback/interface.c
>> @@ -61,12 +61,23 @@ static int xenvif_poll(struct napi_struct *napi, int budget)
>>   {
>>   	struct xenvif *vif = container_of(napi, struct xenvif, napi);
>>   	int work_done;
>> +	unsigned long flags;
>> +
>> +	/* This vif is rogue, we pretend we've there is nothing to do
>> +	 * for this vif to deschedule it from NAPI. But this interface
>> +	 * will be turned off in thread context later.
>> +	 */
>> +	if (unlikely(vif->disabled)) {
>> +		local_irq_save(flags);
>> +		__napi_complete(napi);
>> +		local_irq_restore(flags);
>
> Why isn't this napi_complete(napi) (which uses local_irq_save/restore()
> internally)?
I guess we don't need napi_gro_flush, so you can spare a few cycles, and 
I don't know if we need to check for netpoll, I'm not sure it's a 
sensible thing to run debug console from a guest towards the backend (or 
do I misunderstand what's the purpose here?)

>
> David
>
