From: Cheng Jin <chengjin@cs.caltech.edu>
Subject: Re: gigabit ethernet
Date: Fri, 13 Feb 2004 11:36:41 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0402131116590.24993-100000@fast2.cs.caltech.edu>
References: <20040213103818.55540.qmail@web21110.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Xiaoliang (David) Wei" <weixl@caltech.edu>,
        "netdev@oss.sgi.com" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: satya srikanth <satyasrikanth2001@yahoo.com>
In-Reply-To: <20040213103818.55540.qmail@web21110.mail.yahoo.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


>     I have checked the CPU utilization. Its averaging
> around 50% and reaching 100% and some instances. I
> have also looked at the intel's document. First of all
> I could not understand why all my softirqs are going
> only to cpu0 when I have multiple processors. When I

I read somewhere that Intel SMP has cpu0 taking care of 
all the hardware interrupts, but I don't know about softirqs.
I think all softirqs related to the GbE are handled by the
same cpu.

> used 2.4.18- kernel, I didnt face this problem. Now I
> am using 2.4.20-8 smp. Intel says that e1000 does not
> use NAPI by default. But, I dont know why cpu0 is
> handling all softirqs while other processors are
> sitting idle.

NAPI for e1000 is off by default, you have to explicitly enable it
in the kernel config file (CONFIG_E1000_NAPI).

>     Also I found that number of interrupts are
> reasonable but number of packets per interrupt is
> averaging around 40 in my case. As my cpu is not able
> to handle all these in 1 jiffy(time_squeeze), I am
> reaching throttle count and thus drops. When I changed
> netdev_max_backlog to 300000 and rmem_default to
> 300000000 then I am able to handle all packets
> received by interface. Is it OK to have such a high
> values?

What kind of processors do you have?  I haven't tried pumping 1 Gbps
using processors slower than 2.4G Xeons.  But it sounds like you did
get full utilization of the GbE card.  Data traffic is about 80 
pkts/ms, which translates into 40 pkts/ms for ack traffic, assuming
that you are talking about acks above.

rmem_default will only affect the TCP/socket layer.  For the back2back 
test you described, the bandwidth delay product is small so increasing
netdev_max_backlog queue to 300000 is unnecessary (although TCP reno
will overflow that eventually if you wait long enough).
  
I am not sure why you should see time squeeze with back2back tests...
you can instrument the kernel to see how large snd_cwnd gets, and I 
suspect that you have slow processors...  Also do the time squeeze
happen during loss recovery---when ca_state is 3 or 4?

>     My round trip propagation delay is <0.2 ms. But I
> could not understand how it would affect the
> performance. Please throw some light on this. 

short rtts will help performance because reno recovers much faster, and
linear increase doesnt take long to reach bandwidth delay product.

Cheng
