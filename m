From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: Re: hardware time stamping with extra skb->hwtstamp
Date: Fri, 28 Nov 2008 16:38:16 +0100
Message-ID: <49301068.8090401@hartkopp.net>
References: <1227096528-24150-1-git-send-email-patrick.ohly@intel.com> <200811272053.10009.opurdila@ixiacom.com> <492F1B74.8000701@hartkopp.net> <200811281455.32744.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Octavian Purdila <opurdila@ixiacom.com>,
	Patrick Ohly <patrick.ohly@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.161]:63120 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752386AbYK1PiV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Nov 2008 10:38:21 -0500
In-Reply-To: <200811281455.32744.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Octavian Purdila wrote:
> From: Oliver Hartkopp <oliver@hartkopp.net>
> Date: Thu, 27 Nov 2008 23:13:08 +0100
>
>   
>>> How about this twist: we add a new option at the socket level, to get the
>>> whole skb->head - skb->end data into a user buffer. Then, we call an
>>> device ioctl and pass this buffer. The device will extract the hw
>>> timestamp and give it to the user.
>>>
>>> We might not need to get the whole skb->head - skb->end buffer, maybe
>>> just skb->head - skb->mac if we know that skb->mac is sane at the socket 
>>> level and we use the convention that the device driver must put the 
>>> timestamp below the mac header.
>>>
>>> One potential problem I see with this approach is leaking sensitive
>>> information into userspace, which means we will have to restrict this to
>>> privileged processes only.
>>>       
>> Ugh.
>>
>> Not every protocol that uses skbuffs, has a mac header (e.g. the CAN
>> protocol doesn't have mac addresses). 
>>     
>
> OK, then what about this: we use a device ioctl to get the number of bytes to 
> copy from skb->head. We then pass this to the socket level option.
>
> This is more complicated than option 3 or 4, but it should address the 
> concerns raised here - no performance impact when not using this feature. The 
> trade-off is moving work from core kernel into userspace and device driver. 
>
>   
>> This twist does not look very maintainable to me ...
>>     
>
> Could you elaborate on the maintainability issues, they are not clear to me.
>   

Do you know what all the people are doing with skbuffs in the kernel? 
I'm not aware of it.
So whenever we touch a vital data structure like the skbuff we must be 
sure that our handling is a wise approach for all.

Btw. your answer brought me to a completely different approach:

What about just creating a new pointer in the struct skbuff that points 
to a struct hwstamp when it is available OR the pointer is NULL when no 
hwstamps are available.

This struct hwstamp may consist of 'everthing we really need for 
timestamping' and is added somewhere at the head or the tail of the 
skbuff data section by the device driver.
And if the socket sees this pointer to be not NULL it knows where to 
look for our fancy struct hwstamp ...

I don't know, where this hwstamp data could be pasted into the data 
section in the best way - but surely others know. Especially this 
approach meets the requirement that the additional hwstamp data is only 
allocated (per interface!), when it's really needed - and not for 
everyone by default.

What do you thing about this idea?

Regards,
Oliver
