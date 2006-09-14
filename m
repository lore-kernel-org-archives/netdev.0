From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: netdev tx timeouts
Date: Wed, 13 Sep 2006 21:35:29 -0500
Message-ID: <4508BFF1.5070408@lwfinger.net>
References: <45076C00.2000100@lwfinger.net> <200609131430.53820.mb@bu3sch.de> <450806D1.4080809@lwfinger.net> <200609131549.23764.mb@bu3sch.de> <20060914102337.137d4591@localhost.localdomain> <4508B892.4040309@lwfinger.net> <20060914112140.192e980a@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Michael Buesch <mb@bu3sch.de>, bcm43xx-dev@lists.berlios.de,
	netdev@vger.kernel.org, Stefano Brivio <st3@riseup.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc13.worldnet.att.net ([204.127.131.117]:7393 "EHLO
	mtiwmhc13.worldnet.att.net") by vger.kernel.org with ESMTP
	id S1750802AbWINCfd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Sep 2006 22:35:33 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060914112140.192e980a@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> On Wed, 13 Sep 2006 21:04:02 -0500
> Larry Finger <Larry.Finger@lwfinger.net> wrote:
> 
>> Stephen Hemminger wrote:
>>> On Wed, 13 Sep 2006 15:49:23 +0200
>>> Michael Buesch <mb@bu3sch.de> wrote:
>>>> Simple. Reading the code of synchronize_net() and
>>>> netif_stop_queue() and thinking about why it breaks, instead
>>>> of committing bugfixes that only substitute one bug by another. ;)
>>>> I'll take a look, too.
>>> Why are you doing the synchronize_net()? it is meant for RCU.
>> We know and it no longer is in the code. We have known for a couple of days that 
>> it was the synchronize_net() step that led to the netdev timeouts, but we were 
>> afraid that a bare netif_stop_queue would not be SMP safe. The current structure has
>>
>> mutex_lock
>> netif_tx_disable(dev)   (equivalent to  netif_tx_lock_bh(dev);
>> 				        netif_stop_queue(dev);
>> 			                netif_tx_unlock_bh(dev);
>> spin_lock_irqsafe
>>
>> I see you listed as a maintainer in several network-related parts of the system, 
>> so AFAIK, you are a network guru. Do you think this will work? I have tested 
>> code with just a netif_stop_queue (without the lock_bh/unlock_bh parts) on a UP 
>> system and have gotten no errors, but I do not have access to SMP hardware.
>>
>> Thanks,
>>
> 
> I haven't done a careful review of the broadcom driver. What you
> are proposing looks fine. But most network devices just use spin_lock's
> rather than mutexs because there is little need for holding the lock
> for a long length of time.

I didn't code this section, but I know that the processing that we are about to 
do after the mutex can be quite lengthy - perhaps as long as 200 ms. Prior to 
2.6.18, it was protected with a spin_lock; however, there were complaints about 
the effect on latency, so the mutex approach was taken to allow this long 
section to be preemptible. At appropriate points in the processing, the program 
calls cond_resched() if the kernel has preemption configured. This change 
resulted in the timeouts of the subject, which we are now trying to fix.

Larry



