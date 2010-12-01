From: Rui <wirelesser@gmail.com>
Subject: Re: multi bpf filter will impact performance?
Date: Wed, 1 Dec 2010 11:48:46 +0800
Message-ID: <AANLkTi=-iuGJDzELJpu26KtKr77uDx0xNCc8ibEidJ4h@mail.gmail.com>
References: <AANLkTikx68M43+vv+Rav_HCJMJnuc15TtuBgmbv2xP=U@mail.gmail.com>
	<1291109699.2904.11.camel@edumazet-laptop>
	<AANLkTi=VpmnrXTBNV7McQm6mq9ULT7KTKbM8_hLPoL=2@mail.gmail.com>
	<1291127670.2904.96.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:61718 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754536Ab0LADsr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Nov 2010 22:48:47 -0500
Received: by pva4 with SMTP id 4so998064pva.19
        for <netdev@vger.kernel.org>; Tue, 30 Nov 2010 19:48:46 -0800 (PST)
In-Reply-To: <1291127670.2904.96.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 30, 2010 at 10:34 PM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> Le mardi 30 novembre 2010 =E0 22:21 +0800, Rui a =E9crit :
>
>> does it mean each incoming packet will issue a softirq?
>
> Hmm, if your machine is loaded, one cpu is probably looping inside
> ksoftirqd. You can probably check with "top" command.
>
>> possible to know the corresponding sock,then to run only one filter?
>>
>
> We could add a SKF_AD_CPU filter, thats a couple of lines ;)
>
> tcpdump =A0 .... "cpu 0 and udp ..."
>
>> >
>> >> Q2. performance is bad? any idea to improve it?
>> >>
>> >
>> > multiqueue card : split each IRQ on a separate cpu.
>> >
>> > If not multiqueue card : use RPS on a recent kernel to split the l=
oad on
>> > several cpus.
>> >
>> > Use a filter against the queue, instead of doing a hash code yours=
elf in
>> > the bpf. (code added in commit d19742fb (linux-2.6.33)
>> >
>> > (you need to tweak libpcap to use SKF_AD_QUEUE instruction)
>> >
>> > commit d19742fb1c68e6db83b76e06dea5a374c99e104f
>> > Author: Eric Dumazet <eric.dumazet@gmail.com>
>> > Date: =A0 Tue Oct 20 01:06:22 2009 -0700
>> >
>> > =A0 =A0filter: Add SKF_AD_QUEUE instruction
>> >
>> > =A0 =A0It can help being able to filter packets on their queue_map=
ping.
>> >
>> > =A0 =A0If filter performance is not good, we could add a "numqueue=
" field
>> > =A0 =A0in struct packet_type, so that netif_nit_deliver() and othe=
r functions
>> > =A0 =A0can directly ignore packets with not expected queue number.
>> >
>> > =A0 =A0Lets experiment this simple filter extension first.
>> >
>> >
>> >
>> >
>> >
>> >
>> yes, I will try SKF_AD_QUEUE =A0with kernel 2.6.33.
>>
>> and I am testing the performance when traffic falls at the same
>> rx-queue (same src ip and dst ip traffic),
>> in this situation,I need to find another way to hash the traffic.
>
> Hmm, in this case, all trafic is handled by one cpu in ksoftirqd.
> and RPS wont be able to help you, since the skb hash will be the same
> for all packets.
>
> It would need a change in __skb_get_rxhash() to compute rxhash with t=
he
> hash you use =A0(if udp dest port is 2152, then use ether[66-73] or
> ether[62-69] as the jhash parameter, while we currently only use udp
> addr/port information to compute the rxhash)
>
> Then, you could use RPS to spread the load into 4 separate cpus.
>
>
>
>
one more question is

if  RPS can spread the load into 4 separate cpus, how about the
"packet_rcv(or tpacket_rcv)" ? will they run in parallel?

as I use 'tcpdump(PACKET_MMAP)' to copy the packet to user space, I
expect there are simultaneous packet_rcv running in each CPU to put
the packet into ringbuffer.

thank you
rui
