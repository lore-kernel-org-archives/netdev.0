From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2/2] NET: Accurate packet scheduling	for	ATM/ADSL	(userspace)
Date: Fri, 23 Jun 2006 17:05:36 +0200
Message-ID: <449C0340.7040302@trash.net>
References: <1150278040.26181.37.camel@localhost.localdomain>	 <1150282625.3490.23.camel@localhost.localdomain>	 <1150332449.8605.40.camel@ras.pc.brisbane.lube>	 <1150376591.5116.36.camel@jzny2>	 <Pine.LNX.4.61.0606192048270.31662@ask.diku.dk>	 <1150812370.5270.27.camel@jzny2>  <44980A07.4050106@trash.net>	 <1150817922.5270.125.camel@jzny2>  <44982781.8030301@trash.net> <1151002931.5392.69.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <hawk@diku.dk>, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@osdl.org>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Russell Stuart <russell-tcatm@stuart.id.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:51366 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1751422AbWFWPFi
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Jun 2006 11:05:38 -0400
To: hadi@cyberus.ca
In-Reply-To: <1151002931.5392.69.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
> On Tue, 2006-20-06 at 18:51 +0200, Patrick McHardy wrote:
> 
>> [..]
>>
>>contrary to a local link that would be best managed
>>in work-conserving mode. And I think for better accuracy it is
>>necessary to manage effective throughput, especially if you're
>>interested in guaranteed delays.
>>
> 
> 
> Indeed - but "fixing" the scheduler to achieve such management is not
> the first choice (would be fine if it is generic and non-intrusive)

I have a patch that introduces "sizetables" similar to ratetables
and performs the mapping once and stores the calculated size in the
cb. The schedulers take the size from the cb. Its not very large and
only has minimum overhead. I got distracted during testing by
inaccuracies in the 100mbit range with small packets caused by the
clock source resolution, so I've added a ktime() clocksource and am
currently busy auditing for integer overflows caused by the increased
clock rate. I'll clean up the patch once I'm done with that and post it.

>> [..]
>>
>>I think that point can be used to argue in favour of that Linux should
>>be able to manage effective throughput :)
>>
> 
> I think you have convinced me this is valuable I even suggest probes
> above to discover goodput;-). I hope i have convinced you how rude it
> would be to make extensive changes to compensate for goodput;->

Sure :) So far I haven't been able to measure any improvement by
accounting for link layer overhead, but probably because my test
scenario was chosen badly (very small overhead, large speed) and the
differences were lost in the noise.

>>>I am saying that #2 is the choice to go with hence my assertion earlier,
>>>it should be fine to tell the scheduler all it has is 1Mbps and nobody
>>>gets hurt. #1 if i could do it with minimal intrusion and still get to
>>>use it when i have 802.11g. 
>>>
>>>Not sure i made sense.
>>
>>HFSC is actually capable of handling this quite well. If you use it
>>in work-conserving mode (and the card doesn't do (much) internal
>>queueing) it will get clocked by successful transmissions. Using
>>link-sharing classes you can define proportions for use of available
>>bandwidth, possibly with upper limits. No hacks required :)
>>
> 
> 
> HFSC sounds very interesting - I should go and study it a little more.
> My understanding is though that it is a bit of a CPU pig, true?

It does more calculations at runtime than token-bucket based schedulers,
but it does perform comparable to HTB with a large number of classes,
in which case the constant overhead is probably not visible anymore
because much more time is spent searching, walking lists and trees and
so on. I didn't do any comparisons of constant costs.

>>Anyway, this again goes more in the direction of handling link speed
>>changes.
>>
> 
> 
> The more we discuss this, the more i think they are the same thing ;->

Not really. Link speed changes can be expressed by constant factors
that apply to bandwidth and delay (bandwidth *= f, delay /= f). Link
layer overhead usually can't be expressed this way.

>>>ip dev add compensate_header 100 bytes
>>
>>[...]
>>
>>Unforunately I can't think of a way to handle the ATM case without
>>a division .. or iteration.
>
> 
> I am not thinking straight right now but it does not sound like a big
> change to me i.e within reason.

I also got rid of the division ..

> Note, it may be valuable to think of
> this as related to the speed changing daemon as i stated earlier.
> Only in this case it is "static" discovery of link layer
> goodput/throughput vs some other way to dynamically discover things. 

I still think these are two quite different things. Link speed
changes also can't be handled very well by scaling packet sizes
since TBF-based qdiscs have configured maxima for the packet sizes
they can handle.

