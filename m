From: Michal Soltys <soltys@ziu.info>
Subject: Re: HFSC link sharing behavior related query
Date: Sat, 04 Jul 2009 01:03:13 +0200
Message-ID: <4A4E8E31.7060102@ziu.info>
References: <e54032850907020423q730dad3cm666594dfc130ffa9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Sanket Shah <sanketshah5124@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from drutsystem.com ([80.72.38.138]:4421 "EHLO drutsystem.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751171AbZGCXDW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Jul 2009 19:03:22 -0400
In-Reply-To: <e54032850907020423q730dad3cm666594dfc130ffa9@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sanket Shah wrote:
> Hi,
> 	We are doing experiments on hfsc in various network scenarios. Some
> of the results are not as per our expectation/understanding of our
> hfsc behavior.
> 
> [cut]
> 
> -----------------------------------------------------------------------------------------------------------------------
> 
> 	Scenario 2:
> 
> 		1: (hfsc qdisc)
> 		|
> 		|
> 		1:1 (hfsc root class) (rt 0, ls 200, ul 200)
> 		|
> -------------------------------------------------------------------------------------------------------------------------
> |					|					|					|	
> 1:2 (rt 75, ls 32, ul 200)	1:3 (rt 25, ls 16, ul 200)	1:4(rt 50, ls 8,
> ul 200)	1:5 (rt 25,ls 128,ul 200)
> |					|					|					|
> 2: (sfq qdisc)			3: (sfq qdisc)			4:(sfq qdisc)			5: (sfq qdisc)
> 
> 	In above scenario,
> 		1:2, 1:3, 1:4, 1:5 all are doing http download and we are expecting
> following results,
> 
> 		1:2 - 75 kbps
> 		1:3 - 25 kbps		
> 		1:4 - 50 kbps
> 		1:5 - 50 kbps (according to link sharing ratio, excess 25 kbps
> bandwidth should remain with 1:5)
> 
> 		But we are observing that 25 kbps excess bandwidth is floating
> across 1:2,1:3 and 1:5 on about 4 to 5 minutes. We are also observing
> few packet drops in 1:2 and 1:3. Is there any relation between link
> sharing and packet drop ?
> 

Regarding this scenario, from what I can see - realtime curves will 
cause discrepancy between virtual times of all leaf classes. Excess 
bandwidth is small and LS will be unable to compensate for these 
differences - so the virtual time will drift apart with passing time. 
But - if any of the classes becomes passive briefly, next time it 
becomes active, HFSC updates virtual time using mean of max and min 
virtual time of its sibling classes. Considering that vts are always 
different in this example, activated class will "jump" somewhere in the 
middle, and next class with lowest vt will keep getting excess bandwidth 
(indefinitely) until it becomes passive.

As for dropping packets - it is certainly possible. But it depends on 
many factors (queue size, socket size, HZ and/or hrtimers availability, 
other traffic happening, etc.).

When I test this stuff, I generally rely on netcat in udp mode 
(</dev/zero >/dev/null)

Some general comments regarding both scenarios:

HFSC tries to minimize differences between virtual times. Realtime 
criterion is an exception to that and always takes priority, but LS 
should generally have enough bandwidth to compensate for any 
differences. If you create class hierarchy that violates that - virtual 
times will drift apart and may cause undesirable effects (applies to 
both scenarios above). Classes that get too much bandwidth due to 
realtime criterion will be punished during linksharing. Original HFSC 
paper didn't allow separate definitions for LS and RT curves, thus this 
problem didn't exist there. Be sure to analyze the hierarchy carefully, 
if you want to allow class getting more from RT criterion than it would 
get from LS one.

UL curve is only an extension to LS curve. It's basically and extra 
control to when LS may schedule next packet. In general principle it 
works similary to RT curve. But while it's impossible to create RT curve 
going beyond interface capacity, it's possible to create situation where 
UL curve is above of what class can possibly receive by both RT and LS 
(situation in scenario #1). There's a guard for this that "fast 
forwards" fit time (fit time or 'ft' is what rt is for RT curve and vt 
is for LS curve) to keep it close to real current time. It's commented 
out though for some past problems. Remember than LS and UL are 
independent from RT (but RT scheduling updates both).

Regarding UL curve (apart from above scenarios) - if it's defined in any 
class, the test whenever LS criterion can or cannot dequeue, /will 
propagete/ to the root class, regardless if the intermediary nodes have 
of haven't got UL set. If you leave any leaf class w/o UL "cover" (and 
for better effect - w/o RT "cover" either) directly or indirectly 
(through one of ancestors, excluding root), it has potential to create 
another ugly effect - consider e.g (1:1 ls 100mbit ; 1:2 ls 99.9mbit ; 
1:3 ls 100kbit, ul 100kbit) 1:3 will barely get any traffic, but the 
decision will be immediately made in the root, and the qdisc will just 
set watchdog to wait for proper time on every enqueue (at which 1:2 will 
burst out all the packets it managed to enqueue). So, in a way - UL is 
also independent from LS.

If the needs are simple, UL is best suited to be defined in the root 
class only - to limit for whataver speed you need on the interface (or 
e.g. interface of some upstream router). Let the standard HFSC magic to 
the rest :) Size tables allow further tweaking to e.g. adapt to atm layer.

