From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH net-next V2 1/3] net: Add GRO support for UDP encapsulating
 protocols
Date: Thu, 9 Jan 2014 08:35:07 +0200
Message-ID: <52CE431B.6010109@mellanox.com>
References: <1389108594-665-1-git-send-email-ogerlitz@mellanox.com>	<1389108594-665-2-git-send-email-ogerlitz@mellanox.com>	<1389112433.26646.28.camel@edumazet-glaptop2.roam.corp.google.com>	<CAJZOPZ+q=uc4Svia+dFHrQfYyfJfsSVmqH1avJ99f4O0ES3QoQ@mail.gmail.com>	<1389126735.26646.65.camel@edumazet-glaptop2.roam.corp.google.com>	<CAJZOPZ+b87xF8m7cgTfwH1OqA3k012YFVy0ySJasMuR6x38Czw@mail.gmail.com>	<CAPshTCiFf=vpsw7D_pX5c=NTpg04+fi5u6M9byfQiszOU+qRzw@mail.gmail.com>	<52CD0626.9030001@mellanox.com> <CAPshTChSSB8mycXMXSJ656tpBGDqyjUF37+V2S2eAPQs47gJ2A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Yan Burman <yanb@mellanox.com>,
	Shlomo Pongratz <shlomop@mellanox.com>
To: Jerry Chu <hkchu@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog113.obsmtp.com ([207.126.144.135]:38644 "EHLO
	eu1sys200aog113.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751135AbaAIGfQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 01:35:16 -0500
In-Reply-To: <CAPshTChSSB8mycXMXSJ656tpBGDqyjUF37+V2S2eAPQs47gJ2A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/01/2014 05:12, Jerry Chu wrote:
> On Wed, Jan 8, 2014 at 12:02 AM, Or Gerlitz <ogerlitz@mellanox.com> wrote:
>> On 08/01/2014 00:11, Jerry Chu wrote:
>>> On Tue, Jan 7, 2014 at 12:37 PM, Or Gerlitz <or.gerlitz@gmail.com> wrote:
>>>> On Tue, Jan 7, 2014 at 10:32 PM, Eric Dumazet <eric.dumazet@gmail.com>
>>>> wrote:
>>>>> On Tue, 2014-01-07 at 22:19 +0200, Or Gerlitz wrote:
>>>>>> On Tue, Jan 7, 2014 at 6:33 PM, Eric Dumazet <eric.dumazet@gmail.com>
>>>>>> wrote:
>>>>>>> On Tue, 2014-01-07 at 17:29 +0200, Or Gerlitz wrote:
>>>>>>>> +
>>>>>>>> +#define MAX_UDP_PORT (1 << 16)
>>>>>>>> +extern const struct net_offload __rcu *udp_offloads[MAX_UDP_PORT];
>>>>>>> Thats 512 KB of memory.
>>>>>>> This will greatly impact forwarding performance of UDP packets with
>>>>>>> random ports, and will increase kernel memory size for embedded
>>>>>>> devices.
>>>>>> Re forwarding, are you referring to the case where the forwarded
>>>>>> packets are encapsulated? packets which are not encapusalted will be
>>>>>> flushed in the gro receive handler (this went out by mistake in V2 but
>>>>>> exists in V1)  if skb->encapsulation isn't set.
>>>>>>
>>>>> How do you know encapsulation must be tried for a given incoming
>>>>> packet ? NIC do not magically sets skb->encapsulation I think...
>>>> So here's the thing, per my understanding we want to GRO only received
>>>> **encapsulated** packets whose checksum status is != CHECKSUM_NONE
>>> What's wrong with GRO'ing pkts whose csum == CHECKSUM_NONE?
>>
>> I am not sure, intuitively it sounds a bit wrong to me, empirically, it
>> doesn't work for udp encapsulated  / vxlan
>> traffic, I got drops from the tcp stack in tcp_rcv_established() -- if
>> GRO-ed packets carry CHECKSUM_NONE
>> we arrive to the csum_error label, which means that
>> tcp_checksum_complete_user() failed for them
> This is odd because if pkts have been aggregated successfully,
> tcp4_gro_receive() should've skb_checksum() and turned CHECKSUM_NONE
> into CHECKSUM_UNNECESSARY. (I think i've already tested this
> case with my GRE-GRO patch on a NIC that sends up pkts w/ CHECKSUM_NONE.
>
> But granted there are a lot of csum related bugs in the current code. I just spent half a day scratching my head on a very low thruput number with my GRE patch over a GRE tunnel w/ csum flag on. I just tracked it down to be buggy TSO/GRE code that will produce bad csum on the tx side.

The "there are a lot of csum related bugs in the current code" comment 
sounds really bad, how do we get into a better place? can you point on 
the buggy TSO code that produced bad csum on the tx side?
