From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH V1 net-next 2/2] net: Add UDP GRO support for vxlan traffic
Date: Mon, 6 Jan 2014 23:39:44 +0200
Message-ID: <CAJZOPZ+CBg1WO-kOOTrYhuGbEnxxgaR=fzUsWQCqbpaG2WOvnw@mail.gmail.com>
References: <1388935422-7331-1-git-send-email-ogerlitz@mellanox.com>
	<1388935422-7331-3-git-send-email-ogerlitz@mellanox.com>
	<CA+mtBx-g1tsBEG6D0oOmG-J_fz68fr6py2OY6RAtoJHUts7h3g@mail.gmail.com>
	<CAJZOPZJ2DRP13LRzcu__rh=JxY7oAvCQ37dCpmO40ptiRn5hFw@mail.gmail.com>
	<CAJZOPZLZNEvao9PxtX78sfpg_4GVamgxNMNU52QQ1aFqAxQDZA@mail.gmail.com>
	<CA+mtBx_B+7CU3GDiod+n7tHfwBcA_3DEhD7tvPYhsZMebiwY8w@mail.gmail.com>
	<CAJZOPZKfxws+S3ZtTqKQ_yXYhoV=UTOXscM+rVB24UA2d1Fopg@mail.gmail.com>
	<CA+mtBx-aiCMyJocmDw8MfoGxWns2yppjFr8-hn6mH7yrFbMrGA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Or Gerlitz <ogerlitz@mellanox.com>, Jerry Chu <hkchu@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Yan Burman <yanb@mellanox.com>,
	Shlomo Pongratz <shlomop@mellanox.com>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:35768 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756411AbaAFVjp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jan 2014 16:39:45 -0500
Received: by mail-pd0-f179.google.com with SMTP id r10so18713162pdi.38
        for <netdev@vger.kernel.org>; Mon, 06 Jan 2014 13:39:44 -0800 (PST)
In-Reply-To: <CA+mtBx-aiCMyJocmDw8MfoGxWns2yppjFr8-hn6mH7yrFbMrGA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 6, 2014 at 8:46 PM, Tom Herbert <therbert@google.com> wrote:
> On Mon, Jan 6, 2014 at 10:13 AM, Or Gerlitz <or.gerlitz@gmail.com> wrote:
>> On Mon, Jan 6, 2014 at 6:50 PM, Tom Herbert <therbert@google.com> wrote:
>>> I think this would be a good start. We can further optimize the encap
>>> path later on.
>>
>> good, did you had the chance to look on the 2nd problem I was facing,
>> e.g how to prevent gro-ing encapsulated VM (this issue will not happen
>> for non-virtualization schemes, I think) udp packets which happen to
>> carry a destination port which belongs to an encapsulation protocol?
>> as I wrote earlier here, I was thinking to add some field to struct
>> napi_gro_cb which will be zeroed when the gro stacks starts to work on
>> the skb and set once we pass udp_gro_receive, such that if we arrive
>> again to udp_gro_recieve and this field is set, which means the
>> encapsulated
>> packet is udp one, we flush.
>
> I don't see what the problem is, GRO should not be recursively applied
> to an inner UDP header for encapsulation. The guest may try to do it's
> own version of GRO on an inner UDP packet, but interpreting the
> destination port correctly is its responsibility then.


I wasn't sure what do you mean by "GRO should not be recursively applied
to an inner UDP header for encapsulation", consider these three packets p1/p2/p3
who are vxlan encapsulated with the UDP port used by vxlan being X and are
structured as follows (the arrows depict the gro travels)


p1: ip --> udp dport X --> vxlan --> ip --> tcp  dportZ
p2: ip --> udp dport X --> vxlan --> ip --> udp dportY
p2: ip --> udp dport X --> vxlan --> ip --> udp dportX --> vxlan xxit!

p1 will safely land in the tcp gro code and be handled there

p2 will travel twice to the udp gro code and be flushed on the 2nd
time there since
there is no gro protocol handler for udp port Y

p3 will travel twice to the udp gro code but will not be flushed on
the 2nd time
since it has dport which is registered to have gro handler, as such
the 1st eight bytes
of its payload will be considered vxlan header and from there we will
not be going anywhere good.

My current solution is to mark packets while they manage to cross the
udp gro recv handler
and disallow crossing there twice.
