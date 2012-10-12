From: Rick Jones <rick.jones2@hp.com>
Subject: Re: performance regression with skb_add_data_nocache
Date: Fri, 12 Oct 2012 10:38:46 -0700
Message-ID: <507855A6.9080300@hp.com>
References: <OF2F004787.31D0FC5A-ONC1257A95.004517AF-C1257A95.004F9973@ch.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Bernard Metzler <BMT@zurich.ibm.com>
To: Animesh K Trivedi1 <ZRLATR@ch.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0187.atlanta.hp.com ([15.193.32.64]:5963 "EHLO
	g6t0187.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932587Ab2JLRis (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Oct 2012 13:38:48 -0400
In-Reply-To: <OF2F004787.31D0FC5A-ONC1257A95.004517AF-C1257A95.004F9973@ch.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/12/2012 07:29 AM, Animesh K Trivedi1 wrote:
>
> Hi all,
>
> I recently upgraded from 2.6.36 to 3.2.28 and saw performance
> regression for TCP performance. Upon further investigation it looked
> that skb_add_data_nocache() was the culprit.
>
> I am getting following performance numbers on my Nehalem (Xeon E7520)
> box connected using 10GbE cards (transmit side, and netperf client).
> Server is a another box with E5540 CPU (receiver of the request) .
> For my netperf TCP_RR tests:
>
> -  1,400 bytes request, 1 byte response:
> No cache copy (enabled)  : 26,623 tps, 22.72% utilization
> No cache copy (disabled) : 26,710 tps, 21.76% utilization
>
> - 14,000 bytes request, 1 byte response:
> No cache copy (enabled)  : 14,245 tps, 23.04% utilization
> No cache copy (disabled) : 14,850 tps, 21.6% utilization
>
> and for even larger buffer the performance lag is increases with
> significant CPU load
>
> - 1 MBytes request, 1 byte response:
> No cache copy (enabled)  : 1,032 tps, 98.96% utilization
> No cache copy (disabled) : 1,081 tps, 74.86% utilization
>
> Though there isn't a lot performance difference, but notice the
> significant CPU utilization in case of nocache copy for 1MB buffer
> size. Thoughts?

Over the years I have found there can be some run-to-run variability 
with the TCP_RR test - certainly the single byte one.

To have the i's dotted and t's crossed, I would suggest you shoot the 
irqbalanced in the head and make sure that all the IRQs of the 10GbE 
card (which?) are bound to the same CPU, so as you go from netperf run 
to netperf run you do not go from interrupt CPU to interrupt CPU. (1) 
You should also make certain that netperf and netserver are bound to the 
same CPU each time - initially I would suggest the same CPU as is taking 
the interrupts from the NIC. You can do that either with taskset or with 
the netperf global -T option.  Whether you then move-on to "same chip, 
same core, different thread" and/or "same chip, different core" and/or 
"different chip" (and/or "different chip, other side of "glue" if this 
is a > 4 socket box with glue) is up to you.

I would also suggest enabling the confidence interval feature of netperf 
with a global -i 30,3 option.  You can make the interval narrower or 
wider with the global -I option.  The idea would be to make sure the 
interval is narrower than the difference you are seeing.

Netperf will normalize the throughput and CPU utilization to a service 
demand.  Reporting that can help make the overhead differences more 
clear.   It might be interesting to incldue TCP_STREAM results with the 
test-specific -m option set to 1400 14000 and 1048576 as well.

That there would be greater overhead with a no cache copy seems 
unsurprising to me, particularly if it has a side effect of minimizing 
or eliminating pre-fetching.

happy benchmarking,

rick jones

(1) that is what I like to do anyway because it is easier (IMO) than 
making netperf use the same four-tuple for the data connection each 
time, so it gets hashed/whatnot by the NIC the same way each time.  I 
just send all the queues to the same CPU and am done with it - for 
single-instance testing a la 
http://www.netperf.org/svn/netperf2/trunk/doc/examples/runemomni.sh . 
If I am running aggregate netperf tests I'll either let irqbalanced do 
its thing, or leave it off and spread the IRQs around by hand.
