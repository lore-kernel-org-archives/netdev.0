From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xen-netfront: Fix handling packets on compound pages
 with skb_segment
Date: Tue, 05 Aug 2014 16:15:21 -0700 (PDT)
Message-ID: <20140805.161521.1117004847394195837.davem@davemloft.net>
References: <1406726730-17994-1-git-send-email-zoltan.kiss@citrix.com>
	<20140731.132520.1889577477638334755.davem@davemloft.net>
	<53DFC2FE.8070105@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: konrad.wilk@oracle.com, boris.ostrovsky@oracle.com,
	david.vrabel@citrix.com, wei.liu2@citrix.com,
	Ian.Campbell@citrix.com, paul.durrant@citrix.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	xen-devel@lists.xenproject.org
To: zoltan.kiss@citrix.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <53DFC2FE.8070105@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Zoltan Kiss <zoltan.kiss@citrix.com>
Date: Mon, 4 Aug 2014 18:29:34 +0100

> On 31/07/14 21:25, David Miller wrote:
>> Secondly, for something like UDP you can't just split the packet up
>> like this, or for any other datagram protocol for that matter.
> The netback/netfront interface currently only supports TSO and
> TSO6. That's why I did the pktgen TCP patch

Do a sendfile() with MSG_MORE over UDP, I bet you can construct a
sequence that violates your constraints too.

It doesn't make sense to focus on TSO, it's a fundamental issue.

Packets can come from anywhere, and you have to be prepared to
generically handle a MAX_SKB_FRAGS loaded SKB with arbitrary
start/end/length fragment configurations.

> Currently netback limits each skb sent through to 18 slots, because it
> has to map every grant ref to a frag. There was an idea to handle this
> problem by removing this limit and let the backend coalesce the
> scattered buffers into a brand new piece, but then the backend would
> pay the price, and it would be huge as most of the packet should be
> copied.

18 slots means that even with linearization the maximum SKB size
you can support is 64K.   (16 * 4096) == 64K, please one extra slot
on each side for potential partial pages, gives us 18.

> We haven't seen this problem very often, and it's also a bit hard to
> reproduce (hence my frag offset-size pktgen patches), but we can't
> afford the assumption that it won't happen very often.

It's trivial to reproduce, I've already shown how one could trigger it
_without_ TSO being involved at all.  I'll state it again:

	Set TCP_CORK, or use MSG_MORE on the socket.  Do a sequence of
	many 1 byte sendfile() requests over a file, skipping around
	the offset on every call in order to prevent coalescing.

	Clear TCP_CORK or MSG_MORE, you should see a MAX_SKB_FRAGS skb
	end up in the driver transmit function.

> The main concept in this solution is that if it turns out the packet
> needs too many slots in start_xmit, pretend that netfront is not GSO
> capable, and fall back to the software segmentation, which will result
> in packets which can fit.

This is the fundamental issue with your solution.  It is not a GSO
problem.

You therefore have to fully linearize the packet when you encounter
this situation.
