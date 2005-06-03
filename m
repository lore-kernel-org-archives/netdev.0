From: jamal <hadi@cyberus.ca>
Subject: Re: RFC: NAPI packet weighting patch
Date: Fri, 03 Jun 2005 15:40:50 -0400
Message-ID: <1117827650.6071.59.camel@localhost.localdomain>
References: <1117765954.6095.49.camel@localhost.localdomain>
	 <Pine.CYG.4.58.0506030929300.2788@mawilli1-desk2.amr.corp.intel.com>
	 <1117824150.6071.34.camel@localhost.localdomain>
	 <20050603.120126.41874584.davem@davemloft.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: mitch.a.williams@intel.com, john.ronciak@intel.com, jdmason@us.ibm.com,
        shemminger@osdl.org, netdev@oss.sgi.com, Robert.Olsson@data.slu.se,
        ganesh.venkatesan@intel.com, jesse.brandeburg@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050603.120126.41874584.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2005-03-06 at 12:01 -0700, David S. Miller wrote:
> From: jamal <hadi@cyberus.ca>
> Date: Fri, 03 Jun 2005 14:42:30 -0400
> 
> > When you reduce the weight, the system is spending less time in the
> > softirq processing packets before softirq yields. If this gives more
> > opportunity to your app to run, then the performance will go up.
> > Is this what you are seeing? 
> 
> Jamal, this is my current theory as well, we hit the jiffies
> check.
> 

I think you are more than likely right. If we can instrument it Mitch
could check it out. Mitch would you like to try something that will
instrument this? I know i have seen this behavior but it was when i was
playing with some system that had a real small HZ.

> It it the only logical explanation I can come up with for the
> single adapter case.
> 
> There are some ways we can mitigate this.  Here is one idea
> off the top of my head.
> 
> When the jiffies check is hit, lower the weight of the most recently
> polled device towards some minimum (perhaps divide by two).  If we
> successfully poll without hitting the jiffies check, make a small
> increment of the weight up to some limit.
> 

You probably wanna start high up first until you hit congestion
and then start lowering. 

> It is Van Jacobson TCP congestion avoidance applied to NAPI :-)
> 
> Just a simple AIMD (Additive Increase, Multiplicative Decrease).
> So, hitting the jiffies work limit is congestion, and the cause
> of the congestion is the most recently polled device.
> 
> In this regime, what the driver currently specifies as "->weight"
> is actually the maximum we'll use in the congestion control
> algorithm.  And we can choose some constant minimum, something
> like "8" ought to work well.
> 
> Comments?
> 

In theory it looks good - but i think you end up defeating the fairness
factor. If you can narrow it down to which driver is causing congestion,
and only penalize that driver i think it would work well.


cheers,
jamal
