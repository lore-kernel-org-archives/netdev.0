From: Angelo Rizzi <angelo.rizzi@3dautomazione.it>
Subject: Re: net_tx_action race condition?
Date: Mon, 24 Nov 2014 18:19:00 +0100
Message-ID: <54736884.5040600@3dautomazione.it>
References: <547332D7.7050104@3dautomazione.it> <1416843200.17888.53.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relaygw2-5.mclink.it ([213.21.178.152]:43668 "EHLO
	relaygw2-5.mclink.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753607AbaKXRTF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2014 12:19:05 -0500
In-Reply-To: <1416843200.17888.53.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,
Thanks for your reply
You are right, it seems a bug in the NIOS2 architecture port.
I will check how local_irq_disable()/local_irq_enable() is implemented 
on this kind of architecture.

Regards,
Angelo

Il 24/11/2014 16:33, Eric Dumazet ha scritto:
> On Mon, 2014-11-24 at 14:29 +0100, Angelo Rizzi wrote:
>> Hi Daniel,
>> Here attached the patch file you required.
>> The problem i've found is on the declaration of 'struct softnet_data
>> *sd' in function 'net_tx_action'
>> What happens to me (i have an embedded system based on FPGA and a NIOS2
>> cpu) is that, due to compiler optimization, the content of
>> 'sd->completion_queue' is saved in a CPU register before interrupt
>> disabling (when the instruction 'if (sd->completion_queue) {' is
>> executed) and then the register contents is used for interrupt-disabled
>> assignment ('clist = sd->completion_queue') instead of re-read the
>> variable contents.
>> This seems to lead to a race condition when an interrupt modifies the
>> content of 'sd->completion_queue' between these two instructions.
>> What i have done to avoid this situation is to change the declaration of
>> 'struct softnet_data *sd' to 'volatile struct softnet_data *sd' and now
>> everything seems to be ok.
>> I hope this will help.
>>
>> Regards,
>> Angelo
>>
> Do not add volatile in the kernel, this is not how we solve this kind of
> problems.  Documentation/memory-barriers.txt and
>
> Documentation/00-INDEX:476:volatile-considered-harmful.txt
> Documentation/00-INDEX:477:     - Why the "volatile" type class should not be used
>
>
> I am surprised this patch is needed. Many other 'bugs' would need
> similar fixes.
>
> local_irq_disable() MUST have a memory barrier. This looks like a bug in
> one particular arch implementation.
>
>
> On x86 for example, native_irq_disable() is really :
>
> 	asm volatile("cli": : :"memory");
>
>
> diff --git a/net/core/dev.c b/net/core/dev.c
> index ac4836241a965a71952469ba054f87d8dfca2d32..fa73072e515aa07fa8ae1bc39174b7d59c7a31a5 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -3406,7 +3406,7 @@ static void net_tx_action(struct softirq_action *h)
>   		struct sk_buff *clist;
>   
>   		local_irq_disable();
> -		clist = sd->completion_queue;
> +		clist = ACCESS_ONCE(sd->completion_queue);
>   		sd->completion_queue = NULL;
>   		local_irq_enable();
>   
>
>
>
