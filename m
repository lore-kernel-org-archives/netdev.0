From: Simon Horman <horms@verge.net.au>
Subject: Re: Possible regression in HTB
Date: Wed, 8 Oct 2008 11:21:55 +1100
Message-ID: <20081008002153.GL12021@verge.net.au>
References: <48EB5A92.6010704@trash.net> <20081007220022.GA2664@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Martin Devera <devik@cdi.cz>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:36100 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751495AbYJHAV6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2008 20:21:58 -0400
Content-Disposition: inline
In-Reply-To: <20081007220022.GA2664@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 08, 2008 at 12:00:22AM +0200, Jarek Poplawski wrote:
> Patrick McHardy wrote, On 10/07/2008 02:48 PM:
> 
> > Jarek Poplawski wrote:
> >>>> Prior to this patch the result looks like this:
> >>>>
> >>>> 10194: 545134589bits/s 545Mbits/s
> >>>> 10197: 205358520bits/s 205Mbits/s
> >>>> 10196: 205311416bits/s 205Mbits/s
> >>>> -----------------------------------
> >>>> total: 955804525bits/s 955Mbits/s
> >>>>
> >>>> And after the patch the result looks like this:
> >>>> 10194: 384248522bits/s 384Mbits/s
> >>>> 10197: 284706778bits/s 284Mbits/s
> >>>> 10196: 288119464bits/s 288Mbits/s
> >>>> -----------------------------------
> >>>> total: 957074765bits/s 957Mbits/s
> > 
> > I've misinterpreted the numbers, please disregard my previous mail.
> > 
> > I'm wondering though, even before this patch, the sharing doesn't
> > seem to be proportional to the allocated rates. Assuming the upper
> > limit is somewhere around 950mbit, we have 250 mbit for sharing
> > above the allocated rates, so it should be:
> > 
> > 500mbit class: 500mbit + 250mbit/7*5 == 678.57mbit
> > 100mbit class: 100mbit + 250mbit/1*5 == 150mbit
> > 100mbit class: 100mbit + 250mbit/1*5 == 150mbit
> > 
> > But maybe my understanding of how excess bandwidth is distributed
> > with HTB is wrong.
> 
> Good point, but the numbers a bit wrong:
> 
> 500mbit class: 500mbit + 250mbit/7*5 == 678.57mbit
> 100mbit class: 100mbit + 250mbit/7*1 == 135.71mbit
> 100mbit class: 100mbit + 250mbit/7*1 == 135.71mbit
> 					==========
> 					950.00mbit
> 
> > 
> > I still can't really make anything of this bug, but the only two
> > visible differences to HTB resulting from requeing on an upper level
> > should be that
> > 
> > 1) it doesn't reactivate classes that went passive by the last dequeue
> > 2) the time checkpoint from the last dequeue event is different
> > 
> > I guess its in fact the second thing, if a lower priority packet
> > is requeued and dequeued again, HTB doesn't notice and might allow
> > the class to send earlier again than it would have previously.
> 
> With high requeuing the timing has to be wrong, but I'm not sure why
> just lower priority has to gain here.
> 
> Anyway, IMHO this regression is really doubtful: since the digits are
> wrong in both cases I can only agree the old method gives better wrong
> results...

I first started looking into this problem because I noticed that
borrowing wasn't working in the correct proportions. That is
the problem that Patrick pointed out and you re-did the maths for above.

I noticed this on 2.6.26-rc7. So I did some testing on older kernels and
noticed that although 2.6.26-rc7 was imperfect, it did seem that progress
was being made in the right direction.  Though unfortunately there is noise
in the results, so the trend may not be real. It was also unfortunate that
I was not able to get any older kernels to boot on the hw that I was using
for testing (an HP dl360-g5 - any kernel-config tips welcome).

2.6.27-rc7
----------
10194: 568641840bits/s 568Mbits/s
10197: 193942866bits/s 193Mbits/s
10196: 194073184bits/s 194Mbits/s
-----------------------------------
total: 956657890bits/s 956Mbits/s

2.6.26
------
10194: 507581709bits/s 507Mbits/s
10197: 224391677bits/s 224Mbits/s
10196: 224863501bits/s 224Mbits/s
-----------------------------------
total: 956836888bits/s 956Mbits/s

2.6.25
------
10194: 426211904bits/s 426Mbits/s
10197: 265862037bits/s 265Mbits/s
10196: 264875210bits/s 264Mbits/s
-----------------------------------
total: 956949152bits/s 956Mbits/s


Then I tested net-next-2.6 and noticed that things were not good, as I
reported in my opening post for this thread. Curiously, the trivial revert
patch that I posted, when applied on top of yesterdays's net-next-2.6
("tcp: Respect SO_RCVLOWAT in tcp_poll()"), gives the closest to ideal
result that I have seen in any test.

10194: 666780666bits/s 666Mbits/s
10197: 141154197bits/s 141Mbits/s
10196: 141023090bits/s 141Mbits/s
-----------------------------------
total: 948957954bits/s 948Mbits/s


That does indeed seem promising. Though I do realise that my methods
have essentially been stabs in the dark and the problem needs to
be understood.

-- 
Simon Horman
  VA Linux Systems Japan K.K., Sydney, Australia Satellite Office
  H: www.vergenet.net/~horms/             W: www.valinux.co.jp/en

