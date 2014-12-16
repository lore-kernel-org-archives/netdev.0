From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: Netlink mmap tx security?
Date: Wed, 17 Dec 2014 00:58:52 +0100
Message-ID: <5490C73C.8010405@redhat.com>
References: <20141014.220908.123550384430402000.davem@davemloft.net> <543F6998.5090000@redhat.com> <20141016070753.GA16738@casper.infradead.org> <20141216.175817.576861457076632402.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, luto@amacapital.net, torvalds@linux-foundation.org,
	kaber@trash.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39968 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751066AbaLPX71 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Dec 2014 18:59:27 -0500
In-Reply-To: <20141216.175817.576861457076632402.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/16/2014 11:58 PM, David Miller wrote:
> From: Thomas Graf <tgraf@suug.ch>
> Date: Thu, 16 Oct 2014 08:07:53 +0100
>
>> On 10/16/14 at 08:45am, Daniel Borkmann wrote:
>>> On 10/15/2014 04:09 AM, David Miller wrote:
>>>> That would work as well.
>>>>
>>>> There are pros and cons to all of these approaches.
>>>>
>>>> I was thinking that if we do the "TX mmap --> copy to kernel buffer"
>>>> approach, then if in the future we find a way to make it work
>>>> reliably, we can avoid the copy.  And frankly performance wise it's no
>>>> worse than what happens via normal sendmsg() calls.
>>>>
>>>> And all applications using NETLINK_RX_RING keep working and keep
>>>> getting the performance boost.
>>>
>>> That would be better, yes. This would avoid having such a TPACKET_V*
>>> API chaos we have in packet sockets if this could be fixed for netlink
>>> eventually.
>>
>> Only saw the second part of Dave's message now. I agree that this
>> is even a better option.
>
> Sorry for dropping the ball on this, here is the patch I have right
> now, any comments?
>
> ====================
> [PATCH] netlink: Always copy on mmap TX.
>
> Checking the file f_count and the nlk->mapped count is not completely
> sufficient to prevent the mmap'd area contents from changing from
> under us during netlink mmap sendmsg() operations.
>
> Be careful to sample the header's length field only once, because this
> could change from under us as well.
>
> Signed-off-by: David S. Miller <davem@davemloft.net>

Looks good to me, thanks for following up on this Dave!

Now this also leaves NETLINK_SKB_TX unused afterwards, so we should
get rid of these bits, too. It's only set in the broken 'exclusive'
path and tested for resetting the slot status in the skb destructor,
but _now_ we set it back immediately to NL_MMAP_STATUS_UNUSED instead
of a NL_MMAP_STATUS_RESERVED -> NL_MMAP_STATUS_UNUSED transition via
destructor.

The atomic (tx)ring->pending logic inside the send path seems also
unused now; similarly as in, resp. taken from packet sockets, it was
there to wait for completion (for blocking syscalls) until the
netlink_skb_destructor() has been invoked and thus the slot given
back to user space.

Anyways, above could probably be followed-up; other than that:

Fixes: 5fd96123ee19 ("netlink: implement memory mapped sendmsg()")
Acked-by: Daniel Borkmann <dborkman@redhat.com>
