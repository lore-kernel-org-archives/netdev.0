From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 1/3] net:dsa:mv88e6xxx: use hashtable to store
 multicast entries
Date: Wed, 14 Dec 2016 11:46:14 +0100
Message-ID: <20161214104614.GD27370@lunn.ch>
References: <1481549958-1265-1-git-send-email-volodymyr.bendiuga@gmail.com>
 <87r35db35m.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
 <CAMr9Lbp5eCg1oyWGN+uiDEcF0VZuKUi87FH6JYTGj6pL82R+Mw@mail.gmail.com>
 <48ff1136-dd8f-7704-a512-c23b27989bf8@gmail.com>
 <20161212190915.GA8885@lunn.ch>
 <CAMr9LbqyvrRYe_m34Ufzxkf2Vef3LbMQiuoiwVX0mK=hW6euyA@mail.gmail.com>
 <20161213150948.GD20323@lunn.ch>
 <CABHmqqB-6-L124hrAjNxd4kO3zYp9R=RM1X6PXyuQW6Hapiv4g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Volodymyr Bendiuga <valdr.linuxnext@gmail.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org,
        Volodymyr Bendiuga <volodymyr.bendiuga@westermo.se>
To: Volodymyr Bendiuga <volodymyr.bendiuga@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:54647 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755330AbcLNKqR (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 14 Dec 2016 05:46:17 -0500
Content-Disposition: inline
In-Reply-To: <CABHmqqB-6-L124hrAjNxd4kO3zYp9R=RM1X6PXyuQW6Hapiv4g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 14, 2016 at 11:03:14AM +0100, Volodymyr Bendiuga wrote:
> Hi,
> 
> I understand what you wrote, but we do not refresh anything
> at intervals. FDB dump works only on user request, i.e. user
> run bridge fdb dump command. What we did is just a smarter
> way of feeding the dump request with entries obtained from
> switchcore. Interesting thing is that fdb dump in switchcore
> reads all entries, and from those entries only one is returned at
> a time, others are discarded, because request comes as per port.

Ah, O.K.

> What we do is we dump entries from switchcore once, when the
> first dump request comes, save all of them in the cache, and then
> all following fdb dump requests for each port will be fed from the cache,
> so no more hardware dump operations. We set the cache to be valid for
> 2 seconds, but this could be adjusted and tweaked. So in our case
> we decrease the number of MDIO reads quite a lot.

> What we are thinking now, is that this logics could be moved
> to net/dsa layer, and maybe unified with fdb load logics, if possible.

We should check what the other switches do. Can they perform a dump
with the hardware performing the port filter? Those switches will not
benefit from such a cache. But they should also not suffer.

Combining it with load is a bigger question. Currently the drivers are
stateless. That makes the error handling very simple. We don't have to
worry about running out of memory, since we don't allocate any memory.

If we run out of memory for this dump cache, it is not serious, since
a dump does not result in state change. But if we are out of memory on
a load, we do have state changes. We have to deal with the complexity
of allocating resources in the _prepare call, and then use the
resource in the do call. I would much prefer to avoid this at first,
by optimising the atu get. If we don't see a significant speed up,
then we can consider this complex solution of a cache for load.

     Andrew
