From: James Chapman <jchapman@katalix.com>
Subject: Re: [PATCH][PPPOL2TP]: Fix SMP oops in pppol2tp driver
Date: Thu, 21 Feb 2008 09:53:56 +0000
Message-ID: <47BD4A34.7070606@katalix.com>
References: <20080211224924.GA2863@ami.dom.local> <47B0DD1E.5000608@katalix.com> <20080211.213048.192442721.davem@davemloft.net> <47B17BCD.2070903@katalix.com> <20080214130016.GA2583@ff.dom.local> <47BA0214.40703@katalix.com> <20080219230640.GA2755@ami.dom.local> <47BC4F2C.4000802@katalix.com> <20080220183837.GA2881@ami.dom.local> <47BCABC5.9080204@katalix.com> <20080221085959.GA12944@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Paul Mackerras <paulus@samba.org>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s36.avahost.net ([74.53.95.194]:50161 "EHLO s36.avahost.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754529AbYBUJyB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Feb 2008 04:54:01 -0500
In-Reply-To: <20080221085959.GA12944@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> On Wed, Feb 20, 2008 at 10:37:57PM +0000, James Chapman wrote:
>> Jarek Poplawski wrote:
>>
>>>>> (testing patch #1)
>>> But I hope you tested with the fixed (take 2) version of this patch...
>> Yes I did. :)
>>
>> But I just got another lockdep error (attached).
>>
>>> Since it's quite experimental (testing) this patch could be wrong
>>> as it is, but I hope it should show the proper way to solve this
>>> problem. Probably you did some of these, but here are a few of my
>>> suggestions for testing this:
>>>
>>> 1) try my patch with your full bh locking changing patch;
>>> 2) add while loops to these trylocks on failure, with e.g.  __delay(1);
>>>    this should work like full locks again, but there should be no (this
>>>    kind of) lockdep reports;
>> Hmm, isn't this just bypassing the lockdep checks?
> 
> Yes! But it's only for debugging: to find if this change in locking
> is to be blamed for these new lockups. It should effectively work just
> like without this patch, but without this lockdep warning. So, if
> after such change lockups still happen, then it would seem you didn't
> test this enough before. Otherwise the new patch is to blame and needs
> reworking.

The lockups still happen, but I think they are now due to a different 
problem, as you say.

Some background on this issue might be useful to help get feedback from 
others on the list. This issue was first reported by an ISP who found 
random lockups if an L2TP tunnel carrying hundreds/thousands of L2TP 
sessions went down due to a network outage and then recovered itself. On 
recovery, all of the tunnel's sessions (PPP) are created rapidly. 
Sometimes the tunnel would recover just fine, but other times not. The 
ISP put some effort into reproducing the problem and found that 
repeatedly creating/deleting a tunnel with lots of L2TP sessions would 
cause the failure after a random time between a few minutes and several 
hours. The original lockdep trace came from the ISP. I initially 
couldn't reproduce the problem but I borrowed two equivalent quad-core 
systems and can now reproduce it. Subsequent lockdep traces have been 
from my testing.

The _bh locking fixes in pppol2tp combined with your ppp_generic change 
solved that problem. So I then added data traffic into the mix (since 
this will happen in a real network) and found that lockups still happen. 
But the lockdep trace in this case is different, as you noted.

Does PPPoE stress the PPP setup code as much as this scenario? I guess 
in theory it could if lots of PPPoE clients connected at the same time, 
but there is no aggregate tunnel like there is with L2TP to cause all 
sessions to connect simultaneously. Perhaps PPTP also suffers from these 
issues? Perhaps not because it tends to be used only in VPN setups where 
there is only 1 session per tunnel.

>>> 3) I send here another testing patch with this second way to do this:
>>>    on the write side, but it's even more "experimental" and only a
>>>    proof of concept (should be applied on vanilla ppp_generic).
>> I'll look over it. I think I need to take a step back and look at what's  
>> happening in more detail though.
> 
> This is something completely new and changes all the picture: the xmit
> path wasn't expected (at least by me) to be called in softirq context
> at all, and there were no traces of this on previous reports. But,
> since lockdep always stops after the first warning, there could be
> even more surprises like this in the future. I'll check this report.

Doesn't the TX softirq do transmits if they've been queued up?

-- 
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

