From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [net PATCH] flow_dissector: Fix unaligned access in
 __skb_flow_dissector when used by eth_get_headlen
Date: Sat, 30 Jan 2016 17:13:35 -0800
Message-ID: <CAKgT0UfyK1HO6vp4F9S3rB400A74OhS=qRX_N9RuPRYg2KazLg@mail.gmail.com>
References: <20160129180651.GA17127@oracle.com>
	<20160130024556.6227.51798.stgit@localhost.localdomain>
	<1454124234.7627.119.camel@edumazet-glaptop2.roam.corp.google.com>
	<20160130161702.GA11601@oracle.com>
	<CAKgT0UcZAh+ciNMkJDdnp7E0xyGMhvgSzJLwORLqYXbpABtoRQ@mail.gmail.com>
	<1454182011.7627.141.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Sowmini Varadhan <sowmini.varadhan@oracle.com>,
	Alexander Duyck <aduyck@mirantis.com>,
	Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Tom Herbert <tom@herbertland.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f179.google.com ([209.85.223.179]:36036 "EHLO
	mail-io0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753256AbcAaBNg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jan 2016 20:13:36 -0500
Received: by mail-io0-f179.google.com with SMTP id g73so125613115ioe.3
        for <netdev@vger.kernel.org>; Sat, 30 Jan 2016 17:13:35 -0800 (PST)
In-Reply-To: <1454182011.7627.141.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jan 30, 2016 at 11:26 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Sat, 2016-01-30 at 10:36 -0800, Alexander Duyck wrote:
>
>> As far as the NET_IP_ALIGN on the page offset I think it is a horrible
>> idea.  Basically it means we have to allocate at least 1K more space
>> than we need since page sizes are powers of 2, and buffer sizes in
>> hardware are measured in 1K increments.
>
> I thought Ethernet frames were something like ~1500 bytes.

It is, but if jumbo frames are enabled or LRO is enabled the NIC will
generate larger frames.

> Can't you program the NIC to not receive frames bigger than MTU + 18, or
> at least 2046 ?

Yes and no.  The NIC will already block frames larger than a fixed
size, but there are features like LRO that will let the NIC assemble a
larger frame.

> Of course, if the NIC is able to push 2048 bytes (instead of 2046 max),
> using an offset of 2 is not going to work.

The NIC hardware only allows us to set receive buffer sizes in 1K
increments.  I think fm10k may be an exception in that it may be able
to support 512 byte, but otherwise igb and ixgbe are strictly set in
1K increments.  So basically if we did the NET_IP_ALIGN of the page we
are limited to 1K buffers if we were to retain the current page reuse,
or we could go up to 3K if we were to allocate order 1 pages for
receive buffers as currently occurs with FCoE.

I would really prefer to keep the pages DMA aligned, and the skb->data
IP aligned.  If nothing else it has the advantage of actually having
the proper alignment on all the headers if I only pull the outer
headers and leave the inner headers in the page.. :-/

- Alex
