From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net-next RFC 0/3] virtio-net: Conditionally enable tx
 interrupt
Date: Tue, 14 Oct 2014 14:53:27 -0400 (EDT)
Message-ID: <20141014.145327.365091739350390288.davem@davemloft.net>
References: <1413011806-3813-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rusty-8n+1lVoiYb80n/F98K4Iww@public.gmane.org, mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	kvm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: jasowang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1413011806-3813-1-git-send-email-jasowang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Jason Wang <jasowang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Date: Sat, 11 Oct 2014 15:16:43 +0800

> We free old transmitted packets in ndo_start_xmit() currently, so any
> packet must be orphaned also there. This was used to reduce the overhead of
> tx interrupt to achieve better performance. But this may not work for some
> protocols such as TCP stream. TCP depends on the value of sk_wmem_alloc to
> implement various optimization for small packets stream such as TCP small
> queue and auto corking. But orphaning packets early in ndo_start_xmit()
> disable such things more or less since sk_wmem_alloc was not accurate. This
> lead extra low throughput for TCP stream of small writes.
> 
> This series tries to solve this issue by enable tx interrupts for all TCP
> packets other than the ones with push bit or pure ACK. This is done through
> the support of urgent descriptor which can force an interrupt for a
> specified packet. If tx interrupt was enabled for a packet, there's no need
> to orphan it in ndo_start_xmit(), we can free it tx napi which is scheduled
> by tx interrupt. Then sk_wmem_alloc was more accurate than before and TCP
> can batch more for small write. More larger skb was produced by TCP in this
> case to improve both throughput and cpu utilization.
> 
> Test shows great improvements on small write tcp streams. For most of the
> other cases, the throughput and cpu utilization are the same in the
> past. Only few cases, more cpu utilization was noticed which needs more
> investigation.
> 
> Review and comments are welcomed.

I think proper accounting and queueing (at all levels, not just TCP
sockets) is more important than trying to skim a bunch of cycles by
avoiding TX interrupts.

Having an event to free the SKB is absolutely essential for the stack
to operate correctly.

And with virtio-net you don't even have the excuse of "the HW
unfortunately doesn't have an appropriate TX event."

So please don't play games, and instead use TX interrupts all the
time.  You can mitigate them in various ways, but don't turn them on
selectively based upon traffic type, that's terrible.

You can even use ->xmit_more to defer the TX interrupt indication to
the final TX packet in the chain.
