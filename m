From: Michal Soltys <soltys@ziu.info>
Subject: Re: HFSC link sharing behavior related query
Date: Thu, 02 Jul 2009 18:36:01 +0200
Message-ID: <4A4CE1F1.5060300@ziu.info>
References: <e54032850907020423q730dad3cm666594dfc130ffa9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Sanket Shah <sanketshah5124@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from drutsystem.com ([80.72.38.138]:3945 "EHLO drutsystem.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751268AbZGBQ7Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Jul 2009 12:59:25 -0400
In-Reply-To: <e54032850907020423q730dad3cm666594dfc130ffa9@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sanket Shah wrote:
> Hi,
> 	We are doing experiments on hfsc in various network scenarios. Some
> of the results are not as per our expectation/understanding of our
> hfsc behavior.
> 
> -----------------------------------------------------------------------------------------------------------------------
> 	Scenario 1:
> 
> 		1: (hfsc qdisc)
> 		|
> 		|
> 		1:1 (hfsc root class) (rt 0, ls 40, ul 40)
> 		|
> 	----------------------------------------------------------------
> 	|								|
> 	1:2 (rt 10, ls 1, ul 20)				1:3 (rt 30, ls 1, ul 40)
> 	|								|
> 	2: (sfq qdisc)						3: (sfq qdisc)
> 
> 	In above scenario,
> 		1:2 and 1:3 both are doing http download and we are getting following results.
> 
> 		1:2 - 10 kbps
> 		1:3 - 30 kbps		
> 			That is as per the expectation.
> 
> 	After 5 minutes we are changing ls and ul of 1:1 from 40 to 100. (rt
> 0, ls 100, ul 100)
> 		
> 		For first 2 minutes after above change,
> 
> 			1:2 - 20 kbps
> 			1:3 - 80 kbps
> 				In this case ul curve is getting violated for 2 mins.
> 
> 		After 2 minutes,
> 
> 			1:2 - 20 kbps
> 			1:3 - 50 kbps
> 				That is expected.
> 
> 	Is it an expected behavior ?
> 	why ul curve got violated ?
> 

Regarding this scenario, I have 4 stages (all expected, afaics):

1) 10 : 30 (beginning)
2) 70 : 30 (right after changing 1:1, beacuse of:
		vt far apart between 1:2 and 1:3
		ft artificially limited)
3) 20 : 80 (once 1:2's ft catches up)
4) 20 : 40 (once both ft "stabilize")

This is the effect of two things:

1) LS curve is in 1 to 1 ratio ; looking at initial bandwidth assignment 
20 : 20 - but 40 is all what both children can get from LS (due to UL). 
Actually they will get nothing, as RT curve already covers that in 10:30 
ratio. Furthermore virtual time calculated from LS of both child classes 
will drift apart (more and more with passing time), which is precise 
thing HFSC is trying to avoid

2) UL curve is artificially limited - in this particular case in initial 
period - only realtime criterion is updating virtual time, and RT curve 
is half of UL one - thus ft calculated from received service using UL 
will drift away from current time (again - more and more with passing 
time). ITOW the class will become greedy :)  Actually there is a code 
fragment commented out that is probably meant to prevent that.

The effect is, that imemdiately after bumping up UL to 100 at 1:1, LS 
criterion will be only considering class 1:2 as long as virtual time has 
long way to catch with 1:3 (due to 1). At the same time 1:2's fittime is 
lower than it should be (due to 2), so the class will not be upper 
limited for some time period. RT of 1:3 will serve it 30, all available 
LS will go to 1:2.

After fittime catches up, 1:2 will get cut down by its UL again, while 
1:3 will not be limited by it for some time. Thus - 20:80. vt won't 
really matter at this time, as the arbitration is "choose class with 
lowest vt, while ft fits". vt will start drifting apart again.

Finally, once ft of both classes catch up, the final effect will be 20:40.


(I'll have to doublecheck it later, and look at the 2nd question)

