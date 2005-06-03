From: "David S. Miller" <davem@davemloft.net>
Subject: Re: RFC: NAPI packet weighting patch
Date: Fri, 03 Jun 2005 11:38:17 -0700 (PDT)
Message-ID: <20050603.113817.74562842.davem@davemloft.net>
References: <20050602.171812.48807872.davem@davemloft.net>
	<1117765954.6095.49.camel@localhost.localdomain>
	<Pine.CYG.4.58.0506030929300.2788@mawilli1-desk2.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, john.ronciak@intel.com, jdmason@us.ibm.com,
        shemminger@osdl.org, netdev@oss.sgi.com, Robert.Olsson@data.slu.se,
        ganesh.venkatesan@intel.com, jesse.brandeburg@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: mitch.a.williams@intel.com
In-Reply-To: <Pine.CYG.4.58.0506030929300.2788@mawilli1-desk2.amr.corp.intel.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Mitch Williams <mitch.a.williams@intel.com>
Date: Fri, 3 Jun 2005 10:43:32 -0700

> In my mind, there are two major problems with NAPI as it stands today.
> First, at Gigabit and higher speeds, the default settings don't allow the
> driver to process received packets in a timely manner.  This causes
> dropped packets due to lack of receive resources.  Lowering the weight can
> fix this, at least in a single-adapter environment.

I really don't see how changing the weight can change things
in the single adapter case.

When we hit the quota, we just loop and process more packets.
It doesn't fundamentally change anything about how the NAPI
code operates.

Please investigate what exactly is happening.  I have a few
theories.  First, is it the case that with a lower weight we
drop out of the loop because 'jiffies' advanced one tick?
Some simply instrumentation in net/core/dev.c:net_rx_action()
would show what's going on.  Actually, we keep this statistic
via netdev_rx_stat, so just cat /proc/net/softnet_stat to
get a look at if "time_squeeze" is being incremented when
dev->weight is 64 in your tests.

Next, I don't think "budget" in that function is going down to zero,
that's set to 300 by default.

If the quota is consumed, the device is just added right back
to the tail of the poll_list, and if it's the only device
active we jump right back into it's ->poll() routine over
and over until there is no more pending work in the device
or we hit the "jiffies - start_time > 1" test.
