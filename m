From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xen-netfront: Fix handling packets on compound pages
 with skb_segment
Date: Thu, 31 Jul 2014 13:25:20 -0700 (PDT)
Message-ID: <20140731.132520.1889577477638334755.davem@davemloft.net>
References: <1406726730-17994-1-git-send-email-zoltan.kiss@citrix.com>
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
In-Reply-To: <1406726730-17994-1-git-send-email-zoltan.kiss@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Zoltan Kiss <zoltan.kiss@citrix.com>
Date: Wed, 30 Jul 2014 14:25:30 +0100

> There is a long known problem with the netfront/netback interface: if the guest
> tries to send a packet which constitues more than MAX_SKB_FRAGS + 1 ring slots,
> it gets dropped. The reason is that netback maps these slots to a frag in the
> frags array, which is limited by size. Having so many slots can occur since
> compound pages were introduced, as the ring protocol slice them up into
> individual (non-compound) page aligned slots. The theoretical worst case
> scenario looks like this (note, skbs are limited to 64 Kb here):
> linear buffer: at most PAGE_SIZE - 17 * 2 bytes, overlapping page boundary,
> using 2 slots
> first 15 frags: 1 + PAGE_SIZE + 1 bytes long, first and last bytes are at the
> end and the beginning of a page, therefore they use 3 * 15 = 45 slots
> last 2 frags: 1 + 1 bytes, overlapping page boundary, 2 * 2 = 4 slots
> Although I don't think this 51 slots skb can really happen, we need a solution
> which can deal with every scenario. In real life there is only a few slots
> overdue, but usually it causes the TCP stream to be blocked, as the retry will
> most likely have the same buffer layout.
> This patch solves this problem by slicing up the skb itself with the help of
> skb_segment, and calling xennet_start_xmit again on the resulting packets. It
> also works with the theoretical worst case, where there is a 3 level recursion.
> The good thing is that skb_segment only copies the header part, the frags will
> be just referenced again.
> 
> Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>

This is a really scary change :-)

I definitely see some potential problem here.

First of all, even in cases where it might "work", such as TCP, you
are modifying the data stream.  The sizes are changing, the packet
counts are different, and all of this will have side effects such as
potentially harming TCP performance.

Secondly, for something like UDP you can't just split the packet up
like this, or for any other datagram protocol for that matter.

I know you're in a difficult situation, but I just can't see this
being an acceptable approach to solving the problem right now.

Where does the MAX_SKB_FRAGS + 1 limit really come from, the size of
the TX queue?

If you were to have a 64-slot TX queue, you ought to be able to handle
this theoretical 51 slot SKB.

And I don't think it's so theoretical, a carefully crafted sequence of
sendfile() calls during a TCP_CORK sequence should be able to do it.
