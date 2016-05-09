From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next] ip6_gre: Fix MTU setting
Date: Mon, 9 May 2016 16:47:10 -0700
Message-ID: <CALx6S370WD7pF8zk2mzi9kZhBRbmG4m1bD_a2jM+coRbWw4afg@mail.gmail.com>
References: <1462832909-553684-1-git-send-email-tom@herbertland.com>
	<CAKgT0UdyJyALd6DHA4GeUQtS08MusBTU880A5fNtMbMu_r55Sg@mail.gmail.com>
	<CALx6S35FbaG9jiM4diNmKC+=cSCi+3t7WM1AXxi_c3iigsUu-A@mail.gmail.com>
	<CAKgT0UcHky39E9Sxo7L_ZtOOx9uUNy5NdLa78C+oLeB2q21o+g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>, Kernel Team <kernel-team@fb.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:38091 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753633AbcEIXrL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2016 19:47:11 -0400
Received: by mail-ig0-f181.google.com with SMTP id m9so105242303ige.1
        for <netdev@vger.kernel.org>; Mon, 09 May 2016 16:47:10 -0700 (PDT)
In-Reply-To: <CAKgT0UcHky39E9Sxo7L_ZtOOx9uUNy5NdLa78C+oLeB2q21o+g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 9, 2016 at 4:10 PM, Alexander Duyck
<alexander.duyck@gmail.com> wrote:
> On Mon, May 9, 2016 at 3:49 PM, Tom Herbert <tom@herbertland.com> wrote:
>> On Mon, May 9, 2016 at 3:44 PM, Alexander Duyck
>> <alexander.duyck@gmail.com> wrote:
>>> On Mon, May 9, 2016 at 3:28 PM, Tom Herbert <tom@herbertland.com> wrote:
>>>> In ip6gre_tnl_link_config set t->tun_len and t->hlen correctly for the
>>>> configuration. For hard_header_len and mtu calculation include
>>>> IPv6 header and encapsulation overhead.
>>>>
>>>> In ip6gre_tunnel_init_common set t->tun_len and t->hlen correctly for
>>>> the configuration. Revert to setting hard_header_len instead of
>>>> needed_headroom.
>>>>
>>>> Tested:
>>>>
>>>> ./ip link add name tun8 type ip6gretap remote \
>>>> 2401:db00:20:911a:face:0:27:0 local \
>>>> 2401:db00:20:911a:face:0:25:0 ttl 225
>>>>
>>>> Gives MTU of 1434. That is equal to 1500 - 40 - 14 - 4 - 8.
>>>>
>>>> ./ip link add name tun8 type ip6gretap remote \
>>>> 2401:db00:20:911a:face:0:27:0 local \
>>>> 2401:db00:20:911a:face:0:25:0 ttl 225 okey 123
>>>>
>>>> Gives MTU of 1430. That is equal to 1500 - 40 - 14 - 4 - 8 - 4.
>>>>
>>>> Signed-off-by: Tom Herbert <tom@herbertland.com>
>>>
>>> So this gives me the correct result now.  However we still need patch
>>> 3 / 11 from the set you submitted next week in order to be able to
>>> even transmit because the flags are otherwise mangled.
>>>
>>> Tested-by: Alexander Duyck <aduyck@mirantis.com>
>>
>> Okay, I'll repost the flags patch as a standalone. Do you have any
>> other issues then in this path?
>
> This piece no.
>
> Like I said in the other email I did find two other issues.  First in
> __gre6_xmit I think you want to set the inner protocol to "protocol",
> not "proto".  Second is the issue with ip6_tnl_xmit stomping on
> skb->transport_header.  The second one is the big one that is blocking
> things badly right now.  That is the one that keeps me from doing
> anything with any sort of offload as the headers are jumping around
> out of order with the outer transport header having an offset that is
> further in than the inner mac header.
>
You mean "skb->transport_header = skb->network_header;"? It doesn't
look right to me either, but that line has been around a while....

> I'd be fine with you submitting the whole set as one piece with the
> other 11 patches you had just as long as we get those core pieces
> fixed in the patch set.
>
Probably just as easy to break it up.

> - Alex
