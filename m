From: Baruch Even <baruch@ev-en.org>
Subject: Re: netif_rx packet dumping
Date: Tue, 08 Mar 2005 15:56:04 +0000
Message-ID: <422DCB14.1040805@ev-en.org>
References: <20050303123811.4d934249@dxpl.pdx.osdl.net>	 <20050303125556.6850cfe5.davem@davemloft.net>	 <1109884688.1090.282.camel@jzny.localdomain>	 <20050303132143.7eef517c@dxpl.pdx.osdl.net>	 <1109885065.1098.285.camel@jzny.localdomain>	 <20050303133237.5d64578f.davem@davemloft.net>	 <20050303135416.0d6e7708@dxpl.pdx.osdl.net>	 <Pine.LNX.4.58.0503031657300.22311@tesla.psc.edu>	 <1109888811.1092.352.camel@jzny.localdomain>	 <20050303151606.3587394f@dxpl.pdx.osdl.net>  <4227A23C.5050300@ev-en.org>	 <1109907956.1092.476.camel@jzny.localdomain>  <42282098.8010506@ev-en.org> <1110203711.1088.1393.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>, John Heffner <jheffner@psc.edu>,
        "David S. Miller" <davem@davemloft.net>, rhee@eos.ncsu.edu,
        Yee-Ting.Li@nuim.ie, netdev@oss.sgi.com
To: hadi@cyberus.ca
In-Reply-To: <1110203711.1088.1393.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jamal wrote:
> On Fri, 2005-03-04 at 03:47, Baruch Even wrote:
> 
>>jamal wrote:
> 
> 
>>>Can you explain a little more? Why does the the throttling cause any
>>>bad behavior thats any different from the queue being full? In both
>>>cases, packets arriving during that transient will be dropped.
>>
>>If you have 300 packets in the queue and the throttling kicks in you now 
>>drop ALL packets until the queue is empty, this will normally take some 
>>time, during all of this time you are dropping all the ACKs that are 
>>coming in, you lose SACK information and potentially you leave no packet 
>>in flight so that the next packet will be sent only due to retransmit 
>>timer waking up, at which point your congestion control algorithm starts
>>from cwnd=1.
>>
>>You can look at the report http://hamilton.ie/net/LinuxHighSpeed.pdf for 
>>some graphs of the effects.
> 
> Were the processors tied to NICs? 

No. These are single CPU machines (with HT).

> Your experiment is more than likely a single flow, correct?

Yes.

> In other words the whole queue was infact dedicated just for your one
> flow - thats why you can call this queue a transient burst queue. 

Indeed, For a router or a web server handling several thousand flows it 
might be different, but I don't expect it handles a single packet in one 
  ms (or more) as it happens for the current end-system ack handling code.

> Do you still have the data that shows how many packets were dropped
> during this period. Do you still have the experimental data? I am
> particulary interested in seeing the softnet stats as well as tcp
> netstats.

No, These tests were not run by me, I'll probably rerun similar tests as 
well to base my work on, send me in private how do I get the stats from 
the kernel and I'll add it to my test scripts.

> I think your main problem was the huge amounts of SACK on the writequeue
> and the resultant processing i.e section 1.1 and how you resolved that.

That is my main guess as well, the original work was done rather 
quickly, we are now reorganizing thoughts and redoing the tests in a 
more orderly fashion.

> I dont see any issue in dropping ACKs, many of them even for such large
> windows as you have - TCPs ACKs are cummulative. It is true if you drop
> "large" enough amounts of ACKS, you will end up in timeouts - but large
> enough in your case must be in the minimal 1000 packets. And to say you
> dropped a 1000 packets while processing 300 means you were taking too
> long processing the 300.

With the current code SACK processing takes a long time, so it is 
possible that it happened to drop more than a thousand packets while 
handling 300. I think that after the fixing of the SACK code, the rest 
might work without getting to much into the ingress queue. But that 
might still change when we go to even higher speeds.

> Then what would be really interesting is to see the perfomance you get
> from multiple flows with and without congestion.

We'd need to get a very high speed link for multiple high speed flows.

> I am not against a the benchmarky nature of the single flow and tuning
> for that, but we should also look at a wider scope at the effect before
> you handwave based on the result of one testcase.

I can't say I didn't handwave, but then, there is little experimentation 
done to see if the other claims are correct and that AFQ is really 
needed so early in the packet receive stage. There are also voices that 
say AFQ sucks and causes more damage than good, I don't remember details 
currently.

> So if i was you i would repeat 1.2 with the fix from 1.1 as well as
> tying the NIC to one CPU. And it would be a good idea to present more
> detailed results - not just tcp windows fluctuating (you may not need
> them for the paper, but would be useful to see for debugging purposes
> other parameters).

I'd be happy to hear what other benchmarks you would like to see, I 
currently intend to add some ack processing time analysis and oprofile 
information. With possibly showing the size of the ingress queue as a 
measure as well.

Making it as thorough as possible is one of my goals. Input is always 
welcome.

Baruch
