From: "David S. Miller" <davem@davemloft.net>
Subject: Re: RFC: NAPI packet weighting patch
Date: Fri, 03 Jun 2005 12:01:26 -0700 (PDT)
Message-ID: <20050603.120126.41874584.davem@davemloft.net>
References: <1117765954.6095.49.camel@localhost.localdomain>
	<Pine.CYG.4.58.0506030929300.2788@mawilli1-desk2.amr.corp.intel.com>
	<1117824150.6071.34.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mitch.a.williams@intel.com, john.ronciak@intel.com, jdmason@us.ibm.com,
        shemminger@osdl.org, netdev@oss.sgi.com, Robert.Olsson@data.slu.se,
        ganesh.venkatesan@intel.com, jesse.brandeburg@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1117824150.6071.34.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: jamal <hadi@cyberus.ca>
Date: Fri, 03 Jun 2005 14:42:30 -0400

> When you reduce the weight, the system is spending less time in the
> softirq processing packets before softirq yields. If this gives more
> opportunity to your app to run, then the performance will go up.
> Is this what you are seeing? 

Jamal, this is my current theory as well, we hit the jiffies
check.

It it the only logical explanation I can come up with for the
single adapter case.

There are some ways we can mitigate this.  Here is one idea
off the top of my head.

When the jiffies check is hit, lower the weight of the most recently
polled device towards some minimum (perhaps divide by two).  If we
successfully poll without hitting the jiffies check, make a small
increment of the weight up to some limit.

It is Van Jacobson TCP congestion avoidance applied to NAPI :-)

Just a simple AIMD (Additive Increase, Multiplicative Decrease).
So, hitting the jiffies work limit is congestion, and the cause
of the congestion is the most recently polled device.

In this regime, what the driver currently specifies as "->weight"
is actually the maximum we'll use in the congestion control
algorithm.  And we can choose some constant minimum, something
like "8" ought to work well.

Comments?
