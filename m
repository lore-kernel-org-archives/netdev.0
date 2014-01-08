From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH net-next V2 1/3] net: Add GRO support for UDP encapsulating
 protocols
Date: Wed, 8 Jan 2014 10:02:46 +0200
Message-ID: <52CD0626.9030001@mellanox.com>
References: <1389108594-665-1-git-send-email-ogerlitz@mellanox.com>	<1389108594-665-2-git-send-email-ogerlitz@mellanox.com>	<1389112433.26646.28.camel@edumazet-glaptop2.roam.corp.google.com>	<CAJZOPZ+q=uc4Svia+dFHrQfYyfJfsSVmqH1avJ99f4O0ES3QoQ@mail.gmail.com>	<1389126735.26646.65.camel@edumazet-glaptop2.roam.corp.google.com>	<CAJZOPZ+b87xF8m7cgTfwH1OqA3k012YFVy0ySJasMuR6x38Czw@mail.gmail.com> <CAPshTCiFf=vpsw7D_pX5c=NTpg04+fi5u6M9byfQiszOU+qRzw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Yan Burman <yanb@mellanox.com>,
	Shlomo Pongratz <shlomop@mellanox.com>
To: Jerry Chu <hkchu@google.com>, Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog104.obsmtp.com ([207.126.144.117]:39801 "EHLO
	eu1sys200aog104.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755730AbaAHIDA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jan 2014 03:03:00 -0500
In-Reply-To: <CAPshTCiFf=vpsw7D_pX5c=NTpg04+fi5u6M9byfQiszOU+qRzw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/01/2014 00:11, Jerry Chu wrote:
> On Tue, Jan 7, 2014 at 12:37 PM, Or Gerlitz <or.gerlitz@gmail.com> wrote:
>> On Tue, Jan 7, 2014 at 10:32 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>>> On Tue, 2014-01-07 at 22:19 +0200, Or Gerlitz wrote:
>>>> On Tue, Jan 7, 2014 at 6:33 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>>>>> On Tue, 2014-01-07 at 17:29 +0200, Or Gerlitz wrote:
>>>>>> +
>>>>>> +#define MAX_UDP_PORT (1 << 16)
>>>>>> +extern const struct net_offload __rcu *udp_offloads[MAX_UDP_PORT];
>>>>> Thats 512 KB of memory.
>>>>> This will greatly impact forwarding performance of UDP packets with
>>>>> random ports, and will increase kernel memory size for embedded devices.
>>>> Re forwarding, are you referring to the case where the forwarded
>>>> packets are encapsulated? packets which are not encapusalted will be
>>>> flushed in the gro receive handler (this went out by mistake in V2 but
>>>> exists in V1)  if skb->encapsulation isn't set.
>>>>
>>> How do you know encapsulation must be tried for a given incoming
>>> packet ? NIC do not magically sets skb->encapsulation I think...
>> So here's the thing, per my understanding we want to GRO only received
>> **encapsulated** packets whose checksum status is != CHECKSUM_NONE
> What's wrong with GRO'ing pkts whose csum == CHECKSUM_NONE?

I am not sure, intuitively it sounds a bit wrong to me, empirically, it 
doesn't work for udp encapsulated  / vxlan
traffic, I got drops from the tcp stack in tcp_rcv_established() -- if  
GRO-ed packets carry CHECKSUM_NONE
we arrive to the csum_error label, which means that 
tcp_checksum_complete_user() failed for them


> Also "udp_offload" is a little misleading - you are not trying to GRO UDP
> pkts where UDP is the real transport. You are only trying to GRO UDP encapped TCP pkts.

Indeed -- however, I just plugged into what was there for GSO, e.g stack 
will not do GSO for plain UDP
packets, only for those who encapsulate something the code that does 
this is udp_offloads.c -- any suggestion
how to phrase/frame the change you envision?


>
