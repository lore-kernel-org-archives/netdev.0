From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH] xen-netfront: Fix handling packets on compound pages
 with skb_segment
Date: Mon, 4 Aug 2014 21:35:54 +0100
Message-ID: <20140804203554.GA23767@zion.uk.xensource.com>
References: <1406726730-17994-1-git-send-email-zoltan.kiss@citrix.com>
 <20140731.132520.1889577477638334755.davem@davemloft.net>
 <53DFC2FE.8070105@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: David Miller <davem@davemloft.net>, <konrad.wilk@oracle.com>,
	<boris.ostrovsky@oracle.com>, <david.vrabel@citrix.com>,
	<wei.liu2@citrix.com>, <Ian.Campbell@citrix.com>,
	<paul.durrant@citrix.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <xen-devel@lists.xenproject.org>
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <53DFC2FE.8070105@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 04, 2014 at 06:29:34PM +0100, Zoltan Kiss wrote:
> On 31/07/14 21:25, David Miller wrote:
> >From: Zoltan Kiss <zoltan.kiss@citrix.com>
> >Date: Wed, 30 Jul 2014 14:25:30 +0100
> >
> >>There is a long known problem with the netfront/netback interface: if the guest
> >>tries to send a packet which constitues more than MAX_SKB_FRAGS + 1 ring slots,
> >>it gets dropped. The reason is that netback maps these slots to a frag in the
> >>frags array, which is limited by size. Having so many slots can occur since
> >>compound pages were introduced, as the ring protocol slice them up into
> >>individual (non-compound) page aligned slots. The theoretical worst case
> >>scenario looks like this (note, skbs are limited to 64 Kb here):
> >>linear buffer: at most PAGE_SIZE - 17 * 2 bytes, overlapping page boundary,
> >>using 2 slots
> >>first 15 frags: 1 + PAGE_SIZE + 1 bytes long, first and last bytes are at the
> >>end and the beginning of a page, therefore they use 3 * 15 = 45 slots
> >>last 2 frags: 1 + 1 bytes, overlapping page boundary, 2 * 2 = 4 slots
> >>Although I don't think this 51 slots skb can really happen, we need a solution
> >>which can deal with every scenario. In real life there is only a few slots
> >>overdue, but usually it causes the TCP stream to be blocked, as the retry will
> >>most likely have the same buffer layout.
> >>This patch solves this problem by slicing up the skb itself with the help of
> >>skb_segment, and calling xennet_start_xmit again on the resulting packets. It
> >>also works with the theoretical worst case, where there is a 3 level recursion.
> >>The good thing is that skb_segment only copies the header part, the frags will
> >>be just referenced again.
> >>
> >>Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
> >
> >This is a really scary change :-)
> I admit that :)
> >
> >I definitely see some potential problem here.
> >
> >First of all, even in cases where it might "work", such as TCP, you
> >are modifying the data stream.  The sizes are changing, the packet
> >counts are different, and all of this will have side effects such as
> >potentially harming TCP performance.
> >
> >Secondly, for something like UDP you can't just split the packet up
> >like this, or for any other datagram protocol for that matter.
> The netback/netfront interface currently only supports TSO and TSO6. That's
> why I did the pktgen TCP patch

IMO if this approach is known to be broken in the future (say if we want
to support UFO) we'd better avoid it.

Wei.
