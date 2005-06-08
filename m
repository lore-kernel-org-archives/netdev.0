From: jamal <hadi@cyberus.ca>
Subject: Re: RFC: NAPI packet weighting patch
Date: Wed, 08 Jun 2005 09:36:15 -0400
Message-ID: <1118237775.6382.34.camel@localhost.localdomain>
References: <468F3FDA28AA87429AD807992E22D07E0450C01F@orsmsx408>
	 <20050607.132159.35660612.davem@davemloft.net>
	 <Pine.LNX.4.62.0506071852290.31708@ladlxr>
	 <20050607.204339.21591152.davem@davemloft.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jesse.brandeburg@intel.com, john.ronciak@intel.com, shemminger@osdl.org,
        mitch.a.williams@intel.com, mchan@broadcom.com, buytenh@wantstofly.org,
        jdmason@us.ibm.com, netdev@oss.sgi.com, Robert.Olsson@data.slu.se,
        ganesh.venkatesan@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050607.204339.21591152.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2005-07-06 at 20:43 -0700, David S. Miller wrote:
> From: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Date: Tue, 7 Jun 2005 19:20:37 -0700 (PDT)
[..]
> > I tried the experiment today where I replenish buffers to hardware every 
> > 16 packets or so.  This appears to mitigate all drops at the hardware 
> > level (no drops).  We're still at 100% with the rc5 kernel, however.
> > 
> > even with this replenish fix, the addition of dropping the weight to 16 
> > helped increase our throughput, although only about 1%.
> 
> Any minor timing difference of any kind can have up to a %3 or
> %4 difference in TCP performance when the receiver is CPU
> limited.
> 

Agreed.

[..]
> I don't see how supertso can help the receiver, which is where
> the RX drops should be occuring.  That's a little weird.
> 
> I can't believe a 2.5 GHZ machine can't keep up with a simple 1 Gbit
> TCP stream.  Do you have some other computation going on in that
> system?  As stated yesterday my 1.5 GHZ crappy sparc64 box can receive
> a 1 Gbit TCP stream with much cpu to spare, my 750 MHZ sparc64 box can
> nearly do so as well.
> 
> Something is up, if a single gigabit TCP stream can fully CPU
> load your machine.  10 gigabit, yeah, definitely all current
> generation machines are cpu limited over that link speed, but
> 1 gigabit should be no problem.
> 

Yes, sir.
BTW, all along i thought the sender and receiver are hooked up directly
(there was some mention of chariot a while back).
Even if they did have some smart ass thing in the middle that reorders,
it is still suprising that such a fast CPU cant handle a mere one Gig of
what seems to be MTU=1500 bytes sized packets.
I suppose a netstat -s would help for visualization in addition to those
dumps. 

Heres what i am deducing from their data, correct me if i am wrong:
->The evidence is that something is expensive in their code path (duh).

-> Whatever that expensive thing code is, it not helped by them
replenishing the descriptors after all the budget is exhausted since the
descriptor departure rate is much slower than packet arrival.
---> This is why they would be seeing that the reduction of weight
improves performance since the replenishing happens sooner with a
smaller weight.
------> Clearly the driver needs some fixing - if they could do what
their competitor's(who shall remain nameless) driver does  or replenish
more often, then that would go some way to help (Jesse's result with
replenish after 16 is proof).

This still hasnt resolved what the problem is but we may be getting
close.

Even if they SACKed for every packet, this still would not make any
sense. So i think a profile of where the cycles are spent would also
help. I am suspecting the driver at this point but i could be wrong.

cheers,
jamal
