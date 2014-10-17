From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: use hardware buffer pool to allocate skb
Date: Fri, 17 Oct 2014 09:55:13 -0700
Message-ID: <1413564913.24709.7.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1413343571-33231-1-git-send-email-Jiafei.Pan@freescale.com>
	 <20141015.002514.384962932982389732.davem@davemloft.net>
	 <c02005b9d8794d14bc2149f468ab571c@BY2PR03MB524.namprd03.prod.outlook.com>
	 <1413364533.12304.44.camel@edumazet-glaptop2.roam.corp.google.com>
	 <524626e093684abeba65839d26e94262@BLUPR03MB517.namprd03.prod.outlook.com>
	 <1413432912.28798.7.camel@edumazet-glaptop2.roam.corp.google.com>
	 <aeef795129504782ae1e9f91467d243e@BLUPR03MB517.namprd03.prod.outlook.com>
	 <543FE413.6030406@redhat.com>
	 <1413478657.28798.22.camel@edumazet-glaptop2.roam.corp.google.com>
	 <543FFC03.1060207@redhat.com>
	 <1413481529.28798.29.camel@edumazet-glaptop2.roam.corp.google.com>
	 <54400C6C.7010405@redhat.com>
	 <063D6719AE5E284EB5DD2968C1650D6D1C9D895B@AcuExch.aculab.com>
	 <54412A59.7070508@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Laight <David.Laight@ACULAB.COM>,
	"Jiafei.Pan@freescale.com" <Jiafei.Pan@freescale.com>,
	David Miller <davem@davemloft.net>,
	"jkosina@suse.cz" <jkosina@suse.cz>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"LeoLi@freescale.com" <LeoLi@freescale.com>,
	"linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <54412A59.7070508@redhat.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Fri, 2014-10-17 at 07:40 -0700, Alexander Duyck wrote:
> On 10/17/2014 02:11 AM, David Laight wrote:
> > From: Alexander Duyck
> > ...
> >> Actually the likelihood of anything holding onto the 4K page for very
> >> long doesn't seem to occur, at least from the drivers perspective.  It
> >> is one of the reasons why I went for the page reuse approach rather than
> >> just partitioning a single large page.  It allows us to avoid having to
> >> call IOMMU map/unmap for the pages since the entire page is usually back
> >> in the driver ownership before we need to reuse the portion given to the
> >> stack.
> > That is almost certainly true for most benchmarks, benchmark processes
> > consume receive data.
> > But what about real life situations?
> >
> > There must be some 'normal' workloads where receive data doesn't get consumed.
> >
> > 	David
> >
> 
> Yes, but for workloads where receive data doesn't get consumed it is 
> very unlikely that much receive data is generated. 

This is very optimistic.

Any kind of flood can generate 5 or 6 Million packets per second.

So in stress condition, we possibly consume twice more ram than alloted
in tcp_mem.  (About 3GBytes per second, think about it)

This is fine, if admins are aware of that and can adjust tcp_mem
accordingly to this.

Apparently none of your customers suffered from this, maybe they had
enough headroom to absorb the over commit or they trusted us and could not
find culprit if they had issues.

Open 50,000 tcp sockets, do not read data on 50% of them (pretend you
are busy on disk access or doing cpu intensive work). As traffic is interleaved
(between consumed data and non consumed data), you'll have the side
effect of consuming more ram than advertised.

Compare /proc/net/protocols (grep TCP /proc/net/protocols) and output of
'free', and you'll see that we are not good citizens.

I will work on TCP stack, to go beyond what I did in commit
b49960a05e3212 ("tcp: change tcp_adv_win_scale and tcp_rmem[2]")

So that TCP should not care if a driver chose to potentially use 4K per
MSS.

Right now, it seems we can drop few packets, and get a slight reduction in
throughput (TCP is very sensitive to losses, even if we drop 0.1 % of packets)


