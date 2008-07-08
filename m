From: Rick Jones <rick.jones2@hp.com>
Subject: Re: setsockopt()
Date: Tue, 08 Jul 2008 11:16:42 -0700
Message-ID: <4873AF0A.3020705@hp.com>
References: <48725DFE.6000504@citi.umich.edu> <20080707142408.43aa2a2e@extreme>	<48728B09.1050801@citi.umich.edu> <48729DAD.8010400@hp.com> <1e41a3230807072033n2f5519e4m42003e191b44cefe@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: John Heffner <johnwheffner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0028.austin.hp.com ([15.216.28.35]:37364 "EHLO
	g1t0028.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751209AbYGHSQp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2008 14:16:45 -0400
In-Reply-To: <1e41a3230807072033n2f5519e4m42003e191b44cefe@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

John Heffner wrote:
> On Mon, Jul 7, 2008 at 3:50 PM, Rick Jones <rick.jones2@hp.com> wrote:
> 
>>I'm still a triffle puzzled/concerned/confused by the extent to which
>>autotuning will allow the receive window to grow, again based on some
>>netperf experience thusfar, and patient explanations provided here and
>>elsewhere, it seems as though autotuning will let things get to 2x what it
>>thinks the sender's cwnd happens to be.  So far under netperf testing that
>>seems to be the case, and 99 times out of ten my netperf tests will have the
>>window grow to the max.
> 
> 
> 
> Rick,
> 
> I thought this was covered pretty thoroughly back in April. 

I'll plead bit errors in the dimm wetware memory :( And go back through 
the archives.

> The behavior you're seeing is 100% expected, and not likely to change
>  unless Jerry Chu gets his local queued data measurement patch 
> working. I'm not sure what ultimately happened there, but it was a 
> cool idea and I hope he has time to polish it up. It's definitely 
> tricky to get right.
> 
> Jerry's optimization is a sender-side change.  The fact that the
> receiver announces enough window is almost certainly the right thing
> for it to do, and (I hope) this will not change.

It just seems to be so, well, trusting of the sender.

> 
> If you're still curious:
> http://www.psc.edu/networking/ftp/papers/autotune_sigcomm98.ps
> http://www.lanl.gov/radiant/pubs/drs/lacsi2001.pdf

That one didn't show the effect on LANs, only WANs, although it did say 
things like this when discussing timer granularity and estimating the 
sender's window:

page 4 - "Thus in no case will the actual window be larger than the 
measured amount of data recieved during the period. However, the amount 
of data received during the period may be three times the actual window 
size when measurements are made across wide-area networks with rtt > 20 
ms.  Further, local networks with small round-trip delays may be grossly 
over-estimated."

I imagine that the 20 ms bit depends on the release and its timer 
granularity.  It was really that last sentence that caught my eye.


Still, rerunning with multiple concurrent tests showed they weren't all 
going to the limit:

moe:~# for i in 1 2 3 4; do netperf -t omni -l 30 -H manny -P 0 -- -o 
foo & done
moe:~# 289.31,-1,16384,2635688,-1,87380,2389248
210.43,-1,16384,2415720,-1,87380,2084736
194.87,-1,16384,1783312,-1,87380,1760704
247.00,-1,16384,2647472,-1,87380,2646912

moe:~# for i in 1 2 3 4; do netperf -t omni -l 120 -H manny -P 0 -- -o 
foo & done
moe:~# 240.19,-1,16384,2761384,-1,87380,2635200
197.78,-1,16384,2337160,-1,87380,2225280
220.47,-1,16384,2867440,-1,87380,2834304
283.08,-1,16384,3244528,-1,87380,3091968



I'm not sure the extent to which skew error might be at issue in those 
measurements.
rick jones
