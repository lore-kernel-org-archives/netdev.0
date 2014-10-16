From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: Re: [PATCH] net: use hardware buffer pool to allocate skb
Date: Thu, 16 Oct 2014 15:12:37 -0700
Message-ID: <544042D5.5090501@redhat.com>
References: <1413343571-33231-1-git-send-email-Jiafei.Pan@freescale.com>	 <20141015.002514.384962932982389732.davem@davemloft.net>	 <c02005b9d8794d14bc2149f468ab571c@BY2PR03MB524.namprd03.prod.outlook.com>	 <1413364533.12304.44.camel@edumazet-glaptop2.roam.corp.google.com>	 <524626e093684abeba65839d26e94262@BLUPR03MB517.namprd03.prod.outlook.com>	 <1413432912.28798.7.camel@edumazet-glaptop2.roam.corp.google.com>	 <aeef795129504782ae1e9f91467d243e@BLUPR03MB517.namprd03.prod.outlook.com>	 <543FE413.6030406@redhat.com>	 <1413478657.28798.22.camel@edumazet-glaptop2.roam.corp.google.com>	 <543FFC03.1060207@redhat.com>	 <1413481529.28798.29.camel@edumazet-glaptop2.roam.corp.google.com>	 <54400C6C.7010405@redhat.com> <1413495626.28798.38.camel@edumazet-glaptop2.roam.corp.google.com>
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
In-Reply-To: <1413495626.28798.38.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On 10/16/2014 02:40 PM, Eric Dumazet wrote:
> On Thu, 2014-10-16 at 11:20 -0700, Alexander Duyck wrote:
>
>> My concern would be that we are off by a factor of 2 and prematurely
>> collapse the TCP too soon with this change.
> That is the opposite actually. We can consume 4K but we pretend we
> consume 2K in some worst cases.

The only case where we consume the full 4K but only list it as 2K should 
be if we have memory from the wrong node and we want to flush it from 
the descriptor queue.  For all other cases we should be using the page 
at least twice per buffer.  So the the first page that was assigned for 
an Rx descriptor might be flushed but then after that reuse should take 
hold and stay in place as long as the NAPI poll doesn't change NUMA nodes.

That should be no worse than the case where the remaining space in a 
large page is not large enough to use as a buffer. You still use the 
current size as your truesize, you don't include the overhead of the 
unused space in your calculation.

>>   For example if you are
>> looking at a socket that is holding pages for a long period of time
>> there would be a good chance of it ending up with both halves of the
>> page.  In this case is it fair to charge it for 8K or memory use when in
>> reality it is only using 4K?
> Its better to collapse too soon than too late.
>
> If you want to avoid collapses because one host has plenty of memory,
> all you need to do is increase tcp_rmem.
>
> Why are you referring to 8K ? PAGE_SIZE is 4K

The truesize would be reported as 8K vs 4K for 2 half pages with your 
change if we were to hand off both halves of a page to the same socket.

The 2K value makes sense and is consistent with how we handle this in 
other cases where we are partitioning pages for use as network buffers.  
I think increasing this to 4K is just going to cause performance issues 
as flows are going to get choked off prematurely for memory usage that 
they aren't actually getting.

Part of my hesitation is that I spent the last couple of years 
explaining to our performance testing team and customers that they need 
to adjust tcp_rmem with all of the changes that have been made to 
truesize and the base network drivers, and I think I would prefer it if 
I didn't have to go another round of it.  Then again I probably won't 
have to anyway since I am not doing drivers for Intel any more, but 
still my reaction to this kind of change is what it is.

Thanks,

Alex




