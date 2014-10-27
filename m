From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH net-next 2/2] udp: Reset flow table for flows over
 unconnected sockets
Date: Mon, 27 Oct 2014 12:36:31 -0700
Message-ID: <CA+mtBx_V3WT1bbXY9F731GNdDdb3+ebHwj9hRyVEFynAPYhSXg@mail.gmail.com>
References: <1414432875-23795-1-git-send-email-therbert@google.com>
	<1414432875-23795-2-git-send-email-therbert@google.com>
	<1414435437.32624.1.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f177.google.com ([209.85.223.177]:37445 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753087AbaJ0Tgc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Oct 2014 15:36:32 -0400
Received: by mail-ie0-f177.google.com with SMTP id tp5so5065641ieb.22
        for <netdev@vger.kernel.org>; Mon, 27 Oct 2014 12:36:31 -0700 (PDT)
In-Reply-To: <1414435437.32624.1.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 27, 2014 at 11:43 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Mon, 2014-10-27 at 11:01 -0700, Tom Herbert wrote:
>> When receiving a packet on an unconnected UDP socket clear the
>> flow table for the corresponding hash. This is needed so flows over
>> unconnected UDP sockets will use RPS instead of using what is
>> present in the flow table. In particular, this avoids having flows
>> over unconnected sockets be perpetually steered by unrelated
>> entries in the flow table (idle TCP connections for instance).
>>
>> Tested:
>>
>> First filled up the RPS flow tables by creating a bunch of TCP
>> connections and letting them turn idle. Next, run netperf UDP_RR
>> with 200 flows.
>>
>> Before fix:
>>   Client (connected UDP)
>>     81.15% CPU uilization
>>   Server (unneconnedted UDP)
>>     83.63% CPU uilization
>>   118/167/249 90/95/99% latencies
>>   1.59215e+06 tps
>>
>> After fix:
>>   Client (connected UDP)
>>     81.13% CPU uilization
>>   Server (unneconnedted UDP)
>>     80.68% CPU uilization
>>   116/167/248 90/95/99% latencies
>>   1.61048e+06 tps
>>
>> Signed-off-by: Tom Herbert <therbert@google.com>
>> ---
>>  net/ipv4/udp.c | 5 +++++
>>  1 file changed, 5 insertions(+)
>>
>> diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
>> index 9a0d346..e58d841 100644
>> --- a/net/ipv4/udp.c
>> +++ b/net/ipv4/udp.c
>> @@ -1451,6 +1451,11 @@ static int __udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
>>       if (inet_sk(sk)->inet_daddr) {
>>               sock_rps_save_rxhash(sk, skb);
>>               sk_mark_napi_id(sk, skb);
>> +     } else {
>> +             /* For an unconnected socket reset flow hash so that related
>> +              * flow will use RPS.
>> +              */
>> +             sock_rps_reset_flow_hash(skb->hash);
>>       }
>
> I believe I already said this patch was wrong Tom.
>
> We need something else for UDP packets.
>
> Its not because RFS is wrong for UDP packets that we want to make it
> worse for TCP traffic.
>
Please try this patch and provide real data to support your points.

> We do now want UDP packets to gradually make flow table empty.

If a TCP connection is hot it will continually refresh the table for
that connection, if connection becomes idle it only takes one received
packet to restore the CPU. The only time there could be a persistent
problem is if collision rate is high (which probably means table is
too small).

>
>
>
>
