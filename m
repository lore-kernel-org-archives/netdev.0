From: Tariq Toukan <ttoukan.linux@gmail.com>
Subject: Re: [PATCH v2 net-next 00/14] mlx4: order-0 allocations and page
 recycling
Date: Sun, 12 Feb 2017 19:24:10 +0200
Message-ID: <f21e77a6-86e4-a317-38a5-5822ffb1916c@gmail.com>
References: <20170209135838.16487-1-edumazet@google.com>
 <3c48eac5-0c4f-f43a-1d76-75399e5fc1b8@gmail.com>
 <CANn89i+sbU7b5CAhRq15Mk021X4afkB5E1ip+FRB4NevOrYJvQ@mail.gmail.com>
 <c192d259-644b-0697-748f-549fdc9c11e0@gmail.com>
 <CANn89iLNvQyfXUZwtQuhXBgZrKCDWEaouVtD4Txaem_wDXrdQg@mail.gmail.com>
 <8ffca63d-62f4-9d6b-fe06-20a0e28dc44d@gmail.com>
 <CANn89iJxk=7qqGyVMwo8p5vFtPLK49JY1eHMwwakOdCE+vnxXA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
        "David S . Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Martin KaFai Lau <kafai@fb.com>,
        Willem de Bruijn <willemb@google.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Alexei Starovoitov <ast@kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:32889 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751276AbdBLRYo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 12 Feb 2017 12:24:44 -0500
Received: by mail-wr0-f196.google.com with SMTP id i10so20867313wrb.0
        for <netdev@vger.kernel.org>; Sun, 12 Feb 2017 09:24:14 -0800 (PST)
In-Reply-To: <CANn89iJxk=7qqGyVMwo8p5vFtPLK49JY1eHMwwakOdCE+vnxXA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 12/02/2017 5:32 PM, Eric Dumazet wrote:
> On Sun, Feb 12, 2017 at 7:04 AM, Tariq Toukan <ttoukan.linux@gmail.com> wrote:
>
>> We consistently see this behavior: the higher the BW, the sharper the
>> degradation.
>>
>> This is because the page-cache is of a fixed-size. Any fixed-size page-cache
>> will always meet one of the following:
>> 1) Too small to keep the pace when load is high.
>> 2) Too big (in terms of memory footprint) when load is low.
>>
> So, we had the order-0 allocations for years at Google, then made the
> horrible mistake to rebase mlx4 driver from the upstream one,
> and we had all these issues under load.
>
> I decided to redo the work I did years ago and upstream it.
Thanks for that. I really appreciate and like your re-factorization.
>
> I have warned Mellanox in the past (for cx-5 driver) that _any_ high
> order allocation strategy was nice in benchmarks, but terrible in face
> of real server workloads.
> ( And I am not even referring to malicious attacks )
In mlx5, we fully completed the transition to order-0 allocations in 
Striding RQ.
> Think about what happens on real servers : In the order of 100,000 TCP
> sockets opened.
>
> Then some incast or outcast problem (Mapreduce jobs are fond of this)
> make thousands of TCP socket accumulate _millions_ of TCP messages in
> their out of order queue per second.
>
> There is no way you can hold millions of pages in mlx4 driver.
> A "dynamic" page pool is going to fail very badly.
I understand your point. Today I am totally aware of the advantages in 
using order-0 pages, I am just trying
to have the bread buttered on both sides, by reducing the allocation 
overhead.
Even though the iperf benchmarks are less realistic than the ones you 
described, I think it is still nice
if we could find solutions for the page allocator in order to keep the 
high rates we had before.
As a common bottleneck, we will always gain by improving the page 
allocator, no matter what is the pages order.

Just two points regarding the dynamic page-cache I implemented:
1) We define an upper limit for the size of the dynamic page-cache, so 
the mata-data do not grow too much.
2) When load is high, our dynamic page-cache _does not exclusively hold 
too many pages_, it just keeps track
     of pages that are being anyway processed in stack. In memory 
footprints accounting, I would not account
     such page into the "driver's footprint", as it is being used by the 
stack.


>
> Sure, your iperf bench will look great. But who cares ? Doyou really
> have customers dedicating hosts to run 1 iperf full time ?
>
> Make sure you run tests with 100,000 TCP sockets, and add networking
> small flaps, with 5% packet losses.
> This is what we really care here.
I definitely agree that benchmarks should improve to reflect more 
realistic use cases.
>
> I will send the v3 of the patch series, I really hope that it will go
> in, because we at Google very much need it ASAP, and I would rather
> not have to keep it private in our tree.
>
> Do not focus on your benchmarks, that is marketing only
> Focus on ability of the servers to _survive_ and continue their work.
>
> You did not answer to my questions by the way.
>
> ethtool -g eth0
> ethtool -l eth0
Yes, sorry the delayed reply, it was sent separately.
>
> Thanks.
