From: John Lumby <johnlumby@hotmail.com>
Subject: Re: r8169 :  always copying the rx buffer to new skb
Date: Tue, 26 Apr 2011 22:18:43 -0400
Message-ID: <4DB77D03.9070507@hotmail.com>
References: <4DAC7001.9060800@hotmail.com> <1303147676.2857.20.camel@bwh-desktop> <4DACAC7E.4070400@hotmail.com> <20110420191316.GA18805@electric-eye.fr.zoreil.com> <4DAFA9F9.5080909@hotmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ben Hutchings <bhutchings@solarflare.com>,
	nic_swsd@realtek.com
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from toip4.srvr.bell.ca ([209.226.175.87]:19188 "EHLO
	toip4.srvr.bell.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756556Ab1D0CSz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2011 22:18:55 -0400
In-Reply-To: <4DAFA9F9.5080909@hotmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Anyone have any further thoughts on the proposal to avoid memcpy'ing?  
(see earlier post)

I also have a question concerning NAPI.     I've found that much of the 
CPU saved from not memcpy'ing is burned in extra rx_interrupt'ing,  and 
much of that seems to be wasted (no new packets).    So the actual 
benefit is rather less than I think should be possible.

I've tried some tinkering with the napi weight but can't find any 
setting which really improves the ratio of rx packets to hard interrupts 
significantly.    The problem seems to be that each successive 
rtl8169_poll() is driven too soon after the last one   (in this 
particular workload).     The napi weight doesn't directly influence that.

So  -  question :
is there any way,   when returning from rtl8169_poll,  to tell napi 
something like :
    "   finish this interrupt context and let something else run on this 
CPU  (always CPU0 on my machine) BUT reschedule another napi poll on 
this same device at some time after that "
the point being that rtl8169_poll will,  for this case,  NOT re-enable 
the NIC's napi interrupts,  in the hope that maybe some user work can be 
dispatched,    so something else will have to schedule the next napi 
poll for it.    Conceptually,    if rtl8169_poll finds no rx work done 
on this call,   it wants to cause a yield() and then try again.     
Except it can't from within the interrupt.

I appreciate this could lead to delays in handling new work so might be 
dangerous,    but it seems to me to be in line with NAPI objectives so I 
wanted to try it .   But don't know how.     Any hints or thoughts 
appreciated.


John

