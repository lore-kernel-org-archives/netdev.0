From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [WIP][PATCHES] Network xmit batching
Date: Fri, 08 Jun 2007 10:27:46 -0700
Message-ID: <46699192.6010404@hp.com>
References: <OF4ACB16BB.A5DB2CC2-ON652572F3.002CD2F1-652572F3.002FDC45@in.ibm.com> <1181218576.4064.40.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Krishna Kumar2 <krkumar2@in.ibm.com>,
	Gagan Arneja <gaagaan@gmail.com>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>, netdev@vger.kernel.org,
	Sridhar Samudrala <sri@us.ibm.com>,
	David Miller <davem@davemloft.net>,
	Robert Olsson <Robert.Olsson@data.slu.se>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel13.hp.com ([156.153.255.238]:49787 "EHLO palrel13.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S968334AbXFHR1u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Jun 2007 13:27:50 -0400
In-Reply-To: <1181218576.4064.40.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>These results are based on the test script that I sent earlier today. I
>>removed the results for UDP 32 procs 512 and 4096 buffer cases since
>>the BW was coming >line speed (infact it was showing 1500Mb/s and
>>4900Mb/s respectively for both the ORG and these bits). 
> 
> 
> I expect UDP to overwhelm the receiver. So the receiver needs a lot more
> tuning (like increased rcv socket buffer sizes to keep up, IMO).
> 
> But yes, the above is an odd result - Rick any insight into this?

Indeed, there is no flow control provided by netperf for the UDP_STREAM 
test and so it is quite common for a receiver to be overwhelmed.  One 
can tweak the SO_RCVBUF size a bit to try to help with transients, but 
if the sender is sustainably faster than the receiver, you have to 
configure netperf with --enable-intervals  and then provide a send burst 
(number of sends) size and an inter burst interval (constrained by "HZ" 
on the platform) to pace the netperf UDP sender.  You can get finer 
grained control with --enable-spin, but that shoots your netperf-sided 
CPU util to hell.

And with UDP datagram sizes > MTU there is (in the abstract, not sure 
about current Linux code) the concern about filling a transmit queue 
with some but not all of the fragments of a datagram and the others 
being tossed, so one ends-up sending unreassemblable datagram fragments.


>>Summary : Average BW (whatever meaning that has) improved 0.65%, while
>>                 Service Demand deteriorated 11.86%
> 
> 
> Sorry, been many moons since i last played with netperf; what does "service
> demand" mean?

Service demand is a measure of efficiency.  It is a 
normalization/reconciliation of the "throughput" and the CPU utilization 
to arrive at a CPU consumed per unit of work figure.  Lower is better.

Now, when running aggregate tests with netperf2 using the "launch a 
bunch in the background with confidence intervals enble to get 
iterations to minimize skew error" :)

<http://www.netperf.org/svn/netperf2/tags/netperf-2.4.3/doc/netperf.html#Using-Netperf-to-Measure-Aggregate-Performance>

you cannot take the netperf service demand directly - each netperf is 
calculating assuming that it is the only thing running on the system. 
It then ass-u-me-s that the CPU util it measured was all for its work. 
This means the service demand figure will be quite higher than it really is.

So, for aggregate tests using netperf2, one has to calculate service 
demand by hand.  Sum the throughput as KB/s, convert the CPU util and 
number of CPUs to a microseconds of CPU consumed per second and divide 
to get microseconds per KB for the aggregate.

rick jones
