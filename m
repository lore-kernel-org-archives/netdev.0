From: "David S. Miller" <davem@davemloft.net>
Subject: Re: RFC: NAPI packet weighting patch
Date: Fri, 03 Jun 2005 13:29:22 -0700 (PDT)
Message-ID: <20050603.132922.63997492.davem@davemloft.net>
References: <20050603.120126.41874584.davem@davemloft.net>
	<Pine.CYG.4.58.0506031202280.3344@mawilli1-desk2.amr.corp.intel.com>
	<20050603.132257.23013342.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, john.ronciak@intel.com, jdmason@us.ibm.com,
        shemminger@osdl.org, netdev@oss.sgi.com, Robert.Olsson@data.slu.se,
        ganesh.venkatesan@intel.com, jesse.brandeburg@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: mitch.a.williams@intel.com
In-Reply-To: <20050603.132257.23013342.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: "David S. Miller" <davem@davemloft.net>
Date: Fri, 03 Jun 2005 13:22:57 -0700 (PDT)

> This is why you should replenish RX packets _IN_ your
> RX packet receive processing, not via some tasklet
> or other seperate work processing context.
> 
> No wonder I never see this on tg3.

Actually, the problem is slightly different.

E1000 processes the full QUOTA of RX packets,
_THEN_ replenishes with new RX buffers.  No wonder
the chip runs out of RX descriptors.

You should replenish _AS_ you grab RX packets
off the receive queue, just as tg3 does.  This
allows you to accomplish two things:

1) Keep up with the chip so that it does not starve,
   regardless of dev->weight setting or system load.

2) Make intelligent decisions when RX buffer allocation
   fails.  When we look at a RX descriptor in tg3 we
   never leave the descriptor empty.

   If replacement RX buffer fails, we simply ignore the
   RX packet we're looking at and give it back to the
   chip.  Every driver should implement this policy.

   Drivers that do not do things this way run into all
   kinds of RX ring chip starvation issues like the ones
   you are seeing here.
