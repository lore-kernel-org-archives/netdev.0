From: Ben Greear <greearb@candelatech.com>
Subject: Re: RFC: NAPI packet weighting patch
Date: Fri, 03 Jun 2005 13:30:54 -0700
Message-ID: <42A0BDFE.1020607@candelatech.com>
References: <1117765954.6095.49.camel@localhost.localdomain> <Pine.CYG.4.58.0506030929300.2788@mawilli1-desk2.amr.corp.intel.com> <1117824150.6071.34.camel@localhost.localdomain> <20050603.120126.41874584.davem@davemloft.net> <Pine.CYG.4.58.0506031202280.3344@mawilli1-desk2.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, hadi@cyberus.ca,
        john.ronciak@intel.com, jdmason@us.ibm.com, shemminger@osdl.org,
        netdev@oss.sgi.com, Robert.Olsson@data.slu.se,
        ganesh.venkatesan@intel.com, jesse.brandeburg@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Mitch Williams <mitch.a.williams@intel.com>
In-Reply-To: <Pine.CYG.4.58.0506031202280.3344@mawilli1-desk2.amr.corp.intel.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Mitch Williams wrote:
> 
> On Fri, 3 Jun 2005, David S. Miller wrote:
> 
> 
>>From: jamal <hadi@cyberus.ca>
>>Date: Fri, 03 Jun 2005 14:42:30 -0400
>>
>>
>>>When you reduce the weight, the system is spending less time in the
>>>softirq processing packets before softirq yields. If this gives more
>>>opportunity to your app to run, then the performance will go up.
>>>Is this what you are seeing?
>>
>>Jamal, this is my current theory as well, we hit the jiffies
>>check.
> 
> 
> Well, I hate to mess up your guys' theories, but the real reason is
> simpler:  hardware receive resources, specifically descriptors and
> buffers.
> 
> In a typical NAPI polling loop, the driver processes receive packets until
> it either hits the quota or runs out of packets.  Then, at the end of the
> loop, it returns all of those now-free receive resources back to the
> hardware.
> 
> With a heavy receive load, the hardware will run out of receive
> descriptors in the time it takes the driver/NAPI/stack to process 64
> packets.  So it drops them on the floor.  And, as we know, dropped packets
> are A Bad Thing.

If it can fill up more than 190 RX descriptors in the time it takes NAPI
to pull 64, then there is no possible way to not drop packets!  How could
NAPI ever keep up if what you say is true?

> By reducing the driver weight, we cause the driver to give receive
> resources back to the hardware more often, which prevents dropped packets.
> 
> As Ben Greer noticed, increasing the number of descriptors can help with
> this issue.   But it really can't eliminate the problem -- once the ring
> is full, it doesn't matter how big it is, it's still full.

If you have 1024 rx descriptors, and the NAPI poll pulls off 64 at one
time, I do not see how pulling off 20 could be any more useful.  Either way,
you have more than 900 other RX descriptors to be received.

Even if you only have the default of 256 the NIC should be able to continue
receiving packets with the other 190 or so descriptors while NAPI is doing
it's receive poll.  If the buffers are often nearly used up, then the problem
is that the NAPI poll cannot pull the packets fast enough, and again, I do not
see how making it do more polls could make it able to pull packets from the
NIC more efficiently.

Maybe you could instrument the NAPI receive logic to
see if there is some horrible waste of CPU and/or time when it tries to pull
larger amounts of packets at once?  A linear increase in work cannot explain
what you are describing.

> In my testing (Dual 2.8GHz Xeon, PCI-X bus, Gigabit network, 10 clients),
> I was able to completely eliminate dropped packets in most cases by
> reducing the driver weight down to about 20.

At least tell us what type of traffic you are using?  TCP with MTU sized
packets, traffic-generator with 60 byte packets?  Actual speed that you
are running (aggregate)?  Full-duplex traffic, or mostly uni-directional?
packets-per-second you are receiving & transmitting when the drops occur?

On a dual 2.8Ghz xeon system with PCI-X bus, with a quad-port Intel pro/1000
NIC I can run about 950Mbps of traffic, bi-directional, on two ports at the
same time, and drop few or no packets.  (MTU sized packets here).

This is using a modified version of pktgen, btw.  So, if you are seeing
any amount of dropped pkts on a single NIC, especially if you are mostly
doing uni-directional traffic, then I think the problem might be elsewhere,
because the stock 2.6.11 and similar kernels can easily handle this amount
of network traffic.

Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
