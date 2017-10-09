From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [net PATCH] macvlan: Only deliver one copy of the frame to the
 macvlan interface
Date: Mon, 9 Oct 2017 10:50:32 -0700
Message-ID: <CAKgT0Udnm+WBF9dyvRh1_b-j0JAbfM9YNcPARzrO1Gc=PD9rkQ@mail.gmail.com>
References: <20171008225403.15848.77823.stgit@localhost.localdomain>
 <1507511262.14419.32.camel@edumazet-glaptop3.roam.corp.google.com> <CAKgT0Ueb8O_Exh6ERaQev7kE-xv89Dqkn4C2uWNtmLaqQXZrKw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f194.google.com ([209.85.216.194]:44497 "EHLO
        mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932077AbdJIRue (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Oct 2017 13:50:34 -0400
Received: by mail-qt0-f194.google.com with SMTP id v28so35811982qtv.1
        for <netdev@vger.kernel.org>; Mon, 09 Oct 2017 10:50:33 -0700 (PDT)
In-Reply-To: <CAKgT0Ueb8O_Exh6ERaQev7kE-xv89Dqkn4C2uWNtmLaqQXZrKw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 9, 2017 at 10:30 AM, Alexander Duyck
<alexander.duyck@gmail.com> wrote:
> On Sun, Oct 8, 2017 at 6:07 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> On Sun, 2017-10-08 at 15:54 -0700, Alexander Duyck wrote:
>>> From: Alexander Duyck <alexander.h.duyck@intel.com>
>>>
>>> This patch intoduces a slight adjustment for macvlan to address the fact
>>> that in source mode I was seeing two copies of any packet addressed to the
>>> macvlan interface being delivered where there should have been only one.
>>>
>>> The issue appears to be that one copy was delivered based on the source MAC
>>> address and then the second copy was being delivered based on the
>>> destination MAC address. To fix it I am just freeing the second copy
>>> instead of delivering it up the stack using the same netdev as was already
>>> delivered to.
>>>
>>> Fixes: 79cf79abce71 ("macvlan: add source mode")
>>> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
>>> ---
>>>  drivers/net/macvlan.c |    3 ++-
>>>  1 file changed, 2 insertions(+), 1 deletion(-)
>>>
>>> diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
>>> index d2aea961e0f4..744b0fe6dc78 100644
>>> --- a/drivers/net/macvlan.c
>>> +++ b/drivers/net/macvlan.c
>>> @@ -484,7 +484,8 @@ static rx_handler_result_t macvlan_handle_frame(struct sk_buff **pskb)
>>>               return RX_HANDLER_PASS;
>>>
>>>       dev = vlan->dev;
>>> -     if (unlikely(!(dev->flags & IFF_UP))) {
>>> +     if ((vlan->mode == MACVLAN_MODE_SOURCE) ||
>>> +         unlikely(!(dev->flags & IFF_UP))) {
>>>               kfree_skb(skb);
>>>               return RX_HANDLER_CONSUMED;
>>>       }
>>>
>>
>>
>> Shouldn't we have a consume_skb() then instead of kfree_skb() ?
>>
>> We are not really dropping a packet here, only avoiding some artifact
>> cause by the cited commit.
>
> The cited commit basically introduced an issue where we are cloning it
> and sending the clone to the correct device and then are stuck with
> the original. The way I fixed it is currently consistent with how
> broadcast is already being handled for macvlan since they are calling
> kfree_skb() on the clone that they end up enqueueing for broadcast.
>
> My thought is to look at rewriting this in relation to some other work
> I am doing, but I wanted to have a fix for net and stable kernels that
> prevents this frame duplication from occurring. Really in order to
> handle this correctly my thought is that we should probably be doing a
> vlan_prev similar to how we have a pt_prev in
> __netif_receive_skb_core. Then that way when a packet is meant to be
> handled by one interface, as is the case for most unicast traffic with
> VLAN regardless of source mode or not we can then just jump back in
> using RX_HANDLER_ANOTHER.
>
> - Alex

Actually, now that I am thinking it over again maybe us calling
kfree_skb() isn't the correct answer. It might make more sense to just
return RX_HANDLER_PASS. Then we can defer it to the original interface
to drop it.

- Alex
