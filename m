From: John Lumby <johnlumby@hotmail.com>
Subject: Re: r8169 :  always copying the rx buffer to new skb
Date: Wed, 20 Apr 2011 23:41:44 -0400
Message-ID: <4DAFA778.9000705@hotmail.com>
References: <4DAC7001.9060800@hotmail.com> <1303147676.2857.20.camel@bwh-desktop> <4DACAC7E.4070400@hotmail.com> <20110420191316.GA18805@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ben Hutchings <bhutchings@solarflare.com>,
	nic_swsd@realtek.com
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from toip5.srvr.bell.ca ([209.226.175.88]:31998 "EHLO
	toip5.srvr.bell.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753700Ab1DUDli (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2011 23:41:38 -0400
In-Reply-To: <20110420191316.GA18805@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/20/11 15:13, Francois Romieu wrote:
> John Lumby<johnlumby@hotmail.com>  :
> [...]
>> I've  verified that [...] and everything works just
>> fine,
> Did your testing account for some memory pressure ?

No,  something I need to do.     In my tests paging rate was light.     
I will try a squeeze test to see what happens.

>> So do we really need to be that concerned about occasional
>> allocation failure?
> See $search_engine +r8169 high order memory allocation failure.

The bug reports I see are all related to the problem that occurred at 
open in the days when the init_ring() requested GFP_ATOMIC *and* 
insisted that *all* 256 buffers must be obtained or else failed the open.
I take your point,  but I think it is different in the interrupt case  
-   the rx_interrupt does not consider a single alloc failure to trigger 
any visible failure.   In the old code (and my patched),  it just tries 
again next time.   In the current code,  it can't do that since it has 
no skb to pass up,  so it drops the packet.

Have I missed some other bug reports on alloc failures?

But I also realize that (I guess) few sysadmins may have ever set the 
rx_copybreak down low in the days when the parameter was there,   so 
maybe we just don't really know how many problems would arise with 
it.     So I would propose leaving it to default to 16383 as before.

> Why don't you send the patch through the mailing list ?
>
> (hint, hint)

In my next post.   Still on 2.6.39-rc2 and too late for me to try merge 
to latest right now,  hope still useful.

>>
>> I'm just not sure I
>> see why that has to imply the always_copy.
>>
>>
>> Because of high-order memory allocation failure under memory pressure and
>> memory wastage.

I think memory allocation failure can occur regardless of code design  
-  old,  current and my patched code all do the same amount of dynamic 
alloc'ing of skbs.   It's just the initial set in the ring which is 
different.   In the current code,  alloc failure => we drop packets.    
Maybe dropping many packets might cause more trouble owing to 
re-transmits  than not replenishing the rx buffers temporarily.    
Although I guess the NIC stays up with the current code.   Not really sure.

>>
>>   Btw several 816x have limited jumbo frames abilities.

Is that point that there is some special significance for memory 
allocation?   Not sure about that  -  I mean the total data rate per sec 
is limited to 1Gbit nominal in each direction regardless of size of data 
buffers  (I think).     So naiively jumbo will not put more memory 
pressure than 1500 will it?    Or are you thinking about testing?

John Lumby
