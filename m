From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: GRO aggregation
Date: Thu, 13 Sep 2012 15:47:59 +0300
Message-ID: <CAJZOPZLgQVq+pS1PTU2SM2C_dPPuHx8EnVL8zH077zm5O9aafQ@mail.gmail.com>
References: <504F4063.9030706@mellanox.com>
	<1347388396.13103.658.camel@edumazet-glaptop>
	<36F7E4A28C18BE4DB7C86058E7B607241E622022@MTRDAG01.mtl.com>
	<1347390113.13103.660.camel@edumazet-glaptop>
	<36F7E4A28C18BE4DB7C86058E7B607241E622083@MTRDAG01.mtl.com>
	<1347392132.13103.663.camel@edumazet-glaptop>
	<505054AE.9040901@mellanox.com>
	<1347442394.13103.703.camel@edumazet-glaptop>
	<50509F30.30402@mellanox.com>
	<5050B6FF.5050002@hp.com>
	<5050B9B2.5070107@mellanox.com>
	<5050BDB5.8090200@hp.com>
	<50517F01.9050501@mellanox.com>
	<1347523865.13103.1423.camel@edumazet-glaptop>
	<CAJZOPZL8qrqYfAvcQBDB9CFy7WwztWchaMyADGBnwKpW-r1Q4g@mail.gmail.com>
	<1347537926.13103.1530.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Shlomo Pongartz <shlomop@mellanox.com>,
	Rick Jones <rick.jones2@hp.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.co.il>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:61125 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753203Ab2IMMsA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Sep 2012 08:48:00 -0400
Received: by ieje11 with SMTP id e11so4814584iej.19
        for <netdev@vger.kernel.org>; Thu, 13 Sep 2012 05:48:00 -0700 (PDT)
In-Reply-To: <1347537926.13103.1530.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 13, 2012 at 3:05 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2012-09-13 at 12:59 +0300, Or Gerlitz wrote:
>> On Thu, Sep 13, 2012 at 11:11 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> > MAX_SKB_FRAGS is 16
>> > skb_gro_receive() will return -E2BIG once this limit is hit.
>> > If you use a MSS = 100 (instead of MSS = 1460), then GRO skb will
>> > contain only at most 1700 bytes, but TSO packets can still be 64KB, if
>> > the sender NIC can afford it (some NICS wont work quite well)

>> Addressing this assertion of yours, Shlomo showed that with ixgbe he managed
>> to see GRO aggregating 32KB which means 20-21 packets that is > 16 fragments
>> in this notation, can it be related to the way ixgbe is actually allocating skbs?

> Hard to say without knowing exact kernel version, as things change a lot in this area.

As Shlomo wrote earlier on this thread his testbed is 3.6-rc1


> You have several kind of GRO. One fast and one slow.
> The slow one uses a linked list of skbs (pinfo->frag_list), while the
> fast one uses fragments (pinfo->nr_frags)
>
> For example, some drivers (mellanox one is in this lot) pull too many
> bytes in skb->head and this defeats the fast GRO :
> Part of payload is in skb->head, remaining part in pinfo->frags[0]
>
> skb_gro_receive() then has to allocate a new head skb, to link skbs into
> head->frag_list. The total skb->truesize is not reduced at all, its
> increased.
>
> So you might think GRO is working, but its only a hack, as one skb has a
> list of skbs, and this makes TCP read() slower, and defeats TCP
> coalescing as well. Whats the point of delivering fat skbs to TCP stack
> if it slows down the consumer, because of increased cache line misses ?

Shlomo is dealing with making the IPoIB driver work well with GRO,
thanks for the
comments on the Mellanox Ethernet driver, we will look there too
(added Yevgeny)...

As for IPoIB it has two modes, connected which irrelevant for this
discussion, and datagram
- who is under the  scope here. Its MTU is typically 2044 but can be
4092 as well, the allocation
of skb's for this mode is done in ipoib_alloc_rx_skb() -- which you've
patched recently...

Following your comment we noted that if using the lower/typical mtu of
2044 which means
we are below the ipoib_ud_need_sg() threshold, skbs are allocated on
one "form" and if using
the 4092 mtu in another "form" - do you see each of the form to fall
into different GRO flow, e.g
2044 to the "slow" and 4092 to the "fast"?!

Or.
