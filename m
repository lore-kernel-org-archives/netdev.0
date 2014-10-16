From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: Re: [PATCH] net: use hardware buffer pool to allocate skb
Date: Thu, 16 Oct 2014 11:20:28 -0700
Message-ID: <54400C6C.7010405@redhat.com>
References: <1413343571-33231-1-git-send-email-Jiafei.Pan@freescale.com>	 <20141015.002514.384962932982389732.davem@davemloft.net>	 <c02005b9d8794d14bc2149f468ab571c@BY2PR03MB524.namprd03.prod.outlook.com>	 <1413364533.12304.44.camel@edumazet-glaptop2.roam.corp.google.com>	 <524626e093684abeba65839d26e94262@BLUPR03MB517.namprd03.prod.outlook.com>	 <1413432912.28798.7.camel@edumazet-glaptop2.roam.corp.google.com>	 <aeef795129504782ae1e9f91467d243e@BLUPR03MB517.namprd03.prod.outlook.com>	 <543FE413.6030406@redhat.com>	 <1413478657.28798.22.camel@edumazet-glaptop2.roam.corp.google.com>	 <543FFC03.1060207@redhat.com> <1413481529.28798.29.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Jiafei.Pan@freescale.com" <Jiafei.Pan@freescale.com>,
	David Miller <davem@davemloft.net>,
	"jkosina@suse.cz" <jkosina@suse.cz>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"LeoLi@freescale.com" <LeoLi@freescale.com>,
	"linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1413481529.28798.29.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On 10/16/2014 10:45 AM, Eric Dumazet wrote:
> On Thu, 2014-10-16 at 10:10 -0700, Alexander Duyck wrote:
>
>> So if a page is used twice we are double counting the page size for the
>> socket then, is that correct?  I just want to make sure because prior to
>> this patch both flows did the same thing and counted the portion of the
>> page used in this pass, now with this change for PAGE_SIZE of 4K we
>> count the entire page, and for all other cases we count the portion of
>> the page used.
> When a page is split in 2 parts only, probability that a segment holds
> the 4K page is quite high (There is a single half page)

Actually the likelihood of anything holding onto the 4K page for very 
long doesn't seem to occur, at least from the drivers perspective.  It 
is one of the reasons why I went for the page reuse approach rather than 
just partitioning a single large page.  It allows us to avoid having to 
call IOMMU map/unmap for the pages since the entire page is usually back 
in the driver ownership before we need to reuse the portion given to the 
stack.

> When we split say 64KB in 42 segments, the probability a single segment
> hold the full 64KB block is very low, so we can almost be safe when we
> consider 'truesize = 1536'

Yes, but the likelihood that only a few segments are holding the page is 
still very high.  So you might not have one segment holding the 64K 
page, but I find it very difficult to believe that all 42 would be 
holding it at the same time.  In that case should we be adding some 
portion of the 64K to the truesize for all frames to account for this?

> Of course there are pathological cases, but attacker has to be quite
> smart.
>
> I am just saying that counting 2048 might have a big impact on memory
> consumption if all these incoming segments are stored a long time in
> receive queues (TCP receive queues or out of order queues) : We might be
> off by a factor of 2 on the real memory usage, and delay the TCP
> collapsing too much.

My concern would be that we are off by a factor of 2 and prematurely 
collapse the TCP too soon with this change.  For example if you are 
looking at a socket that is holding pages for a long period of time 
there would be a good chance of it ending up with both halves of the 
page.  In this case is it fair to charge it for 8K or memory use when in 
reality it is only using 4K?

Thanks,

Alex

