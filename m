From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH v3 net-next 08/14] mlx4: use order-0 pages for RX
Date: Wed, 22 Feb 2017 18:18:46 -0800
Message-ID: <CAKgT0UeDmNYyP1CB+es4YsBX=Bwz964rfZMSNjLoDkfbQyYs8w@mail.gmail.com>
References: <20170213195858.5215-1-edumazet@google.com> <20170213195858.5215-9-edumazet@google.com>
 <1487780558.9415.81.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAKgT0UcXhy3V_iSYFCWqPzdu77v=3-4FEXSyZEiUcB=Y_wGnVw@mail.gmail.com>
 <1487787706.9415.86.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAKgT0Uda3Q6MTCdFf2eR_5Sw9KMTzGrnTosxh2iFT6Sn6QCwrw@mail.gmail.com> <1487815618.9415.101.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <edumazet@google.com>,
        Alexander Duyck <alexander.h.duyck@intel.com>,
        "David S . Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Willem de Bruijn <willemb@google.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Alexei Starovoitov <ast@kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:33374 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934460AbdBWC1H (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Feb 2017 21:27:07 -0500
Received: by mail-it0-f67.google.com with SMTP id e137so388710itc.0
        for <netdev@vger.kernel.org>; Wed, 22 Feb 2017 18:27:06 -0800 (PST)
In-Reply-To: <1487815618.9415.101.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 22, 2017 at 6:06 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2017-02-22 at 17:08 -0800, Alexander Duyck wrote:
>
>>
>> Right but you were talking about using both halves one after the
>> other.  If that occurs you have nothing left that you can reuse.  That
>> was what I was getting at.  If you use up both halves you end up
>> having to unmap the page.
>>
>
> You must have misunderstood me.
>
> Once we use both halves of a page, we _keep_ the page, we do not unmap
> it.
>
> We save the page pointer in a ring buffer of pages.
> Call it the 'quarantine'
>
> When we _need_ to replenish the RX desc, we take a look at the oldest
> entry in the quarantine ring.
>
> If page count is 1 (or pagecnt_bias if needed) -> we immediately reuse
> this saved page.
>
> If not, _then_ we unmap and release the page.

Okay, that was what I was referring to when I mentioned a "hybrid
between the mlx5 and the Intel approach".  Makes sense.

> Note that we would have received 4096 frames before looking at the page
> count, so there is high chance both halves were consumed.
>
> To recap on x86 :
>
> 2048 active pages would be visible by the device, because 4096 RX desc
> would contain dma addresses pointing to the 4096 halves.
>
> And 2048 pages would be in the reserve.

The buffer info layout for something like that would probably be
pretty interesting.  Basically you would be doubling up the ring so
that you handle 2 Rx descriptors per a single buffer info since you
would automatically know that it would be an even/odd setup in terms
of the buffer offsets.

If you get a chance to do something like that I would love to know the
result.  Otherwise if I get a chance I can try messing with i40e or
ixgbe some time and see what kind of impact it has.

>> The whole idea behind using only half the page per descriptor is to
>> allow us to loop through the ring before we end up reusing it again.
>> That buys us enough time that usually the stack has consumed the frame
>> before we need it again.
>
>
> The same will happen really.
>
> Best maybe is for me to send the patch ;)

I think I have the idea now.  However patches are always welcome..  :-)
