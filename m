From: =?UTF-8?B?S3J6eXN6dG9mIE9sxJlkemtp?= <ole@ans.pl>
Subject: Re: bnx2/BCM5709: why 5 interrupts on a 4 core system (2.6.33.3)
Date: Sun, 16 May 2010 23:12:34 +0200
Message-ID: <4BF05FC2.4020804@ans.pl>
References: <C27F8246C663564A84BB7AB3439772421B7814753A@IRVEXCHCCR01.corp.ad.broadcom.com>	 <1274040928.2299.17.camel@edumazet-laptop>  <4BF056F0.8010008@ans.pl> <1274042826.2299.26.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Michael Chan <mchan@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([195.187.34.71]:47254 "EHLO
	bizon.gios.gov.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752609Ab0EPVMn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 May 2010 17:12:43 -0400
In-Reply-To: <1274042826.2299.26.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2010-05-16 22:47, Eric Dumazet wrote:
> Le dimanche 16 mai 2010 =C3=A0 22:34 +0200, Krzysztof Ol=C4=99dzki a =
=C3=A9crit :
>> On 2010-05-16 22:15, Eric Dumazet wrote:
>
>>> All tx packets through bonding will use txqueue 0, since bnx2 doesn=
t
>>> provide a ndo_select_queue() function.
>>
>> OK, that explains everything. Thank you Eric. I assume it may take s=
ome
>> time for bonding to become multiqueue aware and/or bnx2x to provide
>> ndo_select_queue?
>>
>
> bonding might become multiqueue aware, there are several patches
> floating around.
>
> But with your ping tests, it wont change the selected txqueue anyway =
(it
> will be the same for any targets, because skb_tx_hash() wont hash the
> destination address, only the skb->protocol.

What do you mean by "wont hash the destination address, only the=20
skb->protocol"? It won't hash the destination address for ICMP or for=20
all IP protocols?

My normal workload is TCP and UDP based so if it is only ICMP then ther=
e=20
is no problem. Actually I have noticeably more UDP traffic than an=20
average network, mainly because of LWAPP/CAPWAP, so I'm interested in=20
good performance for both TCP and UDP.

During my initial tests ICMP ping showed the same behavior like UDP/TCP=
=20
with iperf, so I sticked with it. I'll redo everyting with UDP and TCP=20
of course. :)

>> BTW: With a normal router workload, should I expect big performance =
drop
>> when receiving and forwarding the same packet using different CPUs?
>> Bonding provides very important functionality, I'm not able to drop =
it. :(
>>
>
> Not sure what you mean by forwarding same packet using different CPUs=
=2E
> You probably meant different queues, because in normal case, only one
> cpu is involved (the one receiving the packet is also the one
> transmitting it, unless you have congestion or trafic shaping)

I mean to receive it on a one CPU and to send it on a different one. I=20
would like to assing different vectors (eth1-0 .. eth1-4) to different=20
CPUs, but with bnx2x+bonding packets are received on queues 1-4 (eth1-1=
=20
=2E. eth1-4) and sent from queue 0 (eth1-0). So, for a one packet, two=20
different CPUs will be involved (RX on q1-q4, TX on q0).

> If you have 4 cpus, you can use following patch and have a transparen=
t
> bonding against multiqueue.

Thanks! If I get it right: with the patch, packets should be sent using=
=20
the same CPU (queue?) that was used when receiving?

> Still bonding xmit path hits a global
> rwlock, so performance is not what you can get without bonding.

It may not be perfect, but it should be much better than nothing, right=
?

Best regards,

			Krzysztof Ol=C4=99dzki
