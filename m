From: Tariq Toukan <ttoukan.linux@gmail.com>
Subject: Re: [PATCH v3 net-next 08/14] mlx4: use order-0 pages for RX
Date: Thu, 23 Feb 2017 16:02:28 +0200
Message-ID: <7dd7ef81-1557-a510-a6f1-89047e510b5b@gmail.com>
References: <20170213195858.5215-1-edumazet@google.com>
 <20170213195858.5215-9-edumazet@google.com>
 <1487780558.9415.81.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAKgT0UcXhy3V_iSYFCWqPzdu77v=3-4FEXSyZEiUcB=Y_wGnVw@mail.gmail.com>
 <1487787706.9415.86.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAKgT0Uda3Q6MTCdFf2eR_5Sw9KMTzGrnTosxh2iFT6Sn6QCwrw@mail.gmail.com>
 <1487815618.9415.101.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAKgT0UeDmNYyP1CB+es4YsBX=Bwz964rfZMSNjLoDkfbQyYs8w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
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
To: Alexander Duyck <alexander.duyck@gmail.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:33137 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751041AbdBWOC4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Feb 2017 09:02:56 -0500
Received: by mail-wm0-f66.google.com with SMTP id v77so5626wmv.0
        for <netdev@vger.kernel.org>; Thu, 23 Feb 2017 06:02:34 -0800 (PST)
In-Reply-To: <CAKgT0UeDmNYyP1CB+es4YsBX=Bwz964rfZMSNjLoDkfbQyYs8w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 23/02/2017 4:18 AM, Alexander Duyck wrote:
> On Wed, Feb 22, 2017 at 6:06 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> On Wed, 2017-02-22 at 17:08 -0800, Alexander Duyck wrote:
>>
>>>
>>> Right but you were talking about using both halves one after the
>>> other.  If that occurs you have nothing left that you can reuse.  That
>>> was what I was getting at.  If you use up both halves you end up
>>> having to unmap the page.
>>>
>>
>> You must have misunderstood me.
>>
>> Once we use both halves of a page, we _keep_ the page, we do not unmap
>> it.
>>
>> We save the page pointer in a ring buffer of pages.
>> Call it the 'quarantine'
>>
>> When we _need_ to replenish the RX desc, we take a look at the oldest
>> entry in the quarantine ring.
>>
>> If page count is 1 (or pagecnt_bias if needed) -> we immediately reuse
>> this saved page.
>>
>> If not, _then_ we unmap and release the page.
>
> Okay, that was what I was referring to when I mentioned a "hybrid
> between the mlx5 and the Intel approach".  Makes sense.
>

Indeed, in mlx5 Striding RQ (mpwqe) we do something similar.
Our NIC (ConnectX-4 LX and newer) knows to write multiple _consecutive_ 
packets into the same RX buffer (page).
AFAIU, this is what Eric suggests to do in SW in mlx4.

Here are the main characteristics of our page-cache in mlx5:
1) FIFO (for higher chances of an available page).
2) If the page-cache head is busy, it is not freed. This has its pros 
and cons. We might reconsider.
3) Pages in cache have no page-to-WQE assignment (WQE is for Work Queue 
Element, == RX descriptor). They are shared for all WQEs of an RQ and 
might be used by different WQEs in different rounds.
4) Cache size is smaller than suggested, we would happily increase it to 
reflect a whole ring.

Still, performance tests over mlx5 show that on high load we quickly end 
up allocating pages as the stack does not release its ref count on time.
Increasing the cache size helps of course.
As there's no _fixed_ fair size that guarantees the availability of 
pages every ring cycle, reflecting a ring size can help, and would give 
the opportunity for users to tune their performance by setting their 
ring size according to how powerful their CPUs are, and what traffic 
type/load they're running.

>> Note that we would have received 4096 frames before looking at the page
>> count, so there is high chance both halves were consumed.
>>
>> To recap on x86 :
>>
>> 2048 active pages would be visible by the device, because 4096 RX desc
>> would contain dma addresses pointing to the 4096 halves.
>>
>> And 2048 pages would be in the reserve.
>
> The buffer info layout for something like that would probably be
> pretty interesting.  Basically you would be doubling up the ring so
> that you handle 2 Rx descriptors per a single buffer info since you
> would automatically know that it would be an even/odd setup in terms
> of the buffer offsets.
>
> If you get a chance to do something like that I would love to know the
> result.  Otherwise if I get a chance I can try messing with i40e or
> ixgbe some time and see what kind of impact it has.
>
>>> The whole idea behind using only half the page per descriptor is to
>>> allow us to loop through the ring before we end up reusing it again.
>>> That buys us enough time that usually the stack has consumed the frame
>>> before we need it again.
>>
>>
>> The same will happen really.
>>
>> Best maybe is for me to send the patch ;)
>
> I think I have the idea now.  However patches are always welcome..  :-)
>

Same here :-)
