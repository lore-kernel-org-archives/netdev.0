From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH] [1/1] Deprecate tcp_tw_{reuse,recycle}
Date: Thu, 31 Jan 2008 08:41:38 -0800
Message-ID: <47A1FA42.4070503@candelatech.com>
References: <20080130938.523292915@suse.de> <200801310359.07362.ak@suse.de> <47A16CBB.3000409@candelatech.com> <200801310755.02110.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Andi Kleen <ak@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:44762 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755805AbYAaQln (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Jan 2008 11:41:43 -0500
In-Reply-To: <200801310755.02110.ak@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andi Kleen wrote:
>> I believe the problem was that all of my ports were used up with
>> TIME_WAIT sockets and so it couldn't create more.  My test
>> case was similar to this:
>>     
>
> Ah that's simple to solve then :- use more IP addresses and bind 
> to them in RR in your user program.
>
> Arguably the Linux TCP code should be able to do this by itself
> when enough IP addresses are available, but it's not very hard
> to do in user space using bind(2)
>
> BTW it's also an very unusual case -- in most cases there are more
> remote IP addresses
>   
This could be done, but it does decrease our options for testing certain 
scenarios.
>> So, is there a better way to max out the connections per second without 
>> having to use tcp_tw_recycle?
>>     
>
> Well did you profile where the bottle necks were?
>
> Perhaps also just increase the memory allowed for TCP sockets.
>   
I may be missing something, but I believe the issue is that the sockets 
wait around a while (maybe 30 seconds
or so) in TIME_WAIT state.  So, even if we use all 64k of the local port 
range, that will limit us to about 2000 new sockets
per second, as we have to wait for old ones to transition out of TIME_WAIT.

I guess I could probably decrease TIME_WAIT, but then all of my 
connections would be affected, not just the
ones on the ports creating very large numbers of connections per 
second.  From 'man tcp', it does not seem
I can set the TIME_WAIT on a per-socket basis.

I don't know exactly how the tcp_tw_recycle works, but it seems like it 
could be made to only
take affect when all local ports are used up in TIME_WAIT.  It could 
then recycle the oldest one
as a new socket is requested.  For any normal program, it would be very 
unlikely to ever need to
recycle in this case because there would be enough free IP/port pairs 
available.  But, for weird things
like my own, at least it could be made to work w/out hacking the global 
TIME_WAIT.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com


