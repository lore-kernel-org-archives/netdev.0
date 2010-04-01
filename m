From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 5/5] netfilter: xt_TEE: have cloned packet travel through
 Xtables too
Date: Thu, 01 Apr 2010 15:22:24 +0200
Message-ID: <4BB49E10.8080608@trash.net>
References: <1270031934-15940-1-git-send-email-jengelh@medozas.de> <1270031934-15940-6-git-send-email-jengelh@medozas.de> <4BB47768.1050405@trash.net> <alpine.LSU.2.01.1004011258060.17429@obet.zrqbmnf.qr> <4BB47EEA.4020809@trash.net> <alpine.LSU.2.01.1004011511180.1174@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:52314 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755358Ab0DANW0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Apr 2010 09:22:26 -0400
In-Reply-To: <alpine.LSU.2.01.1004011511180.1174@obet.zrqbmnf.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jan Engelhardt wrote:
> On Thursday 2010-04-01 13:09, Patrick McHardy wrote:
> 
>>> Conntrack loops are prevented by using a dummy conntrack, just as 
>>> NOTRACK does.
>> [...]
>>>  - When the cloned packets gets XFRMed or tunneled, its status switches 
>>>    from "special" to "plain". Doing policy routing on them does not seem 
>>>    so far-fetched.
>> My question was about the case without conntrack.
> 
> Hm. Do you have any suggestion in countering a case whereby a user
> does -I OUTPUT -j TEE without conntrack?
> 
> Perhaps making nesting a feature that requires conntrack, such that the 
> non-CT case can't loop?

If we drop the reentrancy thing, what should work is to prevent
using loopback as output device and using something similar to
the recursion counters tunnel devices used to have.

>>> I can think of a handful of applications:
>>>  - CLASSIFY
>> Good point, you should probably reset a couple of skb members
>> after the skb_copy().
> 
> I take it you mean
> 
>  nf_reset(skb)
>  skb->mark = 0;
>  skb_init_secmark(nskb);

Yes, basically. Although I believe the selinux people would be
happier if you kept the original secmark for the copied packets :)

> Or should we be using skb_alloc and copying the data portion over, like 
> ipt_REJECT does since v2.6.24-2931-g9ba99b0?

I guess pskb_copy() would be most optimal since we can modify
the header, but the non-linear area could be shared
