From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xen-netfront: Fix handling packets on compound pages
 with skb_linearize
Date: Mon, 11 Aug 2014 14:57:18 -0700 (PDT)
Message-ID: <20140811.145718.2107344183649169120.davem@davemloft.net>
References: <1407778343-13622-1-git-send-email-zoltan.kiss@citrix.com>
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
In-Reply-To: <1407778343-13622-1-git-send-email-zoltan.kiss@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Zoltan Kiss <zoltan.kiss@citrix.com>
Date: Mon, 11 Aug 2014 18:32:23 +0100

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
> This patch solves this problem by linearizing the packet. This is not the
> fastest way, and it can fail much easier as it tries to allocate a big linear
> area for the whole packet, but probably easier by an order of magnitude than
> anything else. Probably this code path is not touched very frequently anyway.
> 
> Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>

Applied.

You may wish to now make your queue stop/wake point be MAX_SKB_FRAGS + 1 slots.
That way you will always abide by the netdev queue management rules in that
if the queue is awake you will always be able to accept at least on more SKB.
