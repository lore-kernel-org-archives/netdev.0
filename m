From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: Re: [PATCH] net: use hardware buffer pool to allocate skb
Date: Fri, 17 Oct 2014 11:28:58 -0700
Message-ID: <54415FEA.5000705@redhat.com>
References: <1413343571-33231-1-git-send-email-Jiafei.Pan@freescale.com>	 <20141015.002514.384962932982389732.davem@davemloft.net>	 <c02005b9d8794d14bc2149f468ab571c@BY2PR03MB524.namprd03.prod.outlook.com>	 <1413364533.12304.44.camel@edumazet-glaptop2.roam.corp.google.com>	 <524626e093684abeba65839d26e94262@BLUPR03MB517.namprd03.prod.outlook.com>	 <1413432912.28798.7.camel@edumazet-glaptop2.roam.corp.google.com>	 <aeef795129504782ae1e9f91467d243e@BLUPR03MB517.namprd03.prod.outlook.com>	 <543FE413.6030406@redhat.com>	 <1413478657.28798.22.camel@edumazet-glaptop2.roam.corp.google.com>	 <543FFC03.1060207@redhat.com>	 <1413481529.28798.29.camel@edumazet-glaptop2.roam.corp.google.com>	 <54400C6C.7010405@redhat.com>	 <063D6719AE5E284EB5DD2968C1650D6D1C9D895B@AcuExch.aculab.com>	 <54412A59.707050
 8@redhat.com> <1413564913.24709.7.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Laight <David.Laight@ACULAB.COM>,
	"Jiafei.Pan@freescale.com" <Jiafei.Pan@freescale.com>,
	David Miller <davem@davemloft.net>,
	"jkosina@suse.cz" <jkosina@suse.cz>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"LeoLi@freescale.com" <LeoLi@freescale.com>,
	"linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1413564913.24709.7.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On 10/17/2014 09:55 AM, Eric Dumazet wrote:
> On Fri, 2014-10-17 at 07:40 -0700, Alexander Duyck wrote:
>> On 10/17/2014 02:11 AM, David Laight wrote:
>>> From: Alexander Duyck
>>> ...
>>>> Actually the likelihood of anything holding onto the 4K page for very
>>>> long doesn't seem to occur, at least from the drivers perspective.  It
>>>> is one of the reasons why I went for the page reuse approach rather than
>>>> just partitioning a single large page.  It allows us to avoid having to
>>>> call IOMMU map/unmap for the pages since the entire page is usually back
>>>> in the driver ownership before we need to reuse the portion given to the
>>>> stack.
>>> That is almost certainly true for most benchmarks, benchmark processes
>>> consume receive data.
>>> But what about real life situations?
>>>
>>> There must be some 'normal' workloads where receive data doesn't get consumed.
>>>
>>> 	David
>>>
>> Yes, but for workloads where receive data doesn't get consumed it is
>> very unlikely that much receive data is generated.
> This is very optimistic.
>
> Any kind of flood can generate 5 or 6 Million packets per second.

That is fine.  The first 256 (default descriptor ring size) might be 4K 
while reporting truesize of 2K, after that each page is guaranteed to be 
split in half so we get at least 2 uses per page.

> So in stress condition, we possibly consume twice more ram than alloted
> in tcp_mem.  (About 3GBytes per second, think about it)

I see what you are trying to get at, but I don't see how my scenerio is 
worse then the setups that use a large page and partition it.

> This is fine, if admins are aware of that and can adjust tcp_mem
> accordingly to this.

I can say I have never had a single report of of us feeding too much 
memory to the sockets, if anything the complaints I have seen have 
always been that the socket is being starved due to too much memory 
being used to move small packets.  That is one of the reasons I decided 
we had to have a copy-break built in for packets 256B and smaller.  It 
doesn't make much sense to allocate 2K + ~1K (skb + skb->head) for 256B 
or less of payload data.

> Apparently none of your customers suffered from this, maybe they had
> enough headroom to absorb the over commit or they trusted us and could not
> find culprit if they had issues.

Correct.  I've never received complaints about memory overcommit. Like I 
have said in most cases we are always getting the page back anyway so we 
usually get a good ROI on the page recycling.

> Open 50,000 tcp sockets, do not read data on 50% of them (pretend you
> are busy on disk access or doing cpu intensive work). As traffic is interleaved
> (between consumed data and non consumed data), you'll have the side
> effect of consuming more ram than advertised.

Yes, but in the case we are talking about it is only off by a factor of 
2.  How do you account for the setups such as the code for allocating an 
skb that is allocating a 32K page over multiple frames. In your setup I 
would suspect it wouldn't be uncommon for the socket to end up with 
multiple spots where only a few sockets are holding the entire 32K page 
for some period of time.  So does that mean we should hit anybody that 
uses netdev_alloc_skb with the overhead for 32K since there are 
scenarios where that can happen?

> Compare /proc/net/protocols (grep TCP /proc/net/protocols) and output of
> 'free', and you'll see that we are not good citizens.

I'm assuming there is some sort of test I should be running while I do 
this?  Otherwise the current dump of those is not too interesting 
currently because my system is idle.

> I will work on TCP stack, to go beyond what I did in commit
> b49960a05e3212 ("tcp: change tcp_adv_win_scale and tcp_rmem[2]")
>
> So that TCP should not care if a driver chose to potentially use 4K per
> MSS.

So long as it doesn't impact performance significantly I am fine with 
it.  My concern is that you are bringing up issues that none of the 
customers were brining up when I was at Intel, and the fixes you are 
proposing are likely to result in customers seeing things they will 
report as issues.

> Right now, it seems we can drop few packets, and get a slight reduction in
> throughput (TCP is very sensitive to losses, even if we drop 0.1 % of packets)

Yes, I am well aware of this bit.  That is my concern.  You increase the 
size for truesize, it will cut the amount of queueing in half, and then 
igb will start seeing drops when it has to deal with bursty traffic and 
people will start to complain about a performance regression.  That is 
the bit I want to avoid.

Thanks,

Alex

