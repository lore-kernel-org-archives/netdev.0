From: John Lumby <johnlumby@hotmail.com>
Subject: Re: r8169 :  always copying the rx buffer to new skb
Date: Mon, 18 Apr 2011 17:26:22 -0400
Message-ID: <4DACAC7E.4070400@hotmail.com>
References: <4DAC7001.9060800@hotmail.com> <1303147676.2857.20.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	Francois Romieu <romieu@fr.zoreil.com>, nic_swsd@realtek.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from tomts13-srv.bellnexxia.net ([209.226.175.34]:60682 "EHLO
	tomts13-srv.bellnexxia.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751494Ab1DRV0D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2011 17:26:03 -0400
Received: from toip4.srvr.bell.ca ([209.226.175.87])
          by tomts13-srv.bellnexxia.net
          (InterMail vM.5.01.06.13 201-253-122-130-113-20050324) with ESMTP
          id <20110418212602.JNUP1798.tomts13-srv.bellnexxia.net@toip4.srvr.bell.ca>
          for <netdev@vger.kernel.org>; Mon, 18 Apr 2011 17:26:02 -0400
In-Reply-To: <1303147676.2857.20.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/18/11 13:27, Ben Hutchings wrote:
> At least some variants of the hardware have a bug [...] avoid allocation failures later on (and
> to save memory) the buffers must be copied rather than passed up the
> stack and reallocated.

Yes,  I can see that the always-copy method eliminates all possibility 
of an allocation failure,   but an *occasional* allocation failure does 
no harm  -  the driver just retains ownership of that descriptor and 
tries again on the next rx_interrupt.     With a rx ring of N buffers,  
it would take something like N-(small_number) consecutive allocation 
failures to cause a failure to be exposed up to the application.    
That's the way the code used to work and the way I've re-patched it to 
work and I've  verified that on my 8168c by simulating an allocation 
failure on 15 out of every 16 rx-Interrupts  (unhooking the current skb 
and then simply not allocating a new skb and not giving the 
corresponding descriptor to the asic) and everything works just fine,  
with just a slight drop in throughput (down to 987 Mbits/sec,  still 
well ahead of the always-copy).

So do we really need to be that concerned about occasional allocation 
failure?

And if someone is that concerned,   then,   with my proposal,  they can 
leave the rx_copybreak at its default of 16383,   when every packet is 
copied anyway.     (My patch takes a slightly different approach if the 
allocation of the new skb fails  -   current 2.6.39 drops the packet,   
I would propose to unhook and retain the descriptor because I can 
replenish later  -  but that is also debatable).     Also that's why I 
favour making the rx ring size configurable.

On 04/18/11 14:21, Francois Romieu wrote:
> Short answer: it's mostly related to CVE-2009-4537 (see git log).

I understand the need to make the rx_buf_size 16383 to defeat the DOS 
attacker,   no suggestion to alter that.     I'm just not sure I see why 
that has to imply the always_copy.
> I may resurrect some alternate fix - i.e. detect corrupted Tx descriptors
> and reset before things gets wrong - but it is not easy to prove it right
> since it may be necessary to tailor it for each member of the 816x / 810x
> family. Some input from Realtek may help though.
>
Yes,  more input the better,    and especially I recognize that I have 
tested only my RTL8168c and maybe other models behave differently.

On 04/18/11 13:27, Ben Hutchings wrote:
>> the number of rx buffers allocated at open should be configurable by
>> module param.
> [...]
>
> No, it should implement the ethtool set_ringparam operation.
>
Ah  ok    thanks.     I'll take a look at that.

John Lumby


