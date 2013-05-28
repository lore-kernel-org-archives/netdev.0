From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: Re: [PATCH v5 net-next 3/5] tcp: add TCP support for low latency
 receive poll.
Date: Tue, 28 May 2013 11:26:09 +0300
Message-ID: <51A46A21.9060305@linux.intel.com>
References: <20130527074351.29882.51106.stgit@ladj378.jer.intel.com>  <20130527074421.29882.73968.stgit@ladj378.jer.intel.com> <1369701413.3301.506.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	e1000-devel@lists.sourceforge.net,
	Willem de Bruijn <willemb@google.com>,
	Andi Kleen <andi@firstfloor.org>, HPA <hpa@zytor.com>,
	Eilon Greenstien <eilong@broadcom.com>,
	Or Gerlitz <or.gerlitz@gmail.com>,
	Alex Rosenbaum <alexr@mellanox.com>,
	Eliezer Tamir <eliezer@tamir.org.il>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Dave Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1369701413.3301.506.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 28/05/2013 03:36, Eric Dumazet wrote:
> On Mon, 2013-05-27 at 10:44 +0300, Eliezer Tamir wrote:
>> adds busy-poll support for TCP.
>>
>
> Really, this is a small changelog for such an addition :(

OK


> How poll()/epoll() is supported ?

poll()/select() are done by the code added to fs/select.c in 2/5.
epoll() is not yet supported.

>> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
>> index 9579e1a..4d82939 100644
>> --- a/net/ipv4/tcp_input.c
>> +++ b/net/ipv4/tcp_input.c
>> @@ -74,6 +74,7 @@
>>   #include <linux/ipsec.h>
>>   #include <asm/unaligned.h>
>>   #include <net/netdma.h>
>> +#include <net/ll_poll.h>
>>
>
> Not sure why this include is needed in this file ?
>
> You added nothing else but this line.

This is a mistake, a remnant from an earlier version when sk_mark_ll() 
was where we copy data to the socket.
I will remove it.

>>   #include <net/netdma.h>
>>   #include <net/secure_seq.h>
>>   #include <net/tcp_memcontrol.h>
>> +#include <net/ll_poll.h>
>>
>>   #include <linux/inet.h>
>>   #include <linux/ipv6.h>
>> @@ -2011,6 +2012,7 @@ process:
>>   	if (sk_filter(sk, skb))
>>   		goto discard_and_relse;
>>
>> +	sk_mark_ll(sk, skb);
>>   	skb->dev = NULL;
>>
>>   	bh_lock_sock_nested(sk);
>
> How IPv6 is handled ?

IPv6 is currently not supported (it was not supported in any version of
this patch set, the POC code in fact was hard-codded for UDPv4/TCPv4).

If there is interest, I will add it, I think it will not be complicated.
However, I would prefer to wait with that for a second stage.

My main concern is that adding IPv6 will significantly increase my
  testing effort, which is already 90% of what I'm spending time on.

IMHO epoll() and a more robust support for select()/poll() should have
a higher priority, but I'm open to suggestions.

I would like to get what we have so far applied so more people can try
it, then work on all of the other things that we need.

Dave, I would like to hear your opinion on this, please.

-Eliezer
