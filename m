From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: Re: [PATCH] net: use hardware buffer pool to allocate skb
Date: Thu, 16 Oct 2014 08:28:19 -0700
Message-ID: <543FE413.6030406@redhat.com>
References: <1413343571-33231-1-git-send-email-Jiafei.Pan@freescale.com>	 <20141015.002514.384962932982389732.davem@davemloft.net>	 <c02005b9d8794d14bc2149f468ab571c@BY2PR03MB524.namprd03.prod.outlook.com>	 <1413364533.12304.44.camel@edumazet-glaptop2.roam.corp.google.com>	 <524626e093684abeba65839d26e94262@BLUPR03MB517.namprd03.prod.outlook.com> <1413432912.28798.7.camel@edumazet-glaptop2.roam.corp.google.com> <aeef795129504782ae1e9f91467d243e@BLUPR03MB517.namprd03.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"jkosina@suse.cz" <jkosina@suse.cz>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"LeoLi@freescale.com" <LeoLi@freescale.com>,
	"linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>
To: "Jiafei.Pan@freescale.com" <Jiafei.Pan@freescale.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <aeef795129504782ae1e9f91467d243e@BLUPR03MB517.namprd03.prod.outlook.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On 10/15/2014 10:15 PM, Jiafei.Pan@freescale.com wrote:
>> -----Original Message-----
>> From: Eric Dumazet [mailto:eric.dumazet@gmail.com]
>> Sent: Thursday, October 16, 2014 12:15 PM
>> To: Pan Jiafei-B37022
>> Cc: David Miller; jkosina@suse.cz; netdev@vger.kernel.org; Li Yang-L=
eo-R58472;
>> linux-doc@vger.kernel.org
>> Subject: Re: [PATCH] net: use hardware buffer pool to allocate skb
>>
>> On Thu, 2014-10-16 at 02:17 +0000, Jiafei.Pan@freescale.com wrote:
>>
>>> Thanks for your comments and suggestion. In my case, I want to buil=
d skb
>>> from hardware block specified memory, I only can see two ways, one =
is modified
>>> net card driver replace common skb allocation function with my spec=
ially
>>> functions, another way is to hack common skb allocation function in=
 which
>>> redirect to my specially functions. My patch is just for the second=
 way.
>>> Except these two ways, would you please give me some advice for som=
e other
>>> ways for my case? Thanks
>> I suggest you read drivers/net/ethernet numerous examples.
>>
>> No need to change anything  in net/* or include/*, really.
>>
>> For a start, look at drivers/net/ethernet/intel/igb/igb_main.c
>>
>> Mentioning 'hack' in your mails simply should hint you are doing
>> something very wrong.
>>
>> What makes you think your hardware is so special ?
>>
> In fact, I am developing a bridge driver, it can bridge between any o=
ther the
> third party net card and my own net card. My target is to let any oth=
er the
> third party net card can directly use my own net card specified buffe=
r, then
> there will be no memory copy in the whole bridge process.
> By the way, I don=E2=80=99t see any similar between igb_main.c and my=
 case. And also
> My bridge also can=E2=80=99t implemented with "skb frag" in order to =
aim at zero memory
> copy.

I think the part you are not getting is that is how buffers are=20
essentially handled now.  So for example in the case if igb the only=20
part we have copied out is usually the header, or the entire frame in=20
the case of small packets.  This has to happen in order to allow for=20
changes to the header for routing and such.  Beyond that the frags that=
=20
are passed are the buffers that igb is still holding onto.  So=20
effectively what the other device transmits in a bridging/routing=20
scenario is my own net card specified buffer plus the copied/modified=20
header.

=46or a brief period igb used build_skb but that isn't valid on most=20
systems as memory mapped for a device can be overwritten if the page is=
=20
unmapped resulting in any changes to the header for routing/bridging=20
purposes being invalidated.  Thus we cannot use the buffers for both th=
e=20
skb->data header which may be changed and Rx DMA simultaneously.

Thanks,

Alex
