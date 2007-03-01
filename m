From: Mark Huth <mhuth@mvista.com>
Subject: Re: [PATCH] e1000 stop raw interrupts disabled nag from RT
Date: Wed, 28 Feb 2007 21:59:59 -0700
Message-ID: <45E65DCF.8050903@mvista.com>
References: <45E64080.4070004@mvista.com> <45E645F4.2090403@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway-1237.mvista.com ([63.81.120.158]:33905 "EHLO
	gateway-1237.mvista.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752197AbXCAFAB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Mar 2007 00:00:01 -0500
In-Reply-To: <45E645F4.2090403@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kok, Auke wrote:
> Mark Huth wrote:
>> Current e1000_xmit_frame spews raw interrupt disabled nag messages when
>> used with RT kernel patches.  This patch uses spin_trylock_irqsave,
>> which allows RT patches to properly manage the irq semantics.
>
> Looks OK with me on first sight, I'll keep it on my stack and push it 
> upstream after Jesse looks it over.
>
> Which -RT paches make this pop up btw? I'd like to repro it.
>
> Thanks,
>
> Auke
Auke,

Well, I'm not an expert on the realtime patches - but most any patch set 
from Ingo seems to set this off - we've run through a bunch all the way 
since 2.6.10. It's a standard warning to get drivers to not mess with 
the processor interrupt function, since RT threads both the hard and 
soft irqs, and except for rare instances, the drivers and critical 
region protection no longer require the processor interrupt to be off.  
The XX_irqsave functions get turned into pre-empt disable, which is 
adequate for most things.  But the local_irq_save is recognized and 
warned, and then if it is really necessary it can be converted to an RT 
varient that won't warn.
>
>
>
>
>> Signed-off-by: Mark Huth <mhuth@mvista.com>
>> ---
>> diff --git a/drivers/net/e1000/e1000_main.c 
>> b/drivers/net/e1000/e1000_main.c
>> index 619c892..48f94ee 100644
>> --- a/drivers/net/e1000/e1000_main.c
>> +++ b/drivers/net/e1000/e1000_main.c
>> @@ -3363,12 +3363,9 @@ e1000_xmit_frame(struct sk_buff *skb, struct 
>> net_device *netdev)
>>          (adapter->hw.mac_type == e1000_82573))
>>          e1000_transfer_dhcp_info(adapter, skb);
>>  
>> -    local_irq_save(flags);
>> -    if (!spin_trylock(&tx_ring->tx_lock)) {
>> +    if (!spin_trylock_irqsave(&tx_ring->tx_lock, flags))
>>          /* Collision - tell upper layer to requeue */
>> -        local_irq_restore(flags);
>>          return NETDEV_TX_LOCKED;
>> -    }
>>  
>>      /* need: count + 2 desc gap to keep tail from touching
>>       * head, otherwise try next time */
>

