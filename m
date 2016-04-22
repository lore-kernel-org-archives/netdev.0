From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [RFC PATCH] gro: Partly revert "net: gro: allow to build full
 sized skb"
Date: Fri, 22 Apr 2016 10:14:22 -0700
Message-ID: <CAKgT0UeJLhn5yyK9Ezt=jHsysi4y+fVkRoOyZN2Zbe7Wk0LuHw@mail.gmail.com>
References: <20160421074042.GF3347@gauss.secunet.com>
	<CAKgT0Uc-MfZseKauJMW+xh+5LTEww6hcWmuXeCATsDA+Z-POsQ@mail.gmail.com>
	<20160422085107.GJ3347@gauss.secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Sowmini Varadhan <sowmini.varadhan@oracle.com>,
	Netdev <netdev@vger.kernel.org>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:37281 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932300AbcDVROY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Apr 2016 13:14:24 -0400
Received: by mail-ig0-f179.google.com with SMTP id g8so22143091igr.0
        for <netdev@vger.kernel.org>; Fri, 22 Apr 2016 10:14:23 -0700 (PDT)
In-Reply-To: <20160422085107.GJ3347@gauss.secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 22, 2016 at 1:51 AM, Steffen Klassert
<steffen.klassert@secunet.com> wrote:
> On Thu, Apr 21, 2016 at 09:02:48AM -0700, Alexander Duyck wrote:
>> On Thu, Apr 21, 2016 at 12:40 AM, Steffen Klassert
>> <steffen.klassert@secunet.com> wrote:
>> > This partly reverts the below mentioned patch because on
>> > forwarding, such skbs can't be offloaded to a NIC.
>> >
>> > We need this to get IPsec GRO for forwarding to work properly,
>> > otherwise the GRO aggregated packets get segmented again by
>> > the GSO layer. Although discovered when implementing IPsec GRO,
>> > this is a general problem in the forwarding path.
>>
>> I'm confused as to why you would need this to get IPsec GRO forwarding
>> to work.
>
> It works without this, but the performance numbers are not that good
> if we have to do GSO in software.

Well really GSO is only meant to preform better than if we didn't do
any GRO/GSO at all.  If that isn't the case I wouldn't consider it a
regression since as Eric points out there are other scenerios where
you end up with a chain of buffers stuck on the fraglist.  Mostly what
GRO/GSO gets you is fewer runs through the stack.

>> Are you having to go through a device that doesn't have
>> NETIF_F_FRAGLIST defined?
>
> I don't know of any NIC that can do TSO on a skbuff with fraglist,
> that's why I try to avoid to have a buffer with fraglist.
>

Most of them don't.  There are only one or two NICs out there that
support transmitting a frame that has a fraglist.

>> Also what is the issue with having to go
>> through the GSO layer on segmentation?  It seems like we might be able
>> to do something like what we did with GSO partial to split frames so
>> that they are in chunks that wouldn't require NETIF_F_FRAGLIST.  Then
>> you could get the best of both worlds in that the stack would only
>> process one super-frame, and the transmitter could TSO a series of
>> frames that are some fixed MSS in size.
>
> This could be interesting. Then we could have a buffer with
> fraglist, GSO layer splits in skbuffs without fraglist that
> can be TSO offloaded. Something like this might solve my
> performance problems.

Right.  It is something to think about.  I was considering what might
be involved to make a fraglist based skb a GSO type.  Then we might be
able to handle it kind of like what we do for the whole
SKB_GSO_DODGY/NETIF_F_GSO_ROBUST path.  Basically if we just need to
break the frame at the fraglist level it probably wouldn't be that
hard to do assuming each skb is MSS aligned in terms of size.

- Alex
