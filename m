From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: Re: [PATCH] net: use hardware buffer pool to allocate skb
Date: Fri, 17 Oct 2014 15:13:29 -0700
Message-ID: <54419489.4040007@redhat.com>
References: <1413343571-33231-1-git-send-email-Jiafei.Pan@freescale.com>	 <1413364533.12304.44.camel@edumazet-glaptop2.roam.corp.google.com>	 <524626e093684abeba65839d26e94262@BLUPR03MB517.namprd03.prod.outlook.com>	 <1413432912.28798.7.camel@edumazet-glaptop2.roam.corp.google.com>	 <aeef795129504782ae1e9f91467d243e@BLUPR03MB517.namprd03.prod.outlook.com>	 <543FE413.6030406@redhat.com>	 <1413478657.28798.22.camel@edumazet-glaptop2.roam.corp.google.com>	 <543FFC03.1060207@redhat.com>	 <1413481529.28798.29.camel@edumazet-glaptop2.roam.corp.google.com>	 <54400C6C.7010405@redhat.com>	 <063D6719AE5E284EB5DD2968C1650D6D1C9D895B@AcuExch.aculab.com>	 <54412A59.7070508@redhat.com>	 <1413564913.24709.7.camel@edumazet-glaptop2.roam.corp.google.com>	 <54415FEA.5000705@redhat.com>	 <1413572539.25949.17
 .camel@edumazet-glaptop2.roam.corp.google.com>	 <54417044.5090602@gmail.com> <1413575515.27176.10.camel@edumazet-glaptop2.roam.corp.google.com>
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
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1413575515.27176.10.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On 10/17/2014 12:51 PM, Eric Dumazet wrote:
> On Fri, 2014-10-17 at 12:38 -0700, Alexander Duyck wrote:
>
>> That's not what I am saying, but there is a trade-off we always have to
>> take into account.  Cutting memory overhead will likely have an impact
>> on performance.  I would like to make the best informed trade-off in
>> that regard rather than just assuming worst case always for the driver.
> It seems you misunderstood me. You believe I suggested doing another
> allocation strategy in the drivers.
>
> This was not the case.
>
> This allocation strategy is wonderful. I repeat : This is wonderful.

No, I think I understand you.  I'm just not sure listing this as a 4K 
allocation in truesize makes sense.  The problem is the actual 
allocation can be either 2K or 4K, and my concern is that by setting it 
to 4K we are going to be hurting the case where the actual allocation to 
the socket is only 2K for the half page w/ reuse.

I was brining up the other allocation strategy to prove a point. From my 
perspective it wouldn't make any more sense to assign 32K to the 
truesize for an allocated fragment using __netdev_alloc_frag, but it can 
suffer the same type of issues only to a greater extent due to the use 
of the compound page.  Just because it is shared among many more uses 
doesn't mean it couldn't end up in a scenario where one socket somehow 
keeps queueing up the 32K pages and sitting on them.  I would think all 
it would take is 1 bad acting flow interleaved in ~20 active flows to 
suddenly gobble up a ton of memory without it being accounted for.

> We only have to make sure we do not fool memory management layers, when
> they do not understand where the memory is.
>
> Apparently you think it is hard, while it really is not.

I think you are over simplifying it.  By setting it to 4K there are 
situations where a socket will be double charged for getting two halves 
of the same page.  In these cases there will be a negative impact on 
performance as the number of frames that can be queued is reduced.  What 
you are proposing is possibly overreporting memory use by a factor of 2 
instead of possibly under-reporting it by a factor of 2.

I would be more moved by data than just conjecture on what the driver is 
or isn't doing.  My theory is that most of the time the page is reused 
so 2K is the correct value to report, and very seldom would 4K ever be 
the correct value.  This is what I have seen historically with igb/ixgbe 
using the page reuse.  If you have cases that show that the page isn't 
being reused then we can explore the 4K truesize change, but until then 
I think the page is likely being reused and we should probably just 
stick with the 2K value as we should be getting at least 2 uses per page.

Thanks,

Alex

