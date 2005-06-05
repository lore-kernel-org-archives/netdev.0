From: "David S. Miller" <davem@davemloft.net>
Subject: Re: RFC: NAPI packet weighting patch
Date: Sun, 05 Jun 2005 13:11:38 -0700 (PDT)
Message-ID: <20050605.131138.21611278.davem@davemloft.net>
References: <1117828169.4430.29.camel@rh4>
	<20050603205944.GC20623@xi.wantstofly.org>
	<1117830922.4430.44.camel@rh4>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: buytenh@wantstofly.org, mitch.a.williams@intel.com, hadi@cyberus.ca,
        john.ronciak@intel.com, jdmason@us.ibm.com, shemminger@osdl.org,
        netdev@oss.sgi.com, Robert.Olsson@data.slu.se,
        ganesh.venkatesan@intel.com, jesse.brandeburg@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: mchan@broadcom.com
In-Reply-To: <1117830922.4430.44.camel@rh4>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Fri, 03 Jun 2005 13:35:22 -0700

> I agree on the merit of issuing only one IO at the end. What I'm saying
> is that doing so will make it similar to e1000 where all the buffers are
> replenished at the end. Isn't that so or am I missing something?

You're totally right.  I guess we don't see the e1000 behavior
due to any of the following:

1) we set the RX ring sizes larger by default
2) we set it larger than what the e1000 tests were done with
3) we process the RX ring faster and thus the chip can't catch up
   and exhaust the ring

We use a default of 200 in tg3, and e1000 seems to use a default
of 256.

This actually points more to the fact that what you're actually
doing to process the packet has a huge influence on whether
the chip can catch up and exhaust the RX ring.  How much
software work does the netif_receive_skb() call entail, on
average, for the given workload?

That is why the exact test being run is important in analyzing
reports such as these.  If you're doing a TCP transfer, then
netif_receive_skb() can be _VERY_ expensive per-call.  If, on
the other hand, you're routing tiny 64-byte packets or responding
to simple ICMP echo requests, the per-call cost can be significantly
lower.
